//
//  SSPhotoPreviewViewController.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPhotoPreviewViewController.h"
#import "SSImagePickerController.h"
#import "SSImageManager.h"
#import "SSPhotoPreviewCollectionViewCell.h"
#import "Masonry.h"
#import "SSPhoto.h"

@interface SSPhotoPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *navBarView;
@property (nonatomic, strong) UIView *navContentView;
@property (nonatomic, strong) UIButton *statusButton;

@property (strong, nonatomic) UICollectionView *previewImageCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *previewFlowLayout;
@property (strong, nonatomic) UIView  *bottomBarView;
@property (strong, nonatomic) UIButton *finishButton;

@property (nonatomic, strong) SSPhoto *currentPhotoModel;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation SSPhotoPreviewViewController

static NSInteger KMAXPicCount = 9;

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // 忽略导航高度，从最顶部开始算
    [self setExtendedLayout];
    
    [self setupView];
    [self setupLayout];
    [self setupNavigationBar];
}

- (void)setExtendedLayout {
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    //忽略导航高度，从最顶部开始算
    self.navigationController.navigationBar.translucent = YES;
    
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupView {
    [self.view addSubview:self.previewImageCollectionView];
    [self.view addSubview:self.bottomBarView];
    [self.bottomBarView addSubview:self.finishButton];
}

- (void)setupLayout {
    [_bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(49);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    [_finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-8);
        make.centerY.mas_equalTo(_bottomBarView);
        make.width.mas_equalTo(70);
    }];
}

#pragma mark - setupNavigationBar

- (void)setupNavigationBar {
    [self.view addSubview:self.navBarView];
    [self.navBarView addSubview:self.navContentView];
    
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.height.equalTo(@64);
    }];
    
    [self.navContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@20);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.height.equalTo(@44);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClickedEvent:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];

    [self.navContentView addSubview:backButton];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.centerY.equalTo(self.navContentView);
        make.height.equalTo(@22);
        make.width.equalTo(@50);
    }];
    
    [self.navContentView addSubview:self.statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-10);
        make.centerY.equalTo(self.navContentView);
        make.width.height.equalTo(@24);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = SSHEXCOLOR(0xe3e3e3);
    [self.navBarView addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@0);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.height.equalTo(@0.5);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGFloat width = self.view.frame.size.width+20;
    CGFloat height = SS_SCREEN_HEIGHT;
    
    _previewFlowLayout.itemSize = CGSizeMake(width, height);
    [_previewImageCollectionView setCollectionViewLayout:_previewFlowLayout];
    [_previewImageCollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_currentSelectedIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentSelectedIndex inSection:0];
        [_previewImageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }

    //如果是单张图片不需要显示选择按钮
    if (_singleImage) {
        _bottomBarView.hidden = YES;
    }
    
    self.currentPhotoModel = [self.photoArray objectAtIndex:self.currentIndex];
    [self updateStatusButtonUI];
    [self updateFinishButtonUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private Method

//- (void)updateTitleText {
//    NSInteger currentImageIndex = _currentIndex + 1;
//    NSInteger imageTotal = [_photoArray count];
//    NSString *title = [NSString stringWithFormat:@"%ld/%ld", currentImageIndex, imageTotal];
//    [self setTitleLabel:title withColor:nil];
//
//    NSString *rightTitleString = nil;
//    if (_selectedphotos.count > 0) {
//        rightTitleString = [NSString stringWithFormat:@"发布(%ld/%ld)", _selectedphotos.count, (KMAXPicCount - _uploadedPicsCount)];
//        [self setRightItemWithTitle:rightTitleString font:[UIFont boldSystemFontOfSize:15.0f] function:@selector(publishPhotos:)];
//        self.rightButtonItem.userInteractionEnabled = YES;
//    } else {
//        rightTitleString = [NSString stringWithFormat:@"发布"];
//        [self setRightItemWithTitle:rightTitleString font:[UIFont boldSystemFontOfSize:15.0f] function:@selector(publishPhotos:)];
//        [self.rightButtonItem setTitleColor:HEXCOLOR(0xafe6ff) forState:UIControlStateNormal];
//        self.rightButtonItem.userInteractionEnabled = NO;
//    }
//
//    if (_singleImage) {
//        [self.rightButtonItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        self.rightButtonItem.userInteractionEnabled = YES;
//    }
//}

//图片压缩
- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass([SSPhotoPreviewCollectionViewCell class]);
    SSPhotoPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                                       forIndexPath:indexPath];
    NSInteger item = indexPath.item;
    //    _currentIndex = item;
    
    if (_singleImage) {
        //单张图片
        cell.browserImageView.image = _singleImage;
    } else {
        //获取资源图片的x
        SSPhoto *photoModel = [_photoArray objectAtIndex:item];
        id asset = photoModel.photo;
        CGSize size = CGSizeMake(cell.bounds.size.width, cell.bounds.size.height);
        
        __weak SSPhotoPreviewCollectionViewCell *weakCell = cell;
        [[SSImageManager manager] getPreviewImageForAssetObj:asset withSize:size completion:^(BOOL ret, UIImage *image) {
            weakCell.browserImageView.image = image;
//            [weakCell.browserImageView  eliminateScale];
        }];
    }
    
    cell.browserImageView.singleTapGestureBlock = ^() {
        self.navBarView.hidden = !self.navBarView.isHidden;
        self.bottomBarView.hidden = !self.bottomBarView.isHidden;
    };
    
    return cell;
}

