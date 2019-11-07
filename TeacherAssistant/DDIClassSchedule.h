//
//  DDIClassSchedule.h
//  TeacherAssistant
//
//  Created by yons on 13-11-13.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIMainMenu.h"
#import "OLGhostAlertView.h"
#import "ASIFormDataRequest.h"
#import "DDICourseInfo.h"
#import "YBPopupMenu/YBPopupMenu.h"
@interface DDIClassSchedule : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate,YBPopupMenuDelegate>
{
    NSArray *scheduleArray;
    UIButton *weekSelBtn;
    UIButton *weekLastBtn;
    UIButton *weekNextBtn;
    UIActionSheet *actionSheet;
    UIPickerView *pickerView;
    NSMutableArray *weekArray;
    NSMutableArray *requestArray;
    OLGhostAlertView *alertTip;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    UIAlertController *alertController;
#else
    UIViewController *alertController;
#endif
    NSUserDefaults *userDefaultes;
    NSCalendar *calendar;
    NSInteger unitFlags;
    NSArray *weekDayArray;
    NSMutableArray *buttonArray;
    NSMutableArray *indexStrArray;
    NSArray *indexArray;
    UIStackView *myStackView;
    NSString *banjiname;
    NSMutableDictionary *colorMapDic;
}

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *leftBarView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong,nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) NSString *WeekNo;

-(void) moveView:(UIView *)view direct:(UISwipeGestureRecognizerDirection)direction rect:(CGRect) orgRect;
-(void) drawClassRect:(NSDictionary *)classInfo index:(NSInteger)i;
-(void) reSetLocalNotification;
@end
