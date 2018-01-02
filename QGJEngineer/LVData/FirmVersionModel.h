//
//  FirmVersionModel.h
//  QGJEngineer
//
//  Created by Apple on 2017/4/27.
//  Copyright © 2017年 comyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FirmVersionModel : NSObject

@property (nonatomic, copy) NSString *latest_version;

@property (nonatomic, copy) NSString *download;

+ (instancetype)modalWith:(NSString *)latest_version download:(NSString *)download;

@end
