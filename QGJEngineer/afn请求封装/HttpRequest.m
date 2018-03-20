//
//  HttpRequest.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/26.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "HttpRequest.h"
//#import "UploadParam.h"
@implementation HttpRequest

static id _instance = nil;
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        
    });
    return _instance;
}

#pragma mark -- GET请求 --
- (void)getWithURLString:(NSString *)URLString
              parameters:(id)parameters
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    /**
     *  可以接受的类型
     */
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    /**
     *  请求队列的最大并发数
     */
    //    manager.operationQueue.maxConcurrentOperationCount = 5;
    /**
     *  请求超时的时间
     */
    manager.requestSerializer.timeoutInterval = 30;
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- POST请求 --
- (void)postWithURLString:(NSString *)URLString
               parameters:(id)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            //NSLog(@"KAOKAOKAO  ------%@",responseObject);
            if ([responseObject[@"status"] intValue] == 0){
                NSLog(@"token没有失效  ------");
                success(responseObject);
            }else if ([responseObject[@"status"] intValue] == 1009){
                NSLog(@"token失效了  ------");
                NSString *password= [QFTools getdata:@"password"];
                NSString *phonenum= [QFTools getdata:@"phone_num"];
                
                NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"OEM"];
                NSString * md5=[QFTools md5:pwd];
                NSString *loginURL = [NSString stringWithFormat:@"%@%@",QGJURL,@"oem/login"];
                NSDictionary *loginParameters = @{@"account": phonenum, @"passwd": md5};
                [self postWithURLString:loginURL parameters:loginParameters success:^(id responseObject) {
                    
                    if ([responseObject[@"status"] intValue] == 0){
                        
                        [LVFmdbTool deleteAllBrandData:nil];
                        NSDictionary *data = responseObject[@"data"];
                        NSString * token=[data objectForKey:@"token"];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",phonenum,@"phone_num",password,@"password",nil];
                        [userDefaults setObject:userDic forKey:logInUSERDIC];
                        [userDefaults synchronize];
                        NSMutableArray *brands = data[@"brands"];
                        [LVFmdbTool insertAllBrandModel:[AllBrandNameModel AllBrandModalWith:0 brandname:@"骑管家" logo:@"logo"]];
                        for (NSDictionary *brandInfo in brands) {
                            
                            NSNumber *brand_id = brandInfo[@"brand_id"];
                            NSString *brand_name = brandInfo[@"brand_name"];
                            NSString *logo = brandInfo[@"logo"];
                            AllBrandNameModel *pmodel = [AllBrandNameModel AllBrandModalWith:brand_id.intValue brandname:brand_name logo:logo];
                            [LVFmdbTool insertAllBrandModel:pmodel];
                        }
                        
                        NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
                        [dict002 setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:dict002 success:success failure:failure];
                    }
                    
                } failure:^(NSError *error) {
                    
                    [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                    
                }];
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}


