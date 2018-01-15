//
//  SSPhotoViewController.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPhotoViewController.h"
#import "SSImagePickerController.h"
#import "SSPhotoCollectionViewCell.h"
#import "SSImageManager.h"
#import "SSAlbum.h"
#import "SSAlbumTableViewCell.h"
#import "SSPhotoPreviewViewController.h"
#import "Masonry.h"
#import "SSPhoto.h"

@interface SSPhotoViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,
UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *navBarView;
@property (nonatomic, strong) UIView *navContentView;

@property (nonatomic, strong) UIControl *currentAlbumView;
@property (nonatomic, strong) UILabel *currentAlbumNameLabel;
@property (nonatomic, strong) UIImageView *downImageView;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UICollectionView *photoCollectionView;    ///< 图片展示CollectionView
@property (nonatomic, strong) UICollectionViewFlowLayout *photoCollectionViewLayout;

@property (strong, nonatomic) NSArray *photoArray;
@property (nonatomic, strong) NSArray *photoModelArray;

@property (strong, nonatomic) UITableView *albumTableView;      ///< 相册TableView
@property (strong, nonatomic) NSArray *albumArray;
@property (strong, nonatomic) SSAlbum *currentAlbum;

@property (strong, nonatomic) NSMutableArray *selectedPhotoArray;

@end

@implementation SSPhotoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxCount = 9;
        self.minCount = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setExtendedLayout];

    [self loadAlbums];
    
    [self setupNavigationBar];

    [self.view addSubview:self.photoCollectionView];
    [self.view addSubview:self.albumTableView];
     
    [self.photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navBarView.mas_bottom);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    [self.albumTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_bottom);
        make.leading.equalTo(@0);
        make.trailing.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

- (void)setExtendedLayout {
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    //忽略导航高度，从最顶部开始算
    self.navigationController.navigationBar.translucent = YES;
    
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
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
    
    [self.navContentView addSubview:self.currentAlbumView];
    [self.currentAlbumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
        make.centerX.equalTo(self.navContentView);
    }];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClickedEvent:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [self.navContentView addSubview:cancelButton];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@10);
        make.centerY.equalTo(self.navContentView);
        make.height.equalTo(@22);
        make.width.equalTo(@50);
    }];
    
    [self.navContentView addSubview:self.finishButton];
    
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-10);
        make.centerY.equalTo(self.navContentView);
        make.height.equalTo(@22);
        make.width.equalTo(@60);
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

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.currentAlbumView.selected) {
        [self.albumTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@64);
        }];
    } else {
        [self.albumTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(SS_SCREEN_HEIGHT));
        }];
    }
    
    CGFloat width = (self.view.frame.size.width - 15)/4.0f;
    CGFloat height = width;
    
    _photoCollectionViewLayout.itemSize = CGSizeMake(width, height);
     [_photoCollectionView setCollectionViewLayout:_photoCollectionViewLayout];
    [_photoCollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 更新数据
    [self.photoCollectionView reloadData];
    [self updateUIForSelectedAssetArrayChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.albumTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES
                               scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取当前相册的图片列表,如果第一次则获取所有照片

//获取相册列表
- (void)loadAlbums {
    __weak typeof(self) ws = self;
    [[SSImageManager manager] fetchAlbumsWithCompletion:^(BOOL ret, NSArray *albums) {
        ws.albumArray = albums;
        ws.currentAlbum = [ws.albumArray firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentAlbumNameLabel.text = self.currentAlbum.name;
            [ws loadPhotos];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws reflashGroupTableViewData];
        });
    }];
}

//获取图片
- (void)loadPhotos {
    __weak typeof(self) ws = self;
    [[SSImageManager manager] fetchPhotosWithGroup:_currentAlbum
                                        completion:^(BOOL ret, NSArray *photos)
     {
         ws.photoArray = photos;
         NSMutableArray *models = [NSMutableArray arrayWithCapacity:photos.count];
         [photos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             SSPhoto *model = [ws modelWithPhoto:obj];
             [models addObject:model];
         }];
         
         ws.photoModelArray = models;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [ws reflashCollectionData];
         });
     }];
}

- (void)reflashCollectionData {
    //重载数据
    //    _collectionViewDataSource.items = (NSMutableArray *)_assetArray;
        [self.photoCollectionView reloadData];
}

- (void)reflashGroupTableViewData {
    //重载数据
    //    _groupTableViewDataSource.items = (NSMutableArray *)_groupArray;
        [self.albumTableView reloadData];
}

