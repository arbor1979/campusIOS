//
//  DDIViewController.m
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIVLoginMain.h"
#import "GTMBase64.h"
#import "LFCGzipUtillity.h"

@interface DDIVLoginMain ()

@end

extern NSString *kInitURL;
extern NSString *kServiceURL ;
extern NSString *kUserIndentify;
extern NSMutableDictionary *userInfoDic;
extern NSMutableDictionary *teacherInfoDic;
extern NSString *RecDevToken;
extern Boolean kIOS7;
extern int kUserType;
extern int kSchoolId;
extern DDIDataModel *datam;
@implementation DDIVLoginMain

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id appearance = [UITabBar appearance];
    UIImage *tabBarBackGroungImg =[UIImage imageNamed:@"navBottom"];
    [appearance setBackgroundImage:tabBarBackGroungImg];

    UIImage *navBarImage=[UIImage imageNamed:@"navbar"];
    if(!kIOS7)
        navBarImage=[navBarImage cutFromImage:CGRectMake(0,0,320, 44)];
    [[UINavigationBar appearance]setBackgroundImage:navBarImage forBarMetrics: UIBarMetricsDefault];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.showVersion.text=[NSString stringWithFormat:@"%@ v%@",@"CopyRight©单点科技",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];

    userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaultes stringForKey:@"用户名"];
    NSString *password = [userDefaultes stringForKey:@"密码"];
    userListArray=[NSMutableArray arrayWithArray:[userDefaultes arrayForKey:@"保存用户列表"]];
    if(userName!=nil && userName.length>0)
    {
        self.userName.text=userName;
        self.passWord.text=password;
        [self loginClick:nil];
    }

    UIButton *downArrow=[[UIButton alloc]initWithFrame:CGRectMake(0 , 0, 28, 28)];
    [downArrow setTitle:@"▼" forState:UIControlStateNormal];
    downArrow.titleLabel.font=[UIFont systemFontOfSize:12];
    [downArrow addTarget:self action:@selector(showDropList) forControlEvents:UIControlEventTouchUpInside];
    //[self.userName addSubview:downArrow];
    self.userName.rightView=downArrow;
    self.userName.rightViewMode=UITextFieldViewModeAlways;
    
    if(!userListArray)
        userListArray=[NSMutableArray array];
    else
    {
        while (userListArray.count>5)
            [userListArray removeLastObject];
    }
}
-(void)showDropList
{
    if(userListArray.count==0) return;
    
    CGRect frame=self.loginImage.frame;
    
    popView=[[UIPopoverListView alloc]initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+52, frame.size.width, 100)];
    popView.delegate=self;
    popView.datasource=self;
    popView.backgroundColor=[UIColor colorWithRed:179/255.0 green:238/255.0 blue:205/255.0 alpha:1.0];
    popView.listView.backgroundColor=[UIColor clearColor];
    
    [popView show:self.view];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
//文本框输入时VIEW上移，避免遮挡
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField

{
    
    NSTimeInterval animationDuration=0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,-150,width,height);
    
    self.view.frame=rect;
    
    [UIView commitAnimations];
    
    return YES;
    
}
//文本框输入完毕，点return键盘隐藏，VIEW下移恢复原状
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
    if(textField.tag==1)
    {
        [self.passWord becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self resumeView];
        [self loginClick:textField];
    }
    return YES;
}
//恢复VIEW的原状
-(void)resumeView
{
    
    NSTimeInterval animationDuration=0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,0.0f,width,height);
    
    self.view.frame=rect;
    
    [UIView commitAnimations];
    
}
//背景点击，隐藏键盘
- (IBAction)bgTouchDown:(id)sender {
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
    [self resumeView];
}
//登陆按钮
- (IBAction)loginClick:(id)sender {

    self.userName.text =[self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.passWord.text =[self.passWord.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(self.passWord.text==nil)
        self.passWord.text=@"";
    //断如果用户名没有输入则抖动提示
    if([self.userName.text length]==0)
    {
       
        [self inputFrameShake];
        return;
    }
    [self.indicator startAnimating];
    self.loginButton.enabled=NO;
    //self.demoBtn.enabled=NO;
    [self postLogin];
    
}

//登陆函数
-(void) postLogin
{
    kUserIndentify=nil;
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"GetUserPwdIsRight.php?action=logincheck"] URLEncodedString]];
	NSString *post = [NSString stringWithFormat:@"{\"用户名\":\"%@\",\"密码\":\"%@\"}", self.userName.text,self.passWord.text];
    post =[GTMBase64 base64StringBystring:post];
    post=[NSString stringWithFormat:@"DATA=%@",post];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    [request setTimeoutInterval:30];
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    
}

