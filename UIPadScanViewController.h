//
//  UIPadScanViewController.h
//  MatroPad
//
//  Created by Matro on 16/8/24.
//  Copyright © 2016年 Matro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MLPadViewController.h"

@interface UIPadScanViewController : UIViewController
#define MS_RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@property (nonatomic, copy) void (^SYQRCodeCancleBlock) (UIPadScanViewController *);//扫描取消
@property (nonatomic, copy) void (^SYQRCodeSuncessBlock) (UIPadScanViewController *,NSString *);//扫描结果
@property (nonatomic, copy) void (^SYQRCodeFailBlock) (UIPadScanViewController *);//扫描失败

@end