- (SSPhoto *)modelWithPhoto:(id)photo {
    SSPhoto *model = [[SSPhoto alloc] init];
    model.photo = photo;
    model.selectedIndex = 0;
    
    return model;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = NSStringFromClass([SSPhotoCollectionViewCell class]);
    SSPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSInteger item = indexPath.item;
    
    SSPhoto *photoModel = self.photoModelArray[item];
    CGSize size = CGSizeMake(cell.bounds.size.width, cell.bounds.size.height);
    //        NSInteger photoIndex = item - 1;
    [[SSImageManager manager] getThumbnailForAssetObj:photoModel.photo withSize:size completion:^(BOOL ret, UIImage *image) {
        cell.photoImageView.image = image;
    }];
    
    cell.photoModel = photoModel;
    
    [cell.selectButton addTarget:self action:@selector(selectImageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    
    //预览所有图片
    SSPhotoPreviewViewController *previewViewCtrl = [[SSPhotoPreviewViewController alloc] init];
    previewViewCtrl.photoArray = self.photoModelArray;
    previewViewCtrl.selectedPhotoArray = self.selectedPhotoArray;
    previewViewCtrl.currentSelectedIndex = item;
//    previewViewCtrl.uploadedPicsCount = self.uploadedPicsCount;
    [self.navigationController pushViewController:previewViewCtrl animated:YES];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SSAlbumTableViewCell class])];
    
    SSAlbum *album = [self.albumArray objectAtIndex:indexPath.row];
    
    cell.albumNameLabel.text = album.name;
    
    [[SSImageManager manager] getPosterImageForAlbumObj:album completion:^(BOOL ret, UIImage *posterImage) {
        cell.albumPreviewImageView.image = posterImage;
    }];
    
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", album.count];
//    [cell setSelected:(self.currentAlbum == album) animated:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取group,替换数据
    NSInteger row = indexPath.row;
    self.currentAlbum = [self.albumArray objectAtIndex:row];
    self.currentAlbumNameLabel.text = self.currentAlbum.name;

//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.selected = YES;
//    _groupTableViewDataSource.currentGroup = _currentGroup;
//    [_photoGroupTableView reloadData];
    
    [self loadPhotos];
    
    [self.currentAlbumView sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - EventResponse

- (void)cancelButtonClickedEvent:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)finishButtonClickedEvent:(id)sender {
    SSImagePickerController *imagePickerController = (SSImagePickerController *)self.navigationController;
    if ([SSImageManager manager].delegate && [[SSImageManager manager].delegate respondsToSelector:@selector(imagePickerController:didFinishPickingImages:sourceAssets:)]) {
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.photoModelArray.count];
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:self.photoModelArray.count];
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

