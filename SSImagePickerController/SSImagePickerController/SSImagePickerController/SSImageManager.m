//
//  SSImageManager.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSImageManager.h"
#import "SSPHSourceManager.h"
#import "SSAssetSourceManager.h"

@interface SSImageManager()

//@property (strong, nonatomic) SSPHSourceManager *phManager;
//@property (strong, nonatomic) SSAssetSourceManager *asManager;

@end

static SSImageManager *sharedInstance = nil;

@implementation SSImageManager

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSImageManager alloc] init];
    });
    
    return sharedInstance;
}

- (BOOL)authorizationStatusAuthorized
{
    if (SS_IOS8_OR_LATER) {
        return ( [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusRestricted &&
                [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied );
    } else {
        return ( [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusRestricted &&
                [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied );
    }
}

- (void)requestAuthorization:(void (^)(BOOL))completion {
    if (SS_IOS8_OR_LATER) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            completion(status != PHAuthorizationStatusRestricted &&
                       status != PHAuthorizationStatusDenied );
        }];
    } else {
        NSString *mediaType = AVMediaTypeVideo;
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            completion(granted);
        }];
    }
}

- (void)registerLibraryDidChangeOberver {
//    if (IOS8_OR_LATER) {
//        [self.phManager registerLibraryDidChangeOberver];
//        self.phManager.delegate = self;
//    } else {
//        [self.asManager registerLibraryDidChangeOberver];
//        self.asManager.delegate = self;
//    }
}

- (void)unregisterLibraryDidChangeOberver {
//    if (IOS8_OR_LATER) {
//        [self.phManager unregisterLibraryDidChangeObserver];
//        self.phManager.delegate = nil;
//    } else {
//        [self.asManager unregisterLibraryDidChangeOberver];
//        self.asManager.delegate = nil;
//    }
}

- (void)assetsLibraryDidChange:(id)obj {
    [self changedLibrary:obj];
}

- (void)libraryDidChange:(id)obj {
    [self changedLibrary:obj];
}

- (void)changedLibrary:(id)obj {
//    if (_delegate && [_delegate respondsToSelector:@selector(imageLibraryDidChange:)]) {
//        [_delegate imageLibraryDidChange:obj];
//    }
}

//获取相册
- (void)fetchAlbumsWithCompletion:(void (^)(BOOL ret, NSArray *albums))completion
{
    if (SS_IOS8_OR_LATER) {
        [[SSPHSourceManager sharedManager] fetchAlbumsWithCompletion:^(BOOL ret, NSArray *albums)
         {
             completion(ret, albums);
         }];
    } else {
        [[SSAssetSourceManager sharedManager] fetchAlbumsWithCompletion:^(BOOL ret, NSArray *albums)
         {
             completion(ret, albums);
         }];
    }
}

//获取相册里面的图片
- (void)fetchPhotosWithGroup:(id)group completion:(void (^)(BOOL, NSArray *))completion {
    if (SS_IOS8_OR_LATER) {
        [[SSPHSourceManager sharedManager] fetchPhotosWithGroup:group completion:^(BOOL ret, NSArray *photos) {
            completion(ret, photos);
        }];
    } else {
        [[SSAssetSourceManager sharedManager] fetchPhotosWithGroup:group completion:^(BOOL ret, NSArray *photos) {
            completion(ret, photos);
        }];
    }
}

//获取缩略图
- (void)getThumbnailForAssetObj:(id)asset
                       withSize:(CGSize)size
                     completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (SS_IOS8_OR_LATER) { /*&& !CGSizeEqualToSize(size, CGSizeZero)*/
        [[SSPHSourceManager sharedManager] getImageForPHAsset:asset
                                  withSize:size
                                completion:^(BOOL ret, UIImage *image)
         {
             completion(ret, image);
         }];
    } else {
        if (![asset isKindOfClass:[ALAsset class]]) {
            completion(NO, nil); return;
        }
        
        ALAsset *ast = (ALAsset *)asset;
        completion(YES, [UIImage imageWithCGImage:ast.aspectRatioThumbnail]);
    }
}

//获取获取相册的Poster图片
- (void)getPosterImageForAlbumObj:(id)album completion:(void (^)(BOOL, UIImage *))completion {
    if (SS_IOS8_OR_LATER) {
        [[SSPHSourceManager sharedManager] getPosterImageForAlbumObj:album
                                       completion:^(BOOL ret, UIImage *posterImage)
         {
             completion(ret, posterImage);
         }];
    } else {
        [[SSAssetSourceManager sharedManager] getPosterImageForAlbumObj:album
                                       completion:^(BOOL ret, UIImage *posterImage)
         {
             completion(ret, posterImage);
         }];
    }
}

