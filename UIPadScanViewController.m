//
//  UIPadScanViewController.m
//  MatroPad
//
//  Created by Matro on 16/8/24.
//  Copyright © 2016年 Matro. All rights reserved.
//

#import "UIPadScanViewController.h"
//设备宽/高/坐标
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

//static const float kLineMinY = 185;
static const float kLineMinY = 250;
static const float kLineMaxY = 750;
static const float kReaderViewWidth = 500;
static const float kReaderViewHeight = 500;

@interface UIPadScanViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *qrSession;//回话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;//读取
@property (nonatomic, strong) UIImageView *line;//交互线
@property (nonatomic, strong) UIImageView *img;//交互线框框
@property (nonatomic, strong) NSTimer *lineTimer;//交互线控制
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *labIntroudction;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;

@end

@implementation UIPadScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = MS_RGB(102, 102, 102);
    NSLog(@"bounds000--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    NSLog(@"frame000-->%@",NSStringFromCGRect(self.view.frame));

    self.view.backgroundColor = [UIColor clearColor];

    _line = [[UIImageView alloc] init];
    _img = [[UIImageView alloc] init];
    _labIntroudction = [[UILabel alloc] init];
    _bgView = [[UIView alloc] init];
    _titleLab = [[UILabel alloc] init];

    [self initUI];
    [self setOverlayPickerView];
    [self startSYQRCodeReading];
    [self initTitleView];
    
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications ];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

}


/*
- (void)orientChange:(NSNotification *)noti

{


    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
 
    switch (orient)
    
    {
        case UIDeviceOrientationPortrait:
            
//            [self transinitUI];
//            [self transsetOverlayPickerView];
//            [self transinitTitleView];
 
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            
//            [self transinitUI];
//            [self transsetOverlayPickerView];
//            [self transinitTitleView];

            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            
//            [self transinitUI];
//            [self transsetOverlayPickerView];
//            [self transinitTitleView];
            break;
   
        default:
            
            break;
            
    }
    
}
*/

- (void)dealloc
{
    if (_qrSession) {
        [_qrSession stopRunning];
        _qrSession = nil;
    }
    
    if (_qrVideoPreviewLayer) {
        _qrVideoPreviewLayer = nil;
    }
    
    if (_line) {
        _line = nil;
    }
    
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
}



- (void)initTitleView
{
    _bgView.frame = CGRectMake(0,0,kDeviceWidth, 64);
    _bgView.backgroundColor = MS_RGB(102, 102, 102);
    [self.view addSubview:_bgView];

    _titleLab.frame = CGRectMake((kDeviceWidth - 100) / 2.0, 28, 100, 20);
    
    _titleLab.text = @"扫描二维码";
    _titleLab.shadowOffset = CGSizeMake(0, - 1);
    _titleLab.font = [UIFont boldSystemFontOfSize:18.0];
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLab];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(10, 28, 44, 24)];
    [btn setImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];

    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancleSYQRCodeReading) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
 

}

/*
- (void)transinitTitleView{
    
     UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
     
     if (orient  == UIDeviceOrientationPortrait ) {
         
         NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
         NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));

         
         _bgView.frame = CGRectMake(0,0,self.view.bounds.size.height, 64);
         _bgView.backgroundColor = MS_RGB(102, 102, 102);
         [self.view addSubview:_bgView];
     
         _titleLab.frame = CGRectMake((self.view.bounds.size.height - 100) / 2.0, 28, 100, 20);
     
         _titleLab.text = @"扫描二维码";
         _titleLab.shadowOffset = CGSizeMake(0, - 1);
         _titleLab.font = [UIFont boldSystemFontOfSize:18.0];
         _titleLab.textColor = [UIColor whiteColor];
         _titleLab.textAlignment = NSTextAlignmentCenter;
         [self.view addSubview:_titleLab];
     
         UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
         [btn setFrame:CGRectMake(10, 28, 44, 24)];
         [btn setImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
    
         [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [btn addTarget:self action:@selector(cancleSYQRCodeReading) forControlEvents:UIControlEventTouchUpInside];
         [self.view addSubview:btn];
     
     
     }else if(orient  == UIDeviceOrientationLandscapeLeft || orient  == UIDeviceOrientationLandscapeRight){
         
         NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
         NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));
 
     
         _bgView.frame = CGRectMake(0,0,self.view.bounds.size.height, 64);
         _bgView.backgroundColor = MS_RGB(102, 102, 102);
         [self.view addSubview:_bgView];
     
         _titleLab.frame = CGRectMake((self.view.bounds.size.height - 100) / 2.0, 28, 100, 20);
         
         _titleLab.text = @"扫描二维码";
         _titleLab.shadowOffset = CGSizeMake(0, - 1);
         _titleLab.font = [UIFont boldSystemFontOfSize:18.0];
         _titleLab.textColor = [UIColor whiteColor];
         _titleLab.textAlignment = NSTextAlignmentCenter;
         [self.view addSubview:_titleLab];
     
         UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
         [btn setFrame:CGRectMake(10, 28, 44, 24)];
         [btn setImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
   
         [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [btn addTarget:self action:@selector(cancleSYQRCodeReading) forControlEvents:UIControlEventTouchUpInside];
         [self.view addSubview:btn];
     
     }
    
    
}
*/

