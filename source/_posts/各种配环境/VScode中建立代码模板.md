---
title: VSCode 中自定义代码模板（snippet）
tags: [VSCode]
categories: 各种配环境
date: 2022-1-5 22:01:55
---



这个功能在VS code 中被叫做片段（snippet），其功能是在输入用户定义好的触发词后，可以像代码补全一样补出一段代码。<!-- more -->

具体操作倒也不难，如下：

#### 1.打开VS code，选择文件 => 首选项 => 用户片段 =>选择对应的语言

<img src="https://s2.loli.net/2022/01/09/JxzTLfFiyMuKVhl.jpg" style="zoom:60%;" />

在弹出的以下窗口中选择对应的语言、文件夹或全局，则，仅会在该语言环境、该文件夹抑或全局触发补全该代码片段。此处我以C++为例了。

![如何在 VS code 中自定义代码模板（snippet）-2](https://s2.loli.net/2022/01/09/3OkiXdHyJB5l9cn.jpg)

#### 2.输入代码

在弹出的窗口中，你能看到已经有数行注释如下

```c++
 // Place your snippets for cpp here. Each snippet is defined under a snippet name and has a prefix, body and 
 // description. The prefix is what is used to trigger the snippet and the body will be expanded and inserted. Possible variables are:
 // $1, $2 for tab stops, $0 for the final cursor position, and ${1:label}, ${2:another} for placeholders. Placeholders with the 
 // same ids are connected.
 // Example:
 // "Print to console": {
 //  "prefix": "log",
 //  "body": [
 //   "console.log('$1');",
 //   "$2"
 //  ],
 //  "description": "Log output to console"
 // }
```

事实上这段英语教程已经说得比较清楚，但是作为英语苦手，还是有一定的理解苦难，这就是这篇博文诞生的原因。下做翻译补充：

每一个“代码片段”都应该由如下三部分构成，前缀（prefix）、主干和描述。

前缀是代码片段的触发器，当你在编辑代码时输入前缀（的部分），VS code 就会联想到你的对应代码片段；

主干是被补全的内容，也就是“模板”部分。你应该把代码分行写在 body 的中括号内，并把它们用双引号包括起来，同时在引号外别忘了添加逗号。即

```json
"your code here;",
```

描述被用来描述代码片段的作用，当你有多个相近名字的代码片段时，这无疑有助于你区分它们。此外，这部分也允许你输入中文，或干脆不写（尽管不建议）。

需要额外注意的是最后提到的由 $ 开头的这个小功能。

它的写法是 $加一个数字或在 \$ 后的大括号内依次写入”数字”“冒号”和“占位字符串”。如

```json
$0
${1}
${1:spaceholder}
```

在补全代码后，你的光标会首先停在数值最小的一个 \$ 字符处，随后每次按 Tab 依次停在次小的 \$ 处，最后停在代码片段的末尾或你指定的 \$0 处。（尽管测试下来允许数字不连贯，但是我建议还是使用连贯的从1开始的数字比较好）。如果有多个相同数字的地方，那么光标会同时存在于这些地方。

在上方 spaceholder 部分，你可以填入默认的代码，它们在会光标（按 Tab 转移到此处时被选中以备替换）。

#### 3. 实例

接下来，仿照给出的 Example 在下方输入你的代码即可。

```json
{//这个括号是默认生成的
 "Print to sample"://sample字段可被替换，还没找到其意义
 {
  "prefix": "test",//触发词
  "body": [
   "#include <iostream>",
   "#include <cstdio>",
   "",//这是一个空行
   "using namespace std;",

   "int ${1:i};",
   "$0",
   "",
   "int main()",
   "{",
   "    scanf(\"%d\", &$1);",//在上方写了占位符后，这里可以只写一个数字
   "    return 0;",
   "}",
  ],
  "description": "一般性简单cpp模板"
 },//逗号在有多个片段的时候有意义
    
    "Print to another_sample":
    {
        ...
    }
}
```

