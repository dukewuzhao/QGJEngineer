//
//  PeripheralViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "PeripheralViewController.h"
#import "BottomBtn.h"
#import "TwoDimensionalCodeScanViewController.h"
#import "TestingViewController.h"
#import "LockViewController.h"
#import "SetRssiViewController.h"

@interface PeripheralViewController ()

@end

@implementation PeripheralViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    BottomBtn *SetupBtn = [[BottomBtn alloc] init];
    SetupBtn.width = 90;
    SetupBtn.height = 40;
    SetupBtn.x = ScreenWidth - 110;
    SetupBtn.y = 40;
    [SetupBtn setTitle:@"设置" forState:UIControlStateNormal];
    [SetupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [SetupBtn setImage:[UIImage imageNamed:@"icon_set"] forState:UIControlStateNormal];
    SetupBtn.titleLabel.font = [UIFont fontWithName:@"Courier-Bold" size:15];
    SetupBtn.contentMode = UIViewContentModeCenter;
    [SetupBtn addTarget:self action:@selector(SetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:SetupBtn];
    
    [self setupBtn];
}

- (void)setupBtn{
    
    for (int i = 0; i<3; i++) {
        
        UIButton *selectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, ScreenHeight *.2 +i*ScreenHeight*.23, ScreenWidth - 120, ScreenHeight *.15)];
        selectionBtn.tag = i+30;
        selectionBtn.backgroundColor = [UIColor cyanColor];
        if (i == 0) {
            [selectionBtn setTitle:@"设备注册" forState:UIControlStateNormal];
        }else if (i == 1){
        
            [selectionBtn setTitle:@"设备检测" forState:UIControlStateNormal];
        }else if (i == 2){
            
            [selectionBtn setTitle:@"设备绑定" forState:UIControlStateNormal];
        }
        
        [selectionBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:selectionBtn];
        
    }

}

- (void)btnClick:(UIButton *)btn{

    if (btn.tag == 30) {
        
        TwoDimensionalCodeScanViewController *registVc = [TwoDimensionalCodeScanViewController new];
        registVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:registVc animated:YES];
        
        
    }else if (btn.tag == 31){
    
        TestingViewController *testVc = [TestingViewController new];
        testVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testVc animated:YES];
    
    }else if (btn.tag == 32){
    
        LockViewController *lockVc = [LockViewController new];
        lockVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:lockVc animated:YES];
        
    }

}

- (void)SetBtnClick:(UIButton *)btn{

    SetRssiViewController *setVc = [SetRssiViewController new];
    setVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVc animated:YES];

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
