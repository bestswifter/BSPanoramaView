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

@property (nonatomic, assign) GLKQuaternion lastQuaternion;    /// 存储上一次的四元数

+ (PanoramaManager *)sharedInstance;
- (void)registerView:(BSPanoramaView *)view;
- (void)unRegisterView:(BSPanoramaView *)view;

@end

@interface BSPanoramaView : GLKView

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)imageName;

/**
 * 加载图片
 * @param imageName 全景图图片名
 */
- (void)setImageWithName:(NSString *)imageName;

/**
 *  当不再使用时应该释放内存，并且把自己从全局的 PanoramaManager 中移除
 */
- (void)unloadImage;

@end
