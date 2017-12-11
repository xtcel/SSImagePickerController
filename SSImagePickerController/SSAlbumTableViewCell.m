//
//  SSAlbumTableViewCell.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSAlbumTableViewCell.h"
#import "Masonry.h"
@implementation SSAlbumTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
        [self setupLayout];
    }
    
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.albumPreviewImageView];
    [self.contentView addSubview:self.albumNameLabel];
    [self.contentView addSubview:self.numberLabel];
}

- (void)setupLayout {
    [self.albumPreviewImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.width.height.equalTo(@60);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.albumNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.albumPreviewImageView.mas_trailing).offset(10);
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.numberLabel.mas_leading);
    }];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-10);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@50);
    }];
}

#pragma mark - Getter/Setter

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.contentView.backgroundColor = selected ? SSHEXCOLOR(0xF3F4F3) : [UIColor whiteColor];
}

- (UIImageView *)albumPreviewImageView {
    if (nil == _albumPreviewImageView) {
        CGRect rect = CGRectMake(10, 10, 60, 60);
        _albumPreviewImageView = [[UIImageView alloc] initWithFrame:rect];
        _albumPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _albumPreviewImageView.clipsToBounds = YES;
    }
    
    return _albumPreviewImageView;
}

- (UILabel *)albumNameLabel {
    if (nil == _albumNameLabel) {
        CGRect rect = CGRectMake(90, 10, SS_SCREEN_WIDTH - 90 - 60, 60);
        _albumNameLabel = [[UILabel alloc] initWithFrame:rect];
        _albumNameLabel.font = [UIFont systemFontOfSize:18.0f];
        _albumNameLabel.textColor = SSHEXCOLOR(0x303030);
    }
    
    return _albumNameLabel;
}

- (UILabel *)numberLabel {
    if (nil == _numberLabel) {
        CGRect rect = CGRectMake(SS_SCREEN_WIDTH-60, 10, 50, 60);
        _numberLabel = [[UILabel alloc] initWithFrame:rect];
        _numberLabel.textAlignment = NSTextAlignmentRight;
        _numberLabel.textColor = SSHEXCOLOR(0xC6C6C6);
        _numberLabel.font = [UIFont systemFontOfSize:12.0f];
    }

    return _numberLabel;
}

@end
