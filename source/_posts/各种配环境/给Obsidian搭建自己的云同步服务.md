---
title: 给Obsidian搭建自己的云同步服务
tags: 
  - Obsidian
  - LiveSync
categories: 各种配环境
date: 2023-12-03 17:33:12
# tags请写：来源（如课程）、体裁或用途（如笔记）并适当清晰化，如具体为（课程，图形学）
---

## 前言

阿里云服务器 + docker + self-hosted Sync 插件给 Obsidian 搭建实时同步服务。  <!-- more -->

前几天准备给自己的武汉之旅写一篇很————长————的回忆记，但是这篇后来发现超过 5000 字的文章要是用手机码就麻烦了。原先 Obsidian 在我手里的定位就是手机便签加强版，根本没有考虑过同步的功能，现在为了写这个游记，只好开始想办法进行同步了。于是最后我就找到了博主"吕楪"的这一篇：[Obsidian免费的实时同步服务](https://irithys.com/p/obsidian-livesync/)。

很不幸，由于 fly.io 的政策改动，现在（2023年12月3日）它必须要求你有一个信用卡（而且非双币卡我怀疑不能认可），而且根据评论区消息，他们需要 $2/月 购买 IPv4 地址才能提供服务。既然如此，那么就不如自己在国内搞一个服务器了。

阿里云的学生福利允许通过任务最高领取 7 个月的免费 2 核 2G 服务器，即使不是学生，现在（2023年12月3日）腾讯云和阿里云也都有 100 元左右的 2 核 2G 服务器可以优惠购买。尽管这个价格和官方服务是差不多价格的，但是同步服务占用不大，因此性价比会比官方服务高很多。毕竟还可以跑其他的小东西玩呢。因此，我最后决定使用阿里云的云服务器部署同步服务，实现了 Windows + 安卓的实时同步功能。

下面正式开始论述步骤。

> 在开始配置同步前，最好将其它的同步插件（含官方插件），以及 Onedrive 等同步方式关闭，避免冲突问题。

## 配置服务器

我们的目标是在服务器上运行一个 CouchDB 数据库。

CouchDB 是 Apache 开发的一个开源 NoSQL 数据库，它使用 JSON 文档存储数据，通过 web 访问，使用JavaScript查询、合并和转换文档。

首先，你需要有一个服务器。我的意思是，像腾讯云 Cloudbase 云开发这样的 Serverless 产品，后台是腾讯云内建的数据库，需要通过 API 读写，就应该是不行的。~~（为什么我会知道这个呢）~~

参考云服务器的官方文档（可参见文末参考部分），连接到服务器，我这里使用的是 Workbench，主要是这个连接方式支持复制粘贴并且无需下载客户端。

随后参考另一篇云服务器官方文档（下述文档等均可参见文末参考部分），安装 Docker 和 docker-compose。

> 在 livesync 的官方文档中说道，“设置 CouchDB 的最简单方法是使用 CouchDB docker image”，并且推荐使用同时启动 Caddy 和 CouchDB 的另一方法。因此，这里安装了 Docker 和 docker-compose。

在服务器上，使用 `mkdir` 命令在合适的地方创建一个文件作为 CouchDB 容器的数据文件夹。在该文件夹下，使用 `touch` 命令创建一个名为 `local.ini` 的文件，这是要修改数据库以让它可以用于 Self-hosted LiveSync。使用 vim 或任何其他编辑器打开并粘贴以下内容：

```ini
[couchdb]
single_node=true
max_document_size = 50000000

[chttpd]
require_valid_user = true
max_http_request_size = 4294967296

[chttpd_auth]
require_valid_user = true
authentication_redirect = /_utils/session.html

[httpd]
WWW-Authenticate = Basic realm="couchdb"
enable_cors = true

[cors]
origins = app://obsidian.md,capacitor://localhost,http://localhost
credentials = true
headers = accept, authorization, content-type, origin, referer
methods = GET, PUT, POST, HEAD, DELETE
max_age = 3600
```

再在该文件夹下创建一个 `docker-compose.yml` 文件，打开，贴入以下内容

```yml
version: "2.1"
services:
  couchdb:
    image: couchdb
    container_name: obsidian-livesync
    user: 1000:1000
    environment:
      - COUCHDB_USER=admin
      - COUCHDB_PASSWORD=password
    volumes:
      - ./data:/opt/couchdb/data
      - ./local.ini:/opt/couchdb/etc/local.ini
    ports:
      - 5984:5984
    restart: unless-stopped
```

> ❗请根据需要修改文中 `./local.ini` 、`environment` 以及 `container_name` ，的值。

运行下面这个命令

```shell
docker compose up -d
```

docker 就会自动拉取 couchDB 镜像并配置好。

运行下面这个命令，检查容器是否已经开始运行

```shell
docker ps
```

如果看到了前面设置的 `container_name` ，那么容器已经在运行了。由于服务器没有图形化窗口，这里需要转到阿里云的实例的安全组中， 给“入方向”添加 5984 端口，允许外界访问服务器的 5984 端口。

下面转到本地操作。

### 在网页端创建数据库

在 PC 上访问 `http://[你的服务器公网IP]:5984/_utils`。你应该就能看见图形化界面了。

> 如果拒绝访问，你可能需要写成这种形式`http://[你的用户名]:[你的密码]@[你的服务器公网IP]:5984/_utils`。这里的用户名和密码都是前面的 `docker-compose.yml` 中设置的。

点击网页右上角的 `Create Database`，创建一个数据库，其中 `Database name` 为数据库名字，`Partitioned` 不应该被勾选，然后点 `Create` 创建。

接着点开图标为扳手🔧的 `Setup` 选项卡，依次填入上述配置的管理员姓名和密码凭据，`Bind address` 一栏应保持为 `0.0.0.0` 才能允许所有的 IP 访问，最后，端口写 5984。

最后，点开齿轮⚙️图标的 `Config` 选项卡，点选 CORS，启用，允许直接从浏览器连接到远程服务器并与 CouchDB 对话以加载数据。

> 页面可能会提示报错，你需要刷新页面检查确实是启用并设置为 `All domains` 的就可以。

## 配置 Obsidian

在 Obsidian 本体软件中关闭安全模式，安装插件 `Self-hosted LiveSync` 并启用。

打开卫星图标🛰️的 `Remote Database configuration` 选项卡。输入自己的数据库网址、用户名、密码与数据库名。数据库网址形如：`http://[你的服务器IP地址]:5984`，用户名、密码与数据库名都是在上一节数据库网页设定的。

点击 `Test Database Connection`，若连接成功，则会提示 `connected`，否则，会提示那些步骤存在问题，按描述检查即可。

打开循环图标🔁的 `Sync Settings` 选项卡，将 `Sync Mode` 调整为 `Live Sync`，这样就是实时的同步，而非定时或定节点的保存。

> 一些建议设置：
>
> - 在 `Sync Settings` 选项卡中启用 `Use Trash for deleted files`，启用回收站而非直接删除；
> - 在齿轮图标⚙️的 `General Settings`中，检查启用 `Show staus inside editor`
>   - 💤：表示目前一切就绪
>   - ⚡：表示正在同步
>   - ⚠️：同步出现错误
>   - ↑和↓：表示本次启动以来上传和下载了多少数据
>   - 其它的图标感觉都不大容易碰到，这里略过。
> - 在卫星图标🛰️的 `Remote Database configuration` 选项卡中的 `Confidentiality` 启用端到端加密和路径混淆（Path Obfuscation）并配置加密密码，保护数据。（可能会导致重建数据库）

## 配置第二台设备

继续在上述已经配好的设备的 LiveSync插件上，点选魔法师图标的🧙 `Setup Wizard`选项卡，点选`Copy Setup URI`，输入一个加密密码，生成口令。将其发送到我们需要设置的另一设备。

在第二台设备（例如安卓手机）上，打开同样的选项卡，点击`Open Setup URI`，依次输入口令和加密码进行解密。选择“将其设置为第二或后续设备”，最后同样点击 `Test Database Connection` 检查确实已经连接成功即可。

接下来就可以通过创建文件，打几段话试试同步效果，最后继续写作之旅了。

## 参考和推荐阅读

1. 本文的主要参考对象，吕楪的博客，有一些细节比本文更丰富（毕竟中译中就没意思了）：[Obsidian 免费的实时同步服务](https://irithys.com/p/obsidian-livesync/#%E4%BF%AE%E5%A4%8D%E8%BF%9E%E6%8E%A5)
2. 插件官方提供的设置 CouchDB 教程（顺便一提官方的其它中文文档也值得一看）：[obsidian-livesync/docs/setup_own_server_cn.md at main · vrtmrz/obsidian-livesync](https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server_cn.md)
3. 如果你想了解其它的同步方式，同样是吕楪大佬的：[Obsidian 各种同步方式体验](https://irithys.com/p/obsidian-%E5%90%84%E7%A7%8D%E5%90%8C%E6%AD%A5%E6%96%B9%E5%BC%8F%E4%BD%93%E9%AA%8C/#android%E7%AB%AF%E6%93%8D%E4%BD%9C)
4. 另一篇关于 Obsidian 不同同步方式的文章：[Obsidian 免费同步方案 - 知乎](https://zhuanlan.zhihu.com/p/531516583)
5. 了解如何连接到服务器（阿里云）：[云服务器ECS连接方式介绍与对比_云服务器 ECS-阿里云帮助中心](https://help.aliyun.com/zh/ecs/user-guide/connection-methods#concept-tmr-pgx-wdb)
6. 在阿里云（CentOS 或 Alibaba Cloud Linux）云服务器上安装 Docker：[安装Docker并使用_云服务器 ECS-阿里云帮助中心](https://help.aliyun.com/zh/ecs/use-cases/deploy-and-use-docker-on-alibaba-cloud-linux-2-instances)
