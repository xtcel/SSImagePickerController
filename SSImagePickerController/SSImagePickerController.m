//
//  SSImagePickerController.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "SSImagePickerController.h"
#import "SSImageManager.h"
#import "SSPhotoViewController.h"
#import "SSAlbum.h"

@interface SSImagePickerController ()

@end

@implementation SSImagePickerController

#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // 检测授权
        BOOL isAuthorized = [[SSImageManager manager] authorizationStatusAuthorized];
        if (isAuthorized) {
            [[SSImageManager manager] requestAuthorization:^(BOOL authorizationStatus) {
                if (authorizationStatus) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pushPhotoViewController];
                    });
                } else {
                    //                [self tipNoPhotosAuthorization];
                }
            }];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDelegate:(id<UINavigationControllerDelegate,SSImagePickerControllerDelegate>)delegate {
    [super setDelegate:delegate];
    
    [SSImageManager manager].delegate= delegate;
}


#pragma mark - PushPhotoViewController

- (void)pushPhotoViewController {
    SSPhotoViewController *photoViewCtrl = [[SSPhotoViewController alloc] init];
    [self pushViewController:photoViewCtrl animated:NO];
}

@end
