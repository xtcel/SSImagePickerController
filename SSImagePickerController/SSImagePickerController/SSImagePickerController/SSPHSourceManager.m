//
//  SSPHSourceManager.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPHSourceManager.h"
#import "SSAlbum.h"

@interface SSPHSourceManager ()<PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) PHImageManager *imageManager;
@property (strong, nonatomic) PHFetchResult *currentFetchResult;

@end

@implementation SSPHSourceManager

+ (instancetype)sharedManager {
    static SSPHSourceManager *photoKitHelper = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        photoKitHelper = [[self alloc] init];
    });
    
    return photoKitHelper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    
    return self;
}

- (PHCachingImageManager *)phCachingImageManager {
    static PHCachingImageManager *phCachingImageManger = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        phCachingImageManger = [[PHCachingImageManager alloc] init];
    });
    
    return phCachingImageManger;
}

- (BOOL)haveAccessToPhotos
{
    return ( [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusRestricted &&
            [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied );
}

- (void)registerLibraryDidChangeOberver {
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)unregisterLibraryDidChangeObserver {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:ws.currentFetchResult];
        if (collectionChanges) {
            id obj = [collectionChanges fetchResultAfterChanges];
            NSArray *changesObjs = [collectionChanges changedObjects];
            
            if ([collectionChanges hasIncrementalChanges] && (changesObjs.count <= 0)) {
                //TODO:DID CHANGE Library
                if (_delegate && [_delegate respondsToSelector:@selector(libraryDidChange:)]) {
                    [_delegate libraryDidChange:obj];
                }
            }
        }
    });
}

- (void)fetchAlbumsWithCompletion:(void (^)(BOOL, NSArray *))completion {
    NSMutableArray *tmpAry   = [[NSMutableArray alloc] init];
    PHFetchOptions *option   = [[PHFetchOptions alloc] init];
    option.predicate         = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    option.sortDescriptors   = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
                                                               ascending:NO]];
    PHFetchResult  *cameraRo = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                        subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                        options:nil];
    PHAssetCollection *colt  = [cameraRo lastObject];
    PHFetchResult *fetchR    = [PHAsset fetchAssetsInAssetCollection:colt
                                                             options:option];
    SSAlbum *album   = [[SSAlbum alloc] init];
    //    album.type        = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    album.name        = colt.localizedTitle;
    album.count = fetchR.count;
    album.collection  = fetchR;
    
    if(album.count)
        [tmpAry addObject:album];
    
    PHAssetCollectionSubtype tp = PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum;
    PHFetchResult *albums       = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:tp
                                                                           options:nil];
    for (PHAssetCollection *col in albums) {
        @autoreleasepool
        {
            PHFetchResult *fRes = [PHAsset fetchAssetsInAssetCollection:col
                                                                options:option];
            
            SSAlbum *obj = [SSAlbum new];
            //            obj.type = col.assetCollectionSubtype;
            obj.name = col.localizedTitle;
            obj.collection = fRes;
            obj.count = fRes.count;
            
            if (fRes.count > 0) [tmpAry addObject:obj]; // drop empty album
        }
    }
    
    completion(YES, tmpAry);
    
    //    PHFetchResult *topLevelUser = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    //    PHFetchResult *allPhotos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //    PHFetchResult *favorites = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
    //    PHFetchResult *bursts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil];
    //    PHFetchResult *screenshots= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
    //    PHFetchResult *recentlyAdded= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    //    PHFetchResult *selfPortraits= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
    //
    //    NSArray *allAlbums = @[allPhotos, favorites, selfPortraits, bursts, screenshots, recentlyAdded, topLevelUser];
    //
    //    [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //
    //
    //    completion(allAlbums);
}

- (void)fetchPhotosWithGroup:(SSAlbum *)group completion:(void (^)(BOOL, NSArray *))completion {
    if (![group.collection isKindOfClass:[PHFetchResult class]]) {
        completion(NO, nil); return;
    }
    
    self.currentFetchResult = group.collection;
    
    completion(YES, (NSMutableArray *)group.collection);
}

- (void)getImageForPHAsset:(PHAsset *)asset
                  withSize:(CGSize)size
                completion:(void (^)(BOOL ret, UIImage *image))completion
{
    if (![asset isKindOfClass:[PHAsset class]])
    {
        completion(NO, nil); return;
    }
    
    NSInteger r = [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    [options setSynchronous:YES]; // called exactly once
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(size.width*r, size.height*r)
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info)
     {
         completion(YES, result);
     }];
}

- (void)getPosterImageForAlbumObj:(SSAlbum *)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
    PHAsset *asset = [album.collection firstObject];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat dimension = 60.f;
    CGSize  size  = CGSizeMake(dimension * scale, dimension * scale);
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:size
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info)
     {
         completion((result != nil), result);
     }];
}

//- (void)fetchAllPhotosCompletion:(void (^)(PHFetchResult *result))completion {
//    // Fetch all assets, sorted by date created.
//    PHFetchOptions *options = [[PHFetchOptions alloc] init];
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    PHFetchResult *results = [PHAsset fetchAssetsWithOptions:options];
//
//    completion(results);
//}
//
//- (void)fetchAllAssetsGroupCompletion:(void (^)(NSArray *groupsArray))completion {
//    PHFetchResult *topLevelUser = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
//    PHFetchResult *allPhotos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
//    PHFetchResult *favorites = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
//    PHFetchResult *bursts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil];
//    PHFetchResult *screenshots= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
//    PHFetchResult *recentlyAdded= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
//    PHFetchResult *selfPortraits= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
//
//    NSArray *allAlbums = @[allPhotos, favorites, selfPortraits, bursts, screenshots, recentlyAdded, topLevelUser];
//
//     [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
//
//
//    completion(allAlbums);
//}
//
//- (void)fetchAssetsFromAssetsGroup:(PHCollection *)collection Completion:(void (^)(PHFetchResult *result))completion {
//
//    if ([collection isKindOfClass:[PHAssetCollection class]]) {
//        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
//        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
//        completion(assetsFetchResult);
//    }
//}

@end