#pragma mark- NSURLConnection 回调方法
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_datas appendData:data];
}


-(void) connection:(NSURLConnection *)connection didFailWithError: (NSError *)error {
    
    NSLog(@"%@",[error localizedDescription]);
    //self.labelTip.text=[NSString stringWithFormat:@"%@:%@",@"登录失败",[error localizedDescription]];
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@:%@",@"登录失败",[error localizedDescription]] message:nil];
    [tipView show];
    [self.indicator stopAnimating];
    self.loginButton.enabled=YES;
    //self.demoBtn.enabled=YES;
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection {
    
    
    if(kUserIndentify==nil)
    {
        NSLog(@"登录完成...");
        NSString *dataStr=[[NSString alloc] initWithData:_datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        NSData *data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *loginState=[dict objectForKey:@"登录状态"];
        if(![loginState isEqualToString:@"登录成功"])
        {
            if(loginState==nil)
            {
                loginState=[dict objectForKey:@"STATUS"];
                if(loginState==nil)
                    loginState=@"登录失败，未知错误";
            }
            //self.labelTip.text=loginState;
            //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:loginState message:nil];
            [tipView show];
            
            [self.indicator stopAnimating];
            self.loginButton.enabled=YES;
            //self.demoBtn.enabled=YES;
            
        }
        else
        {
            kUserIndentify=[dict objectForKey:@"用户较验码"];
            NSString *weiyima=[dict objectForKey:@"用户唯一码"];
            NSArray *tmpArray=[weiyima componentsSeparatedByString:@"_"];
            if([[tmpArray objectAtIndex:1] isEqualToString:@"老师"])
                kUserType=1;
            else if([[tmpArray objectAtIndex:1] isEqualToString:@"学生"])
                kUserType=2;
            else if ([[tmpArray objectAtIndex:1] isEqualToString:@"家长"])
                kUserType=3;
            kSchoolId=[[tmpArray objectAtIndex:6] intValue];
            kServiceURL=[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"域名"]];
            teacherInfoDic=[dict mutableCopy];
            [teacherInfoDic setObject:[tmpArray objectAtIndex:1] forKey:@"用户类型"];
           
            [userDefaultes setObject:self.userName.text forKey:@"用户名"];
            [userDefaultes setObject:self.passWord.text forKey:@"密码"];
            BOOL flag=true;
            for(int i=0;i<userListArray.count;i++)
            {
                NSDictionary *item=[userListArray objectAtIndex:i];
                if([[item objectForKey:@"用户名"] isEqualToString:self.userName.text])
                {
                    flag=false;
                    break;
                }
            }
            if(flag)
            {
                NSMutableDictionary *item=[[NSMutableDictionary alloc]init];
                [item setObject:self.userName.text forKey:@"用户名"];
                [item setObject:self.passWord.text forKey:@"密码"];
                [userListArray insertObject:item atIndex:0];
                [userDefaultes setObject:userListArray forKey:@"保存用户列表"];
            }
            
            
            NSString *userName=[teacherInfoDic objectForKey:@"姓名"];
            [datam initHostUser:weiyima hostName:userName];
            
            [self postUserInfo];
            DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
            [app postUpdateTokenRequest];
            [app getMsgList];
            [app getAlbumMsg];
            if(kUserType==2)
                [app getGPS];
            /*
            for (id key in teacherInfoDic)
            {
                NSLog(@"key: %@ ,value: %@",key,[teacherInfoDic objectForKey:key]);
            }
             */
        }
    }
    else
    {
        NSLog(@"初始化完成...");
        NSString* dataStr;
        NSData *upzipData;
        bool suc=true;
        @try
        {
            dataStr = [[NSString alloc] initWithData:_datas encoding:NSUTF8StringEncoding];
            NSData *_decodedData   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
            upzipData = [LFCGzipUtillity uncompressZippedData:_decodedData];
            dataStr = [[NSString alloc] initWithData:upzipData encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
        if(dataStr==nil || dataStr.length==0)
        {
            //self.labelTip.text=@"获取课表数据失败";
            //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideTip) userInfo:nil repeats:NO];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取课表数据失败" message:nil];
            [tipView show];
            suc=false;
        }
        else
        {
            NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingAllowFragments error:nil];
            userInfoDic=[dict mutableCopy];
            [userDefaultes setObject:[NSDate date] forKey:@"初始化时间"];
            
        }
        [self.indicator stopAnimating];
        self.loginButton.enabled=YES;
        //self.demoBtn.enabled=YES;
        if(suc)
           [self openMainTabbar];
            //[self performSegueWithIdentifier:@"mainMenu" sender:nil];
        /*
        for (id key in dict)
        {
            NSLog(@"key: %@ ,value: %@",key,[dict objectForKey:key]);
        }
        */
    }
   
}
-(void)openMainTabbar
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    XHDrawerController *drawerController = [[XHDrawerController alloc] init];
    drawerController.springAnimationOn = YES;
    
    DDIMainMenu *leftSideDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenu"];
    
    UINavigationController *centerSideDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainView"];
    
    drawerController.leftViewController = leftSideDrawerViewController;
    drawerController.centerViewController = centerSideDrawerViewController;
    
    //[self presentViewController:drawerController animated:YES completion:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController=drawerController;
}
//获取所有信息
-(void) postUserInfo
{
    NSString *weekbegin=[userDefaultes valueForKey:@"weekBegin"];
    if(weekbegin==nil)
    {
        weekbegin=@"0";
        [userDefaultes setValue:weekbegin forKey:@"weekBegin"];
    }
    NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"appserver.php?action=initinfo&zip=1"] URLEncodedString]];
	NSString *post = [NSString stringWithFormat:@"{\"用户较验码\":\"%@\",\"周日为第一天\":\"%@\"}",kUserIndentify,weekbegin];
    post =[GTMBase64 base64StringBystring:post];
    post=[NSString stringWithFormat:@"DATA=%@",post];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
    [request setTimeoutInterval:60];
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request delegate:self];
	
    if (connection) {
        _datas = [NSMutableData new];
    }
    
}

