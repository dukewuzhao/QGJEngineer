//
//  LVFmdbTool.m
//  LVDatabaseDemo
//
//
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import "LVFmdbTool.h"


#define LVSQLITE_NAME @"modals.sqlite"

@implementation LVFmdbTool


static FMDatabase *_fmdb;

+ (void)initialize {
    // 执行打开数据库和创建表操作
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:LVSQLITE_NAME];
    _fmdb = [FMDatabase databaseWithPath:filePath];
    
    [_fmdb open];
    
 //#warning 必须先打开数据库才能创建表。。。否则提示数据库没有打开
    
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS p_profiles(id INTEGER PRIMARY KEY, rssi INTEGER NOT NULL,keytest INTEGER,keyconfigure INTEGER,inductionkey INTEGER,keynumber INTEGER,function1 TEXT,function2 TEXT,function3 TEXT ,function4 TEXT, routinetest INTEGER, line TEXT, onekeytest INTEGER, seat INTEGER, lock INTEGER ,calibration INTEGER, shake INTEGER, buzzer INTEGER, inducrssi INTEGER,OneclickControl INTEGER,OnelineSpeech INTEGER,  firmware INTEGER, firmversion TEXT,brand TEXT);"];

    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS firm_models(id INTEGER PRIMARY KEY, latest_version TEXT ,download TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS keymodel(id INTEGER PRIMARY KEY, mac TEXT NOT NULL);"];

    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS allbrandmodels(id INTEGER PRIMARY KEY, brand_id INTEGER NOT NULL,brand_name TEXT,logo TEXT);"];
    
    if (![_fmdb columnExists:@"OneclickControl" inTableWithName:@"p_profiles"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"p_profiles",@"OneclickControl"];
        [_fmdb executeUpdate:alertStr];
        
    }
    
    if (![_fmdb columnExists:@"OnelineSpeech" inTableWithName:@"p_profiles"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"p_profiles",@"OnelineSpeech"];
        [_fmdb executeUpdate:alertStr];
    }
    
    if (![_fmdb columnExists:@"brand" inTableWithName:@"p_profiles"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"p_profiles",@"brand"];
        [_fmdb executeUpdate:alertStr];
    }
}

+ (BOOL)insertPModel:(ProfileModel *)model1 {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO p_profiles(rssi , keytest, keyconfigure,inductionkey, keynumber, function1, function2, function3, function4, routinetest, line, onekeytest, seat, lock, calibration, shake, buzzer,inducrssi,OneclickControl,OnelineSpeech, firmware,firmversion,brand) VALUES ('%zd','%zd', '%zd', '%zd','%zd', '%@','%@', '%@', '%@' ,'%zd','%@', '%zd', '%zd', '%zd', '%zd', '%zd', '%zd','%zd','%zd','%zd', '%zd','%@','%@');", model1.rssi,model1.keytest, model1.keyconfigure,model1.inductionkey, model1.keynumber, model1.function1, model1.function2, model1.function3, model1.function4, model1.routinetest, model1.line, model1.onekeytest, model1.seat, model1.lock, model1.calibration, model1.shake, model1.buzzer, model1.inducrssi,model1.OneclickControl,model1.OnelineSpeech, model1.firmware, model1.firmversion,model1.brand];
    
    return [_fmdb executeUpdate:insertSql];
}


+ (BOOL)insertKeyModel:(InductionKeyModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO keymodel(mac) VALUES ('%@');", model.mac];
    
    return [_fmdb executeUpdate:insertSql];
}

+ (BOOL)insertFirmModel:(FirmVersionModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO firm_models(latest_version ,download) VALUES ('%@' ,'%@');", model.latest_version, model.download];
    
    return [_fmdb executeUpdate:insertSql];
}

+ (BOOL)insertAllBrandModel:(AllBrandNameModel *)model {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO allbrandmodels(brand_id ,brand_name,logo) VALUES ('%zd','%@' ,'%@');", model.brand_id, model.brand_name,model.logo];
    
    return [_fmdb executeUpdate:insertSql];
}




