//
//  SSAlbum.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SSCommonDefine.h"

@interface SSAlbum : NSObject

@property (nonatomic, strong) id collection;

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *posterImage;
@property (assign, nonatomic) NSInteger count;

- (void)postImageWithSize:(CGSize)size completion:(void (^)(BOOL ret, UIImage *image))completion;

@end
