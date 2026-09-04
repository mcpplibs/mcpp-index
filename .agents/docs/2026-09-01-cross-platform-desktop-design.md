# 任何地方都是一块屏幕 —— 跨平台用户态桌面的设计

2026-09-01

四家桌面系统是同一副骨架,只是把「操作系统的边界」画在了不同高度。真正不可移植
的只有两件事:**把一帧像素放上去**、**把输入收进来**。其余全部是纯计算 —— 这决定
了整个设计只需要一个抽象。

---

## §1 五层骨架 × 四个平台

| 层 | Linux | Windows | macOS | Android |
|---|---|---|---|---|
| **① 硬件访问** | DRM/KMS + evdev | WDDM / DXGI + RawInput | IOKit + CoreGraphics | **Composer HAL(HWC)+ Gralloc**;底下仍是 Linux 内核,输入 evdev → InputReader |
| **② 合成器** | wlroots / mutter / KWin(或 X server) | DWM + DirectComposition | WindowServer + Quartz | **SurfaceFlinger** —— HWC 走硬件叠加层,RenderEngine/Skia 兜底 |
| **③ 客户端协议** | Wayland / X11(线协议 + fd 传递) | Win32 消息 + DComp 视觉树 | Cocoa + CoreAnimation 远端图层 | **Binder RPC + BufferQueue**(共享 dma-buf 句柄,**没有线协议**) |
| **④ 渲染** | Mesa(GL/Vulkan)、cairo | D3D / Direct2D | Metal / CoreGraphics | **HWUI / Skia** + GLES/Vulkan |
| **⑤ 控件** | GTK / Qt | WinUI / WPF | AppKit / SwiftUI | **View 体系 / Jetpack Compose** |
| **你能换到第几层** | ✅ ②③ 都能换<br>(所以能自己写合成器) | ⚠️ 只有 ④⑤<br>②③ 锁死 | ⚠️ 只有 ④⑤ | ⚠️ 只有 ④⑤<br>但 NDK 接口最干净 |

> ⭐ 四家锁死了不同的东西,却**都给你同一样东西:一个窗口 + 一个输入流。**
> 这就是整个跨平台设计唯一能站住的地基。

### Android 那一列为什么值得单独看

它是四家里唯一一个**「客户端协议」不是协议**的 —— Binder RPC 加共享缓冲区句柄。
两个直接后果:

- **接管不了。** Wayland 那条路(自己当服务端、让真实应用连进来)在 Android 上
  **没有对应物**。Linux 上那个加分项到 Android 就是零。
- **但 NDK 给的东西异常干净** —— `ANativeWindow_lock` / `unlockAndPost` 就是
  「拿一块可写像素、交回去」,`AInputQueue` 就是输入流。它几乎是照着下面那个
  抽象长的。

还有一点结构上的巧合:SurfaceFlinger 本来就把每个应用当成一个 layer 生产者,
**你的桌面只是多一个生产者** —— 嵌套形态在 Android 上是最自然的,不是将就。

---

## §2 时序 · 一块屏幕是怎么到手的

```
        ┌─────────────── 平台层:唯一不可移植的部分 ───────────────┐
        │                                                          │
   Linux 嵌套      Linux 独占      Windows       macOS      Android       Headless
 wl_surface +      DRM/KMS      CreateWindowEx  NSWindow  ANativeWindow   内存缓冲
 xdg_toplevel      scanout       + DXGI        + CALayer  + AInputQueue    → PNG
        │              │             │             │           │             │
        └──────────────┴─────────────┴──────┬──────┴───────────┴─────────────┘
                                            ▼
                          ┌─────────────────────────────────┐
                          │  Screen                         │
                          │  size / acquire / present / pump│
                          └────────────────┬────────────────┘
                                           ▼
        ┌────────── 可移植核心:纯计算,零平台依赖 ──────────┐
        │  场景图 · 损伤 · 层叠 · 命中测试                  │
        │  窗管策略 · 焦点 · 摆放                           │
        │  控件 · 布局 · 事件分发                           │
        │  文本与矢量绘制(pango + cairo)                  │
        └───────────────────────────────────────────────────┘
```

判断标准很硬:**把 Screen 换成 Headless,核心的行为必须一字不变。**

---

## §3 时序 · 一帧的生命周期

最容易写错的一张,因为错了不报错。

```
  应用                      合成核心                    Screen(平台)
   │                          │                            │
   ├─ attach(buffer) ────────►│                            │
   │  + damage(区域)          │  损伤并入损伤环             │
   │  + commit                │  ⚠️ 不立刻渲染              │
   │                          │                            │
   │                          │◄──── frame 时钟到点 ───────┤
   │                          │                            │
   │                          ├─ acquire() ───────────────►│
   │                          │  只重画损伤区域             │
   │                          │  层叠/遮挡在场景图里算好     │
   │                          ├─ present(damage) ─────────►│
   │                          │                            │
   │◄──── frame_done ─────────┤                            │
   │  收到才画下一帧           │                            │
   ├─ 下一帧 commit ─────────►│                            │
```

