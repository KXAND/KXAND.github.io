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
   - 向量的定义和性质
   - 模与规一化( normalization )$\hat a = \frac{\Vert \vec a \Vert}{\vec a}$
   - 向量相加：三角形法则 / 平行四边形法则、坐标
   - 向量的矩阵形式 $A^T=(x,y)$
2. 点乘 $\vec{a}\cdot \vec{b}=\Vert\vec{a}\Vert\Vert\vec{b}\Vert cos\theta$。考虑矩阵形式。
   - 投影、找夹角
   - 两个向量方向接近的程度，是否**基本**同一个方向
3. 叉乘 $a\times b=-b\times a=\Vert\vec{a}\Vert\Vert\vec{b}\Vert sin\theta$
    - 右手定则与右手坐标系。叉乘确定一个平面。不满足结合律。
    - 判断向量的左右关系
    - 判断点与三角形的内外关系：对每条边都在同一侧

## 矩阵

1. 矩阵
   - 基本运算：乘积
     - 没有交换律。$AB\neq BA$
   - 转置 $T$
     - $(AB)^T=B^{-1}A^{-1}$
   - 单位矩阵 $I$
     - $A^{-1}A=I$
   - 齐次坐标

## 跳转

Home:[GAMES101-1：课程总览与笔记导航](GAMES10101.html)

Prev:[GAMES101-1：课程总览与笔记导航](GAMES10101.html)

Next：[GAMES101-3：变换](GAMES10103.html)
