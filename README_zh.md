Hexo 🐋
============

[English](./README.md) | 简体中文

Docker 版的 Hexo 和 Hexo Admin

这是一个使用最新版Node.js 的Hexo，当前版本是 Node.js 20

[https://github.com/SeeDLL/Ubuntu_Docker](https://github.com/SeeDLL/Ubuntu_Docker)

The image is available directly from [Docker Hub](https://hub.docker.com/r/seedll/hexo/)

### 感谢以下项目:

Node.js :
[https://hub.docker.com/_/node ](https://hub.docker.com/_/node "https://hub.docker.com/_/node")

Hexo Blog:
[https://hexo.io ](https://hexo.io "https://hexo.io")  

### 注意：

   * 如果 -v 指定的目录是空目录，本容器会自动初始化全新的完整的 Hexo 相关配置和页面。

   * 如果 -v 指定的目录已经有现成的 Hexo 文件，本容器不会在初始化 Hexo ，而是会直接运行目录中的 Hexo。

   * 如果 -v 指定的目录已经有 requirements.txt ，会安装 requirements.txt  中所需的模块。

   * 如果需要每次容器启动的时候检查并升级 hexo和所需模块版本，可以指定 APP_CHECK_UPDATE=true 即可实现检查并升级。

### docker命令行设置：

1. 下载镜像

    |镜像源|命令|
    |:-|:-|
    |DockerHub|docker pull seedll/hexo:latest|

2. 创建 aliyunpan 容器

        docker create \
           --name=hexo \
           -p 4000:13389 \
           -e HEXO_SERVER_PORT=13389 \
           -e APP_CHECK_UPDATE=true \
           -e GIT_USER=xxxxxx \
           -e GIT_EMAIL=xxxxxx@gmail.com \
           -v {your hexo dir path}/app \
           --restart unless-stopped \
           seedll/hexo:latest

3. 运行

       docker start hexo

4. 停止

       docker stop hexo

5. 删除容器

       docker rm hexo

6. 删除镜像

       docker image rm seedll/hexo:latest

### 变量参数设置:

|参数|说明|
|:-|:-|
| `-e HEXO_SERVER_PORT` | hexo server port(default port 4000) |
| `-e APP_CHECK_UPDATE` | check and update package version |
| `-e GIT_USER` | git user |
| `-e GIT_EMAIL` | git email |


