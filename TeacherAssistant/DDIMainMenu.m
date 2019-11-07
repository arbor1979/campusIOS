//
//  DDIMainMenu.m
//  老师助手
//
//  Created by yons on 13-11-28.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMainMenu.h"
extern NSString *kUserIndentify;
extern NSMutableDictionary *userInfoDic;
extern NSMutableDictionary *lastMsgDic;
extern Boolean kIOS7;
extern NSString *curVersion;
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSString *kInitURL;
extern DDIDataModel *datam;
@interface DDIMainMenu ()

@end

@implementation DDIMainMenu



- (void)viewDidLoad
{
    [super viewDidLoad];
    userDefaultes = [NSUserDefaults standardUserDefaults];
    _reloginBtn.backgroundColor = [UIColor clearColor];
    NSString *curName=[teacherInfoDic objectForKey:@"姓名"];
    curName=[curName stringByReplacingOccurrencesOfString:@"[家长]" withString:@""];
    curName=[curName stringByAppendingString:[NSString stringWithFormat:@"(%@)",[teacherInfoDic objectForKey:@"用户类型"]]];
    _lblName.text=curName;
    if([[teacherInfoDic objectForKey:@"用户类型"] isEqual:@"老师"])
        _lblBumen.text=[teacherInfoDic objectForKey:@"部门"];
    else
        _lblBumen.text=[teacherInfoDic objectForKey:@"班级"];
    
    requestArray=[[NSMutableArray alloc] init];
    _btnHead.imageView.layer.cornerRadius = 5;
    _btnHead.imageView.layer.masksToBounds = YES;
    
    //NSString *fileName=[CommonFunc getImageSavePath:[teacherInfoDic objectForKey:@"用户唯一码"] ifexist:YES];
    NSString *urlStr=[teacherInfoDic objectForKey:@"用户头像"];
    NSString *fileName=[CommonFunc getCacheImagePath:urlStr];
    if(fileName)
    {
        headImage=[UIImage imageWithContentsOfFile:fileName];
        [_btnHead setImage:headImage forState:UIControlStateNormal];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=[teacherInfoDic objectForKey:@"用户唯一码"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
        
    _lblBanben.text=[NSString stringWithFormat:@"软件版本：%@",curVersion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHeadImage)
                                                 name:@"changeHeadImage"
                                               object:nil];
}
-(void)reloadHeadImage
{
    NSString *fileName=[CommonFunc getImageSavePath:[teacherInfoDic objectForKey:@"用户唯一码"] ifexist:YES];
    if(fileName)
    {
        headImage=[UIImage imageWithContentsOfFile:fileName];
        [_btnHead setImage:headImage forState:UIControlStateNormal];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"更改密码"])
    {
        if(tipAlert)
            [tipAlert hide];
        NSData *datas = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        datas = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"结果"];
        if([status isEqualToString:@"成功"])
        {
            NSDictionary *params=request.userInfo;
            [userDefaultes setObject:[params objectForKey:@"密码"] forKey:@"密码"];
            kUserIndentify=[[dict objectForKey:@"用户资料"] objectForKey:@"用户较验码"];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"密码修改成功！"];
            [tipView show];
        }
        else
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[@"失败：" stringByAppendingString:status]];
            [tipView show];
        }
    }
    else
    {
        NSData *datas = [request responseData];
        headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            [_btnHead setImage:headImage forState:UIControlStateNormal];
            [CommonFunc setCacheImagePath:request.url.absoluteString localPath:path];
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(tipAlert)
        [tipAlert hide];
    NSError *error = [request error];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
    if([requestArray containsObject:request])
        [requestArray removeObject:request];
    request=nil;
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeHeadImage" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)reLogin:(id)sender {

    kUserIndentify=nil;
    userInfoDic=nil;
    if (lastMsgDic)
        lastMsgDic=nil;
    [DDIHelpView setLoginDate:nil];
    //[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [userDefaultes setObject:nil forKey:@"用户名"];
    DDIVLoginMain *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginmain"];
    [UIApplication sharedApplication].keyWindow.rootViewController=loginController;
}
-(UIBarButtonItem *) setupNavBackBtn
{
    //设置导航栏菜单
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    backButtonItem.tintColor=[UIColor whiteColor];
    //self.navigationController.navigationItem.leftBarButtonItem = backButtonItem;
    return backButtonItem;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==1)
    {
        DDIMyInforView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"MyInforView"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"我的资料";
        [self presentViewController:nav animated:true completion:nil];
    }
    else if(indexPath.row==2)
    {
        DDIAlbumPersonal *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"albumPersonal"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        //controller.navigationItem.title=@"";
        controller.userid=[teacherInfoDic objectForKey:@"用户唯一码"];
        controller.username=[teacherInfoDic objectForKey:@"姓名"];
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==3)
    {
        
        UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"请输入旧密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
        [customAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        customAlertView.tag=1;
        [customAlertView show];
        
    }
    else if(indexPath.row==4)
    {
        DDINotifySetup *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"notifySetup"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"课程提醒";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==5)
    {
        DDIShangkeTime *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"ShangkeTime"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"上课时间表";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==6)
    {
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        //controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"关于我们";
        controller.urlStr=[NSString stringWithFormat:@"http://laoshi.dandian.net/yingxin/aboutus.php?school=%@",kUserIndentify];
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==7)
    {
        DDIHelpQuest *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpQuest"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.leftBarButtonItem=[self setupNavBackBtn];
        controller.navigationItem.title=@"意见反馈";
        [self presentViewController:nav animated:true completion:nil];
        
    }
    else if(indexPath.row==8)
    {
        UIActionSheet *av=[[UIActionSheet alloc]initWithTitle:@"确认删除所有缓存图片，包括用户头像和聊天图片？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [av showInView:self.view];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *dirArray=[[NSArray alloc]initWithObjects:@"utils",@"teachers",@"students",@"parents",@"News",@"classRecord",@"classNotes",@"chatImages",@"webbrowers", nil];
        for(int i=0;i<dirArray.count;i++)
        {
            NSString *dir=[NSString stringWithFormat:@"/%@",[dirArray objectAtIndex:i]];
            NSString *path=[CommonFunc createPath:dir];
           [fileManager removeItemAtPath:path error:nil];
           [CommonFunc createPath:dir];
        }
        [datam deleteAllNews];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBadge" object:nil];
        if(dirArray.count>0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"已删除所有缓存文件"];
            [tipView show];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag==1)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            UITextField *nameField = [alertView textFieldAtIndex:0];
            NSString *oldPassword=nameField.text;
            NSString *savedPassword=[userDefaultes stringForKey:@"密码"];
            if([oldPassword isEqualToString:savedPassword])
            {
                
                UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:@"请输入新密码" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil,nil];
                
                [customAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
                
                UITextField *nameField = [customAlertView textFieldAtIndex:0];
                [nameField setSecureTextEntry:YES];
                nameField.placeholder = @"请输入新密码";
                
                UITextField *urlField = [customAlertView textFieldAtIndex:1];
                [urlField setSecureTextEntry:YES];
                urlField.placeholder = @"请再次输入新密码";
                customAlertView.tag=2;
                [customAlertView show];
            }
            else
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"旧密码不正确"];
                [tipView show];
            }
        }
    }
    if(alertView.tag==2)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex)
        {
            UITextField *nameField = [alertView textFieldAtIndex:0];
            NSString *newPassword=nameField.text;
            UITextField *urlField = [alertView textFieldAtIndex:1];
            NSString *comfirmPassword=urlField.text;
            
            if(![newPassword isEqualToString:comfirmPassword])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"两次输入密码不一致"];
                [tipView show];
            }
            else
            {
                if([newPassword trimWhitespace].length==0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"密码不能为空"];
                    [tipView show];
                }
                else
                {
                    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
                    [dic setObject:kUserIndentify forKey:@"用户较验码"];
                    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                    [dic setObject:timeStamp forKey:@"DATETIME"];
                    [dic setObject:@"changePwd"  forKey:@"action"];
                    [dic setObject:[userDefaultes stringForKey:@"用户名"] forKey:@"用户名"];
                    [dic setObject:[userDefaultes stringForKey:@"密码"] forKey:@"旧密码"];
                    [dic setObject:newPassword forKey:@"密码"];
                    
                    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"GetUserPwdIsRight.php"] URLEncodedString]];
                    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                    NSError *error;
                    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                    postStr=[GTMBase64 base64StringBystring:postStr];
                    [request setPostValue:postStr forKey:@"DATA"];
                    [request setDelegate:self];
                    request.userInfo=dic;
                    request.username=@"更改密码";
                    [requestArray addObject:request];
                    [request startAsynchronous];
                    tipAlert=[[OLGhostAlertView alloc] initWithIndicator:@"修改密码中，请稍候" timeout:0 dismissible:NO];
                    [tipAlert show];
                }
            }
        }
    }
    
    
}
-(void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 80);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = headImage;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.parentViewController.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,self.tableView.contentOffset.y,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
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
@end
