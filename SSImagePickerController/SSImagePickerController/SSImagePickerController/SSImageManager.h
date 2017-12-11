//
//  SSImageManager.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SSCommonDefine.h"

@protocol SSImagePickerControllerDelegate;
@interface SSImageManager : NSObject

@property (nonatomic, strong) id<SSImagePickerControllerDelegate> delegate;

+ (instancetype)manager;

- (BOOL)authorizationStatusAuthorized;

- (void)requestAuthorization:(void (^)(BOOL))completion;

/**
 * 获取所有相册
 */
- (void)fetchAlbumsWithCompletion:(void (^)(BOOL ret, NSArray *albums))completion;

/**
 * 从相册中获取所有的图片资源对象
 *@param group 相册
 */
- (void)fetchPhotosWithGroup:(id)group
                  completion:(void (^)(BOOL ret, NSArray *photos))completion;

/**
 *获取缩略图
 *@param asset 资源对象
 *@param size  缩略图的大小，只有在PhotoKit中有用
 */
- (void)getThumbnailForAssetObj:(id)asset
                       withSize:(CGSize)size  // size for iOS 8 only
                     completion:(void (^)(BOOL ret, UIImage *image))completion;
/**
 *获取相册的Poster图片
 *@param album 相册
 */
- (void)getPosterImageForAlbumObj:(id)album
                       completion:(void (^)(BOOL ret, UIImage *posterImage))completion;
/**
 *获取预览图
 *@param asset 资源对象
 *@param size  预览图的大小，只有在PhotoKit中有用
 */
- (void)getPreviewImageForAssetObj:(id)asset
                          withSize:(CGSize)size  // size for iOS 8 only
                        completion:(void (^)(BOOL ret, UIImage *image))completion;
/**
 *获取原图
 *@param asset 资源对象
 */
- (void)getOriginImageForAssetObj:(id)asset
                       completion:(void (^)(BOOL ret, UIImage *image))completion;

/**
 *注册资源改变观察者
 */
- (void)registerLibraryDidChangeOberver;

/**
 *注销资源改变观察者
 */
- (void)unregisterLibraryDidChangeOberver;

@end
