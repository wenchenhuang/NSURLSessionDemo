//
//  UploadDataViewController.m
//  NSURLSessionDemo
//
//  Created by huangwenchen on 15/4/2.
//  Copyright (c) 2015年 huangwenchen. All rights reserved.
//

#import "UploadDataViewController.h"

@interface UploadDataViewController ()<NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *keytextfield;
@property (weak, nonatomic) IBOutlet UITextField *valuetextfield;
@property (weak, nonatomic) IBOutlet UILabel *responselabel;
@property (strong,nonatomic)NSURLSession * session;
@property (strong,nonatomic)UIActivityIndicatorView * spinner;
@end

@implementation UploadDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // Do any additional setup after loading the view.
}
- (IBAction)upload:(id)sender {
    [self.view addSubview:self.spinner];
    self.spinner.center = self.view.center;
    [self.spinner startAnimating];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com/posts"]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:20];
    
    NSDictionary * dataToUploaddic = @{self.keytextfield.text:self.valuetextfield.text};
    NSData * data = [NSJSONSerialization dataWithJSONObject:dataToUploaddic
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
    NSURLSessionUploadTask * uploadtask = [self.session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            self.responselabel.text = dictionary.description;
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
        }else{
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedFailureReason preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
     
    }];
    [uploadtask resume];

}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
