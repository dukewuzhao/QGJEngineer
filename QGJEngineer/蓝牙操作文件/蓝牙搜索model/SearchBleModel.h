//
//  SearchBleModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/10/17.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchBleModel : NSObject

@property (nonatomic) CBPeripheral *peripher;

@property (nonatomic) NSString *titlename;

@property(nonatomic)  NSNumber* rssiValue;

@property(nonatomic,assign)  NSInteger searchCount;
-(void)stopSearchBle;

@end
