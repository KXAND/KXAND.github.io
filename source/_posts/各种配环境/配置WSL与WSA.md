---
title: 配置 WSL 与 WSA
tags: 
  - WSL
  - WSA
categories: 各种配环境
date: 2023-12-10 17:40:37
# tags请写：来源（如课程）、体裁或用途（如笔记）并适当清晰化，如具体为（课程，图形学）
---

## 前言

其实很久之前配过，但是有奇奇怪怪的问题，也没有完全搞懂，干脆重新配了一遍。 <!-- more -->

## WSL 的配置

首先为啥要搞 WSL：

1. 好玩；
2. 一个更方便也更有更强性能的 linux 系统，例如可以使用 Terminal 应用统一管理 shell。

我会使用目前最新的 Windows 11 配置 WSL 2，这也是目前主流的 WSL，如果你想了解 WSL 1，请参考官方文档。

下面是具体步骤。

### 安装 WSL

打开Terminal，使用命令 `wsl --install` 安装默认最新的 Ubuntu，或者直接的 Microsoft Store 搜索对应发行版安装需要的版本即可。

如果是想要安装其它的发行版本，使用 `wsl --list --online` 检查可用的官方发行版，然后用 `wsl --install -d <DistroName>` 安装对应的发行版。

如果有之前搞崩的了的版本需要卸载，需要使用 `wsl --unregister <DistributionName>`，才能清楚所有个人信息，直接在 windows 中卸载是不会删除个人数据的。

然后你就得到了一个崭新的 Ubuntu。输入账号密码即可创建你的账户。

> Terminal 启动会自动登录该账户，所以我不建议你设一个巨复杂的密码。毕竟如果是不常用很容易忘，而且要安全你应该首先就不应该让别人接触到你的 Windows 账户。

此后，Terminal 中输入 `WSL`/`Ubuntu`或直接在开始菜单中输入上述字符串都可以直接启动 WSL 了。

### 配置 WSL

1. 使用 `sudo apt update && sudo apt upgrade` 更新包；
2. 使用 `git --version` 检查是否有 git，现在应该是自带的；
3. VSCode“远程”连接到WSL：在 VSCode 中安装 `Remote Development` 扩展包，然后在 VSC 命令面板选择连接到 WSL，即可在 VSC 中打开 WSL 文件夹进行开发等操作。也可以在 WSL 的对应路径下输入 `code .`，VSC 会自动启动并连接到 WSL 定位到该目录下。把后面的 `.` 换成对应的相对路径也是可行的。
4. 安装一些 GUI 应用：
   1. 文本编辑器 gnome-text-editor：`sudo apt install gnome-text-editor -y`
   2. 文件管理器 nautilus：`sudo apt install nautilus -y`
   3. 火狐浏览器：`sudo apt install firefox`
   安装后可能会出现闪屏的现象，一开始以为是驱动的问题，不过驱动实际上是不需要动或者说动不了的，重启一下就好了。
5. 安装中文字体，不然无法显示:
    `sudo apt-get install fonts-wqy-microhei # 安装文泉驿微米黑字体`
    `sudo apt-get install fonts-wqy-zenhei # 安装文泉驿正黑字体`
    `sudo apt-get install xfonts-wqy # 安装文泉驿点阵宋体`
6. 设置代理，也许你能参考[为 WSL2 一键设置代理 - 知乎](https://zhuanlan.zhihu.com/p/153124468)，但是我使用 Clash 是目前没有配成功。

基本上你可以完全参考 [适用于 Linux 的 Windows 子系统文档 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/wsl/) 中从“概述”到“教程”这几节的东西完成配置，只不过中文本地化的问题会有些麻烦。而且我目前没找到中文输入的手段，只不过由于能直接 Windows 复制粘贴到 WSL，这也就是一个麻烦，不至于成为无法完成的事情。

## WSA 的配置

WSA 使用 Amazon Appstore （而不是Google Play）作为官方应用商店，直接在 Microsoft Store 中搜索 Amazon Appstore 进行下载即可自动安装。

由于 Amazon Appstore 相当垃圾，不仅需要美区 Amazon 号还 app 数量少，所以可以考虑下面的方法启动侧载。

首先在 Windows Subsystem for Android 中`高级设置`中启用`开发者模式`，点击管理开发者选项启用`USB 调试`。在 Windows Terminal中输入`adb devices` 检查现在是否有被 adb 连接的设备。你也可以直接通过 adb 安装 app，但是更方便的办法是通过软件完成。在 Microsoft Store 中下载 WSATools 或者其它类似的软件，启动并选择对应的应用 apk 就可以进行安装了。这样的安装本质也是通过 adb 的，因此你可能需要在弹窗中授予权限。

这部分写得很简略是因为我 WSA 重新配置的过程比较简单，如果你想要更细致的教程，这里是我参考的文章：

[【微软官方】如何安装WSA（附通过ADB安装应用） - 知乎](https://zhuanlan.zhihu.com/p/465269635)

此外，你也许也需要下面两个文档：

- [适用于 Android™️ 的 Windows 子系统 | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/android/wsa/#uninstalling-windows-subsystem-for-android)
- [Android 调试桥 (adb)  |  Android 开发者  |  Android Developers](https://developer.android.com/studio/command-line/adb?hl=zh-cn#Enabling)

> 我不是 Android 开发者，WSA 对我最主要的应用是游戏挂机，现在手游的空间对对我的 128G 千元机实在有些艰巨。几个月前，WSA 出现了奇妙的问题导致游戏无法正常更新，于是催生我一口气干脆把 WSA 和 WSL 重新配了一遍。其实不难，但是我还是了一点感悟，那就是**重装是真有用啊**。WSA 游戏无法正常更新（但是网易云app 可以正常联网）的 bug 在重装 WSA 后就轻松消失了。
