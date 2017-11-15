//
//  PanoTableViewCell.m
//  全景_图片
//
//  Created by 张星宇 on 11/14/17.
//  Copyright © 2017 H. All rights reserved.
//

#import "PanoTableViewCell.h"
#import "BSPanoramaView.h"

#define kPanoViewInterval 4

@interface PanoTableViewCell()

@property (nonatomic, strong) BSPanoramaView *panoView;

@end

@implementation PanoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 300);
        self.panoView = [[BSPanoramaView alloc] initWithFrame:rect];
        [self.contentView addSubview:self.panoView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)willBeDisplayed:(NSUInteger)index {
    [self.panoView setImageWithName:@"test"];
}

- (void)didStopDisplayed:(NSUInteger)index {
    [self.panoView unloadImage];
}

@end
