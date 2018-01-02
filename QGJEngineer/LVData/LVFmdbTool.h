//
//  LVFmdbTool.h
//  LVDatabaseDemo
//
//  Created by 刘春牢 on 15/3/26.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class ProfileModel;
@class InductionKeyModel;
@class FirmVersionModel;
@class AllBrandNameModel;
@interface LVFmdbTool : NSObject

+ (BOOL)insertPModel:(ProfileModel *)model;
+ (BOOL)insertKeyModel:(InductionKeyModel *)model;
+ (BOOL)insertFirmModel:(FirmVersionModel *)model;
+ (BOOL)insertAllBrandModel:(AllBrandNameModel *)model;


+ (NSMutableArray *)queryPData:(NSString *)querySql;
+ (NSMutableArray *)queryKeyData:(NSString *)querySql;
+ (NSMutableArray *)queryFirmData:(NSString *)querySql;
+ (NSMutableArray *)queryAllBrandData:(NSString *)querySql;

/** 删除数据,如果 传空 默认会删除表中所有数据 */
+ (BOOL)deleteData:(NSString *)deleteSql;
+ (BOOL)deleteKeyData:(NSString *)deleteSql;
+ (BOOL)deleteFirmData:(NSString *)deleteSql;
+ (BOOL)deleteAllBrandData:(NSString *)querySql;

+ (BOOL)modifyFirmData:(NSString *)modifySql ;
+ (BOOL)modifyKeyData:(NSString *)modifySql;

@end
