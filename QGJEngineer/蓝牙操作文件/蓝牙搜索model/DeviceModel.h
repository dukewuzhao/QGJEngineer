//
//  DeviceModel.h
//  SmartECH
//
//  Created by smartwallit on 16/4/26.
//  Copyright © 2016年 Tonshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface DeviceModel : NSObject

@property (nonatomic) CBPeripheral *peripher;

@property (nonatomic) NSString *titlename;
@property(nonatomic)  NSNumber* rssivalue;

@end
