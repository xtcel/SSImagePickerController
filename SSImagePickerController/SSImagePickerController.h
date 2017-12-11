//
//  SSImagePickerController.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonDefine.h"

@protocol SSImagePickerControllerDelegate;

@interface SSImagePickerController : UINavigationController

@property(nullable,nonatomic,weak) id <UINavigationControllerDelegate, SSImagePickerControllerDelegate> delegate;

@end

@protocol SSImagePickerControllerDelegate<NSObject>
@optional

- (void)imagePickerController:(SSImagePickerController *)picker didFinishPickingImages:(NSArray *)images sourceAssets:(NSArray *)assets;

- (void)imagePickerControllerDidCancel:(SSImagePickerController *)picker;

@end
