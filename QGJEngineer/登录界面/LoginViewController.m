//
//  LoginViewController.m
//  JinBang
//
//  Created by QFApple on 15/2/28.
//  Copyright (c) 2015年 qf365.com. All rights reserved.
//

#import "LoginViewController.h"
#import "DfuDownloadFile.h"
//#import "PhoneViewController.h"
//

@interface LoginViewController () <UITextFieldDelegate,DfuDownloadFileDelegate>
{
    
    NSString *child;
    
    NSString *main;
}
@property (nonatomic,weak) UITextField *usernameField; // 用户名
@property (nonatomic,weak) UITextField *passwordField; // 密码
@property (nonatomic,weak) UILabel *retrieveLabel; // 找回密码
@property (nonatomic,weak) UIButton *logBtn; // 登录按钮
@property (nonatomic,weak) UIView *headView;

@property(nonatomic,strong)NSMutableData *fileData;
//文件句柄
@property(nonatomic,strong)NSFileHandle *writeHandle;
//当前获取到的数据长度
@property(nonatomic,assign)long long currentLength;
//完整数据长度
@property(nonatomic,assign)long long sumLength;
//请求对象
@property(nonatomic,strong)NSURLConnection *cnnt;
@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
   // [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavgationItemTitle:@"登录"];
    [self initheadView];
    // 背景色
    //self.view.backgroundColor = [QFTools colorWithHexString:@"#FFFFFF"];

    [self setupField];    // 输入框
    [self setupLogBtn];  // 登录按钮
    
}

- (void)initheadView{
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 30 , ScreenWidth - 100, 150)];
    logoImage.image = [UIImage imageNamed:@"icon_logo"];
    [self.view addSubview:logoImage];
    
    UIView *headView = [[UIView alloc] init];
    headView.frame = CGRectMake(10,  CGRectGetMaxY(logoImage.frame) + 10, ScreenWidth - 20, 250);
    //headView.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    self.headView = headView;
    headView.layer.cornerRadius = 3;
    

}


#pragma mark - 用户名、密码输入框
- (void)setupField
{
    // 用户名
    CGFloat usernameFieldY = 20;
    CGFloat usernameFieldW = ScreenWidth * 0.9;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX = (self.headView.width - usernameFieldW) * 0.5;
    
    UITextField *usernameField = [self addOneTextFieldWithTitle:@"用户名／手机号" imageName:nil imageNameWidth:10 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    [self.headView addSubview:usernameField];
    self.usernameField = usernameField;
    
    // 密码
    CGFloat passwordFieldY = CGRectGetMaxY(self.usernameField.frame) + 20;
    CGFloat passwordFieldW = usernameFieldW;
    CGFloat passwordFieldH = usernameFieldH;
    CGFloat passwordFieldX = usernameFieldX;
    
    UITextField *passwordField = [self addOneTextFieldWithTitle1:@"请输入密码" imageName:nil imageNameWidth:10 Frame:CGRectMake(passwordFieldX, passwordFieldY, passwordFieldW, passwordFieldH)];
    passwordField.secureTextEntry = YES;
    [self.headView addSubview:passwordField];
    self.passwordField = passwordField;
    
    
}

#pragma mark - 添加输入框
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleBezel;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    [usernameField becomeFirstResponder];
    //field.keyboardType = UIKeyboardTypeNumberPad;
    field.delegate = self;
  //  field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    UIImage *fieldImage = [UIImage imageNamed:imageName];
//    UIImageView *fieldView = [[UIImageView alloc] initWithImage:fieldImage];
//    fieldView.width = width;
//    // 图片内容居中显示
//    fieldView.contentMode = UIViewContentModeScaleAspectFit;
//    field.leftView = fieldView;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    return field;
}

#pragma mark - 添加输入框
- (UITextField *)addOneTextFieldWithTitle1:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleBezel;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.passwordField becomeFirstResponder];
   // field.keyboardType = UIKeyboardTypeNumberPad;
    field.delegate = self;
    //  field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    UIImage *fieldImage = [UIImage imageNamed:imageName];
//    UIImageView *fieldView = [[UIImageView alloc] initWithImage:fieldImage];
//    fieldView.width = width;
//    // 图片内容居中显示
//    fieldView.contentMode = UIViewContentModeScaleAspectFit;
//    field.leftView = fieldView;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    return field;
}

