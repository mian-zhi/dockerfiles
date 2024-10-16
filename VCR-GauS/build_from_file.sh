echo "build image:"

# 禁用 BuildKit：DOCKER_BUILDKIT=0 表示禁用 Docker BuildKit，这会强制 Docker 使用传统的构建模式，而不是 BuildKit 构建模式。
# BuildKit 是 Docker 在较新版本中引入的默认构建模式，它具有更高效的缓存和构建功能，通常用于加速构建并支持更高级的构建功能。
# 然而，在某些情况下，传统模式可能更兼容或更符合特定的需求。

# -t 标志用于给生成的镜像命名和打标签。
# my_image:v1.0 是生成的 Docker 镜像的名称（my_image）和版本标签（v1.0）

# --build-arg 选项用于向 Docker 构建过程传递构建参数
# http_proxy=http://10.0.1.68:18889 指定了一个 HTTP 代理服务器，地址为 http://10.0.1.68:18889，用于镜像构建过程中网络连接时的代理配置
# 这通常用于在需要通过代理服务器访问外部网络的环境中，确保 apt-get、pip 等工具能够通过指定的代理下载所需的依赖包。
DOCKER_BUILDKIT=0 docker build -t vcr_gaus:v1.0 --build-arg http_proxy=http://10.0.1.68:18889 --build-arg https_proxy=http://10.0.1.68:18889 .
# DOCKER_BUILDKIT=0 docker build -t vcr_gaus:v1.0 --build-arg http_proxy=http://127.0.0.1:7890 --build-arg https_proxy=http://127.0.0.1:7890 .
# DOCKER_BUILDKIT=0 docker build -t vcr_gaus:v1.0 .