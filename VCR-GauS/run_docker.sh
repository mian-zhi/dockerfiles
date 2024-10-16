# -t 选项让Docker分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上， -i 则让容器的标准输入保持打开
# --gpus all 分配GPU
docker run --gpus all  -it --name test --rm vcr_gaus:v1.0