//
//  FunctionSettingTableViewCell.h
//  QGJEngineer
//
//  Created by 吴兆华 on 2018/3/25.
//  Copyright © 2018年 comyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FunctionSettingTableViewCell : UITableViewCell

@property(nonatomic,strong) UILabel *settingLab;
@property(nonatomic,strong) UIButton *selectBtn;
@property (nonatomic, copy) void (^ selectBtnClickBlock)();
@end
