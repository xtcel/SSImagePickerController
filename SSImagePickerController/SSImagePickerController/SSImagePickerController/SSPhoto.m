//
//  SSPhoto.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSPhoto.h"
#import "SSPHSourceManager.h"

@interface SSPhoto ()

@property (strong, nonatomic) ALAsset *alAsset;
@property (strong, nonatomic) PHAsset *phAsset;

@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) UIImage *previewImage;
@property (strong, nonatomic) UIImage *originImage;

@end

@implementation SSPhoto

- (id)photo
{
    return SS_IOS8_OR_LATER ? self.phAsset : self.alAsset;
}

- (void)setPhoto:(id)photo
{
    if (SS_IOS8_OR_LATER) {
        self.phAsset = (PHAsset *)photo;
    } else {
        self.alAsset = (ALAsset *)photo;
    }
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
    if (_thumbnailImage) {
        return _thumbnailImage;
    }
    
    __block UIImage *resultImage;
    
    if (SS_IOS8_OR_LATER) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        phImageRequestOptions.synchronous = YES;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        CGFloat scale = [UIScreen mainScreen].scale;
        PHCachingImageManager *cachingManager = [[SSPHSourceManager sharedManager] phCachingImageManager];
        CGSize targetSize = CGSizeMake(size.width * scale, size.height * scale);
        [cachingManager requestImageForAsset:_phAsset
                                  targetSize:targetSize
                                 contentMode:PHImageContentModeAspectFill
                                     options:phImageRequestOptions
                               resultHandler:^(UIImage *result, NSDictionary *info) {
                                   
                                   resultImage = result;
                               }];
    } else {
        CGImageRef thumbnailImageRef = [_alAsset aspectRatioThumbnail];
        if (thumbnailImageRef) {
            resultImage = [UIImage imageWithCGImage:thumbnailImageRef];
        }
    }
    
    _thumbnailImage = resultImage;
    
    return resultImage;
}

//- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion {
//    if (_usePhotoKit) {
//        if (_thumbnailImage) {
//            if (completion) {
//                completion(_thumbnailImage, nil);
//            }
//            return 0;
//        } else {
//            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
//            // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
//            return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
//                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _thumbnailImage 中
//                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//                if (downloadFinined) {
//                    _thumbnailImage = result;
//                }
//                if (completion) {
//                    completion(result, info);
//                }
//            }];
//        }
//    } else {
//        if (completion) {
//            completion([self thumbnailWithSize:size], nil);
//        }
//        return 0;
//    }
//}

- (UIImage *)previewImage {
    if (_previewImage) {
        return _previewImage;
    }
    __block UIImage *resultImage;
    
    if (SS_IOS8_OR_LATER) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        
        //        PHCachingImageManager *cachingManager = [[YDPhotoKitHelper sharedManager] de];
        PHImageManager *imageManager = [PHImageManager defaultManager];
        [imageManager requestImageForAsset:_phAsset
                                targetSize:CGSizeMake(SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT)
                               contentMode:PHImageContentModeAspectFill
                                   options:imageRequestOptions
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 resultImage = result;
                             }];
    } else {
        CGImageRef fullScreenImageRef = [_alAsset aspectRatioThumbnail];
        //        CGImageRef fullScreenImageRef = [_alAsset fullScreenImage];
        resultImage = [UIImage imageWithCGImage:fullScreenImageRef];
    }
    
    //    _previewImage = resultImage;
    
    return resultImage;
}

//- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
//    if (_usePhotoKit) {
//        if (_previewImage) {
//            // 如果已经有缓存的图片则直接拿缓存的图片
//            if (completion) {
//                completion(_previewImage, nil);
//            }
//            return 0;
//        } else {
//            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//            imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
//            imageRequestOptions.progressHandler = phProgressHandler;
//            return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
//                // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
//                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
//                if (downloadFinined) {
//                    _previewImage = result;
//                }
//                if (completion) {
//                    completion(result, info);
//                }
//            }];
//        }
//    } else {
//        if (completion) {
//            completion([self previewImage], nil);
//        }
//        return 0;
//    }
//}

@end