> ⚠️ **实测踩过的坑 —— 帧回调死锁**
>
> `frame_done` 只发给「这次渲染真的画到了的」表面。如果核心因为「没有新损伤」
> 而跳过渲染,就没人收到 `frame_done`;客户端于是永远不画下一帧,核心也就永远
> 没有新损伤 —— **两边都在等对方,都不报错。**
>
> 普通应用碰不到(画一次就完事),**只有当客户端本身也是个合成器时才会暴露**。
> 套娃 demo 就是这么卡住的:内层两块屏幕是白板,而每一项状态单独看都正常
> (mapped / buffer / texture / enabled 逐项都有)。

---

## §4 时序 · 一个窗口从创建到上屏

这一段的形状在四个平台上惊人地一致 —— 因为它本来就是纯协议,和硬件无关。

```
  应用                    合成核心                  窗管策略
   │                        │                        │
   ├─ 创建表面 ────────────►│                        │
   ├─ 要一个「顶层窗口」角色►│                        │
   ├─ commit(空) ─────────►│                        │
   │  ⚠️ 此刻还不能贴像素    │                        │
   │     要先谈好尺寸        ├─ 新窗口 ──────────────►│
   │                        │◄─ 尺寸 / 位置 / 状态 ──┤
   │◄─ configure(尺寸,状态)┤                        │
   ├─ ack_configure ───────►│                        │
   ├─ attach(第一块像素) ──►│                        │
   │  + commit              ├─ 已 map ──────────────►│
   │                        │◄─ 摆放 + 抬到最上层 ───┤
   │                        │   + 设为激活            │
   │◄─ configure(ACTIVATED)┤                        │
   │  ⭐ 据此画高亮标题栏    │                        │
   │     不是自己猜的        │                        │
   ├─ 重画 + commit ───────►│                        │
```

⚠️ 「先提交一个空表面」是所有人第一次都会漏的:**尺寸要先谈好,才能贴像素。**
在 configure 之前发就撞 `Assertion 'surface->initialized' failed`。

---

## §5 时序 · 一次点击怎么变成焦点

```
 Screen(平台)          合成核心              原焦点窗口        被点的窗口
   │                      │                      │                 │
   ├─ pump() 吐出 ───────►│                      │                 │
   │  按下(x, y)          │ 命中测试:场景图      │                 │
   │                      │ 从上往下问,被遮住    │                 │
   │                      │ 的部分不命中          │                 │
   │                      ├─ 取消激活 ──────────►│                 │
   │                      ├─ 抬到最上层 ─────────┼────────────────►│
   │                      ├─ 设为激活+键盘焦点 ──┼────────────────►│
   │                      ├─ configure(无 ACT) ─►│                 │
   │                      ├─ configure(含 ACT) ──┼────────────────►│
   │                      │◄─ 画成「未聚焦」─────┤                 │
   │                      │◄─ 画成「已聚焦」─────┼─────────────────┤
   │                      │ 两块损伤进环          │                 │
   │                      │ 下一帧一起呈现        │                 │
```

⭐ **除了第 1 步,没有任何一步是平台特有的。** 命中测试、层叠、激活状态推送,
全是核心里的纯计算。

---

## §6 设计 · 把「屏幕」定义成能力,而不是设备

不要把屏幕定义成「一块显示器」。定义成**一个能满足三件事的东西**:

```cpp
struct Screen {
    virtual Size   size() const              = 0;   // 我有多大
    virtual Pixels acquire()                 = 0;   // 给我一块可写的像素
    virtual void   present(const Damage &)   = 0;   // 收下这一帧
    virtual void   pump(EventSink &)         = 0;   // 输入 / 尺寸变化 / 关闭
};
```

接口小到这个程度,不是为了简洁 —— 是因为**接口每大一圈,就多一个平台概念漏进
上层的机会**。凡是能满足这四个方法的,都是一块屏幕:

| 实现 | 是什么 |
|---|---|
| **原生窗口** | Win32 / Cocoa / Android / X11 / Wayland —— 最常见的一种 |
| **独占显示器** | Linux 上 DRM/KMS 直接扫描输出,真正的「全屏系统」 |
| **文件** | 写成 PNG 或编码成视频 —— CI 里跑的就是它 |
| **网络对端** | 把帧和损伤发出去,远端渲染;输入反向回来 |
| **浏览器画布** | WASM + Canvas,桌面直接开在网页里 |
| **另一个桌面** | 屏幕本身是另一套桌面的客户端 —— 套娃 |

最后一条**不是设想,已经跑通了**:同一个二进制,把 headless 换成嵌套后端,它的
每块屏幕就变成宿主里的一个普通窗口,而场景图、焦点、层叠、摆放**一个字没改**。

