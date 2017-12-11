//
//  SSPhotoCollectionViewCell.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPhotoCollectionViewCell.h"

@interface SSPhotoCollectionViewCell()

@property (nonatomic, strong) UIButton *statusButton;

@end

@implementation SSPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.photoImageView];
        [self.contentView addSubview:self.selectButton];
        [self.selectButton addSubview:self.statusButton];
        
//        [self.selectButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  context:nil];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.photoImageView.frame = self.bounds;
    CGFloat cellWidth = self.bounds.size.width;
    
    _selectButton.frame = CGRectMake(cellWidth/2, 0, cellWidth/2, cellWidth/2);
    _statusButton.frame = CGRectMake(cellWidth/2-30, 4, 24, 24);
}

//- (void)dealloc {
//    [self.selectButton removeObserver:self forKeyPath:@"selected"];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    BOOL isSelected = [[change objectForKey:@"new"] boolValue];
//    if (isSelected) {
//        _statusButton.backgroundColor = SSHEXCOLOR(0x7ED321);
//        [_statusButton setTitle:[NSString stringWithFormat:@"%ld", _selectedIndex] forState:UIControlStateNormal];
//    } else {
//        [_statusButton setTitle:@"" forState:UIControlStateNormal];
//        _statusButton.backgroundColor = SSHEXCOLORA(0x4A4A4A, 0.7);
//    }
//}

#pragma mark - public

- (void)updateUI {
    if (self.photoModel.selectedIndex > 0) {
        // 根据是否选中切换状态，避免复用时选中状态对不上
        _selectButton.selected = YES;
        [_statusButton setTitle:[NSString stringWithFormat:@"%ld", self.photoModel.selectedIndex] forState:UIControlStateNormal];
        _statusButton.backgroundColor = SSHEXCOLOR(0x7ED321);
    } else {
        _selectButton.selected = NO;
        [_statusButton setTitle:@"" forState:UIControlStateNormal];
        _statusButton.backgroundColor = SSHEXCOLORA(0x4A4A4A, 0.7);
    }
}

#pragma mark - Getter/Setter

- (void)setPhotoModel:(SSPhoto *)photoModel {
    _photoModel = photoModel;
    
    [self updateUI];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [_statusButton setTitle:[NSString stringWithFormat:@"%ld", _selectedIndex] forState:UIControlStateNormal];
}

- (UIImageView *)photoImageView {
    if (nil == _photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.backgroundColor = [UIColor grayColor];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
    }
    
    return _photoImageView;
}

- (UIButton *)selectButton {
    if (nil == _selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    }
    
    return _selectButton;
}

- (UIButton *)statusButton {
    if (nil == _statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _statusButton.backgroundColor = SSHEXCOLORA(0x4A4A4A, 0.7);
        _statusButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _statusButton.layer.borderWidth = 1.0f;
        _statusButton.layer.cornerRadius = 12.0f;
        _statusButton.layer.masksToBounds = YES;
        [_statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _statusButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        
        _statusButton.userInteractionEnabled = NO;
    }
    
    return _statusButton;
}

@end
