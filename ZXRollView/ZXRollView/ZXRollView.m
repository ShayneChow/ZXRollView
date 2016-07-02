//
//  ZXRollView.m
//  ZXRollView
//
//  Created by Xiang on 16/7/1.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ZXRollView.h"

static const CGFloat    ZXAutoRollTimeIntervalDefault       = 3.f;
static const CGFloat    ZXAutoRollTimeIntervalMin           = 1.599999f;
static const CGFloat    ZXAutoRollTimeIntervalMax           = 6.000001f;
static const CGFloat    ZXInteritemSpacingDefault           = 8.f;
static const CGFloat    ZXIndicatorToBottomSpacingDefault   = 8.f;
static const CGFloat    ZXSystemIndicatorSide               = 7.f;
static const CGFloat    ZXTimerCycle                        = 0.2f;

// only for indicatorImage
static const CGFloat    ZXIndicatorSideMin                  = 4.f;
static const CGFloat    ZXIndicatorSideMax                  = 18.f;
static const CGFloat    ZXIndicatorInteritemSpacing         = 8.f;

typedef NS_ENUM(NSUInteger, ZXRollViewIndicatorStyle) {
    ZXRollViewIndicatorStyleColor = 1,
    ZXRollViewIndicatorStyleImage,
};

//#define ZX_ROLLVIEW_DEBUG
#define ZX_DEALLOC_TEST   - (void)dealloc { NSLog(@"dealloc -> %@",NSStringFromClass([self class])); }

#pragma mark - JXPageControl

@interface ZXPageControl : UIView

@property (nonatomic, assign)   NSUInteger              currentPage;
@property (nonatomic, assign)   NSUInteger              numberOfPages;
@property (nonatomic, strong)   UIImage                 *pageIndicatorImage;
@property (nonatomic, strong)   UIImage                 *currentPageIndicatorImage;
@property (nonatomic, assign)   BOOL                    hidesForSinglePage;

- (ZXPageControl *)initWithPageIndicatorImage:(UIImage *)pageIndicatorImage
                    currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage;

@end

@interface ZXPageControl ()

@property (nonatomic, strong)   NSMutableArray <UIImageView *> *imgViews;
//@property (nonatomic, strong)   NSMutableArray <UIView *> *rollViews;

@end

@implementation ZXPageControl

- (ZXPageControl *)initWithPageIndicatorImage:(UIImage *)pageIndicatorImage currentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
        _imgViews = [[NSMutableArray alloc] init];
        _pageIndicatorImage = pageIndicatorImage;
        _currentPageIndicatorImage = currentPageIndicatorImage;
    }
    return self;
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    if (self.numberOfPages < numberOfPages) {
        for (NSInteger i = self.numberOfPages; i < numberOfPages; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            [self addSubview:imgView];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [self.imgViews addObject:imgView];
        }
    }
    else {
        for (NSInteger i = 0; i < self.numberOfPages - numberOfPages; i ++) {
            [[self.imgViews lastObject] removeFromSuperview];
            [self.imgViews removeLastObject];
        }
    }
    _numberOfPages = numberOfPages;
    
    CGFloat wIndicator = self.numberOfPages * (ZXIndicatorInteritemSpacing + self.frame.size.height) - ZXIndicatorInteritemSpacing;
    CGFloat xLocFirstImgView = (self.frame.size.width - wIndicator) / 2;
    for (NSInteger i = 0; i < self.numberOfPages; i ++) {
        self.imgViews[i].frame = CGRectMake(xLocFirstImgView + i * (ZXIndicatorInteritemSpacing + self.frame.size.height),
                                            0,
                                            self.frame.size.height,
                                            self.frame.size.height);
        self.imgViews[i].image = i == self.currentPage ? self.currentPageIndicatorImage : self.pageIndicatorImage;
    }
    self.hidden = (self.hidesForSinglePage && self.numberOfPages == 1) || self.numberOfPages == 0;
    
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (self.numberOfPages > 0) {
        if (_currentPage < self.imgViews.count) {
            self.imgViews[_currentPage].image = self.pageIndicatorImage;
        }
        self.imgViews[currentPage].image = self.currentPageIndicatorImage;
        _currentPage = currentPage;
    }
}

#ifdef ZX_ROLLVIEW_DEBUG
ZX_DEALLOC_TEST
#endif

@end

#pragma mark - ZXRollView

@interface ZXRollView () <UIScrollViewDelegate>

@property (nonatomic, assign)   CGFloat                     wSelf;                      //
@property (nonatomic, assign)   CGFloat                     hSelf;                      //
@property (nonatomic, assign)   CGFloat                     wScrollView;                //