#pragma mark - EventResponse

- (void)statusButtonClickEvent:(id)sender {
    UIButton *selelctButton = (UIButton *)sender;
    
    //如果cell当前状态为非勾选状态，那么将要勾选的加入到勾选数组中
    if (!selelctButton.isSelected) {
        //如果少于9张图片，则直接加入
        if (self.selectedPhotoArray.count < (12)) {
            
            [self.selectedPhotoArray addObject:self.currentPhotoModel];
            self.currentPhotoModel.selectedIndex = self.selectedPhotoArray.count;
            
//            [cell updateUI];
        } else {
            //已经有9张图片，不让继续添加，返回No，不让Cell切换状态
            //            [self showTipWithTitle:@"每条最多只能上传9张图片哦"];
            return;
        }
    } else {
//        NSInteger removeIndex = cell.photoModel.selectedIndex;
        //如果已经勾选，那么取消勾选状态，并且从数组中删除当前勾选的图片资源元数据
        [self.selectedPhotoArray removeObject:self.currentPhotoModel];
        self.currentPhotoModel.selectedIndex = 0;
//        [cell updateUI];
        
        // 更新其他cell数字索引
        [self.selectedPhotoArray enumerateObjectsUsingBlock:^(SSPhoto *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            photoModel.selectedIndex = idx+1;
        }];
    }
    
    [selelctButton setSelected:(!selelctButton.selected)];
    
    [self updateStatusButtonUI];
    
    [self updateFinishButtonUI];
}

- (void)updateStatusButtonUI {
    if (self.currentPhotoModel.selectedIndex > 0) {
        // 根据是否选中切换状态，避免复用时选中状态对不上
        _statusButton.selected = YES;
        [self.statusButton setTitle:[NSString stringWithFormat:@"%ld", self.currentPhotoModel.selectedIndex] forState:UIControlStateNormal];
        _statusButton.backgroundColor = SSHEXCOLOR(0x7ED321);
    } else {
        _statusButton.selected = NO;
        [self.statusButton setTitle:@"" forState:UIControlStateNormal];
        _statusButton.backgroundColor = SSHEXCOLORA(0x4A4A4A, 0.7);
    }
}

- (void)updateFinishButtonUI
{
    if (_selectedPhotoArray.count > 0) {
        NSString *title = [NSString stringWithFormat:@"完成(%ld)", _selectedPhotoArray.count];
        [_finishButton setTitle:title forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat pageWidth = SS_SCREEN_WIDTH+20;
    int page = floor((offsetX - pageWidth / 2) / pageWidth) + 1;
    
    if (_currentIndex != page) {
        if (page < 0 || page >= self.photoArray.count) {
            return;
        }
        
        _currentIndex = page;
        NSLog(@"currentIndex： %ld", _currentIndex);
        
        self.currentPhotoModel = [_photoArray objectAtIndex:_currentIndex];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateStatusButtonUI];
        });
    }
}

