---
title: 云计算实验：在 Windows 平台搭建 Hadoop
tags:
  - Hadoop
  - 云计算
  - 课程
  - 实验报告
categories: 课程报告
date: 2023-05-23T19:00:56.000Z
---


## 前言

云计算课程大作业：在本机配置一个 Hadoop 环境 <!-- more -->

## 准备工作

Hadoop 有三种运行模式：本地、伪分布、完全分布。由于这只是一次实验，我选择的是在本机搭建运行 Hadoop 的伪分布模式。此模式下，Hadoop 守护进程运行在本地机器上，模拟一个小规模的集群，形式上与完全分布相同，使用不同端口代表不同的机器。 我选择的平台与版本如下：

- Windows 11
- Java 16.0.1
- winutils 3.3.1
- Hadoop 3.3.5

## 实验过程

### 下载

在 Apache 官网下载 Hadoop 的已编译版本，解压至指定目录（此处是 C:/Hadoop）中。

由于我已经装了 Java，所以本次实验我省略安装 Java 的步骤。

由于 Windows 不是 Hadoop 的最初开发和运行平台，目前支持还较为有限。为此，需要额外下载工具 winutils。此工具最初由官方社区开发者维护，但是较新版本来自开发者 github/kontext-tech。下载后放入 C:\hadoop\bin 文件夹内并复制一份hadoop.dll放到C:\Windows\System32下。yarn 已内置于此工具内。

### 配置文件

新建环境变量 HADOOP_HOME 指向 Hadoop 文件夹。Path添加 Hadoop 文件夹下 \bin 和 \sbin 文件夹的地址。完成后可以在终端内通过`hadoop version`检查是否能被正常识别且无错。

在 \Hadoop 文件夹下新建文件夹如下：

- \tmp
- \data\datanode
- \data\namenode

在 \Hadoop\etc\hadoop 文件夹下,修改 core-site.xml 文件如下：

```xml
<configuration>
    <property>
      <name>hadoop.tmp.dir</name>
      <value>/C:/hadoop/hadoop-3.1.3/data</value>
    </property>
    <property>
      <name>fs.defaultFS</name>
      <value>hdfs://your_host_name_or_localhost:9123</value>
    </property>
</configuration>
```

同文件夹下，，修改 hadoop-env.cmd 中的 Java_home 项的值为环境变量中 JAVA_HOME 的值，即指定 JDK 地址。

修改 hdfs-site.xml 文件如下，指定节点数量和实际存储地址。

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/C:/hadoop/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/C:/hadoopdata/datanode</value>
    </property>
</configuration>
```

修改mapred-site.xml

```xml
<configuration>
     <property>
         <name>mapreduce.framework.name</name>
          <value>yarn</value>
    </property>
</configuration>
```

修改yarn-site.xml

```xml
<configuration>
  <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
 <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hahoop.mapred.ShuffleHandler</value>
    </property>
</configuration>
```

特别地，在完成上述步骤后我遇到了端口冲突的问题，为了解决此问题，在 hdfs-site.xml 文件中继续添加参数如下:

```xml
<property>
    <name>dfs.namenode.http-address</name>
    <value>hdfs://localhost:9856</value>
  </property>
  <property>
    <name>dfs.datanode.http.address</name>
    <value>hdfs://localhost:9857</value>
  </property>
  <property>
    <name>dfs.datanode.address</name>
    <value>hdfs://localhost:9858</value>
  </property>
