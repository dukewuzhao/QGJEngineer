//
//  BoxConnectViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/9/28.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "BoxConnectViewController.h"
#import "DeviceModel.h"


@interface BoxConnectViewController ()<ScanDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *rssiList;
    NSArray *ascendArray;
    NSMutableDictionary *uuidarray;
}

@property(nonatomic,weak) UITableView *choseView;

@end

@implementation BoxConnectViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [AppDelegate currentAppDelegate].device2.scanDelete = self;
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    [self configureNavgationItemTitle:@"测试盒子"];
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateBoxStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];
    
    WS(weakself);
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself popBoxView];
        
        
        
    }];
    [self configureRightBarButtonWithTitle:@"断开蓝牙" action:^{
        
        [weakself boxBreak];
        
       
        
    }];
    [self setuptable];
    
    [[AppDelegate currentAppDelegate].device2 startScan];
}

-(void)popBoxView{

    [[AppDelegate currentAppDelegate].device2 stopScan];
    [AppDelegate currentAppDelegate].device2.scanDelete = nil;
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)boxBreak{
    [[AppDelegate currentAppDelegate].device2 remove];
    
    [AppDelegate currentAppDelegate]. device2.deviceStatus=0;
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:[NSNumber numberWithInteger:2]]];
    [[AppDelegate currentAppDelegate].device2 stopScan];
    [AppDelegate currentAppDelegate].device2.scanDelete = nil;
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)setuptable{
    
    UITableView *choseView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //choseView.separatorStyle = NO;
    choseView.backgroundColor = [UIColor whiteColor];
    choseView.delegate = self;
    choseView.dataSource = self;
    [choseView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:choseView];
    self.choseView = choseView;
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
    //cell.textLabel.text = datarray[indexPath.row];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *bluename = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 150, 25)];
    
    bluename.text = [NSString stringWithFormat:@"智能蓝牙盒子%d",(int)indexPath.row +1];
    [cell addSubview:bluename];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[AppDelegate currentAppDelegate].device2 stopScan];
    
    [AppDelegate currentAppDelegate]. device2.peripheral=[[ascendArray objectAtIndex:indexPath.row] peripher];
    NSLog(@"连接上的设备%@",[AppDelegate currentAppDelegate].device2.peripheral.identifier.UUIDString);
    [[AppDelegate currentAppDelegate].device2 connect];
    
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (peripheral.name.length < 8) {
        return;
    }
    
    if([[peripheral.name substringWithRange:NSMakeRange(0, 8)]isEqualToString: @"Qgj-Test"]){
        
         
            DeviceModel *model=[[DeviceModel alloc]init];
            model.peripher=peripheral;
            model.rssivalue = RSSI;
            model.titlename = peripheral.name;
            
            if(![uuidarray objectForKey:peripheral.identifier.UUIDString]){
                [rssiList addObject:model];
               // NSLog(@" saomiaodao 2222:%@",title);
                [uuidarray setObject:peripheral.identifier.UUIDString forKey:peripheral.identifier.UUIDString];
                [self.choseView reloadData];
            }
        
    }
}

-(void)updateBoxStatusAction:(NSNotification*)notification{
    int deviceTag=[notification.object intValue];
    
    if (deviceTag == 2) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_UpdateDeviceStatus object:nil];
        [[AppDelegate currentAppDelegate].device2 stopScan];
        [AppDelegate currentAppDelegate].device2.scanDelete = nil;
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
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
