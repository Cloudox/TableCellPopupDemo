# TableCellPopupDemo
点击列表cell弹出界面的动画demo

## 效果图
![](https://github.com/Cloudox/TableCellPopupDemo/blob/master/screen.gif)

## 实现方法
仔细观察的话效果分为几个部分，点击cell的时候，首先背景会出现阴影，只有点击的cell还亮着，然后有一点点的放大效果，同时cell的界面在慢慢变成纯白色，最后上下炸开进入内容界面，其实仔细想想，这个和3D Touch的peek效果的前奏不是很像嘛。

弄清楚动画的组成成分以后，开始动手实现，怎么实现列表和详情界面就不说了，可以在文末我的示例工程里面看，直接说cell的点击后执行的过程。

我们这里需要额外用到三个小vied，一个是背景的阴影view，一个是点击的cell的view，一个是cell慢慢变成的纯白色view（最后炸开的也是这个纯白的view）。

所以我们先声明者三个view：

```objective-c
@property (nonatomic, strong) UIView *tempView;// 纯白view
@property (nonatomic, strong) UIView *bgView;// 阴影视图
@property (nonatomic, strong) BookListCellView *selectedCell;// 选中的cell
```

这个声明要做成整个视图控制器可调用的，为什么呢？因为这三个视图是在我们点击的时候添加的，我们必须进行移除，否则从详情界面回来列表界面之后，这三个视图还会存在，所以我们要在viewWillAppear方法中将其移除：

```objective-c
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tempView removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self.selectedCell removeFromSuperview];
}
```

三个视图中，背景的阴影视图是固定大小的，即使覆盖整个界面，cell视图和纯白视图要根据点击的位置决定，所以阴影视图可以直接写一个方法来创建：

```objective-c
// 阴影视图
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _bgView;
}
```

接下来就是动画的部分了，我们去到点击cell的方法，也就是
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
方法，代码如下：

```objective-c
#pragma mark TableView Delegate
// 选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 选中后取消选中的颜色
    
    // 详情视图
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    
    // 获取选中的区域范围
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect sourceRect = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
    // 实例化选中的cell视图，内容根据选中的cell内容来获取，范围使用上面获取的范围
    self.selectedCell = (BookListCellView *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell.frame = sourceRect;
    self.selectedCell.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.selectedCell];
    
    // 阴影视图
    [self bgView];
    [self.view addSubview:_bgView];
    // 将cell视图放在最前面
    [self.view bringSubviewToFront:self.selectedCell];
    
    // 实例化纯白视图，范围和cell视图一样，先做成透明
    self.tempView = [[UIView alloc] initWithFrame:self.selectedCell.frame];
    self.tempView.backgroundColor = [UIColor whiteColor];
    self.tempView.alpha = 0;
    [self.view addSubview:self.tempView];
    // 进行动画
    [UIView animateWithDuration:0.3 animations:^{
        // 稍微增加cell视图的大小
        self.selectedCell.transform = CGAffineTransformMakeScale(1.0, 1.1);
        // 纯白视图的透明度设为不透明，这样就会覆盖cell视图
        self.tempView.alpha = 1;
    }];
    
    // 延迟执行
    double delayInSeconds = 0.3;
    __block ViewController* bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [bself.selectedCell removeFromSuperview];
        // 进行动画
        [UIView animateWithDuration:0.3 animations:^{
            // 炸开纯白视图到全屏
            bself.tempView.transform = CGAffineTransformMakeScale(1.0, SCREENHEIGHT / bself.tempView.frame.size.height * 2);
        }];
    });
    
    // 延迟执行
    double delayInSeconds2 = 0.6;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        // 进入详情界面
        [bself.navigationController pushViewController:detailVC animated:NO];
    });
}
```

注释解释了大部分的内容，我们来拆分一下，整个动画分为三个过程：

1. 第一个过程是加阴影，新创建一个对应的cell显示出来，在动画中稍微增大cell凸显效果，同时有一个纯白视图慢慢覆盖cell视图；
2. 第二个过程是炸开纯白视图，在动画中将其的大小设为整个屏幕大小，就可以实现炸开覆盖效果；
3. 第三个过程就是进入详情界面。

第二个过程和第三个过程都要分别加上延时才能正确执行，否则会一起执行就看不出效果了。动画是使用的最基本的UIView动画，教程可以看我[这篇博客](http://blog.csdn.net/cloudox_/article/details/50736092)，使用起来还是很方便的，延迟执行我用的GCD的方法，也可以用别的你熟悉的方式。可以看出我们把三个新的视图覆盖在了界面上，所以每次列表界面要出现的时候我们就要将其移除，如上所述。要注意的是我们不能直接使用点击到的cell的位置，经测试直接用他的原点会变成（0, 0），也就是出现在左上角，我也不知道为什么，所以这里要先获取对应的区域来更改cell的范围并作为纯白view的范围。

这样就实现啦，效果很不错的~更多内容可以查看[我的博客](http://blog.csdn.net/cloudox_/article/details/51262827)