- (void)initUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //摄像头判断
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error)
    {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请到设置里设置相机权限" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    //设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
//    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性

    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
     NSLog(@"frame22222-->%@",NSStringFromCGRect(self.view.layer.bounds));
    
    _preview.frame = self.view.layer.bounds;

    //将图层添加到视图的图层
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    self.qrVideoPreviewLayer = _preview;
    self.qrSession = session;
}

/*
- (void)transinitUI
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //摄像头判断
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error)
    {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请到设置里设置相机权限" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    //设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置输出的代理
    //使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self transgetReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    //拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else
    {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    //设置输出的格式
    //一定要先设置会话的输出为output之后，再指定输出的元数据类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置预览图层
    AVCaptureVideoPreviewLayer *preview1 = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    
    [preview1 setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    NSLog(@"frame22222-->%@",NSStringFromCGRect(self.view.layer.bounds));
    
//    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
//    
//    if (orient  == UIDeviceOrientationPortrait ) {
//  
//        [preview setFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
//        
//    }else if(orient  == UIDeviceOrientationLandscapeLeft || orient  == UIDeviceOrientationLandscapeRight){
//
//        [preview setFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
//    }
    
    
//        preview.frame = self.view.layer.bounds;
    [preview1 setFrame:CGRectMake(0, 0, 2000, 2000)];
    
    
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preview1 atIndex:0];
    self.qrVideoPreviewLayer = preview1;
    self.qrSession = session;
}
*/


#pragma alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
  
//    return  self.view.layer.bounds;
}

/*
- (CGRect)transgetReaderViewBoundsWithSize:(CGSize)asize
{
//    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
    
    return  self.view.layer.bounds;
}
*/

- (void)setOverlayPickerView
{
    //画中间的基准线
    _line.frame = CGRectMake((kDeviceWidth - 500) / 2.0, kLineMinY, 500, 3);
    [_line setImage:[UIImage imageNamed:@"line_saomiao"]];
    [self.view addSubview:_line];
    
    _img.image = [UIImage imageNamed:@"box_saomian"];
    _img.frame = CGRectMake((kDeviceWidth - 500) / 2.0, kLineMinY, kReaderViewWidth, kReaderViewWidth);
    [self.view addSubview:_img];


    //说明label
    _labIntroudction.backgroundColor = [UIColor clearColor];
    _labIntroudction.frame = CGRectMake(CGRectGetMinX(_img.frame), CGRectGetMinY(_img.frame) - 40, kReaderViewWidth, 30);
    _labIntroudction.textAlignment = NSTextAlignmentCenter;
    _labIntroudction.font = [UIFont boldSystemFontOfSize:18.0];
    _labIntroudction.textColor = [UIColor whiteColor];
    _labIntroudction.text = @"对准商品二维码到框内即可扫描";
    [self.view addSubview:_labIntroudction];

    
}

