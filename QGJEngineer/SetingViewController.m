//
//  SetingViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/29.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "SetingViewController.h"
#import "SettingModel.h"
#import "LrdOutputView.h"
#import "DfuDownloadFile.h"
#import "lhScanQCodeViewController.h"


#define SETRSSI @"selected"
#define SETKEY @"selected2"
#define SETBUT1 @"selected3"
#define SETBUT2 @"selected4"
#define SETBUT3 @"selected5"
#define SETBUT4 @"selected6"
#define SETTEST @"selected7"
#define SETBRAND @"selecbrand"
#define SETINDUCKEY @"selected8"
#define SETINDUCRSSI @"selected9"


@interface SetingViewController ()<UITableViewDataSource,LrdOutputViewDelegate,UITableViewDelegate,UITextFieldDelegate,DfuDownloadFileDelegate,UIAlertViewDelegate>

{
    SettingModel *setmodel;
    
    NSString *downloadhttp;
}
@property (nonatomic,weak) UITextField *hardwareversionField;//硬件版本号输入
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *keyArr2;
@property (nonatomic, strong) NSArray *keyArr3;
@property (nonatomic, strong) NSArray *keyArr4;
@property (nonatomic, strong) NSMutableArray *keyArr5;//固件信息数组
@property (nonatomic, strong) LrdOutputView *outputView;
@property (nonatomic, weak) UITableView *setingTable;
@property (nonatomic, assign) NSInteger sectionNum;
@property (nonatomic, weak) LrdCellModel *Lrdmodel;
@property (nonatomic, strong) NSMutableArray *brands;

@end

@implementation SetingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionNum == 6) {
        
        LrdCellModel *model = self.dataArr[indexPath.row];
        if (indexPath.row == 1) {
            
            [_sectionArray replaceObjectAtIndex:6 withObject:model.title];
            [_sectionArray replaceObjectAtIndex:7 withObject:@"无"];
            [_sectionArray replaceObjectAtIndex:8 withObject:@"无"];
            [_sectionArray replaceObjectAtIndex:9 withObject:@"无"];
            
        }else{
        
            [_sectionArray replaceObjectAtIndex:6 withObject:model.title];
        
        }
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.setingTable reloadData];
        });

    }else if (self.sectionNum == 7){
        LrdCellModel *model = self.keyArr2[indexPath.row];
        if ([_sectionArray[6] isEqualToString:@"设防撤防"]) {
            
            switch (indexPath.row) {
                case 0:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 1:
                    [_sectionArray replaceObjectAtIndex:7 withObject:model.title];
                    break;
                
                default:
                    break;
            }
            
        }else{
            
            [_sectionArray replaceObjectAtIndex:7 withObject:model.title];
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.setingTable reloadData];
        });
    
    }else if (self.sectionNum == 8){
         LrdCellModel *model = self.keyArr3[indexPath.row];
        if ([_sectionArray[6] isEqualToString:@"设防撤防"] || [_sectionArray[9] isEqualToString:@"一键启动&开坐桶"]) {
            
            switch (indexPath.row) {
                case 0:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 1:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 2:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 3:
                    [_sectionArray replaceObjectAtIndex:8 withObject:model.title];
                    break;
                    
                default:
                    break;
            }
            
        }else{
            
            [_sectionArray replaceObjectAtIndex:8 withObject:model.title];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.setingTable reloadData];
        });
    
    }else if (self.sectionNum == 9){
        LrdCellModel *model = self.keyArr4[indexPath.row];
        if ([_sectionArray[6] isEqualToString:@"设防撤防"]) {
            
            switch (indexPath.row) {
                case 0:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 1:
                    [SVProgressHUD showSimpleText:@"钥匙类型不匹配"];
                    break;
                case 2:
                    [_sectionArray replaceObjectAtIndex:9 withObject:model.title];
                    break;
                default:
                    break;
            }
            
        }else{
            
            switch (indexPath.row) {
                case 1:
                    [_sectionArray replaceObjectAtIndex:8 withObject:@"无"];
                    break;
                default:
                    break;
            }
            
            [_sectionArray replaceObjectAtIndex:9 withObject:model.title];
            
        }
        //主线程uitableview刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.setingTable reloadData];
        });
    
    }else if (self.sectionNum == 20){
        _Lrdmodel = self.keyArr5[indexPath.row];
        
        if ([_Lrdmodel.title isEqualToString:_sectionArray[20]]) {
            return;
        }
        
        NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM firm_models WHERE latest_version LIKE '%@'", _Lrdmodel.title];
        NSMutableArray *modals = [LVFmdbTool queryFirmData:fuzzyQuerySql];
        FirmVersionModel *modelinfo = modals.firstObject;
        downloadhttp = modelinfo.download;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在下载版本...";
        DfuDownloadFile *downloadfile = [[DfuDownloadFile alloc] init];
        downloadfile.delegate = self;
        [downloadfile startDownload:downloadhttp];
        
    }
    
}