+ (NSMutableArray *)queryPData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM p_profiles;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *rssi = [set stringForColumn:@"rssi"];
        NSString *keytest = [set stringForColumn:@"keytest"];
        NSString *keyconfigure = [set stringForColumn:@"keyconfigure"];
        NSString *inductionkey = [set stringForColumn:@"inductionkey"];
        NSString *keynumber = [set stringForColumn:@"keynumber"];
        NSString *function1 = [set stringForColumn:@"function1"];
        NSString *function2 = [set stringForColumn:@"function2"];
        NSString *function3 = [set stringForColumn:@"function3"];
        NSString *function4 = [set stringForColumn:@"function4"];
        NSString *routinetest = [set stringForColumn:@"routinetest"];
        NSString *line = [set stringForColumn:@"line"];
        NSString *onekeytest = [set stringForColumn:@"onekeytest"];
        NSString *seat = [set stringForColumn:@"seat"];
        NSString *lock = [set stringForColumn:@"lock"];
        NSString *calibration = [set stringForColumn:@"calibration"];
        NSString *shake = [set stringForColumn:@"shake"];
        NSString *buzzer = [set stringForColumn:@"buzzer"];
        NSString *inducrssi = [set stringForColumn:@"inducrssi"];
        NSString *OneclickControl = [set stringForColumn:@"OneclickControl"];
        NSString *OnelineSpeech = [set stringForColumn:@"OnelineSpeech"];
        NSString *firmware = [set stringForColumn:@"firmware"];
        NSString *firmversion = [set stringForColumn:@"firmversion"];
        NSString *brand = [set stringForColumn:@"brand"];
        
        ProfileModel *modal = [ProfileModel modalWith:rssi.intValue keytest:keytest.intValue keyconfigure:keyconfigure.intValue inductionkey:inductionkey.intValue keynumber:keynumber.intValue function1:function1 function2:function2 function3:function3 function4:function4 routinetest:routinetest.intValue line:line onekeytest:onekeytest.intValue seat:seat.intValue lock:lock.intValue calibration:calibration.intValue shake:shake.intValue buzzer:buzzer.intValue inducrssi:inducrssi.intValue OneclickControl:OneclickControl.intValue OnelineSpeech:OnelineSpeech.intValue firmware:firmware.intValue firmversion:firmversion brand:brand];
        [arrM addObject:modal];

    }
    return arrM;
}

+ (NSMutableArray *)queryKeyData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM keymodel;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *mac = [set stringForColumn:@"mac"];
        
        InductionKeyModel *modal = [InductionKeyModel modalWith:mac];
        [arrM addObject:modal];
        
    }
    return arrM;
}

+ (NSMutableArray *)queryFirmData:(NSString *)querySql{

    if (querySql == nil) {
        querySql = @"SELECT * FROM firm_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *latest_version = [set stringForColumn:@"latest_version"];
        NSString *download = [set stringForColumn:@"download"];
        
        FirmVersionModel *modal = [FirmVersionModel modalWith:latest_version download:download];
        [arrM addObject:modal];
        
    }
    return arrM;

}

+ (NSMutableArray *)queryAllBrandData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM allbrandmodels;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *brand_id = [set stringForColumn:@"brand_id"];
        NSString *brand_name = [set stringForColumn:@"brand_name"];
        NSString *logo = [set stringForColumn:@"logo"];
        AllBrandNameModel *modal = [AllBrandNameModel AllBrandModalWith:brand_id.intValue brandname:brand_name logo:logo];
        [arrM addObject:modal];
        
    }
    return arrM;
    
}

+ (BOOL)deleteData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM p_profiles";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteKeyData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM keymodel";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteAllBrandData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM allbrandmodels";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteFirmData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM firm_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)modifyFirmData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE p_profiles SET stand = '789789' WHERE name = 'lisi'";
    }
    return [_fmdb executeUpdate:modifySql];
}

+ (BOOL)modifyKeyData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE keymodel SET mac = '789789' WHERE id = 1";
    }
    return [_fmdb executeUpdate:modifySql];
}


@end
