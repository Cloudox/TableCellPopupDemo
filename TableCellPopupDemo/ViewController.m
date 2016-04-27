//
//  ViewController.m
//  TableCellPopupDemo
//
//  Created by csdc-iMac on 16/4/27.
//  Copyright © 2016年 Cloudox. All rights reserved.
//

#import "ViewController.h"
#import "BookListCellView.h"
#import "DetailViewController.h"

//设备的宽高
#define SCREENWIDTH       [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT      [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) BookListCellView *transitionCell;

@property (nonatomic, strong) UIView *tempView;
@property (nonatomic, strong) UIView *bgView;// 阴影视图
@property (nonatomic, strong) BookListCellView *selectedCell;// 选中的cell

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"点击Cell动画";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 初始化列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, SCREENWIDTH, SCREENHEIGHT)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tempView removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self.selectedCell removeFromSuperview];
}

// 阴影视图
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _bgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView Data Source
// 列表的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

// 每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BookListCellView *cell = (BookListCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell getHeight];
}

// 列表每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[BookListCellView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 90) andData:@[@"《iOS开发》", @"1111", @""]];
    }
    return cell;
}

#pragma mark TableView Delegate
// 选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 选中后取消选中的颜色
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect sourceRect = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    self.selectedCell = (BookListCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell.frame = sourceRect;
    self.selectedCell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectedCell];
    [self bgView];
    [self.view addSubview:_bgView];
    [self.view bringSubviewToFront:self.selectedCell];
    self.tempView = [[UIView alloc] initWithFrame:self.selectedCell.frame];
    self.tempView.backgroundColor = [UIColor whiteColor];
    self.tempView.alpha = 0;
    [self.view addSubview:self.tempView];
    // 进行动画
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedCell.transform = CGAffineTransformMakeScale(1.0, 1.1);
        self.tempView.alpha = 1;
    }];
    
    double delayInSeconds = 0.3;
    __block ViewController* bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [bself.selectedCell removeFromSuperview];
        // 进行动画
        [UIView animateWithDuration:0.3 animations:^{
            bself.tempView.transform = CGAffineTransformMakeScale(1.0, SCREENHEIGHT / bself.tempView.frame.size.height * 2);
        }];
    });
    
    double delayInSeconds2 = 0.6;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        // 进行动画
        [UIView animateWithDuration:0.3 animations:^{
            [bself.navigationController pushViewController:detailVC animated:NO];
        }];
    });
}

@end
