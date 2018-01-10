//
//  LockViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/28.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "LockViewController.h"
#import "DeviceModel.h"
#import "QRCodeReaderView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface LockViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,ScanDelegate>{
    NSString *codeNum;
    NSString *macString;
    NSString *keyMac;
    NSString *editionString;
    
    NSMutableArray *rssiList;
    NSArray *ascendArray;
    NSMutableDictionary *uuidarray;
    
    NSMutableDictionary *deviceList;
    
    NSMutableDictionary *deviceDic;
    NSMutableArray *SetRssiArray;
    
    QRCodeReaderView * readview;//二维码扫描对象
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}

@property(nonatomic,weak) UITableView *deviceTable;
@property(nonatomic,weak) UIView *backView;
@property (strong, nonatomic) CIDetector *detector;

@end

@implementation LockViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    if (isFirst || isPush) {
        if (readview) {
            [self reStartScan];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
        readview.is_Anmotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavgationItemTitle:@"设备绑定"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak LockViewController *weakself = self;
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself backButtonEvent];
    }];
    
//    [self configureRightBarButtonWithTitle:@"相册" action:^{
//        
//        [weakself alumbBtnEvent];
//    }];
    isFirst = YES;
    isPush = NO;
    [self InitScan];
    // Do any additional setup after loading the view.
    [AppDelegate currentAppDelegate].device4.scanDelete = self;
    deviceList=[[NSMutableDictionary alloc]init];
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    
    SetRssiArray = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:RSSIVALUE];
    [SetRssiArray addObject:userDic[@"rssi"]];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(GetBurglarMacString:) name:KNotification_BurglarMac object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(DeviceEdition:) name:KNotification_Edition object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(querySuccess:) name:KNotification_QueryData object:nil];
    
    
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screenWidth, screenHeight - 64)];
    [self.view addSubview:backView];
    self.backView = backView;
    UITableView *deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, backView.height)];
    deviceTable.delegate = self;
    deviceTable.dataSource = self;
    [deviceTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.deviceTable = deviceTable;
    [backView addSubview:deviceTable];
    
    backView.hidden = YES;
}

-(void)updateDeviceStatusAction:(NSNotification*)notification{
    int deviceTag=[notification.object intValue];
    
    if (deviceTag == 4) {
        
        if([AppDelegate currentAppDelegate].device4.deviceStatus == 0){
            
            
            
        }else if([AppDelegate currentAppDelegate].device4.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device4.deviceStatus<5){
            
            [[AppDelegate currentAppDelegate].device4 stopScan];
            
            [self checkKey];
            
            
        }else{
            
            
        }
        
    }
    
}


-(void)GetBurglarMacString:(NSNotification*)notification{

    NSString *date = notification.userInfo[@"data"];
    
    macString = date.uppercaseString;//报警器Mac地址
    [[AppDelegate currentAppDelegate].device4 readDiviceInformation];
    

}

-(void)DeviceEdition:(NSNotification*)notification{
    NSString *date = notification.userInfo[@"data"];
    editionString = date;
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A500000E30020101%@",keyMac];
    [[AppDelegate currentAppDelegate].device4 sendHexstring:passwordHEX];
    [[AppDelegate currentAppDelegate].device4 sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

-(void)querySuccess:(NSNotification*)notification{
    
    NSString *date = notification.userInfo[@"data"];
    NSNumber *tag = notification.userInfo[@"deviceTg"];
    
    if (tag.intValue == 4) {
    
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]) {
        
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [SVProgressHUD showSimpleText:@"绑定失败"];
                self.backView.hidden = YES;
                codeNum = nil;
                editionString = nil;
                macString = nil;
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
                [self bindKey];
            }
        
        }
    }
}

- (void)checkKey{
    
    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:FactoryUserDic];
    NSString *token= userDic[@"token"];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/check"];
    NSDictionary *parameters = @{@"token": token, @"sn":codeNum };
    
    [[HttpRequest sharedInstance] postWithURLString2:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            deviceDic = dict[@"data"];
            keyMac = deviceDic[@"mac"];
            NSLog(@"%@",keyMac);
            [[AppDelegate currentAppDelegate].device4 sendAccelerationValue];
            
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
    }];
    
}

- (void)bindKey{

    NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:FactoryUserDic];
    NSString *token= userDic[@"token"];
    NSLog(@"%@",token);
    NSNumber *type= [NSNumber numberWithInt:1];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/bind"];
    NSDictionary *parameters = @{@"token": token, @"sn":codeNum,@"mac":macString,@"firm_version":editionString,@"type":type,@"device_info":deviceDic};
    
    [[HttpRequest sharedInstance] postWithURLString2:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [[AppDelegate currentAppDelegate].device4 remove];
            self.backView.hidden = YES;
            codeNum = nil;
            editionString = nil;
            macString = nil;
            
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
    }];
}

-(void)dealloc{

    if ([[AppDelegate currentAppDelegate].device4 isConnected]) {
        
        [[AppDelegate currentAppDelegate].device4 remove];
    }
    [[AppDelegate currentAppDelegate].device4 stopScan];
    [AppDelegate currentAppDelegate].device4.scanDelete = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_UpdateDeviceStatus object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_BurglarMac object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_Edition object:nil];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return rssiList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    ascendArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(DeviceModel* obj1, DeviceModel* obj2)
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
    cell.textLabel.text = [NSString stringWithFormat:@"智能蓝牙报警器%d",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[AppDelegate currentAppDelegate].device4 stopScan];
    [AppDelegate currentAppDelegate]. device4.peripheral=[[ascendArray objectAtIndex:indexPath.row] peripher];
    NSLog(@"连接上的设备%@",[AppDelegate currentAppDelegate].device4.peripheral.identifier.UUIDString);
    [[AppDelegate currentAppDelegate].device4 connect];
    
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@" 扫描到 :%@",peripheral.name);
    if (peripheral.name.length < 13) {
        return;
    }
    NSString *rssi = SetRssiArray[0];
    if([[peripheral.name substringWithRange:NSMakeRange(0, 13)]isEqualToString: @"Qgj-SmartBike"]){
        
        if(![uuidarray objectForKey:peripheral.identifier.UUIDString]){
            
            if (RSSI.intValue > rssi.intValue && RSSI.intValue < 0) {
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssivalue = RSSI;
                model.titlename = peripheral.name;
                [rssiList addObject:model];
                [uuidarray setObject:model forKey:peripheral.identifier.UUIDString];
            }
            // 主线程执行：
            dispatch_async(dispatch_get_main_queue(), ^{
                // something
                [self.deviceTable reloadData];
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
                [self.deviceTable reloadData];
            });
        }
    }
}

#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:CGRectMake(0, 0, DeviceMaxWidth, DeviceMaxHeight - 64)];
    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 返回
- (void)backButtonEvent
{
    //    [self dismissViewControllerAnimated:YES completion:^{
    //
    //    }];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 4;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return;
    }
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController         availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    readview.is_Anmotion = YES;
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            
            [self accordingQcode:scannedResult];
        }];
        
    }
    else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            readview.is_Anmotion = NO;
            [readview start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    readview.is_Anmotion = YES;
    [readview stop];
    
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self accordingQcode:result];
    
    [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)str
{
    codeNum = str;
    self.backView.hidden = NO;
    [[AppDelegate currentAppDelegate].device3 startScan];
    
}



- (void)reStartScan
{
    readview.is_Anmotion = NO;
    
    if (readview.is_AnmotionFinished) {
        [readview loopDrawLine];
    }
    
    [readview start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
