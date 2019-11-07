//
//  DDICourseInfo.m
//  老师助手
//
//  Created by yons on 14-2-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDICourseInfo.h"
extern NSDictionary *LinkMandic;//联系人数据
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern Boolean kIOS7;
extern NSString *kUserIndentify;
extern int kUserType;
extern NSString *kInitURL;
@interface DDICourseInfo ()

@end

@implementation DDICourseInfo

- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[NSMutableArray array];
    grayStar=[UIImage imageNamed:@"star"];
    goldStar=[UIImage imageNamed:@"goldStar"];
    savePath=[CommonFunc createPath:@"/classNotes/"];
    [self.headBtn.imageView.layer setMasksToBounds:YES];
    [self.headBtn.imageView.layer setCornerRadius:5.0];
    NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
    for(int i=0;i<allLinkManArray.count;i++)
    {
        NSDictionary *item=[allLinkManArray objectAtIndex:i];
        NSString *userName=[item objectForKey:@"用户名"];
        if(userName && [userName isEqualToString:self.teacherUserName])
        {
            [self loadteacherInfo:item];
            break;
        }
    }
    [self getPingJiaData];
    /*
    NSNumber *grade=[item objectForKey:@"用户评级"];
    if(!grade) grade=[NSNumber numberWithInt:3];
    for(int j=0;j<grade.intValue;j++)
    {
        UIImageView *iv=[self.teacherGrade objectAtIndex:j];
        iv.image=goldStar;
    }
    NSMutableArray *scheduleArray=[[NSMutableArray alloc] initWithArray:[userInfoDic objectForKey:@"教师上课记录"]];
    NSMutableDictionary *classInfoDic=[[NSMutableDictionary alloc] initWithDictionary:[scheduleArray objectAtIndex:self.classIndex.intValue]];
    self.courseContent.text=[classInfoDic objectForKey:@"授课内容"];
    self.courseZuoYe.text=[classInfoDic objectForKey:@"作业布置"];
    NSNumber *grade1=[classInfoDic objectForKey:@"课程评级"];
    
    if(!grade1) grade1=[NSNumber numberWithInt:3];
    for(int j=0;j<grade1.intValue;j++)
    {
        UIImageView *iv=[self.courseGrade objectAtIndex:j];
        iv.image=goldStar;
    }
    NSString *chuqinrenName=[teacherInfoDic objectForKey:@"姓名"];
    NSArray *tmpArray=[chuqinrenName componentsSeparatedByString:@"["];
    self.chuqinren.text=[[tmpArray objectAtIndex:0] stringByAppendingString:@"的出勤"];
    NSArray *queqinArray=[classInfoDic objectForKey:@"缺勤情况登记JSON"];
    if(queqinArray && ![queqinArray isEqual:[NSNull null]])
    {
        for(int i=0;i<queqinArray.count;i++)
        {
            NSDictionary *item=[queqinArray objectAtIndex:i];
            NSString *xuehao=[item objectForKey:@"学号"];
            NSString *userid=[teacherInfoDic objectForKey:@"学号"];
            userid=[userid stringByReplacingOccurrencesOfString:@"jz" withString:@""];
            if([xuehao isEqualToString:userid])
            {
                self.chuqin.text=[item objectForKey:@"考勤类型"];
                break;
            }
        }
    }
    */
}
-(void) loadteacherInfo:(NSDictionary *)item
{
    self.teacherName.text=[item objectForKey:@"姓名"];
    NSString *weiyima=[item objectForKey:@"用户唯一码"];
    NSString *picUrl=[item objectForKey:@"用户头像"];
    self.chargeClass.text=[item objectForKey:@"所带班级"];
    self.chargeCourse.text=[item objectForKey:@"所带课程"];
    
    NSString *userPic=[CommonFunc getImageSavePath:weiyima ifexist:YES];
    UIImage *headImage;
    if(userPic)
    {
        headImage=[UIImage imageWithContentsOfFile:userPic];
        oldImage=headImage;
        CGSize newSize=CGSizeMake(80, 80);
        headImage=[headImage scaleToSize1:newSize];
        headImage=[headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
        
    }
    else
    {
        headImage=[UIImage imageNamed:@"unknowMan"];
        oldImage=headImage;
        headImage=[headImage scaleToSize1:CGSizeMake(80, 80)];
        if(picUrl && picUrl.length>0)
        {
            NSURL *url = [NSURL URLWithString:picUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=weiyima;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
        
    }
    [self.headBtn setImage:headImage forState:UIControlStateNormal];

}
-(void) getPingJiaData
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.teacherUserName forKey:@"老师用户名"];
    [dic setObject:self.className forKey:@"课程名称"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GetCourseAndTeacherInfo.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取数据";
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
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
    if([request.username isEqualToString:@"获取数据"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSNumber *grade=[dict objectForKey:@"老师评分"];
            if(!grade) grade=[NSNumber numberWithInt:3];
            for(int j=0;j<grade.intValue;j++)
            {
                UIImageView *iv=[self.teacherGrade objectAtIndex:j];
                iv.image=goldStar;
            }
            NSNumber *grade1=[dict objectForKey:@"课程评分"];
            if(!grade1) grade1=[NSNumber numberWithInt:3];
            for(int j=0;j<grade1.intValue;j++)
            {
                UIImageView *iv=[self.courseGrade objectAtIndex:j];
                iv.image=goldStar;
            }
            
            [self loadteacherInfo:[dict objectForKey:@"老师介绍"]];
            NSString *courseContent=[dict objectForKey:@"授课内容"];
            //CGSize constraint =CGSizeMake(self.view.frame.size.width-112-10, 1000.0f);
            //CGSize labelSize=[courseContent sizeWithFont:self.courseDate.font constrainedToSize:constraint  lineBreakMode:NSLineBreakByCharWrapping];
            CGSize labelSize=[CommonFunc getSizeByText:courseContent width:self.view.frame.size.width-self.courseDate.frame.origin.x-10 font:self.courseDate.font];
            CGRect rect=self.courseDate.frame;
            rect.origin.y=12;
            rect.size=labelSize;
            UILabel *lb_courseContent=[[UILabel alloc]initWithFrame:rect];
            lb_courseContent.text=courseContent;
            lb_courseContent.tag=99;
            lb_courseContent.font=[UIFont systemFontOfSize:14];
            lb_courseContent.numberOfLines=0;
            lb_courseContent.lineBreakMode=NSLineBreakByCharWrapping;
            [self.photosView addSubview:lb_courseContent];
            
            NSString *zuoyeContent=[dict objectForKey:@"课后作业"];
            //constraint =CGSizeMake(self.view.frame.size.width-112-10, 1000.0f);
            //CGSize labelSize1=[zuoyeContent sizeWithFont:self.courseDate.font constrainedToSize:constraint  lineBreakMode:NSLineBreakByCharWrapping];
            CGSize labelSize1=[CommonFunc getSizeByText:zuoyeContent width:self.view.frame.size.width-self.courseDate.frame.origin.x-10 font:self.courseDate.font];
            rect=self.courseDate.frame;
            rect.origin.y=12;
            rect.size=labelSize1;
            UILabel *lb_zuoyeContent=[[UILabel alloc]initWithFrame:rect];
            lb_zuoyeContent.text=zuoyeContent;
            lb_zuoyeContent.tag=99;
            lb_zuoyeContent.font=[UIFont systemFontOfSize:14];
            lb_zuoyeContent.numberOfLines=0;
            lb_zuoyeContent.lineBreakMode=NSLineBreakByCharWrapping;
            [self.photosView1 addSubview:lb_zuoyeContent];
            
            NSString *summaryContent=[dict objectForKey:@"课堂情况简要"];
            //constraint =CGSizeMake(self.view.frame.size.width-112-10, 1000.0f);
            //CGSize labelSize1=[zuoyeContent sizeWithFont:self.courseDate.font constrainedToSize:constraint  lineBreakMode:NSLineBreakByCharWrapping];
            CGSize labelSize2=[CommonFunc getSizeByText:summaryContent width:self.view.frame.size.width-self.courseDate.frame.origin.x-10 font:self.courseDate.font];
            rect=self.courseDate.frame;
            rect.origin.y=12;
            rect.size=labelSize2;
            UILabel *lb_summaryContent=[[UILabel alloc]initWithFrame:rect];
            lb_summaryContent.text=summaryContent;
            lb_summaryContent.tag=99;
            lb_summaryContent.font=[UIFont systemFontOfSize:14];
            lb_summaryContent.numberOfLines=0;
            lb_summaryContent.lineBreakMode=NSLineBreakByCharWrapping;
            [self.photosView2 addSubview:lb_summaryContent];
            
            //self.courseContent.text=[dict objectForKey:@"授课内容"];
            //self.courseZuoYe.text=[dict objectForKey:@"课后作业"];
            self.courseDate.text=[NSString stringWithFormat:@"%@ %@节",[dict objectForKey:@"上课日期"],[dict objectForKey:@"节次"]];
            self.classRoom.text=[dict objectForKey:@"教室"];
            self.courseJiLv.text=[dict objectForKey:@"课堂纪律"];
            self.courseWeiSheng.text=[dict objectForKey:@"教室卫生"];
            if(kUserType==1)
                self.chuqinren.text=@"学生出勤";
            else
            {
                NSString *chuqinrenName=[teacherInfoDic objectForKey:@"姓名"];
                NSArray *tmpArray=[chuqinrenName componentsSeparatedByString:@"["];
                self.chuqinren.text=[[tmpArray objectAtIndex:0] stringByAppendingString:@"的出勤"];
            }
            self.chuqin.text=[dict objectForKey:@"个人出勤"];
            [self.chuqin sizeToFit];
            self.teacherPingjiaNum.text=[NSString stringWithFormat:@"%@人评",[dict objectForKey:@"老师评分数"]];
            if(coursePingJiaNum==nil)
            {
                UIImageView *iv=[self.courseGrade objectAtIndex:4];
                CGRect frame=iv.frame;
                frame.origin.x=frame.origin.x+frame.size.width+6;
                frame.origin.y=frame.origin.y+10;
                frame.size.height=15;
                frame.size.width=frame.size.width*3;
                coursePingJiaNum=[[UILabel alloc] initWithFrame:frame];
                coursePingJiaNum.font=[UIFont systemFontOfSize:12];
                UIView *parentView=iv.superview;
                [parentView addSubview:coursePingJiaNum];
            }
            coursePingJiaNum.text=[NSString stringWithFormat:@"%@人评",[dict objectForKey:@"课程评分数"]];
            photosArray=[dict objectForKey:@"课堂笔记图片"];
            photosArray1=[dict objectForKey:@"课堂作业图片"];
            photosArray2=[dict objectForKey:@"课堂情况图片"];
            if (photosArray!=nil && photosArray.count>0)
            {
                [self drawImageFromArray:labelSize.height+lb_courseContent.frame.origin.y+5 array:photosArray parent:self.photosView];
                //self.courseContent.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"授课内容"]];
            }
            if(photosArray1!=nil && photosArray1.count>0)
            {
                [self drawImageFromArray:labelSize1.height+lb_zuoyeContent.frame.origin.y+5 array:photosArray1 parent:self.photosView1];
            }
            if(photosArray2!=nil && photosArray2.count>0)
            {
                [self drawImageFromArray:labelSize2.height+lb_summaryContent.frame.origin.y+5 array:photosArray2 parent:self.photosView2];
            }
            //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:1],[NSIndexPath indexPathForRow:4 inSection:1], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            //int top=[self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]]-40;
            [self.tableView reloadData];
            
            
        }
    }
    if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *img=[[UIImage alloc]initWithData:datas];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [datas writeToFile:filename atomically:YES];
        UIButton *btn=[item objectForKey:@"selBtn"];
        for(UIActivityIndicatorView *v in btn.subviews)
        {
            if([v isKindOfClass:[UIActivityIndicatorView class]])
            {
                [v stopAnimating];
                [v removeFromSuperview];
            }
        }
        [btn setImage:img forState:UIControlStateNormal];
    }
    else
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            oldImage=headImage;
            headImage=[headImage scaleToSize1:CGSizeMake(80, 80)];
            CGRect newSize=CGRectMake(0, 0,80,80);
            headImage=[headImage cutFromImage:newSize];
            [self.headBtn setImage:headImage forState:UIControlStateNormal];
        }
    }
}

