//
//  SSAlbum.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSAlbum.h"

@interface SSAlbum()

@property (strong, nonatomic) ALAssetsGroup *group;
@property (strong, nonatomic) PHFetchResult *phCollection;

@end

@implementation SSAlbum

- (id)collection
{
    return SS_IOS8_OR_LATER ? self.phCollection : self.group;
}

- (void)setCollection:(id)collection
{
    if (SS_IOS8_OR_LATER) {
        self.phCollection = (PHFetchResult *)collection;
    } else {
        self.group = (ALAssetsGroup *)collection;
    }
}

//- (void)postImageWithSize:(CGSize)size completion:(void (^)(BOOL, UIImage *))completion {
//    if (_postImage) {
//        completion(YES, _postImage);
//    }
//
//    __block UIImage *resultImage;
//
//    if (IOS8_OR_LATER) {
//        PHFetchOptions *options = [[PHFetchOptions alloc] init];
//        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:_phCollection options:options];
//
//        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
//        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
//        phImageRequestOptions.synchronous = YES;
//        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
//        NSInteger scale = [[UIScreen mainScreen] scale];
//        //        PHCachingImageManager *cachingManager = [[YDPhotoKitHelper sharedManager] phCachingImageManager];
//        PHCachingImageManager *cachingManager = [[YDPHSourceManager sharedManager] phCachingImageManager];
//        CGSize targetSize = CGSizeMake(size.width * scale, size.height * scale);
//
//        [cachingManager requestImageForAsset:[assets firstObject]
//                                targetSize:targetSize
//                               contentMode:PHImageContentModeAspectFill
//                                   options:phImageRequestOptions
//                             resultHandler:^(UIImage *result, NSDictionary *info) {
//                                 resultImage = result;
//                                 _postImage = resultImage;
//                                 if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
//                                     completion((result != nil), resultImage);
//                                 }
//                             }];
//    } else {
//        CGImageRef postImageRef = [_group posterImage];
//        if (postImageRef) {
//            _postImage = resultImage;
//            resultImage = [UIImage imageWithCGImage:postImageRef];
//            completion(YES, resultImage);
//        }
//    }
//}
//
//#pragma mark - Getter/Setter
//
//- (void)setGroup:(ALAssetsGroup *)assetsGroup {
//    _group = assetsGroup;
//    _groupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
//    _numberOfAssets = _assetsGroup.numberOfAssets;
//}
//
//- (void)setPhCollection:(PHAssetCollection *)phCollection {
//    _phCollection = phCollection;
//    _groupName = phCollection.localizedTitle;
//
//    //判断类型，如果是智能相册需要动态加载数量
//    if (PHAssetCollectionTypeSmartAlbum == phCollection.assetCollectionType) {
//        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:phCollection options:nil];
//        _numberOfAssets = assetsFetchResult.count;
//    } else {
//        _numberOfAssets = phCollection.estimatedAssetCount;
//    }
//}

@end