```
   应用 A ─┐
           ├─► 你的桌面 #1 ──► Screen = 嵌套窗口 ─┐
   应用 B ─┘   (合成核心)                        │
                                                  ▼
                        你的桌面 #2 / 系统合成器
                        (它眼里那只是个普通窗口)
                                  │
                                  ▼
                        Screen = 原生窗口 / DRM / 画布
                                  │
                                  ▼
                             真实显示器
```

⭐ **屏幕即客户端。** 这一层可以无限套,也可以在中间任意一环换成网络 ——
远程桌面、多屏、嵌套调试,全是同一个机制的不同接线,不需要各写一套。

---

## §7 模块怎么切

```
xdesk.core          场景图 / 损伤 / 层叠 / 命中测试 / 窗管策略   ← 纯计算
xdesk.paint         文本与矢量绘制(pango + cairo)             ← 今天就跨平台
xdesk.ui            控件 / 布局 / 事件分发                     ← 要写的那层
xdesk.screen        Screen 抽象(上面那四个方法)
  ├ .headless       离屏 + 截图 —— CI 三平台跑的是它
  ├ .wayland        Linux:嵌套,或独占 TTY(DRM)
  ├ .win32          Windows:一个窗口 + GDI/D3D 呈现
  ├ .cocoa          macOS:一个 NSWindow + CALayer
  └ .android        Android:ANativeWindow + AInputQueue
xdesk.host.wayland  Linux 专属:让真实 Wayland 应用也能进来
```

> ⚠️ **最容易走歪的一步**
>
> 跨平台的难点从来不是抽象有多复杂,而是**别让平台概念往上漏**。
>
> 昨天那个 demo 就是反面教材 —— 它直接写在 wlroots 上,`wlr_scene`、`wlr_seat`、
> `wl_listener` 渗透在每一层,**它按构造就是 Linux 专属的**。作为 demo 完全没
> 问题,但它**不能**当这套系统的底座。
>
> 防线只有一条,而且必须一开始就立起来:**`headless` 和一个真后端从第一天就
> 并存,且 CI 三平台都跑。** 越晚做,漏得越深。

---

## §8 索引现状 —— 实测,不是估计

| 能力 | Linux | Windows | macOS | Android |
|---|---|---|---|---|
| **文本/绘制**<br>pango·cairo·freetype<br>harfbuzz·pixman | ✅ 有 | ✅ 有<br><small>无平台限制字段,CI 跑</small> | ✅ 有 | ✗ 无<br><small>包本身能跨,缺的是工具链</small> |
| **合成器构件**<br>wayland·wlroots<br>mesa·libinput | ✅ 有 | —<br><small>按定义不适用</small> | — | — |
| **出画后端** | ✅ 嵌套已验证<br><small>DRM 要独占 TTY</small> | ✗ 要写 | ✗ 要写 | ✗ 要写 |
| **工具链/交叉编译** | ✅ | ✅<br><small>clang++ 打 MSVC ABI</small> | ✅ | ✗ **没有 NDK subos**<br><small>`mcpp --target` 在,缺供给</small> |
| **控件层** | ✗ | ✗ | ✗ | ✗ —— **这是真正的大头** |

CI 矩阵实测:`macos 1 · linux 3 · windows 2`。`freedesktop.cairo` / `gnome.pango` /
`compat.freetype` / `compat.harfbuzz` / `compat.pixman` 都没有平台限制字段。

Android 在索引里是**零**(只有 `compat.ffmpeg` 里的一堆配置常量),
`xlings subos list` 里也没有任何 android/ndk 条目。

---

## §9 排序

1. **先把 `headless` 和一个真后端跑在同一套核心上,CI 三平台都跑。**
   这一步不产出任何功能,价值在于它会立刻暴露所有漏上来的平台概念。

2. **控件层。** 没有它,桌面里只能放手搓两百行连协议的窗口,撑不起第二个应用。
   这也是唯一一处我建议**自己写而不是包 GTK/Qt** 的地方 —— 那两家各自带着一整套
   窗口系统假设(GTK 认 GdkSurface、Qt 认 QPA),引进来等于同时维护两套概念。

3. **Android 工具链供给**(NDK subos + 一批包按 android triple 重过一遍)。
   放在控件层之后,因为**只有一个平台后端的时候去铺第四个平台,验证不了任何东西**。

4. **最后才是 Wayland 兼容后端。** 它让真实 Linux 应用能进来,是加分项;
   放前面会把整个架构拖成 Linux 形状。

关于代价的实话:Chromium 的 `viz`+`aura` 是几十万行,一个**够用**的版本大概一到
两万行,其中控件层占大头。这不是一个周末的项目 —— 但**最难的合成那部分,已经
跑通过一遍了**(见 `Sunrisepeak/mcpp-demos` 的 `wayland-desktop`)。
