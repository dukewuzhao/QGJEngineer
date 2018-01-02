//
//  ProfileModel.m
//  golf
//
//  Created by qihwatech on 16/1/26.
//  Copyright (c) 2016年 qihwatech. All rights reserved.
//

#import "ProfileModel.h"

@implementation ProfileModel

+ (instancetype)modalWith:(NSInteger)rssi keytest:(NSInteger)keytest keyconfigure:(NSInteger )keyconfigure inductionkey:(NSInteger)inductionkey keynumber:(NSInteger)keynumber function1:(NSString *)function1 function2:(NSString *)function2 function3:(NSString *)function3 function4:(NSString *)function4 routinetest:(NSInteger)routinetest line:(NSString *)line onekeytest:(NSInteger)onekeytest seat:(NSInteger)seat lock:(NSInteger)lock calibration:(NSInteger)calibration shake:(NSInteger)shake buzzer:(NSInteger)buzzer inducrssi:(NSInteger)inducrssi OneclickControl:(NSInteger)OneclickControl OnelineSpeech:(NSInteger)OnelineSpeech firmware:(NSInteger)firmware firmversion:(NSString *)firmversion brand:(NSString *)brand{
    
    ProfileModel *model = [[self alloc] init];
    model.rssi = rssi;
    model.keytest = keytest;
    model.keyconfigure = keyconfigure;
    model.inductionkey = inductionkey;
    model.keynumber = keynumber;
    model.function1 = function1;
    model.function2 = function2;
    model.function3 = function3;
    model.function4 = function4;
    model.routinetest= routinetest;
    model.line = line;
    model.onekeytest = onekeytest;
    model.seat = seat;
    model.lock = lock;
    model.calibration = calibration;
    model.shake = shake;
    model.buzzer = buzzer;
    model.inducrssi = inducrssi;
    model.OneclickControl = OneclickControl;
    model.OnelineSpeech = OnelineSpeech;
    model.firmware = firmware;
    model.firmversion = firmversion;
    model.brand = brand;
    
    return model;
}


@end
