//
//  SSPhotoPreviewViewController.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

//  图片预览视图

#import <UIKit/UIKit.h>

@interface SSPhotoPreviewViewController : UIViewController

@property (strong, nonatomic) NSArray *photoArray;           /**< 所有的图片资源 */
@property (nonatomic, strong) NSMutableArray *selectedPhotoArray;/**< 已选择的图片资源 */

@property (nonatomic, assign) NSInteger currentSelectedIndex;/**< 当前选中的图片的索引 */
//@property (assign, nonatomic) NSInteger uploadedPicsCount;   /**< 当前已经上传的图片数量 */

@property (nonatomic, strong) UIImage *singleImage;         /**< 单张拍摄图片 */

@end
