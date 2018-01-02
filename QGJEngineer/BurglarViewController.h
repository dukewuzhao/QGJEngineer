//
//  BurglarViewController.h
//  QGJEngineer
//
//  Created by smartwallit on 16/9/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ringmanager.h"
#import "FileTypeViewController.h"
#import "DFUOperations.h"
@interface BurglarViewController : UIViewController<FileTypeSelectionDelegate, DFUOperationsDelegate>

@property (nonatomic,retain)   Ringmanager *ringManager;

@end
