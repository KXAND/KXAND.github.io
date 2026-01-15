---
title: 在VSC上使用Typecript刷LeetCode
tags: 
  - VSCode
  - Typescript
categories: 各种配环境
date: 2025-05-01 16:53:36
---

## 前言

最近开始学习 TS 了，刚巧又在刷题。于是想到能不能像 C++ 一样用 TS 在 VSC 上刷 LeetCode 呢？这种做法似乎不算很常规——TS 一般的用途还是做 App。实际搭建的过程也遇到了一点麻烦，所以做个记录。 <!-- more -->

## 安装

想到这篇博文的主题，是因为发现了这个 LeetCode 官方插件：

[LeetCode - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=LeetCode.vscode-leetcode&ssr=false#qna)

它允许在 VSCode 上查看题目、提交代码。

这样做还是挺有优点的，毕竟 LeetCode 不像牛客，没有会员无法在线调试。而且我们也可能希望把写过的题目源码保存在本地。

总之，我们需要安装 VSC、LeetCode 插件、以及 TypeScript、Node.js 等等不提。

此外，我们还可以建立一个工作区 （WorkSpace）以便于管理。

最后，一般来说，TypeScript 编译后会生成对应的 .js 文件，然后可以利用 node 等来调试 .js 文件：

```shell
%% 编译 %%
tsc a.ts
%% 编译成指定文件名 %%
tsc .\a.ts --outfile debug.js
%% 调试或运行 %%
node debug.js
```

这样当然没错，但是这样没有办法很好的可视化调试，并且会生成 js 文件，让文件夹显得很乱。编译出来的 js 文件甚至会和原始 ts 文件函数命名冲突导致报警告——因为默认情况下它们都属于同一个项目。

> 其实也有在工作区中隐藏 .js 文件的方法，详见参考文献 1。

为此，我们需要使用 ts-node 包。它可以不经编译直接运行 TypeScript 代码，并且支持单文件脚本。

在 TypeScript 子文件夹下运行（其实在工作区 `主目录` 运行也行，只是在 `子目录` 的话就不会暴露 node_modules 了）：

```shell
pnpm add ts-node
```

## 调试配置

首先，我们需要添加一个 `tsconfig.json`。完全可以参照 参考文献 1 让 VSCode 自动生成，不过也可以自己写，内容参考如下（由我的 VSCode 生成）：

```json
{
    "compilerOptions": {
        "module": "ESNext",
        "moduleResolution": "Bundler",
        "target": "ES2022",
        "jsx": "react",
        "strictNullChecks": true,
        "strictFunctionTypes": true,
        "sourceMap": true
    },
    "exclude": [
        "node_modules",
        "**/node_modules/*"
    ]
}
```

可以放在 `父文件夹` 中，也可以放在 `子文件夹` 中。

然后，在 `.vscode/launch.json` 文件（可以由 `运行与调试` 侧栏中生成，也可以自行创建）中添加任务如下：

```json
"configurations": [
        {
        // 其它任务
        },
        {
            "type": "node",
            "name": "ts-node调试当前文件",
            "request": "launch",
            "program": "${file}",
            "cwd": "${workspaceFolder}/Typescript",
            "runtimeArgs": [
                "-r",
                "ts-node/register"
            ],
            "skipFiles": [
                "<node_internals>/**"
            ],
            "sourceMaps": true,
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen"
        }
    ]
```

其实意思就是在 `${workspaceFolder}/Typescript`（子文件夹）下运行 `node -r ts-node/register <当前ts文件>`。

然后，我们就可以愉快地打断点进行调试了。虽然此时不会像 C/C++ 那样显示一个按钮以供编译运行，但是我们直接按 `F5` 就可以正常调试运行了。

## LeetCode 插件配置

我们还需要调整一下 LeetCode 配置。

`ctrl+shift+P` 打开设置后，切换到 `用户设置` ，搜索 `Leetcode: Endpoint` 可以切换提交站点为 `中国站` 或 `国际站` 。然后相应地登录账号。

搜索 `Leetcode: File Path` 打开 用户设置 对应的 .json 文件，添加配置如下

```json
    "leetcode.filePath": {
        "typescript": {
            "folder": "\\Typescript",
            "filename": "${id}.${kebab-case-name}.${ext}"
        },
        "default": {
            "folder": "",
            "filename": "${id}.${kebab-case-name}.${ext}"
        }
```

这表示 LeetCode 插件为我们生成待完成的代码文件时，会把 Typescript 语言的文件生成在 `\\Typescript` 这个子文件夹下，文件名为`序号.名字.拓展名` 的形式。

> 如果你遵循和我一样的文件名生成方法，并且使用 中国站，那么由于文件名包含中文字符，我们就无法正常进行调试了。
>
> 这种情况下，我的解决方案是建立一个不包含中文字符的 debug.ts，如果由调试需要，就将代码拷贝到该文件下调试。当代码确认没有问题后，再拷回文件存档。
>
> 这样做的好处是保留了做过的题的名字，方便查找。如果你觉得这个没必要，那么也可以不做这一步。
>
## 参考文献

1. [编译 TypeScript – Compiling TypeScript – VSCode 文档](https://code.visualstudio.com/docs/typescript/typescript-compiling)
