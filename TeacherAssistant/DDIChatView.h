//
//  ViewController.h
//  ChatMessageTableViewController
//
//  Created by Yongchao on 21/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//
#import "JSMessagesViewController.h"
#import "DDIDataModel.h"
#import "Message.h"
#import "UIImage+Scale.h"
#import "CommonFunc.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "DDIMyInforView.h"
#import "DDIStudentInfo.h"


/*
 
#import "DDINewsTitle.h"
#import "DDINewsDetail.h"
#import "DDIChengjiTitle.h"
#import "DDIChengjiDetail.h"
#import "DDIWenJuanTitle.h"
#import "DDIWenJuanDetail.h"
 */

@interface DDIChatView : JSMessagesViewController<UIActionSheetDelegate,UIDocumentInteractionControllerDelegate>
{
    UIImage *tmpImage;
    int oldMsgCount;
    UILabel *topTip;
    NSMutableArray *requestArray;
    NSTimer *aTimer;
    UIDocumentInteractionController *documentInteractionController;
}

@property (nonatomic, strong) NSString* respondUser;
@property (nonatomic, strong) NSString* respondName;
@property (nonatomic) int curMaxId;
@property (nonatomic, strong) UIImage* respondManImage;
@property (nonatomic, strong) UIImage* hostManImage;
@property (nonatomic, strong) NSString *userWeiYi;
@property (nonatomic,strong) UIImage *willSendImage;
-(void) postNewMsg:(Message *)newMsg;
@end
