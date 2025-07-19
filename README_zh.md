Hexo 🐋
============

[English](./README.md) | 简体中文

Docker 版的 Hexo 和 Hexo Admin

这是一个使用最新版Node.js 的Hexo，当前版本是 Node.js 24

[https://github.com/SeeDLL/Ubuntu_Docker](https://github.com/SeeDLL/Ubuntu_Docker)

The image is available directly from [Docker Hub](https://hub.docker.com/r/seedll/hexo/)

### 感谢以下项目:

Node.js :
[https://hub.docker.com/_/node ](https://hub.docker.com/_/node "https://hub.docker.com/_/node")

Hexo Blog:
[https://hexo.io ](https://hexo.io "https://hexo.io")  


### docker命令行设置：

1. 下载镜像

   | 镜像源    | 命令                           |
   | :-------- | :----------------------------- |
   | DockerHub | docker pull seedll/hexo:latest |

2. 创建 aliyunpan 容器

   ```dockerfile
   docker create \
      --name=hexo \
      -p 4000:13389 \
      -e HEXO_SERVER_PORT=13389 \
      -e RUN_MODE=server \
      -e APP_CHECK_UPDATE=true \
      -e CUSTOM_SCRIPTS=true \
      -e CUSTOM_SCRIPT1="xx1.sh" \
      -e CUSTOM_SCRIPT2="xx2.sh" \
      -e GIT_USER=xxxxxx \
      -e GIT_EMAIL=xxxxxx@gmail.com \
      -e LANG=h-cn \
      -v {your hexo dir path}:/app \
      -v {your custom script dir path}:/custom_scripts \
      --restart unless-stopped \
      seedll/hexo:latest
   ```


| 变量                | 属性                                                         |
| :------------------ | :----------------------------------------------------------- |
| -e HEXO_SERVER_PORT | 指定                                                         |
| -e RUN_MODE         | 指定 Hexo 运行模式，有 服务器模式<server> 和 网页生成模式< build> ，默认为服务器模式-server |
| -e APP_CHECK_UPDATE | 每次启动容器的时候检查并升级 hexo 和所需模块的最新版本       |
| -e CUSTOM_SCRIPTS   | true or false                                                |
| -e CUSTOM_SCRIPT1   | 自定义脚本 1 的文件名，可以在requirements.txt 模块安装之前进行自定义操作 |
| -e CUSTOM_SCRIPT2   | 自定义脚本 2 的文件名，在 requirements.txt 模块安装之后进行自定义操作 |
| -e GIT_USER         | 配置 Git 用户名                                              |
| -e GIT_EMAIL        | 配置 Git 邮箱                                                |
| /app                | 容器中，存放 Hexo 项目源文件的目录                           |
| /custom_scripts     | 容器中，存放自定义脚本的目录                                 |
| -e LANG=zh-cn | 容器中，配置项目的显示语言：zh-cn：显示中文。en_US：显示英文 |



### 注意：

   * 如果 -v 指定的目录是空目录，则会自动初始化全新的完整的 Hexo 相关配置和页面。

   * 如果 -v 指定的目录已经有现成的 Hexo 文件，但不包含 node_modules 目录，则会初始化 node_modules 目录。

   * 如果 -v 指定的目录已经有 requirements.txt ，则会在 node_modules 初始化完成后，安装 requirements.txt  中所需的模块。

   * 如果需要每次容器启动的时候检查并升级 hexo和所需模块版本，可以指定 APP_CHECK_UPDATE=true 即可实现检查并升级。

3. 运行

   1. 我只需要生成静态网页

   ````
   sudo docker run  -it -d --name=GithubBlog \
     -e HEXO_SERVER_PORT=4000 \
     -e RUN_MODE=build \
     -e CUSTOM_SCRIPTS=true \
     -e CUSTOM_SCRIPT1="diy1.sh" \
     -e CUSTOM_SCRIPT2="diy2.sh" \
     -v /home/temp/code/MyBolgSource/:/app \
     -v /home/temp/code/custDir:/custom_scripts \
     -p 127.0.0.1:4000:4000 \
     seedll/hexo
   ````

   2. 我只需要服务器模式

   ````
   sudo docker run  -it -d --name=GithubBlog \
     -e HEXO_SERVER_PORT=4000 \
       -e RUN_MODE=server \
     -e CUSTOM_SCRIPTS=true \
     -e CUSTOM_SCRIPT1="diy1.sh" \
     -e CUSTOM_SCRIPT2="diy2.sh" \
     -v /home/temp/code/MyBolgSource/:/app \
     -v /home/temp/code/custDir:/custom_scripts \
     -p 127.0.0.1:4000:4000 \
     seedll/hexo
   ````

4. 停止

       docker stop hexo

5. 删除容器

       docker rm hexo

6. 删除镜像

       docker image rm seedll/hexo:latest