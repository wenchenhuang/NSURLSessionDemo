//
//  UploadTaskViewController.m
//  NSURLSessionDemo
//
//  Created by huangwenchen on 15/3/25.
//  Copyright (c) 2015年 huangwenchen. All rights reserved.
//

#import "UploadImageViewController.h"
#import "UploadImageReturnViewController.h"
@interface  UploadImageViewController()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLSessionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>
@property (strong,nonatomic)UIImagePickerController * imagePikerViewController;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong,nonatomic)NSURLSession * session;
@property (weak, nonatomic) IBOutlet UIProgressView *progressview;
@property (strong,nonatomic)UIActivityIndicatorView * spinner;

@end

@implementation UploadImageViewController
-(void)viewDidLoad{
    self.progressview.progress = 0.0;
    self.progressview.hidden = YES;
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.imagePikerViewController = [[UIImagePickerController alloc] init];
    self.imagePikerViewController.allowsEditing = YES;
    self.imagePikerViewController.delegate = self;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

}
- (IBAction)upload:(id)sender {
    if (self.imageview.image == nil) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Select or take photo first" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.view addSubview:self.spinner];
    self.spinner.center = self.view.center;
    [self.spinner startAnimating];
    self.progressview.progress = 0.0;
    self.progressview.hidden = NO;
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.freeimagehosting.net/upload.php"]];
    [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:20];
    NSData * imagedata = UIImageJPEGRepresentation(self.imageview.image,1.0);
    
    NSURLSessionUploadTask * uploadtask = [self.session uploadTaskWithRequest:request fromData:imagedata completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString * htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        UploadImageReturnViewController * resultvc = [self.storyboard instantiateViewControllerWithIdentifier:@"resultvc"];
        resultvc.htmlString = htmlString;
        [self.navigationController pushViewController:resultvc animated:YES];
        self.progressview.hidden = YES;
        [self.spinner stopAnimating];
        [self.spinner removeFromSuperview];
    }];
    [uploadtask resume];
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%@",error.description);
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    self.progressview.progress = totalBytesSent/(float)totalBytesExpectedToSend;
}
- (IBAction)takePhoto:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"Take Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePikerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePikerViewController animated:YES completion:NULL];
        }else{
            [self showAlertWithMessage:@"Camera is not available in this device or simulator"];
        }
        // Handle Take Photo here
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"Choose Existing Photo" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            self.imagePikerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePikerViewController animated:YES completion:NULL];
        }
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];
    [self presentViewController: alertController animated: YES completion: nil];


}
-(void)showAlertWithMessage:(NSString *)message{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    self.imageview.image = image;
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
