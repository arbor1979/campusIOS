//
//  DDIMyInforView.m
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMyInforView.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;
extern NSMutableDictionary *tempLinkMandic;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern int kUserType;
extern NSString *kInitURL;
@interface DDIMyInforView ()

@end

@implementation DDIMyInforView

- (void)viewDidLoad
{
    [super viewDidLoad];
    savepath=[CommonFunc createPath:@"/utils/"];
    if(kIOS7)
    {
        //self.automaticallyAdjustsScrollViewInsets=NO;
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    requestArray=[[NSMutableArray alloc] init];
    _disableChangeArray=[[NSMutableArray alloc] init];
   
    
    if(_userWeiYi==nil || [_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
    {
        _userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
        theTeacherDic=teacherInfoDic;
    }
    else
    {
        /*
        NSDictionary *duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
        NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
        NSNumber *key=[duizhaoDic objectForKey:_userWeiYi];
        if(key)
            theTeacherDic=[allLinkManArray objectAtIndex:key.intValue];
         */
    }
    if(theTeacherDic==nil)
    {
        NSDictionary *dic=[tempLinkMandic objectForKey:_userWeiYi];
        if(dic)
            theTeacherDic=dic;
    }
    NSArray *tmpArray=[_userWeiYi componentsSeparatedByString:@"_"];
    if([[tmpArray objectAtIndex:1] isEqualToString:@"老师"])
    {

        [_disableChangeArray addObject:@"性别"];
        [_disableChangeArray addObject:@"单位名称"];
        if(kUserType==1)
            [_disableChangeArray addObject:@"手机"];
        [_disableChangeArray addObject:@"电邮"];
        [_disableChangeArray addObject:@"部门"];
        [_disableChangeArray addObject:@"所带班级"];
        [_disableChangeArray addObject:@"所带课程"];
        [_disableChangeArray addObject:@"登录时间"];
    }
    else if([[tmpArray objectAtIndex:1] isEqualToString:@"魔灯"])
    {
        [_disableChangeArray addObject:@"城市"];
        [_disableChangeArray addObject:@"单位名称"];
        [_disableChangeArray addObject:@"班级名称"];
        [_disableChangeArray addObject:@"电子邮件"];
        [_disableChangeArray addObject:@"域名"];
        [_disableChangeArray addObject:@"登录时间"];
    }
    else
    {
        [_disableChangeArray addObject:@"性别"];
        [_disableChangeArray addObject:@"单位名称"];
        if([_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
        {
            if(kUserType==2)
            {
                [_disableChangeArray addObject:@"学生电话"];
            }
            else
                [_disableChangeArray addObject:@"家长电话"];
        }
        
        
        [_disableChangeArray addObject:@"学号"];
        [_disableChangeArray addObject:@"班级"];
        [_disableChangeArray addObject:@"登录时间"];
    }
    if(_headImage==nil)
        _headImage=[UIImage imageNamed:@"unknowMan"];
  

    [self getPersonalInfo];
    if(theTeacherDic==nil)
    {
        tipView = [[OLGhostAlertView alloc] initWithTitle:@"正在刷新个人数据" message:nil timeout:0 dismissible:NO];
        [tipView showInView:self.view];
    }
    
}
-(void)dealClickURL:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSLog(@"text = %@",label.text);
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt:%@",label.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)getPersonalInfo
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:_userWeiYi forKey:@"hostId"];
    [dic setObject:@"个人相册简介" forKey:@"action"];
    
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"个人相册简介";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"个人相册简介"])
    {
        if(tipView)
            [tipView removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            if([[res objectForKey:@"结果"] isEqualToString:@"成功"])
            {
                if(theTeacherDic==nil)
                {
                    if(tempLinkMandic==nil)
                        tempLinkMandic=[NSMutableDictionary dictionary];
                    theTeacherDic=[res objectForKey:@"个人资料"];
                    [tempLinkMandic setObject:theTeacherDic forKey:_userWeiYi];
                }
                else
                    theTeacherDic=[res objectForKey:@"个人资料"];
                
                albumArray=[res objectForKey:@"最近"];
                NSNumber *allnum=[res objectForKey:@"总数"];
                albumCount=allnum.intValue;
                [self.tableView reloadData];
                [self reloadHeadImage];
            }
        }
    }
    if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        NSDictionary *indexDic=request.userInfo;
        NSString *filename=[indexDic objectForKey:@"filename"];
        [datas writeToFile:filename atomically:YES];
        
        UIButton *btn=[indexDic objectForKey:@"btn"];
        [btn setImage:headImage forState:UIControlStateNormal];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if([request.username isEqualToString:@"上传图片"])
    {
        if(tipView) [tipView removeFromSuperview];
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            NSString *path=[CommonFunc getImageSavePath:_userWeiYi ifexist:NO];
            NSDictionary *dic=request.userInfo;
            NSData *data=[dic objectForKey:@"data"];
            [data writeToFile:path atomically:YES];
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:nil userInfo:nil];
        }
    }
    else if([request.username isEqualToString:@"更新联系方式"])
    {
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
        NSString * status=[dict objectForKey:@"结果"];
        if([status isEqualToString:@"成功"])
        {
            NSString *newNumber=[dict objectForKey:@"新号码"];
            NSMutableDictionary *newdic=[NSMutableDictionary dictionaryWithDictionary:theTeacherDic];
            if(kUserType==1)
            {
                [newdic setObject:newNumber forKey:@"手机"];
            }
            else if(kUserType==2)
                [newdic setObject:newNumber forKey:@"学生电话"];
            else if(kUserType==3)
                [newdic setObject:newNumber forKey:@"家长电话"];
            theTeacherDic=newdic;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            tipView = [[OLGhostAlertView alloc] initWithTitle:@"修改成功"];
            [tipView showInView:self.view];
            
        }
        else
        {
            tipView = [[OLGhostAlertView alloc] initWithTitle:[@"失败:" stringByAppendingString:status]];
            [tipView showInView:self.view];
        }
            
    }
    else
    {
        NSData *datas = [request responseData];
        _headImage=[[UIImage alloc]initWithData:datas];
        if(_headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
          
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:nil userInfo:nil];

        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(tipView)
        [tipView removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    NSArray *tmpArray=[request.username componentsSeparatedByString:@"_"];
    if(tmpArray.count<4)
    {
        OLGhostAlertView *tipV = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
        [tipV showInView:self.view];
    }
    else
    {
        _headImage=[UIImage imageNamed:@"unknowMan"];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section==0)
        return 1;
    else if(section==1)
        return _disableChangeArray.count;
    else if(section==2)
        return 1;
    else
        return 0;
    
        
}
-(void)reloadHeadImage
{
    NSString *urlStr=[theTeacherDic objectForKey:@"用户头像"];
    if(urlStr && ![urlStr isEqual:[NSNull null]])
    {
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=_userWeiYi;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if(indexPath.section==0)
    {
        static NSString *CellIdentifier1 = @"Cell1";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        UIButton *headBtn=(UIButton *)[cell viewWithTag:11];
        [headBtn.layer setMasksToBounds:YES];
        [headBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        [headBtn setImage:_headImage forState:UIControlStateNormal];
        if(theTeacherDic)
        {
            
            NSString *path=[CommonFunc getImageSavePath:_userWeiYi ifexist:YES];
            if(path)
            {
                _headImage=[UIImage imageWithContentsOfFile:path];
                
            }
            else
            {
                if([[theTeacherDic objectForKey:@"性别"] isEqualToString:@"女"])
                    _headImage=[UIImage imageNamed:@"woman"];
                else
                    _headImage=[UIImage imageNamed:@"man"];
            }
            [headBtn setImage:_headImage forState:UIControlStateNormal];
            
        }

        
        UILabel *realName=(UILabel *)[cell viewWithTag:12];
        realName.text=[theTeacherDic objectForKey:@"姓名"];
        UILabel *usertype=(UILabel *)[cell viewWithTag:13];
        if([theTeacherDic objectForKey:@"用户类型"])
            usertype.text=[NSString stringWithFormat:@"(%@)",[theTeacherDic objectForKey:@"用户类型"]];
        else
            usertype.text=@"";
        
        UIButton *changeBtn=(UIButton *)[cell viewWithTag:14];
        if([_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
            changeBtn.hidden=NO;
        else
            changeBtn.hidden=YES;
    }
    else if(indexPath.section==1)
    {
        static NSString *CellIdentifier2 = @"Cell2";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        UILabel *title=nil;
        UILabel *detail=nil;
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier2] ;
            [cell.detailTextLabel setNumberOfLines:0];
            cell.detailTextLabel.font=[UIFont systemFontOfSize:15];
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:@"修改" forState:UIControlStateNormal];
            btn.titleLabel.font=[UIFont boldSystemFontOfSize:14];
            [btn addTarget:self action:@selector(changeInfo) forControlEvents:UIControlEventTouchUpInside];
            btn.tag=101;
            [cell addSubview:btn];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            //btn.backgroundColor=[UIColor redColor];
        }
        title=cell.textLabel;
        detail=cell.detailTextLabel;
        title.text=[_disableChangeArray objectAtIndex:indexPath.row];
        if([[theTeacherDic objectForKey:title.text] isEqual:[NSNull null]])
            detail.text=@"";
        else
        {
            NSString *value=[theTeacherDic objectForKey:title.text];
            detail.text=value;
            if([CommonFunc isValidateMobile:value] || [CommonFunc isValidateTel:value])
            {
                detail.textColor=detail.tintColor;
                detail.userInteractionEnabled = YES;
                if(detail.gestureRecognizers==nil || detail.gestureRecognizers.count==0)
                {
                    UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealClickURL:)];
                    [detail addGestureRecognizer:labelTap];
                }
            }
            else
            {
                detail.textColor=[UIColor blackColor];
                detail.userInteractionEnabled = NO;
                
            }
        }
        
        CGSize size = [detail.text sizeWithFont:detail.font constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        
        [detail setFrame:CGRectMake(detail.frame.origin.x, detail.frame.origin.y, size.width, size.height)];
        [detail sizeToFit];
        NSString *fieldName=[_disableChangeArray objectAtIndex:indexPath.row];
        UIButton *btn=(UIButton *)[cell viewWithTag:101];
        if([_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]] && ([fieldName isEqualToString:@"手机"] || [fieldName isEqualToString:@"学生电话"] || [fieldName isEqualToString:@"家长电话"]))
        {
            btn.frame=CGRectMake(self.view.frame.size.width-120, 10, 50, 25);
            [btn setTitle:@"修改" forState:UIControlStateNormal];
            [btn setHidden:NO];
        }
        else
        {
            [btn setHidden:YES];
        }
        //detail.text=btn.titleLabel.text;
    }
    else if (indexPath.section==2)
    {
        static NSString *CellIdentifier3 = @"Cell3";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if(cell==nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier3] ;
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(112, 10, 200, 15)];
            label.font=[UIFont systemFontOfSize:15];
            label.backgroundColor=[UIColor clearColor];
            label.tag=101;
            [cell addSubview:label];
            if(kIOS7)
            {
                UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, 91, 15)];
                title.textAlignment=NSTextAlignmentRight;
                title.font=cell.textLabel.font;
                title.textColor=cell.textLabel.textColor;
                title.tag=102;
                title.backgroundColor=[UIColor clearColor];
                [cell addSubview:title];
            }
        }
        //cell.textLabel.text=@"个人相册";
        UILabel *title=(UILabel *)[cell viewWithTag:102];
        if(title)
            title.text=@"个人相册";
        else
            cell.textLabel.text=@"个人相册";
        UILabel *label=(UILabel *)[cell viewWithTag:101];
        if(albumCount==0)
            label.text=@"还未上传照片";
        else
        {
            label.text=[NSString stringWithFormat:@"已上传了%ld张照片",(long)albumCount];
            int top=10+20;
            int left=114;
            int width=40;
            int height=40;
            for(int i=0;i<albumArray.count;i++)
            {
                UIButton *iv=[[UIButton alloc]initWithFrame:CGRectMake(left+48*i, top, width, height)];
                [cell addSubview:iv];
                [iv addTarget:self action:@selector(gotoAlbumPersonal) forControlEvents:UIControlEventTouchUpInside];
                NSDictionary *item=[albumArray objectAtIndex:i];
                NSString *imageName=[item objectForKey:@"文件名"];
                NSString *picUrl=[item objectForKey:@"文件地址"];
                [self getImageByNameToButton:imageName picUrl:picUrl imageview:iv];
            }
        }
        
    }
    return cell;
}
-(void)changeInfo
{
    UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"请输入新的号码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
    [customAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [customAlertView textFieldAtIndex:0].keyboardType=UIKeyboardTypeNumberPad;
    customAlertView.tag=1;
    [customAlertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag==1)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            UITextField *nameField = [alertView textFieldAtIndex:0];
            NSString *newNumber=nameField.text;
            
            if([newNumber trimWhitespace].length!=11)
            {
                tipView = [[OLGhostAlertView alloc] initWithTitle:@"请输入11位手机号"];
                [tipView showInView:self.view];
            }
            else
            {
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
                [dic setObject:kUserIndentify forKey:@"用户较验码"];
                NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                [dic setObject:timeStamp forKey:@"DATETIME"];
                [dic setObject:@"更新联系方式"  forKey:@"action"];
                [dic setObject:newNumber forKey:@"新号码"];
                
                NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"AlbumPraise.php"] URLEncodedString]];
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                NSError *error;
                NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                postStr=[GTMBase64 base64StringBystring:postStr];
                [request setPostValue:postStr forKey:@"DATA"];
                [request setDelegate:self];
                request.userInfo=dic;
                request.username=@"更新联系方式";
                [requestArray addObject:request];
                [request startAsynchronous];
            }
            
        }
    }
    
    
}
-(void)gotoAlbumPersonal
{
    DDIAlbumPersonal *control=[[self storyboard] instantiateViewControllerWithIdentifier:@"albumPersonal"];
    control.userid=_userWeiYi;
    control.username=[theTeacherDic objectForKey:@"姓名"];
    [self.navigationController pushViewController:control animated:YES];
}
-(void)getImageByNameToButton:(NSString *)imageName picUrl:(NSString *)picUrl imageview:(UIButton *)headBtn
{
    UIImage *image;
    NSString *filename=[savepath stringByAppendingString:imageName];
    if([CommonFunc fileIfExist:filename])
    {
        image=[UIImage imageWithContentsOfFile:filename];
        [headBtn setImage:image forState:UIControlStateNormal];
    }
    else
    {
        image=[UIImage imageNamed:@"empty_photo"];
        [headBtn setImage:image forState:UIControlStateNormal];
        if(picUrl && picUrl.length>0)
        {
            NSURL *url = [NSURL URLWithString:picUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:headBtn forKey:@"btn"];
            [indexDic setObject:filename forKey:@"filename"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if([_userWeiYi isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
            return 118;
        else
            return 100;
    }
    else if(indexPath.section==1)
    {
        /*
        UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
        UILabel *detail=cell.detailTextLabel;
        
        if(detail.frame.size.height>24)
            return detail.frame.size.height+20;
        else
            return 44;
         */
        NSString *titletext=[_disableChangeArray objectAtIndex:indexPath.row];
        NSString *detailtext=@"";
        if([[theTeacherDic objectForKey:titletext] isEqual:[NSNull null]])
            detailtext=@"";
        else
            detailtext=[theTeacherDic objectForKey:titletext];
        
        CGSize size = [detailtext sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(220, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        if(size.height>24)
            return size.height+20;
        else
            return 44;
    
    }
    else if(indexPath.section==2)
    {
        if(albumArray.count>0)
            return 80;
        else
            return 44;
    }
    else
        return 0;
}

- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 80);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = _headImage;
    imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (IBAction)changeHeadImage:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    actionSheet.tag=-1;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = CGPointMake(60, 80);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag==-1)
    {
        
        switch (buttonIndex) {
            case 0://照相机
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            case 1://本地相簿
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
                
            default:
                break;
        }
        
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  *img;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(800, 800);
        img=[img scaleToSize:newsize];
        //NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        
        
        
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
    if(img)
    {
        MLImageCrop *imageCrop = [[MLImageCrop alloc]init];
        imageCrop.delegate = self;
        imageCrop.ratioOfWidthAndHeight = 600.0f/600.0f;
        imageCrop.image = img;
        [imageCrop showWithAnimation:YES];
    }
    else
    {
        tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取图片失败"];
        [tipView showInView:self.view];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    [self uploadNewHeadImage:cropImage];
    
    
}
-(void)uploadNewHeadImage:(UIImage *)image
{
    
    NSData *fileData = UIImageJPEGRepresentation(image, 0.5);
    
    tipView=[[OLGhostAlertView alloc] initWithIndicator:@"正在上传..." timeout:0 dismissible:NO];
    [tipView showInView:self.view];
    
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:fileData withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:@"头像" forKey:@"TuPianLeiBie"];
    
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:fileData forKey:@"data"];
    request.username=@"上传图片";
    request.userInfo=dic;
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
}
@end
