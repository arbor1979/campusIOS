//
//  DDIHuiZong.h
//  掌上校园
//
//  Created by yons on 14-3-8.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "OLGhostAlertView.h"
#import "CommonFunc.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "DDINewsTitle.h"
#import "DDIKaoQinTitle.h"
#import "DDIChengjiTitle.h"
#import "DDIWenJuanTitle.h"
#import "JSBadgeView.h"
#import "DDIMessageList.h"
#import "DDILinkManGroup.h"
#import "DDIClassSchedule.h"
#import "SidebarViewController.h"
#import "XHDrawerController.h"
#import "DDIHelpView.h"
#import "DDILiuYan.h"
#import <AVFoundation/AVFoundation.h>
#import "QRCodeController.h"

@interface DDIHuiZong : UICollectionViewController
{
    NSMutableArray *requestArray;
    NSMutableArray *titleArray;
    NSString *savepath;
    int allUnread;
    NSDictionary *unreadDic;
    NSMutableArray *moduleGroup;
    NSMutableDictionary *moduleList;
}
@end
