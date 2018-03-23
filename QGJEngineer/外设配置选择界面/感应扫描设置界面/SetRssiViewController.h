//
//  SetRssiViewController.h
//  QGJEngineer
//
//  Created by smartwallit on 16/10/10.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetRssiViewController : BaseViewController
{
    NSMutableArray *RssiArray;
    NSMutableArray *SetRssiArray;
    NSMutableDictionary *_showDic;//用来判断分组展开与收缩的
}
    
@end
