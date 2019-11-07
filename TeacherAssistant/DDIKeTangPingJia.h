//
//  DDIKeTangPingJia.h
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+URLEncoding.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Scale.h"
#import "CommonFunc.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "DDIPictureBrows.h"
#import "QCheckBox.h"
@interface DDIKeTangPingJia : UITableViewController<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIBarButtonItem *rightBtn;
    UIImage *goldStar;
    UIImage *grayStar;
    int iJiLvIndex;
    int iWeiShengIndex;
    float kOldOffset;
    int teacherGrade;
    int classGrade;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    UIImage *addPhoto;
    NSMutableArray *photosArray;
    NSMutableArray *photosArray1;
    NSMutableArray *photosArray2;
    NSString *savePath;
    MDRadialProgressView *rpv;
    int curIndex;
    bool bWanzixi;
}
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *classBtns;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *teacherBtns;
@property (strong,nonatomic) NSString *teacherUserName;
@property (strong,nonatomic) NSString *banjiName;
@property (strong,nonatomic) NSString *className;
@property (strong,nonatomic) NSString *classNo;
@property (strong,nonatomic) NSNumber *classIndex;
@property (weak, nonatomic) IBOutlet UITextView *neiRongText;
@property (weak, nonatomic) IBOutlet UITextView *zuoYeText;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UIStackView *stackShouduan;
@property (weak, nonatomic) IBOutlet UIStackView *stackPingtai;
@property (strong,nonatomic) NSMutableArray *imageSel; //绿色选中图片
@property (strong,nonatomic) NSMutableArray *imageDes; //灰色未选中图片
@property (strong,nonatomic) NSArray *dengjiArray;
@property (strong,nonatomic) NSMutableArray *scheduleArray; //上课记录
@property (strong,nonatomic) NSMutableDictionary *classInfoDic;//本节课信息
@property (strong,nonatomic) UIDocumentInteractionController *documentInteractionController;

- (IBAction)pingJiaClick:(id)sender;
- (IBAction)starPingJiaClick:(id)sender;
-(void) getPingJiaData;
@end
