//
//  DownloadTaskViewController.m
//  NSURLSessionDemo
//
//  Created by huangwenchen on 15/3/24.
//  Copyright (c) 2015年 huangwenchen. All rights reserved.
//

#import "DownloadTaskViewController.h"
@interface DownloadTaskViewController()<NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate,UITextFieldDelegate>
@property (strong,nonatomic)NSURLSession * session;
@property (strong,nonatomic)NSURLSessionDownloadTask * downloadTask;
@property (weak, nonatomic) IBOutlet UITextField *urltextfield;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;
@end


@implementation DownloadTaskViewController
//开始下载
- (IBAction)download:(id)sender {
        self.progressview.hidden = NO;
        self.progressview.progress = 0.0;
        NSString * imageurl = self.urltextfield.text;
        self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:imageurl]];
        [self.downloadTask resume];
        [self.session finishTasksAndInvalidate];
}
//初始化
-(void)viewDidLoad{
    self.urltextfield.delegate = self;
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"id"];
    self.session = [NSURLSession sessionWithConfiguration:configuration
                                             delegate:self
                                        delegateQueue:[NSOperationQueue mainQueue]];
}
//Session层次的Task完成的事件
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil];
        [alert show];
    }
    self.progressview.hidden = YES;
}
//Task完成的事件
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSData * data = [NSData dataWithContentsOfURL:location.filePathURL];
    UIImage * image = [UIImage imageWithData:data];
    self.imageview.image = image;
    UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil);
    self.session = nil;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
//下载进度的代理
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
        self.progressview.progress = totalBytesWritten/(float)totalBytesExpectedToWrite;
    }
}
//TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.urltextfield resignFirstResponder];
    return YES;
}
@end
