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

@interface DDIWenJuanDetail : UITableViewController<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSMutableArray *detailArray;
    NSString *savePath;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
    UIToolbar * topView;
    UITextView *activeView;
    BOOL enabled;
    UIBarButtonItem *rightBtn;
    NSString *saveUrl;
    UIColor *myGreen;
    UIImage *addPhoto;
    MDRadialProgressView *rpv;
    UITableViewCell *parentCell;
    
    UIActionSheet *pickerActionSheet;
    
    UIPickerView *pickerView;
    UIDatePicker *dtPickerView;
    NSArray *pickerArray;
    UIButton *senderBtn;

    int top;
    int curRow;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    UIAlertController *alertController;
#endif
}
@property (nonatomic,strong) NSString *interfaceUrl;
@property (nonatomic,strong) NSString *examStatus;
@property (nonatomic,strong) NSMutableArray *parentTitleArray;
@property (nonatomic) int key;
@end