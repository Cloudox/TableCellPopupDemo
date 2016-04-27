//
//  DetailViewController.m
//  TableCellPopupDemo
//
//  Created by csdc-iMac on 16/4/27.
//  Copyright © 2016年 Cloudox. All rights reserved.
//

#import "DetailViewController.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"详情界面";
    
    UILabel *noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 250) / 2, 200, 250, 20)];
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    noResultLabel.textColor = [UIColor blackColor];
    noResultLabel.text = @"这是详情界面";
    noResultLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:noResultLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
