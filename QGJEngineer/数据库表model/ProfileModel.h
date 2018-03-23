//
//  ProfileModel.h
//  golf
//
//  Created by qihwatech on 16/1/26.
//  Copyright (c) 2016年 qihwatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileModel : NSObject

@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, assign) NSInteger keytest;
@property (nonatomic, assign) NSInteger keyconfigure;
@property (nonatomic, assign) NSInteger inductionkey;//感应钥匙
@property (nonatomic, assign) NSInteger keynumber;
@property (nonatomic, copy) NSString *function1;
@property (nonatomic, copy) NSString *function2;
@property (nonatomic, copy) NSString *function3;
@property (nonatomic, copy) NSString *function4;
@property (nonatomic, assign) NSInteger routinetest;
@property (nonatomic, copy) NSString *line;
@property (nonatomic, assign) NSInteger onekeytest;//一键启动
@property (nonatomic, assign) NSInteger seat;//做通锁
@property (nonatomic, assign) NSInteger lock;
@property (nonatomic, assign) NSInteger calibration;
@property (nonatomic, assign) NSInteger shake;//震动
@property (nonatomic, assign) NSInteger buzzer;//蜂鸣器
@property (nonatomic, assign) NSInteger inducrssi;//感应钥匙rssi
@property (nonatomic, assign) NSInteger OneclickControl;//一键通控制
@property (nonatomic, assign) NSInteger OnelineSpeech;//一线通语音
@property (nonatomic, assign) NSInteger fingerPrint;//指纹测试
@property (nonatomic, assign) NSInteger firmware;//固件是否升级
@property (nonatomic, copy) NSString *firmversion;//固件版本
@property (nonatomic, copy) NSString *brand;

+ (instancetype)modalWith:(NSInteger)rssi keytest:(NSInteger)keytest keyconfigure:(NSInteger )keyconfigure inductionkey:(NSInteger )inductionkey keynumber:(NSInteger)keynumber function1:(NSString *)function1 function2:(NSString *)function2 function3:(NSString *)function3 function4:(NSString *)function4 routinetest:(NSInteger)routinetest line:(NSString *)line onekeytest:(NSInteger)onekeytest seat:(NSInteger)seat lock:(NSInteger)lock calibration:(NSInteger)calibration shake:(NSInteger)shake buzzer:(NSInteger)buzzer inducrssi:(NSInteger)inducrssi OneclickControl:(NSInteger)OneclickControl OnelineSpeech:(NSInteger)OnelineSpeech fingerPrint:(NSInteger)fingerPrint firmware:(NSInteger)firmware firmversion:(NSString *)firmversion brand:(NSString *)brand;

@end