#pragma mark - EventResponse

- (void)backButtonClickedEvent:(id)sender {
    // 返回按钮点击事件
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishButtonClickedEvent:(id)sender {
    SSImagePickerController *imagePickerController = (SSImagePickerController *)self.navigationController;
    if ([SSImageManager manager].delegate && [[SSImageManager manager].delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:sourceAssets:)]) {
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.photoArray.count];
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:self.photoArray.count];
        [self.selectedPhotoArray enumerateObjectsUsingBlock:^(SSPhoto *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [assets addObject:photoModel.photo];
            
            CGSize size = CGSizeMake(SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
            [[SSImageManager manager] getPreviewImageForAssetObj:photoModel.photo withSize:size completion:^(BOOL ret, UIImage *image) {
                [images addObject:image];
            }];
        }];
        
        
        [[SSImageManager manager].delegate imagePickerController:imagePickerController didFinishPickingImages:images sourceAssets:assets];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getter/Setter

- (void)setSingleImage:(UIImage *)singleImage {
    _singleImage = singleImage;
    
    _photoArray = @[singleImage];
}

- (UIView *)navBarView {
    if (nil == _navBarView) {
        _navBarView = [[UIView alloc] initWithFrame:CGRectZero];
        _navBarView.backgroundColor = [UIColor whiteColor];
    }
    
    return _navBarView;
}

- (UIView *)navContentView {
    if (nil == _navContentView) {
        _navContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _navContentView.backgroundColor = [UIColor whiteColor];
    }
    
    return _navContentView;
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
        
        [_statusButton addTarget:self action:@selector(statusButtonClickEvent:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _statusButton;
}

- (UICollectionView *)previewImageCollectionView {
    if (nil == _previewImageCollectionView) {
        _previewImageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, SS_SCREEN_WIDTH+20, SS_SCREEN_HEIGHT)
                                                         collectionViewLayout:self.previewFlowLayout];
    }
    
    _previewImageCollectionView.dataSource = self;
    _previewImageCollectionView.delegate = self;
    _previewImageCollectionView.pagingEnabled = YES;
    NSString *cellIdentifier = NSStringFromClass([SSPhotoPreviewCollectionViewCell class]);
    [_previewImageCollectionView registerClass:[SSPhotoPreviewCollectionViewCell class]
                    forCellWithReuseIdentifier:cellIdentifier];
    _previewImageCollectionView.allowsMultipleSelection = YES;
    _previewImageCollectionView.showsHorizontalScrollIndicator = NO;
    
//    _previewImageCollectionView.backgroundColor = SSHEXCOLOR(0x151515);
//    _previewImageCollectionView.backgroundColor = [UIColor redColor];

    return _previewImageCollectionView;
}

- (UICollectionViewFlowLayout *)previewFlowLayout {
    if (nil == _previewFlowLayout) {
        _previewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    
    _previewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat width = SS_SCREEN_WIDTH+20;
    CGFloat height = SS_SCREEN_HEIGHT;
    _previewFlowLayout.itemSize = CGSizeMake(width, height);
    _previewFlowLayout.minimumInteritemSpacing = 0;
    _previewFlowLayout.minimumLineSpacing = 0;
    
    return _previewFlowLayout;
}

- (UIView *)bottomBarView {
    if (nil == _bottomBarView) {
        _bottomBarView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomBarView.backgroundColor = [UIColor whiteColor];
    }
    
    return _bottomBarView;
}

- (UIButton *)finishButton {
    if (nil == _finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"完成" forState:UIControlStateDisabled];
        _finishButton.enabled = NO;
        [_finishButton setTitleColor:[UIColor grayColor]
                            forState:UIControlStateDisabled];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_finishButton addTarget:self action:@selector(finishButtonClickedEvent:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _finishButton;
}

@end
