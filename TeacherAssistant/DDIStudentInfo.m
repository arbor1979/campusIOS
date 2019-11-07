//
//  DDIStudentInfo.m
//  老师助手
//
//  Created by yons on 13-11-29.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIStudentInfo.h"
#import "UIUnderlinedButton.h"
#import "PieChartViewController.h"
#import "DDIStudentResults.h"

extern NSMutableDictionary *userInfoDic;
extern NSMutableDictionary *LinkMandic;
extern Boolean kIOS7;
extern NSString *kUserIndentify;
extern NSString *kInitURL;//默认单点webServic

@interface DDIStudentInfo ()

@end

@implementation DDIStudentInfo


- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[[NSMutableArray alloc] init];
    if(self.student==nil)
    {
        NSDictionary *duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
        NSArray *allLinkMan=[LinkMandic objectForKey:@"数据源_用户信息列表"];
        NSNumber *key=[duizhaoDic objectForKey:self.userWeiYi];
        if(key)
        {
            self.student=[allLinkMan objectAtIndex:key.intValue];
            /*
            NSString *xuehao=[self.student objectForKey:@"学号"];
            NSString *banjiName=[self.student objectForKey:@"班级"];
            NSArray *banjiChengyuan=[userInfoDic objectForKey:banjiName];
            for(int i=0;i<banjiChengyuan.count;i++)
            {
                NSDictionary *item=[banjiChengyuan objectAtIndex:i];
                if([[item objectForKey:@"学号"] isEqualToString:xuehao])
                {
                    self.student=item;
                    break;
                }
            }
            */
        }
    }
    else
        self.userWeiYi=[self.student objectForKey:@"用户唯一码"];
	UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    navbarHeight=self.navigationController.navigationBar.frame.size.height;
    /*
    if(kIOS7)
    {
        //self.automaticallyAdjustsScrollViewInsets=NO;
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.scrollView.frame = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height-navbarHeight-40);
    }
    else
        self.scrollView.frame = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height-navbarHeight-20);
    
    if([UIScreen mainScreen].bounds.size.height<500)
        self.scrollView.frame = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height-navbarHeight-20);
    else
        self.scrollView.frame = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height-navbarHeight-37-20);
    */

    float scrollWidth=self.view.frame.size.width;
    float scrollHeight=self.view.frame.size.height-self.pageControl.frame.size.height;
    
    self.scrollView.contentSize  = CGSizeMake(self.view.frame.size.width*3, scrollHeight);
  
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* page1ViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"page1"];
    self.page1 = page1ViewController.view;
    self.page1.frame=CGRectMake(0.0f, 0.0f, scrollWidth, scrollHeight);
    //self.page1.backgroundColor=[UIColor redColor];
    headImage=(UIImageView *)[page1ViewController.view viewWithTag:11];
    UILabel *stuName=(UILabel *)[page1ViewController.view viewWithTag:12];
    UIButton *stuTel=(UIButton *)[page1ViewController.view viewWithTag:13];
    UIUnderlinedButton *stuTelLink=[[UIUnderlinedButton alloc]initWithFrame:stuTel.frame];
    stuTelLink.titleLabel.font=[UIFont systemFontOfSize: 18.0];
    stuTelLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [stuTel removeFromSuperview];
    [page1ViewController.view addSubview:stuTelLink];
    UILabel *stuEmail=(UILabel *)[page1ViewController.view viewWithTag:14];
    UILabel *stuParentName=(UILabel *)[page1ViewController.view viewWithTag:15];
    UIButton *stuParentTel=(UIButton *)[page1ViewController.view viewWithTag:16];
    UIUnderlinedButton *stuParentTelLink=[[UIUnderlinedButton alloc]initWithFrame:stuParentTel.frame];
    stuParentTelLink.titleLabel.font=[UIFont systemFontOfSize: 18.0];
    stuParentTelLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [stuParentTel removeFromSuperview];
    [page1ViewController.view addSubview:stuParentTelLink];
    UILabel *stuAddress=(UILabel *)[page1ViewController.view viewWithTag:17];
    UILabel *stuMemo=(UILabel *)[page1ViewController.view viewWithTag:18];
    UILabel *banjiName=(UILabel *)[page1ViewController.view viewWithTag:19];
    UILabel *xuehaoLbl=(UILabel *)[page1ViewController.view viewWithTag:20];
    NSString *xuehao=[self.student objectForKey:@"学号"];
    if(xuehao)
        xuehaoLbl.text=[NSString stringWithFormat:@"学号:%@",xuehao];
    stuName.text=[self.student objectForKey:@"姓名"];
    [stuTelLink setTitle:[self.student objectForKey:@"学生电话"] forState:UIControlStateNormal];
  
    stuEmail.text=[self.student objectForKey:@"学生邮箱"];
    stuParentName.text=[self.student objectForKey:@"家长姓名"];
    
    [stuParentTelLink setTitle:[self.student objectForKey:@"家长电话"] forState:UIControlStateNormal];

    stuAddress.text=[self.student objectForKey:@"家庭住址"];
    stuMemo.text=[self.student objectForKey:@"备注"];
    if([self.student objectForKey:@"班级"])
        banjiName.text=[self.student objectForKey:@"班级"];

    NSString *stuSexVal=[self.student objectForKey:@"性别"];
    
    if([stuSexVal isEqualToString:@"女"])
        headImage.image=[UIImage imageNamed:@"woman"];
       //[headImage setImage:[UIImage imageNamed:@"woman"] forState:UIControlStateNormal];
    
    
    //获取已保存的头像
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/students/"];
    headImageName=[NSString stringWithFormat:@"%@%@.jpg",savePath,_userWeiYi];
    if([fileManager fileExistsAtPath:headImageName])
    {
        UIImage *oldImage=[UIImage imageWithContentsOfFile:headImageName];
        CGSize newSize=CGSizeMake(160, 160);
        UIImage *img=[oldImage scaleToSize1:newSize];
        img=[img cutFromImage:CGRectMake(0, 0, 160, 160)];
        headImage.image=img;
        //        UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:page1ViewController action:@selector(handleGesture:)];
//        [headImage addGestureRecognizer:gesture];
        //[headImage addTarget:self action:@selector(popImageView:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        NSString *urlStr=[self.student objectForKey:@"用户头像"];
        if(urlStr)
        {
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=headImageName;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
    }
    headImage.layer.cornerRadius = headImage.frame.size.width / 2;
    headImage.layer.masksToBounds = YES;
    UIButton *tmpBtn=[[UIButton alloc]initWithFrame:headImage.frame];
    [tmpBtn addTarget:self action:@selector(popLargePic) forControlEvents:UIControlEventTouchUpInside];
    [page1ViewController.view addSubview:tmpBtn];
    
    [stuTelLink addTarget:self action:@selector(ActionSheet:)  forControlEvents:UIControlEventTouchUpInside];
    [stuParentTelLink addTarget:self action:@selector(ActionSheet:)  forControlEvents:UIControlEventTouchUpInside];
    
    PieChartViewController* page2ViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"page2"];
    page2ViewController.viewHeight=[[NSNumber alloc]initWithFloat:scrollHeight];
    self.page2 = page2ViewController.view;
    self.page2.frame = CGRectMake(scrollWidth, 0.0f, scrollWidth, scrollHeight);
    [self reloadChuQin];
    
    DDIStudentResults* page3ViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"page3"];
    page3ViewController.viewHeight=[[NSNumber alloc]initWithFloat:scrollHeight];
    self.page3 = page3ViewController.view;
    self.page3.frame = CGRectMake(2 * scrollWidth, 0.0f, scrollWidth, scrollHeight);
    [self reloadChengJi];
    
    self.scrollView.delegate = self;
    
    [self.scrollView setCanCancelContentTouches:YES];
    [self.scrollView setBounces:NO];
    [self.scrollView setDelaysContentTouches:NO];
    
    [self.scrollView addSubview:self.page1];
    [self.scrollView addSubview:self.page2];
    [self.scrollView addSubview:self.page3];
    
}
-(void)reloadChuQin
{
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[self.student objectForKey:@"学号"]  forKey:@"studentId"];
    [dic setObject:[userInfoDic objectForKey:@"当前学期"] forKey:@"当前学期"];
    
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"InterfaceStudent/XUESHENG-KAOQIN-Student.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"学生考勤";
    [requestArray addObject:request];
    [request startAsynchronous];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取出勤数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.page2];
    
}
-(void)reloadChengJi
{
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[self.student objectForKey:@"学号"]  forKey:@"学生编号"];
    [dic setObject:[userInfoDic objectForKey:@"当前学期"] forKey:@"学期"];
    [dic setObject:@"ceyanResult" forKey:@"ACTION"];
    
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"GetCeyanInfo.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"学生成绩";
    [requestArray addObject:request];
    [request startAsynchronous];
    alertTip1 = [[OLGhostAlertView alloc] initWithTitle:@"正在获取成绩数据" message:nil timeout:0 dismissible:NO];
    [alertTip1 showInView:self.page3];
    
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    NSData *datas = [request responseData];
    if([request.username isEqualToString:@"学生考勤"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"适用模板"];
        if([status isEqualToString:@"考勤"])
        {
            [self initKaoQinView:dict];
        }
    }
    else if([request.username isEqualToString:@"学生成绩"])
    {
        if(alertTip1)
            [alertTip1 removeFromSuperview];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        
        if(dict!=nil)
        {
            [self initChengJiView:dict];
        }
    }
    else
    {
        UIImage *newHead=[[UIImage alloc]initWithData:datas];
        if(newHead!=nil)
        {
            NSString *path=request.username;
            [datas writeToFile:path atomically:YES];
            newHead=[newHead scaleToSize1:CGSizeMake(160, 160)];
            CGRect newSize=CGRectMake(0, 0,160,160);
            newHead=[newHead cutFromImage:newSize];
            headImage.image=newHead;
            
        }
    }
}
-(void)initChengJiView:(NSDictionary *)dict
{
    UIColor *underBodyBg=[[UIColor alloc] initWithRed:208/255.0 green:230/255.0 blue:217/255.0 alpha:1];
    UIColor *BodyBg=[[UIColor alloc] initWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];
    float viewWidth=self.view.frame.size.width;
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(15, 10, viewWidth-30, 80)];
    title.backgroundColor=[UIColor clearColor];
    title.textAlignment=NSTextAlignmentLeft;
    title.font=[UIFont systemFontOfSize:16];
    title.textColor=BodyBg;
    title.text=[NSString stringWithFormat:@"%@的课堂测验成绩",[dict objectForKey:@"学生姓名"]];
    [title sizeToFit];
    
    [self.page3 addSubview:title];
    
    UILabel *subTitle=[[UILabel alloc] initWithFrame:CGRectMake(15, 30, viewWidth-30, 20)];
    subTitle.numberOfLines=2;
    subTitle.backgroundColor=[UIColor clearColor];
    subTitle.textAlignment=NSTextAlignmentLeft;
    subTitle.font=[UIFont systemFontOfSize:12];
    NSString *kechengName=@"";
    if([dict objectForKey:@"课程名称"]!=nil)
        kechengName=[dict objectForKey:@"课程名称"];
    subTitle.text=[NSString stringWithFormat:@"(%@:%@)",[dict objectForKey:@"学期"],kechengName];
    [subTitle sizeToFit];
    [self.page3 addSubview:subTitle];
    
    NSMutableArray *chengjiArray=[dict objectForKey:@"测验结果"];
    if(chengjiArray==nil)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有成绩数据"];
        [tipView showInView:self.page3];
    }
    
    int initTop=60;
    int cellHeight=35;
    int lineHeight=20;
    
    UIScrollView* scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, initTop, self.page3.frame.size.width , self.page3.frame.size.height-initTop-80)];
    if([UIScreen mainScreen].bounds.size.height<500)
        scrollerView.frame=CGRectMake(0, initTop, self.page3.frame.size.width , self.page3.frame.size.height-initTop-80);
    scrollerView.scrollEnabled = YES;
    [self.page3 addSubview:scrollerView];
    
    for(int i=0;i<chengjiArray.count;i++)
    {
        NSDictionary *item=[chengjiArray objectAtIndex:i];
        NSString *className=[item objectForKey:@"上课日期"];
        NSString *jieci=[item objectForKey:@"节次"];
        NSNumber *score=[item objectForKey:@"分数"];
        UILabel *head=[[UILabel alloc] initWithFrame:CGRectMake(15, cellHeight*i, 70, 50)];
        head.backgroundColor=[UIColor clearColor];
        head.text=[NSString stringWithFormat:@"%@\n%@节",[className substringFromIndex:5],jieci];
        head.font=[UIFont systemFontOfSize:12];
        head.numberOfLines=2;
        [head sizeToFit];
        UILabel *underbody=[[UILabel alloc] initWithFrame:CGRectMake(60, cellHeight*i, viewWidth-110, lineHeight)];
        underbody.layer.cornerRadius = 5;
        underbody.backgroundColor=underBodyBg;
        UILabel *body=[[UILabel alloc] initWithFrame:CGRectMake(60, cellHeight*i, (viewWidth-110)*(score.floatValue/100), lineHeight)];
        body.layer.cornerRadius = 5;
        UIColor *color=BodyBg;
        if(score.floatValue<60)
            color=[UIColor redColor];
        body.backgroundColor=color;
        UILabel *scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth-40, cellHeight*i, 30, lineHeight)];
        scoreLabel.backgroundColor=[UIColor clearColor];
        scoreLabel.textColor=[UIColor orangeColor];
        scoreLabel.font=[UIFont systemFontOfSize:12];
        scoreLabel.text=[NSString stringWithFormat:@"%d",score.intValue];
        [scrollerView addSubview:head];
        [scrollerView addSubview:underbody];
        [scrollerView addSubview:body];
        [scrollerView addSubview:scoreLabel];
    }
    scrollerView.contentSize = CGSizeMake(self.page3.frame.size.width, cellHeight*chengjiArray.count);
    UILabel *avg=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth/4, scrollerView.frame.size.height+initTop+10, 50, 50)];
    avg.backgroundColor=[UIColor clearColor];
    avg.font=[UIFont systemFontOfSize:18];
    avg.textAlignment=NSTextAlignmentCenter;
    NSString *avgChengji=[dict objectForKey:@"平均分"];
    if(avgChengji==nil)
        avgChengji=@"暂无";
    NSString *allChengji=[dict objectForKey:@"总分"];
    if(allChengji==nil)
        allChengji=@"暂无";
    avg.text=[NSString stringWithFormat:@"%@",avgChengji];
    avg.textColor=BodyBg;
    avg.layer.cornerRadius = 25;
    avg.layer.masksToBounds=YES;
    avg.backgroundColor=underBodyBg;
    UILabel *avgdetail=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth/4-10, scrollerView.frame.size.height+initTop+60, 70, 20)];
    avgdetail.backgroundColor=[UIColor clearColor];
    avgdetail.textAlignment=NSTextAlignmentCenter;
    avgdetail.textColor=BodyBg;
    avgdetail.font=[UIFont systemFontOfSize:12];
    avgdetail.text=@"平均分";
    [self.page3 addSubview:avg];
    [self.page3 addSubview:avgdetail];
    
    UILabel *total=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth*3/5, scrollerView.frame.size.height+initTop+10, 50, 50)];
    total.backgroundColor=[UIColor clearColor];
    total.font=[UIFont systemFontOfSize:18];
    total.textAlignment=NSTextAlignmentCenter;
    total.text=[NSString stringWithFormat:@"%@",allChengji];
    total.layer.cornerRadius = 25;
    total.layer.masksToBounds=YES;
    total.backgroundColor=underBodyBg;
    total.textColor=BodyBg;
    UILabel *totaldetail=[[UILabel alloc] initWithFrame:CGRectMake(viewWidth*3/5-10, scrollerView.frame.size.height+initTop+60, 70, 20)];
    totaldetail.backgroundColor=[UIColor clearColor];
    totaldetail.textAlignment=NSTextAlignmentCenter;
    totaldetail.textColor=BodyBg;
    totaldetail.font=[UIFont systemFontOfSize:12];
    totaldetail.text=@"总分数";
    [self.page3 addSubview:total];
    [self.page3 addSubview:totaldetail];
}
-(void)initKaoQinView:(NSDictionary *)dict
{
    NSString *studentName=[dict objectForKey:@"用户姓名"];
    NSString *chuqinRate=[dict objectForKey:@"出勤率"];
    NSString *shunxu=[dict objectForKey:@"顺序"];
    NSArray *kaoQinNames=[shunxu componentsSeparatedByString:@","];
    NSDictionary *chuQinDic=[dict objectForKey:@"考勤数值"];
    
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(15, 20, 300, 80)];
    title.backgroundColor=[UIColor clearColor];
    title.textAlignment=NSTextAlignmentLeft;
    title.font=[UIFont systemFontOfSize:18];
    title.text=[NSString stringWithFormat:@"%@的考勤(%@)",studentName,[userInfoDic objectForKey:@"当前学期"]];
    
    title.numberOfLines=2;
    [title sizeToFit];
    
    [self.page2 addSubview:title];
    int height = [self.view bounds].size.width/3*2.; // 220;
    int width = [self.view bounds].size.width; //320;
    PCPieChart *pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(([self.view bounds].size.width-width)/2,([self.view bounds].size.height-height)/2-30,width,height)];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:width/2];
    [pieChart setSameColorLabel:YES];
    
    [self.page2 addSubview:pieChart];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
    {
        pieChart.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30];
        pieChart.percentageFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:50];
    }
    NSMutableArray *components = [NSMutableArray array];
    for(int i=0;i<kaoQinNames.count;i++)
    {
        NSString *key=[kaoQinNames objectAtIndex:i];
        
        float val=[[[chuQinDic objectForKey:key] objectForKey:@"值"] floatValue];
        if(val==0) continue;
        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:key value:val];
        
        if (i==0)
        {
            [component setColour:PCColorGreen];
        }
        else if (i==1)
        {
            [component setColour:PCColorYellow];
        }
        else if (i==2)
        {
            [component setColour:PCColorBlue];
        }
        else if (i==3)
        {
            [component setColour:PCColorRed];
            
        }
        
        [components addObject:component];
    }
    [pieChart setComponents:components];
    
    UILabel *title1=[[UILabel alloc] initWithFrame:CGRectMake(20, pieChart.frame.origin.y+pieChart.frame.size.height, width-40, 50)];
    title1.backgroundColor=[UIColor clearColor];
    title1.textAlignment=NSTextAlignmentRight;
    title1.font=[UIFont systemFontOfSize:18];
    title1.text=[NSString stringWithFormat:@"该生出勤率:%@",chuqinRate];
    [self.page2 addSubview:title1];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([request.username isEqualToString:@"学生考勤"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSString *errorStr;
        if([error.localizedDescription isEqualToString:@"The request was cancelled"])
            errorStr=@"操作被取消";
        else if([error.localizedDescription isEqualToString:@"The request timed out"])
            errorStr=@"请求超时";
        else
            errorStr=[error localizedDescription];
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:errorStr];
        [tipView show];
    }
   
}
- (void)popLargePic
{
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = headImage.frame;
    imageView.backgroundColor=[UIColor blackColor];
    CGPoint point = CGPointMake(headImage.frame.origin.x+headImage.frame.size.width/2, headImage.frame.origin.y+headImage.frame.size.height/2);
    imageView.center = point;
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *oldImage=[UIImage imageWithContentsOfFile:headImageName];
    imageView.image = oldImage;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    [imageView addGestureRecognizer:gesture1];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    }];
}
- (void)handleGesture1:(UITapGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = CGPointMake(headImage.frame.origin.x+headImage.frame.size.width/2, headImage.frame.origin.y+headImage.frame.size.height/2);
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = point;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
- (void)ActionSheet:(id)sender {
    
    UIButton *btn=(UIButton *)sender;
    selTel=btn.titleLabel.text;
    if(selTel.length>0)
    {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"拨打电话",@"发送短信",nil];
	
	actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
	[actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    
}
#pragma  mark-- 实现UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            //拨打电话
            NSString *tel=[@"tel://" stringByAppendingString:selTel];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
            break;
        }
        case 1:
        {
            //发送短信
            NSString *tel=[@"sms://" stringByAppendingString:selTel];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
            break;
        }
        default:
            break;
    }
}

-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	CGPoint offset = aScrollView.contentOffset;
	self.pageControl.currentPage = offset.x / self.view.frame.size.width;
}

- (IBAction)pageChange:(id)sender {
    NSInteger whichPage = self.pageControl.currentPage;
    self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width * whichPage, 0.0f);

}
-(void)viewWillDisappear:(BOOL)animated
{
    self.scrollView.delegate=nil;
    [super viewWillDisappear:animated];
}


@end
