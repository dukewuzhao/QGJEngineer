//
//  FounctionModel.m
//  QGJEngineer
//
//  Created by 吴兆华 on 2018/3/25.
//  Copyright © 2018年 comyou. All rights reserved.
//

#import "FounctionModel.h"

@implementation FounctionModel



- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.selectName forKey:@"selectName"];
    NSNumber *output = [NSNumber numberWithBool:self.select];
    [aCoder encodeObject:output forKey:@"select"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
        self.selectName = [aDecoder decodeObjectForKey:@"selectName"];
        NSNumber *output = [aDecoder decodeObjectForKey:@"select"];
        self.select = output.integerValue;
    }
    return self;
}

@end
