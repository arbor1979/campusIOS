//
//  HomeViewController.m
//  DDScrollViewController Example
//
//  Created by Hirat on 13-11-8.
//  Copyright (c) 2013年 Hirat. All rights reserved.
//

#import "DDIAlbumScrollPage.h"
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern Boolean kIOS7;
extern NSMutableDictionary *teacherInfoDic;//老师数据
@interface DDIAlbumScrollPage ()

@end

@implementation DDIAlbumScrollPage

- (void)viewDidLoad
{
    if(kIOS7)
    {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    self.dataSource = self;
    pageCacheArray=[NSMutableArray array];
    requestArray=[NSMutableArray array];
    browsedArray=[NSMutableArray array];
    [browsedArray addObject:[_imageArray objectAtIndex:0]];
    praisedArray=[NSMutableArray array];
    deleteArray=[NSMutableArray array];
    //设置导航栏菜单
    rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
    [rightBtn setTitle:@"" forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"empty_heart_white"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(sendPraise) forControlEvents:UIControlEventTouchUpInside];
    exportBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
    [exportBtn setTitle:@"" forState:UIControlStateNormal];
    [exportBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [exportBtn addTarget:self action:@selector(exportBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *heartBtn= [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    UIBarButtonItem *spaceBtn= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBtn.width=20;
    UIBarButtonItem *shareBtn= [[UIBarButtonItem alloc] initWithCustomView:exportBtn];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:shareBtn,spaceBtn,heartBtn,nil];
//    self.navigationItem.rightBarButtonItem = heartBtn;

    [self getImageDetailInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewImage:)
                                                 name:@"newImageUpload"
                                               object:nil];
    emtionV=[[DDIEmotionView alloc]initWithFrame:CGRectZero];
    emtionV.imageNameArray=[CommonFunc emojiStringArray];
    emtionV.frame=CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 216);
    emtionV.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0 blue:240/255.0 alpha:1.0f];
    [emtionV fillImageToView];

    [super viewDidLoad];
}
-(void)exportBtnClick
{
    NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
    NSString *faburen=[item objectForKey:@"发布人唯一码"];
    NSString *userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
    NSString *isAdmin=[teacherInfoDic objectForKey:@"相册管理员"];
    UIAlertView *alert;
    if([userWeiYi isEqualToString:faburen] || [isAdmin isEqualToString:@"是"])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:nil
                                                  message:nil
                                                 delegate:self
                                         cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"分享", @"保存到本地",@"删除",nil];
    }
    else
    {
        alert = [[UIAlertView alloc]initWithTitle:nil
                                          message:nil
                                         delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"分享", @"保存到本地", @"举报",nil];
    }
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *textToShare =@"单点掌上校园图片分享：";
        UIImage* imageToShare=[UIImage imageNamed:@"empty_photo"];
        NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
        NSString *iconName=[item objectForKey:@"文件名"];
        NSString *savepath=[CommonFunc createPath:@"/utils/"];
        NSString *filename=[savepath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            imageToShare=[UIImage imageWithContentsOfFile:filename];
        }
        NSArray *activityItems = @[textToShare, imageToShare];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        
        //不出现在活动项目
        activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,                                             UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }else if (buttonIndex == 2)
    {
        UIImage* imageToShare;
        NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
        NSString *iconName=[item objectForKey:@"文件名"];
        NSString *savepath=[CommonFunc createPath:@"/utils/"];
        NSString *filename=[savepath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            imageToShare=[UIImage imageWithContentsOfFile:filename];
        }
        UIImageWriteToSavedPhotosAlbum(imageToShare, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }else if(buttonIndex == 3) {
        NSString *title=[alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"举报"])
        {
            NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
            NSString *faburen=[item objectForKey:@"发布人唯一码"];
            NSString *imageid=[item objectForKey:@"文件名"];
            [self sendJubao:imageid userid:faburen];
        }
        else if([title isEqualToString:@"删除"])
        {
            NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
            NSString *faburen=[item objectForKey:@"发布人唯一码"];
            NSString *imageid=[item objectForKey:@"文件名"];
            [self sendDelete:imageid userid:faburen];
        }
    }
}
-(void)sendJubao:(NSString *)imageId userid:(NSString *)userid
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"举报" forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:imageId forKey:@"imageId"];
    [dic setObject:userid forKey:@"hostId"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"举报";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)sendDelete:(NSString *)imageId userid:(NSString *)userid
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"删除" forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:imageId forKey:@"imageId"];
    [dic setObject:userid forKey:@"hostId"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"删除";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"保存成功！"];
        [tipView showInView:self.view];
    }
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
        [tipView showInView:self.view];
    }
}
-(void)addNewImage:(NSNotification *)notification
{
    if(notification)
    {
        NSDictionary *item=[notification userInfo];
        NSString *action=[item objectForKey:@"action"];
        if([action isEqualToString:@"评论"])
        {
            NSDictionary *commDic=[item objectForKey:@"commonItem"];
            NSDictionary *imageDic=[commDic objectForKey:@"相片信息"];
            for(int i=0;i<_imageArray.count;i++)
            {
                NSDictionary *subitem=[_imageArray objectAtIndex:i];
                NSString *imageId=[subitem objectForKey:@"文件名"];
                NSString *theImageId=[imageDic objectForKey:@"文件名"];
                if([theImageId isEqualToString:imageId])
                {
                    NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:subitem];
                    //NSMutableArray *commList=[NSMutableArray arrayWithArray:[newItem objectForKey:@"评论列表"]];
                    NSMutableArray *commList=[newItem objectForKey:@"评论列表"];
                    [commList insertObject:commDic atIndex:0];
                    //[newItem setObject:commList forKey:@"评论列表"];
                    [_imageArray replaceObjectAtIndex:i withObject:newItem];
                    break;
                }
            }
            
        }
        else if([action isEqualToString:@"删除评论"])
        {
            AlbumMsg *theMsg=[item objectForKey:@"commonItem"];
            NSDictionary *imageDic=theMsg.imageDic;
            for(int i=0;i<_imageArray.count;i++)
            {
                NSDictionary *subitem=[_imageArray objectAtIndex:i];
                NSString *imageId=[subitem objectForKey:@"文件名"];
                NSString *theImageId=[imageDic objectForKey:@"文件名"];
                if([theImageId isEqualToString:imageId])
                {
                    NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:subitem];
                    //NSMutableArray *commList=[NSMutableArray arrayWithArray:[newItem objectForKey:@"评论列表"]];
                    NSMutableArray *commList=[newItem objectForKey:@"评论列表"];
                    
                    for(NSDictionary *item in commList)
                    {
                        NSString *fromId=[item objectForKey:@"评论人"];
                        NSString *time=[item objectForKey:@"时间"];
                        NSString *content=[item objectForKey:@"评论内容"];
                        if([fromId isEqualToString:theMsg.fromId] && [time isEqualToString:theMsg.time] && [content isEqualToString:theMsg.msg])
                        {
                            [commList removeObject:item];
                            break;
                        }
                    }
                    [newItem setObject:commList forKey:@"评论列表"];
                    [_imageArray replaceObjectAtIndex:i withObject:newItem];
                    break;
                }
            }
            
        }
    }
}
-(void)sendPraise
{
    NSDictionary *item=[self.imageArray objectAtIndex:self.activeIndex];
    NSArray *praiseList=[item objectForKey:@"点赞列表"];
    NSString *action=@"点赞";
    for(int i=0;i<praiseList.count;i++)
    {
        NSDictionary *subItem=[praiseList objectAtIndex:i];
        NSString *userid=[subItem objectForKey:@"点赞人"];
        NSString *userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
        if([userid isEqualToString:userWeiYi])
        {
            //OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"您已赞过！"];
            //[tipView showInView:self.view];
            //return;
            action=@"取消赞";
        }
    }
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"fill_heart_white"] forState:UIControlStateNormal];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:action forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[item objectForKey:@"文件名"] forKey:@"imageId"];
    [dic setObject:[item objectForKey:@"发布人唯一码"] forKey:@"hostId"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=action;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
-(void)updateRightButton:(NSInteger)curIndex;
{
    BOOL flag=false;
    NSDictionary *item=[self.imageArray objectAtIndex:curIndex];
    NSArray *praiseList=[item objectForKey:@"点赞列表"];
    for(int i=0;i<praiseList.count;i++)
    {
        NSDictionary *subItem=[praiseList objectAtIndex:i];
        NSString *userid=[subItem objectForKey:@"点赞人"];
        NSString *userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
        if([userid isEqualToString:userWeiYi])
        {
            flag=true;
            break;
        }
    }
    if(flag)
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"fill_heart_white"] forState:UIControlStateNormal];
    else
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"empty_heart_white"] forState:UIControlStateNormal];
    
} 


