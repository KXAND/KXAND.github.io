---
title: 解决 VSCode 无法识别用户环境变量的问题
tags: 
  - VSCode
  - Prompt
categories: 各种配环境
date: 2025-07-09 13:14:38
---

## 前言

VSCode 在一定条件下，无法识别用户环境变量的一种解决方式。 <!-- more -->

## 问题描述

不知道从什么时候起，VS Code 突然无法读取用户环境变量了，只能读取到系统环境变量。这事最直观的体现就是，oh-my-posh 无法正常工作了，很烦人。

具体来说，我面临的情况是这样的：

- 我在 Windows 11 上使用 PowerShell 7 和 VS Code
- 我的用户环境变量的 PATH 和系统环境变量的 PATH 并不保持一致，其中最显著的区别就是 oh-my-posh 的路径是写在用户环境变量中。当然，二者不止这些差别，例如我的 yarn 也是写在用户环境变量中。
- 当我从 VSCode 终端启动 PowerShell 等 Shell 时时，这些用户环境变量不能被正常读取。这些用户环境变量没有被加载：$env:PATH 中只包含系统环境变量，不包含用户变量，其他自定义变量也都缺失。这种现象最显著的结果是，每次打开终端我只能看到一个红红的报错信息，看不到 oh-my-posh 美化过的结果。当然问题不止于此，实际上 CMD 等其它 Shell 也无法读取用户环境变量。
- 如果通过 Windows Terminal 启动 Powershell，或者使用管理员模式打开 VS Code。用户环境变量就能正常读取。因此，问题出现在 VSCode 而非 PowerShell 或 oh-my-posh。
  
这个问题无法通过“以后只用管理员模式启动 VS Code”解决，因为 VS Code 管理员模式下只能启动一个实例，这很不方便。尽管有一段时间我就是这么干的。同时，只是简单粗暴地将用户环境变量同步移植到系统环境变量虽然看似能解决问题，但是实际上只是在掩盖问题，因此我们不希望这么干。

