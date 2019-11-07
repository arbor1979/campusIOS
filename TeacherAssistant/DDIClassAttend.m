//
//  DDIClassAttend.m
//  老师助手
//
//  Created by yons on 13-11-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIClassAttend.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "GTMBase64.h"
#import "DDIStudentInfo.h"

@implementation DDIClassAttend
extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern int kUserType;

-(void) viewDidLoad
{

    [super viewDidLoad];
    
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAttend)];
    
    //本班学生数组
    NSDictionary *tmpDic=[userInfoDic objectForKey:self.banjiName];
    NSArray *tmpArray=nil;
    if ([tmpDic isKindOfClass:[NSArray class]]) {
        tmpArray=[[NSArray alloc] initWithArray:(NSArray *)tmpDic];
    }
    else
        tmpArray= [[NSArray alloc] initWithArray:tmpDic.allValues];
   
    //本节课学生考勤情况
    _scheduleArray=[[NSMutableArray alloc] initWithArray:[userInfoDic objectForKey:@"教师上课记录"]];
    _classInfoDic=[[NSMutableDictionary alloc] initWithDictionary:[_scheduleArray objectAtIndex:self.classIndex.intValue]];
    
    if([[_classInfoDic objectForKey:@"缺勤情况登记JSON"] isKindOfClass:[NSArray class]])
        _stuKaoQinArray=[[NSMutableArray alloc] initWithArray:[_classInfoDic objectForKey:@"缺勤情况登记JSON"]];
    else
        _stuKaoQinArray=[[NSMutableArray alloc] init];
    
    //考勤名称
    NSString *kaoqinStr=[userInfoDic objectForKey:@"考勤名称"];
    
    _kaoqinNameArray=[[NSMutableArray alloc] initWithArray:[kaoqinStr componentsSeparatedByString:@","]];
    [_kaoqinNameArray removeObject:@"出勤"];
    
    fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    _savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/students/"];
    BOOL fileExists = [fileManager fileExistsAtPath:_savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:_savePath withIntermediateDirectories:NO attributes:nil error:nil];
    
    _studentArray=[[NSMutableArray alloc] init];
    _headImageDic=[[NSMutableDictionary alloc] init];
    _requestArray=[[NSMutableArray alloc]init];
    _studentArray=[NSMutableArray arrayWithArray:tmpArray];
    /*
    for(int i=0;i<[tmpArray count];i++)
    {
        NSMutableDictionary *student=[[NSMutableDictionary alloc] initWithDictionary:[tmpArray objectAtIndex:i]];
        
     
        NSString *pinYinResult=[NSString string];
        for(int j=0;j<studentName.length;j++){
            NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([studentName characterAtIndex:j])]uppercaseString];
            
            pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        [student setObject:pinYinResult forKey:@"拼音"];
     
        [student setObject:[[NSNumber alloc] initWithInt:1] forKey:@"考勤"];
        [student setObject:@"出勤" forKey:@"考勤名"];
        [_studentArray addObject:student];
        
        for(int j=0;j<_stuKaoQinArray.count;j++)
        {
            NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:j];
            NSString *keyName=[kaoqinItem objectForKey:@"学号"];
            NSString *xuehao=[student objectForKey:@"学号"];
            if([keyName isEqualToString:xuehao])
            {
                NSString *kaoqinName=[kaoqinItem objectForKey:@"考勤类型"];
                NSUInteger index=[_kaoqinNameArray indexOfObject:kaoqinName];
                if(index==NSNotFound)
                    index=0;
                else
                    index=index+1;
                
                NSMutableDictionary *itemDic=[NSMutableDictionary dictionary];
                [itemDic setObject:[kaoqinItem objectForKey:@"节次"] forKey:@"节次"];
                [itemDic setObject:kaoqinName forKey:@"考勤名"];
                [itemDic setObject:[[NSNumber alloc] initWithInt:(int)index] forKey:@"考勤"];
                [student setObject:itemDic forKey:@"考勤"];
                break;
            }
        }
    
        NSString *firstLetter=[pinYinResult substringToIndex:1];
        NSMutableArray *groupArray=[_studentDic objectForKey:firstLetter];
        if(groupArray==nil)
            groupArray=[[NSMutableArray alloc] init];
        [groupArray addObject:student];
        [_studentDic setObject:groupArray forKey:firstLetter];
     
    }*/
    if(_studentArray.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本班没有学生"];
        [tipView show];
        return;
    }
    
    
    UIImage *chuqinSel=[UIImage imageNamed:@"class_call_attend_sel"];
    UIImage *chuqinNor=[UIImage imageNamed:@"class_call_attend_nor"];
    UIImage *lateSel=[UIImage imageNamed:@"class_call_late_sel"];
    UIImage *lateNor=[UIImage imageNamed:@"class_call_late_nor"];
    UIImage *leaveSel=[UIImage imageNamed:@"class_call_leave_sel"];
    UIImage *leaveNor=[UIImage imageNamed:@"class_call_leave_nor"];
    UIImage *absenceSel=[UIImage imageNamed:@"class_call_absence_sel"];
    UIImage *absenceNor=[UIImage imageNamed:@"class_call_absence_nor"];
    UIImage *zaotuiSel=[UIImage imageNamed:@"class_call_zaotui_sel"];
    UIImage *zaotuiNor=[UIImage imageNamed:@"class_call_zaotui_nor"];
    UIImage *gongjiaSel=[UIImage imageNamed:@"class_call_gongjia_sel"];
    UIImage *gongjiaNor=[UIImage imageNamed:@"class_call_gongjia_nor"];
    UIImage *bingjiaSel=[UIImage imageNamed:@"class_call_bingjia_sel"];
    UIImage *bingjiaNor=[UIImage imageNamed:@"class_call_bingjia_nor"];
    UIImage *shuijiaoSel=[UIImage imageNamed:@"class_call_shuijiao_sel"];
    UIImage *shuijiaoNor=[UIImage imageNamed:@"class_call_shuijiao_nor"];
    UIImage *wanshoujiSel=[UIImage imageNamed:@"class_call_shouji_sel"];
    UIImage *wanshoujiNor=[UIImage imageNamed:@"class_call_shouji_nor"];
    UIImage *xiaofuSel=[UIImage imageNamed:@"class_call_xiaofu_sel"];
    UIImage *xiaofuNor=[UIImage imageNamed:@"class_call_xiaofu_nor"];
    UIImage *chatSel=[UIImage imageNamed:@"class_call_chat_sel"];
    UIImage *chatNor=[UIImage imageNamed:@"class_call_chat_nor"];
    UIImage *eatSel=[UIImage imageNamed:@"class_call_eat_sel"];
    UIImage *eatNor=[UIImage imageNamed:@"class_call_eat_nor"];
    UIImage *readSel=[UIImage imageNamed:@"class_call_read_sel"];
    UIImage *readNor=[UIImage imageNamed:@"class_call_read_nor"];
    
    _imageSel=[[NSMutableArray alloc] init];
    _imageDes=[[NSMutableArray alloc] init];
    
    for(int i=0;i<_kaoqinNameArray.count;i++)
    {
        if(i>9) break;
        NSString *kaoqinname=[_kaoqinNameArray objectAtIndex:i];
        if([kaoqinname isEqualToString:@"出勤"])
        {
            [_imageSel addObject:chuqinSel];
            [_imageDes addObject:chuqinNor];
        }
        else if([kaoqinname isEqualToString:@"迟到"])
        {
            [_imageSel addObject:lateSel];
            [_imageDes addObject:lateNor];
        }
        else if([kaoqinname isEqualToString:@"请假"] || [kaoqinname isEqualToString:@"事假"])
        {
            [_imageSel addObject:leaveSel];
            [_imageDes addObject:leaveNor];
        }
        else if([kaoqinname isEqualToString:@"缺课"])
        {
            [_imageSel addObject:absenceSel];
            [_imageDes addObject:absenceNor];
        }
        else if([kaoqinname isEqualToString:@"早退"])
        {
            [_imageSel addObject:zaotuiSel];
            [_imageDes addObject:zaotuiNor];
        }
        else if([kaoqinname isEqualToString:@"公假"])
        {
            [_imageSel addObject:gongjiaSel];
            [_imageDes addObject:gongjiaNor];
        }
        else if([kaoqinname isEqualToString:@"病假"])
        {
            [_imageSel addObject:bingjiaSel];
            [_imageDes addObject:bingjiaNor];
        }
        else if([kaoqinname isEqualToString:@"睡觉"])
        {
            [_imageSel addObject:shuijiaoSel];
            [_imageDes addObject:shuijiaoNor];
        }
        else if([kaoqinname isEqualToString:@"玩手机"])
        {
            [_imageSel addObject:wanshoujiSel];
            [_imageDes addObject:wanshoujiNor];
        }
        else if([kaoqinname isEqualToString:@"无着校服"])
        {
            [_imageSel addObject:xiaofuSel];
            [_imageDes addObject:xiaofuNor];
        }
        else if([kaoqinname isEqualToString:@"聊天"])
        {
            [_imageSel addObject:chatSel];
            [_imageDes addObject:chatNor];
        }
        else if([kaoqinname isEqualToString:@"吃东西"])
        {
            [_imageSel addObject:eatSel];
            [_imageDes addObject:eatNor];
        }
        else if([kaoqinname isEqualToString:@"看课外书"])
        {
            [_imageSel addObject:readSel];
            [_imageDes addObject:readNor];
        }
        else
        {
            [_imageSel addObject:eatSel];
            [_imageDes addObject:eatNor];
        }
    }
    
    _imageMan=[UIImage imageNamed:@"man"];
    _imageWoman=[UIImage imageNamed:@"woman"];
    
    NSString *jiecistr=[_classInfoDic objectForKey:@"节次"];
    NSArray *jieciArray=[jiecistr componentsSeparatedByString:@"-"];
    if (curJieci==nil) {
        curJieci=[jieciArray objectAtIndex:0];
    }
    if(jieciArray.count>1)
    {
        UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 36)];
        //[headView setBackgroundColor:[UIColor whiteColor]];
        int width=(int)jieciArray.count*60;
        UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width-width)/2, 5, width, 26) ];
        for(int i=0;i<jieciArray.count;i++)
        {
            NSString *item=[jieciArray objectAtIndex:i];
            item=[NSString stringWithFormat:@"第%@节",item];
            [segmentedControl insertSegmentWithTitle:item atIndex:i animated:NO];
        }
        
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        segmentedControl.selectedSegmentIndex=0;
        segmentedControl.tintColor = [UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];
        [headView addSubview:segmentedControl];
        self.tableView.tableHeaderView=headView;
    }
   
    [self reloadStudentKaoQin];
    
}
-(void)reloadStudentKaoQin
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"InterfaceStudent/XUESHENG-KAOQIN-Teacher.php?action=classkaoqin"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.banjiName forKey:@"classname"];
    [dic setObject:[_classInfoDic objectForKey:@"编号"] forKey:@"subjectid"];
    
    request.username=@"获取学生考勤";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [_requestArray addObject:request];
}
- (void)dealloc
{
    
    for(ASIHTTPRequest *req in _requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *datas = [request responseData];
    if([request.username isEqualToString:@"获取学生考勤"])
    {
        NSString *dataStr = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        datas = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *tmpDic= [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        if(tmpDic!=nil)
        {
            
            NSArray *tmparray=[tmpDic objectForKey:@"结果"];
            if(tmparray!=nil && tmparray.count>0)
            {
                _stuKaoQinArray=[NSMutableArray arrayWithArray:tmparray];
                [self.tableView reloadData];
            }
        }
    }
    else if([request.username isEqualToString:@"保存学生考勤"])
    {
        NSString* dataStr = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        datas = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString *result=[dict objectForKey:@"结果"];
        NSRange range=[result rangeOfString:@"成功"];
        NSLog(@"%@",result);
        if(result!=nil && range.location!= NSNotFound)
        {
            result=@"已保存";
            [rightBtn setTitle:@"保存"];
        }
        else
        {
            
            NSLog(@"失败，原因：%@",dict);
        }
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
        [tipView show];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(kUserType==1)
        {
            NSArray *scheduleArray=[userInfoDic objectForKey:@"教师上课记录"];
            for(NSDictionary *item in scheduleArray)
            {
                if([[item objectForKey:@"编号"] isEqualToString:[_classInfoDic objectForKey:@"编号"]])
                {
                    NSString *neirong=[item objectForKey:@"授课内容"];
                    if(neirong==nil || neirong.length==0)
                    {
                        self.tabBarController.selectedIndex=3;
                    }
                }
            }
        }
    }
    else
    {
        UIImage *img=[[UIImage alloc]initWithData:datas];
        if(img!=nil)
        {
            NSString *path=[NSString stringWithFormat:@"%@%@.jpg",_savePath,request.username];
            [datas writeToFile:path atomically:YES];
            img=[img scaleToSize1:CGSizeMake(80, 80)];
            CGRect newSize=CGRectMake(0, 0,80,80);
            img=[img cutFromImage:newSize];
            [_headImageDic setObject:img forKey:request.username];
            NSIndexPath *index=[request.userInfo objectForKey:@"indexPath"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self.tableView reloadData];
            
        }
    }
    if([_requestArray containsObject:request])
        [_requestArray removeObject:request];
    request=nil;
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([_requestArray containsObject:request])
        [_requestArray removeObject:request];
    request=nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.banjiName;
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma tableview datasoucre
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
 
	return _studentArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"attendCell" forIndexPath:indexPath];
    //0=出勤 1=迟到 2=请假 事假 3=缺课 4=早退 5=公假 6=病假 7=睡觉 8=玩手机 9＝无着校服
    for(int i=0;i<_kaoqinNameArray.count;i++)
    {
        if(i>=_imageDes.count) break;
        UIButton *btn1=(UIButton *)[cell viewWithTag:1001+i];
        NSString *kaoqinname=[_kaoqinNameArray objectAtIndex:i];
        btn1.hidden=NO;
        [btn1 setImage:[_imageDes objectAtIndex:i]  forState:UIControlStateNormal];
        //if(i>3) break;
        UILabel *lable=(UILabel *)[cell viewWithTag:2001+i];
        [lable setText:kaoqinname];
        lable.hidden=NO;
    }
    

	NSUInteger row = [indexPath row];

    NSDictionary *student = [_studentArray objectAtIndex:row];

    NSString *stuName=[student objectForKey:@"姓名"];
    NSString *xuehao=[student objectForKey:@"学号"];
    NSString *weiyima=[student objectForKey:@"用户唯一码"];
    if(weiyima==nil || weiyima.length==0)
        weiyima=xuehao;
    NSString *xingbie=[student objectForKey:@"性别"];
    //NSNumber *kaoqin=[student objectForKey:@"考勤"];
    NSString *kaoqinName=@"出勤";
    NSString *reason=@"";
    NSString *seatNo=[student objectForKey:@"座号"];
    NSMutableArray *tagArray=[NSMutableArray array];
    for(int j=0;j<_stuKaoQinArray.count;j++)
    {
        NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:j];
        NSString *keyName=[kaoqinItem objectForKey:@"学号"];
        NSString *jieci=[kaoqinItem objectForKey:@"节次"];
        
        if([keyName isEqualToString:xuehao] && [jieci isEqualToString:curJieci])
        {
            kaoqinName=[kaoqinItem objectForKey:@"考勤类型"];
            NSUInteger index=[_kaoqinNameArray indexOfObject:kaoqinName];
            if(index==NSNotFound)
            {
                [tagArray addObject:[NSNumber numberWithInt:-1]];
                reason=[kaoqinItem objectForKey:@"原因"];
            }
            else
                [tagArray addObject:[NSNumber numberWithInt:(int)index+1]];
           
        }
    }

    UIScrollView *scroll=(UIScrollView *)[cell viewWithTag:13];
    CGSize size=scroll.frame.size;
    if(tagArray.count>0)
    {
        NSNumber *num=[tagArray objectAtIndex:0];
        int tag=num.intValue;
        if(tag==-1)
        {
            size.width=40;
            UIButton *btnSel=(UIButton *)[cell viewWithTag:1001];
            UIImage *img=nil;
            if([kaoqinName isEqualToString:@"请假"] || [kaoqinName isEqualToString:@"事假"])
                img=[UIImage imageNamed:@"class_call_leave_sel"];
            else if([kaoqinName isEqualToString:@"公假"])
                img=[UIImage imageNamed:@"class_call_gongjia_sel"];
            else if([kaoqinName isEqualToString:@"病假"])
                img=[UIImage imageNamed:@"class_call_bingjia_sel"];
            [btnSel setImage:img forState:UIControlStateNormal];
            UILabel *lable=(UILabel *)[cell viewWithTag:2001];
            [lable setText:kaoqinName];
            for(int i=1;i<10;i++)
            {
                UIButton *btnSel=(UIButton *)[cell viewWithTag:1001+i];
                UILabel *lable=(UILabel *)[cell viewWithTag:2001+i];
                btnSel.hidden=YES;
                lable.hidden=YES;
            }
            
        }
        else
        {
            size.width=40*_imageSel.count;
            for(int i=0;i<tagArray.count;i++)
            {
                NSNumber *num=[tagArray objectAtIndex:i];
                int tag=num.intValue;
                UIButton *btnSel=(UIButton *)[cell viewWithTag:1000+tag];
                if(tag>0)
                    [btnSel setImage:[_imageSel objectAtIndex:tag-1]  forState:UIControlStateNormal];
            }
            
        }
    }
    else
        size.width=40*_imageSel.count;
    [scroll setContentSize:size];
    [scroll setContentOffset:CGPointMake(0, 0)];
    
    
    UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
    headBtn.imageView.layer.cornerRadius = headBtn.frame.size.width / 2;
    headBtn.imageView.layer.masksToBounds = YES;
    
    UILabel *lblname=(UILabel *)[cell viewWithTag:12];
    lblname.text=stuName;
    UILabel *lbldetail=(UILabel *)[cell viewWithTag:14];
    if(seatNo!=nil && seatNo.length>0)
    {
        lbldetail.text=[NSString stringWithFormat:@"座号:%@",seatNo];
    }
    else
    {
        lbldetail.text=@"";
    }
    if([xingbie isEqualToString:@"女"])
        [headBtn setImage:_imageWoman forState:UIControlStateNormal];
    else
        [headBtn setImage:_imageMan forState:UIControlStateNormal];
    UIImage *headImage=[_headImageDic objectForKey:xuehao];
    if(headImage!=Nil)
    {
        
        [headBtn setImage:headImage forState:UIControlStateNormal];
        //NSLog(@"%f,%f",headImage.size.width,headImage.size.height);
        
    }
    else
    {
        //判断是否存在学生头像，如果没有则下载
        NSString *fileName=[NSString stringWithFormat:@"%@%@.jpg",_savePath,weiyima];
        if([fileManager fileExistsAtPath:fileName])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:fileName];
            img=[img scaleToSize1:CGSizeMake(80, 80)];
            CGRect newSize=CGRectMake(0, 0,80,80);
            img=[img cutFromImage:newSize];
            [_headImageDic setObject:img forKey:xuehao];
            [headBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSString *urlStr=[student objectForKey:@"头像"];
            NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
            BOOL flag=false;
            for(ASIHTTPRequest *item in _requestArray)
            {
                if([item.url isEqual:url])
                {
                    flag=true;
                    break;
                }
            }
            if(!flag)
            {
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [_requestArray addObject:request];
                request.username=weiyima;
                request.userInfo=[NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
                [request setDelegate:self];
                [request startAsynchronous];
            }
            
        }

    }
    UILabel *lb_reason=[cell viewWithTag:2100];
    if([reason isKindOfClass:[NSString class]] && reason.length>0)
    {
        if(lb_reason==nil)
        {
            lb_reason=[[UILabel alloc]initWithFrame:CGRectMake(scroll.frame.origin.x+size.width+5, scroll.frame.origin.y, self.tableView.bounds.size.width-scroll.frame.origin.x-size.width-15, size.height)];
            lb_reason.textColor=lbldetail.textColor;
            lb_reason.font=lbldetail.font;
            lb_reason.numberOfLines=2;
            lb_reason.lineBreakMode=NSLineBreakByTruncatingTail;
            lb_reason.tag=2100;
            [cell addSubview:lb_reason];
        }
        lb_reason.text=reason;
    }
    else
    {
        if(lb_reason)
           [lb_reason removeFromSuperview];
    }
    cell.tag=[xuehao intValue];
    return cell;
}