@property (nonatomic, strong)   UIScrollView                *scrollView;                //
//@property (nonatomic, strong)   NSMutableArray <UIImageView *>  *imgViews;
@property (nonatomic, strong)   NSMutableArray <UIView *>   *rollViews; //
@property (nonatomic, assign)   ZXRollViewIndicatorStyle    rollViewIndicatorStyle;     //
@property (nonatomic, strong)   UIPageControl               *pageControlColor;          //
@property (nonatomic, strong)   ZXPageControl               *pageControlImage;          //

@property (nonatomic, assign)   NSInteger                   currentPage;                //
@property (nonatomic, assign)   NSInteger                   numberOfPages;              //

@property (nonatomic, strong)   NSTimer                     *timer;                     //
@property (nonatomic, assign)   NSUInteger                  cycleCounter;               //
@property (nonatomic, assign)   BOOL                        counting;                   //

@end

@implementation ZXRollView

#pragma mark public setter
- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor {
    _pageIndicatorColor = pageIndicatorColor;
    self.pageControlColor.pageIndicatorTintColor = self.pageIndicatorColor;
}

- (void)setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor {
    _currentPageIndicatorColor = currentPageIndicatorColor;
    self.pageControlColor.currentPageIndicatorTintColor = self.currentPageIndicatorColor;
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage {
    _pageIndicatorImage = pageIndicatorImage;
    [self decideIndicatorImage];
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    _currentPageIndicatorImage = currentPageIndicatorImage;
    [self decideIndicatorImage];
}

- (void)decideIndicatorImage {
    if (self.pageIndicatorImage &&
        self.currentPageIndicatorImage &&
        self.pageIndicatorImage.size.width > 0 &&
        self.pageIndicatorImage.size.height > 0 &&
        self.currentPageIndicatorImage.size.width > 0 &&
        self.currentPageIndicatorImage.size.height > 0) {
        self.pageControlImage = [[ZXPageControl alloc] initWithPageIndicatorImage:self.pageIndicatorImage
                                                        currentPageIndicatorImage:self.currentPageIndicatorImage];
        [self addSubview:self.pageControlImage];
        self.rollViewIndicatorStyle = ZXRollViewIndicatorStyleImage;
        [self.pageControlColor removeFromSuperview];
        [self reSetFrame];
    }
}

//- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
//    _imageContentMode = imageContentMode;
//    for (UIImageView *imgViewEnum in self.imgViews) {
//        imgViewEnum.contentMode = self.imageContentMode;
//    }
//}

- (void)setAutoRolling:(BOOL)autoRolling {
    _autoRolling = autoRolling;
}

- (void)setAutoRollingTimeInterval:(CGFloat)autoRollingTimeInterval {
    if (autoRollingTimeInterval >= ZXAutoRollTimeIntervalMin &&
        autoRollingTimeInterval <= ZXAutoRollTimeIntervalMax) {
        _autoRollingTimeInterval = autoRollingTimeInterval;
    }
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self reSetFrame];
}

- (void)setIndicatorToBottomSpacing:(CGFloat)indicatorToBottomSpacing {
    _indicatorToBottomSpacing = indicatorToBottomSpacing;
    [self reSetFrame];
}

- (void)setHideIndicatorForSinglePage:(BOOL)hideIndicatorForSinglePage {
    _hideIndicatorForSinglePage = hideIndicatorForSinglePage;
    if (self.rollViewIndicatorStyle == ZXRollViewIndicatorStyleColor) {
        self.pageControlColor.hidesForSinglePage = self.hideIndicatorForSinglePage;
    }
    else {
        self.pageControlImage.hidesForSinglePage = self.hideIndicatorForSinglePage;
    }
}

#pragma mark private setter
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    if (self.rollViewIndicatorStyle == ZXRollViewIndicatorStyleColor) {
        self.pageControlColor.currentPage = self.currentPage;
    }
    else {
        self.pageControlImage.currentPage = self.currentPage;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    if (self.rollViewIndicatorStyle == ZXRollViewIndicatorStyleColor) {
        self.pageControlColor.numberOfPages = self.numberOfPages;
    }
    else {
        self.pageControlImage.numberOfPages = self.numberOfPages;
    }
    
    if (self.numberOfPages == 1 && self.hideIndicatorForSinglePage) {
        self.scrollView.scrollEnabled = NO;
    }
}

- (UIImageView *)createImageView {
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
    imgView.clipsToBounds = YES;
    imgView.contentMode = self.imageContentMode;
    return imgView;
}

- (UIView *)createRollView {
    UIView *rollView = [[UIView alloc] init];
    rollView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0f];
    rollView.clipsToBounds = YES;
    //rollView.contentMode = self.imageContentMode;
    return rollView;
}

