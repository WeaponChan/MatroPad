//
//  MLActivityViewController.h
//  MatroPad
//
//  Created by Matro on 16/8/24.
//  Copyright © 2016年 Matro. All rights reserved.
//

#import <UIKit/UIKit.h>


#define MS_RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface MLActivityViewController : UIViewController
@property(nonatomic ,copy)NSString *activityurl;
@end

