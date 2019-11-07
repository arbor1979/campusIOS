//
//  DDIViewController.h
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "DDIMainMenu.h"
#import "ASIFormDataRequest.h"
#import "DDIAppDelegate.h"
#import "UIImage+Scale.h"
#import "UIPopoverListView.h"
#import "DDIDataModel.h"
#import "UIPopoverListView.h"
#import "XHDrawerController.h"
#import "OLGhostAlertView.h"
#import "ASIHTTPRequest.h"
@interface DDIVLoginMain : UIViewController <UITextFieldDelegate,NSURLConnectionDelegate,UIAlertViewDelegate,UIPopoverListViewDelegate,UIPopoverListViewDataSource>
{
    NSMutableArray *userListArray;
    UIPopoverListView *popView;
    NSUserDefaults *userDefaultes;
    NSMutableArray *requestArray;
}
- (IBAction)TestLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *loginImage;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *showVersion;

//接收从服务器返回数据。
@property (strong,nonatomic) NSMutableData *datas;

- (IBAction)bgTouchDown:(id)sender;
- (IBAction)loginClick:(id)sender;

-(void) inputFrameShake;
-(void) postLogin;
-(void) postUserInfo;
-(void)hideTip;

@end