-(void)getImageDetailInfo
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumDownloadDetail.php?IsZip=1"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSString *imageIds=@"";
    for(int i=0;i<_imageArray.count;i++)
    {
        NSDictionary *item=[_imageArray objectAtIndex:i];
        if(imageIds.length>0)
            imageIds=[imageIds stringByAppendingString:@";"];
        imageIds=[imageIds stringByAppendingString:[item objectForKey:@"文件名"]];
    }
    [dic setObject:imageIds forKey:@"imageIds"];
    
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"获取相册明细";
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
    
    if([request.username isEqualToString:@"获取相册明细"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSData *upzipData = [LFCGzipUtillity uncompressZippedData:data];
        
        id res = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dianzan=[res objectForKey:@"点赞"];
            for(NSString *key in dianzan)
            {
                NSArray *praiseList=[dianzan objectForKey:key];
                if(praiseList!=nil && praiseList.count>0)
                {
                    for(int i=0;i<_imageArray.count;i++)
                    {
                        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[_imageArray objectAtIndex:i]];
                        NSString *filename=[item objectForKey:@"文件名"];
                        if([filename isEqual:key])
                        {
                            [item setValue:praiseList forKey:@"点赞列表"];
                            [_imageArray replaceObjectAtIndex:i withObject:item];
                            break;
                        }
                    }
                }
            }
            NSDictionary *pinglun=[res objectForKey:@"评论"];
            for(NSString *key in pinglun)
            {
                NSArray *commonList=[pinglun objectForKey:key];
                if(commonList!=nil && commonList.count>0)
                {
                    for(int i=0;i<_imageArray.count;i++)
                    {
                        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[_imageArray objectAtIndex:i]];
                        NSString *filename=[item objectForKey:@"文件名"];
                        if([filename isEqual:key])
                        {
                            [item setValue:commonList forKey:@"评论列表"];
                            [_imageArray replaceObjectAtIndex:i withObject:item];
                            break;
                        }
                    }
                }
            }
            [self reloadData];
            [self updateRightButton:self.activeIndex];
            
        }
    }
    if([request.username isEqualToString:@"点赞"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                NSDictionary *newItem=[res objectForKey:@"返回"];
                NSString *key=[newItem objectForKey:@"imageId"];
                for(int i=0;i<_imageArray.count;i++)
                {
                    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[_imageArray objectAtIndex:i]];
                    NSString *filename=[item objectForKey:@"文件名"];
                    if([filename isEqual:key])
                    {
                        NSMutableArray *praiseList=[NSMutableArray arrayWithArray:[item objectForKey:@"点赞列表"]];
                        [praiseList insertObject:newItem atIndex:0];
                        [item setObject:praiseList forKey:@"点赞列表"];
                        [_imageArray replaceObjectAtIndex:i withObject:item];
                        [praisedArray addObject:item];
                        break;
                    }
                }
                [self updateRightButton:self.activeIndex];
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"已赞！"];
                [tipView showInView:self.view];
                [self reloadData];
            }
        }
    }
    if([request.username isEqualToString:@"取消赞"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                NSDictionary *newItem=[res objectForKey:@"返回"];
                NSString *key=[newItem objectForKey:@"imageId"];
                NSString *userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
                for(int i=0;i<_imageArray.count;i++)
                {
                    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[_imageArray objectAtIndex:i]];
                    NSString *filename=[item objectForKey:@"文件名"];
                    if([filename isEqual:key])
                    {
                        NSMutableArray *praiseList=[NSMutableArray arrayWithArray:[item objectForKey:@"点赞列表"]];
                        for(NSDictionary *praiseItem in praiseList)
                        {
                            if([[praiseItem objectForKey:@"点赞人"] isEqualToString:userWeiYi])
                            {
                                [praiseList removeObject:praiseItem];
                                break;
                            }
                        }
                        [item setObject:praiseList forKey:@"点赞列表"];
                        [_imageArray replaceObjectAtIndex:i withObject:item];
                        [praisedArray addObject:item];
                        break;
                    }
                }
                [self updateRightButton:self.activeIndex];
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"已取消赞！"];
                [tipView showInView:self.view];
                [self reloadData];
            }
        }
    }
    if([request.username isEqualToString:@"举报"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"举报成功！"];
                [tipView showInView:self.view];
            }
        }
    }
    if([request.username isEqualToString:@"删除"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                NSDictionary *fanhui=[res objectForKey:@"返回"];
                if(fanhui)
                    [deleteArray addObject:fanhui];
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"照片已从服务器删除！"];
                [tipView showInView:self.view];
            }
        }
    }
    if([request.username isEqualToString:@"浏览"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                //NSLog(@"更新浏览数成功%@",[res objectForKey:@"返回"]);
            }
        }
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{

    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView showInView:self.view];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newImageUpload" object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}

