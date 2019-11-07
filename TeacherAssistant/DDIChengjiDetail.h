//
//  DDIChengjiDetail.h
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLGhostAlertView.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "DDIHelpView.h"
#import "DDIWenJuanDetail.h"
#import "CommonFunc.h"
//#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "DDICourseInfo.h"
#import "DDIKeJianDownload.h"
#import "DDIKeTangExam.h"
#import "DDIKeTangPingJia.h"
#import "DDIClassAttend.h"
#import "DDIChengjiTitle.h"
#import "DDIWenJuanTitle.h"
#import "NSString+URLEncoding.h"

@interface DDIChengjiDetail : UITableViewController<UIDocumentInteractionControllerDelegate>
{
    NSMutableArray *detailArray;
    NSString *savePath,*btnUrl,*loginUrl;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    NSNumber *leftWidth;
    NSString *savepath;
    
}
@property (nonatomic,strong) NSString *interfaceUrl;
@property (strong,nonatomic) UIDocumentInteractionController *documentInteractionController;
@end
