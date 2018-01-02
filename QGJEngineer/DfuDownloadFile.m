//
//  DfuDownloadFile.m
//  RideHousekeeper
//
//  Created by Apple on 2017/7/12.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "DfuDownloadFile.h"

@interface DfuDownloadFile()

@property(nonatomic,strong)NSMutableData *fileData;
//文件句柄
@property(nonatomic,strong)NSFileHandle *writeHandle;
//当前获取到的数据长度
@property(nonatomic,assign)long long currentLength;
//完整数据长度
@property(nonatomic,assign)long long sumLength;

//请求对象
@property(nonatomic,strong)NSURLConnection *cnnt;


@end

@implementation DfuDownloadFile


/**
 *  固件升级模式
 */

- (void)startDownload:(NSString *)downloadHttp{
    
    [self deleteFile];
    //创建下载路径
    NSURL *url=[NSURL URLWithString:downloadHttp];
    
    //创建一个请求
    //        NSURLRequest *request=[NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    
    //设置请求头信息
    //self.currentLength字节部分重新开始读取
    NSString *value=[NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
    [request setValue:value forHTTPHeaderField:@"Range"];
    
    //发送请求（使用代理的方式）
    self.cnnt=[NSURLConnection connectionWithRequest:request delegate:self];
    [self.cnnt start];
}

#pragma mark- NSURLConnectionDataDelegate代理方法
/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
#warning 判断是否是第一次连接
    if (self.sumLength) return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/test.zip", pathDocuments];
    // NSString *createDir = [NSString stringWithFormat:@"%@/MessageQueueImage", pathDocuments];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        
        
    }
    
    //3.创建写数据的文件句柄
    self.writeHandle=[NSFileHandle fileHandleForWritingAtPath:filePath];
    
    //4.获取完整的文件长度
    self.sumLength=response.expectedContentLength;
}

/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //累加接收到的数据长度
    self.currentLength+=data.length;
    //计算进度值
    
    //一点一点接收数据。
    //把data写入到创建的空文件中，但是不能使用writeTofile(会覆盖)
    //移动到文件的尾部
    [self.writeHandle seekToEndOfFile];
    //从当前移动的位置，写入数据
    [self.writeHandle writeData:data];
    
    //NSLog(@"接收到服务器的数据！---%@",data);
}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"下载完毕----%lld",self.sumLength);
    //关闭连接，不再输入数据在文件中
    [self.writeHandle closeFile];
    
    //清空进度值
    self.currentLength=0;
    self.sumLength=0;
    
    if([self.delegate respondsToSelector:@selector(DownloadOver)])
    {
        [self.delegate DownloadOver];
    }
    
}



/*
 *请求错误（失败）的时候调用（请求超时\断网\没有网\，一般指客户端错误）
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    
    if([self.delegate respondsToSelector:@selector(DownloadBreak)])
    {
        [self.delegate DownloadBreak];
    }
}

/**
 删除文件
 */
-(void)deleteFile{
    NSString *documentsPath =[self getDocumentsPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *iOSPath = [documentsPath stringByAppendingPathComponent:@"test.zip"];
    BOOL isSuccess = [fileManager removeItemAtPath:iOSPath error:nil];
    if (isSuccess) {
        NSLog(@"delete success");
    }else{
        NSLog(@"delete fail");
    }
}

- (NSString *)getDocumentsPath
{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"path:%@", path);
    return path;
}

@end