#pragma mark - DDScrollViewDataSource

- (NSUInteger)numberOfViewControllerInDDScrollView:(DDScrollViewController *)DDScrollView
{
    return [self.imageArray count];
}

- (UIViewController*)ddScrollView:(DDScrollViewController *)ddScrollView contentViewControllerAtIndex:(NSUInteger)index
{
    NSDictionary *item=[self.imageArray objectAtIndex:index];

    for(int i=0;i<pageCacheArray.count;i++)
    {
        NSString *filename=[item objectForKey:@"文件名"];
        DDIAlbumPageItem *itemController=[pageCacheArray objectAtIndex:i];
        NSString *filename1=[itemController.imageItem objectForKey:@"文件名"];
        if([filename isEqualToString:filename1])
        {
            itemController.imageItem=[[NSMutableDictionary alloc]initWithDictionary:item];
            [itemController.tableView reloadData];
            return itemController;
        }
    }
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DDIAlbumPageItem *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"albumPageItem"];
    itemController.myNav=self.navigationController;
    itemController.imageItem=[[NSMutableDictionary alloc]initWithDictionary:item];
    itemController.emtionV=emtionV;
    [pageCacheArray addObject:itemController];
    if(pageCacheArray.count>4)
        [pageCacheArray removeObjectAtIndex:0];
    
    return itemController;
}
-(void)didscrollToNewPage:(NSInteger)pageIndex;
{
    [self updateRightButton:pageIndex];
    NSDictionary *item=[self.imageArray objectAtIndex:pageIndex];
    if(![browsedArray containsObject:item])
        [browsedArray addObject:item];
    if(pageIndex==self.imageArray.count-1 && self.delegate!=nil)
    {
        [self performSelector:@selector(reloadImageArray:) withObject:item afterDelay:1.0f];
        
    }
}
-(void)reloadImageArray:(NSDictionary *)item
{
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    self.imageArray=[self.delegate getNewImageArray:[item objectForKey:@"文件名"]];
    self.activeIndex=0;
    [self getImageDetailInfo];
}
-(void)viewDidDisappear:(BOOL)animated
{
    if(praisedArray.count>0)
    {
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:@"点赞" forKey:@"action"];
        [dict setObject:praisedArray forKey:@"praisedArray"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageUpload" object:nil userInfo:dict];
        [praisedArray removeAllObjects];
    }
    if(browsedArray.count>0)
    {
        NSString *imageIds=@"";
        NSString *hostIds=@"";
        for(NSDictionary *item in browsedArray)
        {
            NSString *imageName=[item objectForKey:@"文件名"];
            NSString *hostId=[item objectForKey:@"发布人唯一码"];
            if(imageIds.length>0)
                imageIds=[imageIds stringByAppendingString:@";"];
            imageIds=[imageIds stringByAppendingString:imageName];
            if(hostIds.length>0)
                hostIds=[hostIds stringByAppendingString:@";"];
            hostIds=[hostIds stringByAppendingString:hostId];
        }
        
        NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
        [dic setObject:@"浏览" forKey:@"action"];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        [dic setObject:hostIds forKey:@"hostIds"];
        [dic setObject:imageIds forKey:@"imageIds"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        request.username=@"浏览";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
        [browsedArray removeAllObjects];
    }
    if(deleteArray.count>0)
    {
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:@"删除" forKey:@"action"];
        [dict setObject:deleteArray forKey:@"deleteArray"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageUpload" object:nil userInfo:dict];
        [deleteArray removeAllObjects];
    }
    [super viewDidDisappear:animated];
}


@end