-(void)hideTip
{
    //self.labelTip.text=@"";
    //[self.userName becomeFirstResponder];
}
//登录框抖动
-(void) inputFrameShake
{
    

    CGAffineTransform moveRight = CGAffineTransformTranslate(CGAffineTransformIdentity, 10, 0);
    CGAffineTransform moveLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -10, 0);
    CGAffineTransform resetTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    [UIImageView animateWithDuration:0.1 animations:^{
        self.loginImage.transform = moveLeft;
    } completion:^(BOOL finished) {
        [UIImageView animateWithDuration:0.1 animations:^{
            self.loginImage.transform = moveRight;
        } completion:^(BOOL finished) {
            [UIImageView animateWithDuration:0.1 animations:^{
                self.loginImage.transform = moveLeft;
            } completion:^(BOOL finished) {
                [UIImageView animateWithDuration:0.1 animations:^{
                    self.loginImage.transform = resetTransform;
                }];
            }];
            
        }];
    }];
 
}
- (IBAction)TestLogin:(id)sender {
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"请选择用户类型"
                                                  message:nil
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"老师", @"学生", @"家长",nil];
    [alert show];
    
   
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"mainMenu"])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        //[self.navigationController setNavigationBarHidden:NO];
        
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        self.userName.text=@"0038@dandian.net";
        self.passWord.text=@"0038";
        [self loginClick:nil];
    }
    else if(buttonIndex==2)
    {
        self.userName.text=@"1229641397@dandian.net";
        self.passWord.text=@"123456";
        [self loginClick:nil];
    }
    else if (buttonIndex==3)
    {
        self.userName.text=@"jz1229641397@dandian.net";
        self.passWord.text=@"123456";
        [self loginClick:nil];
    }
}
#pragma mark - UIPopoverListViewDelegate
-(CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
-(NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section
{
    return userListArray.count;
}
-(UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:identifier];
    
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *item=[userListArray objectAtIndex:indexPath.row];
    cell.textLabel.text=[item objectForKey:@"用户名"];
    UIImage *clearImage=[UIImage imageNamed:@"关闭"];
    UIButton *clearBtn=[[UIButton alloc]initWithFrame:CGRectMake(20, 0, 32, 32)];
    [clearBtn setImage:clearImage forState:UIControlStateNormal];
    //[clearBtn setBackgroundColor:[UIColor redColor]];
    cell.accessoryView=clearBtn;
    clearBtn.tag=indexPath.row;
    [clearBtn addTarget:self action:@selector(clearRow:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)clearRow:(UIButton *)sender
{
    [userListArray removeObjectAtIndex:sender.tag];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [indexPaths addObject:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    [UIView animateWithDuration:.35 animations:^{
        [popView.listView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    } completion:^(BOOL finished) {
        if (finished) {
            [popView.listView reloadData];
        }
    }];
    [userDefaultes setObject:userListArray forKey:@"保存用户列表"];
}
-(void)popoverListView:(UIPopoverListView *)popoverListView didSelectIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[userListArray objectAtIndex:indexPath.row];
    self.userName.text=[item objectForKey:@"用户名"];
    self.passWord.text=[item objectForKey:@"密码"];
    [self loginClick:nil];
}

@end