//- (void)reFrame {
//    self.wSelf = CGRectGetWidth(self.frame);
//    self.hSelf = CGRectGetHeight(self.frame);
//    self.wScrollView = self.wSelf + self.interitemSpacing;
//    
//    [self.scrollView setContentSize:CGSizeMake(self.imgViews.count * self.wScrollView, self.hSelf)];
//    [self.scrollView setContentOffset:CGPointMake(self.wScrollView, 0)];
//    [self.scrollView setFrame:CGRectMake(0, 0, self.wScrollView, self.hSelf)];
//    for (NSInteger i = 0; i < self.imgViews.count; i ++) {
//        CGRect rectImgView = CGRectMake(i * self.wScrollView, 0, self.wSelf, self.hSelf);
//        self.imgViews[i].frame = rectImgView;
//        [self.scrollView addSubview:self.imgViews[i]];
//    }
//    
//    if (self.rollViewIndicatorStyle == ZXRollViewIndicatorStyleColor) {
//        self.pageControlColor.frame = CGRectMake(0,
//                                                 self.hSelf - self.indicatorToBottomSpacing - ZXSystemIndicatorSide,
//                                                 self.wSelf,
//                                                 ZXSystemIndicatorSide);
//    }
//    else {
//        CGSize indicatorSize = self.pageControlImage.pageIndicatorImage.size;
//        CGFloat indicatorSide = indicatorSize.width > indicatorSize.height ? indicatorSize.width : indicatorSize.height;
//        indicatorSide = indicatorSide < ZXIndicatorSideMin ? ZXIndicatorSideMin : (indicatorSide > ZXIndicatorSideMax ? ZXIndicatorSideMax : indicatorSide);
//        
//        self.pageControlImage.frame = CGRectMake(0,
//                                                 self.hSelf - self.indicatorToBottomSpacing - indicatorSide,
//                                                 self.wSelf,
//                                                 indicatorSide);
//    }
//}

- (void)reSetFrame {
    self.wSelf = CGRectGetWidth(self.frame);
    self.hSelf = CGRectGetHeight(self.frame);
    self.wScrollView = self.wSelf + self.interitemSpacing;
    
    [self.scrollView setContentSize:CGSizeMake(self.rollViews.count * self.wScrollView, self.hSelf)];
    [self.scrollView setContentOffset:CGPointMake(self.wScrollView, 0)];
    [self.scrollView setFrame:CGRectMake(0, 0, self.wScrollView, self.hSelf)];
    for (NSInteger i = 0; i < self.rollViews.count; i ++) {
        CGRect rectImgView = CGRectMake(i * self.wScrollView, 0, self.wSelf, self.hSelf);
        self.rollViews[i].frame = rectImgView;
        [self.scrollView addSubview:self.rollViews[i]];
    }
    
    if (self.rollViewIndicatorStyle == ZXRollViewIndicatorStyleColor) {
        self.pageControlColor.frame = CGRectMake(0,
                                                 self.hSelf - self.indicatorToBottomSpacing - ZXSystemIndicatorSide,
                                                 self.wSelf,
                                                 ZXSystemIndicatorSide);
    }
    else {
        CGSize indicatorSize = self.pageControlImage.pageIndicatorImage.size;
        CGFloat indicatorSide = indicatorSize.width > indicatorSize.height ? indicatorSize.width : indicatorSize.height;
        indicatorSide = indicatorSide < ZXIndicatorSideMin ? ZXIndicatorSideMin : (indicatorSide > ZXIndicatorSideMax ? ZXIndicatorSideMax : indicatorSide);
        
        self.pageControlImage.frame = CGRectMake(0,
                                                 self.hSelf - self.indicatorToBottomSpacing - indicatorSide,
                                                 self.wSelf,
                                                 indicatorSide);
    }
}

//- (void)reloadImages {
//    self.counting = NO;
//    self.numberOfPages = [self.delegate numberOfItemsInRollView:self];
//    
//    for (UIImageView *imgView in self.imgViews) {
//        [imgView removeFromSuperview];
//    }
//    [self.imgViews removeAllObjects];
//    if (self.numberOfPages > 0) {
//        for (NSInteger i = 0; i < self.numberOfPages + 2; i ++) { [self.imgViews addObject:[self createImageView]]; }
//        [self reSetFrame];
//        self.currentPage = 0;
//        [self refreshImages];
//        self.cycleCounter = 0;
//        self.counting = YES;
//        self.scrollView.hidden = NO;
//        self.userInteractionEnabled = YES;
//    }
//    else {
//        self.scrollView.hidden = YES;
//        self.userInteractionEnabled = NO;
//    }
//}

