//
//  BSPanoramaView.h
//  BSPanoramaView
//
//  Created by 张星宇 on 11/15/17.
//  Copyright © 2017 bestswifter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@class BSPanoramaView;

@interface PanoramaManager: NSObject

@property (nonatomic, assign) GLKQuaternion lastQuaternion;    ///< 存储最近一次有效的四元数

+ (PanoramaManager *)sharedInstance;
- (void)registerView:(BSPanoramaView *)view;
- (void)unRegisterView:(BSPanoramaView *)view;

@end

@interface BSPanoramaView : GLKView

/**
 新建全景图对象

 @param frame 图片大小
 @return 图片资源名称
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 新建全景图对象

 @param frame 图片大小
 @param imageName 图片资源名称，如果图片分辨率高于 4096 * 2048，为了避免过高的内存占用会拒绝加载
 @return 全景图对象
 */
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName;

/**
 加载全景图片

 @param imageName 全景图图片名称
 */
- (void)setImageWithName:(NSString *)imageName;

/**
 当不再使用时应该释放内存，并且把自己从全局的 PanoramaManager 中移除
 */
- (void)unloadImage;

@end
