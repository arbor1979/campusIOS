//
//  DDIKeTangExam.m
//  老师助手
//
//  Created by yons on 13-12-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIKeTangExam.h"
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;
extern int kUserType;
@interface DDIKeTangExam ()

@end

@implementation DDIKeTangExam



- (void)viewDidLoad
{
    [super viewDidLoad];
    examArray=[[NSMutableArray alloc]init];
    requestArray=[[NSMutableArray alloc]init];
    
    
    ceYanShouJuan=[userInfoDic objectForKey:@"课堂测验_收卷2"];
    
    abcArray=[[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",nil];
    clGray=[UIColor colorWithRed:163/255.0f green:171/255.0f blue:174/255.0f alpha:1.0f];
    clLightGray=[UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
    clGreen=[UIColor colorWithRed:16/255.0f green:112/255.0f blue:16/255.0f alpha:1.0f];
    timeTip=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    timeTip.backgroundColor=clLightGray;
    timeTip.font=[UIFont systemFontOfSize:14];
    timeTip.textColor=[UIColor orangeColor];
    timeTip.textAlignment=NSTextAlignmentCenter;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timerGetStatus:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if(kUserType==1)
        rightBtn=[[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStyleDone target:self action:@selector(startClick:)];
    else
        rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(submitAnswer)];
    
    [self timerGetStatus:nil];

}
-(void)loadExamList
{
    
    [examArray removeAllObjects];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    [dic setObject:self.banjiName forKey:@"班级"];
    [dic setObject:@"GetInfo" forKey:@"ACTION"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetCeyanInfo.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"测验列表";
    [requestArray addObject:request];
    [request startAsynchronous];
 
}
//保存答题结果
-(void)submitAnswer
{
    if([rightBtn.title isEqualToString:@"刷新"])
    {
        [self timerGetStatus:nil];
        return;
    }
    
    NSMutableArray *result=[NSMutableArray new];
    for(int i=0;i<examArray.count;i++)
    {
        
        NSDictionary *item=[examArray objectAtIndex:i];
        NSString *answer=[item objectForKey:@"学生答题结果"];
        if(answer==nil) answer=@"";
        [result addObject:answer];
    }
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    [dic setObject:result forKey:@"选项记录集"];
    [dic setObject:@"UploadAnswer" forKey:@"ACTION"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetCeyanInfo.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"提交结果";
    [requestArray addObject:request];
    [request startAsynchronous];
    rightBtn.enabled=false;
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在保存答题结果" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.parentViewController.view];
    
}
- (void)dealloc
{
    if(aTimer)
    {
        [aTimer invalidate];
        aTimer=nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}


- (void)timerFireMethod:(NSTimer*)theTimer
{
    _leftSec=_leftSec-1;
    if(_leftSec<=0)
    {
       [aTimer invalidate];
        aTimer=nil;
        //提示时间已到

        _examStatus=@"已结束";
        
        if(kUserType==2)
        {
            [self submitAnswer];
        }
        [self updateExamStatue];
        //5秒后刷新测验结果
        aTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(loadExamList) userInfo:nil repeats:NO];
        
        return;
    }
    
    int hours=(int)_leftSec/3600;
    int minutes=(int)(_leftSec-hours*3600)/60;
    int secends=(int)_leftSec-hours*3600-minutes*60;
    NSString *leftTime=[NSString stringWithFormat:@"再有%d时%d分%d秒结束",hours,minutes,secends];
    timeTip.text=leftTime;
    
}
- (void)timerGetStatus:(NSTimer*)theTimer
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    [dic setObject:@"GetInfo" forKey:@"ACTION"];
    [dic setObject:self.banjiName forKey:@"班级"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetCeyanStatus.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"测验状态";
    [requestArray addObject:request];
    [request startAsynchronous];
    rightBtn.enabled=false;
    if(aTimer)
    {
        [aTimer invalidate];
        aTimer=nil;
    }
    timeTip.text=@"正在获取测验状态...";
}

-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.className;
   
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.parentViewController.navigationItem.titleView=nil;
    [super viewWillDisappear:animated];
}

-(void)startClick:(UIBarButtonItem *)sender
{
    if([sender.title isEqualToString:@"开始"])
    {
        
        if(examArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本节课没有测验"];
            [tipView showInView:self.parentViewController.view];
            return;
        }
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
        for(int i=0;i<ceYanShouJuan.count;i++)
        {
            NSDictionary *item=[ceYanShouJuan objectAtIndex:i];
            
            [actionSheet addButtonWithTitle:[item objectForKey:@"名称"]];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else if([sender.title isEqualToString:@"手动结束"])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示" message:@"测验结束时间未到，是否手动结束？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {

        NSString *ceYanState=[NSString stringWithFormat:@"结束答题:%d",timeLim.intValue];
        [self postData:ceYanState];
    }
}
#pragma  mark-- 实现UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(![rightBtn.title isEqualToString:@"开始"] || buttonIndex==ceYanShouJuan.count)
        return;
    NSDictionary *item=[ceYanShouJuan objectAtIndex:buttonIndex];
    timeLim=[item objectForKey:@"值"];
    NSString *ceYanState=[NSString stringWithFormat:@"开始答题:%d",timeLim.intValue];
    [self postData:ceYanState];
    
}
-(void)postData:(NSString *)ceYanState
{
    NSString *urlStr= [kServiceURL stringByAppendingString:@"appserver.php?action=changeceyanzhuangtai"];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *ceYanSubmitDic=[[NSMutableDictionary alloc]init];
    request.username=@"开始答题";
    [ceYanSubmitDic setValue:self.classNo forKey:@"教师上课记录编号"];
    [ceYanSubmitDic setValue:ceYanState forKey:@"课堂测验状态"];
    [ceYanSubmitDic setValue:kUserIndentify forKey:@"用户较验码"];
    request.userInfo=ceYanSubmitDic;
    
    NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
    [dicArray addObject:ceYanSubmitDic];
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    [rightBtn setTitle:@"执行中"];
    rightBtn.enabled=false;

}
-(void)updateExamStatue
{
    if(aTimer)
    {
        [aTimer invalidate];
        aTimer=nil;
    }
    if([_examStatus isEqualToString:@"执行中"])
    {
        if(kUserType==1)
            [rightBtn setTitle:@"手动结束"];
        else if(kUserType==2)
            [rightBtn setTitle:@"保存"];
        
        aTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:aTimer forMode:NSRunLoopCommonModes];
        [self loadExamList];
    }
    else if([_examStatus isEqualToString:@"已结束"])
    {
        if(kUserType==1)
            [rightBtn setTitle:@"开始"];
        else if(kUserType==2)
            [rightBtn setTitle:@"刷新"];
        if(_endTime)
        {
            NSString *endtime=[CommonFunc stringFromDate:_endTime];
            endtime=[NSString stringWithFormat:@"上次测验结束时间 %@",endtime];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:nil message:endtime timeout:3 dismissible:YES];
            [tipView showInView:self.parentViewController.view];
        }
        [self loadExamList];
    }
    else if ([_examStatus isEqualToString:@"未开始"])
    {
        if(kUserType==1)
            [rightBtn setTitle:@"开始"];
        else if(kUserType==2)
            [rightBtn setTitle:@"刷新"];
        if(kUserType==1)
            [self loadExamList];
    }
    timeTip.text=[NSString stringWithFormat:@"测验状态:%@",_examStatus];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"开始答题"])
    {
        rightBtn.enabled=true;
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSNumber *suc=[dict objectForKey:@"成功"];
        if(suc.intValue==1)
        {
            NSDictionary *item=[dict objectForKey:@"189结果"];
            _examStatus=[item objectForKey:@"答题状态"];
            NSNumber *sec=[item objectForKey:@"剩余时间"];
            _leftSec=sec.intValue;
            sec=[dict objectForKey:@"时间戳"];
            if(sec)
                _endTime=[NSDate dateWithTimeIntervalSince1970:sec.intValue];
            else
                _endTime=nil;
            if([_examStatus isEqualToString:@"已结束"])
            {
                [self loadExamList];
            }
            else
                [self updateExamStatue];
        }
        else
        {
            NSLog(@"失败，原因：%@",dict);
        }
    }
    else if([request.username isEqualToString:@"测验列表"])
    {
        
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        examArray=[[NSMutableArray alloc]initWithArray:[resultArray objectForKey:@"测验数据"]];
        if(examArray==nil || examArray.count==0)
        {
            timeTip.text=@"本节课没有测验";
        }
        else
        {
            
            NSDictionary *item=[examArray objectAtIndex:0];
            examName=[item objectForKey:@"测验名称"];
            if(examName.length<=12)
                self.parentViewController.navigationItem.title=examName;
            else
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
                [label setNumberOfLines:2];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont boldSystemFontOfSize:14.0];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = examName;
                self.parentViewController.navigationItem.titleView=label;
            }
            [self.tableView reloadData];
            if([_examStatus isEqualToString:@"已结束"])
            {
                if(kUserType==1)
                {
                    int avgScore=0;
                    for(int i=0;i<examArray.count;i++)
                    {
                        NSDictionary *item=[examArray objectAtIndex:i];
                        NSNumber *fen=[item objectForKey:@"正确率"];
                        if([fen isEqual:[NSNull null]]) fen=0;
                        avgScore=avgScore+fen.intValue;
                    }
                    avgScore=avgScore/examArray.count;
                    timeTip.text=[NSString stringWithFormat:@"测验状态:%@ 平均分:%d",_examStatus,avgScore];
                }
                else
                {
                    int avgScore=0;
                    for(int i=0;i<examArray.count;i++)
                    {
                        NSDictionary *item=[examArray objectAtIndex:i];
                        if ([[item objectForKey:@"学生答题状态"] isEqualToString:@"正确"])
                            avgScore=avgScore+1;
                    }
                    avgScore=avgScore*100/examArray.count;
                    timeTip.text=[NSString stringWithFormat:@"测验状态:%@ 得分:%d",_examStatus,avgScore];
                }
            }
        }
        
    }
    else if([request.username isEqualToString:@"提交结果"])
    {
        [alertTip removeFromSuperview];
        rightBtn.enabled=true;
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *suc=[resultArray objectForKey:@"结果"];
        OLGhostAlertView *tipView;
        if([suc isEqualToString:@"保存成功"])
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"测验已保存"];
        else
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"提交测验结果失败"];
        [tipView show];

        
    }
    else if([request.username isEqualToString:@"测验状态"])
    {
        rightBtn.enabled=true;
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(!resultArray)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取答题状态失败"];
            [tipView show];
            return;
        }
        _examStatus=[resultArray objectForKey:@"答题状态"];
        NSNumber *sec=[resultArray objectForKey:@"剩余时间"];
        if(sec)
            _leftSec=sec.intValue;
        else
            _leftSec=0;
        
        if(_leftSec<=0)
            _examStatus=@"已结束";
        
        [self updateExamStatue];
        
        
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    rightBtn.enabled=true;
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
    [self updateExamStatue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return examArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellExam";
    UILabel *titleLabel = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    float viewWidth=self.view.frame.size.width;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, viewWidth-40, 20)];
        [titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [titleLabel setNumberOfLines:0];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [titleLabel setTag:11];
        titleLabel.textColor=clGreen;
        titleLabel.backgroundColor=[UIColor clearColor];
        [[cell contentView] addSubview:titleLabel];
        for(int i=0;i<6;i++)
        {
            UIButton *bodybtn = [[UIButton alloc] initWithFrame:CGRectZero];
            
            //bodyLabel.titleLabel.font=[UIFont systemFontOfSize:14];
            [bodybtn setTag:12+i];
            bodybtn.layer.cornerRadius=5;
            [bodybtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            bodybtn.backgroundColor=clLightGray;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            titleLabel.backgroundColor=[UIColor clearColor];
            [titleLabel setFont:[UIFont systemFontOfSize:15]];
            [titleLabel setNumberOfLines:0];
            titleLabel.tag=100;
            [bodybtn addSubview:titleLabel];
            [bodybtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:bodybtn];
        }
        UILabel *lblResult=[[UILabel alloc]initWithFrame:CGRectZero];
        lblResult.tag=20;
        [lblResult setNumberOfLines:2];
        [lblResult setFont:[UIFont systemFontOfSize:15]];
        lblResult.backgroundColor=[UIColor clearColor];
        [[cell contentView] addSubview:lblResult];
    }
    else
    {
        titleLabel=(UILabel *)[cell viewWithTag:11];
    }
    [titleLabel setFrame:CGRectMake(10, 10, viewWidth-20, cell.frame.size.height-10)];
    NSDictionary *item=[examArray objectAtIndex:indexPath.row];
    titleLabel.text=[item objectForKey:@"题目名称"];
    [titleLabel sizeToFit];
    
    float curY=titleLabel.frame.size.height+10;

    for(int i=0;i<abcArray.count;i++)
    {
        
        NSString *tigan=[abcArray objectAtIndex:i];
        NSString *neirong=[item objectForKey:tigan];
        if(neirong==nil || neirong.length==0)
            continue;
        NSString *rightAnswer=[item objectForKey:@"正确答案"];
        UIButton *selectionBtn=(UIButton *)[cell viewWithTag:12+i];
        [selectionBtn setFrame:CGRectMake(20, curY, viewWidth-40, 20)];
//        [selectionBtn setTitle:[NSString stringWithFormat:@"%@.%@",tigan,neirong] forState:UIControlStateNormal];
        UILabel *titleLabel=(UILabel *)[selectionBtn viewWithTag:100];
        [titleLabel setFrame:CGRectMake(5, 5, selectionBtn.frame.size.width-5, selectionBtn.frame.size.height)];
        titleLabel.text=[NSString stringWithFormat:@"%@.%@",tigan,neirong];
        [titleLabel sizeToFit];
        [selectionBtn setFrame:CGRectMake(20, curY, titleLabel.frame.size.width+10, titleLabel.frame.size.height+10)];
        curY=curY+selectionBtn.frame.size.height+5;
        if(kUserType==1)
        {
            if([rightAnswer.uppercaseString isEqualToString:tigan.uppercaseString])
                selectionBtn.backgroundColor=clGray;
            else
                selectionBtn.backgroundColor=clLightGray;
        }
        else
        {
            NSString *myAnswer=[item objectForKey:@"学生答题结果"];
            
            if([myAnswer.uppercaseString isEqualToString:tigan.uppercaseString])
                selectionBtn.backgroundColor=clGreen;
            else
                selectionBtn.backgroundColor=clLightGray;
        }
        
    }
    if([_examStatus isEqualToString:@"已结束"])
    {
        
        UILabel *lblResult=(UILabel *)[cell viewWithTag:20];
        [lblResult setFrame:CGRectMake(20, curY, viewWidth-40, 20)];
        
        if(kUserType==1)
        {
            lblResult.text=[item objectForKey:@"题目分类统计"];
            
        }
        else
        {
            NSString *right=[item objectForKey:@"正确答案"];
            NSString *myAnswer=[item objectForKey:@"学生答题结果"];
            
            if([myAnswer isEqualToString:right])
            {
                lblResult.textColor=clGreen;
                lblResult.text=@"正确";
            }
            else
            {
                lblResult.textColor=[UIColor redColor];
                lblResult.text=[@"错误 正确答案:" stringByAppendingString:right];
            }
        }
        [lblResult sizeToFit];
        curY=curY+lblResult.frame.size.height+5;
    }
    [cell setFrame:CGRectMake(0, 0, viewWidth, curY)];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return timeTip;
}

-(void) answerClick:(id)sender
{
    if(![_examStatus isEqualToString:@"执行中"] || kUserType!=2)
        return;
    UIView *parent=[(UIButton *)sender superview];
    NSArray *controls=[parent subviews];
    
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
	NSUInteger row = [indexPath row];
    NSMutableDictionary *examItem = [[NSMutableDictionary alloc] initWithDictionary:[examArray objectAtIndex:row]];
    
    for(int i=0;i<controls.count;i++)
    {
        UIControl *ctl=[controls objectAtIndex:i];
        UIButton *btn=nil;
        if([ctl isKindOfClass:[UIButton class]])
            btn=(UIButton *)ctl;
        else
            continue;
        if(btn==sender)
        {
            btn.backgroundColor=clGreen;
            NSNumber *tag=[[NSNumber alloc] initWithInt:(int)btn.tag-12];
            [examItem setObject:[abcArray objectAtIndex:tag.intValue] forKey:@"学生答题结果"];
            [examArray setObject:examItem atIndexedSubscript:row];
        }
        else
        {
            
            btn.backgroundColor=clLightGray;
        }
    }
}

@end
