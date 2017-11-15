# BSPanoramaView

BSPanoramaView 是 iOS 平台上一个轻量的全景图组件，**它不依赖任何第三方框架，仅有 300 多行代码，最终的包大小只会增加 30Kb 左右。**

![](./BSPanorama.gif)

由于录制屏幕的原因，横屏效果无法展示，在真机上会有更好的用户体验。

BSPanoramaView 从 [WushuputiGH/Panorama](https://github.com/WushuputiGH/Panorama) 这个 Repo 中借鉴了很多 OpenGL 相关的运算，主要涉及模型生成以及矩阵变换。

BSPanoramaView 重构了整个应用层并且修复了几个重大的 bug，因此基本上可以投入生产环境使用。可能是因为没有正式测试的原因，目前没有发现明显的问题。如果你的项目对性能和稳定性的要求不是变态级别的，可以考虑使用 BSPanoramaView 或者在此基础上略作修改。

# 使用方法

`BSPanoramaView` 是 `GLKView` 的子类，而后者又是 `UIView` 的子类，所以可以直接把 `BSPanoramaView` 当成一个普通的 `UIView` 来使用，比如：

```objc
#import "BSPanoramaView.h"

- (void)viewDidLoad {
    [super viewDidLoad];

    BSPanoramaView *panoView = [[BSPanoramaView alloc] initWithFrame:self.view.bounds imageName:@"test"];
    [self.view addSubview:panoView];
}
```

OpenGL 的纹理，也就是图片，相当占用内存。以一张 4096 * 2048 的图片为例，它会占用 `4096 * 2048 * 4 / 1024 / 1024 = 32M` 的内存，这个虽然难以避免但我们应该对此保持警惕，尽可能及时的释放它。当 `BSPanoramaView` 的实例被释放时，它的 `dealloc` 函数会调用 `unloadImage` 方法释放内存：

```objc
- (void)dealloc {
    [self unloadImage];
}
```

在这种情况下，内存管理对使用者是透明的，无需额外的关注。但如果在 `UITableview` 中使用了 BSPanoramaView，由于 cell 会被重用，因此在 cell 滑出屏幕外时，需要手动调用 `unloadImage` 方法，这在 Demo 的 `PanoTableViewCell` 类中有具体的代码。

# 安装方法

由于整个项目只有两个文件，所以直接拖到工程里也是可以的。然而 BSPanoramaView 还处于不稳定的版本，随时会有更新来修复 bug 或者新增功能，所以我的建议是使用 Cocoapods：

```
pod 'BSPanoramaView'
```

# 原理介绍

就像把大象放进箱子里需要三步一样，全景图控件并非系统提供，也需要以下几个步骤：

1. 生成一个球，这个球是由多个三角形近似拼接起来的，三角形的顶点就是 OpenGL 中的顶点数组对象（VBO）
2. 想象一下两个三角形可以拼成一个矩形，用三角形表示的话需要六个点，但实际上矩形只要四个点，这是因为有两个点被重复了，导致浪费了一些内存空间，这时候我们定义一个四个顶点的数组，然后用数组下标来表示顶点，再多的顶点也不会增加多少内存占用，这叫索引缓冲对象（IBO）
3. 有了顶点数组对象和索引缓冲对象以后，OpenGL 就可以画出一个球了，接来下的任务就是加载纹理，也就是图片，并且把纹理贴到球上。

以上基本上就是 OpenGL 的绘制过程，对 OpenGL 完全不了解的同学可以参考[这篇文章](https://learnopengl-cn.github.io/01%20Getting%20started/04%20Hello%20Triangle/) 简单的学习一下。在 `BSPanoramaView` 中，由于不考虑多平台兼容，所以使用了 OC 的 GLKit，它是对 OpenGL 的封装，提供了很多有效的函数。

`BSPanoramaView` 中的 `setupOpenGL` 方法就是处理这个问题的。

## 定时绘制

OpenGL 需要我们手动管理绘制，也就是一秒钟绘制 60 帧，这可以通过 `CADisplayLink` 实现。

不管是设备的晃动还是手势拖拽，最终都会以变换矩阵的形式呈现，应用到 OpenGL 中并且改变我们看到的结果。

考虑到多个 `BSPanoramaView` 实例有可能同时存在，为了避免性能损耗，我使用了单例的 `PanoramaManager` 负责获取设备的位移信息，并且注册了 `CADisplayLink` 负责定时绘制。

每个 `BSPanoramaView` 都会把自己注册到 manager 的弱引用数组中，这样可以确保自己的绘制方法每 1/60 秒都会被调用一次。同样的，`BSPanoramaView` 也不会访问设备的位置信息，而是由单例的 manager 获取一次，然后分发给多个实例。

## 传感器信息

传统的描述位置信息的方法是欧拉角，它由三个角度（横滚、偏航、俯仰）组成，然而欧拉角的最大问题是万向节死锁，导致角度错乱。因此在 iOS 上我们使用四元数避免上述问题，而且通过 GLKit 的 `GLKMatrix4MakeWithQuaternion` 函数直接转换成变换矩阵。

为了兼容模拟器，我构造了一个固定的四元数。

## 矩阵变换

无论是滑动手势还是缩放手势，最终都会转换成矩阵运算，从[WushuputiGH/Panorama](https://github.com/WushuputiGH/Panorama) 中抄来的代码虽然看起来格式不太正确，但工作起来却意外的毫无问题，暂时没有调整的计划。
