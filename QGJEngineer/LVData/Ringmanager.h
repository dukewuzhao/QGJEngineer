//
//  Ringmanager.h
//  SmartKee
//
//  Created by AlanWang on 14-6-24.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayDelegate <NSObject>
@required
-(void)didFinishPlay;

@end

@interface Ringmanager : NSObject<AVAudioPlayerDelegate>

@property (assign, nonatomic) id<PlayDelegate>      playDelegate;

 @property (retain, nonatomic)    AVAudioPlayer       *thePlayer;
 
-(void)play:(int)type withLoop:(NSInteger)loop ;

-(void)stopPlay;


-(void)playVibrate:(NSInteger )time;//time：震动时间,单位秒
-(void)stopVibrate;


-(double)playWithPath:(NSString *)path andLoop:(NSInteger)loop needVibrate:(BOOL)need;

@end