-(void)drawImageFromArray:(int)top array:(NSArray *)photos parent:(UIView *)parentView
{
    
    int j=(int)photos.count;
    int cols=(self.view.frame.size.width-100)/41;
    int left=110;
    if(kIOS7)
        left=110;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn;
        if(i<cols)
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+i*41, top, 35, 35)];
        else
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+(i-cols)*41, top+41, 35, 35)];
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[photos objectAtIndex:i]];
        NSString *filename=[item objectForKey:@"文件名"];
        [item setObject:selBtn forKey:@"selBtn"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [selBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSString *urlStr=[item objectForKey:@"文件地址"];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            request.userInfo=item;
            request.tag=100+i;
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [selBtn addSubview:aiv];
            
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            [aiv startAnimating];
        }
        selBtn.tag=100+i;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(popPhotoView:) forControlEvents:UIControlEventTouchUpInside];
        [parentView addSubview:selBtn];
    }
    
    
}

-(void)popPhotoView:(UIButton *)sender
{
    NSArray *photos;
    if([sender.superview isEqual:self.photosView])
        photos=photosArray;
    else if([sender.superview isEqual:self.photosView1])
        photos=photosArray1;
    else
        photos=photosArray2;
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
    for(int i=0;i<photos.count;i++)
    {
        NSDictionary *item=[photos objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
    }
    if(picArray.count>0)
    {
        browserView.picArray=picArray;
        [browserView showFromIndex:(int)sender.tag-100];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.className;
    self.parentViewController.navigationItem.rightBarButtonItem =nil;
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    _headBtn=(UIButton *)sender;
    imageView.bounds = _headBtn.frame;
    imageView.backgroundColor=[UIColor blackColor];
    CGPoint point = CGPointMake(_headBtn.frame.origin.x+_headBtn.frame.size.width/2, _headBtn.frame.origin.y+_headBtn.frame.size.height/2);
    imageView.center = point;
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = oldImage;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,0+self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = CGPointMake(_headBtn.frame.origin.x+_headBtn.frame.size.width/2, _headBtn.frame.origin.y+_headBtn.frame.size.height/2);
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = point;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height=[super tableView:tableView heightForRowAtIndexPath:indexPath];
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    UILabel *realLabel=[cell viewWithTag:99];
    if(!realLabel)
        realLabel=cell.detailTextLabel;

    if([self.cellsChangeHeight containsObject:cell])
    {
        [realLabel sizeToFit];
        NSString *text=realLabel.text;
        //CGSize constraint =CGSizeMake(cell.frame.size.width-realLabel.frame.origin.x-20, 1000.0f);
        //CGSize labelSize=[text sizeWithFont:realLabel.font constrainedToSize:constraint  lineBreakMode:NSLineBreakByCharWrapping];
        UIFont *font=realLabel.font;
        if(!font)
            font=[UIFont systemFontOfSize:14];
        CGSize labelSize=[CommonFunc getSizeByText:text width:cell.frame.size.width-realLabel.frame.origin.x-10 font:font] ;
        
        CGRect rect=realLabel.frame;
        rect.size=labelSize;
        realLabel.frame=rect;
        if(labelSize.height+20>height)
            height=labelSize.height+20;
        if(indexPath.section==1 && indexPath.row==3 && photosArray.count>0)
        {
            int cols=(self.view.frame.size.width-110)/41;
            if(photosArray.count>cols)
                height=height+41*2;
            else
                height=height+41;
        }
        if(indexPath.section==1 && indexPath.row==4 && photosArray1.count>0)
        {
            int cols=(self.view.frame.size.width-110)/41;
            if(photosArray1.count>cols)
                height=height+41*2;
            else
                height=height+41;
        }
        if(indexPath.section==2 && indexPath.row==0 && photosArray2.count>0)
        {
            int cols=(self.view.frame.size.width-110)/41;
            if(photosArray2.count>cols)
                height=height+41*2;
            else
                height=height+41;
        }

    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section==1)
        return 10;
    else
        return 1;
}

@end
