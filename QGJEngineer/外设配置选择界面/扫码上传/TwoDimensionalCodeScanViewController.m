//
//  QRViewController.m
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import "TwoDimensionalCodeScanViewController.h"
//#import "DeviceModel.h"
#import "SearchBleModel.h"
#import "QRCodeReaderView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface TwoDimensionalCodeScanViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,ScanDelegate,UINavigationControllerDelegate>{
    
    NSString *codeNum;
    NSMutableArray *rssiList;
    NSArray *ascendArray;
    NSMutableDictionary *uuidarray;
    
    NSMutableDictionary *deviceList;
    
    NSString *MacString;
    NSString *EditionString;
    
    QRCodeReaderView * readview;//二维码扫描对象
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}

@property(nonatomic,weak) UITableView *deviceTable;
@property(nonatomic,weak) UIView *backView;

@property (strong, nonatomic) CIDetector *detector;
@end

@implementation TwoDimensionalCodeScanViewController


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
    [self configureNavgationItemTitle:@"设备锁定"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak TwoDimensionalCodeScanViewController *weakself = self;
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself backButtonEvent];
    }];
    
    isFirst = YES;
    isPush = NO;
    [self InitScan];
    
    [AppDelegate currentAppDelegate].device3.scanDelete = self;
    deviceList=[[NSMutableDictionary alloc]init];
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(DeviceMac:) name:KNotification_Mac object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(DeviceEdition:) name:KNotification_Edition object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(reloadTableViewData:) name:KNotification_reloadTableViewData object:nil];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64)];
    [self.view addSubview:backView];
    self.backView = backView;
    UITableView *deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, backView.height)];
    deviceTable.delegate = self;
    deviceTable.dataSource = self;
    [deviceTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    self.deviceTable = deviceTable;
    [backView addSubview:deviceTable];
    
    backView.hidden = YES;
}

-(void)reloadTableViewData:(NSNotification*)notification{
    
    SearchBleModel *bleModel = notification.userInfo[@"searchmodel"];
    
    if ([rssiList containsObject: bleModel]) {
        
        [rssiList removeObject:bleModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.deviceTable reloadData];
    });
}

