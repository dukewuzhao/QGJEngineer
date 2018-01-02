
//
//  CustomProgress.m
//  WisdomPioneer
//
//  Created by 主用户 on 16/4/11.
//  Copyright © 2016年 江萧. All rights reserved.
//

#import "CustomProgress.h"
#define DURATION 0.7f
@implementation CustomProgress
@synthesize bgimg,leftimg,presentlab,instruc;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgimg.layer.borderColor = [UIColor clearColor].CGColor;
        bgimg.layer.borderWidth =  1;
        bgimg.layer.cornerRadius = 5;
        [bgimg.layer setMasksToBounds:YES];

        [self addSubview:bgimg];
        leftimg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 0, self.frame.size.height - 4)];
        leftimg.layer.borderColor = [UIColor clearColor].CGColor;
        leftimg.layer.borderWidth =  1;
        leftimg.layer.cornerRadius = 8;
        [leftimg.layer setMasksToBounds:YES];
        [self addSubview:leftimg];
        
        presentlab = [[UILabel alloc] initWithFrame:CGRectMake(0, - self.frame.size.height - 50, self.frame.size.width, self.frame.size.height)];
        presentlab.textAlignment = NSTextAlignmentCenter;
        presentlab.textColor = [UIColor whiteColor];
        presentlab.font = [UIFont systemFontOfSize:16];
        [self addSubview:presentlab];
        
        instruc = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftimg.frame) - 25, -30, 50,30 )];
        instruc.layer.borderColor = [UIColor clearColor].CGColor;
        instruc.layer.borderWidth =  1;
        instruc.layer.cornerRadius = 5;
        [instruc.layer setMasksToBounds:YES];
        
        [self addSubview:instruc];
        
    }
    return self;
}

-(void)animationTime{

    self.timer =[NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(timer2)
                                               userInfo:nil
                                                repeats:YES];

}

-(void)timer2
{
    [self ActionFanzhuan];
    
}

-(void)setPresent:(int)present
{
    //presentlab.text = [NSString stringWithFormat:@"%d％",present];
    leftimg.frame = CGRectMake(2, 2, (self.frame.size.width - 4)/self.maxValue*present, self.frame.size.height - 4);
    instruc.frame = CGRectMake(CGRectGetMaxX(leftimg.frame) - 25, -30, 50,30);
}

-(void)ActionFanzhuan{
    //获取当前画图的设备上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //开始准备动画
    [UIView beginAnimations:nil context:context];
    //设置动画曲线，翻译不准，见苹果官方文档
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //设置动画持续时间
    [UIView setAnimationDuration:1.0];
    //因为没给viewController类添加成员变量，所以用下面方法得到viewDidLoad添加的子视图
    //设置动画效果
    //[UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:parentView cache:YES];  //从上向下
    [self animationWithView:instruc WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];//翻转动画
    // [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:parentView cache:YES];   //从下向上
    // [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:parentView cache:YES];  //从左向右
    // [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:parentView cache:YES];//从右向左
    //设置动画委托
    [UIView setAnimationDelegate:self];
    //当动画执行结束，执行animationFinished方法
    [UIView setAnimationDidStopSelector:@selector(animationFinished:)];
    //提交动画
    [UIView commitAnimations];
}

//动画效果执行完毕
- (void) animationFinished: (id) sender{
    NSLog(@"animationFinished !");
}



#pragma UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:DURATION animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

-(void)stopAnimation{
    
    [self.timer invalidate];

}
-(void)startAnimation{

    [self animationTime];

}

@end
