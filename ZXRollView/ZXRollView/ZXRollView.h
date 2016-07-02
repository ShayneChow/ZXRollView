//
//  ZXRollView.h
//  ZXRollView
//
//  Created by Xiang on 16/7/1.
//  Copyright © 2016年 周想. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXRollView;

@protocol ZXRollViewDelegate <NSObject>

@required

/**
 *  @param rollView  一个表示请求该信息的 ZXRollview 对象.
 *  @return 返回 ZXRollView 的View个数
 */
- (NSInteger)numberOfItemsInRollView:(nonnull ZXRollView *)rollView;

/**
 *  @param rollView  一个表示请求该信息的 ZXRollview 对象.
 *  @param view      设置到 rollView 的视图对象.
 *  @param index     view 的位置.
 */
- (void)rollView:(nonnull ZXRollView *)rollView setViewForRollView:(nonnull UIView *)view atIndex:(NSInteger)index;

@optional

/**
 *  点击事件回调
 *
 *  @param rollView  请求该信息的 ZXRollView 对象.
 *  @param index     点击所在位置.
 */
- (void)rollView:(nonnull ZXRollView *)rollView didTapItemAtIndex:(NSInteger)index;

@end

@interface ZXRollView : UIView

/**
 *  ZXRollView 代理
 */
@property (nonatomic, weak, nullable) id <ZXRollViewDelegate> delegate;

/**
 *  自定义指示器颜色.
 */
@property (nonatomic, strong, nullable) UIColor *pageIndicatorColor;
@property (nonatomic, strong, nullable) UIColor *currentPageIndicatorColor;

/**
 *  自定义指示器的图片, 两者同时设置才有效果并且忽略指示器的颜色设置.(图片大小[4, 18]pt.)
 */
@property (nonatomic, strong, nullable) UIImage *pageIndicatorImage;
@property (nonatomic, strong, nullable) UIImage *currentPageIndicatorImage;

/**
 *  视图的内容模式. 默认 UIViewContentModeScaleAspectFill.
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

/**
 *  视图之间的间距 默认 8pt.
 */
@property (nonatomic, assign) CGFloat interitemSpacing;

/**
 *  自动滚动 默认 YES.
 */
@property (nonatomic, assign) BOOL autoRolling;

/**
 *  自动滚动时间间隔 [1.6, 6.0]s 默认 3s.
 */
@property (nonatomic, assign) CGFloat autoRollingTimeInterval;

/**
 *  页面指示器距底部的距离 默认 8pt.
 */
@property (nonatomic, assign) CGFloat indicatorToBottomSpacing;

/**
 *  如果只有一张图片时自动隐藏指示器, 同时滚动禁用. 默认 NO.
 */
@property (nonatomic, assign) BOOL hideIndicatorForSinglePage;

/**
 *  与 UITableView 类似
 */
- (void)reloadViews;

/**
 *  释放定时器.
 */
- (void)invalidate;

@end
