# BSPanoramaView

中文文档请阅读[这里](./Chinese.md)

![](http://images.bestswifter.com/BSPanorama.gif)

Due to the limitation of recording screen, the actual experience on real device is much better the gif shown above.

BSPanoramaView is a lightweight panorama picture browser on iOS platform, which will only make the binary file 30k larger.

BSPanoramaView does not rely on any other third party framework and it only contains about three hundred lines of code.

BSPanoramaView was inspired by [WushuputiGH/Panorama](https://github.com/WushuputiGH/Panorama) and copied some calculations about OpenGL but rewrote the application architecture and fixed many bugs. 

At current time, BSPanoramaView can be applied in production environment if you are tolerant of some tiny defects.

# Usage

BSPanoramaView is the subclass of `GLKView` which itself is a subclass of `UIView`, so you can use BSPanoramaView as a normal view:

```objc
#import "BSPanoramaView.h"

- (void)viewDidLoad {
    [super viewDidLoad];

    BSPanoramaView *panoView = [[BSPanoramaView alloc] initWithFrame:self.view.bounds imageName:@"test"];
    [self.view addSubview:panoView];
}
```

The texture(test.png) takes a lot of memory. For example, an picture with resolution of 4096 * 20148 takes 32M memory which means you should be careful about the memory occupation.

When the instance of BSPanoramaView is released, it will unload the texture in `dealloc` method and you don't need to pay any extra attention to this:

```objc
- (void)dealloc {
    [self unloadImage];
}
```

However, if it is not released, such as scrolling outside the screen, you should be careful to call `unloadImage` method manually at proper time. This is also demostrated in the code in `PanoTableViewCell` class.

# Installation

You can just copy the source code into your project because there are only two files.

However, since this is a beta-version code which may be optimized constantly, I strongly encourage you to use **Cocoapods**:

```
pod 'BSPanoramaView'
```
