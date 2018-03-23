//
//  BottomBtn.m
//  ylss
//
//  Created by yons on 15/8/15.
//  Copyright (c) 2015年 yfapp. All rights reserved.
//

#import "BottomBtn.h"

@implementation BottomBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel.font = FONT_YAHEI(12);
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = self.width * 0.5;
    CGFloat titleW = 40;
    CGFloat titleH = 20;
    CGFloat titleY = (self.height - titleH) * 0.5;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageW = 32;
    CGFloat imageH = 32;
    CGFloat imageX = 5;
    CGFloat imageY = (self.height - imageH) * 0.5;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end