这种现象还挺稀有的，我只在 Reddit 上找到了一例相同的情况：[User Env Variables wont be read when starting powershell with “pwsh” (version 7.2.5.0) : r/PowerShell](https://www.reddit.com/r/PowerShell/comments/wdhhve/user_env_variables_wont_be_read_when_starting/)
解决方案
我目前的解决方案是在 Microsoft.PowerShell_profile.ps1 文件首行中写入如下指令

```bash
# 合并系统 PATH 和用户 PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
```

这表示在 PowerShell 启动时，将 Path 环境变量自动设置为系统 PATH 变量和用户 PATH 变量的结合。尽管这没有根本解决 VS Code 的问题，但是暂时来说也足够了，因为实际使用中确实很少使用 CMD 等。
我现在的 Microsoft.PowerShell_profile.ps1 文件长这样：

```bash
# 合并系统 PATH 和用户 PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
oh-my-posh init pwsh  --config [我的用户文件地址]\AppData\Local\Programs\oh-my-posh\themes\multiverse-neon.omp.json | Invoke-Expression
```

需要注意的是拼接环境变量需要在唤醒 oh-my-posh 之前，否则第二行命令中调用的 oh-my-posh 就无法找到了。

上述解决方案由“通义 Qwen3”提供。如果你阅读了我上面提供的 Reddit 链解，你会发现这也是原 Po 使用的解决方案。

## 一点吐槽

这个问题我先后询问了三个 AI， Prompt 略有不同。其中唯一有效的解决方案来自通义千问。下面是一个简单的对比：

- ChatGPT: gpt-4o
  - prompt: `I put various paths into the user env like for oh-my-posh. But when pwsh isn't started via Terminal the path of the system and the user env values aren't concatenated. Indeed none of my user env variables are read. This is especially a problem for the invoke via directory context menu.阅读上述文字，搜索网页，给出解决永久的、安全的、方便的解决方案。`其中英文部分是上述 Reddit 链接楼主的描述，因为犯懒就没有自己写。
  - 解决方案：
    - 修改注册表上下文菜单命令以加载新环境：注册表是个大坑，既然我在安装 VSCode 和 oh-my-posh 等时没有动过注册表，那么我应该也不需要动注册表，以免发生预期外的行为。
    - 修改环境变量后，重启 Explorer 确保生效：这个是无稽之谈，因为我没有修改环境变量，并且 VS Code 是开机后的第一次启动。
    - 确保 PowerShell profile 自动加载 oh-my-posh：这个也是无稽之谈，无论是正常工作的 Terminal 还是 Code 中找不到 oh-my-posh 的报错，都证明 oh-my-posh 被自动加载了，问题出在环境变量的加载上。
- DeepSeek R1 深度思考
  - prompt: `I put various paths into the user env like for oh-my-posh. But when pwsh isn't started via Terminal the path of the system and the user env values aren't concatenated. Indeed none of my user env variables are read. This is especially a problem for the invoke via directory context menu.阅读上述文字，搜索网页，给出解决永久的、安全的、方便的解决方案。`
  - 解决方案：注册表持久化 + 启动脚本修正，和GPT一样，无需多说。
- Qwen3 深度思考
  - prompt：`I put various paths into the user env like for oh-my-posh. But when pwsh isn't started via Terminal the path of the system and the user env values aren't concatenated. Indeed none of my user env variables are read. This is especially a problem for the invoke via directory context menu.阅读上述文字，搜索网页，给出解决永久的、安全的、方便的解决方案。`
  - 解决方案：
    - 方法一：修改用户环境变量：不知所谓。
    - 方法二：修改PowerShell配置文件：正确答案，但是没有完全命中，这可能和 Prompt 写得不好有关。
    - 方法三：注册表修改（高级）：Qwen3将修改注册表排在最后并明确注明不推荐，这点我很喜欢。
可以看到 Qwen 的结果是更好的。不过实际上我在询问 Qwen 时并没有采用这串 Prompt， ~~上面 Qwen3 的结果是为了写博客补的，~~ 而是终于忍受不了，自己写了一个新的 Prompt：

> 我在 Windows 上使用 PowerShell 7和VSCode，并通过用户环境变量（如 PATH）添加了一些工具路径（例如 oh-my-posh）。当我从 VSCode 终端启动控制台如 PowerShell 时，这些用户环境变量不能被正常读取。这些用户环境变量没有被加载：$env:PATH 中只包含系统环境变量，不包含用户变量，其他自定义变量也都缺失。
>
> 这会导致 oh-my-posh 和其他工具无法使用。
>
> 注意，
>
> 1. 通过管理员模式启动VSCode时，以及通过Windows Terminal启动Shell时，用户环境变量可以被正常加载
非管理员模式启动VSCode时，任何Shell都无法正常加载用户环境变量
> 2. 对此，我需要你通过一个解决方案，安全、高效、永久地解决问题，保证Vscode在非管理员模式下能够合并并正确加载系统和用户环境变量。
>
> 请注意
>
> 1. ohmyposh不是问题的关键
> 2. 联网搜索时，使用英文搜索，并且忽略 [CSDN.net](http://csdn.net/) 的结果
> 3. 禁止“每次启动时手动执行初始化脚本”的解决方案，禁止“将用户环境变量迁移系统环境变量”的解决方案
> 4. 你需要先重复我的要求，确保你完全理解了我的意思

这个串比起从 Reddit 中的信息更准确，突出了问题可能是由 VSCode 引起的。 ~~我后来才意识到原 Po 并没有提到 VSC。~~ Qwen3 的回答如下：

1. 显式配置 VSCode 的终端环境变量
2. 修改 PowerShell 配置文件（Profile.ps1）
3. 调整 VSCode 的终端启动参数

最终我采用了方案 2（方案 1 即使主要思路对了，给出的细节也表明它直接将用户环境变量和 oh-my-posh 地址划等号了），即上面给出的结果，问题解决了。

最终感悟就是

1. AI 产品还需货比三家，chatGPT 和 DeepSeek R1 都是行业焦点，然而表现效果也并不总是最优，尤其是这种互联网资料较少的情况。
2. 好的 Prompt 对 AI 结果影响也很大。

## 参考文献

1. [User Env Variables wont be read when starting powershell with “pwsh” (version 7.2.5.0) : r/PowerShell](https://www.reddit.com/r/PowerShell/comments/wdhhve/user_env_variables_wont_be_read_when_starting/)
