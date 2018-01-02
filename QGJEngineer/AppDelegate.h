//
//  AppDelegate.h
//  QGJEngineer
//
//  Created by smartwallit on 16/9/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
//#import "BurglarViewController.h"
#import "WYDevice.h"
#import "Ringmanager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainController;

@property (nonatomic,retain)   WYDevice *device;
@property (nonatomic,retain)   WYDevice *device2;
@property (nonatomic,retain)   WYDevice *device3;
@property (nonatomic,retain)   WYDevice *device4;
@property (nonatomic,retain)   Ringmanager *ringManager;
@property (assign, nonatomic) BOOL IsCodeScan;
+ (AppDelegate *)currentAppDelegate;



@end

