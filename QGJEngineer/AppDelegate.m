//
//  AppDelegate.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <Bugly/Bugly.h>

#define BUGLY_APP_ID @"04c576d7c4"
@interface AppDelegate ()<DeviceDelegate,BuglyDelegate>



@end

@implementation AppDelegate

+ (AppDelegate *)currentAppDelegate
{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setupBugly];
    
    _device =[[WYDevice alloc]init];
    _device.deviceDelegate=self;
    _device.tag = 1;
    
    _device2 = [[WYDevice alloc]init];
    _device2.deviceDelegate=self;
    _device2.tag = 2;
    
    _device3 = [[WYDevice alloc]init];
    _device3.deviceDelegate=self;
    _device3.tag = 3;
    
    _device4 = [[WYDevice alloc]init];
    _device4.deviceDelegate=self;
    _device4.tag = 4;
    
    if([USER_DEFAULTS objectForKey:DevicUUID_0]){
        _device.deviceStatus=5;
    }
    
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerConnect:) userInfo:nil repeats:NO];
    
    // [self changeToHomeViewController];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"version1.3"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"version1.3"];
        [LVFmdbTool deleteData:nil];
        ProfileModel *pmodel = [ProfileModel modalWith:-65 keytest:1 keyconfigure:1 inductionkey:0 keynumber:2 function1:@"1号按键" function2:@"2号按键" function3:@"3号按键" function4:@"4号按键" routinetest:0 line:@"单线测试" onekeytest:0 seat:0 lock:0 calibration:0 shake:0 buzzer:0 inducrssi:-65 OneclickControl:0 OnelineSpeech:0 firmware:0 firmversion:@"X100.V1.1.0" brand:@"无"];
        [LVFmdbTool insertPModel:pmodel];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:@"-65",@"rssi", nil];
        [userDefaults setObject:userDic forKey:RSSIVALUE];
        [userDefaults synchronize];
        
        NSDictionary *verDic = [NSDictionary dictionaryWithObjectsAndKeys:@"000000",@"version", @"设防",@"key1",@"撤防",@"key2",@"寻车",@"key3",@"一键启动",@"key4",@"X100.V1.1.0",@"firmversion",nil];
        [userDefaults setObject:verDic forKey:versionDic];
        [userDefaults synchronize];
    }
    
    [self loginStateChange:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:86400.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupBugly {
    // Get the default config
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.debugMode = YES;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 1.5;
    config.channel = @"Bugly";
    config.delegate = self;
    config.consolelogEnable = NO;
    config.viewControllerTrackingEnable = NO;
    [Bugly startWithAppId:BUGLY_APP_ID
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];
    
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"User: %@", [UIDevice currentDevice].name]];
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];
    
}


- (void)timerFired:(NSTimer *)timer{
    
    [self logindata];
}

- (void)logindata{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:logInUSERDIC];
    if ([QFTools isBlankString:userDic[@"phone_num"]]) {
        return;
    }
    
    NSString *password= userDic[@"password"];
    NSString *phonenum= userDic[@"phone_num"];
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"FACTORY"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/login"];
    NSDictionary *parameters = @{@"account": phonenum, @"passwd": md5};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSString * token=[data objectForKey:@"token"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",phonenum,@"phone_num",password,@"password",nil];
            [userDefaults setObject:userDic forKey:FactoryUserDic];
            [userDefaults synchronize];
            NSArray *Firms = data[@"Firms"];
            [LVFmdbTool deleteFirmData:nil];
            
            for (NSDictionary *firmModel in Firms) {
                
                NSString *latest_version = firmModel[@"latest_version"];
                NSString *download = firmModel[@"download"];
                
                FirmVersionModel *pmodel = [FirmVersionModel modalWith:latest_version download:download];
                [LVFmdbTool insertFirmModel:pmodel];
                
            }
            
        }
        else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                [userDefatluts removeObjectForKey:logInUSERDIC];
                [userDefatluts synchronize];
                self.device.scanDelete = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            });
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

#pragma mark - private
//登陆状态改变
-(void)loginStateChange:(NSNotification *)notification
{
    UIViewController *nav = nil;
    BOOL loginSuccess = [notification.object boolValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:logInUSERDIC];
    if (![QFTools isBlankString:userDic[@"phone_num"]] || loginSuccess) {//登陆成功加载主窗口控制器
        
        if (_mainController == nil) {
            
            _mainController = [[MainViewController alloc] init];
            nav = _mainController;
        }else{
            
            nav  = _mainController;
        }
    }else{//登陆失败加载登陆页面控制器
        
        _mainController = nil;
        LoginViewController *loginController = [[LoginViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:loginController];
    }
    
    self.window.rootViewController = nav;
}

#pragma mark - 蓝牙连接回调

-(void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral
{
    if (tag == 1) {
        
        _device.deviceStatus=2;
        
    }else if (tag == 2){
        
        _device2.deviceStatus=2;
    }else if (tag == 3){
        
        _device3.deviceStatus=2;
    }else if (tag == 4){
        
        _device4.deviceStatus=2;
    }
    
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:[NSNumber numberWithInteger:tag]]];
    
#pragma mark---同步数据 ---发送命令
    
    NSLog(@"蓝牙连接上了报警器了");
}

-(void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral
{
    if (tag == 1) {
        
        _device.deviceStatus=0;
        NSLog(@"蓝牙断开连接了报警器了");
        
    }else if (tag == 2){
        
        _device2.deviceStatus=0;
    }else if (tag == 3){
        
        _device3.deviceStatus=0;
    }else if (tag == 4){
        
        _device4.deviceStatus=0;
    }
    
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:[NSNumber numberWithInteger:tag]]];
}


#pragma mark---接收到了数据 蓝牙indication
-(void)didGetSensorData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
{
    
    NSString *result = [ConverUtil data2HexString:data];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tag],@"deviceTg",result,@"data", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryData object:nil userInfo:dict]];
}

-(void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{

    NSString *result = [ConverUtil data2HexString:data];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tag],@"deviceTg",result,@"data", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_Mac object:nil userInfo:dict]];
}

//固件版本号
-(void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{

    NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tag],@"deviceTg",result,@"data", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_Edition object:nil userInfo:dict]];
}

//硬件版本号回调
-(void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *version = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tag],@"deviceTg",version,@"version", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_Version object:nil userInfo:dict]];
}

-(void)didGetMacStringCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{

    
    NSString *result = [ConverUtil data2HexString:data];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:tag],@"deviceTg",result,@"data", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BurglarMac object:nil userInfo:dict]];
}

- (NSUInteger) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
