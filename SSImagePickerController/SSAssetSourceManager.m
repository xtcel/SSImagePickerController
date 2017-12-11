//
//  SSAssetSourceManager.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSAssetSourceManager.h"
#import "SSAlbum.h"

@interface SSAssetSourceManager ()

@property (nonatomic, strong) NSMutableArray  *assetGroups;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation SSAssetSourceManager

+ (instancetype)sharedManager {
    static SSAssetSourceManager *_sharedPhotoManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedPhotoManager = [[self alloc] init];
    });
    
    return _sharedPhotoManager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        if (nil == _assetsLibrary) {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        
        self.stopEnumeratePhoto = NO;
    }
    
    return self;
}

- (BOOL)haveAccessToPhotos
{
    return ( [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusRestricted &&
            [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied );
}

- (void)registerLibraryDidChangeOberver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:self.assetsLibrary];
}

- (void)unregisterLibraryDidChangeOberver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:self.assetsLibrary];
}

- (void)assetsLibraryDidChange:(NSNotification *)notification {
    if ([notification userInfo]) {
        NSSet *insertedGroupURLs = [[notification userInfo] objectForKey:ALAssetLibraryUpdatedAssetsKey];
        NSURL *assetURL = [insertedGroupURLs anyObject];
        if (assetURL) {
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (_delegate && [_delegate respondsToSelector:@selector(assetsLibraryDidChange:)]) {
                    [_delegate assetsLibraryDidChange:asset];
                }
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }
}

//获取相册
- (void)fetchAlbumsWithCompletion:(void (^)(BOOL, NSArray *))completion
{
    @autoreleasepool
    {
        NSMutableArray *tmpAry = [[NSMutableArray alloc] init];
        // Group enumerator Block
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (group == nil) {
                self.assetGroups = tmpAry;
                completion(YES, self.assetGroups); return;
            }
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            if ([group numberOfAssets]) {
                SSAlbum *album   = [[SSAlbum alloc] init];
                album.collection  = group;
                album.name        = [group valueForProperty:ALAssetsGroupPropertyName];
                album.posterImage = [UIImage imageWithCGImage:group.posterImage];
                album.count       = group.numberOfAssets;
                //Insert Obj
                [tmpAry insertObject:album atIndex:0];
            }
        };
        
        // Group Enumerator Failure Block
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
            if (error.code == ALAssetsLibraryAccessUserDeniedError ||
                error.code == ALAssetsLibraryAccessGloballyDeniedError) {
                completion(NO, nil);
            }
        };
        
        // Enumerate Albums
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                          usingBlock:assetGroupEnumerator
                                        failureBlock:assetGroupEnumberatorFailure];
    }
}

- (void)fetchPhotosWithGroup:(SSAlbum *)album completion:(void (^)(BOOL, NSArray *))completion {
    if (![album.collection isKindOfClass:[ALAssetsGroup class]]) {
        completion(NO, nil); return;
    }
    
    ALAssetsGroup *group = (ALAssetsGroup *)album.collection;
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    @autoreleasepool
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[group numberOfAssets]];
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
         {
             if (self.stopEnumeratePhoto) {
                 *stop = YES; return;
             }
             // enum end, and reload data
             if (nil == result) {
                 completion(YES, tmpArray); return;
             }
             
             [tmpArray addObject:result];
         }];
    }
}

- (void)getPosterImageForAlbumObj:(SSAlbum *)album
                       completion:(void (^)(BOOL ret, id obj))completion
{
    ALAssetsGroup *group = (ALAssetsGroup *)album.collection;
    UIImage *image       = [UIImage imageWithCGImage:group.posterImage];
    
    completion((image != nil), image);
}

//- (void)fetchAllPhotosCompletion:(void (^)(NSArray *))completion {
//    NSMutableArray *assetArray = [[NSMutableArray alloc] initWithCapacity:1];
//
//    [self fetchAllAssetsGroupCompletion:^(NSArray *result) {
//        for (ALAssetsGroup *group in result) {
//            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
//            if([groupName isEqualToString:@"All Photos"] ||
//               [groupName isEqualToString:@"Camera Roll"]) {
//
//                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                    if (result) {
//                        [assetArray addObject:result];
//                    } else {
//                        //结束
//                        completion(assetArray);
//                    }
//                }];
//            }
//        }
//    }];
//}
//
//- (void)fetchAllAssetsGroupCompletion:(void (^)(NSArray *))completion {
//    if (nil == _assetsGroupArray) {
//        _assetsGroupArray = [[NSMutableArray alloc] initWithCapacity:1];
//    } else {
//        completion(_assetsGroupArray);
//        return;
//    }
//
//    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//
//            if (group.numberOfAssets > 0) {
//                [_assetsGroupArray insertObject:group atIndex:0];
//            }
//            //NSLog(@"group name : %@",[group valueForProperty:ALAssetsGroupPropertyName]);
//        } else {
//            if (_assetsGroupArray.count > 0) {
//                completion(_assetsGroupArray);
//            } else {
//                //没有任何相册
//            }
//        }
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Group not found!\n");
//    }];
//}

//- (void)getAssetsGroup:(ResultBlock)finishBlock failureBlock:(FailureBlock)failureBlock {
////    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
//    NSMutableArray *assetsGroupArray = [[NSMutableArray alloc] initWithCapacity:1];
//
//    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        if (group) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//
//            if (group.numberOfAssets > 0) {
//                [assetsGroupArray insertObject:group atIndex:0];
//            }
//            //NSLog(@"group name : %@",[group valueForProperty:ALAssetsGroupPropertyName]);
//        } else {
//            if (assetsGroupArray.count > 0) {
//                finishBlock(assetsGroupArray);
//            } else {
//                //没有任何相册
//            }
//        }
//    } failureBlock:^(NSError *error) {
//        NSLog(@"Group not found!\n");
//        failureBlock(error);
//    }];
//}
//
//- (void)getAssetsFormGroup:(ALAssetsGroup *)group completion:(void (^)(NSArray *result))completion {
//    NSMutableArray *assetsArray = [[NSMutableArray alloc] initWithCapacity:1];
////    [group setAssetsFilter:al];
//    //开启线程异步获取数据
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//            if (result) {
//                [assetsArray addObject:result];
//            } else {
//                //结束
//                completion(assetsArray);
//            }
//        }];
//    });
//}

@end