#pragma mark - 添加输入框方法
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.borderStyle = UITextBorderStyleBezel;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    [usernameField becomeFirstResponder];
    field.delegate = self;
    field.textColor = [UIColor blackColor];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIImage *fieldImage = [UIImage imageNamed:imageName];
    UIImageView *fieldView = [[UIImageView alloc] initWithImage:fieldImage];
    fieldView.width = width;
    // 图片内容居中显示
    fieldView.contentMode = UIViewContentModeScaleAspectFit;
    field.leftView = fieldView;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    return field;
}

- (NSMutableArray *)keyArr5 {
    if (!_keyArr5) {
        _keyArr5 = [[NSMutableArray alloc] init];
    }
    return _keyArr5;
}

- (NSMutableArray *)brands {
    if (!_brands) {
        _brands = [[NSMutableArray alloc] init];
    }
    return _brands;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    setmodel = [[SettingModel alloc] init];
    [self configureNavgationItemTitle:@"设置"];
    
    __weak SetingViewController *weakself = self;
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self setupmenu];
    [self setupmenu2];
    [self setupmenu3];
    [self setupmenu4];
    [self setupmenu5];
    
    [self configureRightBarButtonWithTitle:@"保存" action:^{
        
        [weakself saveBtn];
        
    }];
    
    UITableView *setingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    setingTable.backgroundColor = [UIColor whiteColor];
    setingTable.delegate = self;
    setingTable.dataSource = self;
    [setingTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:setingTable];
    self.setingTable = setingTable;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 45)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    setingTable.tableHeaderView = headView;
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
    name.text = @"硬件版本";
    name.textColor = [UIColor blackColor];
    name.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:name];
    
    UITextField *hardwareversionField = [self addOneTextFieldWithTitle:nil imageName:@"" imageNameWidth:10 Frame:CGRectMake(CGRectGetMaxX(name.frame), 5, ScreenWidth - 140, 35)];
    [headView addSubview:hardwareversionField];
    self.hardwareversionField = hardwareversionField;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *verDic = [defaults objectForKey:versionDic];
    hardwareversionField.text = verDic[@"version"];
    
    
    UIView *footVie = [[UIView alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 100)];
    
    UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 为button设置frame
    footerButton.frame = CGRectMake(0, 10, screenWidth, 40);
    footerButton.layer.cornerRadius = 5;
    [footerButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [footerButton setBackgroundColor:[UIColor brownColor]];
    // 这里为button添加相应事件
    [footerButton addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    [footVie addSubview:footerButton];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 为button设置frame
    scanButton.frame = CGRectMake(0, CGRectGetMaxY(footerButton.frame)+10, screenWidth, 40);
    scanButton.layer.cornerRadius = 5;
    [scanButton setTitle:@"APP扫描更新" forState:UIControlStateNormal];
    [scanButton setBackgroundColor:[UIColor brownColor]];
    // 这里为button添加相应事件
    [scanButton addTarget:self action:@selector(scanUpdate) forControlEvents:UIControlEventTouchUpInside];
    [footVie addSubview:scanButton];
    setingTable.tableFooterView = footVie;
    
    RssiArray = [NSMutableArray arrayWithObjects:@"-50",@"-51",@"-52",@"-53",@"-54",@"-55",@"-56",@"-57",@"-58",@"-59",@"-60",@"-61",@"-62",@"-63",@"-64",@"-65",@"-66",@"-67",@"-68",@"-69",@"-70", nil];
    
    InducRssiArray = [NSMutableArray arrayWithObjects:@"-50",@"-51",@"-52",@"-53",@"-54",@"-55",@"-56",@"-57",@"-58",@"-59",@"-60",@"-61",@"-62",@"-63",@"-64",@"-65",@"-66",@"-67",@"-68",@"-69",@"-70", nil];
    
    _sectionArray = [NSMutableArray arrayWithObjects:@"报警器RSSI",@"钥匙配置",@"钥匙测试",@"感应钥匙",@"感应钥匙RSSI",@"数量",verDic[@"key1"],verDic[@"key2"],verDic[@"key3"],verDic[@"key4"],@"常规测试",@"通讯线路测试",@"震动察觉测试",@"蜂鸣器测试",@"一键启动测试",@"坐桶测试",@"龙头锁&中撑锁测试",@"参数校准",@"一键通线路控制",@"语音测试",verDic[@"firmversion"],@"品牌选择", nil];
    
    
    lineArray = [NSMutableArray arrayWithObjects:@"无",@"单线测试",@"双线测试", nil];
    
    functionArray = [NSMutableArray arrayWithObjects:@"1号按键",@"2号按键",@"3号按键",@"4号按键", nil];
    
    keyArray = [NSMutableArray arrayWithObjects:@"1把",@"2把", nil];
    inductionkeyArray = [NSMutableArray arrayWithObjects:@"0把",@"1把",@"2把", nil];
    setArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *allbrands = [LVFmdbTool queryAllBrandData:nil];
    [self.brands addObject:@"无"];
    for (AllBrandNameModel *brandmodel in allbrands) {
        
        [self.brands addObject:brandmodel.brand_name];
        
    }
    
    
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM p_profiles WHERE id LIKE '%zd'", 1];
    NSMutableArray *modals = [LVFmdbTool queryPData:fuzzyinduSql];
    ProfileModel *pmodel = modals.firstObject;
    
    if (pmodel.keytest == 0) {
        
        setmodel.bool1 = NO;
        
    }else if (pmodel.keytest == 1){
    
        setmodel.bool1 = YES;
        
    }
    
    if (pmodel.keyconfigure == 0) {
        
        setmodel.bool2 = NO;
    }else if (pmodel.keyconfigure == 1){
        
        setmodel.bool2 = YES;
    }
    
    if (pmodel.routinetest == 0) {
        
        setmodel.bool3 = NO;
    }else if (pmodel.routinetest == 1){
        
        setmodel.bool3 = YES;
    }
    
    if (pmodel.onekeytest == 0) {
        
        setmodel.bool4 = NO;
    }else if (pmodel.onekeytest == 1){
        
        setmodel.bool4 = YES;
    }
    
    if (pmodel.seat == 0) {
        
        setmodel.bool5 = NO;
    }else if (pmodel.seat == 1){
        
        setmodel.bool5 = YES;
    }
    
    if (pmodel.lock == 0) {
        
        setmodel.bool6 = NO;
    }else if (pmodel.lock == 1){
        
        setmodel.bool6 = YES;
    }
    
    if (pmodel.calibration == 0) {
        
        setmodel.bool7 = NO;
    }else if (pmodel.calibration == 1){
        
        setmodel.bool7 = YES;
    }
    
    if (pmodel.shake == 0) {
        
        setmodel.bool8 = NO;
    }else if (pmodel.shake == 1){
        
        setmodel.bool8 = YES;
    }
    
    if (pmodel.buzzer == 0) {
        
        setmodel.bool9 = NO;
    }else if (pmodel.buzzer == 1){
        
        setmodel.bool9 = YES;
    }
    
    if (pmodel.firmware == 0) {
        
        setmodel.bool10 = NO;
    }else if (pmodel.firmware == 1){
        
        setmodel.bool10 = YES;
    }
    
    if (pmodel.OneclickControl == 0) {
        
        setmodel.oneClick = NO;
    }else if (pmodel.OneclickControl == 1){
        
        setmodel.oneClick = YES;
    }
    
    if (pmodel.OnelineSpeech == 0) {
        
        setmodel.oneLine = NO;
    }else if (pmodel.OnelineSpeech == 1){
        
        setmodel.oneLine = YES;
    }
    
    NSArray *pmodelArr = [QFTools  getClassAttribute:pmodel];
    
    for (int tt = 0; tt < pmodelArr.count; tt ++)
    {
        [setArray addObject:[NSString stringWithFormat:@"%@",[pmodel valueForKey:pmodelArr[tt]]]];
    }
    
}

-(void)saveBtn{

    if ([QFTools isBlankString:self.hardwareversionField.text]) {
        [SVProgressHUD showSimpleText:@"请输入硬件版本"];
        
        return ;
    }else if (self.hardwareversionField.text.length !=6){
        
        [SVProgressHUD showSimpleText:@"请输入6位硬件版本"];
        
        return ;
        
    }else if ([_sectionArray[6] isEqualToString:@"设防撤防"] && (![_sectionArray[7] isEqualToString:@"无"] || ![_sectionArray[8] isEqualToString:@"无"] || ![_sectionArray[9] isEqualToString:@"无"])){
        
        [SVProgressHUD showSimpleText:@"定义的钥匙按键不正确"];
        
        return;
        
    }
    
    [LVFmdbTool deleteData:nil];
    
    NSArray *array = @[setArray[5], setArray[6], setArray[7], setArray[8]];
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *item in array) {
        // 调用-containsObject:本质也是要循环去判断，因此本质上是双层遍历
        // 时间复杂度为O ( n^2 )而不是O (n)
        if (![resultArray containsObject:item]) {
            [resultArray addObject:item];
        }else{
            
            [resultArray removeAllObjects];
            [SVProgressHUD showSimpleText:@"定义的钥匙按键重复"];
            
            return ;
        }
    }
    
    NSString *rssi = setArray[0];
    NSString *keytest = setArray[1];
    NSString *keyconfigure = setArray[2];
    NSString *inductionkey = setArray[3];
    NSString *keynumber = setArray[4];
    NSString *function1 = setArray[5];
    NSString *function2 = setArray[6];
    NSString *function3 = setArray[7];
    NSString *function4 = setArray[8];
    NSString *routinetest = setArray[9];
    NSString *line = setArray[10];
    NSString *onekeytest = setArray[11];
    NSString *seat = setArray[12];
    NSString *lock = setArray[13];
    NSString *calibration = setArray[14];
    NSString *shake = setArray[15];
    NSString *buzzer = setArray[16];
    NSString *inducrssi = setArray[17];
    NSString *OneclickControl = setArray[18];
    NSString *OnelineSpeech = setArray[19];
    NSString *firmware = setArray[20];
    NSString *firmversion = setArray[21];
    NSString *brand = setArray[22];
    
    ProfileModel *pmodel = [ProfileModel modalWith:rssi.intValue keytest:keytest.intValue keyconfigure:keyconfigure.intValue inductionkey:inductionkey.intValue keynumber:keynumber.intValue function1:function1 function2:function2 function3:function3 function4:function4 routinetest:routinetest.intValue line:line onekeytest:onekeytest.intValue seat:seat.intValue lock:lock.intValue calibration:calibration.intValue shake:shake.intValue buzzer:buzzer.intValue inducrssi:inducrssi.intValue OneclickControl:OneclickControl.intValue OnelineSpeech:OnelineSpeech.intValue firmware:firmware.intValue firmversion:firmversion brand:brand];
    BOOL isInsertp = [LVFmdbTool insertPModel:pmodel];
    
    if (isInsertp) {
        
        NSLog(@"插入数据成功");
        [SVProgressHUD showSimpleText:@"保存成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"插入数据失败");
        [SVProgressHUD showSimpleText:@"保存失败"];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *verDic = [NSDictionary dictionaryWithObjectsAndKeys:self.hardwareversionField.text,@"version",_sectionArray[6],@"key1", _sectionArray[7],@"key2",_sectionArray[8],@"key3",_sectionArray[9],@"key4",_sectionArray[20],@"firmversion",nil];
    [userDefaults setObject:verDic forKey:versionDic];
    [userDefaults synchronize];
}


-(void)logoutClick{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否退出" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    alert.tag =4000;
    [alert show];
    
}

-(void)scanUpdate{
    
    lhScanQCodeViewController * sqVC = [[lhScanQCodeViewController alloc]init];
    [self.navigationController pushViewController:sqVC animated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (alertView.tag == 4000) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"退出账号中...";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                [userDefatluts removeObjectForKey:logInUSERDIC];
                [LVFmdbTool deleteFirmData:nil];
                [userDefatluts synchronize];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [SVProgressHUD showSimpleText:@"退出成功"];
                [AppDelegate currentAppDelegate].device.scanDelete = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
                
            });
            
        }
    }
    
    
}

