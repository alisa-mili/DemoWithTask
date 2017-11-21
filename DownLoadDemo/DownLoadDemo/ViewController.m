//
//  ViewController.m
//  DownLoadDemo
//
//  Created by sangfor on 2017/11/17.
//  Copyright © 2017年 sangfor. All rights reserved.
//

#import "ViewController.h"
#import "HttpRequest.h"
#define kDownLoadBtnX       50
#define kDownLoadBtnY       50
#define kDownLoadBtnWidth   50
#define kDownLoadBtnHeight  50
#define kTextViewX          10
#define kTextViewWidth      (self.view.frame.size.width) - 10
#define kTextViewHeight     self.view.frame.size.height - kDownLoadBtnHeight - kDownLoadBtnY
#define textViewLineSpacing 10
#define textViewTextFont    16
#define kPauseBtnX          kDownLoadBtnX + kDownLoadBtnWidth + 40
#define kResumeBtnX         kPauseBtnX + kDownLoadBtnWidth + 40

@interface ViewController ()
@property (nonatomic, strong) UITextView *textView;

// - 下载
@property (nonatomic,strong) UIButton * downBtn;
// - 暂停
@property (nonatomic,strong) UIButton * pauseBtn;
// - 继续
@property (nonatomic,strong) UIButton * resumeBtn;
// - GCD队列
@property (nonatomic,strong) dispatch_queue_t  queue;
// - 返回的数据
@property (nonatomic, strong) NSString *returnDataStr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化控件
    [self initDownBtn];
    [self initPauseBtn];
    [self initResumeBtn];
    [self initTextView];
    
    //创建一个并发执行队列，按照追加的顺序 进行处理，先进先出FIFO。
    _queue = dispatch_queue_create("testGCD", DISPATCH_QUEUE_CONCURRENT);
}


- (void)initDownBtn
{
    if (!_downBtn) {
        _downBtn = [[UIButton alloc]initWithFrame:CGRectMake(kDownLoadBtnX, kDownLoadBtnY, kDownLoadBtnWidth, kDownLoadBtnHeight)];
        [_downBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.view addSubview:self.downBtn];
        [_downBtn addTarget:self action:@selector(downBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)initPauseBtn {
    if (!_pauseBtn) {
        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(kPauseBtnX, kDownLoadBtnY, kDownLoadBtnWidth, kDownLoadBtnHeight)];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.view addSubview:self.pauseBtn];
        [_pauseBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initTextView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(kTextViewX, kDownLoadBtnY + kDownLoadBtnHeight, kTextViewWidth, kTextViewHeight)];
        _textView.editable = NO;
        _textView.layoutManager.allowsNonContiguousLayout = NO;
        _textView.showsVerticalScrollIndicator = YES;
        [_textView setContentOffset:CGPointZero animated:NO];
        NSMutableParagraphStyle *textViewParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        textViewParagraphStyle.lineSpacing = textViewLineSpacing;
        _textView.font = [UIFont systemFontOfSize:textViewTextFont];
        [self.view addSubview:_textView];
    }
}

- (void)initResumeBtn {
    if (!_resumeBtn) {
        _resumeBtn = [[UIButton alloc] initWithFrame:CGRectMake(kResumeBtnX, kDownLoadBtnY, kDownLoadBtnWidth, kDownLoadBtnHeight)];
        [_resumeBtn setTitle:@"继续" forState:UIControlStateNormal];
        [_resumeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.view addSubview:self.resumeBtn];
        [_resumeBtn addTarget:self action:@selector(resumeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)downBtnClick {
    //开启异步线程下载
    dispatch_async(_queue, ^{
        [[HttpRequest shareInstace] RequestVideo:^(NSString *response) {
            _returnDataStr = response;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[[_textView textStorage] mutableString] appendString:@"下载视频成功...\n"];
                [[[_textView textStorage] mutableString] appendString:_returnDataStr];
            });
        }];
        
         });

//    sleep(5);
//     [[[_textView textStorage] mutableString] appendString:@"\n测试阻塞线程5秒\n"];

    
    dispatch_async(_queue, ^{
        //dispatch_apply类似一个for循环，会在指定的dispatch queue中运行block任务n次，如果队列是并发队列，则会并发执行block任务，dispatch_apply是一个同步调用，block任务执行n次后才返回。
        dispatch_apply(5, _queue, ^(size_t index) {
            NSLog(@"%ld",index);
            [[HttpRequest shareInstace] RequestFrame:^(NSString *response) {
                _returnDataStr = response;
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[[_textView textStorage] mutableString] appendString:@"下载框架Demo成功...\n"];
                    [[[_textView textStorage] mutableString] appendString:_returnDataStr];
                });
            }];
        });
    });
    
    dispatch_async(_queue, ^{
        [[HttpRequest shareInstace] RequestDemo:^(NSString *response) {
            _returnDataStr = response;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[[_textView textStorage] mutableString] appendString:@"下载Demo成功...\n"];
                [[[_textView textStorage] mutableString] appendString:_returnDataStr];
            });
        }];
        
    });
    
    dispatch_async(_queue, ^{
        [[HttpRequest shareInstace] RequestImgDownThread:^(NSString *response) {
            _returnDataStr = response;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[[_textView textStorage] mutableString] appendString:@"下载多线程图片成功...\n"];
                [[[_textView textStorage] mutableString] appendString:_returnDataStr];
            });
        }];
    });
    
    dispatch_async(_queue, ^{
        [[HttpRequest shareInstace] RequestImgDownGCD:^(NSString *response) {
            _returnDataStr = response;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [[[_textView textStorage] mutableString] appendString:@"下载GCD图片成功...\n"];
                [[[_textView textStorage] mutableString] appendString:_returnDataStr];
            });
        }];
        
    });

}

