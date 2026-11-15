---
title: GAMES101-2：回顾线代
tags:     
  - 图形学
  - GAMES
  - GAMES101
  - 笔记
  - 线性代数
  - 向量
  - 矩阵
categories: GAMES101
date: 2023-03-09 14:53:39
permalink: GAMES10102.html
---
## 前言

[GAMES101-P2](https://www.bilibili.com/video/BV1X7411F744?p=2)：回顾线代：向量、矩阵。<!-- more -->

## 向量

1. 向量：
   - 向量的定义和性质：大小和方向，可以平移。
   - 模与归一化（normalization）：模就是向量的长度，如二维下 $\Vert\vec a\Vert=\sqrt{x^2+y^2}$。归一化：$\hat a=\frac{\vec a}{\Vert\vec a\Vert}$（$\vec a\neq 0$），归一化后的模为 1。
   - 向量相加：三角形法则 / 平行四边形法则、坐标对应相加。
   - 向量的矩阵形式：$A^T=(x,y)$。
2. 点乘：$\vec{a}\cdot \vec{b}=\Vert\vec{a}\Vert\Vert\vec{b}\Vert\cos\theta$。考虑矩阵形式：$\vec a^T\vec b=a_xb_x+a_yb_y$（二维）。
   - 投影、找夹角：$\vec a$ 向 $\vec b$ 投影，长度（带正负）为 $\Vert\vec a\Vert\cos\theta=\vec a\cdot\hat b$，乘以单位方向 $\hat b$ 即投影向量。夹角把上面的式子反过来算：$\theta=\arccos\frac{\vec a\cdot\vec b}{\Vert\vec a\Vert\Vert\vec b\Vert}$。
   - 两个向量方向接近的程度，是否**基本**同一个方向。
3. 叉乘：$\vec a\times\vec b=-\vec b\times\vec a$，模为 $\Vert\vec a\times\vec b\Vert=\Vert\vec a\Vert\Vert\vec b\Vert\sin\theta$。
    - 右手定则与右手坐标系。叉乘确定平面的法线方向（两向量不共线时）。不满足结合律。
    - 判断向量的左右关系：二维下叉乘只看 $z$ 分量 $a_xb_y-a_yb_x$。从 $\vec a$ 看 $\vec b$，正数在左，负数在右（$x$ 向右、$y$ 向上）。
    - 判断点与三角形的内外关系：对每条边都在同一侧。沿三角形 $ABC$ 绕一圈，分别用 $\overrightarrow{AB}\times\overrightarrow{AP}$、$\overrightarrow{BC}\times\overrightarrow{BP}$、$\overrightarrow{CA}\times\overrightarrow{CP}$，结果都朝同一个方向就说明 $P$ 在三角形内。

      ![点在三角形内外时，三条有向边与顶点到 P 的向量叉乘结果的对比](/assets/101-point-in-triangle.svg)

## 矩阵

1. 矩阵：
   - 基本运算：乘积，左行乘右列再相加。
     - 没有交换律。一般 $AB\neq BA$。
   - 转置 $T$：行列互换。
     - $(AB)^T=B^TA^T$。
   - 单位矩阵 $I$：
     - $A^{-1}A=I$。
   - 齐次坐标：用 $n+1$ 维表示 $n$ 维。二维的点为 $(x,y,1)^T$，向量为 $(x,y,0)^T$，最后一维把两者区分开，平移时就可以只移动点。这样平移也能写成矩阵左乘。

## 跳转

Home：[GAMES101-1：课程总览与笔记导航](GAMES10101.html)

Prev：[GAMES101-1：课程总览与笔记导航](GAMES10101.html)

Next：[GAMES101-3：变换](GAMES10103.html)
