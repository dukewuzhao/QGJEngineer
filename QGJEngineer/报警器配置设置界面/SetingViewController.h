//
//  SetingViewController.h
//  QGJEngineer
//
//  Created by smartwallit on 16/9/29.
//  Copyright © 2016年 comyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetingViewController : BaseViewController
{

    NSMutableArray *_sectionArray;
    NSMutableArray *keyArray;
    NSMutableArray *inductionkeyArray;
    NSMutableArray *functionArray;
    NSMutableArray *RssiArray;
    NSMutableArray *InducRssiArray;
    NSMutableArray *lineArray;
    NSMutableArray *setArray;
    NSMutableDictionary *_showDic;//用来判断分组展开与收缩的
}
@end
