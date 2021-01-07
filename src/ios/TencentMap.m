//
//  TencentMap.m
//  dingwei
//
//  Created by chenlei on 2020/12/28.
//

#import "TencentMap.h"
#import <TencentLBS/TencentLBS.h>

@interface TencentMap ()<TencentLBSLocationManagerDelegate>

@property (readwrite, nonatomic, strong) TencentLBSLocationManager *locationManager;

@end
@implementation TencentMap

static TencentMap *_Manager = nil;
+ (instancetype)shareManager {
    static dispatch_once_t oneceToken;
    dispatch_once(&oneceToken, ^{
        _Manager = [[self alloc] init];
    });
    return _Manager;
}
- (instancetype)init{
    if (self == [super init]) {
       
    }
    return self;
}

- (void)startTencentLocation:(NSString *)apiKey
{
    self.locationManager = [[TencentLBSLocationManager alloc] init];
 
    [self.locationManager setDelegate:self];
 
    [self.locationManager setApiKey:apiKey];
 
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
 
    // 需要后台定位的话，可以设置此属性为YES。
    [self.locationManager setAllowsBackgroundLocationUpdates:NO];
 
    // 如果需要POI信息的话，根据所需要的级别来设定，定位结果将会根据设定的POI级别来返回，如：
    [self.locationManager setRequestLevel:TencentLBSRequestLevelName];
 
    // 申请的定位权限，得和在info.list申请的权限对应才有效
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}
 
// 单次定位
- (void)getTencentLocation:(CDVInvokedUrlCommand*)command
 {
     NSString*appkey=[command.arguments objectAtIndex:0];
     if ( [appkey isKindOfClass:[NSNull class]] || [appkey isEqualToString:@""] || appkey == nil) {
         appkey = @"5WNBZ-2JYR6-SPUSL-M3WGH-U4KDT-K2FYV";
     }
     [self startTencentLocation:appkey];
    [self.locationManager requestLocationWithCompletionBlock:
        ^(TencentLBSLocation *location, NSError *error) {
        CDVPluginResult*pluginResult =nil;
        NSString*callbackidStr=  command.callbackId;
        //要传递的参数
        NSDictionary * ret = @{@"latitude":[NSString stringWithFormat:@"%f",location.location.coordinate.latitude] ,@"longitude":[NSString stringWithFormat:@"%f",location.location.coordinate.longitude]};
        if (callbackidStr!=nil) {
            pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:ret];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackidStr];
        }
        
    }];
}
 
// 连续定位
- (void)startSerialLocation {
    //开始定位
    [self.locationManager startUpdatingLocation];
}
 
- (void)stopSerialLocation {
    //停止定位
    [self.locationManager stopUpdatingLocation];
}
 
- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied ||
        authorizationStatus == kCLAuthorizationStatusRestricted) {
 
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"定位权限未开启，是否开启？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if( [[UIApplication sharedApplication]canOpenURL:
                [NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
                [[UIApplication sharedApplication] openURL:
                    [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }]];
 
        [alert addAction:[UIAlertAction actionWithTitle:@"否"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
        }]];
 
        [self.getCurrentVC presentViewController:alert animated:true completion:nil];
 
    }
}
 
 
- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    //定位结果
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }

    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}
@end
