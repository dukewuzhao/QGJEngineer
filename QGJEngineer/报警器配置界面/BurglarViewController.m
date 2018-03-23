//
//  BurglarViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "BurglarViewController.h"
#import "BottomBtn.h"
#import "DeviceModel.h"
#import "BoxConnectViewController.h"
#import "SetingViewController.h"
#import "MJRefresh.h"
#import "Constants.h"
#import "AppFilesViewController.h"
#import "UserFilesViewController.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "Utility.h"
#import "DFUHelper.h"
#import "QuartzCore/QuartzCore.h"
#import "CustomProgress.h"


@interface BurglarViewController ()<UITableViewDataSource,UITableViewDelegate,ScanDelegate,UIAlertViewDelegate>
{
    NSMutableArray *rssiList;
    NSArray *ascendArray;
    NSMutableDictionary *uuidarray;
    NSMutableDictionary *keycodeDic;
    NSMutableArray *stepArray;
    
    NSMutableArray *inductionAry;
    NSMutableDictionary *inductionDic;
    
    NSTimer *countTimer;
    NSInteger timeNumber;
    NSInteger keynumber;
    NSInteger lineNumber;
    NSInteger linetype;
    
    NSInteger bindingtime;

    NSString *keytitle1;
    NSString *keytitle2;
    NSString *keytitle3;
    NSString *keytitle4;
    //感应钥匙配置参数
    NSString *MacString;//感应钥匙的Mac地址
    
    NSString *EditionString;
    
    NSInteger induckey;
    BOOL testing;
    
    CustomProgress *custompro;
    
}
@property (nonatomic ,copy) NSString *smartBikeMac;//报警器mac地址
@property (nonatomic, strong) NSMutableArray *promteArray;
@property (nonatomic, weak) UILabel *connecttitle;
@property (nonatomic, weak) UIView *firstview;
@property (nonatomic, weak) UITableView *resulttable;
@property (nonatomic, weak) UITableView *keyTable;
@property (nonatomic ,weak) UITableView *table;
@property (nonatomic ,weak) UIView *headView;
@property (nonatomic ,weak) UILabel *prompttitle;
@property (nonatomic ,weak) UILabel *prompttitle2;
@property (nonatomic ,weak) UILabel *countdown;
@property (nonatomic ,copy) NSString *keyHex;
@property (nonatomic ,weak) UIView *backView;
@property (nonatomic ,weak) UIWindow *backWindow;
@property (nonatomic ,weak) UILabel *messageLabel;
@property (nonatomic ,assign) BOOL engineering;
@property (nonatomic ,copy) NSString *keycode;//钥匙吗
@property (nonatomic ,assign) BOOL state;

@property (nonatomic ,assign) NSInteger keyType;//配置钥匙类型
@property (nonatomic, strong) NSMutableArray *keyArray;//最近配置的钥匙的mac地址

@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;
@property (strong, nonatomic) NSString *selectedFileType;
@property(nonatomic,weak)NSTimer *verification;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;

@end

@implementation BurglarViewController

@synthesize selectedPeripheral;
@synthesize dfuOperations;
@synthesize selectedFileType;

- (NSMutableArray *)promteArray {
    if (!_promteArray) {
        _promteArray = [[NSMutableArray alloc] init];
    }
    return _promteArray;
}

- (NSMutableArray *)keyArray {
    if (!_keyArray) {
        
        _keyArray = [[NSMutableArray alloc] init];
        
    }
    return _keyArray;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
     [self.navigationController.navigationBar setHidden:YES];
    [AppDelegate currentAppDelegate].device.scanDelete = self;
    [AppDelegate currentAppDelegate].device3.scanDelete = self;
    [stepArray removeAllObjects];
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM p_profiles WHERE id LIKE '%zd'", 1];
    NSMutableArray *modals = [LVFmdbTool queryPData:fuzzyinduSql];
    ProfileModel *pmodel = modals.firstObject;
    [self matchkeytype2];
    
    NSArray *attributeArr = [QFTools  getClassAttribute:pmodel];
    for (int tt = 0; tt < attributeArr.count; tt ++){
        //  打印值 使用 valueForKey:
        [stepArray addObject:[NSString stringWithFormat:@"%@",[pmodel valueForKey:attributeArr[tt]]]];
    }
    [self beiyong];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PACKETS_NOTIFICATION_INTERVAL=10;
    dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    self.dfuHelper = [[DFUHelper alloc] initWithData:dfuOperations];
    
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance]
     setCategory: AVAudioSessionCategoryPlayback
     error: &setCategoryErr];
    [[AVAudioSession sharedInstance]
     setActive: YES
     error: &activationErr];
    
    //为了能后台播放音乐
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    _ringManager=[[Ringmanager alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    rssiList=[[NSMutableArray alloc]init];
    stepArray = [[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    keycodeDic = [[NSMutableDictionary alloc]init];
    
    inductionAry = [[NSMutableArray alloc]init];
    inductionDic = [[NSMutableDictionary alloc]init];
    
    timeNumber = 11;
    keynumber = 0;
    bindingtime = 0;
    lineNumber = 0;
    linetype = 0;
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];//连接状态的
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(querySuccess:) name:KNotification_QueryData object:nil];//发送的命令回复
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(DeviceMac:) name:KNotification_Mac object:nil];//钥匙Mac地址的监听
    
    //[NSNOTIC_CENTER addObserver:self selector:@selector(DeviceVersion:) name:KNotification_Version object:nil];//报警器硬件版本号的监听
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(DeviceEdition:) name:KNotification_Edition object:nil];//固件版本号
    
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM p_profiles WHERE id LIKE '%zd'", 1];
    NSMutableArray *modals = [LVFmdbTool queryPData:fuzzyinduSql];
    ProfileModel *pmodel = modals.firstObject;
    NSArray *pmodelArr = [QFTools  getClassAttribute:pmodel];
    
    for (int tt = 0; tt < pmodelArr.count; tt ++){
        
        [stepArray addObject:[NSString stringWithFormat:@"%@",[pmodel valueForKey:pmodelArr[tt]]]];
    }
    
    [self setupheadView];
    
    WS(weakSelf);
    __unsafe_unretained UITableView *tableView = self.table;
    // 主页下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf refreshMainView];
        
        
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    __unsafe_unretained UITableView *tableView2 = self.keyTable;
    // 下拉刷新
    tableView2.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf refreshKeyView];
        
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView2.mj_header.automaticallyChangeAlpha = YES;
    
    /**
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [tableView.mj_footer endRefreshing];
        });
    }];
    **/
    
    UIWindow *backWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    backWindow.windowLevel = UIWindowLevelAlert;
    [[UIApplication sharedApplication].keyWindow addSubview:backWindow];
    self.backWindow = backWindow;
    backWindow.hidden = YES;
    
    custompro = [[CustomProgress alloc] initWithFrame:CGRectMake(50, self.view.centerY - 10, self.view.frame.size.width-100, 20)];
    custompro.maxValue = 100;
    custompro.leftimg.image = [UIImage imageNamed:@"leftimg"];
    custompro.bgimg.image = [UIImage imageNamed:@"bgimg"];
    custompro.instruc.image = [UIImage imageNamed:@"bike"];
    //可以更改lab字体颜色
    [backWindow addSubview:custompro];
    
}

-(void)refreshHead{

    
}

-(void)refreshMainView{
    
    [[AppDelegate currentAppDelegate].device stopScan];
    [rssiList removeAllObjects];
    [uuidarray removeAllObjects];
    
    if ([[AppDelegate currentAppDelegate].device isConnected]) {
        [[AppDelegate currentAppDelegate].device remove];
    }
    // 结束刷新
    self.state = NO;
    [self.table.mj_header endRefreshing];
    [[AppDelegate currentAppDelegate].device startScan];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.table reloadData];
    });
    
}

-(void)refreshKeyView{
    
    [[AppDelegate currentAppDelegate].device3 stopScan];
    [inductionAry removeAllObjects];
    [inductionDic removeAllObjects];
    
    
    // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 结束刷新
    [self.keyTable.mj_header endRefreshing];
    [[AppDelegate currentAppDelegate].device3 startScan];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.keyTable reloadData];
    });
    
}

-(void)updateDeviceStatusAction:(NSNotification*)notification{
    
    if ([AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    int deviceTag=[notification.object intValue];
    if (deviceTag == 1) {
    
        if([AppDelegate currentAppDelegate].device.deviceStatus == 0){
            if (![AppDelegate currentAppDelegate].device.upgrate) {
               [self.table.mj_header beginRefreshing];
            }
            
        }else if([AppDelegate currentAppDelegate].device.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device.deviceStatus<5){
            
            [rssiList removeAllObjects];//清除数组
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.table reloadData];
                
            });
            [[AppDelegate currentAppDelegate].device readDiviceInformation];//读取固件版本
            //[[AppDelegate currentAppDelegate].device readDiviceVersion];//读取硬件版本
        }else{
            self.firstview.hidden = NO;
            [countTimer invalidate];
            countTimer = nil;
        }
        
    }else if (deviceTag == 2){
    
        if([AppDelegate currentAppDelegate].device2.deviceStatus == 0){
            
            self.connecttitle.text = @"未连接";
            
        }else if([AppDelegate currentAppDelegate].device2.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device2.deviceStatus<5){
            
            self.connecttitle.text = @"已连接";
            
        }else{
            
            self.connecttitle.text = @"未连接";
            
        }
    
    }else if (deviceTag == 3) {
        
        if([AppDelegate currentAppDelegate].device3.deviceStatus == 0){
            
            
        }else if([AppDelegate currentAppDelegate].device3.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device3.deviceStatus<5){
            
            [inductionAry removeAllObjects];
            [inductionDic removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.keyTable reloadData];
            });
            
            self.keyTable.hidden = YES;
            [[AppDelegate currentAppDelegate].device3 stopScan];
            [[AppDelegate currentAppDelegate].device3 readDiviceMac];
            
        }else{
            
            
        }
        
    }
    
}

-(void)DeviceMac:(NSNotification*)notification{
    
    if ([AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    NSString *date = notification.userInfo[@"data"];
    MacString = date.uppercaseString;
    [[AppDelegate currentAppDelegate].device3 remove];
    
    [self recordInduckey:date.uppercaseString];
    
}

//-(void)DeviceVersion:(NSNotification*)notification{
//
//    if ([AppDelegate currentAppDelegate].IsCodeScan) {
//        return;
//    }
//    NSString *version = notification.userInfo[@"version"];
//
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *verDic = [defaults objectForKey:versionDic];
//    if ([version isEqualToString:verDic[@"version"]]) {
//
//        //读取报警器的固件版本号
//        [[AppDelegate currentAppDelegate].device readDiviceInformation];
//
//    }else{
//
//        [SVProgressHUD showSimpleText:@"硬件版本不匹配"];
//        return;
//
//    }
//
//}


-(void)DeviceEdition:(NSNotification*)notification{
    
    if ([AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    NSNumber *deviceTag = notification.userInfo[@"deviceTg"];
    if (deviceTag.intValue == 1) {
        NSString *date = notification.userInfo[@"data"];
        
        EditionString = date.uppercaseString;
        self.firstview.hidden = YES;
        self.state = YES;
        NSString *brandName = stepArray[23];
        if ([brandName isEqualToString:@"无"]) {
            [self performSelector:@selector(Verification) withObject:nil afterDelay:2.0];
            [self startEngineering];//进入工程模式
            
        }else{
            self.prompttitle.text = @"网络上传";
            [self omebind];
        }
    }
    
}

-(void)omebind{
    [self performSelector:@selector(bindingfail) withObject:nil afterDelay:10];
    NSString *brandName = stepArray[23];
    NSString *brandSql = [NSString stringWithFormat:@"SELECT * FROM allbrandmodels WHERE brand_name LIKE '%@'", brandName];
    NSMutableArray *brandAry = [LVFmdbTool queryAllBrandData:brandSql];
    AllBrandNameModel *allBrandModel = brandAry.firstObject;
    NSNumber *brandid = [NSNumber numberWithInteger:allBrandModel.brand_id];
    NSNumber *modelid = [NSNumber numberWithInt:-1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:logInUSERDIC];
    NSString *token= userDic[@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"oem/bind"];
    NSDictionary *parameters = @{@"token": token, @"mac": self.smartBikeMac,@"brand_id": brandid, @"model_id": modelid};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingfail) object:nil];
            if ([dict[@"status"] intValue] == 0) {
                
                [SVProgressHUD showSimpleText:@"上传品牌成功"];
                [self performSelector:@selector(Verification) withObject:nil afterDelay:2.0];
                [self startEngineering];//进入工程模式
        }else {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        NSLog(@"error :%@",error);
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(bindingfail) object:nil];
        self.prompttitle.text = @"网络上传失败";
        [self  failer];
    }];
    
}

-(void)bindingfail{

    self.prompttitle.text = @"网络上传失败";
    [self  failer];
}


-(void)delayfunction{

    [self performSelector:@selector(querylevel) withObject:nil afterDelay:0.3];
    
}

-(void)delaykeyTest{
    
    [self performSelector:@selector(beganKeytest) withObject:nil afterDelay:0.3];
    
}

-(void)delayBoxFunction{
    
    [self performSelector:@selector(queryBoxLevel) withObject:nil afterDelay:0.3];
    
}

-(void)startEngineering{

    [self engineermode];
}

