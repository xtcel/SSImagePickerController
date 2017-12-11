//
//  SSPHSourceManager.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@protocol SSPHSourceManagerDelegate;

@interface SSPHSourceManager : NSObject

@property (nonatomic, weak) id<SSPHSourceManagerDelegate> delegate;

/**
 * 获取单例
 */
+ (instancetype)sharedManager;

- (PHCachingImageManager *)phCachingImageManager;

/**
 *注册资源变化观察者
 */
- (void)registerLibraryDidChangeOberver;

/**
 *注销资源变化观察者
 */
- (void)unregisterLibraryDidChangeObserver;

/**
 * 获取所有相册
 */
- (void)fetchAlbumsWithCompletion:(void (^)(BOOL ret, NSArray *albums))completion;

/**
 * 从相册中获取所有的图片
 * group 相册
 */
- (void)fetchPhotosWithGroup:(id)group
completion:(void (^)(BOOL ret, NSArray *photos))completion;

- (void)getAlbumsWithCompletion:(void (^)(BOOL ret, id obj))completion;

- (void)getImageForPHAsset:(PHAsset *)asset
withSize:(CGSize)size
completion:(void (^)(BOOL ret, UIImage *image))completion;

- (void)getPosterImageForAlbumObj:(id)album
completion:(void (^)(BOOL ret, id obj))completion;
///**
// * 获取所有图片
// */
//- (void)fetchAllPhotosCompletion:(void (^)(PHFetchResult *result))completion;
//
///**
// * 获取所有相册
// */
//- (void)fetchAllAssetsGroupCompletion:(void (^)(NSArray *groupsArray))completion;
//
///**
// * 从相册中获取图片
// */
//- (void)fetchAssetsFromAssetsGroup:(PHCollection *)collection Completion:(void (^)(PHFetchResult *result))completion;

@end

@protocol SSPHSourceManagerDelegate <NSObject>

- (void)libraryDidChange:(id)obj;

@end
