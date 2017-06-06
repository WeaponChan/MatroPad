//
//  ViewController.m
//  MatroPad
//
//  Created by Matro on 16/5/5.
//  Copyright © 2016年 Matro. All rights reserved.
//

#import "ViewController.h"
#import "UIPadScanViewController.h"
#import "MLActivityViewController.h"
#import "AppDelegate.h"
#import "MLPadViewController.h"

@protocol JSObjectDelegate <JSExport>

- (void)padScan;
- (void)skipActivity:(NSString *)url;
//- (void)getversion;

@end

@interface ViewController ()<UIWebViewDelegate,JSObjectDelegate>{
    NSString *actUrl;
    NSString *version;
}
@property(nonatomic,strong)JSContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://matropad.matrojp.com/matroPad/coffee.v2/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    self.webView.scrollView.bounces = NO;

}


-(void)webViewDidFinishLoad:(UIWebView *)webView{

    NSLog(@"webView网页完成加载");
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.context[@"_native"] = self;
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"JavaScript异常信息：%@", exceptionValue);
    };
    
    NSString *alertJS=@"getversion(2)"; //准备执行的js代码
    [self.context evaluateScript:alertJS];//通过oc方法调用js的方法
}

//-(void)getversion{
//
//    NSString *alertJS=@"getversion(2)"; //准备执行的js代码
//    [self.context evaluateScript:alertJS];//通过oc方法调用js的方法
//}

#pragma mark 二维码扫描
- (void)padScan{
    [self performSelectorOnMainThread:@selector(testAction) withObject:nil waitUntilDone:YES];
}

- (void)testAction{
    [self scanning];
}

- (void)scanning{
    //开始捕获
    //扫描二维码
    
    UIPadScanViewController *qrcodevc = [[UIPadScanViewController alloc] init];
    
    qrcodevc.SYQRCodeSuncessBlock = ^(UIPadScanViewController *aqrvc,NSString *qrString){
        NSLog(@"%@",qrString);
        
        //扫除结果后处理字符串
        
        [aqrvc dismissViewControllerAnimated:NO completion:^{

            if (qrString.length >0) {
                NSString *scanStr = [NSString stringWithFormat:@"%@",qrString];
                NSString *alertJS=@"padScanAfter()"; //准备执行的js代码
                JSValue *jsFunction = self.context[@"padScanAfter"];
                JSValue *value1 = [jsFunction callWithArguments:@[scanStr]];
                
            }else{
               
            }
            
        }];
    };
    qrcodevc.SYQRCodeFailBlock = ^(UIPadScanViewController *aqrvc){//扫描失败
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(UIPadScanViewController *aqrvc){//取消扫描
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    [self presentViewController:qrcodevc animated:YES completion:nil];
    
}

-(NSString *)jiexi:(NSString *)CS webaddress:(NSString *)webaddress
{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",CS];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    // NSString *webaddress=@"http://www.baidu.com/dd/adb.htm?adc=e12&xx=lkw&dalsjd=12";
    NSArray *matches = [regex matchesInString:webaddress
                                      options:0
                                        range:NSMakeRange(0, [webaddress length])];
    for (NSTextCheckingResult *match in matches) {
        //NSRange matchRange = [match range];
        //NSString *tagString = [webaddress substringWithRange:matchRange];  // 整个匹配串
        //        NSRange r1 = [match rangeAtIndex:1];
        //        if (!NSEqualRanges(r1, NSMakeRange(NSNotFound, 0))) {    // 由时分组1可能没有找到相应的匹配，用这种办法来判断
        //            //NSString *tagName = [webaddress substringWithRange:r1];  // 分组1所对应的串
        //            return @"";
        //        }
        
        NSString *tagValue = [webaddress substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        //    NSLog(@"分组2所对应的串:%@\n",tagValue);
        return tagValue;
    }
    return @"";
}
#pragma end 二维码扫描结束

-(void)skipActivity:(NSString *)url{
    NSLog(@"url===%@",url);
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    actUrl  = url;
    [self performSelector:@selector(gotoactDetail) withObject:self afterDelay:0.5f];
    
//    if (url && url.length >0) {

//        /*
//        dispatch_async(dispatch_get_main_queue(), ^{
//        ActivityViewController *vc = [[ActivityViewController alloc ]init];
//        vc.activityurl = url;
//        [self.navigationController pushViewController:vc animated:YES];
//        });
//         */
//    }
    
}

-(void)gotoactDetail{
 
    dispatch_async(dispatch_get_main_queue(), ^{
  
        MLActivityViewController *searchViewController = [[MLActivityViewController alloc]init];
        searchViewController.activityurl = actUrl;
 
        UINavigationController *searchNavigationViewController = [[UINavigationController alloc]initWithRootViewController:searchViewController];
        
        UIViewController *rootViewController = ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        [rootViewController addChildViewController:searchNavigationViewController];
        [rootViewController.view addSubview:searchNavigationViewController.view];
        
    });
    
}

- (NSString*)getVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"version===%@",version);
    return version;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