-(void)DeviceMac:(NSNotification*)notification{
    
    if (![AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    NSString *date = notification.userInfo[@"data"];
    
    for (int i = 0; i< 3; i++) {
        
        NSString *first = [date substringWithRange:NSMakeRange(i*2, 2)];
        NSString *second = [date substringWithRange:NSMakeRange((5-i)*2, 2)];
        date = [date stringByReplacingCharactersInRange:NSMakeRange(i*2, 2) withString:second];
        date = [date stringByReplacingCharactersInRange:NSMakeRange((5-i)*2, 2) withString:first];
    }
    
    MacString = date.uppercaseString;
    [[AppDelegate currentAppDelegate].device3 readDiviceInformation];
}

-(void)DeviceEdition:(NSNotification*)notification{
    
    if (![AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    NSString *date = notification.userInfo[@"data"];
    EditionString = date.uppercaseString;
    NSNumber *type= [NSNumber numberWithInt:2];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:FactoryUserDic];
    NSString *token= userDic[@"token"];
    NSNumber *device_id = [NSNumber numberWithInt:0];
    NSDictionary *DeviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:device_id,@"device_id",type,@"type",MacString,@"mac",codeNum,@"sn",EditionString,@"firm_version",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/regdevice"];
    NSDictionary *parameters = @{@"token": token, @"device_info":DeviceInfo};
    
    [[HttpRequest sharedInstance] postWithURLString2:URLString parameters:parameters success:^(id _Nullable dict) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(overtime) object:nil];
        if ([dict[@"status"] intValue] == 0) {
            NSLog(@"骑管家上传成功");
            [self uploadLYDevice];

        }else{
            [SVProgressHUD showSimpleText:@"骑管家外设上传失败"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}
//绿源外设上传
-(void)uploadLYDevice{
    
    NSString *token= [USER_DEFAULTS valueForKey:LYFactoryToken];
    NSNumber *device_id = [NSNumber numberWithInt:0];
    NSNumber *type= [NSNumber numberWithInt:2];
    NSDictionary *DeviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:device_id,@"device_id",type,@"type",MacString,@"mac",codeNum,@"sn",EditionString,@"firm_version",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",LYURL,@"factory/regdevice"];
    NSDictionary *parameters = @{@"token": token, @"device_info":DeviceInfo};
    
    [[HttpRequest sharedInstance] postWithLYURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        if ([dict[@"status"] intValue] == 0) {
            NSLog(@"绿源上传成功");
            [self uploadTLDevice];
        }else{
            [SVProgressHUD showSimpleText:@"绿源外设上传失败"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        
    }];
}
//台铃外设上传
-(void)uploadTLDevice{
    NSString *token= [USER_DEFAULTS valueForKey:TLFactoryToken];
    NSNumber *device_id = [NSNumber numberWithInt:0];
    NSNumber *type= [NSNumber numberWithInt:2];
    NSDictionary *DeviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:device_id,@"device_id",type,@"type",MacString,@"mac",codeNum,@"sn",EditionString,@"firm_version",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",TLURL,@"factory/regdevice"];
    NSDictionary *parameters = @{@"token": token, @"device_info":DeviceInfo};
    
    [[HttpRequest sharedInstance] postWithTLURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        if ([dict[@"status"] intValue] == 0) {
            NSLog(@"台铃上传成功");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:@"外设上传成功"];
            [[AppDelegate currentAppDelegate].device3 remove];
            self.backView.hidden = YES;
            codeNum = nil;
            MacString = nil;
            EditionString = nil;
        }else{
            [SVProgressHUD showSimpleText:@"台铃外设上传失败"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        
    }];
}


-(void)updateDeviceStatusAction:(NSNotification*)notification{
    
    if (![AppDelegate currentAppDelegate].IsCodeScan) {
        return;
    }
    
    int deviceTag=[notification.object intValue];
    if (deviceTag == 3) {
        
        if([AppDelegate currentAppDelegate].device3.deviceStatus == 0){
            
            
        }else if([AppDelegate currentAppDelegate].device3.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device3.deviceStatus<5){
            
            [[AppDelegate currentAppDelegate].device3 stopScan];
            [[AppDelegate currentAppDelegate].device3 readDiviceMac];
            
        }else{
            
            
        }
        
    }
    
}

-(void)dealloc{

    if ([[AppDelegate currentAppDelegate].device3 isConnected]) {
        
        [[AppDelegate currentAppDelegate].device3 remove];
        
    }
    [[AppDelegate currentAppDelegate].device3 stopScan];
    [AppDelegate currentAppDelegate].device3.scanDelete = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_UpdateDeviceStatus object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_Mac object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_Edition object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
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
    
    
    ascendArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(SearchBleModel* obj1, SearchBleModel* obj2)
                   {
                       float f1 = fabsf([obj1.rssiValue floatValue]);
                       float f2 = fabsf([obj2.rssiValue floatValue]);
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@   智能蓝牙钥匙%d",[ascendArray[indexPath.row] rssiValue] ,indexPath.row];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //[rssiList[indexPath.row] rssi]
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (int i=0; i<ascendArray.count; i++) {
        [[ascendArray objectAtIndex:indexPath.section] stopSearchBle];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"绑定中...";
    [[AppDelegate currentAppDelegate].device3 stopScan];
    
    [self performSelector:@selector(overtime) withObject:nil afterDelay:10];
    
    [AppDelegate currentAppDelegate]. device3.peripheral=[[ascendArray objectAtIndex:indexPath.row] peripher];
    NSLog(@"连接上的设备%@",[AppDelegate currentAppDelegate].device3.peripheral.identifier.UUIDString);
    [[AppDelegate currentAppDelegate].device3 connect];
    
}

-(void)overtime{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[AppDelegate currentAppDelegate].device3 remove];
    self.backView.hidden = YES;
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager.operationQueue cancelAllOperations];
    codeNum = nil;
    MacString = nil;
    EditionString = nil;
    [SVProgressHUD showSimpleText:@"绑定失败"];
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@" 扫描到 :%@",peripheral.name);
    if (peripheral.name.length < 7) {
        return;
    }
    
    if([[peripheral.name substringWithRange:NSMakeRange(0, 7)]isEqualToString: @"Qgj_Key"]){
        
        NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:RSSIVALUE];
        NSString *rssi = userDic[@"rssi"];
        
        if(![uuidarray objectForKey:peripheral.identifier.UUIDString]){
            
            if (RSSI.intValue > rssi.intValue  && RSSI.intValue < 0) {
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssiValue = RSSI;
                model.titlename = peripheral.name;
                model.searchCount = 1;
                [rssiList addObject:model];
                [uuidarray setObject:model forKey:peripheral.identifier.UUIDString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.deviceTable reloadData];
                });
            }
        }else{
            
            SearchBleModel *model = [uuidarray objectForKey:peripheral.identifier.UUIDString];
            if (RSSI.intValue >0 ) {
                model.rssiValue = [NSNumber numberWithInt:-64];;
            }else{
                model.rssiValue = RSSI;
            }
            
            if (RSSI.intValue < rssi.intValue && RSSI.intValue < 0) {
                [rssiList removeObject:model];
                [uuidarray removeObjectForKey:peripheral.identifier.UUIDString];
            }else{
                model.searchCount = 1;
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


@end
