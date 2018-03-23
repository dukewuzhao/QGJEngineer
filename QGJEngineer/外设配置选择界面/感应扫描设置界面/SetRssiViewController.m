//
//  SetRssiViewController.m
//  QGJEngineer
//
//  Created by smartwallit on 16/10/10.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "SetRssiViewController.h"
#import "lhScanQCodeViewController.h"
#define SETRSSI @"selectrssi"

@interface SetRssiViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UITableView *setingTable;

@end

@implementation SetRssiViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureNavgationItemTitle:@"设置"];
    
    __weak SetRssiViewController *weakself = self;
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self configureRightBarButtonWithTitle:@"保存" action:^{
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:SetRssiArray[0],@"rssi", nil];
        [userDefaults setObject:userDic forKey:RSSIVALUE];
        [userDefaults synchronize];
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    UITableView *setingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStyleGrouped];
    setingTable.backgroundColor = [UIColor whiteColor];
    setingTable.delegate = self;
    setingTable.dataSource = self;
    [setingTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:setingTable];
    self.setingTable = setingTable;
    
    RssiArray = [NSMutableArray arrayWithObjects:@"-50",@"-51",@"-52",@"-53",@"-54",@"-55",@"-56",@"-57",@"-58",@"-59",@"-60",@"-61",@"-62",@"-63",@"-64",@"-65",@"-66",@"-67",@"-68",@"-69",@"-70", nil];
    
    SetRssiArray = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:RSSIVALUE];
    
    [SetRssiArray addObject:userDic[@"rssi"]];
    
}

#pragma mark -UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 21;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cell_id = @"tablieview";
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
            
        }
    
    return cell;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    cell.backgroundColor = [UIColor whiteColor];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 45;
    
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
    
    header .backgroundColor  = [QFTools colorWithHexString:@"#f1f1f1"];
    
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 12, 120, 20)];
    myLabel.text = @"蓝牙RSSI";
    myLabel.textColor = [UIColor blackColor];
    [header addSubview:myLabel];
    // 单击的 Recognizer ,收缩分组cell
    header.tag = section;
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 40, 18, 14, 9)];
    image.image = [UIImage imageNamed:@"icon_down"];
    [header addSubview:image];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [header addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    
    UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 160, 12, 100, 20)];
    value.text = SetRssiArray[0];
    value.tag = 50;
    value.textColor = [UIColor blackColor];
    value.textAlignment = NSTextAlignmentRight;
    [header addSubview:value];
    
    
    return header;
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
    
    UILabel *lab1=(UILabel*)[self.view viewWithTag:50];
    
    [[NSUserDefaults standardUserDefaults]setValue:[RssiArray objectAtIndex:indexPath.row] forKey:SETRSSI];
    lab1.text = RssiArray[indexPath.row];
    [SetRssiArray replaceObjectAtIndex:0 withObject:RssiArray[indexPath.row]];
    [self.setingTable reloadData];
    
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
