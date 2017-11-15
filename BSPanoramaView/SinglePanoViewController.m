//
//  TableviewTestViewController.m
//  BSPanoramaView
//
//  Created by 张星宇 on 11/15/17.
//  Copyright © 2017 bestswifter. All rights reserved.
//

#import "SinglePanoViewController.h"
#import "BSPanoramaView.h"

@interface SinglePanoViewController ()

@end

@implementation SinglePanoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect panoRect = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height- 64);
    BSPanoramaView *panoView = [[BSPanoramaView alloc] initWithFrame:panoRect imageName:@"test"];
    [self.view addSubview:panoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