#pragma mark -UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sectionArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 21;
    }else if (section == 3){
        return 3;
        
    }else if (section == 4){
        return 21;
        
    }else if (section == 5){
        return 2;
    
    }else if (section == 6){
        return 4;
        
    }else if (section == 7){
        
        return 4;
    }else if (section == 8){
        
        return 4;
    }else if (section == 9){
        
        return 4;
    }else if(section == 11){
    
        return 3;
    }else if(section == 21){
    
        return self.brands.count;
    }else{
    
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cell_id = @"profile";
    // 先从重用池中找cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        //cell必须先进行初始化
        cell = [[UITableViewCell alloc]init];
        //  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID andDataArr:[_courArrayM objectAtIndex:indexPath.row] andIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.separatorInset=UIEdgeInsetsZero;
        cell.clipsToBounds = YES;
        
        //设置cell点击无任何效果和背景色
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.section == 0) {
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 80, 12, 40, 20)];
            myLabel.text = RssiArray[indexPath.row];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETRSSI] isEqualToString:[RssiArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 3){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 80, 12, 40, 20)];
            myLabel.text =  inductionkeyArray[indexPath.row];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETINDUCKEY] isEqualToString:[inductionkeyArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 4){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 80, 12, 40, 20)];
            myLabel.text =  InducRssiArray[indexPath.row];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETINDUCRSSI] isEqualToString:[InducRssiArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 5){
        
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 80, 12, 40, 20)];
            myLabel.text =  keyArray[indexPath.row];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETKEY] isEqualToString:[keyArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        
        }else if (indexPath.section == 6){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",functionArray[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETBUT1] isEqualToString:[functionArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 7){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",functionArray[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETBUT2] isEqualToString:[functionArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 8){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",functionArray[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETBUT3] isEqualToString:[functionArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 9){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",functionArray[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETBUT4] isEqualToString:[functionArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        }else if (indexPath.section == 11){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",lineArray[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETTEST] isEqualToString:[lineArray objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }else if (indexPath.section == 21){
            
            UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 180, 12, 120, 20)];
            myLabel.text =  [NSString stringWithFormat:@"%@",self.brands[indexPath.row]];
            myLabel.textColor = [UIColor blackColor];
            myLabel.textAlignment = NSTextAlignmentRight;
            [cell addSubview:myLabel];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:SETBRAND] isEqualToString:[self.brands objectAtIndex:indexPath.row]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    }
    
    return cell;
}



- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    cell.backgroundColor = [UIColor whiteColor];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 45;

}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{   if (section == 0 || section == 4 || section == 9) {
        return 20;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
        
        return 45;
    }
    
    return 0;
}


//section头部显示的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    
    if (section%2) {
        
        header .backgroundColor  = [QFTools colorWithHexString:@"#f1f1f1"];
        
    }else{
        header .backgroundColor  = [UIColor cyanColor];
        
    }
    
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 12, 180, 20)];
    myLabel.text = [NSString stringWithFormat:@"%@",_sectionArray[section]];
    myLabel.textColor = [UIColor blackColor];
    [header addSubview:myLabel];
    
    // 单击的 Recognizer ,收缩分组cell
    header.tag = section;
    if (section == 0 || section == 3 ||section == 4 || section == 5 || section == 6 || section == 7 || section == 8 ||section == 9||section == 11||section == 21) {
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 40, 18, 14, 9)];
        image.image = [UIImage imageNamed:@"icon_down"];
        [header addSubview:image];
        
        if (section == 6 || section == 7 || section == 8 ||section == 9) {
            
            UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 45)];
            share.titleLabel.font = [UIFont systemFontOfSize:13];
            [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
            [share addTarget:self action:@selector(shareclick:) forControlEvents:UIControlEventTouchUpInside];
            share.backgroundColor = [UIColor clearColor];
            share.tag = section;
            [header addSubview:share];
            
        }
        
        
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [header addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    
    }else if (section == 20){
    
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 45)];
        share.titleLabel.font = [UIFont systemFontOfSize:13];
        [share setImage:[UIImage imageNamed:@"top_share"] forState:UIControlStateNormal];
        [share addTarget:self action:@selector(shareclick:) forControlEvents:UIControlEventTouchUpInside];
        share.backgroundColor = [UIColor clearColor];
        share.tag = section;
        [header addSubview:share];
        
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 5, 35, 35)];
        if (setmodel.bool10) {
            [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
        }else{
            
            [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
        }
        
        selectBtn.tag = section;
        [selectBtn addTarget:self action:@selector(selectbtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:selectBtn];
    
    }else{
        UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 5, 35, 35)];
        
        if (section == 1) {
            if (setmodel.bool1) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
            
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 2) {
            if (setmodel.bool2) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 10) {
            if (setmodel.bool3) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 12) {
            if (setmodel.bool4) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 13) {
            if (setmodel.bool5) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 14) {
            if (setmodel.bool6) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 15) {
            if (setmodel.bool7) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 16) {
            if (setmodel.bool8) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 17) {
            if (setmodel.bool9) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 18) {
            if (setmodel.oneClick) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }else if (section == 19) {
            if (setmodel.oneLine) {
                [selectBtn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            }else{
                
                [selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            }
        }
        
        selectBtn.tag = section;
        [selectBtn addTarget:self action:@selector(selectbtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:selectBtn];
    
    
        
    }
    
    if (section == 0) {
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.text = setArray[0];
        value.tag = 20;
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
    }else if (section == 3) {
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        if ([setArray[3] isEqualToString:@"0"]) {
            value.text = @"0把";
        }else if ([setArray[3] isEqualToString:@"1"]){
            
            value.text = @"1把";
        
        }else if ([setArray[3] isEqualToString:@"2"]){
            
            value.text = @"2把";
            
        }
        value.tag = 21;
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
    }else if (section == 4) {
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.text = setArray[17];
        value.tag = 28;
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
    }else if (section == 5) {
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        if ([setArray[4] isEqualToString:@"1"]){
            
            value.text = @"1把";
            
        }else if ([setArray[4] isEqualToString:@"2"]){
            
            value.text = @"2把";
            
        }
        value.tag = 22;
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
    }else if (section == 6){
    
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 23;
        value.text = setArray[5];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];

    }else if (section == 7){
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 24;
        value.text = setArray[6];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
        
    }else if (section == 8){
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 25;
        value.text = setArray[7];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
        
    }else if (section == 9){
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 26;
        value.text = setArray[8];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
        
    }else if (section == 11){
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 27;
        value.text = setArray[10];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
        
    }else if (section == 21){
        
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
        value.tag = 28;
        value.text = setArray[22];
        value.textColor = [UIColor blackColor];
        value.textAlignment = NSTextAlignmentRight;
        [header addSubview:value];
        
    }
    
    return header;
}

#pragma mark =====选择按键功能=====-
-(void)shareclick:(UIButton *)btn{
    self.sectionNum = btn.tag;
    CGRect rectInTableView = [self.setingTable rectForSection:btn.tag];
    CGRect rectInSuperview = [self.setingTable convertRect:rectInTableView toView:[self.view superview]];
    
    CGFloat x = btn.center.x + 80;
    CGFloat y = rectInSuperview.origin.y + btn.bounds.size.height;
    
    CGFloat y2 = rectInSuperview.origin.y - [LVFmdbTool queryFirmData:nil].count*44;
    if (btn.tag == 6) {
        
        _outputView = [[LrdOutputView alloc] initWithDataArray:self.dataArr origin:CGPointMake(x, y) width:125 height:44 direction:kLrdOutputViewDirectionRight];
        
    }else if (btn.tag == 7){
    
        _outputView = [[LrdOutputView alloc] initWithDataArray:self.keyArr2 origin:CGPointMake(x, y) width:125 height:44 direction:kLrdOutputViewDirectionRight];
    }else if (btn.tag == 8){
        
        _outputView = [[LrdOutputView alloc] initWithDataArray:self.keyArr3 origin:CGPointMake(x, y) width:125 height:44 direction:kLrdOutputViewDirectionRight];
    
    }else if (btn.tag == 9){
        
        _outputView = [[LrdOutputView alloc] initWithDataArray:self.keyArr4 origin:CGPointMake(x, y) width:125 height:44 direction:kLrdOutputViewDirectionRight];
    }else if (btn.tag == 20){
        
        _outputView = [[LrdOutputView alloc] initWithDataArray:[self.keyArr5 copy] origin:CGPointMake(x + 40, y2) width:160 height:44 direction:kLrdOutputViewDirectionRight];
    }
    
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        //设置成nil，以防内存泄露
        _outputView = nil;
    };
    [_outputView pop];
    
}

