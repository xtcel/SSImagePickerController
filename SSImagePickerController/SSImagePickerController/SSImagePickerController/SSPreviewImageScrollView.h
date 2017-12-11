//
//  SSPreviewImageScrollView.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPreviewImageScrollView : UIScrollView

@property (nonatomic , strong) UIImage  *image;
@property (nonatomic, copy) void (^singleTapGestureBlock)();

@end