-(void)segmentAction:(UISegmentedControl *)Seg
{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSString *jiecistr=[_classInfoDic objectForKey:@"节次"];
    NSArray *jieciArray=[jiecistr componentsSeparatedByString:@"-"];
    curJieci=[jieciArray objectAtIndex:Index];
    [self.tableView reloadData];
}
- (IBAction)dingMingClick:(id)sender {
    
    UIView *parent=[(UIButton *)sender superview];
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    
	NSUInteger row = [indexPath row];
    
    NSMutableDictionary *student = [_studentArray objectAtIndex:row];
    NSString *xuehao=[student objectForKey:@"学号"];
    NSMutableArray *kaoqinNameArray=[NSMutableArray array];
    NSMutableArray *oldArray=[NSMutableArray array]; //当前学生原有的考勤记录
    for(int j=0;j<_stuKaoQinArray.count;j++)
    {
        NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:j];
        NSString *keyName=[kaoqinItem objectForKey:@"学号"];
        NSString *jieci=[kaoqinItem objectForKey:@"节次"];
        
        if([keyName isEqualToString:xuehao] && [jieci isEqualToString:curJieci])
        {
            [kaoqinNameArray addObject:[kaoqinItem objectForKey:@"考勤类型"]];
            [oldArray addObject:kaoqinItem];
        }
    }
    if(![kaoqinNameArray containsObject:@"请假"] && ![kaoqinNameArray containsObject:@"事假"] && ![kaoqinNameArray containsObject:@"公假"] && ![kaoqinNameArray containsObject:@"病假"])
    {
        UIButton *btn=sender;
        UITextView *txt=[parent viewWithTag:btn.tag+1000];
        NSString *btnText=txt.text;
        bool ifsel;
        //设置按钮选中状态
        if([btn.imageView.image isEqual:[_imageSel objectAtIndex:btn.tag-1001]])
        {
            [btn setImage:[_imageDes objectAtIndex:btn.tag-1001]  forState:UIControlStateNormal];
            [kaoqinNameArray removeObject:btnText];
            ifsel=false;
        }
        else
        {
            [btn setImage:[_imageSel objectAtIndex:btn.tag-1001]  forState:UIControlStateNormal];
            [kaoqinNameArray addObject:btnText];
            ifsel=true;
        }
        //设置其他按钮状态
        if(ifsel)
        {
            for(int i=1001;i<1001+_imageDes.count;i++)
            {
                UIButton *otherbtn=(UIButton *)[parent viewWithTag:i];
                UITextView *othertxt=[parent viewWithTag:i+1000];
                if(btn!=otherbtn)
                {
                    //如果是缺课则清除其他选择
                    if([btnText isEqualToString:@"缺勤"] || [btnText isEqualToString:@"缺课"] || [btnText isEqualToString:@"旷课"])
                    {
                        [otherbtn setImage:[_imageDes objectAtIndex:otherbtn.tag-1001]  forState:UIControlStateNormal];
                        [kaoqinNameArray removeObject:othertxt.text];
                    }
                    else
                    {
                        //否则只清除缺课的选择
                        if([othertxt.text isEqualToString:@"缺勤"] || [othertxt.text isEqualToString:@"缺课"] || [othertxt.text isEqualToString:@"旷课"])
                        {
                            [otherbtn setImage:[_imageDes objectAtIndex:otherbtn.tag-1001]  forState:UIControlStateNormal];
                            [kaoqinNameArray removeObject:othertxt.text];
                        }
                    }
                        
                }
            }
        }
        //移除原有的考勤记录
        for(int j=0;j<oldArray.count;j++)
        {
            [_stuKaoQinArray removeObject:[oldArray objectAtIndex:j]];
        }
        //重新增加考勤记录
        for(int i=0;i<kaoqinNameArray.count;i++)
        {
            NSMutableDictionary *item=[NSMutableDictionary dictionary];
            [item setObject:xuehao forKey:@"学号"];
            [item setObject:curJieci forKey:@"节次"];
            NSString *newkaoqinName=[kaoqinNameArray objectAtIndex:i];
            [item setObject:newkaoqinName forKey:@"考勤类型"];
            [_stuKaoQinArray addObject:item];
            
        }
        
    }
    
}