```

### 格式化与启动

在终端中输入

```cmd
hdfs namenode -format
```

进行节点格式化。观察到输出末尾有`namenode has been successfully formatted` 字样即格式化成功。

随后启动 \hadoop\sbin 目录下的 start-all.cmd。如果一切正常，那么将会弹出四个终端窗口且无报错。此时即已正常运行 Hadoop。

### 检查

在浏览器输入 localhost:9857 和 localhost:9856，访问 datanode 和 namenode。

使用 `hadoop fs -put <local_file> <hdfs_destination>` 命令上传文件、`hadoop fs -get <hdfs_file> <local_destination>`下载文件。创建文件夹（-mkdir）、列出文件（-ls）、删除文件（-rm）等命令与 Linux 系统相似。可以 在namenode中可以观察到上传成功，也可以使用 -ls 命令检查。

## 遇到的各种问题

1. winutils 的版本问题

   最早的 Wintils 是由 [Stevelougran开发的](https://github.com/steveloughran/winutils)，他是 Hadoop 的提交者（committer）之一。由于忙碌，此仓库停留在了 3.0.0 版本，而后[cdarlint继续开发](https://github.com/cdarlint/winutils)并停留在了 3.2.2 版本，而[kontext-tech继续](https://github.com/kontext-tech/winutils/tree/master)在Fork cdarlint 后开发。 与本次作业的 Hadoop 版本（3.3.5）最接近的是 kontext-tech 的 3.3.1 版本，本次使用的就是此版本。经验证，能正常工作。

2. `yarn --version` 无结果

    winutils 中包含了运行 Hadoop所需的 yarn，但是这一过程中我们没有给 yarn 配置环境变量，运行上述命令不成功。不过 yarn 实际上已经可以正常运行了。我们可以使用 `where yarn`（cmd）或`where.exe yarn`(powershell)来检查 yarn 存在的位置。

3. JAVA_HOME 的配置细节

   需要注意的是，在 cmd 文件中 JAVA_HOME 指向使用的 Java 的地址。此地址不应该包含空格也**不能**通过打双引号的方式规避空格问题。二者的报错不一样但是均会有影响。前者为"Error JAVA_HOME is incorrectly set.",后者为"The filename, directory name, or volume label syntax is incorrect hadoop" 针对空格源自 `Progame files` 的情况，可以通过改写为 `PROGRA~1` 来表达含义同时规避空格问题。（这是由于早期文件夹名不能包含空格引起的） 此外，电脑上还可能含有多个 Java 版本。通过如问题2所述 `where` 语句，我们可以检查到底有几个 Java 版本，在环境变量中调整顺序，使得需要的版本最前，即可保证 `Java --version`的检查结果和后续使用的是同一个版本。

4. 格式化时结尾为"SHUTDOWN_MSG: Shutting down NameNode at xxxx"

   这是正常现象，只要在其上可以找到`namenode has been successfully formatted`即可。

5. start-all.cmd 时出现"error Couldn't find a package.json file in \hadoop-2.7.7\sbin"错误

    这一错误是由于有多个 yarn 引起的。例如 winutils 中包含了 yarn 而自己随后又通过 npm 安装了yarn。我选择了暂时卸载后者即可解决问题。
6. 端口被占用

   正常来说，我们可以通过杀死对应端口进程来结束占用。检查端口被进程占用的方法是终端中输入`netstat -aon|findstr [端口号]` 。然后结束对应进程（如果无返回结果则说明此端口无占用）。 但是奇怪的是我一开始并没有发现有什么进程占用了端口。不过通过上述第二部分改端口配置，可以成功解决 namenode 的端口占用问题。而 datanode 则还加了一次重启的步骤。 运行 start-all.cmd 后，可以通过使用 `netstat -aon|findstr [端口号]` node 对应端口号的方式确定程序在正常工作：各端口均有一个进程。

7. 一个建议：

   在配置过程中，不免频繁输入各类命令：例如不断运行 start-all.cmd 同时检查进程。这个过程中可以善用 Windows 终端的多窗口功能，将命令进行分类，使得窗口更加美观。不过，更改了环境变量以后，需要重新打开终端（而非shell）来使其生效。+

## 参考资料

- [WIN10安装配置Hadoop-知乎](https://zhuanlan.zhihu.com/p/111844817)
- [如何在windows系统下安装hadoop-CSDN](https://blog.csdn.net/weixin_43627314/article/details/109245056)
- [Install Hadoop 3.3.0 on Windows 10 Step by Step Guide](https://kontext.tech/article/447/install-hadoop-330-on-windows-10-step-by-step-guide)
- [hadoop中修改端口号-李悠然-博客园](https://www.cnblogs.com/youran-he/p/8250040.html)