- (void)reloadViews {
    self.counting = NO;
    self.numberOfPages = [self.delegate numberOfItemsInRollView:self];
    
    for (UIView *rollView in self.rollViews) {
        [rollView removeFromSuperview];
    }
    [self.rollViews removeAllObjects];
    if (self.numberOfPages > 0) {
        for (NSInteger i = 0; i < self.numberOfPages + 2; i ++) { [self.rollViews addObject:[self createRollView]]; }
        [self reSetFrame];
        self.currentPage = 0;
        [self refreshViews];
        self.cycleCounter = 0;
        self.counting = YES;
        self.scrollView.hidden = NO;
        self.userInteractionEnabled = YES;
    }
    else {
        self.scrollView.hidden = YES;
        self.userInteractionEnabled = NO;
    }
}

//- (void)refreshImages {
//    for (NSInteger i = 0; i < 3; i ++) {
//        NSInteger imgViewIndex = (self.numberOfPages + self.currentPage + 2 + i) % (self.numberOfPages + 2);
//        NSInteger itemIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
//        [self.delegate rollView:self setImageForImageView:self.imgViews[imgViewIndex] atIndex:itemIndex];
//    }
//}

- (void)refreshViews {
    for (NSInteger i = 0; i < 3; i ++) {
        NSInteger rollViewIndex = (self.numberOfPages + self.currentPage + 2 + i) % (self.numberOfPages + 2);
        NSInteger itemIndex = (self.numberOfPages + self.currentPage - 1 + i) % self.numberOfPages;
        [self.delegate rollView:self setViewForRollView:self.rollViews[rollViewIndex] atIndex:itemIndex];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.counting = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.cycleCounter = 0;
    self.counting = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.numberOfPages > 0) {
        CGFloat xOffSet = scrollView.contentOffset.x;
        if (xOffSet < self.wScrollView * 0.5f) {
            scrollView.contentOffset = CGPointMake(xOffSet + self.wScrollView * self.numberOfPages, 0);
        }
        if (xOffSet >= self.wScrollView * (self.numberOfPages + .5)) {
            scrollView.contentOffset = CGPointMake(xOffSet - self.wScrollView * self.numberOfPages, 0);
        }
        xOffSet = scrollView.contentOffset.x;
        NSInteger currentPageNow = (xOffSet - self.wScrollView * .5) / self.wScrollView;
        if (self.currentPage != currentPageNow) {
            self.currentPage = currentPageNow;
            [self refreshViews];
        }
    }
}

- (void)timerTicking {
    if (self.window &&
        self.counting &&
        self.autoRolling &&
        self.numberOfPages > 0 &&
        !self.scrollView.isDragging &&
        self.numberOfPages + 2 == self.rollViews.count &&
        !(self.numberOfPages == 1 && self.hideIndicatorForSinglePage)) {
        
        if (self.cycleCounter * ZXTimerCycle >= self.autoRollingTimeInterval ) {
            self.cycleCounter = 0;
            [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:ZXTimerCycle + .25f]];
            CGPoint offset = CGPointMake(self.wScrollView * (self.currentPage + 2), 0);
            [self.scrollView setContentOffset:offset animated:YES];
        }
        else {
            self.cycleCounter ++;
        }
    }
    else {
        self.cycleCounter = 0;
    }
}

- (void)appEnterBackground {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)appEnterForeground {
    self.cycleCounter = 0;
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:ZXTimerCycle + .25f]];
}

- (void)tapAction {
    if ([self.delegate respondsToSelector:@selector(rollView:didTapItemAtIndex:)]) {
        [self.delegate rollView:self didTapItemAtIndex:self.currentPage];
    }
}

- (void)invalidate {
    [self.timer invalidate];
    self.scrollView.delegate = nil;
    self.delegate = nil;
}

#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self createComponent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ([super initWithCoder:coder]) {
        [self createComponent];
    }
    return self;
}

- (void)createComponent {
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
    //self.imgViews = [[NSMutableArray alloc] init];
    self.rollViews = [[NSMutableArray alloc] init];
    self.autoRollingTimeInterval = ZXAutoRollTimeIntervalDefault;
    self.autoRolling = YES;
    self.rollViewIndicatorStyle = ZXRollViewIndicatorStyleColor;
    self.cycleCounter = 0;
    _indicatorToBottomSpacing = ZXIndicatorToBottomSpacingDefault;
    _imageContentMode = UIViewContentModeScaleAspectFill;
    _interitemSpacing = ZXInteritemSpacingDefault;
    self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0f];
    
    //
    self.scrollView = [[UIScrollView alloc] init];
    [self addSubview:self.scrollView];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.hidden = YES;
    
    //
    self.pageControlColor = [[UIPageControl alloc] init];
    [self addSubview:self.pageControlColor];
    self.pageControlColor.userInteractionEnabled = NO;
    
    //
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    //
    self.timer = [NSTimer timerWithTimeInterval:ZXTimerCycle
                                         target:self
                                       selector:@selector(timerTicking)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reSetFrame];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#ifdef ZX_ROLLVIEW_DEBUG
    NSLog(@"dealloc -> %@",NSStringFromClass([self class]));
#endif
}

@end
