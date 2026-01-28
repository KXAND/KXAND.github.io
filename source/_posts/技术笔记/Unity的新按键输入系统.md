---
title: Unity的新按键输入系统
tags: 
 - Unity
 - 输入
categories: 技术笔记
date: 2023-07-17 23:39:53
# tags请写：来源（如课程）、体裁或用途（如笔记）并适当清晰化，如具体为（课程，图形学）
---

## 前言

这是 Unity 新输入系统（input system）的简要笔记。<!-- more -->

官方文档地址：[Input System | Input System | 1.5.1](https://docs.unity3d.com/Packages/com.unity.inputsystem@1.5/manual/index.html)

## Actions

### Action Type

- Value 类型：每次值改变的时候触发`OnAction`报告值；适用于追踪持续改变状态的输入。
- Button 类型：每次按下的时候触发；
- Passthrough 类型：看文档意思是一种冲突解决方案：对所有的控制类型都会响应。

因此，一次按下松开会使 Value 类型调用两次 OnAction，但是只会调用一次 Button 或 Passthrough。

### 检查 Action 的状态(委托与轮循)

可以使用下列三个 Action————此处 Action 是指一参无返的委托，不是 InputAction：

1. `action.started`
2. `action.performed`
3. `action.canceled`

也可以使用下列函数进行轮循：

- 对于 value 类型：

  1. `action.ReadValue<T>()`
  2. `action.PerformedThisFrame()`

- 对于 Button 类型：
  1. `action.IsPressed()`
  2. `action.WasPressedThisFrame()`
  3. `action.WasReleasedThisFrame`

