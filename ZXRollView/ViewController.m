//
//  ViewController.m
//  ZXRollView
//
//  Created by Xiang on 16/7/1.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ViewController.h"
#import "ZXRollView.h"

@interface ViewController () <ZXRollViewDelegate>

@property (nonatomic, strong) ZXRollView *rollViewImage;
@property (nonatomic, strong) ZXRollView *rollViewColor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const CGFloat yLocation = 20.f;
    const CGFloat imgRate = 16 / 9.f;
    const CGFloat wScreen = [UIScreen mainScreen].bounds.size.width;
    const CGFloat spa_Edge = 8.f;
    
    
    // 创建指示器为自定义图片的 ZXRollView.
    self.rollViewImage = [[ZXRollView alloc] initWithFrame:CGRectMake(0, 20, wScreen, wScreen / imgRate)];
    [self.view addSubview:self.rollViewImage];
    self.rollViewImage.pageIndicatorImage = [UIImage imageNamed:@"indicatorImageNormal"];
    self.rollViewImage.currentPageIndicatorImage = [UIImage imageNamed:@"indicatorImageHighlight"];
    self.rollViewImage.autoRollingTimeInterval = M_LN10;
    self.rollViewImage.delegate = self;
    [self.rollViewImage reloadViews];
    
    
    // 创建指示器为自定义颜色的 ZXRollView.
    CGFloat x = 2 * spa_Edge;
    CGFloat y = yLocation + self.rollViewImage.frame.size.height + spa_Edge;
    CGFloat w = wScreen - 4 * spa_Edge;
    CGFloat h = (wScreen - 2 * spa_Edge) / imgRate;
    self.rollViewColor = [[ZXRollView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.view addSubview:self.rollViewColor];
    self.rollViewColor.pageIndicatorColor = [UIColor lightGrayColor];
    self.rollViewColor.currentPageIndicatorColor = [UIColor redColor];
    self.rollViewColor.delegate = self;
    self.rollViewColor.autoRolling = YES;
    self.rollViewColor.hideIndicatorForSinglePage = YES;
    self.rollViewColor.interitemSpacing = 0;
    [self.rollViewColor reloadViews];
}

#pragma mark <ZXRollViewDelegate>
- (NSInteger)numberOfItemsInRollView:(ZXRollView *)rollView {
    if (rollView == _rollViewImage) {
        return 3;
    } else {
       return 5;
    }
}

- (void)rollView:(nonnull ZXRollView *)rollView setViewForRollView:(nonnull UIView *)view atIndex:(NSInteger)index {
    switch (index) {
        case 0: {
            view.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.502 alpha:1.000];
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, view.frame.size.width - 20, 100)];
            subView.backgroundColor = [UIColor whiteColor];
            [view addSubview:subView];
        }
            break;
        case 1:
            view.backgroundColor = [UIColor colorWithRed:0.502 green:0.000 blue:0.251 alpha:1.000];
            break;
        case 2:
            view.backgroundColor = [UIColor colorWithRed:0.800 green:0.400 blue:1.000 alpha:1.000];
            break;
        case 3:
            view.backgroundColor = [UIColor colorWithRed:0.400 green:1.000 blue:0.800 alpha:1.000];
            break;
            
        default:
            view.backgroundColor = [UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1.000];
            break;
    }
}

- (void)rollView:(ZXRollView *)rollView didTapItemAtIndex:(NSInteger)index {
    if (rollView == _rollViewImage) {
        NSLog(@"=== Tap the rollViewImage index %ld", index);
    } else {
        NSLog(@"*** Tap the rollViewColor index %ld", index);
    }
}

- (void)dealloc {
    [self.rollViewImage invalidate];
    [self.rollViewColor invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
