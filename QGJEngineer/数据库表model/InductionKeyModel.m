//
//  InductionKeyModel.m
//  QGJEngineer
//
//  Created by smartwallit on 16/12/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import "InductionKeyModel.h"

@implementation InductionKeyModel

+ (instancetype)modalWith:(NSString *)mac{

    InductionKeyModel *model = [[self alloc] init];
    model.mac = mac;
    
    return model;
    
}

@end
