//
//  FunctionSettingTableViewCell.m
//  QGJEngineer
//
//  Created by 吴兆华 on 2018/3/25.
//  Copyright © 2018年 comyou. All rights reserved.
//

#import "FunctionSettingTableViewCell.h"

@implementation FunctionSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.settingLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 25)];
        self.settingLab.textColor = [UIColor blackColor];
        self.settingLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:self.settingLab];
        
        [self.selectBtn setImage:[UIImage imageNamed:@"iconcheck"] forState:UIControlStateNormal];
        [self.selectBtn addTarget:self action:@selector(iselected) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview: self.selectBtn];
        
    }
    return self;
}

-(void)iselected{
    
    if (self.selectBtnClickBlock) {
        self.selectBtnClickBlock();
    }
}

-(UIButton *)selectBtn{
    
    if (!_selectBtn) {
        _selectBtn = [UIButton new];
    }
    return _selectBtn;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.selectBtn.frame = CGRectMake(self.width - 38, self.height/2 - 10, 20, 20);
}

@end
