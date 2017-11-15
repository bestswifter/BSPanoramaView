//
//  ViewController.m
//  BSPanoramaView
//
//  Created by 张星宇 on 11/15/17.
//  Copyright © 2017 bestswifter. All rights reserved.
//

#import "ViewController.h"

#import "TablePanoViewController.h"
#import "SinglePanoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *jumpToSingleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpToSingleButton.frame = CGRectMake(50, 200 + 10, [UIScreen mainScreen].bounds.size.width - 100, 40);
    [jumpToSingleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [jumpToSingleButton setBackgroundColor:[UIColor grayColor]];
    [jumpToSingleButton setTitle:@"测试单个全景图" forState:UIControlStateNormal];
    [jumpToSingleButton addTarget:self action:@selector(navigateToSinglePanoView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpToSingleButton];
    
    UIButton *jumpToMultiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpToMultiButton.frame = CGRectMake(50, 300 + 10, [UIScreen mainScreen].bounds.size.width - 100, 40);
    [jumpToMultiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [jumpToMultiButton setBackgroundColor:[UIColor grayColor]];
    [jumpToMultiButton setTitle:@"在 UITableview 中测试" forState:UIControlStateNormal];
    [jumpToMultiButton addTarget:self action:@selector(navigateToMultiPanoView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpToMultiButton];
}

- (void)navigateToSinglePanoView:(id)sender {
    [self.navigationController pushViewController:[SinglePanoViewController new] animated:YES];
}

- (void)navigateToMultiPanoView:(id)sender {
    [self.navigationController pushViewController:[TablePanoViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
