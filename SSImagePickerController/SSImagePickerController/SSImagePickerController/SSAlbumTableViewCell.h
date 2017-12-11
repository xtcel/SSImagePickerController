//
//  SSAlbumTableViewCell.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonDefine.h"

@interface SSAlbumTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *albumPreviewImageView;
@property (strong, nonatomic) UILabel *albumNameLabel;
@property (strong, nonatomic) UILabel *numberLabel;

@end
