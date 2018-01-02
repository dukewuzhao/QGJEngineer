//
//  InductionKeyModel.h
//  QGJEngineer
//
//  Created by smartwallit on 16/12/27.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InductionKeyModel : NSObject

@property (nonatomic, copy) NSString *mac;

+ (instancetype)modalWith:(NSString *)mac;

@end