-(void) saveAttend
{
    if(_studentArray.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"本班没有学生"];
        [tipView show];
        return;
    }
    if(![rightBtn.title isEqualToString:@"保存"])
        return;
    
    int iWeiChuqin=0;
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"appserver.php?action=changekaoqininfo&APP=IOS"] URLEncodedString]];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"编号"];
    [dic setObject:[[NSNumber alloc] initWithInt:(int)_studentArray.count] forKey:@"班级人数"];
    
    
    for(int i=0;i<_stuKaoQinArray.count;i++)
    {
        NSDictionary *kaoqinItem=[_stuKaoQinArray objectAtIndex:i];
        NSString *chuqin=[kaoqinItem objectForKey:@"考勤类型"];
        NSString *jieci=[kaoqinItem objectForKey:@"节次"];
        NSString *jiecistr=[_classInfoDic objectForKey:@"节次"];
        NSArray *jieciArray=[jiecistr componentsSeparatedByString:@"-"];
        NSString *firstjieci=[jieciArray objectAtIndex:0];
        if([jieci isEqualToString:firstjieci])
        {
        if([chuqin isEqualToString:@"请假"] || [chuqin isEqualToString:@"事假"] || [chuqin isEqualToString:@"公假"] || [chuqin isEqualToString:@"病假"] || [chuqin isEqualToString:@"缺课"] || [chuqin isEqualToString:@"缺勤"] || [chuqin isEqualToString:@"旷课"])
                iWeiChuqin++;
        }
        
    }
    [dic setObject:[[NSNumber alloc] initWithInt:(int)_studentArray.count-iWeiChuqin] forKey:@"实到人数"];
    [_classInfoDic setObject:_stuKaoQinArray forKey:@"缺勤情况登记JSON"];
    [_scheduleArray setObject:_classInfoDic atIndexedSubscript:self.classIndex.intValue];
    [userInfoDic setObject:_scheduleArray forKey:@"教师上课记录"];
    
    //NSError *error;
    [dic setObject:_stuKaoQinArray forKey:@"缺勤情况登记JSONArray"];
    NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
    [dicArray addObject:dic];
    
    /*
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    
 
    //NSString *postStr = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\",\"编号\":\"%@\",\"班级人数\":\"%d\",\"实到人数\":\"%d\"}",kUserIndentify,self.classNo,kaoQinArray.count,iChuqin];
    
    postStr=[GTMBase64 base64StringBystring:postStr];
    postStr=[NSString stringWithFormat:@"DATA=%@",postStr];
    postData = [postStr dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    */
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.username=@"保存学生考勤";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [_requestArray addObject:request];
    [rightBtn setTitle:@"保存中"];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"studentInfo"])
    {
        UIView *parent=[(UIButton *)sender superview];
        while(![parent isKindOfClass:[UITableViewCell class]])
            parent=[parent superview];
        UITableViewCell *cell=(UITableViewCell *)parent;
       
        NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
        NSUInteger row = [indexPath row];
        NSDictionary *student = [_studentArray objectAtIndex:row];
        DDIStudentInfo *destController=segue.destinationViewController;
        destController.student=student;
        
    }
    
}

@end
