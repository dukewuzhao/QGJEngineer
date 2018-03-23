//
//  FirmVersionModel.m
//  QGJEngineer
//
//  Created by Apple on 2017/4/27.
//  Copyright © 2017年 comyou. All rights reserved.
//

#import "FirmVersionModel.h"

@implementation FirmVersionModel

+ (instancetype)modalWith:(NSString *)latest_version download:(NSString *)download{

    FirmVersionModel *model = [[self alloc] init];

    model.latest_version = latest_version;
    model.download = download;
    
    return model;
}



@end
