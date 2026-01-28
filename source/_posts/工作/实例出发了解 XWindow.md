---
title: 实例出发了解 XWindow
tags: 
  - X11
  - Linux
  - XWindow
categories: 工作
date: 2024-10-03 14:51:33
---

## 前言

之前因为在做一个给 Linux 窗口添加水印的任务，偶然了解到了一个有趣的项目 Activate Linux。以此为例，可以串联我对 XWindow 的初步了解。 <!-- more -->

## 什么是 XWindow

XWindow，即[X窗口系统](https://zh.wikipedia.org/wiki/X視窗系統) 是一种 GUI 系统，它最初是1984年麻省理工学院的一项研究，之后成了 UNIX 、类 UNIX、以及 OpenVMS 等操作系统所一致适用的标准化软件工具包及显示架构的运作协议。目前 XWindow 最主流的实现是基于 1987 年的 XWindow 11 的， 因此，人们也常常简称其为 X11（下面我们也会将其简称为 X）。

上面这段基本是摘自维基百科，从中我们可以知道，X 是一个相当老的窗口系统，但是在今天仍然应用广泛。许多著名的 Linux 桌面环境，例如 GNOME 和 KDE 等等都运行在 X 之上。当然，它们未必直接基于 X，而可能是基于 QT 之类的更现代的跨平台图形库。X 的开源实现（C 语言）如今由 [X.Org 基金会](https://www.x.org/wiki/) 维护。

要使用 X11 的接口，你需要引入 Xlib 系列的库，不过，提供更现代更简单的函数接口，有人推出了名为 XCB（Xlib C binding） 的库，旨在取代 Xlib。~~主要的区别是驼峰命名改下划线命名了~~。 XCB 比 Xlib 更现代，所以，如果你真的不想用 QT 等更上层的图形接口，至少也应该尽量用 XCB 而非 Xlib。毕竟 Xlib 能做的事情，XCB 全都能做，但是却更新。

最后给出两个 X 的参考文档地址：

1. X.org: [Documentation](https://www.x.org/wiki/Documentation/)
2. tronche: [The X Window system](https://tronche.com/gui/x/)

## X 系统的架构，以及它落伍的原因

如前所述，X11 是一个相当老的系统，它已经快四十岁了！当然，X 在系统相当底层的位置，所以更新频率和各类应用软件不能相提并论，但是 30 多岁依然太老了，下面我们首先描述它的架构，并最后说明为什么太老了。这部分内容转述自 [Alynx Zhou 的 X 和 Wayland 的主要区别 - 喵’s StackHarbor](https://sh.alynx.one/posts/Difference-between-X-and-Wayland/)。

首先，X 是基于 C/S 架构的。这就是说它会首先起一个 X Server，然后各 App 就是 X Client，它们使用上一节提到的 X 接口渲染好自己的 GUI 界面后，将数据交给 X Server 进行处理，最后，用户通过显示器观看到 X Server 处理好的画面并交互。这点和 Windows 相当不同，因为 Windows 将 GUI 集成到了系统内核中，因此并不需要额外启动一个 Server。App 之间的通信也就并不需要总是通过 X Server 进行。

> 这方面的一个典型例子是剪贴板的实现，在 Windows 下，剪贴板是一块公共的内存区域，只要调用指定的函数，任何 App 都可读可写。在 X 中，剪贴板读写依赖一种被称为 Selection 的东西，粘贴操作需要 Client 请求 Server，然后 Server 通知拥有 Selection 的 Client 提供数据。

当然这没啥问题，一个 App 图形渲染显然不应该是依赖另一个 App 的数据的。不过，“X Server 处理好画面”具体是指什么处理呢？

在一些现代的操作系统，例如 Windows 10 中，这种处理实际上相当类似于游戏渲染，用 Shader 制造出酷炫的视觉效果，用 Z 轴处理窗口的深浅变化……可以说，如今的 Windows 桌面就是一个大“游戏”。但是，回到八九十年代，X 才刚刚诞生的时候， 计算机性能和内存可不像今天这样可以奢侈地挥霍。为了节约内存，X 的处理非常简单：开辟桌面大小的内存空间，所有 Client 的图像数据按顺序写入数据，把前面的图形数据直接覆盖掉，整个过程就好像画油画一样。

这在 80 年代没有问题，但是随着计算机性能的爆炸，人们也想吃点“细糠”了，例如，窗口能不能添加上半透明效果？

这就等于是说，一个地方需要同时存在两个 App 的图像数据，并且当鼠标点击的时候需要命中上层的窗口。Client 肯定不能做这件事，因为它们并不知道自己和其它 App 的位置图像关系。但是传统的 Server 也并没有解决这个问题，所以人们引入了 Compositor（混合器）。

具体来说，Compositor 取代了 Server 接收 Client 发来的图像数据，并对它们进行处理，最后发送给 Server 桌面大小的内存数据。由于 Compositor 拥有所有窗口的图形数据，因此 Compositor 可以任意做出各类半透明效果，毛玻璃等等。这样，我们就得到了现代的 X 系统架构。其中，Compositor 这个玩意由于不是标准 X 协议的一部分，一般是各桌面环境独立实现。

![图 0](https://s2.loli.net/2024/10/03/qR6x4tzK9wkmETH.png)

打个补丁看上去虽然有些丑陋，但是事情就完美的解决了……吗？

现在考虑鼠标点击事件，X Server 接收到鼠标点击后，会将事件点击位置发送给“客户端”。由于 Compositor 承担了中间人的作用，因此 Server 实际上是将点击事件和点击桌面的位置发送给了 Compositor，Compositor 再通知对应的窗口。换句话说，Compositor 必须能正确找到 Server 说的坐标是哪个 Client， Compositor 必须将桌面位置和窗口位置进行对应。

如果处理透明窗口，或者带位置动画的窗口，Compositor 的渲染的时候，可以很简单地将这一部分数据丢掉或者位移了事。但是 Compositor 必须清楚地知道它们在 Server 眼里对应的坐标。或者干脆这种动画变化就不传给 Server 了（然后导致动画变了以后点击位置和显示位置不一致）。

说到这里其实问题已经很明显了，面对如今的需求，X 原始的 C/S 架构其实已经不够用了。Client 们有各种各样的需求。不仅仅是透明，还有想自己利用显卡处理图形等等，此外，现代操作系统也并不那么在乎远程性：Server 和 Client 大多时候都是跑在一个机器上……但是碍于 X 的历史问题，我们难以直接在 Server 上动刀子，只能添加一个 Compositor 作为补丁。

问题还不止这些，X 的问题还包括图像没有 Z 轴信息（API 结构中的 Depth 是色深），以及没有规定颜色空间（仅规定了黑和白色）等等……

既然如此，为什么我们还要给 X 当裱糊匠呢？为什么我们不设计一个新的窗口系统，窗口混合直接是集成在 Server 中的一部分，并添加其它现代需要的功能呢？是的，许多人也是这么想的。既然 Compositor 如此重要，我们就让它负责所有的事情，它直接和输入输出对接，直接和图像API（OpenGL啥的）对接，于是我们得到了 Wayland。

![pic_1727947031886.png](https://s2.loli.net/2024/10/03/PoGUOpJcLCZ7sde.png)

## XWindow 实例：Activate Linux

终于进入正题了，尽管 X 诚然存在刚刚吐槽的种种问题，作为主流的 Linux 图形系统，我们还是有必要对其有初步的了解。接下来以 Activate Linux 为例进行说明。请注意这里只是一个初步的说明，所以一些细节的处理（例如多屏幕等）被忽略了。

[MrGlockenspiel/activate-linux](https://github.com/MrGlockenspiel/activate-linux) 是一个简单的整活软件，它模仿 Windows 10 右下角的 “激活 Windows”图标，可以给你的 Linux 添加相似的“激活 Linux” 图标(放心，不会真的限制你使用 Linux 的功能)。效果如图（源自原 Github 仓库）：
![pic_1727947834282.png](https://s2.loli.net/2024/10/03/XaoxWLcuKvsbFle.png)

程序的代码在 `./src/` 下，从 `src/activate_linux.c` 进入，在根据系统引入了 X11 的库后，启动了`src/x11/x11.h` 下的 `int x11_backend_start(void);` 函数处理所有的逻辑。

首先，我们检查是否有 Compositor 真正运行，这是半透明效果的前提。

```C
static bool compositor_check(Display *d, int screen)
{
    char prop_name[16];
    snprintf(prop_name, 16, "_NET_WM_CM_S%d", screen);
    Atom prop_atom = XInternAtom(d, prop_name, False);
    return XGetSelectionOwner(d, prop_atom) != None;
}
//....
int x11_backend_start(void)
{
    bool compositor_running = compositor_check(d, XDefaultScreen(d));
}
```

它的本质是通过 `XGetSelectionOwner` 检查 `Display` 是否存在一个 `_NET_WM_CM_S<Display's Screen>` 的属性。

随后，在进行一些必要的变量声明以后，创建窗口

```C
Window overlay[num_entries];
overlay[i] = XCreateWindow(
  d, // display
  root, // parent
  si[i].x_org + si[i].width - overlay_width,  // x position
  si[i].y_org + si[i].height - overlay_height, // y position
  overlay_width,  // width
  overlay_height, // height
  // ...
  CWOverrideRedirect | CWColormap | CWBackPixel | CWBorderPixel,    // value mask
  //...
);
```

这里我忽略了一些参数，以明晰主干，可以看到程序的逻辑是创建一个窗口，父结点为 root，位置为窗口的最右下角，并且通过 `CWOverrideRedirect` 表明其不受窗口管理器控制(不会有标题栏等信息，无法设为焦点窗口)

随后对窗口进行一些必要的设置

```C
// subscribe to Exposure Events, required for redrawing after DPMS blanking
XSelectInput(d, overlay[i], ExposureMask);
XMapWindow(d, overlay[i]);

// allows the mouse to click through the overlay
XRectangle rect;
XserverRegion region = XFixesCreateRegion(d, &rect, 1);
XFixesSetWindowShapeRegion(d, overlay[i], ShapeInput, 0, 0, region);
XFixesDestroyRegion(d, region);
```

主要是通过 `XSelectInput` 使其可以接收事件输入，通过 `XMapWindow` 使其被渲染（Map 表示这个窗口需要被映射到桌面，需要被渲染），通过 `XFixesSetWindowShapeRegion` 使得鼠标可以穿透。

随后，我们引入了一个名为 cairo 的图形库来帮助我们更好的创建窗口。这里需要了解 cairo 下两个术语， `cairo_surface_t` 是类似 X `中的Window` 的概念，存储了画面的大小、色深等信息。`cairo_surface_t` 则存储了其它的上下文信息，例如我们接下来会用到的字体大小等。

创建对应的 cairo surface 和上下文，并根据需要对其进行渲染：

```C
cairo_surface_t *surface[num_entries];
cairo_t *cairo_ctx[num_entries];
// ...
surface[i] = cairo_xlib_surface_create(d, overlay[i], vinfo.visual, overlay_width, overlay_height);
cairo_ctx[i] = cairo_create(surface[i]);
```

最后，根据监听到的消息令窗口进行对应的处理即可，当消息为 `Expose` 时，我们根据上下文进行绘画

```C
XEvent event;
while (1)
{
    XNextEvent(d, &event);
    // ...
    else if (event.type == Expose)
    {
      //...
      if (!compositor_running)
      {
          draw_text(cairo_ctx[i], 2);
          draw_text(xshape_ctx[i], 1);
          XShapeCombineMask(d, overlay[i], ShapeBounding, 0, 0,
                            cairo_xlib_surface_get_drawable(xshape_surface[i]), ShapeSet);
      } 
      else
      {
          draw_text(cairo_ctx[i], 0);
      }
    }
    else
    {
        // ...
    }
}
```

我们先不考虑具体的 `compositor_running == False` 的情况，可以看到细节被封装到了 `draw_text` 中，这个函数的定义在 `src/cairo_draw_text.c` 中。

这里的细节就比较简单且和 X 无关了，它是纯 cairo 的，我们设定了字体大小、斜体粗体、换行以及反走样的信息。

```C
void draw_text(cairo_t *const cr, int xshape_mask)
{
 cairo_set_font_options(cr, font_options);

    // set font size, and scale up or down
    cairo_set_font_size(cr, 24 * options.scale);

    // font weight and slant settings
    cairo_font_weight_t font_weight = CAIRO_FONT_WEIGHT_NORMAL;
    if (options.bold_mode)
    {
        font_weight = CAIRO_FONT_WEIGHT_BOLD;
    }

    cairo_font_slant_t font_slant = CAIRO_FONT_SLANT_NORMAL;
    if (options.italic_mode)
    {
        font_slant = CAIRO_FONT_SLANT_ITALIC;
    }

    cairo_select_font_face(cr, options.custom_font, font_slant, font_weight);

    cairo_move_to(cr, 20, 30 * options.scale);
    cairo_show_text(cr, options.title);

    cairo_set_font_size(cr, 16 * options.scale);
    cairo_move_to(cr, 20, 55 * options.scale);

    // handle string with \n as cairo cannot do it out of the box
    char *subtitle = options.subtitle;
    char *new_line_ptr = strchr(subtitle, '\n');
    if (new_line_ptr)
    {
        size_t first_line_len = new_line_ptr - subtitle;
        char *first_line = calloc(1, first_line_len + 1);
        memcpy(first_line, subtitle, first_line_len);
        cairo_show_text(cr, first_line);
        free(first_line);

        cairo_move_to(cr, 20, 75 * options.scale);
        cairo_show_text(cr, new_line_ptr + 1);
    }
}

```

那么 `compositor_running == False` 的情况是怎么样的？在上面我们可以看到

```C
//...
if (!compositor_running)
{
    draw_text(cairo_ctx[i], 2);
    draw_text(xshape_ctx[i], 1);
    XShapeCombineMask(d, overlay[i], ShapeBounding, 0, 0,
                      cairo_xlib_surface_get_drawable(xshape_surface[i]), ShapeSet);
} 

```

这里的关键是 `XShapeCombineMask`。由于没有 Compositor ，我们直接以字创建了一个以字为形状的 `cairo surface`，然后将它转换为 X 下的 `drawable` 结构，最后用 `XShapeCombineMask` 进行蒙版。这样，我们就得到了一个异形窗口：字是完全不透明的。

在实际操作过程中，我还发现，这种伪透明的窗口，虽然能起到一定的效果，但是有的情况下会导致窗口残影，可见这仍然只是权宜手段。

## 参考

1. [Alynx Zhou 的 X 和 Wayland 的主要区别 - 喵’s StackHarbor](https://sh.alynx.one/posts/Difference-between-X-and-Wayland/)
2. [【已解决】有懂x11的吗，如何创建一个背景透明的子窗口？ - Ubuntu中文论坛](https://forum.ubuntu.org.cn/viewtopic.php?t=493598)
3. X.org: [Documentation](https://www.x.org/wiki/Documentation/)
4. tronche: [The X Window system](https://tronche.com/gui/x/)