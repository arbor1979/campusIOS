//
//  DDIWenJuanDetail.h
//  掌上校园
//
//  Created by yons on 14-3-17.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLGhostAlertView.h"
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "QCheckBox.h"
#import "QRadioButton.h"
#import "CommonFunc.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Scale.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "DDIPictureBrows.h"
#import "NSString+URLEncoding.h"
#import "DDIAppDelegate.h"
#import "DDIMultiSelStudent.h"

@interface DDIWenJuanDetail : UITableViewController<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,SelectMutiDataDelegate>
{
    NSMutableArray *detailArray;
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    UIToolbar * topView;
    UIView *activeView;
    BOOL enabled;
    UIBarButtonItem *rightBtn;
    NSString *saveUrl;
    UIColor *myGreen;
    UIImage *addPhoto;
    MDRadialProgressView *rpv;
    
    UIActionSheet *pickerActionSheet;
    
    UIPickerView *pickerView;
    UIDatePicker *dtPickerView;
    NSArray *pickerArray;
    NSArray *pickerSubArray;
    NSArray *pickerThirdArray;
    NSDictionary *pickerDict;
    UIButton *senderBtn;
    int curRowIndex;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    UIAlertController *alertController;
#else
    UIViewController *alertController;
#endif
}
@property (nonatomic,strong) NSString *interfaceUrl;
@property (nonatomic,strong) NSString *examStatus;
@property (nonatomic,strong) NSString *autoClose;
@property (nonatomic,strong) NSString *gpsLocation;
@property (nonatomic,strong) NSMutableArray *parentTitleArray;
@property (nonatomic) int key;
@end
