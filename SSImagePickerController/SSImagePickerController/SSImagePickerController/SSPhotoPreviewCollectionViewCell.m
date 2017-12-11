//
//  SSPhotoPreviewCollectionViewCell.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPhotoPreviewCollectionViewCell.h"
#import "Masonry.h"

@implementation SSPhotoPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.browserImageView];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
//        [self.browserImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(@10);
//            make.top.equalTo(@0);
//            make.bottom.equalTo(@0);
//            make.trailing.equalTo(@-10);
//        }];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _browserImageView.frame = CGRectMake(10, 0, size.width-20, size.height);
 }

#pragma mark - Getter/Setter

- (SSPreviewImageScrollView *)browserImageView {
    if (nil == _browserImageView) {
        _browserImageView = [[SSPreviewImageScrollView alloc] initWithFrame:CGRectZero];
    }
    
    return _browserImageView;
}

@end
