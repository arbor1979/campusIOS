//
//  DDIClassSchedule.m
//  TeacherAssistant
//
//  Created by yons on 13-11-13.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIClassSchedule.h"
#import "DDIClassAttend.h"
#import "DDIKeJianDownload.h"
#import "DDIKeTangExam.h"
#import "DDIKeTangPingJia.h"

@interface DDIClassSchedule ()

@end

CGRect orgRectLeftBar;
CGRect orgRectTopBar;
CGRect orgRectMainView;
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSMutableArray *colorArray;
extern int kUserType;
extern NSString *kServiceURL;
extern NSString *kUserIndentify;
@implementation DDIClassSchedule


- (void)viewDidLoad
{
    [super viewDidLoad];
    userDefaultes = [NSUserDefaults standardUserDefaults];
    calendar=[NSCalendar currentCalendar];
    unitFlags=NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday;
    buttonArray=[NSMutableArray array];
    indexStrArray=[NSMutableArray array];
    banjiname=@"";
    //设置背景图
//    self.bgImage.image=[UIImage imageNamed:@"ScheduleBg"];
    [self changeScheduleBg];
    
    //拖拽
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePanGestures:)];
    //无论最大还是最小都只允许一个手指
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.mainView addGestureRecognizer:self.panGestureRecognizer];
    
    //初始位置大小
    orgRectTopBar=self.topBarView.frame;
    orgRectLeftBar=self.leftBarView.frame;
    orgRectMainView=self.mainView.frame;
    
    weekDayArray=[NSArray arrayWithObjects:@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",nil];
    [self initTitleBar];
    
    //获取课表
    scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
    [self reSetColorMap];
    NSString *curWeek=[userInfoDic objectForKey:@"当前周次"];
    _WeekNo=[NSString stringWithFormat:@"第%@周(本周)",curWeek];
    
    weekLastBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    //[weekLastBtn setBackgroundImage:[UIImage imageNamed:@"arrowLeft"] forState:UIControlStateNormal];
    [weekLastBtn setImage:[UIImage imageNamed:@"arrowLeft"] forState:UIControlStateNormal];
    weekLastBtn.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    [weekLastBtn addTarget:self action:@selector(weekDec) forControlEvents:UIControlEventTouchUpInside];
    weekNextBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    //[weekNextBtn setBackgroundImage:[UIImage imageNamed:@"arrowRight"] forState:UIControlStateNormal];
    [weekNextBtn setImage:[UIImage imageNamed:@"arrowRight"] forState:UIControlStateNormal];
    weekNextBtn.contentEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
    [weekNextBtn addTarget:self action:@selector(weekInc) forControlEvents:UIControlEventTouchUpInside];
    NSString *selWeek=@"";
    if([[userInfoDic objectForKey:@"选择周次"] isEqual:[userInfoDic objectForKey:@"当前周次"]])
        selWeek=_WeekNo;
    else
        selWeek=[NSString stringWithFormat:@"第%@周",[userInfoDic objectForKey:@"选择周次"]];
    weekSelBtn=[[UIButton alloc] init];
    [weekSelBtn setTitle:selWeek forState:UIControlStateNormal];
    [weekSelBtn addTarget:self action:@selector(popWeekList) forControlEvents:UIControlEventTouchUpInside];
    [weekSelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if([[[UIDevice currentDevice]systemVersion] floatValue] >= 9.0)
    {
        myStackView=[[UIStackView alloc]initWithFrame:CGRectMake(0, 0, 170, 44)];
        myStackView.axis=UILayoutConstraintAxisHorizontal;
        myStackView.alignment=UIStackViewAlignmentCenter;
        myStackView.spacing=5;
        [myStackView addArrangedSubview:weekLastBtn];
        [myStackView addArrangedSubview:weekSelBtn];
        [myStackView addArrangedSubview:weekNextBtn];
        myStackView.distribution=UIStackViewDistributionEqualSpacing;
    }
    else
    {
        myStackView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 170, 44)];
        weekLastBtn.frame=CGRectMake(0, 10, 24, 24);
        weekNextBtn.frame=CGRectMake(146, 10, 24, 24);
        weekSelBtn.frame=CGRectMake(24, 0, 122, 44);
        [myStackView addSubview:weekLastBtn];
        [myStackView addSubview:weekSelBtn];
        [myStackView addSubview:weekNextBtn];
    }
    /*
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selWeek stringByAppendingString:@"▼"]];
    [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
    if(kIOS7)
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, str.length)];
        
    }
    else
    {
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, str.length)];
    }
    [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
     */
    
    [buttonArray removeAllObjects];
    [indexStrArray removeAllObjects];
    for (int i=0;i<[scheduleArray count];i++)
    {
        NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
        [self drawClassRect:classInfo index:i];
        
    }
    [self reSetLocalNotification];
    
    
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    actionSheet.backgroundColor=[UIColor whiteColor];
    [actionSheet setBounds:CGRectMake(0, 0, 100, 150)];
    pickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 120)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *spacer=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width=20;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(docancel)];
    navItem.leftBarButtonItems = [NSArray arrayWithObjects:spacer,leftButton,nil];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done)];

    navItem.rightBarButtonItems =[NSArray arrayWithObjects:spacer,rightButton,nil];
    NSArray *array = [[NSArray alloc] initWithObjects:navItem, nil];
    [navBar setItems:array];
    
    
    [actionSheet addSubview:navBar];
    [actionSheet addSubview:pickerView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if([[[UIDevice currentDevice]systemVersion] floatValue] >=8.0)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        pickerView.frame=CGRectMake(0, 40, alertController.view.bounds.size.width, 160);
        navBar.frame=CGRectMake(0, 0, alertController.view.bounds.size.width-20, 40);
        
        [alertController.view addSubview:navBar];
        [alertController.view addSubview:pickerView];
    }
    
