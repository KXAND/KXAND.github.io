---
title: 毕业设计（1）：RSA密码与其数学原理
tags: 
  - 毕业设计
  - 密码学
  - 数论
  - RSA
  - 数论
categories: 毕业设计
date: 2023-12-13 22:09:26
# tags请写：来源（如课程）、体裁或用途（如笔记）并适当清晰化，如具体为（课程，图形学）
---
## 前言

什么是 RSA 算法及其数学原理。毕业设计笔记。 <!-- more -->

## RSA 算法的步骤

这里先不加数学原理解释，直接给出 RSA 的基本工作步骤，如下。

### 密钥的生成

1. 选择两个素数 $p$，$q$；
2. 记

   $n = p \times q \\
   \varphi(n) = (p-1)\times(q-1)
   $
3. 求公钥：任意选择 $e$ 使得：

   $$
   \left\{
        \begin{aligned}
                &0<e<\varphi(n)   \\
                &gcd(\varphi(n),e)=1
        \end{aligned}
    \right.
   $$

   即 $e$ 小于 $\varphi(n)$，且与 $\varphi(n)$ 互质；
4. 求私钥：计算 $d$，其满足 $d\cdot e \equiv 1 \mod(\varphi(n))$。或者说，$d\cdot e+ c\cdot\varphi(n)=1$，其中 $c$ 不确定，求 $d$；
5. {e,n}为公钥，{d，n}为私钥，p，q丢弃。

> 发现自己连第四步中的 $d\cdot e+ c\cdot\varphi(n)=1$ 都不会推了，简单记一下。
>
> $$
> \begin{aligned}
> d\cdot e &\equiv 1 \mod(\varphi(n))\\
> d\cdot e-1&=k\cdot\varphi(n)\\
> d\cdot e+ c\cdot\varphi(n)&= 1
> \end{aligned}
> $$

### 加密

对于明文 m，密文为c：

$$
c\equiv m^e \mod(n)
$$

也就是说，我们对 $m$ 进行幂运算同时进行模运算即可加密。

### 解密

对于密文 $c$，明文 $m$：

$$
m\equiv c^d \mod(n)
$$

也就是说，我们对 $c$ 进行幂运算同时进行模运算即可解密。

## RSA 的数学基础

### 乘法逆元与扩展欧几里得算法

#### 裴蜀定理（不证）

裴蜀定理（Bézout's lemma）指出，关于 $a$，$b$ 的方程：

$$
ax+by=m
$$

仅在 $m$ 为 $a$，$b$ 的最大公约数的倍数时，有整数解。

通过裴蜀定理，我们就可以把 $\gcd(a,b)$ 转化成 $ax+by=m$。其中 m 是最大公因数的倍数。

特别地，当 $m=1$，这个时候 $x,y$ 分别被叫做 $a$关于模 $b$ 的模逆元 $x$ 和 $b$关于模 $a$ 的模逆元 $y$。

#### 乘法逆元

$$
ab\equiv 1 \mod(n)
$$

则 $a,b$ 互为乘法逆元（模逆元、模倒数）。此时有：

$$
ab+kn=1
$$

乘法逆元存在的充要条件是 $a,n$ 互质，换句话说，右边的 1 其实是 $gcd(a,n)$。若 $gcd(a,n) \neq 1$，那么 $x$ 就不是逆元。

求乘法逆元我们可以使用下面介绍的扩展欧几里得算法，在求 $gcd(a,n)$ 的过程中，将逆元 $b$ 求出。

在 RSA 中，私钥 $d$ 实际上就是公钥 $e$ 的乘法逆元。

#### 欧几里得算法与其证明

欧几里得算法即辗转相除法，用于求两个数的最大公因数。在密钥生成的第三步，我们可以用欧几里得算法检查 $gcd(\varphi(n),e)$ 是否为 1。其算法逻辑如下：

```c++
int gcd(int a, int b)
{
    if (b == 0)
    {
        return a;
    }
    int d = gcd(b, a % b);
    return d;
}
```

比较简单就只写代码了。

下面是该算法有效性的证明：

设 $a>b$ （否则，代码结果会等价于做一次交换）：
在带余除法下，我们设

- $q=\displaystyle\left\lfloor\frac{a}{b}\right\rfloor$：商
- $r=a\bmod b$：余
- $d_1=\gcd(a,b)$：最大公因数
- $d_2=\gcd(b,r)$：与余的最大公因数

那么，对于 $d_1$：

1. 由于 $b$ 是最大公因数 $d_1$ 的倍数，那么 $qb$ 也是 $d_1$ 的倍数；
2. 又 $a$ 是最大公因数 $d_1$ 的倍数，那么 $a-qb$ 也是 $d_1$ 的倍数；
3. 又 $r=a-qb$ ，所以 $r$ 也是 $d_1$ 的倍数。
4. $d_1$同时为 $b$ 和 $r$ 因数，即 $d_1$ 是 $b$ 和 $r$ 的公因数。
5. 由于 $d_2=\gcd(b,r)$ 数，根据性质“最大公因数是所有公因数的倍数”，可知 $d_1$ 是 $d_2$ 的因数。

另一方面，对于 $d_2$：

1. 由于 $b$ 是最大公因数 $d_2$ 的倍数，那么 $qb$ 也是 $d_2$ 的倍数；
2. 又 $r$ 是最大公因数 $d_2$ 的倍数，那么 $r+qb$ 也是 $d_2$ 的倍数；
3. 由于 $a=qb+r$ ，所以 $a$ 也是 $d_2$ 的倍数。
4. 所以 $d_2$ 是 $a$ 和 $b$ 的公因数。
5. 由于 $d_1=\gcd(a,b)$ ，根据性质“最大公因数是所有公因数的倍数”，所以 $d_2$ 是 $d_1$ 的因数。

$d_1$ 是 $d_2$ 的因数， $d_2$ 也是 $d_1$ 的因数，这说明 $d_1=d_2$ ，即 $\gcd(a,b)=\gcd(b,a\bmod b)$ 。因此辗转相除法是正确的。

> 最大公因数是所有公因数的倍数的证明：
>
> 设 $g= gcd(a,b)$，$d$ 是所有形如 $ax+by$ 的**正**整数中最小的。
>
> 由于正整数 $d=ax+by=xk_1g+yk_2g=g(xk_1+yk_2)>0$，那么 $g$ 整除 $d$ 且 $g\leqslant d$；
>
> 设 $d=ax_0+by_0$，用 $d$ 带余除任意形如 $ax+by$ 的数，设为 $ax+by=dq+r$，那么 $r=ax+by-d=a(x-qx_0)+b(y-qy_0)$。即 $r$ 也是一个形如 $ax+by$ 的数。
>
> 由余数的定义，可知 $0\leqslant r< d$；若 $r>0$ 那么这与前述“$d$ 是所有形如 $ax+by$ 的正整数中最小的”相矛盾，所以 $r=0$。
>
> 即： $d$ 整除任意形如 $ax+by$ 的数。
>
> 因此，$d$ 整除 $a$，$b$，即 $d$ 是 $a$，$b$的公因数。那么， $d\leqslant g$。
>
> 综合 $g\leqslant d$ 和 $d\leqslant g$ 有 $g=d=ax+by$。
>
> 可以看出 $ax+by$ 可以被 $a$，$b$ 的每一个公因数整除，因此，最大公因数是所有公因数的倍数。
>
> 得证。

#### 扩展欧几里得算法与其证明

### 欧拉函数与欧拉定理

#### 欧拉函数

如果两个正整数，除了 1 以外，没有其他公因数，我们就称这两个数是互质关系。两个数互质，不说明两个数是质数。

给定一个数 $n$，求出在小于 $n$ 的数中有多少个与 $n$ 互质，这就是**欧拉函数** $\varphi (n)$。

在欧拉函数的第一步中，我们就计算了 $n$ 的欧拉函数值 $\varphi (n)=(p-1)(q-1)$。

> 欧拉函数函数式的推导：
>
> 分情况讨论：
>
> 1. n=1：$\varphi(1) =1$。1 与任何数都互质。
> 2. n 为质数：$\varphi(n) =n-1$。不难想到，互质的两个数中，若大的为质数，那么二者必然互质，因为质数只有两个因数。
> 3. $n = p^k\ (k>0)$，即 $n$ 是一质数 $p$ 的某一次方幂：
>
>    $$
>    \begin{aligned}
>    \varphi(n)
>    &=p^k-p^{k-1}\\
>    &= p^k(1-\frac{1}{p})
>    \end{aligned}
>    $$
>
>    这是因为小于 $p^k$ 的数中，$1\times p,2\times p\dots p^{k-1}\times p$ 共计 $p^{k-1}$ 个数都有质数 $p$ 做因数，需要剔除。
>
>    第二种情况是第三种情况的特殊情况。
> 4. $n = p_1\times p_2$，即 $n$ 是两互质整数的积：
>
>    $$
>    \varphi(n) =\varphi(p_1)\varphi(p_2)
>    $$
>
>    证明需要用到中国剩余定理。
> 5. $n$ 是一般的正整数，通过质因数分解，其可以化为 $n=p_1^{k_1}p_2^{k_2}p_3^{k_3}\dots p_m^{k_m}$。那么有：
>
>    $$
>    \begin{aligned}
>    \varphi(n)
>    &= \varphi(p_1)\varphi(p_2)\cdots\varphi(p_m)\ (情况4)\\
>    &= p_1^{k_1}p_2^{k_2}\dots p_m^{k_m}\times(1-\frac{1}{p_1})(1-\frac{1}{p_2})\cdots(1-\frac{1}{p_m})\ (情况3)\\
>    &=n(1-\frac{1}{p_1})(1-\frac{1}{p_2})\cdots(1-\frac{1}{p_m})
>    \end{aligned}
>    $$

#### 欧拉定理（不证）

有了欧拉函数，我们可以有**欧拉定理**，对于互质的两个数 $a,n$：

$$
a^{\varphi(n)}\equiv 1\mod(n)
$$

> 若 $a,p$ 互质，那么有
>
> $$
> a^{p-1}\equiv 1\mod(n)
> $$
>
> 这就是费马小定理

欧拉定理这里不证。

### RSA 的有效性证明

为什么 RSA 这样进行加密可以保证解密后一定是原文？下面给出证明。

根据【加密】一节，可以知道，密文 $c$ 和$m^e$ 之间差距为若干个 $n$:

$$
c= m^e+kn
$$

代入【解密】中的公式，有：

$$
(m^e+kn)^d\equiv m \mod(n)
$$

左侧多项式展开后，所有含 $kn$ 的项都可被 $n$ 整除，不影响余数。于是等价为：

$$
m^{ed}\equiv m\mod(n)
$$

根据【密钥生成】中第四步的公式 $d\cdot e+ k\cdot\varphi(n)=1$ （为避免歧义，将 $\varphi(n)$ 的系数换了字母）代换：

$$
\begin{aligned}
m^{1-k\varphi (n)}&\equiv m\mod(n)\\
\implies m\cdot {m^{\varphi (n)}}^{-k}&\equiv m\mod(n)
\end{aligned}
$$

此时分情况讨论：

1. $m,n$ 互质，根据欧拉定理就有 $m^{\varphi(n)}\equiv 1\mod(n)$，将 $m^{\varphi(n)}$ 代入就得证。
2. $m,n$ 不互质。而 $n$ 是两大素数的乘积，那么 $m$ 的因子中必然有 $p,q$ 中的一个而与另一个互质。假设 $m,n$ 公因子为 $p$，$m$ 与 $q$ 互质，有：

   > 两个素数不可能同时为公因子，这意味着 $m$ 不小于 $n$，那么就无法正确【解密】了。
   >

   根据费马小定理：

   $$
   m^{\varphi(q)}\equiv 1\mod(q)
   $$

   于是根据欧拉函数以及前面提到的 $d\cdot e+ k\cdot\varphi(n)=1$ 推出：

   $$
   \begin{aligned}
   m^{\varphi(q)}&\equiv 1\mod(q)\\
   m^{q-1}&\equiv 1\mod(q)\\
   {(m^{q-1})}^{-k(p-1)}&\equiv 1\mod(q)\\
   {m^{-k\varphi(n)}}&\equiv 1\mod(q)\\
   m^{ed-1}&\equiv 1\mod(q)\\
   \end{aligned}
   $$

   于是设

   $$
   m = r\cdot p\\
   m^{ed-1}=t\cdot q+1
   $$

   那么

   $$
   \begin{aligned}
   m^{ed-1}&= tq+1\\
   m^{ed}&= tq\cdot m+m\\
   m^{ed}&= tq\cdot (r\cdot p)+m\\
   m^{ed}&= tr\cdot pq+m\\
   m^{ed}&= tr\cdot n+m\\
   \implies m^{ed}&\equiv m \mod(n)\\
   \end{aligned}
   $$

   得证。