#pragma mark -- POST请求 --
- (void)postWithURLString2:(NSString *)URLString
               parameters:(id)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            
            if ([responseObject[@"status"] intValue] == 0){
                NSLog(@"token没有失效  ------");
                success(responseObject);
            }else if ([responseObject[@"status"] intValue] == 1009){
                NSLog(@"token失效了  ------");
                NSString *password= [QFTools getuserInfo:@"password"];
                NSString *phonenum= [QFTools getuserInfo:@"phone_num"];
                
                NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"FACTORY"];
                NSString * md5=[QFTools md5:pwd];
                
                NSString *loginURL = [NSString stringWithFormat:@"%@%@",QGJURL,@"factory/login"];
                NSDictionary *loginParameters = @{@"account": phonenum, @"passwd": md5};
                
                [self postWithURLString2:loginURL parameters:loginParameters success:^(id responseObject) {
                    
                    if ([responseObject[@"status"] intValue] == 0) {
                            
                       
                        NSDictionary *data = responseObject[@"data"];
                        NSString * token=[data objectForKey:@"token"];
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",phonenum,@"phone_num",password,@"password",nil];
                        [userDefaults setObject:userDic forKey:logInUSERDIC];
                        [userDefaults synchronize];
                        
                        NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
                        [dict002 setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithURLString2:URLString parameters:dict002 success:success failure:failure];
                    }
                    
                } failure:^(NSError *error) {
                    [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                    NSLog(@"error :%@",error);
                }];
                
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

#pragma mark -- 台铃POST请求 --
- (void)postWithTLURLString:(NSString *)URLString
                parameters:(id)parameters
                   success:(void (^)(id))success
                   failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            
            if ([responseObject[@"status"] intValue] == 0){
                NSLog(@"台铃token没有失效  ------");
                success(responseObject);
            }else if ([responseObject[@"status"] intValue] == 1009){
                NSLog(@"台铃token失效了  ------");
                NSString *phonenum= @"tl";
                NSString *password= @"123456";
                
                NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"FACTORY"];
                NSString * md5=[QFTools md5:pwd];
                
                NSString *loginURL = [NSString stringWithFormat:@"%@%@",TLURL,@"factory/login"];
                NSDictionary *loginParameters = @{@"account": phonenum, @"passwd": md5};
                
                [self postWithTLURLString:loginURL parameters:loginParameters success:^(id responseObject) {
                    
                    if ([responseObject[@"status"] intValue] == 0) {
                        
                        NSDictionary *data = responseObject[@"data"];
                        NSString * token=[data objectForKey:@"token"];
                        [USER_DEFAULTS setValue:token forKey:TLFactoryToken];
                        
                        NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
                        [dict002 setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithTLURLString:URLString parameters:dict002 success:success failure:failure];
                    }else{
                        success(responseObject);
                    }
                    
                } failure:^(NSError *error) {
                    [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                    NSLog(@"error :%@",error);
                }];
                
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

#pragma mark -- 绿源POST请求 --
- (void)postWithLYURLString:(NSString *)URLString
                 parameters:(id)parameters
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            
            if ([responseObject[@"status"] intValue] == 0){
                NSLog(@"绿源token没有失效  ------");
                success(responseObject);
            }else if ([responseObject[@"status"] intValue] == 1009){
                NSLog(@"绿源token失效了  ------");
                NSString *phonenum= @"lvyuan";
                NSString *password= @"123456";
                NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"FACTORY"];
                NSString * md5=[QFTools md5:pwd];
                
                NSString *loginURL = [NSString stringWithFormat:@"%@%@",LYURL,@"factory/login"];
                NSDictionary *loginParameters = @{@"account": phonenum, @"passwd": md5};
                
                [self postWithLYURLString:loginURL parameters:loginParameters success:^(id responseObject) {
                    
                    if ([responseObject[@"status"] intValue] == 0) {
                        
                        NSDictionary *data = responseObject[@"data"];
                        NSString * token=[data objectForKey:@"token"];
                        [USER_DEFAULTS setValue:token forKey:LYFactoryToken];
                        
                        NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
                        [dict002 setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithLYURLString:URLString parameters:dict002 success:success failure:failure];
                    }else{
                        success(responseObject);
                    }
                    
                } failure:^(NSError *error) {
                    [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                    NSLog(@"error :%@",error);
                }];
                
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

#pragma mark -- POST/GET网络请求 --
- (void)requestWithURLString:(NSString *)URLString
                  parameters:(id)parameters
                        type:(HttpRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    switch (type) {
        case HttpRequestTypeGet:
        {
            [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case HttpRequestTypePost:
        {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
    }
}

//- (void)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(NSArray<UploadParam *> *)uploadParams success:(void (^)())success failure:(void (^)(NSError *))failure {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        for (UploadParam *uploadParam in uploadParams) {
//            [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
//        }
//    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (success) {
//            success(responseObject);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
//}

#pragma mark - 下载数据
- (void)downLoadWithURLString:(NSString *)URLString parameters:(id)parameters progerss:(void (^)())progress success:(void (^)())success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress();
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    [downLoadTask resume];
}

@end
