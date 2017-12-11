//
//  SSCommonDefine.h
//  SSImagePickerController
//
//  Created by xiaoyao on 2017/12/8.
//  Copyright © 2017年 xtcel.com. All rights reserved.
//

#ifndef SSCommonDefine_h
#define SSCommonDefine_h

//判断IOS8
//#define SS_IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define SS_IOS8_OR_LATER ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)

#define SS_SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SS_SCREEN_HEIGHT    [UIScreen mainScreen].bounds.size.height

// 提供RGB模式的UIColor定义.
#define     SSRGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define     SSHEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define     SSHEXCOLORA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#endif /* SSCommonDefine_h */
