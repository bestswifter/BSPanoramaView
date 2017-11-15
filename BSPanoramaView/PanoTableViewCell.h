//
//  PanoTableViewCell.h
//  全景_图片
//
//  Created by 张星宇 on 11/14/17.
//  Copyright © 2017 H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanoTableViewCell : UITableViewCell

- (void)willBeDisplayed:(NSUInteger)index;
- (void)didStopDisplayed:(NSUInteger)index;

@end
