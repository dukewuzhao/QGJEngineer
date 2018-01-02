//
//  CustomProgress.h
//  WisdomPioneer
//
//  Created by 主用户 on 16/4/11.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProgress : UIView
@property(nonatomic, retain)UIImageView *bgimg;
@property(nonatomic, retain)UIImageView *leftimg;
@property(nonatomic, retain)UIImageView *instruc;
@property(nonatomic, retain)UILabel *presentlab;
@property(nonatomic)float maxValue;
@property(nonatomic, weak) NSTimer* timer;
-(void)setPresent:(int)present;
-(void)stopAnimation;
-(void)startAnimation;
@end
