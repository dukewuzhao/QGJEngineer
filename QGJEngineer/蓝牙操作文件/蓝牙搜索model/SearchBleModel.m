//
//  SearchBleModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/10/17.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SearchBleModel.h"

@interface SearchBleModel()

@property(nonatomic, strong) MSWeakTimer * queraTime;//0.5秒的计时器，用于查询数据

@end

@implementation SearchBleModel

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"model被创建了");
        self.queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(queryFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }
    return self;
}

-(void)queryFired{
    
    if (self.searchCount == 0) {
        
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self,@"searchmodel", nil];
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_reloadTableViewData object:nil userInfo:dict]];
        [self.queraTime invalidate];
        self.queraTime = nil;
    }else{
        
        self.searchCount = 0;
    }
    
}

-(void)stopSearchBle{
    
    [self.queraTime invalidate];
    self.queraTime = nil;
}

-(void)dealloc{
    [self.queraTime invalidate];
    self.queraTime = nil;
    NSLog(@"searchmodel被释放了");
}

@end
