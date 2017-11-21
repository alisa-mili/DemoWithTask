//
//  HttpRequest.h
//  DownLoadDemo
//
//  Created by sangfor on 2017/11/18.
//  Copyright © 2017年 sangfor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject
//会话对象
@property (nonatomic, strong) NSURLSession *urlSession;
//请求任务
@property (nonatomic, strong) NSURLSessionDataTask *requestVideoTask;
@property (nonatomic, strong) NSURLSessionDataTask *requestDemoTask;
@property (nonatomic, strong) NSURLSessionDataTask *requestFrameTask;
@property (nonatomic, strong) NSURLSessionDataTask *requestImgDownThreadTask;
@property (nonatomic, strong) NSURLSessionDataTask *requestImgDownGCDTask;

+(instancetype)shareInstace;

/**
 请求下载视频
 */
-(void)RequestVideo:(void (^)(NSString* response))resultBlock;
/**
 请求下载Demo
 */
-(void)RequestDemo:(void (^)(NSString* response))resultBlock;
/**
 请求下载Demo
 */
-(void)RequestFrame:(void (^)(NSString* response))resultBlock;
/**
 请求下载多线程图片
 */
-(void)RequestImgDownThread:(void (^)(NSString* response))resultBlock;
/**
 请求下载GCD图片
 */
-(void)RequestImgDownGCD:(void (^)(NSString* response))resultBlock;
@end
