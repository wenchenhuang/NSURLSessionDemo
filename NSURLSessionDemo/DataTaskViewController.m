//
//  ViewController.m
//  NSURLSessionDemo
//
//  Created by huangwenchen on 15/3/5.
//  Copyright (c) 2015年 huangwenchen. All rights reserved.
//

#import "DataTaskViewController.h"
@interface DataTaskViewController ()<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate>
@property (strong,nonatomic) IBOutlet UIImageView * imageview;
@property (strong,nonatomic)NSURLSession * session;
@property (strong,nonatomic)NSURLSessionDataTask * dataTask;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;
@property (nonatomic)NSUInteger expectlength;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong,nonatomic) NSMutableData * buffer;
@end

static NSString * imageURL = @"http://f12.topit.me/o129/10129120625790e866.jpg";

@implementation DataTaskViewController

//属性全部采用惰性初始化
#pragma mark - lazy property
-(NSMutableData *)buffer{
    if (!_buffer) {
        _buffer = [[NSMutableData alloc] init];
        
    }
    return _buffer;
}
#pragma mark - life circle of viewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
     NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration
                                             delegate:self
                                        delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:imageURL]];
    [self.view addSubview:self.imageview];
    self.cancelButton.enabled = NO;
    self.pauseButton.enabled = NO;
}
#pragma mark - target-action
//注意判断当前Task的状态
- (IBAction)pause:(UIButton *)sender {
    if (self.dataTask.state == NSURLSessionTaskStateRunning) {
        [self.dataTask suspend];
        self.resumeButton.enabled = YES;
        self.pauseButton.enabled = NO;
        self.cancelButton.enabled = YES;
    }
}

- (IBAction)cancel:(id)sender {
    switch (self.dataTask.state) {
        case NSURLSessionTaskStateRunning:
        case NSURLSessionTaskStateSuspended:
            [self.dataTask cancel];
            self.cancelButton.enabled = NO;
            self.pauseButton.enabled = NO;
            self.resumeButton.enabled = NO;
            break;
        default:
            break;
    }
}
- (IBAction)resume:(id)sender {
    if (self.dataTask.state == NSURLSessionTaskStateSuspended) {
        self.resumeButton.enabled = NO;
        self.cancelButton.enabled = YES;
        self.pauseButton.enabled = YES;
        [self.dataTask resume];
        self.progressview.hidden = NO;
    }
}

#pragma mark -  URLSession delegate method
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSUInteger length = [response expectedContentLength];
    if (length != -1) {
        self.expectlength = [response expectedContentLength];//存储一共要传输的数据长度
        completionHandler(NSURLSessionResponseAllow);//继续数据传输
    }else{
        completionHandler(NSURLSessionResponseCancel);//如果Response里不包括数据长度的信息，就取消数据传输
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"error"
                                                         message:@"Do not contain property of expectedlength"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }
  
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.buffer appendData:data];//数据放到缓冲区里
    self.progressview.progress = [self.buffer length]/((float) self.expectlength);//更改progressview的progress
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    [self.session finishTasksAndInvalidate];//完成task就invalidate

    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{//用GCD的方式，保证在主线程上更新UI
            UIImage * image = [UIImage imageWithData:self.buffer];
            self.imageview.image = image;
            self.progressview.hidden = YES;
            self.session = nil;
            self.dataTask = nil;
        });
       
    }else{
        NSDictionary * userinfo = [error userInfo];
        NSString * failurl = [userinfo objectForKey:NSURLErrorFailingURLStringErrorKey];
        NSString * localDescription = [userinfo objectForKey:NSLocalizedDescriptionKey];
        if ([failurl isEqualToString:imageURL] && [localDescription isEqualToString:@"cancelled"]) {//如果是task被取消了，就弹出提示框
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                             message:@"The task is canceled"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Unknown type error"//其他错误，则弹出错误描述
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            [alert show];
        }
        self.buffer = nil;
        self.progressview.hidden = YES;
    }
    self.cancelButton.enabled = NO;
    self.pauseButton.enabled = NO;
    self.resumeButton.enabled = NO;
}
@end
