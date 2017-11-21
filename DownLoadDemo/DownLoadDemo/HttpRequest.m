//
//  HttpRequest.m
//  DownLoadDemo
//
//  Created by sangfor on 2017/11/18.
//  Copyright © 2017年 sangfor. All rights reserved.
//

#import "HttpRequest.h"
#define kVideoURL                   @"http://221.228.249.82/youku/697A5CA0CEB3582FB91C4E3A88/03002001004E644FA2997704E9D2A7BA1E7B9D-6CAB-79A9-E635-3B92A92B3500.mp4"
#define kDemoURL                    @"https://github.com/linqiang/Demo.git"
#define kAppFrameDemo               @"https://github.com/CYXiang/CYXTenMinDemo.git"
#define kDownLoadImgWithThread      @"http://image.baidu.com/search/detail?ct=503316480&z=0&ipn=d&word=ios%20多线程线程池&step_word=&hs=0&pn=1&spn=0&di=155689730570&pi=0&rn=1&tn=baiduimagedetail&is=0%2C0&istype=0&ie=utf-8&oe=utf-8&in=&cl=2&lm=-1&st=undefined&cs=2016172702%2C3460081509&os=2723263731%2C1477538915&simid=0%2C0&adpicid=0&lpn=0&ln=1191&fr=&fmq=1510970160339_R&fm=&ic=undefined&s=undefined&se=&sme=&tab=0&width=undefined&height=undefined&face=undefined&ist=&jit=&cg=&bdtype=0&oriquery=&objurl=http%3A%2F%2Fwww.th7.cn%2Fd%2Ffile%2Fp%2F2014%2F06%2F06%2F9ba086e9da1d7540e1e91aeb39616df0.png&fromurl=ippr_z2C%24qAzdH3FAzdH3Fooo_z%26e3Bpi0_z%26e3BvgAzdH3FP6526w4AzdH3FIOSAzdH3Fda89amAzdH3Fd8n0ll_z%26e3Bfip4s&gsm=0&rpstart=0&rpnum=0"
#define kDownLoadImgWithGCD         @"https://image.baidu.com/search/detail?ct=503316480&z=0&ipn=d&word=iOS%20GCD&step_word=&hs=0&pn=26&spn=0&di=144381896780&pi=0&rn=1&tn=baiduimagedetail&is=0%2C0&istype=2&ie=utf-8&oe=utf-8&in=&cl=2&lm=-1&st=-1&cs=4099577417%2C357676626&os=2426865403%2C3085902732&simid=3372152178%2C72508503&adpicid=0&lpn=0&ln=251&fr=&fmq=1510971011844_R&fm=result&ic=0&s=undefined&se=&sme=&tab=0&width=&height=&face=undefined&ist=&jit=&cg=&bdtype=0&oriquery=&objurl=http%3A%2F%2Fimages2015.cnblogs.com%2Fblog%2F860596%2F201603%2F860596-20160310111008850-241733276.png&fromurl=ippr_z2C%24qAzdH3FAzdH3Fooo_z%26e3B2jgfi7tx7j_z%26e3Bv54AzdH3Ft-vxyAzdH3FrAzdH3F0ll8bm9&gsm=0&rpstart=0&rpnum=0"

@interface HttpRequest () <NSObject>
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSFileHandle *readAndWriteHandle;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, copy)   NSString     *filePath;
@property (nonatomic, copy)   NSData       *responseData;
@end
@implementation HttpRequest

+(instancetype)shareInstace {
    static HttpRequest *httpRequest;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpRequest = [[HttpRequest alloc] init];
    });
    return httpRequest;
}

-(instancetype)init {
    if (self = [super init]) {
        _urlSession = [NSURLSession sharedSession];
        _request = [[NSURLRequest alloc] init];
        _responseData = nil;
        _readAndWriteHandle = [[NSFileHandle alloc] init];
        _fileManager = [NSFileManager defaultManager];
        NSArray* directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* docmentPath = directories[0];
        _filePath = [docmentPath stringByAppendingString:@"/DownLoadDemoFile.txt"];
        NSError* error;
        NSString* test = @"Testing writetoFile\n";
        [test writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"%@", error);
    }
    return self;
}


/**
 请求下载视频
 */
-(void)RequestVideo:(void (^)(NSString* response))resultBlock{
    NSURL *urlWithVideo = [NSURL URLWithString:kVideoURL];
    _requestVideoTask = [_urlSession dataTaskWithURL:urlWithVideo completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //请求结束，打印数据
        _responseData = data;
        NSString *downLoadErrorMsg = @"\n请求下载视频失败";
        if (error) {
            [downLoadErrorMsg stringByAppendingString: @"\n请求下载视频失败原因：\n"];
            [downLoadErrorMsg stringByAppendingString:[error localizedDescription]];
        }
        //打开文件句柄
        _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
        
        if (_responseData && [_responseData length] != 0) {
            [_readAndWriteHandle writeData:_responseData];
        } else {
            [_readAndWriteHandle writeData:[downLoadErrorMsg dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [_readAndWriteHandle closeFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_responseData && [_responseData length] != 0) {
                NSLog(@"%@---%@",@"\n下载视频成功,保存成功\n",_responseData);
                NSString *successResult = @"\n下载视频成功,保存成功\n";
                resultBlock(successResult);
            } else {
                resultBlock(downLoadErrorMsg);
                NSLog(@"errorMessage:%@",downLoadErrorMsg);
            }
        });
    }];
    [_requestVideoTask resume];
}

