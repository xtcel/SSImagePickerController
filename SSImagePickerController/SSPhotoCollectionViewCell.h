//
//  SSPhotoCollectionViewCell.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonDefine.h"
#import "SSPhoto.h"

@interface SSPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIButton *selectButton;

@property (strong, nonatomic) SSPhoto *photoModel;

@property (assign, nonatomic) NSInteger selectedIndex;  ///< 选中图片索引

- (void)updateUI;

@end
