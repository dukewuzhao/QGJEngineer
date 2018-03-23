//
//  AllBrandNameModel.m
//  QGJEngineer
//
//  Created by Apple on 2017/8/14.
//  Copyright © 2017年 comyou. All rights reserved.
//

#import "AllBrandNameModel.h"

@implementation AllBrandNameModel


+ (instancetype)AllBrandModalWith:(NSInteger )brand_id brandname:(NSString *)brand_name logo:(NSString *)logo{
    
    AllBrandNameModel *model = [[self alloc] init];
    model.brand_id = brand_id;
    model.brand_name = brand_name;
    model.logo = logo;
    
    return model;
    
}

@end