/**
 请求下载Demo
 */
-(void)RequestDemo:(void (^)(NSString* response))resultBlock {
    NSURL *urlWithDemo = [NSURL URLWithString:kDemoURL];
//    _requestDemoTask = [_urlSession dataTaskWithURL:urlWithDemo completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //请求结束，打印数据
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _returnDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"文件路径:%@",_filePath);
//            _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
//            [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
//            [_readAndWriteHandle writeData:[_returnDataStr dataUsingEncoding:NSUTF8StringEncoding]];
//            [_readAndWriteHandle closeFile];
//            if (_returnDataStr) {
//                NSLog(@"%@---%@",@"\n下载Demo成功,保存成功\n",_returnDataStr);
//                 resultBlock(_returnDataStr);
//            }
//        });
//        if (error) {
//            NSLog(@"请求下载Demo，errorMessage:%@",[error localizedDescription]);
//        }
//    }];
    
    _requestDemoTask = [_urlSession dataTaskWithURL:urlWithDemo completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //请求结束，打印数据
        _responseData = data;
        NSString *downLoadErrorMsg = @"\n请求下载Demo失败";
        if (error) {
            [downLoadErrorMsg stringByAppendingString: @"\n请求下载Demo失败原因：\n"];
            [downLoadErrorMsg stringByAppendingString:[error localizedDescription]];
        }

        //打开文件句柄
        _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
        
        if (_responseData && [_responseData length] != 0) {
            [_readAndWriteHandle writeData:_responseData];
        } else {
            [_readAndWriteHandle writeData:[downLoadErrorMsg dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [_readAndWriteHandle closeFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_responseData && [_responseData length] != 0) {
                NSLog(@"%@---%@",@"\n下载Demo成功,保存成功\n",_responseData);
                NSString *successResult = @"\n下载Demo成功,保存成功\n";
                resultBlock(successResult);
            } else {
                resultBlock(downLoadErrorMsg);
                NSLog(@"errorMessage:%@",downLoadErrorMsg);
            }
        });
    }];
    [_requestDemoTask resume];
}
/**
 请求下载框架Demo
 */
-(void)RequestFrame:(void (^)(NSString* response))resultBlock {
    NSURL *urlWithAppFrameDemo = [NSURL URLWithString:kAppFrameDemo];
//    _requestFrameTask = [_urlSession dataTaskWithURL:urlWithAppFrameDemo completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //请求结束，打印数据
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _returnDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
//            [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
//            [_readAndWriteHandle writeData:[_returnDataStr dataUsingEncoding:NSUTF8StringEncoding]];
//            [_readAndWriteHandle closeFile];
//            if (_returnDataStr) {
//                NSLog(@"%@---%@",@"\n下载框架Demo成功,保存成功\n",_returnDataStr);
//                resultBlock(_returnDataStr);
//            }
//        });
//        if (error) {
//            NSLog(@"请求下载框架Demo，errorMessage:%@",[error localizedDescription]);
//        }
//    }];
    
    _requestFrameTask = [_urlSession dataTaskWithURL:urlWithAppFrameDemo completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //请求结束，打印数据
        _responseData = data;
        NSString *downLoadErrorMsg = @"\n请求下载框架Demo失败";
        if (error) {
            [downLoadErrorMsg stringByAppendingString: @"\n请求下载框架Demo失败原因：\n"];
            [downLoadErrorMsg stringByAppendingString:[error localizedDescription]];
        }

        //打开文件句柄
        _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
        if (_responseData && [_responseData length] != 0) {
            [_readAndWriteHandle writeData:_responseData];
        } else {
            [_readAndWriteHandle writeData:[downLoadErrorMsg dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [_readAndWriteHandle closeFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_responseData && [_responseData length] != 0) {
                NSLog(@"%@---%@",@"\n下载框架Demo成功,保存成功\n",_responseData);
                NSString *successResult = @"\n下载框架Demo成功,保存成功\n";
                resultBlock(successResult);
            } else {
                resultBlock(downLoadErrorMsg);
                NSLog(@"errorMessage:%@",downLoadErrorMsg);
            }
        });
    }];
    
    [_requestFrameTask resume];
}
/**
 请求下载多线程图片
 */