#pragma mark - 登录按钮
- (void)setupLogBtn
{
    UIButton *logBtn = [[UIButton alloc] init];
    logBtn.frame = CGRectMake(self.usernameField.x , CGRectGetMaxY(self.passwordField.frame) + 25, self.usernameField.width, 35);
    logBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    [logBtn setTitle:@"登录" forState:UIControlStateNormal];
    [logBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    logBtn.titleLabel.font = FONT_YAHEI(16);
    logBtn.contentMode = UIViewContentModeCenter;
    [logBtn.layer setCornerRadius:5.0]; // 切圆角
    [logBtn addTarget:self action:@selector(logBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.headView addSubview:logBtn];
    self.logBtn = logBtn;
    
}


#pragma mark - 点击登录
- (void)logBtnBtnClick
{
//
    NSLog(@"用户名:%@ , 密码:%@",self.usernameField.text,self.passwordField.text);
    if ([QFTools isBlankString:self.usernameField.text] || [QFTools isBlankString:self.passwordField.text]) {
        [SVProgressHUD showSimpleText:@"请输入账号密码"];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"努力登录中...";
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"FACTORY"];
    NSString * md5=[QFTools md5:pwd];
    NSLog(@"%@",md5);
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/login"];
    NSDictionary *parameters = @{@"account": self.usernameField.text, @"passwd": md5};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
       
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSArray *Firms = data[@"Firms"];
            [LVFmdbTool deleteFirmData:nil];
            
            NSString * token=[data objectForKey:@"token"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",self.usernameField.text,@"phone_num",self.passwordField.text,@"password",nil];
            [userDefaults setObject:userDic forKey:FactoryUserDic];
            [userDefaults synchronize];
            
            for (NSDictionary *firmModel in Firms) {
                
                NSString *latest_version = firmModel[@"latest_version"];
                NSString *download = firmModel[@"download"];
                
                FirmVersionModel *pmodel = [FirmVersionModel modalWith:latest_version download:download];
                [LVFmdbTool insertFirmModel:pmodel];
                
                if ([firmModel[@"description"] isEqualToString:@"正式软件"]) {
                    
                    DfuDownloadFile *downloadfile = [[DfuDownloadFile alloc] init];
                    downloadfile.delegate = self;
                    [downloadfile startDownload:download];
                    
                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE p_profiles SET firmversion = '%@' WHERE id = 1", latest_version];
                    [LVFmdbTool modifyFirmData:updateSql];
                    [self updateversionDic:latest_version];
                }
                
            }
            
        }
            else if([dict[@"status"] intValue] == 1001){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

-(void)DownloadOver{
    
    [self LYFactorylogin];
}

-(void)DownloadBreak{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [SVProgressHUD showSimpleText:@"下载中断"];
}


//1
-(void)LYFactorylogin{
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",@"123456",@"FACTORY"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",LYURL,@"factory/login"];
    NSDictionary *parameters = @{@"account": @"lvyuan", @"passwd": md5};
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSString * token=[data objectForKey:@"token"];
            [USER_DEFAULTS setValue:token forKey:LYFactoryToken];
            [self TLFactorylogin];
        }
        else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        
    }];
    
}
//2
-(void)TLFactorylogin{
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",@"123456",@"FACTORY"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",TLURL,@"factory/login"];
    NSDictionary *parameters = @{@"account": @"tl", @"passwd": md5};
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSString * token=[data objectForKey:@"token"];
            [USER_DEFAULTS setValue:token forKey:TLFactoryToken];
            [self omelogin];//骑管家后台 品牌上传token
        }
        else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
}
//3
-(void)omelogin{
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"OEM"];
    NSString * md5=[QFTools md5:pwd];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"oem/login"];
    NSDictionary *parameters = @{@"account": self.usernameField.text, @"passwd": md5};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [LVFmdbTool deleteAllBrandData:nil];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            NSDictionary *data = dict[@"data"];
            NSString * token=[data objectForKey:@"token"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",self.usernameField.text,@"phone_num",self.passwordField.text,@"password",nil];
            [userDefaults setObject:userDic forKey:logInUSERDIC];
            [userDefaults synchronize];
            
            NSMutableArray *brands = data[@"brands"];
            [LVFmdbTool insertAllBrandModel:[AllBrandNameModel AllBrandModalWith:0 brandname:@"骑管家" logo:@"logo"]];
            for (NSDictionary *brandInfo in brands) {
                
                NSNumber *brand_id = brandInfo[@"brand_id"];
                NSString *brand_name = brandInfo[@"brand_name"];
                NSString *logo = brandInfo[@"logo"];
                AllBrandNameModel *pmodel = [AllBrandNameModel AllBrandModalWith:brand_id.intValue brandname:brand_name logo:logo];
                [LVFmdbTool insertAllBrandModel:pmodel];
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }
        else if([dict[@"status"] intValue] == 1001){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        
    }];
    
}



-(void)updateversionDic:(NSString *)NewVersion{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *verDic = [defaults objectForKey:versionDic];
    
    NSMutableDictionary *NewDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:verDic[@"settingmodel"],@"settingmodel",verDic[@"key1"],@"key1", verDic[@"key2"],@"key2",verDic[@"key3"],@"key3",verDic[@"key4"],@"key4",NewVersion,@"firmversion",nil];
    [defaults setObject:NewDic forKey:versionDic];
    [defaults synchronize];
    
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    
}

#pragma mark - pop
- (void)leftBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 监听输入框
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.usernameField.text.length && self.passwordField.text.length) {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    }else {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    }
    return YES;
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 100, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}
//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.usernameField.text.length && self.passwordField.text.length) {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    }else {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    }
    return YES;
    
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
}


@end
