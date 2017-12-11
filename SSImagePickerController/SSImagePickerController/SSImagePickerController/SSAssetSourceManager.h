//
//  SSAssetSourceManager.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@protocol SSAssetSourceManagerDelelgate;

typedef void(^ResultBlock)(NSArray *resultArray);
typedef void(^FailureBlock)(NSError *error);

@interface SSAssetSourceManager : NSObject

@property (nonatomic, assign) id<SSAssetSourceManagerDelelgate> delegate;
@property (nonatomic, assign) BOOL stopEnumeratePhoto;

/**
 * 获取单例
 */
+ (instancetype)sharedManager;

- (void)registerLibraryDidChangeOberver;

- (void)unregisterLibraryDidChangeOberver;

- (void)fetchAlbumsWithCompletion:(void (^)(BOOL ret, NSArray *albums))completion;

/**
 * 从相册中获取所有的图片
 * group 相册
 */
- (void)fetchPhotosWithGroup:(ALAssetsGroup *)group
                  completion:(void (^)(BOOL ret, NSArray *photos))completion;
/**
 获取poster图片
 */
- (void)getPosterImageForAlbumObj:(id)album
                       completion:(void (^)(BOOL ret, id obj))completion;
///**
// * 获取所有图片
// */
//- (void)fetchAllPhotosCompletion:(void (^)(NSArray *result))completion;
//
///**
// * 获取所有相册
// */
//- (void)fetchAllAssetsGroupCompletion:(void (^)(NSArray *result))completion;
//
///**
// * 获取Asset从一个AssetGroup中
// * @praram group:AssetGroup
// */
//- (void)getAssetsFormGroup:(ALAssetsGroup *)group completion:(void (^)(NSArray *result))completion;

@end

@protocol SSAssetSourceManagerDelelgate <NSObject>

- (void)assetsLibraryDidChange:(id)obj;

@end