/*
- (void)transsetOverlayPickerView{
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    if (orient  == UIDeviceOrientationPortrait ) {
        
        NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));

        //画中间的基准线
        _line.frame = CGRectMake((self.view.bounds.size.height - 500) / 2.0, kLineMinY, 500, 3);
        [_line setImage:[UIImage imageNamed:@"line_saomiao"]];
        [self.view addSubview:_line];
        _img.image = [UIImage imageNamed:@"box_saomian"];
        _img.frame = CGRectMake((self.view.bounds.size.height - 500) / 2.0, kLineMinY, kReaderViewWidth, kReaderViewWidth);
       
        [self.view addSubview:_img];
        
        
        //说明label
        _labIntroudction.backgroundColor = [UIColor clearColor];
        _labIntroudction.frame = CGRectMake(CGRectGetMinX(_img.frame), CGRectGetMinY(_img.frame) - 40, kReaderViewWidth, 30);
        _labIntroudction.textAlignment = NSTextAlignmentCenter;
        _labIntroudction.font = [UIFont boldSystemFontOfSize:18.0];
        _labIntroudction.textColor = [UIColor whiteColor];
        _labIntroudction.text = @"对准商品二维码到框内即可扫描";
        [self.view addSubview:_labIntroudction];
        
        
    }else if(orient  == UIDeviceOrientationLandscapeLeft || orient  == UIDeviceOrientationLandscapeRight){
        
        NSLog(@"bounds--->%@",NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        NSLog(@"frame-->%@",NSStringFromCGRect(self.view.frame));

        //画中间的基准线
        _line.frame = CGRectMake((self.view.bounds.size.height - 500) / 2.0, kLineMinY, 500, 3);
        [_line setImage:[UIImage imageNamed:@"line_saomiao"]];
        [self.view addSubview:_line];

        _img.image = [UIImage imageNamed:@"box_saomian"];
        _img.frame = CGRectMake((self.view.bounds.size.height - 500) / 2.0, kLineMinY, kReaderViewWidth, kReaderViewWidth);
        [self.view addSubview:_img];
        
        
        //说明label
        _labIntroudction.backgroundColor = [UIColor clearColor];
        _labIntroudction.frame = CGRectMake(CGRectGetMinX(_img.frame), CGRectGetMinY(_img.frame) - 40, kReaderViewWidth, 30);
        _labIntroudction.textAlignment = NSTextAlignmentCenter;
        _labIntroudction.font = [UIFont boldSystemFontOfSize:18.0];
        _labIntroudction.textColor = [UIColor whiteColor];
        _labIntroudction.text = @"对准商品二维码到框内即可扫描";
        [self.view addSubview:_labIntroudction];
        
    }
    
    
}
*/

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//
//{
//    
//    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
//    
//}

- (BOOL)shouldAutorotate

{
    
    return NO;
    
}

//- (NSUInteger)supportedInterfaceOrientations
//
//{
//    
//    return UIInterfaceOrientationMaskPortrait;//只支持这一个方向(正常的方向)
//    
//}
//
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    return UIInterfaceOrientationPortrait;
//}

#pragma mark -
#pragma mark 输出代理方法

//此方法是在识别到QRCode，并且完成转换
//如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //扫描结果
    if (metadataObjects.count > 0)
    {
        [self stopSYQRCodeReading];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            NSLog(@"---------%@",obj.stringValue);
            
            
            if ([obj.stringValue containsString:@"http"])
            {
                if (self.SYQRCodeSuncessBlock) {
                    self.SYQRCodeSuncessBlock(self,obj.stringValue);
                }
            }
            else
            {
                if (self.SYQRCodeFailBlock) {
                    self.SYQRCodeFailBlock(self);
                }
            }
        }
        else
        {
            if (self.SYQRCodeFailBlock) {
                self.SYQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.SYQRCodeFailBlock) {
            self.SYQRCodeFailBlock(self);
        }
    }
}


#pragma mark -
#pragma mark 交互事件

- (void)startSYQRCodeReading
{
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [self.qrSession startRunning];
    
    NSLog(@"start reading");
}

- (void)stopSYQRCodeReading
{
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
    [self.qrSession stopRunning];
    
    NSLog(@"stop reading");
}

//取消扫描
- (void)cancleSYQRCodeReading
{
    [self stopSYQRCodeReading];
    
    if (self.SYQRCodeCancleBlock)
    {
        self.SYQRCodeCancleBlock(self);
    }
    NSLog(@"cancle reading");
}


#pragma mark -
#pragma mark 上下滚动交互线

- (void)animationLine
{
    __block CGRect frame = _line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            _line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (_line.frame.origin.y >= kLineMinY)
        {
            if (_line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                _line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    _line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }

}

@end