-(void)RequestImgDownThread:(void (^)(NSString* response))resultBlock {
    NSString *downLoadWithThreadStr = [kDownLoadImgWithThread stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:kDownLoadImgWithThread]];
//    NSString *downLoadWithThreadStr = [kDownLoadImgWithThread stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlWithDownImgThread = [NSURL URLWithString:downLoadWithThreadStr];
//    _request = [NSURLRequest requestWithURL:urlWithDownImgThread];
//    _requestImgDownThreadTask = [_urlSession downloadTaskWithRequest:_request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@",response.suggestedFilename);//为nil导致crash
//        NSLog(@"%@",location);//系统临时存在下载文件地址
//
//        //利用MSFileManager类将临时文件剪切转移到自定义路径
//        NSFileManager *fileMag = [NSFileManager defaultManager];
//        [fileMag moveItemAtURL:location
//                         toURL:[NSURL fileURLWithPath:[kDownLoadImgThreadPath stringByAppendingPathComponent:response.suggestedFilename]]
//                         error:nil];
//        //请求结束，打印数据
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _returnDataStr = @"\n下载多线程图片成功,保存成功\n";
//            NSLog(@"%@",_returnDataStr);
//            resultBlock(_returnDataStr);
//        });
//    }];
    
    _requestImgDownThreadTask = [_urlSession dataTaskWithURL:urlWithDownImgThread completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _responseData = data;
        //请求结束，打印数据
        NSString *downLoadErrorMsg = @"\n请求下载多线程图片失败\n";
        if (error) {
            [downLoadErrorMsg stringByAppendingString: @"\n请求下载多线程图片失败原因：\n"];
            [downLoadErrorMsg stringByAppendingString:[error localizedDescription]];
        }
       
        //打开文件句柄
        _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
        if (_responseData && [_responseData length] != 0) {
            [_readAndWriteHandle writeData:_responseData];
        } else {
            [_readAndWriteHandle writeData:[downLoadErrorMsg dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [_readAndWriteHandle closeFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_responseData && [_responseData length] != 0) {
                NSLog(@"%@---%@",@"\n下载多线程图片成功,保存成功\n",_responseData);
                NSString *successResult = @"\n下载多线程图片成功,保存成功\n";
                resultBlock(successResult);
            } else {
                resultBlock(downLoadErrorMsg);
                NSLog(@"errorMessage:%@",downLoadErrorMsg);
            }
        });
    }];
    
    [_requestImgDownThreadTask resume];
}
/**
 请求下载GCD图片
 */
-(void)RequestImgDownGCD:(void (^)(NSString* response))resultBlock {
        NSString *downLoadWithGCDStr = [kDownLoadImgWithGCD stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:kDownLoadImgWithGCD]];
    NSURL *urlWithDownImgGCD = [NSURL URLWithString:downLoadWithGCDStr];
//    _requestImgDownGCDTask = [_urlSession dataTaskWithURL:urlWithDownImgGCD completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        //请求结束，打印数据
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _returnDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
//            [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
//            [_readAndWriteHandle writeData:[_returnDataStr dataUsingEncoding:NSUTF8StringEncoding]];
//            [_readAndWriteHandle closeFile];
//            NSLog(@"%@---%@",@"\n下载GCD图片成功,保存成功\n",_returnDataStr);
//            resultBlock(_returnDataStr);
//        });
//        if (error) {
//            NSLog(@"请求下载多线程图片，errorMessage:%@",[error localizedDescription]);
//        }
//    }];
    
    _requestImgDownGCDTask = [_urlSession dataTaskWithURL:urlWithDownImgGCD completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //请求结束，打印数据
        _responseData = data;
        NSString *downLoadErrorMsg = @"\n请求下载GCD图片失败\n";
        if (error) {
            [downLoadErrorMsg stringByAppendingString: @"\n请求下载GCD图片失败原因：\n"];
            [downLoadErrorMsg stringByAppendingString:[error localizedDescription]];
        }
        //打开文件句柄
        _readAndWriteHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
        [_readAndWriteHandle seekToEndOfFile];//把偏移量指到文件尾部
        if (_responseData && [_responseData length] != 0) {
            [_readAndWriteHandle writeData:_responseData];
        } else {
            [_readAndWriteHandle writeData:[downLoadErrorMsg dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [_readAndWriteHandle closeFile];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_responseData && [_responseData length] != 0) {
                NSLog(@"%@---%@",@"\n下载GCD图片成功,保存成功\n",_responseData);
                NSString *successResult = @"\n下载GCD图片成功,保存成功\n";
                resultBlock(successResult);
            } else {
                resultBlock(downLoadErrorMsg);
                NSLog(@"errorMessage:%@",downLoadErrorMsg);
            }
        });
    }];
    [_requestImgDownGCDTask resume];
    NSLog(@"============发起GCD图片下载请求，URL：%@",urlWithDownImgGCD);
}


@end
