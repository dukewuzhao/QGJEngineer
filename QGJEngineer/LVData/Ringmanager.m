//
//  Ringmanager.m
//  SmartKee
//
//  Created by AlanWang on 14-6-24.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//

#import "Ringmanager.h"

@implementation Ringmanager{
    BOOL canVibrate;
    double vibrateInterval;
}

-(instancetype)init{
    vibrateInterval=1;
    
    return [super init];
}

-(double)playWithPath:(NSString *)path andLoop:(NSInteger)loop needVibrate:(BOOL)need{
    NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:path];
    _thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    _thePlayer.delegate = self;
    // 创建播放器
    [_thePlayer prepareToPlay];
    [_thePlayer setVolume:1];
    _thePlayer.numberOfLoops = loop-1;
    
    double duration= [_thePlayer duration]*(loop+0.5);
   // vibrateInterval=[_thePlayer duration];
    
    if(need)
    [self playVibrate:loop];
    
    [_thePlayer play];
    
    return duration;
}

-(void)play:(int)type withLoop:(NSInteger)loop
{
    //播放背景音乐
    NSString *musicPath;
    
    switch (type) {
        case 11://设备找手机
            musicPath= [[NSBundle mainBundle] pathForResource:@"cat" ofType:@"mp3"];
            loop=-1;
            break;
        case 21://要求手机报警
            musicPath= [[NSBundle mainBundle] pathForResource:@"bird" ofType:@"wav"];
            loop=loop-1;
            break;
        case 71://低电量
            musicPath= [[NSBundle mainBundle] pathForResource:@"dog" ofType:@"wav"];
            loop=0;
            break;
        case 72://0电量关机
            musicPath= [[NSBundle mainBundle] pathForResource:@"dog" ofType:@"wav"];
            loop=0;
            break;
        case 73://充满电
            musicPath= [[NSBundle mainBundle] pathForResource:@"dog" ofType:@"wav"];
            loop=0;
            break;
        case 88://行李到达
             musicPath= [[NSBundle mainBundle] pathForResource:@"cat" ofType:@"mp3"];
             loop=2;
            break;
        case 99:
            musicPath= [[NSBundle mainBundle] pathForResource:@"didi" ofType:@"mp3"];
            loop=0;
            break;
        case 100://手机 预警
             musicPath= [[NSBundle mainBundle] pathForResource:@"warning" ofType:@"mp3"];
            loop=loop-1;
            break;
        default:
            break;
    }
    
    NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicPath];
    _thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
   // _thePlayer.delegate = self;
    // 创建播放器
    [_thePlayer prepareToPlay];
    [_thePlayer setVolume:1];
    _thePlayer.numberOfLoops = loop;
    [_thePlayer play];

}

-(void)stopPlay{
    [_thePlayer stop];
}

-(void)stopVibrate{
    canVibrate=NO;
}

-(void)playVibrate:(NSInteger)time{
    
    canVibrate=YES;
    [self performSelectorInBackground:@selector(vibrate:) withObject:[NSNumber numberWithInteger:time]];
}
-(void)vibrate:(NSNumber *)time{
    NSInteger i=0;
    NSLog(@"start vibrate");
    
    while (i<[time integerValue] && canVibrate) {
        [NSThread sleepForTimeInterval:vibrateInterval];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        i++;
       
    }
    [self stopVibrate];
  //  NSLog(@"stop");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
  //  NSLog(@"播放结束");
    [self stopVibrate];
    
    if(self.playDelegate!=nil&& [self.playDelegate respondsToSelector:@selector(didFinishPlay)]){
        [self.playDelegate didFinishPlay];
    }
}



@end
