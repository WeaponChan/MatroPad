//
//  MLActivityViewController.m
//  MatroPad
//
//  Created by Matro on 16/8/24.
//  Copyright © 2016年 Matro. All rights reserved.
//

#import "MLActivityViewController.h"
#import "ViewController.h"
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
@interface MLActivityViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MLActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self initTitleView];
    [self createBackBtn];
    [self loadWebView];
}


- (void)orientChange:(NSNotification *)noti

{
    
    NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    switch (orient)
    
    {
            
        case UIDeviceOrientationPortrait:
            
            [self transinitTitleView];
            
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [self transinitTitleView];
           
            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            [self transinitTitleView];
          
            break;
            
        default:
            
            break;
            
    }
    
}

- (void)initTitleView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kDeviceWidth, 44)];
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 100 - 120) / 2.0, 10, 100, 22)];
    logoImage.image = [UIImage imageNamed:@"logo"];
    [bgView addSubview:logoImage];
    self.navigationItem.titleView = bgView;
    
}

- (void)transinitTitleView{
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    if (orient  == UIDeviceOrientationPortrait ) {
        
        NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 44)];
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100 - 120) / 2.0, 10, 100, 22)];
        logoImage.image = [UIImage imageNamed:@"logo"];
        [bgView addSubview:logoImage];
        self.navigationItem.titleView = bgView;
        
        
    }else if(orient  == UIDeviceOrientationLandscapeLeft || orient  == UIDeviceOrientationLandscapeRight){
        
        NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.height, 44)];
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.height - 100) / 2.0, 10, 100, 22)];
        logoImage.image = [UIImage imageNamed:@"logo"];
        [bgView addSubview:logoImage];
        self.navigationItem.titleView = bgView;
    }
    
    
}

- (void)createBackBtn
{
    UIImage *backButtonImage = [[UIImage imageNamed:@"back1"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@""  style:UIBarButtonItemStylePlain target:self action:@selector(Actcancle)];
    item.title = @"";
    item.image = backButtonImage;
    item.width = 20;
    item.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)Actcancle{
    
    [self.parentViewController.view removeFromSuperview];
    [self.parentViewController removeFromParentViewController];
    
}

-(BOOL)shouldAutorotate{

    return NO;
}

-(void)loadWebView{
    
    NSLog(@"---222---%@",self.activityurl);
    
    _webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.activityurl]];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

