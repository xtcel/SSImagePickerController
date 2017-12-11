//
//  ViewController.m
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/7.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#import "ViewController.h"
#import "SSImagePickerController.h"

@interface ViewController ()<SSImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectImageButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectImageButtonClickEvent:(id)sender {
    SSImagePickerController *imagePickerViewCtrl = [[SSImagePickerController alloc] init];
    imagePickerViewCtrl.delegate = self;
    [self presentViewController:imagePickerViewCtrl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(SSImagePickerController *)picker didFinishPickingImages:(NSArray *)images sourceAssets:(NSArray *)assets {
    
}


@end
