import tensorflow as tf
import tensorflow_datasets as tfds
import datetime
import time
import os
import argparse
# from tensorflow.contrib.memory_stats.python.ops.memory_stats_ops import BytesInUse

from tensorflow.compat.v1.keras.backend import set_session
from tensorflow.compat.v1 import Session, ConfigProto, GPUOptions
# tf_config = ConfigProto(gpu_options=GPUOptions(allow_growth=True))
# session = Session(config=tf_config)
# set_session(session)


parser = argparse.ArgumentParser()
parser.add_argument('-e', '--epochs', default=5, type=int, metavar='N',
                    help='number of total epochs to run')
parser.add_argument('-b', '--batch', default=256, type=int,
                    help='batch size')
parser.add_argument('-m', '--memory', default=5000, type=float,
                    help='memory limit (max 12196 on titan)')
args = parser.parse_args()

# tf.debugging.set_log_device_placement(True)
#gpus = tf.config.list_physical_devices('GPU')
#tf.config.experimental.set_virtual_device_configuration(
#        gpus[0],
#        [tf.config.experimental.VirtualDeviceConfiguration(memory_limit=4096)])

(ds_train, ds_test), ds_info = tfds.load(
    'mnist',
    split=['train', 'test'],
    shuffle_files=True,
    as_supervised=True,
    with_info=True,
)

batch = args.batch

def normalize_img(image, label):
  """Normalizes images: `uint8` -> `float32`."""
  return tf.cast(image, tf.float32) / 255., label

ds_train = ds_train.map(
    normalize_img, num_parallel_calls=tf.data.AUTOTUNE)
ds_train = ds_train.cache()
ds_train = ds_train.shuffle(ds_info.splits['train'].num_examples)
ds_train = ds_train.batch(32)
ds_train = ds_train.prefetch(tf.data.AUTOTUNE)

ds_test = ds_test.map(
    normalize_img, num_parallel_calls=tf.data.AUTOTUNE)
ds_test = ds_test.batch(batch)
ds_test = ds_test.cache()
ds_test = ds_test.prefetch(tf.data.AUTOTUNE)

# model = tf.keras.models.Sequential([
#   tf.keras.layers.Flatten(input_shape=(28, 28)),
#   tf.keras.layers.Dense(batch, activation='relu'),
#   tf.keras.layers.Dense(10)
# ])
model = tf.keras.Sequential([
    tf.keras.layers.Conv2D(32, [3, 3], activation='relu'),
    tf.keras.layers.Conv2D(64, [3, 3], activation='relu'),
    tf.keras.layers.MaxPooling2D(pool_size=(2, 2)),
    tf.keras.layers.Dropout(0.25),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dropout(0.5),
    tf.keras.layers.Dense(10, activation='softmax')
])
model.compile(
    optimizer=tf.keras.optimizers.Adam(0.001),
    loss=tf.keras.losses.SparseCategoricalCrossentropy(),
    metrics=[tf.keras.metrics.SparseCategoricalAccuracy()],
)
#log_dir = 'rlogs/' + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
#tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1, profile_batch = '500,520')
#tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
start = time.perf_counter()
# print('before training, memory usage: {}'.format(tf.config.experimental.get_memory_usage('GPU:0')))

with tf.device("/gpu:0"):
    model.fit(
            ds_train,
            epochs=args.epochs,
            validation_data=ds_test,
            #callbacks=[tensorboard_callback]
        )

elapsed = time.perf_counter() - start

# print('after training, memory usage: {}'.format(tf.config.experimental.get_memory_usage('GPU:0')))
print('Elapsed %.3f seconds.' % elapsed)