- (void)setupmenu{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"设防" imageName:@"item_school"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"设防撤防" imageName:@"item_school"];
    
    self.dataArr = @[one,two];
}

- (void)setupmenu2{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"撤防" imageName:@"item_school"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"无" imageName:@"item_school"];
    
    self.keyArr2 = @[one,two];
}

- (void)setupmenu3{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"寻车" imageName:@"item_school"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"静音" imageName:@"item_school"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"开坐桶" imageName:@"item_school"];
    LrdCellModel *four = [[LrdCellModel alloc] initWithTitle:@"无" imageName:@"item_school"];
    
    self.keyArr3 = @[one,two,three,four];
}

- (void)setupmenu4{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"一键启动" imageName:@"item_school"];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"一键启动&开坐桶" imageName:@"item_school"];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"无" imageName:@"item_school"];
    
    self.keyArr4 = @[one,two,three];
}

- (void)setupmenu5{
    [self.keyArr5 removeAllObjects];
    NSMutableArray *firmAry = [LVFmdbTool queryFirmData:nil];
    for (FirmVersionModel *firmodel in firmAry) {
        
        LrdCellModel *lrdcellmodel = [[LrdCellModel alloc] initWithTitle:firmodel.latest_version imageName:@"item_school"];
        [self.keyArr5 addObject:lrdcellmodel];
    }
}


