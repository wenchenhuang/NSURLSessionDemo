//
//  UploadImageReturnViewController.m
//  NSURLSessionDemo
//
//  Created by huangwenchen on 15/4/2.
//  Copyright (c) 2015年 huangwenchen. All rights reserved.
//

#import "UploadImageReturnViewController.h"

@interface UploadImageReturnViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation UploadImageReturnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webview loadHTMLString:self.htmlString baseURL:nil];
    self.webview.scalesPageToFit = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