-(void)engineermode{

    NSString *passwordHEX = @"A5000007400101";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

- (void)beganKeytest{

    NSString *passwordHEX = @"A5000007400401";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

- (void)querylevel{
    timeNumber = 11;
    NSString *passwordHEX = [NSString stringWithFormat:@"A500000740050%d",(int)linetype+1];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];

}

- (void)queryBoxLevel{
    timeNumber = 11;
    NSString *passwordHEX = [NSString stringWithFormat:@"A500000710010%d",(int)linetype+1];
    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

-(void)Verification{

    if (!self.engineering) {
        [self testend];
    }
}


-(void)keytips{

    NSString *path= [[NSBundle mainBundle] pathForResource:@"didi" ofType:@"mp3"];
    [_ringManager playWithPath:path andLoop:1 needVibrate:NO];

}



-(void)querySuccess:(NSNotification*)notification{
    if ([AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    NSString *date = notification.userInfo[@"data"];
    NSNumber *tag = notification.userInfo[@"deviceTg"];
    
    if (tag.intValue == 1) {
    
    if ([date isEqualToString:@"A5000007400101"]) {
        
        if (self.state) {
        
        [[AppDelegate currentAppDelegate].device stopScan];
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(Verification) object:nil];
        self.engineering = YES;
        
        if ([stepArray[1] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"第1把钥匙配置";
            self.prompttitle2.text = @"请按键";
            [self matchkeytype];
        }else {
            
            if ([stepArray[2] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"钥匙1测试";
                self.prompttitle2.text = @"请按键";
                [self keyTest];
            }else{
                
                if ([stepArray[3] intValue] >0 ) {
                    
                    [self inductionkeyTest];
                    
                }else{
                
                if ([stepArray[9] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"常规测试";
                    [self nomalTest];
                }else{
                    
                    if ([stepArray[10] isEqualToString:@"单线测试"]){
                        
                        self.prompttitle.text = @"单线测试";
                        [self roudTest];
                        
                    }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                        
                        self.prompttitle.text = @"双线测试";
                        [self roudTest];
                        
                    }else{
                        
                        if ([stepArray[11] isEqualToString:@"1"]) {
                            self.prompttitle.text = @"震动察觉测试";
                            [self vibrationdetection];
                        }else{
                            
                            if ([stepArray[12] isEqualToString:@"1"]) {
                                self.prompttitle.text = @"蜂鸣器测试";
                                [self buzzerTest];
                            }else{
                                
                                if ([stepArray[13] isEqualToString:@"1"]) {
                                    self.prompttitle.text = @"一键启动测试";
                                    [self onekeystart];
                                }else{
                                    
                                    if ([stepArray[14] isEqualToString:@"1"]) {
                                        self.prompttitle.text = @"坐桶测试";
                                        [self seatTest];
                                    }else{
                                        
                                        if ([stepArray[15] isEqualToString:@"1"]) {
                                            self.prompttitle.text = @"龙头锁测试";
                                            [self lockTest];
                                        }else{
                                            
                                            if ([stepArray[16] isEqualToString:@"1"]) {
                                                
                                                self.prompttitle.text = @"参数校准";
                                                [self calibrationTest];
                                            }else{
                                                
                                                if ([stepArray[18] isEqualToString:@"1"]) {
                                                    
                                                    
                                                    self.prompttitle.text = @"一键通线路控制";
                                                    [self oneClickControlHigh];
                                                }else{
                                                    
                                                    if ([stepArray[19] isEqualToString:@"1"]) {
                                                        
                                                        
                                                        self.prompttitle.text = @"一线通语音";
                                                        [self oneLineSpeechOpen];
                                                        
                                                    }else{
                                                    
                                                        if ([stepArray[20] isEqualToString:@"1"]) {
                                                            self.prompttitle.text = @"指纹测试";
                                                            [self fingerPrintTest];
                                                            
                                                        }else{
                                                            
                                                            if ([stepArray[21] isEqualToString:@"1"]) {
                                                                
                                                                [self firmwareUpdate];
                                                                
                                                            }else{
                                                                
                                                                [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                                [self testend];
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
              }
            }
            
        }
        
    }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4002"]) {
        
        [self keytips];
        
        NSString *uniquecode = [date substringWithRange:NSMakeRange(12, 7)];
        self.keycode = uniquecode;//钥匙码
        
        
        if(![keycodeDic objectForKey:uniquecode]){
            [countTimer invalidate];
            countTimer = nil;
            self.countdown.hidden = YES;
            [keycodeDic setObject:uniquecode forKey:uniquecode];
            NSString *outHEX = @"A5000007400200";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:outHEX]];
            keynumber++;
        }else{
            
            [SVProgressHUD showSimpleText:@"钥匙重复,请换钥匙"];
            NSString *passwordHEX = @"A5000007400201";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
            return;
        }
        
        if ([stepArray[4] isEqualToString:@"2"]) {
            
            if (keynumber <= 2) {
                
                if (keynumber == 2) {
                    self.prompttitle2.text = @"钥匙配置完成";
                    
                }
                NSString *key1;
                NSString *key2;
                NSString *key3;
                NSString *key4;
                
                if ([stepArray[5] isEqualToString:@"1号按键"]) {
                    
                    key1 = [NSString stringWithFormat:@"%@1",uniquecode];
                }else if ([stepArray[5] isEqualToString:@"2号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@2",uniquecode];
                    
                }else if ([stepArray[5] isEqualToString:@"3号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@4",uniquecode];
                    
                }else if ([stepArray[5] isEqualToString:@"4号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@8",uniquecode];
                    
                }
                
                if ([stepArray[6] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                }else if ([stepArray[6] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                    
                }else if ([stepArray[6] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[6] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                if ([stepArray[7] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8 || self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                    
                }else if ([stepArray[7] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8 || self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                }else if ([stepArray[7] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8 || self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[7] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8 || self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                if ([stepArray[8] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                //A500001740030000A1196100A1196200A1196400A11968
                
                NSString *passwordHEX = [NSString stringWithFormat:@"A500001740030%d%@%@%@%@",(int)keynumber-1,key1,key2,key3,key4];
                
                [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
            }else{
//                self.prompttitle2.text = @"钥匙配置完成";
//                NSString *title = @"第二把钥匙配置完成";
//                [self.promteArray addObject:title];
//                
//                //主线程
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    [self.resulttable reloadData];
//                });
            }
        }else{
            if (keynumber == 1) {
                
                NSString *key1;
                NSString *key2;
                NSString *key3;
                NSString *key4;
                if ([stepArray[5] isEqualToString:@"1号按键"]) {
                    
                    key1 = [NSString stringWithFormat:@"%@1",uniquecode];
                }else if ([stepArray[5] isEqualToString:@"2号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@2",uniquecode];
                    
                }else if ([stepArray[5] isEqualToString:@"3号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@4",uniquecode];
                    
                }else if ([stepArray[5] isEqualToString:@"4号按键"]){
                    
                    key1 = [NSString stringWithFormat:@"%@8",uniquecode];
                    
                }
                
                if ([stepArray[6] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                }else if ([stepArray[6] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                    
                }else if ([stepArray[6] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[6] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 7) {
                        key2 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else{
                        key2 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                if ([stepArray[7] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8 || self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                    
                }else if ([stepArray[7] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8|| self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                }else if ([stepArray[7] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8|| self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[7] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 7 || self.keyType == 8|| self.keyType == 9) {
                        key3 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key3 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                if ([stepArray[8] isEqualToString:@"1号按键"]) {
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@1",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"2号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@2",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"3号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@4",uniquecode];
                    }
                    
                }else if ([stepArray[8] isEqualToString:@"4号按键"]){
                    
                    if (self.keyType == 3 || self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 7) {
                        key4 = [NSString stringWithFormat:@"%@0",uniquecode];
                    }else {
                        key4 = [NSString stringWithFormat:@"%@8",uniquecode];
                    }
                    
                }
                
                NSString *passwordHEX = [NSString stringWithFormat:@"A500001740030%d%@%@%@%@",(int)keynumber-1,key1,key2,key3,key4];
                [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
                
            }
        }
        
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4003"]) {
        
        if ([stepArray[4] isEqualToString:@"2"]) {
        
            NSString *title = [NSString stringWithFormat:@"第%d把钥匙配置完成",(int)keynumber];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });
            
            if (keynumber<2) {
                self.prompttitle.text = [NSString stringWithFormat:@"第%d把钥匙配置",(int)keynumber+1];
                
                self.countdown.hidden = NO;
                [self keypair];
                
            }else if(keynumber == 2){
                
                keynumber = 0;
                //******************************************//
                
                    if ([stepArray[2] isEqualToString:@"1"]) {
                        
                        self.prompttitle.text = @"钥匙1测试";
                        [self keyTest];
                        
                    }else{
                        
                        if ([stepArray[3] intValue] >0 ) {
                            
                            [self inductionkeyTest];
                            
                        }else{
                            
                            if ([stepArray[9] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"常规测试";
                                [self nomalTest];
                            }else{
                                
                                if ([stepArray[10] isEqualToString:@"单线测试"]){
                                    
//                                    lineNumber = 8;
//                                    linetype = 2;
                                    self.prompttitle.text = @"单线测试";
                                    [self roudTest];
                                    
                                }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                                    
//                                    lineNumber = 8;
//                                    linetype = 2;
                                    self.prompttitle.text = @"双线测试";
                                    [self roudTest];
                                    
                                }else{
                                    
                                    if ([stepArray[11] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"震动察觉测试";
                                        [self vibrationdetection];
                                    }else{
                                        
                                        if ([stepArray[12] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"蜂鸣器测试";
                                            [self buzzerTest];
                                        }else{
                                            
                                            if ([stepArray[13] isEqualToString:@"1"]) {
                                                
                                                self.prompttitle.text = @"一键启动测试";
                                                [self onekeystart];
                                            }else{
                                                
                                                if ([stepArray[14] isEqualToString:@"1"]) {
                                                    
                                                    self.prompttitle.text = @"坐桶测试";
                                                    [self seatTest];
                                                }else{
                                                    
                                                    if ([stepArray[15] isEqualToString:@"1"]) {
                                                        
                                                        self.prompttitle.text = @"龙头锁测试";
                                                        [self lockTest];
                                                    }else{
                                                        
                                                        if ([stepArray[16] isEqualToString:@"1"]) {
                                                            
                                                            self.prompttitle.text = @"参数校准";
                                                            [self calibrationTest];
                                                        }else{
                                                            if ([stepArray[18] isEqualToString:@"1"]) {
                                                                
                                                                
                                                                
                                                                self.prompttitle.text = @"一键通线路控制";
                                                                [self oneClickControlHigh];
                                                                
                                                            }else{
                                                                
                                                                if ([stepArray[19] isEqualToString:@"1"]) {
                                                                    
                                                                    
                                                                    self.prompttitle.text = @"一线通语音";
                                                                    [self oneLineSpeechClose];
                                                                    
                                                                }else{
                                                                    
                                                                    if ([stepArray[20] isEqualToString:@"1"]) {
                                                                        self.prompttitle.text = @"指纹测试";
                                                                        [self fingerPrintTest];
                                                                        
                                                                    }else{
                                                                        
                                                                        if ([stepArray[21] isEqualToString:@"1"]) {
                                                                            
                                                                            [self firmwareUpdate];
                                                                            
                                                                        }else{
                                                                            
                                                                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                                            [self testend];
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                
                //*******************************************//
            }
            
        }else if([stepArray[4] isEqualToString:@"1"]){
        
            NSString *title = [NSString stringWithFormat:@"第%d把钥匙配置完成",(int)keynumber];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });
            
            if (keynumber<1) {
                self.prompttitle.text = [NSString stringWithFormat:@"第%d把钥匙配置",(int)keynumber+1];
                self.prompttitle2.text = @"请按键";
                self.countdown.hidden = NO;
                [self keyTest];
            }else if(keynumber == 1){
                
                keynumber = 0;
                
                if ([stepArray[2] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"钥匙1测试";
                    [self keyTest];
                    self.countdown.hidden = NO;
                }else{
                    
                    if ([stepArray[3] intValue] >0 ) {
                        
                        [self inductionkeyTest];
                        
                    }else{
                        
                        if ([stepArray[9] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"常规测试";
                            [self nomalTest];
                        }else{
                            
                            if ([stepArray[10] isEqualToString:@"单线测试"]){
                                
//                                lineNumber = 8;
//                                linetype = 2;
                                self.prompttitle.text = @"单线测试";
                                [self roudTest];
                                
                            }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                                
//                                lineNumber = 8;
//                                linetype = 2;
                                self.prompttitle.text = @"双线测试";
                                [self roudTest];
                                
                            }else{
                                
                                if ([stepArray[11] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"震动察觉测试";
                                    [self vibrationdetection];
                                }else{
                                    
                                    if ([stepArray[12] isEqualToString:@"1"]) {
                                        self.prompttitle.text = @"蜂鸣器测试";
                                        [self buzzerTest];
                                    }else{
                                        
                                        if ([stepArray[13] isEqualToString:@"1"]) {
                                            self.prompttitle.text = @"一键启动测试";
                                            [self onekeystart];
                                        }else{
                                            
                                            if ([stepArray[14] isEqualToString:@"1"]) {
                                                
                                                self.prompttitle.text = @"坐桶测试";
                                                [self seatTest];
                                            }else{
                                                
                                                if ([stepArray[15] isEqualToString:@"1"]) {
                                                    
                                                    self.prompttitle.text = @"龙头锁测试";
                                                    [self lockTest];
                                                }else{
                                                    
                                                    if ([stepArray[16] isEqualToString:@"1"]) {
                                                        
                                                        self.prompttitle.text = @"参数校准";
                                                        [self calibrationTest];
                                                    }else{
                                                        
                                                        if ([stepArray[18] isEqualToString:@"1"]) {
                                                            
                                                            
                                                            self.prompttitle.text = @"一键通线路控制";
                                                            [self oneClickControlHigh];
                                                            
                                                        }else{
                                                            
                                                            if ([stepArray[19] isEqualToString:@"1"]) {
                                                                
                                                                
                                                                self.prompttitle.text = @"一线通语音";
                                                                [self oneLineSpeechOpen];
                                                                
                                                            }else{
                                                                
                                                                if ([stepArray[20] isEqualToString:@"1"]) {
                                                                    self.prompttitle.text = @"指纹测试";
                                                                    [self fingerPrintTest];
                                                                    
                                                                }else{
                                                                    
                                                                    if ([stepArray[21] isEqualToString:@"1"]) {
                                                                        
                                                                        [self firmwareUpdate];
                                                                        
                                                                    }else{
                                                                        
                                                                        [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                                        [self testend];
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
        
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4004"]) {
        
        NSInteger testkey;
        
        if ([stepArray[4] isEqualToString:@"1"]) {
        
            testkey = 1;
        
        }else if ([stepArray[4] isEqualToString:@"2"]) {
        
            testkey = 2;
        }
        
        if(keynumber == testkey){
            return;
        }
        
        [self keytips];
        
        if(self.keyType == 0 || self.keyType == 1 || self.keyType == 2){
        
            if (bindingtime == 0) {
                
                self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                bindingtime ++;
                keytitle1 = date;
                timeNumber = 11;
                
            }else if (bindingtime == 1){
                
                if ([keytitle1 isEqualToString:date]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    keytitle2 = date;
                    bindingtime ++;
                    timeNumber = 11;
                }
                
                
                
            }else if (bindingtime == 2){
                
                if ([keytitle1 isEqualToString:date] || [keytitle2 isEqualToString:date]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    
                    keytitle3 = date;
                    bindingtime ++;
                    timeNumber = 11;
                    
                }
                
                
            }else if (bindingtime == 3){
                
                if ([keytitle1 isEqualToString:date] || [keytitle2 isEqualToString:date] || [keytitle3 isEqualToString:date]) {
                    
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    
                    keynumber ++;
                    NSString *title = [NSString stringWithFormat:@"第%d把钥匙测试完成",(int)keynumber];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    NSString *passwordHEX = @"A5000007400400";
                    //[appDelegate.device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                    keytitle4 = date;
                    bindingtime ++;
                    timeNumber = 11;
                    
                    if (keynumber < testkey) {
                        
                        /**
                         *  /////////////////////////////////////////////////
                         */
                        [self beganKeytest];
                        
                        self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                        
                        keytitle1 = nil;
                        keytitle2 = nil;
                        keytitle3 = nil;
                        keytitle4 = nil;
                        bindingtime = 0;
                        
                    }else{
                        
                        [countTimer invalidate];
                        countTimer = nil;
                        self.countdown.hidden = YES;
                        
                        NSString *passwordHEX = @"A5000007400400";
                        //[appDelegate.device sendHexstring:passwordHEX];
                        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                        
                        
                        if ([stepArray[3] intValue] >0) {
                            
                            [self inductionkeyTest];
                            
                        }else{
                            
                            [self nexTest];
                            
                        }
                        
                    }
                }
                
            }
        
        }else if (self.keyType == 4 || self.keyType == 5 || self.keyType == 6 || self.keyType == 8 || self.keyType == 9){
        
            if (bindingtime == 0) {
                
                self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                bindingtime ++;
                keytitle1 = date;
                timeNumber = 11;
                
            }else if (bindingtime == 1){
                
                if ([keytitle1 isEqualToString:date]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    keytitle2 = date;
                    bindingtime ++;
                    timeNumber = 11;
                }
                
                
                
            }else{
                
                if ([keytitle1 isEqualToString:date] || [keytitle2 isEqualToString:date]) {
                    
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    
                    keynumber ++;
                    NSString *title = [NSString stringWithFormat:@"第%d把钥匙测试完成",(int)keynumber];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    NSString *passwordHEX = @"A5000007400400";
                    //[appDelegate.device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                    keytitle3 = date;
                    bindingtime ++;
                    timeNumber = 11;
                    if (keynumber < testkey) {
                        
                        /**
                         *  /////////////////////////////////////////////////
                         */
                        [self beganKeytest];
                        
                        self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                        
                        keytitle1 = nil;
                        keytitle2 = nil;
                        keytitle3 = nil;
                        keytitle4 = nil;
                        bindingtime = 0;
                        
                    }else{
                        
                        [countTimer invalidate];
                        countTimer = nil;
                        self.countdown.hidden = YES;
                        
                        NSString *passwordHEX = @"A5000007400400";
                        //[appDelegate.device sendHexstring:passwordHEX];
                        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                        
                        
                        if ([stepArray[3] intValue] >0) {
                            
                            [self inductionkeyTest];
                            
                        }else{
                            
                            [self nexTest];
                            
                        }
                        
                    }
                }
                
            }
        
        }else if (self.keyType == 3){
        
            if (bindingtime == 0) {
                
                self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                bindingtime ++;
                keytitle1 = date;
                timeNumber = 11;
                
            }else{
                
                if ([keytitle1 isEqualToString:date]) {
                    
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                }else{
                    
                    keynumber ++;
                    NSString *title = [NSString stringWithFormat:@"第%d把钥匙测试完成",(int)keynumber];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    NSString *passwordHEX = @"A5000007400400";
                    //[appDelegate.device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                    keytitle2 = date;
                    bindingtime ++;
                    timeNumber = 11;
                    if (keynumber < testkey) {
                        
                        /**
                         *  /////////////////////////////////////////////////
                         */
                        [self beganKeytest];
                        
                        self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                        
                        keytitle1 = nil;
                        keytitle2 = nil;
                        keytitle3 = nil;
                        keytitle4 = nil;
                        bindingtime = 0;
                        
                    }else{
                        
                        [countTimer invalidate];
                        countTimer = nil;
                        self.countdown.hidden = YES;
                        
                        NSString *passwordHEX = @"A5000007400400";
                        //[appDelegate.device sendHexstring:passwordHEX];
                        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                        
                        
                        if ([stepArray[3] intValue] >0) {
                            
                            [self inductionkeyTest];
                            
                        }else{
                            
                            [self nexTest];
                            
                        }
                        
                    }
                }
                
            }
        
        }else if(self.keyType == 7){
            
            if (bindingtime == 0) {
                
                self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                bindingtime ++;
                keytitle1 = date;
                timeNumber = 11;
                
                keynumber ++;
                NSString *title = [NSString stringWithFormat:@"第%d把钥匙测试完成",(int)keynumber];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                NSString *passwordHEX = @"A5000007400400";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
                keytitle1 = date;
                bindingtime ++;
                timeNumber = 11;
                
                if (keynumber < testkey) {
                    
                    [self beganKeytest];
                    self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                    keytitle1 = nil;
                    keytitle2 = nil;
                    keytitle3 = nil;
                    keytitle4 = nil;
                    bindingtime = 0;
                    
                }else{
                    
                    [countTimer invalidate];
                    countTimer = nil;
                    self.countdown.hidden = YES;
                    
                    NSString *passwordHEX = @"A5000007400400";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                    if ([stepArray[3] intValue] >0) {
                        
                        [self inductionkeyTest];
                        
                    }else{
                        
                        [self nexTest];
                        
                    }
                    
                }
            
        }
            
    }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4005"]) {
    
        if (lineNumber == 0) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                NSString *title = [NSString stringWithFormat:@"报警器电门线高电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                timeNumber = 1;
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                lineNumber++;
                NSString *title = [NSString stringWithFormat:@"报警器电门线高电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
            
                
                
                [self queryBoxLevel];
                
            }
            
        }else if (lineNumber == 2){
            
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                lineNumber++;
                NSString *title = [NSString stringWithFormat:@"报警器电门线低电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                
                [self queryBoxLevel];
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                NSString *title = [NSString stringWithFormat:@"报警器电门线低电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
            }
            
        }else if (lineNumber == 6){
        
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                NSString *title = [NSString stringWithFormat:@"报警器转动线高电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                lineNumber++;
                NSString *title = [NSString stringWithFormat:@"报警器转动线高电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                NSString *passwordHEX = @"A500000810020100";
                [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                [self delayfunction];
                
            }
        
        }else if (lineNumber == 7){
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                lineNumber++;
                linetype  = 2;
                NSString *title = [NSString stringWithFormat:@"报警器转动线低电平输出成功"];
                [self.promteArray addObject:title];
                
                NSString *title2 = [NSString stringWithFormat:@"转动线测试成功"];//要加判断,单线双线
                [self.promteArray addObject:title2];
                
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                [countTimer invalidate];
                countTimer = nil;
                
                if ([stepArray[10] isEqualToString:@"单线测试"] || [stepArray[10] isEqualToString:@"双线测试"]) {
                    
                    if ([stepArray[10] isEqualToString:@"单线测试"]) {
                        self.prompttitle.text = @"单线测试";
                    }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                        self.prompttitle.text = @"双线测试";
                    }
                    [self roudTest];
                    
                    
                }else {
                    
                    if ([stepArray[11] isEqualToString:@"1"]) {
                        
                        self.prompttitle.text = @"震动察觉测试";
                        [self vibrationdetection];
                        
                    }else{
                        
                        if ([stepArray[12] isEqualToString:@"1"]) {
                           
                            self.prompttitle.text = @"蜂鸣器测试";
                            [self buzzerTest];
                            
                        }else{
                            
                            if ([stepArray[13] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"一键启动测试";
                                [self onekeystart];
                                
                                
                            }else{
                                
                                if ([stepArray[14] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"坐桶测试";
                                    [self seatTest];
                                    
                                }else{
                                    
                                    if ([stepArray[15] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"龙头锁测试";
                                        [self lockTest];
                                        
                                    }else{
                                        
                                        if ([stepArray[16] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"参数校准";
                                            
                                            [self calibrationTest];
                                            
                                        }else{
                                            if ([stepArray[18] isEqualToString:@"1"]) {
        
                                                
                                                self.prompttitle.text = @"一键通线路控制";
                                                [self oneClickControlHigh];
                                                
                                            }else{
                                                
                                                if ([stepArray[19] isEqualToString:@"1"]) {
                                                    
                                                
                                                    self.prompttitle.text = @"一线通语音";
                                                    [self oneLineSpeechOpen];
                                                    
                                                }else{
                                                    
                                                    if ([stepArray[20] isEqualToString:@"1"]) {
                                                        self.prompttitle.text = @"指纹测试";
                                                        [self fingerPrintTest];
                                                        
                                                    }else{
                                                        
                                                        if ([stepArray[21] isEqualToString:@"1"]) {
                                                            
                                                            [self firmwareUpdate];
                                                            
                                                        }else{
                                                            
                                                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                            [self testend];
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                NSString *title = [NSString stringWithFormat:@"报警器通讯线低电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
               timeNumber = 1;
            }
            
        }else if (lineNumber == 8){
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                NSString *title = [NSString stringWithFormat:@"报警器通讯线高电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                lineNumber++;
                
                NSString *title = [NSString stringWithFormat:@"报警器通讯线高电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                NSString *passwordHEX = @"A500000810020200";
                [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
                [self delayfunction];
            }
            
        }else if (lineNumber == 9){
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                lineNumber++;
                NSString *title = [NSString stringWithFormat:@"报警器通讯线低电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                if ([stepArray[10] isEqualToString:@"单线测试"]) {
                    
                    [countTimer invalidate];
                    countTimer = nil;
                    NSString *title = [NSString stringWithFormat:@"单线测试成功"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    if ([stepArray[11] isEqualToString:@"1"]) {
                        
                        
                        self.prompttitle.text = @"震动察觉测试";
                        [self vibrationdetection];
                        
                    }else{
                        
                        if ([stepArray[12] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"蜂鸣器测试";
                            [self buzzerTest];
                            
                        }else{
                            
                            if ([stepArray[13] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"一键启动测试测试";
                                [self onekeystart];
                                
                            }else{
                                
                                if ([stepArray[14] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"坐桶测试";
                                    [self seatTest];
                                    
                                }else{
                                    
                                    if ([stepArray[15] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"龙头锁测试";
                                        [self lockTest];
                                        
                                    }else{
                                        
                                        if ([stepArray[16] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"参数校准";
                                            [self calibrationTest];
                                            
                                        }else{
                                            
                                            if ([stepArray[18] isEqualToString:@"1"]) {
                                                
                                                
                                                self.prompttitle.text = @"一键通线路控制";
                                                [self oneClickControlHigh];
                                                
                                            }else{
                                                
                                                if ([stepArray[19] isEqualToString:@"1"]) {
                                                    
                                                    
                                                    self.prompttitle.text = @"一线通语音";
                                                    [self oneLineSpeechOpen];
                                                    
                                                }else{
                                                    
                                                    if ([stepArray[20] isEqualToString:@"1"]) {
                                                        self.prompttitle.text = @"指纹测试";
                                                        [self fingerPrintTest];
                                                        
                                                    }else{
                                                        
                                                        if ([stepArray[21] isEqualToString:@"1"]) {
                                                            
                                                            [self firmwareUpdate];
                                                            
                                                        }else{
                                                            
                                                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                            [self testend];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                    
                    NSString *passwordHEX = @"A500000840060301";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    [self delayBoxFunction];
                
                }
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                NSString *title = [NSString stringWithFormat:@"报警器通讯线低电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                
                timeNumber = 1;
            }
            
        }else if (lineNumber == 12){
        
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]) {
                
                [self oneClickCheckLow];
            
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]){
            
                NSString *title = [NSString stringWithFormat:@"报警器一键通高电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
            }
            
        }else if (lineNumber == 13){
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]) {
                
                NSString *title = [NSString stringWithFormat:@"报警器一键通低电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]){
                
                [countTimer invalidate];
                countTimer = nil;
                    if ([stepArray[19] isEqualToString:@"1"]) {
                        
                        
                        self.prompttitle.text = @"一线通语音";
                        [self oneLineSpeechOpen];
                        
                    }else{
                        
                        if ([stepArray[20] isEqualToString:@"1"]) {
                            self.prompttitle.text = @"指纹测试";
                            [self fingerPrintTest];
                            
                        }else{
                            
                            if ([stepArray[21] isEqualToString:@"1"]) {
                                
                                [self firmwareUpdate];
                                
                            }else{
                                
                                [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                [self testend];
                            }
                        }
                    }
            }
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4009"]) {
        
        [countTimer invalidate];
        countTimer = nil;
        
        NSString *title = @"一键测试成功";
        [self.promteArray addObject:title];
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        NSString *passwordHEX = @"A5000007400900";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        
        if ([stepArray[14] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"坐桶测试";
            
            [self seatTest];
            
            
        }else{
            
            if ([stepArray[15] isEqualToString:@"1"]) {
               
                self.prompttitle.text = @"龙头锁测试";
                [self lockTest];
                
            }else{
                
                if ([stepArray[16] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"参数校准";
                    [self calibrationTest];
                }else{
                    
                    if ([stepArray[18] isEqualToString:@"1"]) {
                        
                        
                        self.prompttitle.text = @"一键通线路控制";
                        [self oneClickControlHigh];
                        
                    }else{
                        
                        if ([stepArray[19] isEqualToString:@"1"]) {
                            
                            
                            self.prompttitle.text = @"一线通语音";
                            [self oneLineSpeechOpen];
                            
                            
                        }else{
                            
                            if ([stepArray[20] isEqualToString:@"1"]) {
                                self.prompttitle.text = @"指纹测试";
                                [self fingerPrintTest];
                                
                            }else{
                                
                                if ([stepArray[21] isEqualToString:@"1"]) {
                                    
                                    [self firmwareUpdate];
                                    
                                }else{
                                    
                                    [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                    [self testend];
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"400C"]) {
    
        [countTimer invalidate];
        countTimer = nil;
        
         if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            self.prompttitle.text = @"参数校准成功";
            NSString *title = [NSString stringWithFormat:@"参数校准成功"];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });
             
             if ([stepArray[18] isEqualToString:@"1"]) {
                 
                 
                 self.prompttitle.text = @"一键通线路控制";
                 [self oneClickControlHigh];
                 
             }else{
                 
                 if ([stepArray[19] isEqualToString:@"1"]) {
                     
                     
                     self.prompttitle.text = @"一线通语音";
                     [self oneLineSpeechOpen];
                     
                     
                 }else{
                     
                     if ([stepArray[20] isEqualToString:@"1"]) {
                         self.prompttitle.text = @"指纹测试";
                         [self fingerPrintTest];
                         
                     }else{
                         
                         if ([stepArray[21] isEqualToString:@"1"]) {
                             
                             [self firmwareUpdate];
                             
                         }else{
                             
                             [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                             [self testend];
                         }
                     }
                 }
             }

            
         }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]){
         
             self.prompttitle.text = @"参数校准失败";
             
             NSString *title = [NSString stringWithFormat:@"参数校准失败"];
             [self.promteArray addObject:title];
             //主线程uitableview刷新
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.resulttable reloadData];
             });
         timeNumber = 1;
         }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"4007"]){
        [countTimer invalidate];
        countTimer = nil;
        NSString *title = [NSString stringWithFormat:@"震动察觉测试成功"];
        [self.promteArray addObject:title];
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        if ([stepArray[12] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"蜂鸣器测试";
            [self buzzerTest];
            
        }else{
            
            if ([stepArray[13] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"一键启动测试";
                [self onekeystart];
                
            }else{
                
                if ([stepArray[14] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"坐桶测试";
                    [self seatTest];
                    
                }else{
                    
                    if ([stepArray[15] isEqualToString:@"1"]) {
                       
                        self.prompttitle.text = @"龙头锁测试";
                        [self lockTest];
                        
                    }else{
                        
                        if ([stepArray[16] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"参数校准";
                            [self calibrationTest];
                            
                        }else{
                            if ([stepArray[18] isEqualToString:@"1"]) {
                                
                                
                                self.prompttitle.text = @"一键通线路控制";
                                [self oneClickControlHigh];
                                
                            }else{
                                
                                if ([stepArray[19] isEqualToString:@"1"]) {
                                    
                                    
                                    self.prompttitle.text = @"一线通语音";
                                    [self oneLineSpeechOpen];
                                    
                                    
                                }else{
                                    
                                    if ([stepArray[20] isEqualToString:@"1"]) {
                                        self.prompttitle.text = @"指纹测试";
                                        [self fingerPrintTest];
                                        
                                    }else{
                                        
                                        if ([stepArray[21] isEqualToString:@"1"]) {
                                            
                                            [self firmwareUpdate];
                                            
                                        }else{
                                            
                                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                            [self testend];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"400D"]){
        
        if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"400D01"]) {
            induckey ++;
            [countTimer invalidate];
            countTimer = nil;
            self.countdown.hidden = YES;
            testing = NO;//感应钥匙配置成功判断bool
            
            NSString *title = [NSString stringWithFormat:@"感应钥匙%d配置成功",(int)induckey];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
                
            });
            
            if (induckey < [stepArray[3] intValue]) {
                
                [self inductionkeyTest];
                
            }else{
                
                if ([stepArray[9] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"常规测试";
                    [self nomalTest];
                }else{
                    
                    if ([stepArray[10] isEqualToString:@"单线测试"]){
                        
                        lineNumber = 8;
                        linetype = 2;
                        self.prompttitle.text = @"单线测试";
                        [self roudTest];
                        
                    }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                        
                        lineNumber = 8;
                        linetype = 2;
                        self.prompttitle.text = @"双线测试";
                        [self roudTest];
                        
                    }else{
                        
                        if ([stepArray[11] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"震动察觉测试";
                            [self vibrationdetection];
                        }else{
                            
                            if ([stepArray[12] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"蜂鸣器测试";
                                [self buzzerTest];
                            }else{
                                
                                if ([stepArray[13] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"一键启动测试";
                                    [self onekeystart];
                                }else{
                                    
                                    if ([stepArray[14] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"坐桶测试";
                                        [self seatTest];
                                    }else{
                                        
                                        if ([stepArray[15] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"龙头锁测试";
                                            [self lockTest];
                                        }else{
                                            
                                            if ([stepArray[16] isEqualToString:@"1"]) {
                                                
                                                self.prompttitle.text = @"参数校准";
                                                [self calibrationTest];
                                            }else{
                                                
                                                if ([stepArray[18] isEqualToString:@"1"]) {
                                                    
                                                    
                                                    self.prompttitle.text = @"一键通线路控制";
                                                    [self oneClickControlHigh];
                                                    
                                                }else{
                                                    
                                                    if ([stepArray[19] isEqualToString:@"1"]) {
                                                        
                                                        
                                                        self.prompttitle.text = @"一线通语音";
                                                        [self oneLineSpeechOpen];
                                                        
                                                        
                                                    }else{
                                                        
                                                        if ([stepArray[20] isEqualToString:@"1"]) {
                                                            self.prompttitle.text = @"指纹测试";
                                                            [self fingerPrintTest];
                                                            
                                                        }else{
                                                            
                                                            if ([stepArray[21] isEqualToString:@"1"]) {
                                                                
                                                                [self firmwareUpdate];
                                                                
                                                            }else{
                                                                
                                                                [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                                [self testend];
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        }else if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"400D00"]){
        
            NSString *title = [NSString stringWithFormat:@"感应钥匙%d配置失败",(int)induckey+1];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });
            //self.prompttitle.text = [NSString stringWithFormat:@"感应钥匙%d配置失败",induckey+1];
            timeNumber = 1;
            [self coutdowntime];
           
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"400E"]){//钥匙类型查询命令回复
    
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            
            [SVProgressHUD showSimpleText:@"钥匙类型配置失败"];
            [self testend];
        
        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]) {
        
            [self keypair];
        }
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1004"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            
            [SVProgressHUD showSimpleText:@"进入固件升级失败"];
            [self testend];
        }else if([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
            [[AppDelegate currentAppDelegate].device remove];
            self.backWindow.hidden = NO;
            [self performSelector:@selector(breakconnect) withObject:nil afterDelay:2];
        }
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            
            NSString *title = [NSString stringWithFormat:@"指纹测试失败"];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });
            timeNumber = 1;
            
        }else if([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
            //[countTimer invalidate];
            //countTimer = nil;
            timeNumber = 10;
            self.backView.hidden = NO;
            
        }
    }

    }else if (tag.intValue == 2){/////////////////////////////////设备盒子
    
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
            if (lineNumber == 1) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                NSString *title = [NSString stringWithFormat:@"盒子电门线高电平输出失败"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 1;
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                lineNumber++;
                NSString *title = [NSString stringWithFormat:@"盒子电门线高电平输出成功"];
                [self.promteArray addObject:title];
                //主线程uitableview刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.resulttable reloadData];
                });
                timeNumber = 11;
                NSString *passwordHEX = @"A500000840060100";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                [self delayfunction];
                }
        
            }else if (lineNumber == 3){
                
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    lineNumber++;
                    linetype ++;
                    NSString *title = [NSString stringWithFormat:@"盒子电门线低电平输出成功"];
                    [self.promteArray addObject:title];
                    
                    NSString *title2 = [NSString stringWithFormat:@"电门线测试完成"];
                    [self.promteArray addObject:title2];
                    
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    NSString *passwordHEX = @"A500000840060201";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    [self delayBoxFunction];
                    
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    
                    NSString *title = [NSString stringWithFormat:@"盒子电门线低电平输出失败"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    timeNumber = 1;
                }
            
            }else if (lineNumber == 4){
                
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    
                    NSString *title = [NSString stringWithFormat:@"盒子锁车线高电平输出失败"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    timeNumber = 1;
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    lineNumber++;
                    NSString *title = [NSString stringWithFormat:@"盒子锁车线高电平输出成功"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    
                    NSString *passwordHEX = @"A500000840060200";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    [self delayBoxFunction];
                    
                }
                
                
            }else if (lineNumber == 5){
                
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    lineNumber++;
                    
                    NSString *title = [NSString stringWithFormat:@"盒子锁车线低电平输出成功"];
                    [self.promteArray addObject:title];
                    
                    NSString *title2 = [NSString stringWithFormat:@"锁车线测试成功"];
                    [self.promteArray addObject:title2];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    /**
                     *  单双线检测及后面流程//需要加判断
                     */
                    
                    NSString *passwordHEX = @"A500000810020101";
                    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    [self delayfunction];
                    
                    
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    
                    NSString *title = [NSString stringWithFormat:@"盒子锁车线低电平输出失败"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    timeNumber = 1;
                }
                
            }else if (lineNumber == 10){
            
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    
                    NSString *title = [NSString stringWithFormat:@"盒子通讯线高电平输出失败"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    timeNumber = 1;
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    
                    lineNumber++;
                    NSString *title = [NSString stringWithFormat:@"盒子通讯线高电平输出成功"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    NSString *passwordHEX = @"A500000840060300";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    [self delayBoxFunction];
                    
                }
                
            }else if (lineNumber == 11){
                
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    lineNumber++;
                    NSString *title = [NSString stringWithFormat:@"盒子通讯线低电平输出成功"];
                    [self.promteArray addObject:title];
                    
                    NSString *title2 = [NSString stringWithFormat:@"双线测试成功"];
                    [self.promteArray addObject:title2];
                    
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    [countTimer invalidate];
                    countTimer = nil;
                    
                    if ([stepArray[11] isEqualToString:@"1"]) {
                        
                        self.prompttitle.text = @"震动察觉测试";
                        [self vibrationdetection];
                        
                    }else{
                        
                        if ([stepArray[12] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"蜂鸣器测试";
                            [self buzzerTest];
                        }else{
                            
                            if ([stepArray[13] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"一键启动测试";
                                
                                [self onekeystart];
                                
                            }else{
                                
                                if ([stepArray[14] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"坐桶测试";
                                    [self seatTest];
                                    
                                }else{
                                    
                                    if ([stepArray[15] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"龙头锁测试";
                                        [self lockTest];
                                        
                                    }else{
                                        
                                        if ([stepArray[16] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"参数校准";
                                            [self calibrationTest];
                                        }else{
                                            
                                            if ([stepArray[18] isEqualToString:@"1"]) {
                                                
                                                
                                                self.prompttitle.text = @"一键通线路控制";
                                                [self oneClickControlHigh];
                                                
                                            }else{
                                                
                                                if ([stepArray[19] isEqualToString:@"1"]) {
                                                    
                                                    
                                                    self.prompttitle.text = @"一线通语音";
                                                    [self oneLineSpeechOpen];
                                                    
                                                    
                                                    
                                                }else{
                                                    
                                                    if ([stepArray[20] isEqualToString:@"1"]) {
                                                        self.prompttitle.text = @"指纹测试";
                                                        [self fingerPrintTest];
                                                        
                                                    }else{
                                                        
                                                        if ([stepArray[21] isEqualToString:@"1"]) {
                                                            
                                                            [self firmwareUpdate];
                                                            
                                                        }else{
                                                            
                                                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                                            [self testend];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }

                    
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    
                    NSString *title = [NSString stringWithFormat:@"盒子通讯线低电平输出失败"];
                    [self.promteArray addObject:title];
                    //主线程uitableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.resulttable reloadData];
                    });
                    
                    timeNumber = 1;
                }
                
            }
        }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1003"]) {
            [countTimer invalidate];
            countTimer = nil;
            NSString *parameter = [date substringWithRange:NSMakeRange(12, 8)];
            
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000A400C%@",parameter];//@"A5000007400C01";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
            
        }
    }
    
}

//主动断开连接
- (void)breakconnect{
    
    [[AppDelegate currentAppDelegate].device startScan2];
    
}

/**
 *  自定义的 alertView
 */
- (void)setupAlertView{
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [self.view addSubview:backView];
    self.backView = backView;
    
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(20, ScreenHeight/2 - 70, ScreenWidth - 40, 140)];
    alertView.backgroundColor =  [UIColor whiteColor];
    [backView addSubview:alertView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, alertView.width, 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"提示";
    nameLabel.font = [UIFont systemFontOfSize:15];
    [alertView addSubview:nameLabel];
    
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame) + 30, alertView.width, 20)];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"确认后请点击(10s)";
    messageLabel.font = [UIFont systemFontOfSize:15];
    [alertView addSubview:messageLabel];
    self.messageLabel = messageLabel;
    
    UIButton *sure = [[UIButton alloc] initWithFrame:CGRectMake(0, alertView.height - 50, alertView.width, 40)];
    [sure addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [alertView addSubview:sure];
    
    backView.hidden = YES;
}


/**
 **人工手动确定按钮
 **/

- (void)sureClick{
    
    if([self.prompttitle.text isEqualToString:@"坐桶测试"]){
        [countTimer invalidate];
        countTimer = nil;
        
        self.backView.hidden = YES;
        if ([stepArray[15] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"龙头锁测试";
            [self lockTest];
            
            NSString *title = [NSString stringWithFormat:@"坐桶测试成功"];
            [self.promteArray addObject:title];
            //主线程uitableview刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.resulttable reloadData];
            });

            
        }else{
            
            if ([stepArray[16 ] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"参数校准";
                [self calibrationTest];
                
            }else{
                
                
                
                if ([stepArray[18] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"一键通线路控制";
                    [self oneClickControlHigh];
                    
                }else{
                    
                    if ([stepArray[19] isEqualToString:@"1"]) {
                        
                        
                        self.prompttitle.text = @"一线通语音";
                        [self oneLineSpeechOpen];
                        
                    }else{
                        
                        if ([stepArray[20] isEqualToString:@"1"]) {
                            self.prompttitle.text = @"指纹测试";
                            [self fingerPrintTest];
                            
                        }else{
                            
                            if ([stepArray[21] isEqualToString:@"1"]) {
                                
                                [self firmwareUpdate];
                                
                            }else{
                                
                                [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                [self testend];
                            }
                        }
                    }
                }
            }
            
        }
        
    }else if ([self.prompttitle.text isEqualToString:@"龙头锁测试"]){
        [countTimer invalidate];
        countTimer = nil;
        self.backView.hidden = YES;
        
        NSString *title = [NSString stringWithFormat:@"龙头锁测试成功"];
        [self.promteArray addObject:title];
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        if ([stepArray[16] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"参数校准";
            [self calibrationTest];
            
        }else{
            
            if ([stepArray[18] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"一键通线路控制";
                [self oneClickControlHigh];
                
            }else{
                
                if ([stepArray[19] isEqualToString:@"1"]) {
                    
                    
                    self.prompttitle.text = @"一线通语音";
                    [self oneLineSpeechOpen];
                    
                    
                }else{
                    
                    if ([stepArray[20] isEqualToString:@"1"]) {
                        self.prompttitle.text = @"指纹测试";
                        [self fingerPrintTest];
                        
                    }else{
                        
                        if ([stepArray[21] isEqualToString:@"1"]) {
                            
                            [self firmwareUpdate];
                            
                        }else{
                            
                            [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                            [self testend];
                        }
                    }
                }
            }
        }
        
    }else if ([self.prompttitle.text isEqualToString:@"蜂鸣器测试"]){
        [countTimer invalidate];
        countTimer = nil;
        self.backView.hidden = YES;
        
        NSString *buzzerHEX = @"A5000007400800";//@"A5000007400C01";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:buzzerHEX]];
        
        NSString *title = [NSString stringWithFormat:@"蜂鸣器测试成功"];
        [self.promteArray addObject:title];
        
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        if ([stepArray[13] isEqualToString:@"1"]) {
            
            
            self.prompttitle.text = @"一键启动测试";
            [self onekeystart];
            
        }else{
            
            if ([stepArray[14] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"坐桶测试";
                [self seatTest];
                
            }else{
                
                if ([stepArray[15] isEqualToString:@"1"]) {
                   
                    self.prompttitle.text = @"龙头锁测试";
                    [self lockTest];
                    
                }else{
                    
                    if ([stepArray[16] isEqualToString:@"1"]) {
                       
                        self.prompttitle.text = @"参数校准";
                        [self calibrationTest];
                    }else{
                        
                        if ([stepArray[18] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"一键通线路控制";
                            [self oneClickControlHigh];
                            
                        }else{
                            
                            if ([stepArray[19] isEqualToString:@"1"]) {
                                self.prompttitle.text = @"一线通语音";
                                [self oneLineSpeechOpen];
                            }else{
                                if ([stepArray[20] isEqualToString:@"1"]) {
                                    self.prompttitle.text = @"指纹测试";
                                    [self fingerPrintTest];
                                    
                                }else{
                                    
                                    if ([stepArray[21] isEqualToString:@"1"]) {
                                        
                                        [self firmwareUpdate];
                                        
                                    }else{
                                        
                                        [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                                        [self testend];
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }else if ([self.prompttitle.text isEqualToString:@"一线通语音"]){
        [countTimer invalidate];
        countTimer = nil;
        
        self.backView.hidden = YES;
        NSString *title = [NSString stringWithFormat:@"一线通测试成功"];
        [self.promteArray addObject:title];
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        if ([stepArray[20] isEqualToString:@"1"]) {
            self.prompttitle.text = @"指纹测试";
            [self fingerPrintTest];
            
        }else{
            
            if ([stepArray[21] isEqualToString:@"1"]) {
                
                [self firmwareUpdate];
                
            }else{
                
                [SVProgressHUD showSimpleText:@"请先设置测试选项"];
                [self testend];
            }
        }
        
    }else if ([self.prompttitle.text isEqualToString:@"指纹测试"]){
        [countTimer invalidate];
        countTimer = nil;
        
        self.backView.hidden = YES;
        NSString *title = [NSString stringWithFormat:@"指纹测试成功"];
        [self.promteArray addObject:title];
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.resulttable reloadData];
        });
        
        if ([stepArray[21] isEqualToString:@"1"]) {
            
            [self firmwareUpdate];
            
        }else{
            [self testend];
        }
    }
}


//测试结束

- (void)testend{
    [countTimer invalidate];
    countTimer = nil;
    [self.promteArray removeAllObjects];
    [keycodeDic removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.resulttable reloadData];
        
    });
    self.firstview.hidden = NO;
    self.headView.backgroundColor = [UIColor blueColor];
    self.prompttitle.text = @"";
    self.prompttitle2.text = @"请按键";
    
    self.state = NO;
    testing = NO;
    if ([AppDelegate currentAppDelegate].device.isConnected) {
        NSString *passwordHEX = @"A5000007400100";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
    self.countdown.hidden = NO;
    self.countdown.text = @"10";
    timeNumber = 11;
    keynumber = 0;
    bindingtime = 0;
    lineNumber = 0;
    linetype = 0;
    induckey = 0;
    self.engineering = NO;
    //[self performSelector:@selector(removeconnect) withObject:nil afterDelay:1];//5秒后检测是否还是断线
}
////测试结束断开报警器
//-(void)removeconnect{
//    if ([appDelegate.device isConnected]) {
//        [appDelegate.device remove];
//    }
//    //[appDelegate.device startScan];
//    [self.table.mj_header beginRefreshing];
//}

-(void)coutdowntime{
    
    countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countFired:) userInfo:nil repeats:YES];
    
}

//计时器,进行倒计时确认
- (void)countFired:(NSTimer *)timer{

    timeNumber--;
    self.countdown.text = [NSString stringWithFormat:@"%d",(int)timeNumber];
    
    if([self.prompttitle.text isEqualToString:@"坐桶测试"] || [self.prompttitle.text isEqualToString:@"蜂鸣器测试"] || [self.prompttitle.text isEqualToString:@"龙头锁测试"]|| [self.prompttitle.text isEqualToString:@"一线通语音"]|| [self.prompttitle.text isEqualToString:@"指纹测试"]){
        self.messageLabel.text = [NSString stringWithFormat:@"确认点击(%ds)",(int)timeNumber];
    }
    
    if (timeNumber == 0) {
        
        [timer invalidate];
        timeNumber = 11;
        self.countdown.hidden = YES;
        
        if ([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"第%d把钥匙配置",(int)keynumber+1]]) {
        self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d配置失败",(int)keynumber+1];
        NSString *outHEX = @"A5000007400200";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:outHEX]];
        
        }else if ([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1]]){
            self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试失败",(int)keynumber+1];
            NSString *passwordHEX = @"A5000007400400";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else if ([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"感应钥匙%d配置",(int)induckey+1]]){
            
            self.prompttitle.text = [NSString stringWithFormat:@"感应钥匙%d配置失败",(int)induckey+1];
            
        }else if ([self.prompttitle.text isEqualToString:@"常规测试"]){
        
            self.prompttitle.text = @"常规测试失败";
            lineNumber = 0;
            
        }else if ([self.prompttitle.text isEqualToString:@"单线测试"]){
            
            self.prompttitle.text = @"单线测试失败";
            
        }else if ([self.prompttitle.text isEqualToString:@"双线测试"]){
            
            self.prompttitle.text = @"双线测试失败";
            
        }else if([self.prompttitle.text isEqualToString:@"一键启动测试"]){
            
            self.prompttitle.text = @"一键启动测试失败";
            NSString *passwordHEX = @"A5000007400900";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        
        }else if([self.prompttitle.text isEqualToString:@"坐桶测试"]){
            self.backView.hidden = YES;
            
            self.prompttitle.text = @"坐桶测试失败";
            
        }else if([self.prompttitle.text isEqualToString:@"参数校准"]){
            
            self.prompttitle.text = @"参数校准失败";
            
            
        }else if([self.prompttitle.text isEqualToString:@"震动察觉测试"]){
            
            self.prompttitle.text = @"震动察觉测试失败";
            
            NSString *passwordHEX = @"A5000007400700";//@"A5000007400C01";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else if([self.prompttitle.text isEqualToString:@"蜂鸣器测试"]){
            self.backView.hidden = YES;
            self.prompttitle.text = @"蜂鸣器测试失败";
            NSString *passwordHEX = @"A5000007400800";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else if ([self.prompttitle.text isEqualToString:@"龙头锁测试"]){
            self.backView.hidden = YES;
            self.prompttitle.text = @"龙头锁测试失败";
            
        }else if ([self.prompttitle.text isEqualToString:@"一键通线路控制"]){
            self.backView.hidden = YES;
            self.prompttitle.text = @"一键通线路控制测试失败";
            
        }else if ([self.prompttitle.text isEqualToString:@"一线通语音"]){
            self.backView.hidden = YES;
            self.prompttitle.text = @"一线通语音测试失败";
            
        }else if ([self.prompttitle.text isEqualToString:@"指纹测试"]){
            
            self.prompttitle.text = @"指纹测试失败";
        }

        [self  failer];
        
    }
    
}

//测试失败
- (void)failer{
    
    self.headView.backgroundColor = [UIColor redColor];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"失败是否重测" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"确定", nil];
    alertView.tag = 1000;
    [alertView show];

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000){
    
        if (buttonIndex != [alertView cancelButtonIndex]) {
            self.headView.backgroundColor = [UIColor blueColor];
            self.countdown.hidden = NO;
            if([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"钥匙%d配置失败",(int)keynumber+1]]){
            
                self.prompttitle.text = [NSString stringWithFormat:@"第%d把钥匙配置",(int)keynumber+1];
                [self keypair];
                
            }else if ([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"钥匙%d测试失败",(int)keynumber+1]]){
            
                self.prompttitle.text = [NSString stringWithFormat:@"钥匙%d测试",(int)keynumber+1];
                [self keyTest];
                
            }else if ([self.prompttitle.text isEqualToString:[NSString stringWithFormat:@"感应钥匙%d配置失败",(int)induckey+1]]){
                
                [self inductionkeyTest];
                
            }else if ([self.prompttitle.text isEqualToString:@"常规测试失败"]){
                self.prompttitle.text = @"常规测试";
                [self nomalTest];
            
            }else if ([self.prompttitle.text isEqualToString:@"单线测试失败"]){
                self.prompttitle.text = @"单线测试";
                [self roudTest];
            
            }else if ([self.prompttitle.text isEqualToString:@"双线测试失败"]){
            
                self.prompttitle.text = @"双线测试";
                [self roudTest];
            
            }else if ([self.prompttitle.text isEqualToString:@"震动察觉测试失败"]){
            
                self.prompttitle.text = @"震动察觉测试";
                [self vibrationdetection];
            
            }else if ([self.prompttitle.text isEqualToString:@"一键启动测试失败"]){
            
                self.prompttitle.text = @"一键启动测试";
                [self onekeystart];
            
            }else if ([self.prompttitle.text isEqualToString:@"坐桶测试失败"]){
                
                self.prompttitle.text = @"坐桶测试";
                [self seatTest];
                
            }else if ([self.prompttitle.text isEqualToString:@"龙头锁测试失败"]){
                
                self.prompttitle.text = @"龙头锁测试";
                [self lockTest];
                
            }else if ([self.prompttitle.text isEqualToString:@"参数校准失败"]){
                
                self.prompttitle.text = @"参数校准";
                [self calibrationTest];
                
            }else if ([self.prompttitle.text isEqualToString:@"蜂鸣器测试失败"]){
                
                self.prompttitle.text = @"蜂鸣器测试";
                [self buzzerTest];
                
            }else if ([self.prompttitle.text isEqualToString:@"一键通线路控制测试失败"]){
                
                self.prompttitle.text = @"一键通线路控制";
                [self oneClickControlHigh];
                
            }else if ([self.prompttitle.text isEqualToString:@"一线通语音测试失败"]){
                
                self.prompttitle.text = @"一线通语音";
                [self oneLineSpeechOpen];
                
            }else if ([self.prompttitle.text isEqualToString:@"网络上传失败"]){
                
                self.prompttitle.text = @"网络上传";
                [self omebind];
                
            }else if ([self.prompttitle.text isEqualToString:@"指纹测试失败"]){
                
                self.prompttitle.text = @"指纹测试";
                [self fingerPrintTest];
                
            }
        }else{
        
            [self testend];
        }
    }else if (alertView.tag == 2000){
    
        if (buttonIndex != [alertView cancelButtonIndex]) {
        
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000D400D0%d%@",(int)induckey,MacString];//@"A5000006400C";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else{
            
            [self inductionkeyTest];
        
        }
    
    }
}

- (void)setupheadView{
    
    UIImageView *boximage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, 32, 32)];
    boximage.image = [UIImage imageNamed:@"icon_box"];
    [self.view addSubview:boximage];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(boximage.frame) + 10, boximage.y, 100, 15)];
    title.text = @"测试盒子";
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:title];
    
    UILabel *connecttitle = [[UILabel alloc] initWithFrame:CGRectMake(title.x, CGRectGetMaxY(title.frame), 80, 15)];
    connecttitle.text = @"未连接";
    connecttitle.textColor = [UIColor cyanColor];
    connecttitle.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:connecttitle];
    self.connecttitle = connecttitle;
    
    UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, 100, 40)];
    [clearBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearBtn];
    
    BottomBtn *SetupBtn = [[BottomBtn alloc] init];
    SetupBtn.width = 90;
    SetupBtn.height = 40;
    SetupBtn.x = ScreenWidth - 110;
    SetupBtn.y = 40;
    [SetupBtn setTitle:@"设置" forState:UIControlStateNormal];
    [SetupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [SetupBtn setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    SetupBtn.titleLabel.font = [UIFont fontWithName:@"Courier-Bold" size:15];;
    SetupBtn.contentMode = UIViewContentModeCenter;
    [SetupBtn addTarget:self action:@selector(SetupBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SetupBtn];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(SetupBtn.frame) + 25, ScreenWidth, 90)];
    headView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:headView];
    self.headView = headView;
    
    
    UILabel *prompttitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 30)];
    prompttitle.font = [UIFont systemFontOfSize:30];
    prompttitle.textColor = [UIColor greenColor];
    prompttitle.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:prompttitle];
    self.prompttitle = prompttitle;
    
    [self beiyong];
    
    UILabel *prompttitle2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(prompttitle.frame) + 10, ScreenWidth, 30)];
    prompttitle2.font = [UIFont systemFontOfSize:30];
    prompttitle2.textColor = [UIColor greenColor];
    prompttitle2.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:prompttitle2];
    self.prompttitle2 = prompttitle2;
    
    UILabel *countdown = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 60, 20, 50, 50)];
    countdown.font = [UIFont systemFontOfSize:45];
    countdown.textColor = [UIColor greenColor];
    countdown.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:countdown];
    self.countdown = countdown;
    
    UITableView *resultTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame) + 20, ScreenWidth, ScreenHeight - 240)];
    //resultTable.separatorStyle = NO;
    resultTable.delegate = self;
    resultTable.dataSource = self;
    [resultTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:resultTable];
    self.resulttable = resultTable;
    
    UITableView *keyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame) + 20, ScreenWidth, ScreenHeight - 240)];
    //resultTable.separatorStyle = NO;
    keyTable.delegate = self;
    keyTable.dataSource = self;
    [keyTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:keyTable];
    keyTable.hidden = YES;
    self.keyTable = keyTable;
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
    [self.view addSubview:footview];
    keyTable.tableFooterView = footview;
    
    UILabel *addbike = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth *.5 - 50, 20, 100, 40)];
    addbike.textColor = [UIColor whiteColor];
    addbike.layer.masksToBounds = YES;
    addbike.layer.cornerRadius = 8;
    addbike.text = @"返回";
    addbike.backgroundColor = [QFTools colorWithHexString:@"#20c8ac"];
    addbike.textAlignment = NSTextAlignmentCenter;
    [footview addSubview:addbike];
    
    addbike.userInteractionEnabled = YES;
    UITapGestureRecognizer *addbikeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backClicked)];
    addbikeTap.numberOfTapsRequired = 1;
    [addbike addGestureRecognizer:addbikeTap];
    
    UIView *firstview = [[UIView alloc] initWithFrame:CGRectMake(0, 80, ScreenWidth, ScreenHeight - 80)];
    firstview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:firstview];
    self.firstview = firstview;
    
    UITableView *Table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, firstview.height)];
    //Table.separatorStyle = NO;
    Table.delegate = self;
    Table.dataSource = self;
    [Table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [firstview addSubview:Table];
    self.table = Table;
    
    [self performSelector:@selector(begainScan) withObject:nil afterDelay:3];
    [self setupAlertView];
}

- (void)begainScan{
    
    [[AppDelegate currentAppDelegate].device startScan];
    
}

- (void)clearBtnClick{
    
    if (self.state) {
        
        [SVProgressHUD showSimpleText:@"测试中不能选择"];
        return;
        
    }
    
    BoxConnectViewController *boxVc = [BoxConnectViewController new];
    boxVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:boxVc animated:YES];
}


- (void)SetupBtnClick:(UIButton *)btn{
    
    if (self.state) {
        
        [SVProgressHUD showSimpleText:@"测试中不能选择"];
        return;
    }
    
    SetingViewController *setVc = [SetingViewController new];
    setVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVc animated:YES];

}

#pragma mark---uitableviewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:self.table]) {
        
        return rssiList.count;
        
    }else if([tableView isEqual:self.resulttable]){
        return self.promteArray.count;
        
    }else if([tableView isEqual:self.keyTable]){
    
        return inductionAry.count;
        
    }else{
    
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return 45;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    static NSString * celltable = @"celltable";
    static NSString * keytable = @"keytable";
    if ([tableView isEqual:self.table]) {
        UITableViewCell * leftCell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!leftCell) {
            leftCell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellName];
            
            leftCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            
        }
        if (indexPath.row+1 <= rssiList.count) {
            
            leftCell.textLabel.text =[NSString stringWithFormat:@"%@    %@",[rssiList[indexPath.row] rssivalue].description,[NSString stringWithFormat:@"智能蓝牙报警器%d",(int)indexPath.row+1]];
        }
        
        
        return leftCell;
        
    }else if ([tableView isEqual:self.keyTable]) {
        UITableViewCell * rightCell = [tableView dequeueReusableCellWithIdentifier:keytable];
        if (!rightCell) {
            rightCell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:keytable];
            
            rightCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            
        }
        if (indexPath.row+1 <= inductionAry.count) {
            
            rightCell.textLabel.text =[NSString stringWithFormat:@"%@    %@",[inductionAry[indexPath.row] rssivalue].description,[NSString stringWithFormat:@"感应钥匙%d",(int)indexPath.row+1]];
        }
        
        
        return rightCell;
        
    }else{
        
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        UITableViewCell * midCell = [tableView cellForRowAtIndexPath:indexPath];
        if (!midCell) {
            midCell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:celltable];
            
            midCell.selectionStyle = UITableViewCellSelectionStyleNone;
            midCell.textLabel.text =self.promteArray[indexPath.row];
        }
        return midCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([tableView isEqual:self.table]) {
        
        if ([stepArray[9] isEqualToString:@"1"] || ![stepArray[10] isEqualToString:@"无"] || [stepArray[16] isEqualToString:@"1"] || [stepArray[18] isEqualToString:@"1"]){
            
            if (![[AppDelegate currentAppDelegate].device2 isConnected]) {
                [SVProgressHUD showSimpleText:@"请先连接盒子"];
                return;
            }
    }
        
        if (indexPath.row >= rssiList.count) {
            return;
        }
        
        self.smartBikeMac = [[rssiList objectAtIndex:indexPath.row] titlename];
        [AppDelegate currentAppDelegate]. device.peripheral=[[rssiList objectAtIndex:indexPath.row] peripher];
        [[AppDelegate currentAppDelegate].device connect];
        
    }else if([tableView isEqual:self.keyTable]){
        if (indexPath.row >= inductionAry.count) {
            return;
        }
        [[AppDelegate currentAppDelegate].device3 stopScan];
        [AppDelegate currentAppDelegate]. device3.peripheral=[[inductionAry objectAtIndex:indexPath.row] peripher];
        [[AppDelegate currentAppDelegate].device3 connect];
    }
}


- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
        cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
        //|| RSSI.intValue < -70
     if(testing){
        NSString *rssi = stepArray[17];
        //NSLog(@" 扫描到 :%@",peripheral.name);
        if (peripheral.name.length < 7) {
            return;
        }
        
        if([[peripheral.name substringWithRange:NSMakeRange(0, 7)]isEqualToString: @"Qgj_Key"]){
            
            if(![inductionDic objectForKey:peripheral.identifier.UUIDString]){
                
                if (RSSI.intValue > rssi.intValue  && RSSI.intValue < 0) {
                    DeviceModel *model=[[DeviceModel alloc]init];
                    model.peripher=peripheral;
                    model.rssivalue = RSSI;
                    model.titlename = peripheral.name;
                    [inductionAry addObject:model];
                    
                    [inductionDic setObject:model forKey:peripheral.identifier.UUIDString];
                }
                // 主线程执行：
                dispatch_async(dispatch_get_main_queue(), ^{
                    // something
                    [self.keyTable reloadData];
                });
                
                
            }else{
                
                DeviceModel *model = [inductionDic objectForKey:peripheral.identifier.UUIDString];
                if (RSSI.intValue >0 ) {
                    model.rssivalue = [NSNumber numberWithInt:-64];;
                }else{
                    model.rssivalue = RSSI;
                }
                
                if (RSSI.intValue < rssi.intValue && RSSI.intValue < 0) {
                    [inductionAry removeObject:model];
                    [inductionDic removeObjectForKey:peripheral.identifier.UUIDString];
                }
                
                // [self performSelectorOnMainThread:@selector(rssefresh) withObject:nil waitUntilDone:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.keyTable reloadData];
                });
            }
        }
        
    }else if ([AppDelegate currentAppDelegate].device.upgrate) {
        
        if (peripheral.name.length == 7) {
            
            if([[peripheral.name substringWithRange:NSMakeRange(0, 7)]isEqualToString: @"Qgj-Ota"]){
                
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssivalue = RSSI;
                [rssiList addObject:model];
                
                
                [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
                
            }
            
        }else if (peripheral.name.length == 11){
            
            if([[peripheral.name substringWithRange:NSMakeRange(0, 11)]isEqualToString: @"Qgj-DfuTarg"]){
                
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssivalue = RSSI;
                [rssiList addObject:model];
                
                [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
                
            }
            
        }else if (peripheral.name.length == 8){
            
            if([[peripheral.name substringWithRange:NSMakeRange(0, 8)]isEqualToString: @"Qgj-DfuT"]){
                
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssivalue = RSSI;
                [rssiList addObject:model];
                
                [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
            }
        }
    }else{
        
        NSString *rssi = stepArray[0];
        if (peripheral.name.length < 13) {
            
            return;
        }
        
        if([[peripheral.name substringWithRange:NSMakeRange(0, 13)]isEqualToString: @"Qgj-SmartBike"]){
            const char *valueString = [[[advertisementData objectForKey:@"kCBAdvDataManufacturerData"] description] cStringUsingEncoding: NSUTF8StringEncoding];
            if (valueString == NULL) {
                return;
            }
            
            NSString *title = [[NSString alloc] initWithUTF8String:valueString];
            NSString *macName = [[title substringWithRange:NSMakeRange(5, 4)] stringByAppendingString:[title substringWithRange:NSMakeRange(10, 8)]].uppercaseString;
            if(![uuidarray objectForKey:peripheral.identifier.UUIDString]){
                
                if (RSSI.intValue > rssi.intValue && RSSI.intValue < 0) {
                    DeviceModel *model=[[DeviceModel alloc]init];
                    model.peripher = peripheral;
                    model.rssivalue = RSSI;
                    model.titlename = macName;
                    [rssiList addObject:model];
                    [uuidarray setObject:model forKey:peripheral.identifier.UUIDString];
                }
                // 主线程执行：
                dispatch_async(dispatch_get_main_queue(), ^{
                    // something
                    [self.table reloadData];
                });
                
                
            }else{
                
                DeviceModel *model = [uuidarray objectForKey:peripheral.identifier.UUIDString];
                if (RSSI.intValue >0 ) {
                    model.rssivalue = [NSNumber numberWithInt:-64];;
                }else{
                    
                    model.rssivalue = RSSI;
                    
                }
                
                
                if (RSSI.intValue < rssi.intValue && RSSI.intValue < 0) {
                    [rssiList removeObject:model];
                    [uuidarray removeObjectForKey:peripheral.identifier.UUIDString];
                }
                
                
                
                // [self performSelectorOnMainThread:@selector(rssefresh) withObject:nil waitUntilDone:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // something
                    [self.table reloadData];
                });
            }
            
        }
        
    }
}

//连接处理
- (void)connectDfuModel{
    
    [[AppDelegate currentAppDelegate].device stopScan];
    [custompro stopAnimation];
    if(rssiList.count>0){
        custompro.presentlab.text = @"正在固件升级中...";
        //self.backView.hidden = NO;
        NSArray *dfuArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(DeviceModel* obj1, DeviceModel* obj2)
                                {
                                    float f1 = fabsf([obj1.rssivalue floatValue]);
                                    float f2 = fabsf([obj2.rssivalue floatValue]);
                                    if (f1 > f2)
                                    {
                                        return (NSComparisonResult)NSOrderedDescending;
                                    }
                                    if (f1 < f2)
                                    {
                                        return (NSComparisonResult)NSOrderedAscending;
                                    }
                                    return (NSComparisonResult)NSOrderedSame;
                                }];
        [dfuArray objectAtIndex:0];
        selectedPeripheral = [[dfuArray objectAtIndex:0] peripher];
        [dfuOperations setCentralManager:[AppDelegate currentAppDelegate].device.centralManager];
        [dfuOperations connectDevice:[[dfuArray objectAtIndex:0] peripher]];
        [self performSelector:@selector(connectDfuSuccess) withObject:nil afterDelay:2];
        
    }else{
        // AlertMSG(@"提示", @"请确认设备已开启或重启设备");
        [AppDelegate currentAppDelegate].device.upgrate = NO;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:NSLocalizedString( @"请确认设备已开启或重启手机和设备", @"") delegate:self cancelButtonTitle:NSLocalizedString( @"确定", @"") otherButtonTitles:nil, nil];
        [alert show];
        self.backView.hidden = YES;
    }
    
    
}




/**
 *
 *  记录绑定的感应钥匙
 */
-(void)recordInduckey:(NSString *)mac{
    
    [self.keyArray removeAllObjects];
    NSMutableArray *modals = [LVFmdbTool queryKeyData:nil];
    for (InductionKeyModel *keymodel in modals) {
        
        if ([mac isEqualToString:keymodel.mac]) {
            
            [countTimer invalidate];
            countTimer = nil;
            self.countdown.hidden = YES;
            timeNumber = 11;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该钥匙已被匹配过,是否继续" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 2000;
            [alertView show];
            
            return;
        }
    }
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A500000D400D0%d%@",(int)induckey,MacString];//@"A5000006400C";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    if (modals.count<5) {
        
        InductionKeyModel *induckeyModel = [InductionKeyModel modalWith:mac];
        [LVFmdbTool insertKeyModel:induckeyModel];
        
        
    }else{
        
        for (InductionKeyModel *keymodel in modals) {
            
            [self.keyArray addObject:keymodel.mac];
            
            }
        
        [self.keyArray removeObjectAtIndex:0];
        [self.keyArray addObject:mac];

        BOOL delata = [LVFmdbTool deleteKeyData:nil];
        
        if (delata) {
            
            for (NSString *macs in self.keyArray) {
                
                InductionKeyModel *induckeyModel = [InductionKeyModel modalWith:macs];
                [LVFmdbTool insertKeyModel:induckeyModel];
            }
        } else {
            
            NSLog(@"删除数据失败");
        }
    }
}

-(void)backClicked{

    [[AppDelegate currentAppDelegate].device3 stopScan];
    self.keyTable.hidden = YES;
    [self testend];

}

/**
 *  一键启动命令
 */

- (void)onekeystart{

    timeNumber = 11;
    self.prompttitle.text = @"一键启动测试";
    self.prompttitle2.text = @"请按键";
    self.countdown.hidden = NO;
    [self coutdowntime];
    NSString *passwordHEX = @"A5000007400901";
    //[appDelegate.device sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];

}

/**
 *  感应钥匙配置
 */

- (void)inductionkeyTest{
    testing = YES;
    self.prompttitle2.text = @"请链接钥匙";
    self.prompttitle.text = [NSString stringWithFormat:@"感应钥匙%d配置",(int)induckey+1];
    [[AppDelegate currentAppDelegate].device3 startScan];
    self.countdown.hidden = YES;
    self.keyTable.hidden = NO;
    
}


/**
 *  震动察觉测试命令
 */
-(void)vibrationdetection{
    
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = NO;
    self.prompttitle.text = @"震动察觉测试";
    self.prompttitle2.text = @"请晃动报警器";
    NSString *passwordHEX = @"A5000007400701";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];

}

/**
 *  钥匙配置测试命令
 */
-(void)keypair{
    timeNumber = 11;
    [self coutdowntime];
    self.prompttitle2.text = @"请按键";
    NSString *passwordHEX = @"A5000007400201";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    
}

/**
 *  蜂鸣器测试
 */

- (void)buzzerTest{
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = YES;
    self.prompttitle2.text = @"请确认";
    self.backView.hidden = NO;
    NSString *passwordHEX = @"A5000007400801";//@"A5000007400C01";
    //[appDelegate.device sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  常规测试命令
 */
-(void)nomalTest{
    
    timeNumber = 11;
    self.countdown.hidden = NO;
    [self coutdowntime];
    self.prompttitle.text = @"常规测试";
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A500000840060101";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    [self delayfunction];
    
}

/**
 *  钥匙配置测试命令
 */
-(void)keyTest{
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = NO;
    self.prompttitle2.text = @"请按键";
    NSString *passwordHEX = @"A5000007400401";
    //[appDelegate.device sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  龙头锁测试
 *
 *
 */

-(void)lockTest{
    timeNumber = 11;
    self.backView.hidden = NO;
    self.countdown.hidden = YES;
    self.prompttitle2.text = @"请确认";
    [self coutdowntime];
    NSString *passwordHEX = @"A5000006400B";
    //[appDelegate.device sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  坐桶测试
 */
- (void)seatTest{
    
    timeNumber = 11;
    [self coutdowntime];
    self.backView.hidden = NO;
    self.countdown.hidden = YES;
    self.prompttitle2.text = @"请确认";
    NSString *passwordHEX = @"A5000006400A";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  参数校准测试
 */

-(void)calibrationTest{
    
    timeNumber = 11;
    [self coutdowntime];
    self.prompttitle2.text = @"";
    self.countdown.hidden = NO;
    NSString *passwordHEX = @"A50000061003";
    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  单双线路测试
 */
- (void)roudTest{
    
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = NO;
    lineNumber = 8;
    linetype = 2;
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A500000810020201";//通讯线路高电平输出
    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    [self delayfunction];
}

/**
 *  一键通控制高电平
 */

- (void)oneClickControlHigh{
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = NO;
    lineNumber = 12;
    linetype = 3;
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A500000810020301";//一键通高电平输出
    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    [self delayfunction];
}

/**
 *  一键通控制低电平
 */

- (void)oneClickCheckLow{
    
    lineNumber = 13;
    linetype = 3;
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A500000810020300";//一键通低低平输出
    [[AppDelegate currentAppDelegate].device2 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    [self delayfunction];}

/**
 *  一线通语音开启
 */

- (void)oneLineSpeechOpen{
    timeNumber = 6;
    [self coutdowntime];
    self.countdown.hidden = YES;
    self.prompttitle2.text = @"请确认";
    self.backView.hidden = NO;
    NSString *passwordHEX = @"A5000007400F01";//一键通低低平输出
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}

/**
 *  一线通语音关闭
 */

- (void)oneLineSpeechClose{
    
    [self coutdowntime];
    self.countdown.hidden = NO;
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A5000007400F00";//一键通低低平输出
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

/**
 *  指纹测试
 */
- (void)fingerPrintTest{
    timeNumber = 11;
    [self coutdowntime];
    self.countdown.hidden = YES;
    self.prompttitle2.text = @"请按指纹确认";
    self.prompttitle2.text = @"";
    NSString *passwordHEX = @"A5000007300500";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}


/**
 *  固件升级
 */
-(void)firmwareUpdate{
    
    NSString *localFirmwar = stepArray[22];
    if ([[EditionString substringWithRange:NSMakeRange(0, EditionString.length - 6)] isEqualToString:[localFirmwar substringWithRange:NSMakeRange(0, localFirmwar.length - 6)]]) {
        
        if ([EditionString isEqualToString:localFirmwar]){
            [SVProgressHUD showSimpleText:@"已是最新版本无需更新"];
            [self testend];
            return;
        }
        
    }else{
        [SVProgressHUD showSimpleText:@"版本不适配,不能更新"];
        [self testend];
        return;
    }
    
    NSString *NetworktVersion = [localFirmwar substringFromIndex:localFirmwar.length- 5];
    NSString *CurrentVersion = [EditionString substringFromIndex:EditionString.length- 5];
    
    CurrentVersion = [CurrentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (CurrentVersion.length==2) {
        CurrentVersion  = [CurrentVersion stringByAppendingString:@"0"];
    }else if (CurrentVersion.length==1){
        CurrentVersion  = [CurrentVersion stringByAppendingString:@"00"];
    }
    NetworktVersion = [NetworktVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (NetworktVersion.length==2) {
        NetworktVersion  = [NetworktVersion stringByAppendingString:@"0"];
    }else if (NetworktVersion.length==1){
        NetworktVersion  = [NetworktVersion stringByAppendingString:@"00"];
    }
    
    //当前版本号大于本地版本
    if([CurrentVersion floatValue] >= [NetworktVersion floatValue])
    {
        NSLog(@"无需更新");
        return;
        
    }
    
    self.prompttitle.text = @"固件升级";
    self.prompttitle2.text = @"";
    self.countdown.hidden = YES;
    [custompro startAnimation];
    custompro.presentlab.text = @"报警器正在连接中...";
    [AppDelegate currentAppDelegate].device.upgrate = YES;
    NSString *passwordHEX = @"A50000061004";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
}


/**
 初始测试匹配
 */
-(void)beiyong{

    if ([stepArray[1] isEqualToString:@"1"]) {
        
        self.prompttitle.text = @"第1把钥匙配置";
        
    }else {
        
        if ([stepArray[2] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"钥匙1测试";
            
        }else{
            
            if ([stepArray[3] intValue] > 0) {
                
                self.prompttitle.text = @"感应钥匙配置";
                
            }else{
            
                if ([stepArray[9] isEqualToString:@"1"]) {
                    
                    self.prompttitle.text = @"常规测试";
                }else{
                    
                    if ([stepArray[10] isEqualToString:@"单线测试"]){
                        
                        self.prompttitle.text = @"单线测试";
                        
                    }else if ([stepArray[10] isEqualToString:@"双线测试"]){
                        
                        self.prompttitle.text = @"双线测试";
                        
                    }else{
                        
                        if ([stepArray[11] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"震动察觉测试";
                            
                        }else{
                            
                            if ([stepArray[12] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"蜂鸣器测试";
                                
                            }else{
                                
                                if ([stepArray[13] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"一键启动测试";
                                    
                                }else{
                                    
                                    if ([stepArray[14] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"坐桶测试";
                                        
                                    }else{
                                        
                                        if ([stepArray[15] isEqualToString:@"1"]) {
                                            
                                            self.prompttitle.text = @"龙头锁测试";
                                            
                                        }else{
                                            
                                            if ([stepArray[16] isEqualToString:@"1"]) {
                                                
                                                self.prompttitle.text = @"参数校准";
                                                
                                                
                                            }else{
                                                
                                                if ([stepArray[18] isEqualToString:@"1"]) {
                                                    
                                                    self.prompttitle.text = @"一键通线路控制";
                                                    self.prompttitle2.text = @"";
                                                    
                                                    
                                                }else{
                                                    
                                                    if ([stepArray[19] isEqualToString:@"1"]) {
                                                        
                                                        self.prompttitle.text = @"一线通语音";
                                                        self.prompttitle2.text = @"";
                                                        
                                                        
                                                    }else{
                                                        
                                                        if ([stepArray[20] isEqualToString:@"1"]) {
                                                            
                                                            self.prompttitle.text = @"指纹测试";
                                                            self.prompttitle2.text = @"";
                                                            
                                                        }else{
                                                            
                                                            if ([stepArray[21] isEqualToString:@"1"]) {
                                                                
                                                                self.prompttitle.text = @"固件升级";
                                                                self.prompttitle2.text = @"";
                                                                
                                                            }else{
                                                                
                                                                self.prompttitle.text = @"请先设置测试选项";
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 *  钥匙测试后检测
 */

-(void)nexTest{

    if ([stepArray[9] isEqualToString:@"1"]) {
        self.prompttitle.text = @"常规测试";
        [self nomalTest];
    }else{
    
    if ([stepArray[10] isEqualToString:@"单线测试"]){
        
        self.prompttitle.text = @"单线测试";
        [self roudTest];
        
    }else if ([stepArray[10] isEqualToString:@"双线测试"]){
        
        self.prompttitle.text = @"双线测试";
        [self roudTest];
        
    }else{
        
        if ([stepArray[11] isEqualToString:@"1"]) {
            
            self.prompttitle.text = @"震动察觉测试";
            [self vibrationdetection];
        }else{
            
            if ([stepArray[12] isEqualToString:@"1"]) {
                
                self.prompttitle.text = @"蜂鸣器测试";
                [self buzzerTest];
            }else{
                
                if ([stepArray[13] isEqualToString:@"1"]) {
                    self.prompttitle.text = @"一键启动测试";
                    [self onekeystart];
                }else{
                    
                    if ([stepArray[14] isEqualToString:@"1"]) {
                        
                        self.prompttitle.text = @"坐桶测试";
                        [self seatTest];
                    }else{
                        
                        if ([stepArray[15] isEqualToString:@"1"]) {
                            
                            self.prompttitle.text = @"龙头锁测试";
                            [self lockTest];
                        }else{
                            
                            if ([stepArray[16] isEqualToString:@"1"]) {
                                
                                self.prompttitle.text = @"参数校准";
                                [self calibrationTest];
                            }else{
                                
                                if ([stepArray[18] isEqualToString:@"1"]) {
                                    
                                    self.prompttitle.text = @"一键通线路控制";
                                    [self oneClickControlHigh];
                                    
                                }else{
                                    
                                    if ([stepArray[19] isEqualToString:@"1"]) {
                                        
                                        self.prompttitle.text = @"一线通语音";
                                        [self oneLineSpeechOpen];
                                        
                                    }else{
                                        
                                        if ([stepArray[20] isEqualToString:@"1"]) {
                                            self.prompttitle.text = @"指纹测试";
                                            [self fingerPrintTest];
                                            
                                        }else{
                                            
                                            if ([stepArray[21] isEqualToString:@"1"]) {
                                                
                                                [self firmwareUpdate];
                                                
                                            }else{
                                                
                                                [self testend];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
        }
     }
    
  }
}



/**
 *  匹配钥匙类型
 */

- (void)matchkeytype{
    
    switch(self.keyType){
            
        case 0:{
            
            NSString *passwordHEX = @"A5000007400E00";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        
        }
            break;
            
        case 1:{
            
            NSString *passwordHEX = @"A5000007400E01";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 2:{
            
            NSString *passwordHEX = @"A5000007400E02";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
        case 3:{
            
            NSString *passwordHEX = @"A5000007400E03";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 4:{
            
            NSString *passwordHEX = @"A5000007400E04";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 5:{
            
            NSString *passwordHEX = @"A5000007400E05";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 6:{
            
            NSString *passwordHEX = @"A5000007400E06";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 7:{
            
            NSString *passwordHEX = @"A5000007400E07";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
        case 8:{
            
            NSString *passwordHEX = @"A5000007400E08";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            
            break;
            
        case 9:{
            
            NSString *passwordHEX = @"A5000007400E09";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
            break;
        default:
            
            [self testend];
            
            break;
            
            
            
    }
    
}


/**
 *钥匙类型匹配
 */
- (void)matchkeytype2{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *verDic = [defaults objectForKey:versionDic];
    
    NSString *keyname = [NSString stringWithFormat:@"%@%@%@%@",verDic[@"key1"],verDic[@"key2"],verDic[@"key3"],verDic[@"key4"]];
    
    if ([keyname isEqualToString:@"设防撤防寻车一键启动"]) {
        
        self.keyType = 0;
    }else if ([keyname isEqualToString:@"设防撤防静音一键启动"]){
        
        self.keyType = 1;
    }else if ([keyname isEqualToString:@"设防撤防开坐桶一键启动"]){
        
        self.keyType = 2;
    }else if ([keyname isEqualToString:@"设防撤防无无"]){
        
        self.keyType = 3;
    }else if ([keyname isEqualToString:@"设防撤防寻车无"]){
        
        self.keyType = 4;
    }else if ([keyname isEqualToString:@"设防撤防静音无"]){
        
        
        self.keyType = 5;
    }else if ([keyname isEqualToString:@"设防撤防开坐桶无"]){
        
        
        self.keyType = 6;
    }else if ([keyname isEqualToString:@"设防撤防无无无"]){
        
        
        self.keyType = 7;
    }else if ([keyname isEqualToString:@"设防撤防无一键启动"]){
        
        
        self.keyType = 8;
    }else if ([keyname isEqualToString:@"设防撤防无一键启动&开坐桶"]){
        
        
        self.keyType = 9;
    }else{
    
        self.keyType = 0;
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//*******************???固件升级????*******************//

- (void)connectDfuSuccess{
    
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/test.zip", pathDocuments];
    NSURL *URL = [NSURL URLWithString:filePath];
    [self onFileTypeNotSelected];
    
    // Save the URL in DFU helper
    self.dfuHelper.selectedFileURL = URL;
    
    //if (self.dfuHelper.selectedFileURL) {
    NSMutableArray *availableTypes = [[NSMutableArray alloc] initWithCapacity:4];
    
    // Read file name and size
    NSString *selectedFileName = [[URL path] lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:URL];
    self.dfuHelper.selectedFileSize = fileData.length;
    
    // Get last three characters for file extension
    NSString *extension = [[selectedFileName substringFromIndex: [selectedFileName length] - 3] lowercaseString];
    if ([extension isEqualToString:@"zip"])
    {
        self.dfuHelper.isSelectedFileZipped = YES;
        self.dfuHelper.isManifestExist = NO;
        // Unzip the file. It will parse the Manifest file, if such exist, and assign firmware URLs
        [self.dfuHelper unzipFiles:URL];
        
        // Manifest file has been parsed, we can now determine the file type based on its content
        // If a type is clear (only one bin/hex file) - just select it. Otherwise give user a change to select
        NSString* type = nil;
        if (((self.dfuHelper.softdevice_bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL) ||
             (self.dfuHelper.softdeviceURL && self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)) &&
            !self.dfuHelper.applicationURL)
        {
            type = FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER;
        }
        else if (self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_SOFTDEVICE;
        }
        else if (self.dfuHelper.bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_BOOTLOADER;
        }
        else if (self.dfuHelper.applicationURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_APPLICATION;
        }
        
        // The type has been established?
        if (type)
        {
            // This will set the selectedFileType property
            [self onFileTypeSelected:type];
        }
        else
        {
            if (self.dfuHelper.softdeviceURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_SOFTDEVICE];
            }
            if (self.dfuHelper.bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOOTLOADER];
            }
            if (self.dfuHelper.applicationURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_APPLICATION];
            }
            if (self.dfuHelper.softdevice_bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER];
            }
        }
    }
    else
    {
        // If a HEX/BIN file has been selected user needs to choose the type manually
        self.dfuHelper.isSelectedFileZipped = NO;
        [availableTypes addObjectsFromArray:@[FIRMWARE_TYPE_SOFTDEVICE, FIRMWARE_TYPE_BOOTLOADER, FIRMWARE_TYPE_APPLICATION, FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER]];
    }
    
    [self performDFU];
}

-(void)performDFU
{
    
    [self.dfuHelper checkAndPerformDFU];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // The 'scan' or 'select' seque will be performed only if DFU process has not been started or was completed.
    //return !self.isTransferring;
    return YES;
}


- (void) clearUI
{
    selectedPeripheral = nil;
}

-(void)enableUploadButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectedFileType && self.dfuHelper.selectedFileSize > 0)
        {
            if ([self.dfuHelper isValidFileSelected])
            {
                NSLog(@"Valid file selected");
            }
            else
            {
                NSLog(@"Valid file not available in zip file");
                [Utility showAlert:[self.dfuHelper getFileValidationMessage]];
                return;
            }
        }
        if (self.dfuHelper.isDfuVersionExist)
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion > 1)
            {
                if ([self.dfuHelper isInitPacketFileExist])
                {
                    // uploadButton.enabled = YES;
                }
                else
                {
                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else
            {
                if (selectedPeripheral && self.isConnected && self.dfuHelper.dfuVersion < 1)
                {
                    // uploadStatus.text = [NSString stringWithFormat:@"Unsupported DFU version: %d", self.dfuHelper.dfuVersion];
                }
                NSLog(@"Can't enable Upload button");
            }
        }
        else
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected)
            {
                // uploadButton.enabled = YES;
            }
            else
            {
                NSLog(@"Can't enable Upload button");
            }
        }
        
    });
}


-(void)appDidEnterBackground:(NSNotification *)_notification
{
    if (self.isConnected && self.isTransferring)
    {
        [Utility showBackgroundNotification:[self.dfuHelper getUploadStatusMessage]];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



#pragma mark File Selection Delegate
-(void)onFileTypeSelected:(NSString *)type
{
    selectedFileType = type;
    //fileType.text = selectedFileType;
    if (type)
    {
        [self.dfuHelper setFirmwareType:selectedFileType];
        [self enableUploadButton];
    }
}

-(void)onFileTypeNotSelected
{
    self.dfuHelper.selectedFileURL = nil;
    //    fileName.text = nil;
    //    fileSize.text = nil;
    [self onFileTypeSelected:nil];
}

#pragma mark DFUOperations delegate methods

-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self enableUploadButton];
    
    [SVProgressHUD showSimpleText:@"固件升级失败"];
    self.backView.hidden = YES;
    [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
    [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
    [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Device ready";
    });
    
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Reading DFU version...";
    });
    
    //Following if condition display user permission alert for background notification
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    self.isTransferring = NO;
    self.isConnected = NO;
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion != 1)
        {
            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
        }
        else
        {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [dfuOperations connectDevice:peripheral];
            });
        }
    });
}

-(void)onReadDFUVersion:(int)version
{
    self.dfuHelper.dfuVersion = version;
    if (self.dfuHelper.dfuVersion == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        [dfuOperations setAppToBootloaderMode];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        [self enableUploadButton];
    }
}

-(void)onDFUStarted
{
    NSLog(@"DFU Started");
    self.isTransferring = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:uploadStatusMessage];
        }
        else
        {
            
        }
    });
}

-(void)onDFUCancelled
{
    NSLog(@"DFU Cancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    
    [SVProgressHUD showSimpleText:@"固件升级失败"];
    [[AppDelegate currentAppDelegate].device stopScan];
    [custompro stopAnimation];
    self.backView.hidden = YES;
    [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
    [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
    [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
}

-(void)onSoftDeviceUploadStarted
{
    NSLog(@"SoftDevice Upload Started");
}

-(void)onSoftDeviceUploadCompleted
{
    NSLog(@"SoftDevice Upload Completed");
}

-(void)onBootloaderUploadStarted
{
    NSLog(@"Bootloader Upload Started");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:@"Uploading bootloader..."];
        }
        else
        {
            
        }
    });
}

-(void)onBootloaderUploadCompleted
{
    NSLog(@"Bootloader Upload Completed");
}

-(void)onTransferPercentage:(int)percentage
{
    //NSLog(@"Transfer progress: %d%%",percentage);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [custompro setPresent:(int)percentage];
        
    });
}

-(void)onSuccessfulFileTranferred
{
    NSLog(@"File Transferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)dfuOperations.binFileSize, (unsigned long)dfuOperations.uploadTimeInSeconds];
        
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:message];
        }
        else
        {
            //[Utility showAlert:message];
            
            [SVProgressHUD showSimpleText:@"升级完成"];
            [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
            [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
            [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
            
            
            
        }
    });
}


-(void)connectBle{
    
    [AppDelegate currentAppDelegate].device.upgrate = NO;
    self.backWindow.hidden = YES;
    int present = 0;
    [custompro setPresent:present];
    [self testend];
    
}

-(void)onError:(NSString *)errorMessage
{
    NSLog(@"Error: %@", errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[Utility showAlert:errorMessage];
        [self clearUI];
        
        [SVProgressHUD showSimpleText:@"固件升级失败"];
        [[AppDelegate currentAppDelegate].device stopScan];
        [custompro stopAnimation];
        [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
        [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
        [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
        
    });
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
