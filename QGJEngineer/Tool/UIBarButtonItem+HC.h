//
//  UIBarButtonItem+HC.h
//  jinbang
//
//  Created by 同时科技 on 14-8-6.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HC)

/** 自定义barButton */
+ (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)name highlightedName:(NSString *)highName target:(id)target action:(SEL)sel;

@end
