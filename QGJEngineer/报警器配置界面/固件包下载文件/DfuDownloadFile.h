//
//  DfuDownloadFile.h
//  RideHousekeeper
//
//  Created by Apple on 2017/7/12.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DfuDownloadFile;
@protocol DfuDownloadFileDelegate <NSObject>
@optional
-(void)DownloadBreak;
-(void)DownloadOver;

@end

@interface DfuDownloadFile : NSObject


-(void)startDownload:(NSString *)downloadHttp;
@property (nonatomic,weak) id<DfuDownloadFileDelegate> delegate;
@end