- (void)selectbtnClick:(UIButton *)btn{
    
    if (btn.tag == 1) {
        
        setmodel.bool1 = !setmodel.bool1;
        
        if (setmodel.bool1) {
            
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:1 withObject:@"1"];
            
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:1 withObject:@"0"];
        }
        
    }else if (btn.tag == 2){
    
        setmodel.bool2 = !setmodel.bool2;
        
        if (setmodel.bool2) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:2 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:2 withObject:@"0"];
        }
        
    }else if (btn.tag == 10){
       
        setmodel.bool3 = !setmodel.bool3;
        
        if (setmodel.bool3) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:9 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:9 withObject:@"0"];
        }
        
    }else if (btn.tag == 12){
        
        setmodel.bool4 = !setmodel.bool4;
        
        if (setmodel.bool4) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:11 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:11 withObject:@"0"];
        }
        
    }else if (btn.tag == 13){
        
        setmodel.bool5 = !setmodel.bool5;
        
        if (setmodel.bool5) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:12 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:12 withObject:@"0"];
        }
        
    }else if (btn.tag == 14){
        
        setmodel.bool6 = !setmodel.bool6;
        
        if (setmodel.bool6) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:13 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:13 withObject:@"0"];
        }
    }else if (btn.tag == 15){
        
        setmodel.bool7 = !setmodel.bool7;
        
        if (setmodel.bool7) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:14 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:14 withObject:@"0"];
        }
    }else if (btn.tag == 16){
        
        setmodel.bool8 = !setmodel.bool8;
        
        if (setmodel.bool8) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:15 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:15 withObject:@"0"];
        }
    }else if (btn.tag == 17){
        
        setmodel.bool9 = !setmodel.bool9;
        
        if (setmodel.bool9) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:16 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:16 withObject:@"0"];
        }
    }else if (btn.tag == 18){
        
        setmodel.oneClick = !setmodel.oneClick;
        
        if (setmodel.oneClick) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:18 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:18 withObject:@"0"];
        }
    }else if (btn.tag == 19){
        
        setmodel.oneLine = !setmodel.oneLine;
        
        if (setmodel.oneLine) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:19 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:19 withObject:@"0"];
        }
    }else if (btn.tag == 20){
        
        setmodel.bool10 = !setmodel.bool10;
        
        if (setmodel.bool10) {
            [btn setImage:[UIImage imageNamed:@"iconchecked"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:20 withObject:@"1"];
        }else{
            
            [btn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
            [setArray replaceObjectAtIndex:20 withObject:@"0"];
        }
    }
    


}

#pragma mark 展开收缩section中cell 手势监听
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    NSInteger didSection = recognizer.view.tag;
    
    if (!_showDic) {
        _showDic = [[NSMutableDictionary alloc]init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)didSection];
    if (![_showDic objectForKey:key]) {
        [_showDic setObject:@"1" forKey:key];
        
    }else{
        [_showDic removeObjectForKey:key];
        
    }
    [self.setingTable reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UILabel *lab1=(UILabel*)[self.view viewWithTag:20];
    UILabel *lab2=(UILabel*)[self.view viewWithTag:21];
    UILabel *lab3=(UILabel*)[self.view viewWithTag:22];
    UILabel *lab4=(UILabel*)[self.view viewWithTag:23];
    UILabel *lab5=(UILabel*)[self.view viewWithTag:24];
    UILabel *lab6=(UILabel*)[self.view viewWithTag:25];
    UILabel *lab7=(UILabel*)[self.view viewWithTag:26];
    UILabel *lab8=(UILabel*)[self.view viewWithTag:27];
    UILabel *lab9=(UILabel*)[self.view viewWithTag:28];
    
    if (indexPath.section == 0) {
        
        [[NSUserDefaults standardUserDefaults]setValue:[RssiArray objectAtIndex:indexPath.row] forKey:SETRSSI];
        lab1.text = RssiArray[indexPath.row];
        [setArray replaceObjectAtIndex:0 withObject:RssiArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 3){
        
        [[NSUserDefaults standardUserDefaults]setValue:[inductionkeyArray objectAtIndex:indexPath.row] forKey:SETINDUCKEY];
        lab2.text = inductionkeyArray[indexPath.row];
        [setArray replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 4){
        
        [[NSUserDefaults standardUserDefaults]setValue:[InducRssiArray objectAtIndex:indexPath.row] forKey:SETINDUCRSSI];
        lab9.text = InducRssiArray[indexPath.row];
        [setArray replaceObjectAtIndex:17 withObject:InducRssiArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 5){
        
        [[NSUserDefaults standardUserDefaults]setValue:[keyArray objectAtIndex:indexPath.row] forKey:SETKEY];
        lab3.text = keyArray[indexPath.row];
        [setArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row + 1]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 6){
        
        [[NSUserDefaults standardUserDefaults]setValue:[functionArray objectAtIndex:indexPath.row] forKey:SETBUT1];
        lab4.text = functionArray[indexPath.row];
        [setArray replaceObjectAtIndex:5 withObject:functionArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 7){
        
        [[NSUserDefaults standardUserDefaults]setValue:[functionArray objectAtIndex:indexPath.row] forKey:SETBUT2];
        lab5.text = functionArray[indexPath.row];
        [setArray replaceObjectAtIndex:6 withObject:functionArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 8){
        
        [[NSUserDefaults standardUserDefaults]setValue:[functionArray objectAtIndex:indexPath.row] forKey:SETBUT3];
        lab6.text = functionArray[indexPath.row];
        [setArray replaceObjectAtIndex:7 withObject:functionArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 9){
        
        [[NSUserDefaults standardUserDefaults]setValue:[functionArray objectAtIndex:indexPath.row] forKey:SETBUT4];
        lab7.text = functionArray[indexPath.row];
        [setArray replaceObjectAtIndex:8 withObject:functionArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 11){
        
        [[NSUserDefaults standardUserDefaults]setValue:[lineArray objectAtIndex:indexPath.row] forKey:SETTEST];
        lab8.text = lineArray[indexPath.row];
        [setArray replaceObjectAtIndex:10 withObject:lineArray[indexPath.row]];
        [self.setingTable reloadData];
        
    }else if (indexPath.section == 21){
        
        [[NSUserDefaults standardUserDefaults]setValue:[self.brands objectAtIndex:indexPath.row] forKey:SETBRAND];
        lab8.text = self.brands[indexPath.row];
        [setArray replaceObjectAtIndex:22 withObject:self.brands[indexPath.row]];
        [self.setingTable reloadData];
        
    }
    
}

-(void)DownloadOver{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_sectionArray replaceObjectAtIndex:20 withObject:_Lrdmodel.title];
    [setArray replaceObjectAtIndex:21 withObject:_Lrdmodel.title];
    //主线程uitableview刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.setingTable reloadData];
    });
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *verDic = [NSDictionary dictionaryWithObjectsAndKeys:self.hardwareversionField.text,@"version",_sectionArray[6],@"key1", _sectionArray[7],@"key2",_sectionArray[8],@"key3",_sectionArray[9],@"key4",_sectionArray[20],@"firmversion",nil];
    [userDefaults setObject:verDic forKey:versionDic];
    [userDefaults synchronize];
    
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE p_profiles SET firmversion = '%@' WHERE id = 1", _sectionArray[20]];
    [LVFmdbTool modifyFirmData:updateSql];
}

-(void)DownloadBreak{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD showSimpleText:@"下载中断"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
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
