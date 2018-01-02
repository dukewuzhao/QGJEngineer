//
//  UIBarButtonItem+HC.h
//  jinbang
//
//  Created by 同时 on 14-8-6.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "UIBarButtonItem+HC.h"

@implementation UIBarButtonItem (HC)

+ (UIBarButtonItem *)barButtonItemWithImageName:(NSString *)name highlightedName:(NSString *)highName target:(id)target action:(SEL)sel
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highName] forState:UIControlStateHighlighted];
    btn.size = CGSizeMake(45, 45); // curreutImage 只能是图片不能是背景图
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    // 将UIButton包装成UIBarButtonItem
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return itemBtn;
}

@end