- (void)currentAlbumButtonClickedEvent:(id)sender {
    // 显示相册列表
    UIButton *button = sender;
    if (button.isSelected) {
        //隐藏
        [UIView animateWithDuration:0.3f animations:^{
            self.albumTableView.frame = CGRectMake(0, SS_SCREEN_HEIGHT, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
            self.downImageView.transform = CGAffineTransformRotate(self.downImageView.transform, -M_PI);
        }];
    } else {
        //显示
        [UIView animateWithDuration:0.3f animations:^{
            self.albumTableView.frame = CGRectMake(0, 64, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
            self.downImageView.transform = CGAffineTransformRotate(self.downImageView.transform, -M_PI);
        }];
    }
    
    button.selected = !button.isSelected;
}

- (void)selectImageButtonClicked:(id)sender {
    UIButton *selelctButton = (UIButton *)sender;
    
    SSPhotoCollectionViewCell *cell = (SSPhotoCollectionViewCell *)[[selelctButton superview] superview];
    
    //如果cell当前状态为非勾选状态，那么将要勾选的加入到勾选数组中
    if (!selelctButton.isSelected) {
        //如果少于9张图片，则直接加入
        if (self.selectedPhotoArray.count < (self.maxCount)) {
            
            [self.selectedPhotoArray addObject:cell.photoModel];
            cell.photoModel.selectedIndex = self.selectedPhotoArray.count;
            
            [cell updateUI];
        } else {
            //已经有9张图片，不让继续添加，返回No，不让Cell切换状态
//            [self showTipWithTitle:@"最多只能选择9张图片"];
            return;
        }
    } else {
        NSInteger removeIndex = cell.photoModel.selectedIndex;
        //如果已经勾选，那么取消勾选状态，并且从数组中删除当前勾选的图片资源元数据
        [self.selectedPhotoArray removeObject:cell.photoModel];
        cell.photoModel.selectedIndex = 0;
        [cell updateUI];

        // 更新其他cell数字索引
        [self.selectedPhotoArray enumerateObjectsUsingBlock:^(SSPhoto *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            photoModel.selectedIndex = idx+1;
        }];
        
        [self.photoCollectionView reloadData];
    }
    
    [selelctButton setSelected:(!selelctButton.selected)];
    
    [self updateUIForSelectedAssetArrayChanged];
}

- (void)updateUIForSelectedAssetArrayChanged
{
    if (_selectedPhotoArray.count > 0) {
        NSString *title = [NSString stringWithFormat:@"完成(%ld)", _selectedPhotoArray.count];
        [_finishButton setTitle:title forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _finishButton.enabled = YES;
    } else {
        _finishButton.enabled = NO;
//        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
//        [_finishButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UICollectionView *)photoCollectionView {
    if (nil == _photoCollectionView) {
        _photoCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _photoCollectionViewLayout.minimumInteritemSpacing = 5;
        _photoCollectionViewLayout.minimumLineSpacing = 5;
        _photoCollectionViewLayout.sectionInset = UIEdgeInsetsMake(5, 0, 0, 0);
        
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_photoCollectionViewLayout];
        
        _photoCollectionView.dataSource = self;
        _photoCollectionView.delegate = self;
        
        NSString *cellIdentifier = NSStringFromClass([SSPhotoCollectionViewCell class]);
        [_photoCollectionView registerClass:[SSPhotoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
//        [_photoCollectionView registerClass:[YDTakePhotoCollectionViewCell class] forCellWithReuseIdentifier:kTakePhotoCollectionCell];
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.allowsMultipleSelection = YES;
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        
        // 手动布局
//        _photoCollectionView.frame = CGRectMake(0, 0, screenWidth, screenHeigh);
    }
    
    return _photoCollectionView;
}

- (UITableView *)albumTableView {
    if (nil == _albumTableView) {
        CGRect rect =  CGRectMake(0, SS_SCREEN_HEIGHT, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
        _albumTableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        
        _albumTableView.dataSource = self;
        _albumTableView.delegate = self;
        
        [_albumTableView registerClass:[SSAlbumTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SSAlbumTableViewCell class])];
        _albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _albumTableView.showsHorizontalScrollIndicator = NO;
        _albumTableView.allowsSelection = YES;
    }
    
    return _albumTableView;
}

- (NSMutableArray *)selectedPhotoArray {
    if (nil == _selectedPhotoArray) {
        _selectedPhotoArray = [NSMutableArray array];
    }
    
    return _selectedPhotoArray;
}

#pragma mark - navigationBarView

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

- (UIControl *)currentAlbumView {
    if (nil == _currentAlbumView) {
        _currentAlbumView = [UIButton buttonWithType:UIButtonTypeCustom];
        _currentAlbumView = [[UIControl alloc] initWithFrame:CGRectZero];
        
        _currentAlbumNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_currentAlbumView addSubview:_currentAlbumNameLabel];
        
        [_currentAlbumNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        
        _downImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        NSString *bundleString = [[NSBundle mainBundle] pathForResource:@"SSImagePickerController" ofType:@"bundle"];
        NSString *imageFilePathString = [[NSBundle bundleWithPath:bundleString] pathForResource:@"icon_down@2x" ofType:@"png" inDirectory:@"images"];
        _downImageView.image = [UIImage imageWithContentsOfFile:imageFilePathString];
        [_currentAlbumView addSubview:_downImageView];
        
        [_downImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_currentAlbumNameLabel.mas_trailing).offset(5);
            make.centerY.equalTo(_currentAlbumView);
            make.trailing.equalTo(@0);
            make.height.equalTo(@(23/2.0));
            make.width.equalTo(@20);
        }];
        

        [_currentAlbumView addTarget:self action:@selector(currentAlbumButtonClickedEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _currentAlbumView;
}

- (UIButton *)finishButton {
    if (nil == _finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"完成" forState:UIControlStateDisabled];
        _finishButton.enabled = NO;
//        _finishButton.state = UIControlStateDisabled;
        [_finishButton setTitleColor:[UIColor grayColor]
                            forState:UIControlStateDisabled];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_finishButton addTarget:self action:@selector(finishButtonClickedEvent:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _finishButton;
}

@end
