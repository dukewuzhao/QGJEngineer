//
//  MainViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "MainViewController.h"
#import "BurglarViewController.h"
#import "PeripheralViewController.h"



#define ShareApp ((AppDelegate *)[[UIApplication sharedApplication] delegate])
@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewWillLayoutSubviews{
    
    CGRect frame = self.tabBar.frame;
    frame.size.height = 80;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.tabBar.frame = frame;
    
    //self.tabBar.barStyle = UIBarStyleBlack;//此处需要设置barStyle，否则颜色会分成上下两层
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.tabBar.tintColor=[UIColor whiteColor];
        UIImage *select = [UIImage imageNamed:@"tab_favorite_red"];
        self.tabBarItem.selectedImage = [select imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBar.tintColor=[UIColor colorWithRed:84.0/255 green:11.0/255 blue:111.0/255 alpha:1.0];
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // [self.navigationController.navigationBar setHidden:YES];
    //self.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //tabbar不透明
    self.tabBarController.tabBar.translucent = NO;
    
    [self addAllChildVcs];

    self.tabBar.opaque = YES;
    
    //设置tabbar的title的位置
    UITabBarItem* it = [[self.tabBarController.tabBar items] objectAtIndex:0];
    it.titlePositionAdjustment = UIOffsetMake(0.0, 2.0);
    
    self.view.backgroundColor = [UIColor cyanColor];
    
}

- (void)addAllChildVcs{

    UITabBarItem *item1 = [[UITabBarItem alloc] init];
    item1.tag = 1;
    [item1 setTitle:@"报警器"];
    [item1 setImage:[UIImage imageNamed:@"bg-1-n-1"]];
    [item1 setSelectedImage:[[UIImage imageNamed:@""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor lightGrayColor], UITextAttributeTextColor,
                                   nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = [UIColor orangeColor];
    [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   titleHighlightedColor, UITextAttributeTextColor,
                                   nil] forState:UIControlStateSelected];
    
    
    UITabBarItem *item2 = [[UITabBarItem alloc] init];
    item2.tag = 2;
    
    [item2 setTitle:@"外设"];
    [item2 setImage:[UIImage imageNamed:@"bg-2-n-1"]];
    [item2 setSelectedImage:[[UIImage imageNamed:@"bg-01"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor lightGrayColor], UITextAttributeTextColor,
                                   nil] forState:UIControlStateNormal];
    [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIColor orangeColor], UITextAttributeTextColor,
                                   nil] forState:UIControlStateSelected];
    
    
    
    BurglarViewController *bikeController = [BurglarViewController new];
    bikeController.tabBarItem = item1;
    UINavigationController *bikeNavController = [[UINavigationController alloc] initWithRootViewController:bikeController];
    
    
    PeripheralViewController *mapVC = [PeripheralViewController new];
    mapVC.tabBarItem = item2;
    UINavigationController *mapNavController = [[UINavigationController alloc] initWithRootViewController:mapVC];
    

    self.viewControllers = [NSArray arrayWithObjects:bikeNavController,mapNavController, nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == 1){
        
        NSLog(@"TestOneController");
        //  [self.tabBarController.tabBarsetSelectedImageTintColor:[UIColor greenColor]];
        [AppDelegate currentAppDelegate].IsCodeScan = NO;
        
    }else if(item.tag == 2){
        
        NSLog(@"TestTwoController");
        [AppDelegate currentAppDelegate].IsCodeScan = YES;
    }else if(item.tag == 3){
        
        NSLog(@"TestThirdController");
        
    }
    
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
