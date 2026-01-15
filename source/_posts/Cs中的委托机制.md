---
title: C# 中的委托机制(delegate、action、func)
tags: [delegate, C#,Event,视频笔记]
categories: Unity 与 C#
date: 2023-07-06 21:40:05
# tags请写：来源（如课程）、体裁或用途（如笔记）并适当清晰化，如具体为（课程，图形学）
---

## 前言

简单了解了 C# 中的 Delegate、Func、Event、Action。粗略理解：委托是一个规定了参数的函数待执行队列；Func 是只有一参一返的 Delegate；Action 是一参无返的 Delegate；Event 是?

<!-- more -->

主要参考了[C# 的委托与事件大致是怎么一回事_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV163411S7QG/)，一个很好的视频。

## 委托 Delegate

委托的底层是一种函数指针。顾名思义委托的作用就是，当一个函数“不方便做某事”的时候，“拜托”另一个函数去做。可以用于实现**事件**与**回调**。

所有的委托都派生自 System.Delegate 类。

### 声明一个委托

委托的声明

```Csharp
delegate <return type> <delegate-name> <parameter list>
```

委托经过**声明**以后决定其可以引用的**方法**。方法与声明有相同的**参数**、**返回类型**、**标签**（[关于标签参考此 CSDN 博客](https://blog.csdn.net/yiyelanxin/article/details/79087971)）。换句话说，委托的声明决定了它能调用什么样的方法，委托是被调用方法的模板。

### 实例化委托

声明完成后，可以用 new 实例化一个委托实例，并且在参数中指定实例调用的方法。如下

```Csharp
public delegate void printString(string s);
...
printString ps1 = new printString(WriteToScreen);
printString ps2 = new printString(WriteToFile);
```

最后向委托中传递参数即可。如下是一个完整的例子（From：runnoob）

```Csharp
using System;

delegate int NumberChanger(int n);
namespace DelegateAppl
{
   class TestDelegate
   {
      static int num = 10;
      public static int AddNum(int p)
      {
         num += p;
         return num;
      }

      public static int MultNum(int q)
      {
         num *= q;
         return num;
      }
      public static int getNum()
      {
         return num;
      }

      static void Main(string[] args)
      {
         // 创建委托实例
         NumberChanger nc1 = new NumberChanger(AddNum);
         NumberChanger nc2 = new NumberChanger(MultNum);
         // 使用委托对象调用方法
         nc1(25);
         Console.WriteLine("Value of Num: {0}", getNum());
         nc2(5);
         Console.WriteLine("Value of Num: {0}", getNum());
         Console.ReadKey();
      }
   }
}
```

### 委托的多播

如果委托对象（即实例）的类型相同，则可以合并、分离委托（使用 `+` 和 `-` 运算符），这被称之为委托的**多播**或组播。如下是一个例子（From：runnoob）

```Csharp
...
static void Main(string[] args)
      {
         // 创建委托实例
         NumberChanger nc;
         NumberChanger nc1 = new NumberChanger(AddNum);
         NumberChanger nc2 = new NumberChanger(MultNum);
         nc = nc1;
         nc += nc2;
         // 调用多播
         nc(5);
         Console.WriteLine("Value of Num: {0}", getNum());
         Console.ReadKey();
      }
```

## Func

**Func 是委托的一种，它固定具有一个参数和一个返回值。**
格式如下：

```Csharp
Func <parameter_type,return_type> expression;
```

expression 可以是一个 lambda 表达式，也可以是一个方法。是方法的时候，这个方法和 Func 一样必须有一个传入值和一个返回值。这样，就**可以把方法作为参数进行传递**，同时不必像委托一样显式的进行定义声明。

lambda 表达式的举例：

```Csharp
Func<string, string> convert = s => s.ToUpper();

string name = "Dakota";
Console.WriteLine(convert(name));
```

实例化委托方法的举例：

```Csharp
Func<string, string> convertMethod = UppercaseString;
string name = "Dakota";

Console.WriteLine(convertMethod(name));

string UppercaseString(string inputString)
{
   return inputString.ToUpper();
}
```

## Action

**Action 也是委托的一种，它一定具有一个参数，并且没有返回值。**

即： `Action <T> name`

总的来说，和 Func 差别不大。同样可以给它赋值为 lambda 表达式或方法。只要这个方法有一个参数并且没有返回值。

## Event

Event 是一种特殊的委托，但是其复制的权限为delegate。使用 Delegate 的时候，我们不一定想立刻为其赋值。这种情况下，我们可以考虑使用 Event。

事件的声明：

```Csharp
    delegate void MyDelegate();
    event MyDelegate myEvent;
   //  or
   event Action myEvent //Action 的本质是 Delegate

```

事件声明完成后就是一个实例了（类似变量）。

当作为类成员的时候， event  只能在类中被调用。

Event 的一种用处：让类外成员可以观测到类的私有成员发生了变化。

> 在类中定义私有成员的 public {get;set;} 变量，set 时，invoke 类中的event；
> 类外事物需要观测时，在 event 中注册函数就会收到通知。

## 参考

1. [C# 的委托与事件大致是怎么一回事_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV163411S7QG/)
2. [C# 委托（Delegate） | 菜鸟教程](https://www.runoob.com/csharp/csharp-delegate.html)
3. [Func<T,TResult> 委托 (System) | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/api/system.func-2?view=net-7.0)
4. [三分钟彻底搞懂委托，事件，Action，Func的作用和区别_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1LT411L7yv/)

## 延申

1. 逆变与协变类型请参考：[Covariance and Contravariance in Generics | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/generics/covariance-and-contravariance)
2. lambda 表达式部分参考：
   1. [Lambda表达式_百度百科](https://baike.baidu.com/item/Lambda%E8%A1%A8%E8%BE%BE%E5%BC%8F/4585794)
   2. [C++ 中的 Lambda 表达式 | Microsoft Learn](https://learn.microsoft.com/zh-cn/cpp/cpp/lambda-expressions-in-cpp?view=msvc-170#constexpr-lambda-expressions)
