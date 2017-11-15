# BSPanoramaView

BSPanoramaView 是 iOS 平台上一个轻量的全景图组件，它不依赖任何第三方框架，仅有 300 多行代码，最终的包大小只会增加 30Kb 左右。

BSPanoramaView 从 [WushuputiGH/Panorama](https://github.com/WushuputiGH/Panorama) 这个 Repo 中借鉴了很多 OpenGL 相关的运算，主要涉及模型生成以及矩阵变换。

BSPanoramaView 基本上重构了整个应用层并且修复了几个重大的 bug，因此基本上可以投入生产环境使用。可能是因为没有正式测试的原因，目前没有发现明显的问题。如果你的项目对性能和稳定性的要求不是变态级别的，可以考虑使用 BSPanoramaView 或者在此基础上略作修改。

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

