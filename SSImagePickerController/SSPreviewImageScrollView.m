//
//  SSPreviewImageScrollView.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPreviewImageScrollView.h"
#import "SSCommonDefine.h"
#import "Masonry.h"

@interface SSPreviewImageScrollView()<UIScrollViewDelegate>

@property (nonatomic , strong) UIImageView  *photoImageView;

@end

@implementation SSPreviewImageScrollView

#pragma mark - initial UI

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.backgroundColor= [UIColor clearColor];
    self.photoImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.photoImageView];
    
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:singleTap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.userInteractionEnabled = YES;
}

#pragma mark - private method - 手势处理,缩放图片

- (void)singleTap:(UITapGestureRecognizer *)singleTap
{
//    if (self.zoomingScrollViewdelegate && [self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)]) {
//        [self.zoomingScrollViewdelegate zoomingScrollView:self singleTapDetected:singleTap];
//    }
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (self.zoomScale > 1.0) {
        self.contentInset = UIEdgeInsetsZero;
        [self setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [doubleTap locationInView:self.photoImageView];
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - Setter

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.photoImageView.image = image;
    [self resetZoomScale];
    [self setNeedsLayout];
}

/**
 *  根据图片和屏幕比例关系,调整最大和最小伸缩比例
 */
- (void)resetZoomScale
{
    self.zoomScale = 1.0;
    
    // self.photoImageView的初始位置
    UIImage *image = self.photoImageView.image;
    if (image == nil || image.size.height==0) {
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = SS_SCREEN_WIDTH;
    CGFloat height = SS_SCREEN_WIDTH / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y = 0;
    if (image.size.height > SS_SCREEN_HEIGHT) {
        y = 0;
        self.scrollEnabled = YES;
    } else {
        y = (SS_SCREEN_HEIGHT - image.size.height ) * 0.5;
        self.scrollEnabled = NO;
    }
    
    [self.photoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
    }];
    
    //    self.photoImageView.frame = CGRectMake(x, y, width, height);
    self.maximumZoomScale = MAX(SS_SCREEN_HEIGHT / image.size.height, 2.5);
    self.minimumZoomScale = 1.0;
    [self setZoomScale:1.0 animated:NO];
    self.contentSize = CGSizeMake(SS_SCREEN_WIDTH, MAX(height, SS_SCREEN_HEIGHT));
}

#pragma mark - Getter

- (UIImageView *)photoImageView
{
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
    }
    
    return _photoImageView;
}

@end