#endif
    
    weekArray=[NSMutableArray array];
    NSNumber *maxWeek=[userInfoDic objectForKey:@"最大周次"];
    if(curWeek.intValue>maxWeek.intValue)
        maxWeek=[NSNumber numberWithInt:curWeek.intValue+1];
  
    for(int i=1;i<=maxWeek.intValue;i++)
    {
        NSString *text=[NSString stringWithFormat:@"第%d周",i];
        NSNumber *n=[NSNumber numberWithInt:i];
        if(curWeek.intValue==n.intValue)
            text=[text stringByAppendingString:@"(本周)"];
        [weekArray addObject:text];
    }
    requestArray=[NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifChangeWeekToCurweek)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadSchedule)
                                                 name:@"reloadSchedule"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeScheduleBg)
                                                 name:@"changeScheduleBg"
                                               object:nil];
    if(scheduleArray.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本周没有课程"];
        [tipView showInView:self.view];
        return;
    }
}
-(void)weekDec
{
    NSString *selweek=[userInfoDic objectForKey:@"选择周次"];
    if(selweek.intValue>1)
    {
        selweek=[NSString stringWithFormat:@"%d",selweek.intValue-1];
        NSString *selected1 = [weekArray objectAtIndex:selweek.intValue-1];
        if(selected1 )
        {
            NSRange range = [selected1 rangeOfString:@"(本周)"];
            if (range.length == 0)
                selected1=[selected1 stringByAppendingString:@"(非本周)"];

            [weekSelBtn setTitle:selected1 forState:UIControlStateNormal];
            [self postUserInfo:selweek];
        }
    }
}
-(void)weekInc
{
    NSString *selweek=[userInfoDic objectForKey:@"选择周次"];
    NSString *maxweek=[userInfoDic objectForKey:@"最大周次"];
    if(selweek.intValue<maxweek.intValue)
    {
        selweek=[NSString stringWithFormat:@"%d",selweek.intValue+1];
        NSString *selected1 = [weekArray objectAtIndex:selweek.intValue-1];
        if(selected1 )
        {
            NSRange range = [selected1 rangeOfString:@"(本周)"];
            if (range.length == 0)
                selected1=[selected1 stringByAppendingString:@"(非本周)"];
            
            [weekSelBtn setTitle:selected1 forState:UIControlStateNormal];
            [self postUserInfo:selweek];
        }
    }
}
-(void) changeScheduleBg
{
    NSString *bgname=[userDefaultes valueForKey:@"课表背景"];
    UIImage *img;
    if(![bgname isEqualToString:@"ScheduleBg"])
    {
        img=[UIImage imageWithContentsOfFile:bgname];
        if(img==nil)
            img=[UIImage imageNamed:@"ScheduleBg"];
    }
    else
        img=[UIImage imageNamed:@"ScheduleBg"];
    self.bgImage.backgroundColor=[UIColor colorWithPatternImage:img];
}
-(void)reloadSchedule
{
    [self postUserInfo:[userInfoDic objectForKey:@"当前周次"]];
}
-(void)ifChangeWeekToCurweek
{
    if(![[userInfoDic objectForKey:@"选择周次"] isEqual:[userInfoDic objectForKey:@"当前周次"]])
    {
        NSString *selected1 = [NSString stringWithFormat:@"第%@周(本周)",[userInfoDic objectForKey:@"当前周次"]];
        /*
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selected1 stringByAppendingString:@"▼"]];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
        [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
        [weekSelBtn sizeToFit];
         */
        [weekSelBtn setTitle:selected1 forState:UIControlStateNormal];
        [self postUserInfo:[userInfoDic objectForKey:@"当前周次"]];
    }
    else
    {
        NSDate *lastdate=[userDefaultes valueForKey:@"初始化时间"];
        NSDateComponents *comps=[calendar components:unitFlags fromDate:lastdate];
        NSInteger lastweek=[comps weekOfYear];
        comps=[calendar components:unitFlags fromDate:[NSDate date]];
        NSInteger nowweek=[comps weekOfYear];
        if(lastweek!=nowweek)
            [self postUserInfo:@"0"];
    }
}
- (void) done{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];

    
    
    NSInteger row1 = [pickerView selectedRowInComponent:0];
	NSString *selected1 = [weekArray objectAtIndex:row1];
    if(selected1 )
    {
        NSRange range = [selected1 rangeOfString:@"(本周)"];
        if (range.length == 0)
            selected1=[selected1 stringByAppendingString:@"(非本周)"];
        /*
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[selected1 stringByAppendingString:@"▼"]];
        [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, str.length-1)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:8] range:NSMakeRange(str.length-1,1)];
        [weekSelBtn setAttributedTitle:str forState:UIControlStateNormal];
        [weekSelBtn sizeToFit];
         */
        [weekSelBtn setTitle:selected1 forState:UIControlStateNormal];
        [self postUserInfo:[NSString stringWithFormat:@"%d",(int)row1+1]];
    }
    
}
-(void) postUserInfo:(NSString *)selWeek
{
    NSString *weekbegin=[userDefaultes valueForKey:@"weekBegin"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@appserver.php?action=initinfo&zip=1&WEEK=%@",kServiceURL,selWeek]];
    NSString *postStr = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\",\"周日为第一天\":\"%@\",\"banjiname\":\"%@\"}",kUserIndentify,weekbegin,banjiname];
    postStr =[GTMBase64 base64StringBystring:postStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"初始化数据";
    [requestArray addObject:request];
    [request startAsynchronous];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取所选周课表" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    if([request.username isEqualToString:@"初始化数据"])
    {
        NSString* dataStr;
        NSData *upzipData;
        @try
        {
            dataStr = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
            NSData *_decodedData   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
            upzipData = [LFCGzipUtillity uncompressZippedData:_decodedData];
            dataStr = [[NSString alloc] initWithData:upzipData encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
        if(dataStr==nil || dataStr.length==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取周课表失败"];
            [tipView showInView:self.view];
            
        }
        else
        {
            NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingAllowFragments error:nil];
            userInfoDic=[dict mutableCopy];
            [self refreshTable];
        }
        
    }
}
-(void)refreshTable
{
    [userDefaultes setObject:[NSDate date] forKey:@"初始化时间"];
    [self initTitleBar];
    for(UIButton *subview in self.mainView.subviews)
    {
        if([subview isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
    }
    scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
    [self reSetColorMap];
    [buttonArray removeAllObjects];
    [indexStrArray removeAllObjects];
    for (int i=0;i<[scheduleArray count];i++)
    {
        NSDictionary *classInfo=[scheduleArray objectAtIndex:i];
        [self drawClassRect:classInfo index:i];
        
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
       NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:[error localizedDescription]];
    [tipView show];
    request=nil;
}
- (void) docancel{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    
}
-(void)popWeekList
{
    NSString *title=weekSelBtn.titleLabel.text;
    title=[title stringByReplacingOccurrencesOfString:@"(非本周)" withString:@""];
    NSInteger row1=[weekArray indexOfObject:title];
    if(row1>=0 && row1<50)
    {
        [pickerView selectRow:row1 inComponent:0 animated:NO];
        
        if(alertController)
            [self presentViewController:alertController animated:YES completion:nil];
        else
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
        return weekArray.count;
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component {
		return [weekArray objectAtIndex:row];
}
-(void)reSetLocalNotification
{
    NSMutableDictionary *allWeekDayClass=[NSMutableDictionary dictionary];
    NSArray *futureScheduleArray=[userInfoDic objectForKey:@"未来两周课程"];
    for (int i=0;i<[futureScheduleArray count];i++)
    {
        NSDictionary *classInfo=[futureScheduleArray objectAtIndex:i];
        NSString *theDay=[classInfo objectForKey:@"上课日期"];
        NSString *banJi;
        if(kUserType==1)
            banJi=[classInfo objectForKey:@"班级"];
        else
            
            banJi=[classInfo objectForKey:@"课程"];
        NSMutableArray *item=[allWeekDayClass objectForKey:theDay];
        if(!item)
            item=[NSMutableArray arrayWithObject:banJi];
        else
        {
            if(![item containsObject:banJi])
            {
                [item addObject:banJi];
            }
        }
        [allWeekDayClass setObject:item forKey:theDay];

    }
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *ifPopDay=[defaults objectForKey:@"ifPopDay"];
    if(![ifPopDay isEqualToString:@"off"])
    {
        NSString *theTime=[defaults objectForKey:@"alertTime"];
        if(!theTime)
            theTime=@"前一天 20:00";
        NSArray *strArray=[theTime componentsSeparatedByString:@" "];
        NSString *day=[strArray objectAtIndex:0];
        NSString *str=[strArray objectAtIndex:1];
        strArray=[str componentsSeparatedByString:@":"];
        NSString *hour=[strArray objectAtIndex:0];
        NSString *minute=[strArray objectAtIndex:1];
        
        NSString *dayName=@"今天";
        if([day isEqualToString:@"前一天"])
            dayName=@"明天";
        
        for(int i=0;i<15;i++)
        {
            NSDate *dt=[[NSDate alloc]initWithTimeIntervalSinceNow:24*3600*i];
            NSString *daystr=[CommonFunc stringFromDateShort:dt];
            NSArray *classArray=[allWeekDayClass objectForKey:daystr];
            NSString *body;
            if(classArray.count>0)
            {
                if(kUserType==1)
                    body=[NSString stringWithFormat:@"%@有%d个班的课要上:",dayName,(int)classArray.count];
                else
                    body=[NSString stringWithFormat:@"%@有%d门课要上:",dayName,(int)classArray.count];
                for (int j=0; j<classArray.count; j++) {
                    body=[body stringByAppendingString:@"\n"];
                    body=[body stringByAppendingString:[classArray objectAtIndex:j]];
                }
                NSString *tipDateStr=[NSString stringWithFormat:@"%@ %@:%@:00",daystr,hour,minute];
                NSDate *tipDate=[CommonFunc dateFromString:tipDateStr];
                
                if([day isEqualToString:@"前一天"])
                {
                    tipDate=[NSDate dateWithTimeInterval:-24*60*60 sinceDate:tipDate];
                }
                UILocalNotification *localNoti = [[UILocalNotification alloc]init];
                localNoti.alertBody = body;
                localNoti.fireDate=tipDate;
                localNoti.soundName=UILocalNotificationDefaultSoundName;
                localNoti.repeatInterval=0;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
            }
            
                
        }
        
    }
}
-(void)initTitleBar
{
    NSString *weekDayBegin=[[userInfoDic objectForKey:@"课表规则"] objectForKey:@"周开始日期"];
    if(weekDayBegin!=nil)
    {
        NSDate *dt=[CommonFunc dateFromStringShort:weekDayBegin];
        NSInteger begin=[CommonFunc getweekDayWithDate:dt];
       for(int i=1;i<=7;i++)
        {
            NSDate *now=[NSDate date];
            UILabel *tv=(UILabel *)[self.topBarView viewWithTag:100+i];
            NSString *datetext=[CommonFunc stringFromDateShort:dt];
            NSString *nowText=[CommonFunc stringFromDateShort:now];
            if([datetext isEqualToString:nowText])
                tv.backgroundColor=[UIColor colorWithRed:7/255.0f green:92/255.0f blue:27/255.0f alpha:1];
            else
            {
                if(i%2==1)
                    tv.backgroundColor=[UIColor colorWithRed:0.159048f green:0.554445f blue:0.30384f alpha:1];
                else
                    tv.backgroundColor=[UIColor colorWithRed:0.306536f green:0.737287f blue:0.46742f alpha:1];
            }
            [tv setFont:[UIFont systemFontOfSize:11]];
            if(begin==weekDayArray.count)
                begin=0;
            NSString *oldtext=[weekDayArray objectAtIndex:begin];
            begin++;
            datetext=[datetext substringFromIndex:5];
            [tv setText:[NSString stringWithFormat:@"%@\n%@",oldtext,datetext]];
            dt=[NSDate dateWithTimeInterval:24*60*60 sinceDate:dt];
            
        }
        
    }
    NSArray *sectionTimeArray=[[userInfoDic objectForKey:@"课表规则"] objectForKey:@"节次时间"];
    if(sectionTimeArray!=nil)
    {
        
        for(int i=0;i<sectionTimeArray.count;i++)
        {
            if(i>11) break;
            UILabel *lab=(UILabel *)[self.leftBarView viewWithTag:101+i];
            
            NSDictionary *item=[sectionTimeArray objectAtIndex:i];
            NSString *timestr=[item objectForKey:@"时间"];
            NSArray *timeArray=[timestr componentsSeparatedByString:@"-"];
            NSString *starttime=[timeArray objectAtIndex:0];
            NSString *showtext=[NSString stringWithFormat:@"%@\n%@",starttime,[item objectForKey:@"名称"]];
            NSMutableAttributedString *attrString=[[NSMutableAttributedString alloc] initWithString:showtext];
            UIFont *littleFont=[UIFont systemFontOfSize:10];

            [attrString addAttribute:NSFontAttributeName value:littleFont range:NSMakeRange(0, starttime.length)];
            lab.attributedText=attrString;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *banjistr=[userInfoDic objectForKey:@"管辖班级"];
    if(kUserType==1 && banjistr!=nil && banjistr.length>0)
    {
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        backBtn.imageEdgeInsets=UIEdgeInsetsMake(5, 5, 5, 5);
        [backBtn setImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
        //[backBtn setBackgroundImage:[UIImage imageNamed:@"dropdown"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(dropdownmenu:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.parentViewController.navigationItem.rightBarButtonItem=backBarBtn;
    }
    self.parentViewController.navigationItem.title=nil;
    self.parentViewController.navigationItem.titleView=myStackView;
    [super viewDidAppear:animated];
    
}

-(void)dropdownmenu:(id)sender
{
    NSString *banjistr=[userInfoDic objectForKey:@"管辖班级"];
    banjistr=[banjistr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    banjistr=[NSString stringWithFormat:@"我的课表,%@",banjistr];
    NSArray *menutitle=[banjistr componentsSeparatedByString:@","];
   [YBPopupMenu showRelyOnView:sender titles:menutitle icons:nil menuWidth:170 delegate:self];
}
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    //推荐回调
    NSLog(@"点击了 %@ 选项",ybPopupMenu.titles[index]);
    if(index>0)
        banjiname=ybPopupMenu.titles[index];
    else
        banjiname=@"";
    [self reloadSchedule];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    self.parentViewController.navigationItem.titleView=Nil;
    [super viewDidDisappear:animated];
}
-(void) drawClassRect:(NSDictionary *)classInfo index:(NSInteger)index
{
    NSString *weekbegin=[userDefaultes valueForKey:@"weekBegin"];
    
    NSString *sectionStr=[classInfo objectForKey:@"节次"];
    NSString *weekDay=[NSString stringWithFormat:@"%@",[classInfo objectForKey:@"星期"]];
    NSInteger iweekday=weekDay.intValue;
    if([weekbegin isEqualToString:@"0"])
    {
        iweekday--;
        if(iweekday==-1)
            iweekday=7;
    }
    NSString *className=[classInfo objectForKey:@"课程"];
    NSString *classRoom=[classInfo objectForKey:@"教室"];
    NSString *banJi;
    if(kUserType==1 && banjiname.length==0)
        banJi=[classInfo objectForKey:@"班级"];
    else
        banJi=[classInfo objectForKey:@"课程"];
    NSArray *sectionArray=[sectionStr componentsSeparatedByString:@"-"];
    CGFloat x=iweekday*60+1;
    CGFloat y=([[sectionArray objectAtIndex:0] intValue]-1)*45+1;
    CGFloat height=[[sectionArray objectAtIndex:[sectionArray count]-1] intValue]*45-y;
   
    UIColor *randColor=[colorMapDic objectForKey:banJi];
    /*
    UIEdgeInsets insets=UIEdgeInsetsMake(5, 5, 5, 5);
    DDIInsetsLabel *classText = [[DDIInsetsLabel alloc] initWithFrame: CGRectMake(x, y, 60-1, height) andInsets:insets];
    classText.backgroundColor = randColor;
    classText.textColor=[UIColor blackColor];
    classText.lineBreakMode=NSLineBreakByCharWrapping;
    classText.alpha=1;
    classText.numberOfLines = 0;
    classText.tag=[classNo intValue];
    [classText setFont:[UIFont systemFontOfSize:10.0]];
    NSString *titleValue=[NSString stringWithFormat:@"%@(%@)",className,classRoom];
    [classText setText:titleValue];
    [self.mainView addSubview:classText];
     
    */
    BOOL flag=false;
    for (int i=0;i<buttonArray.count;i++) {
        UIButton *btnItem=[buttonArray objectAtIndex:i];
        NSString *indexStr=[indexStrArray objectAtIndex:i];
        NSDictionary *scheduleItem=[scheduleArray objectAtIndex:btnItem.tag];
        NSString *weekDay1=[scheduleItem objectForKey:@"星期"];
        NSString *sectionStr1=[scheduleItem objectForKey:@"节次"];
        NSString *className1=[scheduleItem objectForKey:@"课程"];
        
        if([weekDay isEqualToString:weekDay1] && [sectionStr isEqualToString:sectionStr1] && [className isEqualToString:className1])
        {
            flag=true;
            if(indexStr!=nil && indexStr.length>0)
                indexStr=[indexStr stringByAppendingString:@","];
            indexStr=[indexStr stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)index]];
            [indexStrArray replaceObjectAtIndex:i withObject:indexStr];
            NSString *newTitle=[NSString stringWithFormat:@"%@,%@",btnItem.currentTitle,banJi];
            [btnItem setTitle:newTitle forState:UIControlStateNormal];
            break;
        }
    }
    if(!flag)
    {
        UIButton *innerBtn=[[UIButton alloc] initWithFrame:CGRectMake(x, y, 60-1, height)];
        innerBtn.backgroundColor=randColor;
        innerBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        NSString *titleValue=[NSString stringWithFormat:@"%@(%@)%@",className,classRoom,banJi];
        [innerBtn setTitle:titleValue forState:UIControlStateNormal];
        [innerBtn setTag:index];
        //innerBtn.titleLabel.text=[NSString stringWithFormat:@"%ld",(long)index];
        [innerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [innerBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
        innerBtn.titleLabel.lineBreakMode=NSLineBreakByCharWrapping;
        innerBtn.titleLabel.numberOfLines=floor((height+1)/45)*3;
        
        innerBtn.alpha=1;
        [innerBtn addTarget:self action:@selector(openAttendView:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:innerBtn];
        [buttonArray addObject:innerBtn];
        [indexStrArray addObject:[NSString stringWithFormat:@"%ld",(long)index]];
    }

}
-(void)openAttendView:(UIButton *)sender
{
    UIButton *btn=(UIButton *)sender;
    NSInteger index=[buttonArray indexOfObject:btn];
    NSString *indexStr=[indexStrArray objectAtIndex:index];
    indexArray=[indexStr componentsSeparatedByString:@","];
    if(indexArray!=nil && indexArray.count>1)
    {
        
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:nil,nil];
        
        for(NSString *index in indexArray)
        {
            NSDictionary *schedule=[scheduleArray objectAtIndex:index.intValue];
            NSString *banji=@"";
            if(kUserType==1)
                banji=[schedule objectForKey:@"班级"];
            else
                banji=[schedule objectForKey:@"教师姓名"];
            [alert addButtonWithTitle:banji];
        }
        [alert show];
    }
    else
    {
        if(banjiname.length>0)
        {
            DDICourseInfo *dest1=[self.storyboard instantiateViewControllerWithIdentifier:@"courseinfo"];
            NSDictionary *classInfo=[scheduleArray objectAtIndex:indexStr.intValue];
            dest1.className=[classInfo objectForKey:@"课程"];
            dest1.teacherUserName=[classInfo objectForKey:@"教师用户名"];
            dest1.classNo=[classInfo objectForKey:@"编号"];
            dest1.classIndex=[NSNumber numberWithInt:indexStr.intValue];
            [self.navigationController pushViewController:dest1 animated:YES];
            
        }
        else
            [self performSegueWithIdentifier:@"classAttend" sender:[NSNumber numberWithInt:indexStr.intValue]];
    }
}
// 拖拽手势
- (void)handlePanGestures:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    switch (gestureRecognizer.state) {
        
        case UIGestureRecognizerStateChanged:{
           
            CGRect screen = [ UIScreen mainScreen ].bounds;
            CGFloat minX=screen.size.width-self.mainView.frame.size.width;
            CGFloat maxX=30;
            if(minX>maxX)
                minX=maxX;
            CGFloat minY=self.view.frame.size.height-self.mainView.frame.size.height;
            CGFloat maxY=30;
            if(minY>maxY)
                minY=maxY;
            
            /*
             让view跟着手指移动
             
             1.获取每次系统捕获到的手指移动的偏移量translation
             2.根据偏移量translation算出当前view应该出现的位置
             3.设置view的新frame
             4.将translation重置为0（十分重要。否则translation每次都会叠加，很快你的view就会移除屏幕！）
             */
            
            CGPoint translation = [gestureRecognizer translationInView:self.view];
            if(gestureRecognizer.view.frame.origin.x + translation.x>maxX)
                translation.x=maxX-gestureRecognizer.view.frame.origin.x;
            if(gestureRecognizer.view.frame.origin.x + translation.x<minX)
                translation.x=minX-gestureRecognizer.view.frame.origin.x;
            if(gestureRecognizer.view.frame.origin.y + translation.y>maxY)
                translation.y=maxY-gestureRecognizer.view.frame.origin.y;
            if(gestureRecognizer.view.frame.origin.y + translation.y<minY)
                translation.y=minY-gestureRecognizer.view.frame.origin.y;
            view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, gestureRecognizer.view.center.y + translation.y);
            [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];//  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加，很快你的view就会移除屏幕！
            
            self.leftBarView.frame=CGRectMake(orgRectLeftBar.origin.x,view.frame.origin.y,orgRectLeftBar.size.width,orgRectLeftBar.size.height);
            self.topBarView.frame=CGRectMake(view.frame.origin.x,orgRectTopBar.origin.y,orgRectTopBar.size.width,orgRectTopBar.size.height);
            break;
        }
        default:{
            break;
        }
    }
}

-(void) moveView:(UIView *)view direct:(UISwipeGestureRecognizerDirection)direction rect:(CGRect) orgRect
{
    
    CGRect screen = [ UIScreen mainScreen ].bounds;
    [UIView animateWithDuration:0.5 animations:^(void){
       
        if(direction==UISwipeGestureRecognizerDirectionRight)
            [view setFrame:CGRectMake(orgRect.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionLeft)
            [view setFrame:CGRectMake(screen.size.width-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionUp)
            [view setFrame:CGRectMake(view.frame.origin.x, self.view.frame.size.height-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        else if(direction==UISwipeGestureRecognizerDirectionDown)
            [view setFrame:CGRectMake(view.frame.origin.x, orgRect.origin.y, view.frame.size.width, view.frame.size.height)];
        NSLog(@"self:%f Y:%f",self.view.frame.size.height,view.frame.size.height);
    }completion:^(BOOL finished){
       
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"classAttend"])
    {
        UINavigationController *NavController=segue.destinationViewController;
        
        UITabBarController *destController=[NavController.childViewControllers objectAtIndex:0];
        NSNumber *number=(NSNumber *)sender;
        
        DDIClassAttend *dest=[destController.childViewControllers objectAtIndex:0];
        NSDictionary *classInfo=[scheduleArray objectAtIndex:number.intValue];
        NSString *banjiName=[classInfo objectForKey:@"班级"];
        NSString *classNo=[classInfo objectForKey:@"编号"];
        dest.banjiName=banjiName;
        dest.classNo=classNo;
        dest.classIndex=number;
        
        DDICourseInfo *dest1=[destController.childViewControllers objectAtIndex:1];
        dest1.className=[classInfo objectForKey:@"课程"];
        dest1.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest1.classNo=classNo;
        dest1.classIndex=number;
        
        DDIKeJianDownload *dest2=[destController.childViewControllers objectAtIndex:2];
        dest2.className=[classInfo objectForKey:@"课程"];
        dest2.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest2.classNo=classNo;
        
        DDIKeTangExam *dest3=[destController.childViewControllers objectAtIndex:3];
        dest3.className=[classInfo objectForKey:@"课程"];
        dest3.classNo=classNo;
        dest3.classIndex=number.intValue;
        dest3.banjiName=banjiName;
        
        DDIKeTangPingJia *dest4=[destController.childViewControllers objectAtIndex:4];
        dest4.banjiName=banjiName;
        dest4.classNo=classNo;
        dest4.classIndex=number;
        dest4.className=[classInfo objectForKey:@"课程"];
        dest4.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        if(kUserType==1)
        {
            [dest1 removeFromParentViewController];
        }
        else
        {
            [dest removeFromParentViewController];
        }
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        destController.navigationItem.leftBarButtonItem = backButtonItem;
    }

}
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
   
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex>0)
    {
        NSString *indexStr=[indexArray objectAtIndex:buttonIndex-1];
        [self performSegueWithIdentifier:@"classAttend" sender:[NSNumber numberWithInt:indexStr.intValue]];
    }
}
-(void)reSetColorMap
{
    if(colorMapDic==nil)
        colorMapDic=[NSMutableDictionary dictionary];
    [colorMapDic removeAllObjects];
    int i=0;
    if(scheduleArray!=nil)
    {
        for(NSDictionary *item in scheduleArray)
        {
            NSString *key;
            if(kUserType==1 && banjiname.length==0)
               key=[item objectForKey:@"班级"];
            else
               key=[item objectForKey:@"课程"];
            if([colorMapDic objectForKey:key]==nil)
            {
                if(i==colorArray.count)
                    i=0;
                UIColor *color= [colorArray objectAtIndex:i];
                [colorMapDic setObject:color forKey:key];
                i++;
            }
        }
    }
}
@end