- (void)pauseBtnClick {
    if ([HttpRequest shareInstace].requestVideoTask.state == NSURLSessionTaskStateRunning) {
        //线程挂起,暂停一个队列来阻止它执行的block对象，会增加queue引用计数，引用计数大于0则保持挂起状态.suspend与resume是成对出现的
        dispatch_suspend(_queue);
        [[[_textView textStorage] mutableString] appendString:@"\n线程挂起\n"];
        [[HttpRequest shareInstace].requestVideoTask suspend];
        [[[_textView textStorage] mutableString] appendString:@"\n下载视频网络请求暂停...\n"];
    } else if ([HttpRequest shareInstace].requestDemoTask.state == NSURLSessionTaskStateRunning) {
        dispatch_suspend(_queue);
        [[[_textView textStorage] mutableString] appendString:@"\n线程挂起\n"];
        [[HttpRequest shareInstace].requestDemoTask suspend];
        [[[_textView textStorage] mutableString] appendString:@"\n下载Demo网络请求暂停...\n"];
    } else if ([HttpRequest shareInstace].requestFrameTask.state == NSURLSessionTaskStateRunning) {
        dispatch_suspend(_queue);
        [[[_textView textStorage] mutableString] appendString:@"\n线程挂起\n"];
        [[HttpRequest shareInstace].requestFrameTask suspend];
        [[[_textView textStorage] mutableString] appendString:@"\n下载框架Demo网络请求暂停...\n"];
    } else if ([HttpRequest shareInstace].requestImgDownThreadTask.state == NSURLSessionTaskStateRunning) {
        dispatch_suspend(_queue);
        [[[_textView textStorage] mutableString] appendString:@"\n线程挂起\n"];
        [[HttpRequest shareInstace].requestImgDownThreadTask suspend];
        [[[_textView textStorage] mutableString] appendString:@"\n下载多线程图片请求暂停...\n"];
    }  else if ([HttpRequest shareInstace].requestImgDownGCDTask.state == NSURLSessionTaskStateRunning) {
        dispatch_suspend(_queue);
        [[[_textView textStorage] mutableString] appendString:@"\n线程挂起\n"];
        [[HttpRequest shareInstace].requestImgDownGCDTask suspend];
        [[[_textView textStorage] mutableString] appendString:@"\n下载GCD请求暂停...\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有网络请求\n"];
    }
}

- (void)resumeBtnClick {
    //判断网络请求状态是否为暂停状态
    if ([HttpRequest shareInstace].requestVideoTask.state == NSURLSessionTaskStateSuspended) {
        //网络请求继续
        [[HttpRequest shareInstace].requestVideoTask resume];
        [[[_textView textStorage] mutableString] appendString:@"\n下载视频网络请求恢复\n"];
        dispatch_resume(_queue);
        NSLog(@"\n下载视频网络请求恢复,线程恢复\n");
        [[[_textView textStorage] mutableString] appendString:@"\n线程恢复\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有下载视频被暂停...\n"];
    }
    
    if ([HttpRequest shareInstace].requestDemoTask.state == NSURLSessionTaskStateSuspended) {
        //网络请求继续
        [[HttpRequest shareInstace].requestDemoTask resume];
        [[[_textView textStorage] mutableString] appendString:@"\n下载Demo网络请求恢复\n"];
        dispatch_resume(_queue);
        NSLog(@"\n下载Demo网络请求恢复,线程恢复\n");
        [[[_textView textStorage] mutableString] appendString:@"\n线程恢复\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有下载Demo被暂停...\n"];
    }
    
    if ([HttpRequest shareInstace].requestFrameTask.state == NSURLSessionTaskStateSuspended) {
        
        //网络请求继续
        [[HttpRequest shareInstace].requestFrameTask resume];
        [[[_textView textStorage] mutableString] appendString:@"\n下载框架Demo网络请求恢复\n"];
        //线程恢复，会减少queue引用计数。挂起和恢复是异步的，只在block之间执行,在执行一个新的block之前或之后生效。挂起一个queue不会导致正在执行的block停止。
        dispatch_resume(_queue);
        NSLog(@"\n下载框架Demo网络请求恢复,线程恢复\n");
        [[[_textView textStorage] mutableString] appendString:@"\n线程恢复\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有下载框架Demo请求被暂停...\n"];
    }
    
    if ([HttpRequest shareInstace].requestImgDownThreadTask.state == NSURLSessionTaskStateSuspended) {
        //网络请求继续
        [[HttpRequest shareInstace].requestImgDownThreadTask resume];
        [[[_textView textStorage] mutableString] appendString:@"\n下载多线程图片网络请求恢复\n"];
        //线程恢复，会减少queue引用计数。挂起和恢复是异步的，只在block之间执行,在执行一个新的block之前或之后生效。挂起一个queue不会导致正在执行的block停止。
        dispatch_resume(_queue);
        NSLog(@"\n下载多线程图片网络请求恢复,线程恢复\n");
        [[[_textView textStorage] mutableString] appendString:@"\n线程恢复\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有下载多线程图片请求被暂停...\n"];
    }
    
    if ([HttpRequest shareInstace].requestImgDownGCDTask.state == NSURLSessionTaskStateSuspended) {
        //网络请求继续
        [[HttpRequest shareInstace].requestImgDownGCDTask resume];
        [[[_textView textStorage] mutableString] appendString:@"\n下载GCD图片网络请求恢复\n"];
        dispatch_resume(_queue);
        NSLog(@"\n下载GCD图片网络请求恢复,线程恢复\n");
        [[[_textView textStorage] mutableString] appendString:@"\n线程恢复\n"];
    } else {
        [[[_textView textStorage] mutableString] appendString:@"\n当前没有下载GCD图片请求被暂停...\n"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
