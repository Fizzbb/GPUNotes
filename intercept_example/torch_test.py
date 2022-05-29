import torch
device = torch.cuda.current_device()
print(device)
x = torch.randn(1024, 1024).to(device)
y = torch.randn(1024, 1024).to(device)
print("send x and y to device")
z = torch.matmul(x, y)
print("matmul is done")
