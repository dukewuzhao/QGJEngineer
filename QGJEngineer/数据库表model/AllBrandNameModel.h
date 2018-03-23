//
//  AllBrandNameModel.h
//  QGJEngineer
//
//  Created by Apple on 2017/8/14.
//  Copyright © 2017年 comyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllBrandNameModel : NSObject

@property (nonatomic, assign) NSInteger brand_id;
@property (nonatomic, copy) NSString* brand_name;
@property (nonatomic, copy) NSString* logo;//感应钥匙

+ (instancetype)AllBrandModalWith:(NSInteger )brand_id brandname:(NSString *)brand_name logo:(NSString *)logo;

@end