//获取缩略图
- (void)getPreviewImageForAssetObj:(id)asset withSize:(CGSize)size completion:(void (^)(BOOL, UIImage *))completion {
    if (SS_IOS8_OR_LATER) {
        [[SSPHSourceManager sharedManager] getImageForPHAsset:asset withSize:size completion:^(BOOL ret, UIImage *image) {
            completion(ret, image);
        }];
    } else {
        if (![asset isKindOfClass:[ALAsset class]]) {
            completion(NO, nil); return;
        }
        
        ALAsset *ast = (ALAsset *)asset;
        CGImageRef fullScreenImage = [[ast defaultRepresentation] fullScreenImage];
        completion(YES, [UIImage imageWithCGImage:fullScreenImage]);
    }
}

//获取原图
- (void)getOriginImageForAssetObj:(id)asset completion:(void (^)(BOOL, UIImage *))completion {
    
}

//- (void)fetchAllPhotosCompletion:(void (^)(NSArray *assets))completion {
//    if (IOS8_OR_LATER) {
//        __block NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
//        [_phManager fetchAllPhotosCompletion:^(PHFetchResult *result) {
//            for (PHAsset *asset in result) {
//                YDPhoto *assetObject = [[YDPhoto alloc] init];
//                assetObject.phAsset = asset;
//                [assets addObject:assetObject];
//            }
//        }];
//
//        completion(assets);
//    } else {
//        __block NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
//
//        [_asManager fetchAllPhotosCompletion:^(NSArray *result) {
//            for (ALAsset *asset in result) {
//                YDPhoto *assetObject = [[YDPhoto alloc] init];
//                assetObject.alAsset = asset;
//                [assets addObject:assetObject];
//            }
//
//            completion(assets);
//        }];
//    }
//}
//
//- (void)fetchAssetsGroupCompletion:(void (^)(NSArray *assetsGroupList))completion {
//    if (IOS8_OR_LATER) {
//        __block NSMutableArray *assetsGroupList = [[NSMutableArray alloc] initWithCapacity:1];
//        [_phManager fetchAllAssetsGroupCompletion:^(NSArray *groupsArray) {
//            for (PHFetchResult *result in groupsArray) {
//                for (PHAssetCollection *collection in result) {
//                    PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
//                    BOOL isSmartAlbum = (PHAssetCollectionTypeSmartAlbum == collection.assetCollectionType);
//                    //smartAlbum需要图片数量大于0
//                    if (!isSmartAlbum || (assetsFetchResult.count > 0)) {
//                        YDAlbum *assetsGroup = [[YDAlbum alloc] init];
//                        [assetsGroup setPhCollection:collection];
//                        [assetsGroupList addObject:assetsGroup];
//                    }
//                }
//            }
//        }];
//
//        completion(assetsGroupList);
//    } else {
//        __block NSMutableArray *assetsGroupList = [[NSMutableArray alloc] initWithCapacity:1];
//
//        [_asManager fetchAllAssetsGroupCompletion:^(NSArray *result) {
//            for (ALAssetsGroup *assetsGroup in result) {
//                YDAlbum *assetsGroupObject = [[YDAlbum alloc] init];
//                [assetsGroupObject setGroup:assetsGroup];
//                [assetsGroupList addObject:assetsGroupObject];
//            }
//
//            completion(assetsGroupList);
//        }];
//    }
//}
//
//- (void)fetchAssetsFromAssetsGroup:(YDAlbum *)group Completion:(void (^)(NSArray *assets))completion {
//    if (IOS8_OR_LATER) {
//        PHCollection *phCollection = group.phCollection;
//        __block NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
//
//        [_phManager fetchAssetsFromAssetsGroup:phCollection Completion:^(PHFetchResult *result) {
//            for (PHAsset *asset in result) {
//                YDPhoto *assetObject = [[YDPhoto alloc] init];
//                assetObject.phAsset = asset;
//                [assets addObject:assetObject];
//            }
//
//            completion(assets);
//        }];
//    } else {
//        ALAssetsGroup *assetsGroup = group.group;
//
//        __block NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
//        [_asManager getAssetsFormGroup:assetsGroup completion:^(NSArray *result) {
//            for (ALAsset *asset in result) {
//                YDPhoto *assetObject = [[YDPhoto alloc] init];
//                assetObject.alAsset = asset;
//                [assets addObject:assetObject];
//            }
//
//            completion(assets);
//        }];
//    }
//}

@end
