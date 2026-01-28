---
title: 用批处理简化hexo命令操作
tags:
  - bat
  - Hexo
categories: 
  - 各种配环境
  - 搭建博客
date: 2022-03-24 00:19:24
---

使用 git bash 新建博文过于繁琐，有没有更简单无脑的办法？
<!-- more -->

## 背景

搭建好博客网站后，之所以长时间没有更新，~~当然是因为本人懒狗~~，不过除此之外，hexo 糟糕的新建博文方法也是一大原因。

有两种方法可以新建一篇博文：

1. 在博客的本地地址建立一个新的 Markdown 文件，然后依次修改它的各部分内容。
2. 在博客的本地地址右键选择 git bash，然后输入命令进行操作。

第一个简单，但是糟糕的地方是头部信并不是自动生成的，需要从老博文里面复制。麻烦不说，时间戳不是自动生成的、混用 _drafts 和_posts 也总让我感觉有些难受。

第二个能自动生成头部信息，但是需要输入命令然后再关掉窗口打开编辑器，实际上也很麻烦。

但是，既然每次输入的命令都是类似的，这就自然让人想到能不能用例如 bat 批处理脚本来自动化这个过程。

答案是可以的， bat 脚本事实上就是一连串的命令。在 bat 文件中写 `hexo help` 和 新建一个 cmd 黑窗口输入 `hexo help` 没有任何差别。

使用批处理以后，可以从重复而繁琐的命令中解放时间，更好的专注于写作本身、也可以让草稿和博文真正的很清楚（而我还没有搞清楚hexo的开发者的初始设想到底是如何使用？想必不是让用户自己写批处理XD)

下面是脚本代码

## 实现

1. 新建博文草稿并用编辑器打开
    newDraft.bat

   ```dos
    @echo off
    @REM 跳转到博客地址
    D:
    cd D:\***\***
    @REM 输入文件名
    set /p name= input Name: 
    @REM 新建文件、唤起第二个脚本
    hexo new draft %name% && call openEditor.bat %name%
   ```

   openEditor.bat

   ```dos
    echo the input is %1
    set name=%1
    echo %name%
    start /d "C:\***\***\VSCode的安装地址\" Code.exe "D:\博客的本地地址\source\_drafts\%name%.md"
   ```

   这里，第一个脚本建立草稿文件，并唤起第二个脚本用编辑器（这里是VS Code）打开新建的 Markdown 文件。为什么不能写成一个文件这里我还不是非常清楚，似乎bat文件会在运行到 `hexo ***`后自动结束导致后面的命令运行不了。
2. 发布（Publish）文章
   publish.bat

   ```dos
    @echo off
    set /p publishBlog=
    hexo publish %publishBlog%
   ```

   此脚本将指定名字的 blog 发布到 _post 文件夹中。
3. 上传到博客网站
    deploy.bat

   ```dos
    start clean.bat
    start /min /w mshta vbscript:setTimeout("window.close()",2000)
    start generateAndDeploy.bat
    exit
   ```

   分别调用clean和generateAndDeploy，清理缓存、生成并部署。
    clean.bat

   ```dos
    @echo off
    hexo clean
    exit
   ```

    generateAndDeploy.bat

   ```dos
    hexo g -d
    exit
   ```

## 总结

1. 有效激发了本人的写作热情，写好脚本以后当场写（水）了这篇博文。
2. 算是对 bat 有了一点粗浅的认识，当然还有搞不懂的地方，例如为什么运行到` hexo *** `以后就退出了呢？还是需要以后再看，今天鉴于时间因素，还是就此暂停了。
3. 自己用命令测试的时候请记住要用 CMD 运行！powershell的话你大概会遇到`因为在此系统上禁止运行脚本`的错误,这里是可能的参考[解决方法](https://www.jianshu.com/p/4eaad2163567)。
4. 这篇文章是向CSDN上“蓝蓝223”的这篇文章:[《bat批处理脚本自动部署Hexo博客》](https://blog.csdn.net/qq_21808961/article/details/84868482)学习后的成果。我对代码进行了一点无关痛痒的小改动。
5. 代码块在MPE上预览要敲 `batch` 才有高亮，但是要生成的网页有中有高亮得敲 `dos`…… 我不理解orz
