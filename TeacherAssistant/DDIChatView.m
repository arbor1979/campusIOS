//
//  ViewController.m
//  ChatMessageTableViewController
//
//  Created by Yongchao on 21/11/13.
//  Copyright (c) 2013 Yongchao. All rights reserved.
//

#import "DDIChatView.h"
#import "DDIHelpView.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSString *talkingRespond;
extern NSString *kUserIndentify;
extern NSString *kInitURL;//默认单点webServic
extern Boolean kIOS7;
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern NSMutableDictionary *lastMsgDic;
extern DDIDataModel *datam;
extern int kSchoolId;
@interface DDIChatView () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation DDIChatView


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    self.navigationItem.title=_respondName;
    _userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
    tmpImage=[UIImage imageNamed:@"jpg"];
    requestArray=[[NSMutableArray alloc]init];
    datam.messages=[[NSMutableArray alloc]init];
    _curMaxId=[datam queryMsgByUserId:_respondUser maxId:-1 minId:0];

    
    
    
    NSString *fileName=[CommonFunc getImageSavePath:_respondUser ifexist:YES];
    if(fileName!=nil)
    {
        UIImage *img=[UIImage imageWithContentsOfFile:fileName];
        img=[img scaleToSize1:CGSizeMake(80, 80)];
        CGRect newSize=CGRectMake(0, 0,80,80);
        _respondManImage=[img cutFromImage:newSize];
    }
    else
    {
        _respondManImage=[UIImage imageNamed:@"unknowMan"];
    }
    fileName=[CommonFunc getImageSavePath:_userWeiYi ifexist:YES];
    if(fileName!=nil)
    {
        UIImage *img=[UIImage imageWithContentsOfFile:fileName];
        img=[img scaleToSize1:CGSizeMake(80, 80)];
        CGRect newSize=CGRectMake(0, 0,80,80);
        _hostManImage=[img cutFromImage:newSize];
    }
    else
    {
        _hostManImage=[UIImage imageNamed:@"unknowMan"];
    }
    if(kIOS7)
        self.edgesForExtendedLayout=UIRectEdgeNone;
    if(datam.messages.count==0)
    {
        topTip=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        topTip.textAlignment=NSTextAlignmentCenter;
        topTip.textColor=[UIColor grayColor];
        topTip.text=@"还没有聊天记录";
        [self.view addSubview:topTip];
    }
    
    [self updateMsgState];
    [self getUnreadState];
    
    //设置导航栏菜单
    UIButton *shuziBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [shuziBtn setTitle:@"" forState:UIControlStateNormal];
    [shuziBtn setBackgroundImage:[UIImage imageNamed:@"shuaizi"] forState:UIControlStateNormal];
    [shuziBtn addTarget:self action:@selector(clearUnRead) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *clearBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shuziBtn];
    self.navigationItem.rightBarButtonItem=clearBarBtn;
   
}
-(void)clearUnRead
{
    if(datam.messages.count>0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否清除所有聊天记录?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"否"
                                                   destructiveButtonTitle:@"是"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=[actionSheet cancelButtonIndex]){
        
        [datam deleteMessageByUserId:_respondUser];
        [datam.messages removeAllObjects];
        _curMaxId=[datam queryMsgByUserId:_respondUser maxId:-1 minId:0];
        [self.tableView reloadData];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    talkingRespond=_respondUser;
    if(aTimer)
        [aTimer invalidate];
    aTimer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getUnreadState) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewMessageFromDB:)
                                                 name:@"newMessageReach"
                                               object:nil];
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    talkingRespond=@"";
    //[datam clearUnReadByUser:_respondUser];
    if(aTimer)
        [aTimer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMessageReach" object:nil];
    [super viewDidDisappear:animated];
}
-(void)dealloc
{
    if(aTimer)
        [aTimer invalidate];
    
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}

- (void)getNewMessageFromDB:(NSNotification*)notification
{
    if(notification)
        [JSMessageSoundEffect playMessageReceivedSound];
    _curMaxId=[datam queryMsgByUserId:_respondUser maxId:-1 minId:_curMaxId];
    [self updateMsgState];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

-(void)getUnreadState
{
    NSMutableArray *unReadArray=[NSMutableArray array];
    for(int i=0;i<datam.messages.count;i++)
    {
        Message *msg=[datam.messages objectAtIndex:i];
        if(msg.ifReceive==0 && msg.ifRead==0 && msg.ifsuc==2)
        {
            for(int j=0;j<msg.msgIdArray.count;j++)
            {
                NSDictionary *item=[msg.msgIdArray objectAtIndex:j];
                NSNumber *ifRead=[item objectForKey:@"ifRead"];
                if(ifRead.intValue==0)
                    [unReadArray addObject:[item objectForKey:@"msgId"]];
            }
            
        }
    }
    if(unReadArray.count>0)
    {
        NSString *msgId=[unReadArray componentsJoinedByString:@","];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        [dic setObject:@"GetInfo" forKey:@"ACTION"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        [dic setObject:msgId forKey:@"MSG_ID_LIST"];
        
        
        NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GeSmsStatus.php"]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        request.username=@"获取已读状态";
        request.userInfo=dic;
        [request startAsynchronous];
        [requestArray addObject:request];
    }
}

-(void) postNewMsg:(Message *)newMsg
{
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:newMsg.text forKey:@"CONTENT"];
    [dic setObject:newMsg.msgType forKey:@"CONTENT_TYPE"];
    [dic setObject:@"DataDeal" forKey:@"action"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:_respondUser forKey:@"TOID"];
    [dic setObject:[NSNumber numberWithInt:newMsg.rowid] forKey:@"rowid"];
    if([newMsg.msgType isEqualToString:@"img"])
    {
        NSData *imageData=UIImageJPEGRepresentation(newMsg.img,0.3);
        newMsg.text=[GTMBase64 stringByEncodingData:imageData];
        [dic setObject:newMsg.text forKey:@"CONTENT"];
    }
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"SendSMS_MSG_ATOB.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
    [dicArray addObject:dic];
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"发消息";
    request.userInfo=dic;
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"发消息"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *result=[dict objectForKey:@"MSG_STATUS"];
        NSLog(@"消息发送：%@",result);
        
        NSDictionary *dic=request.userInfo;
        NSNumber *rowid=[dic objectForKey:@"rowid"];
        if([result isEqualToString:@"成功"])
        {
             [JSMessageSoundEffect playMessageSentSound];
            //[JSMessageSoundEffect playMessageReceivedSound];
            NSArray *msgIdArray=[dict objectForKey:@"MSG_ID"];
            NSArray *userIdArray=[dict objectForKey:@"TO_USERID_UNIQUE"];
            [datam updateMessageFlag:rowid.intValue flag:2 msgIdArray:msgIdArray userIdArray:userIdArray];
            
            if(lastMsgDic && lastMsgDic.count>0)
            {
                NSString *msgType=[dic objectForKey:@"CONTENT_TYPE"];
                NSString *msgContent=[dic objectForKey:@"CONTENT"];
                NSArray *userArray=[_respondUser componentsSeparatedByString:@","];
                for(int i=0;i<userArray.count;i++)
                {
                    NSString *userid=[userArray objectAtIndex:i];
                    NSMutableDictionary *item=[[NSMutableDictionary alloc] initWithDictionary:[lastMsgDic objectForKey:userid]];
                    NSMutableDictionary *lastMsg;
                    if(item)
                    {
                        
                        lastMsg=[[NSMutableDictionary alloc] initWithDictionary:[item objectForKey:@"最后一次聊天记录"]];
                        if(lastMsg)
                        {
                            [lastMsg setValue:msgContent forKey:@"CONTENT"];
                            [lastMsg setValue:msgType forKey:@"TYPE"];
                        }
                        
                    }
                    else
                    {
                        lastMsg=[NSMutableDictionary dictionary];
                        [lastMsg setValue:msgContent forKey:@"CONTENT"];
                        [lastMsg setValue:msgType forKey:@"TYPE"];
                        item=[NSMutableDictionary dictionary];
                        
                    }
                    [item setValue:lastMsg forKey:@"最后一次聊天记录"];
                    [lastMsgDic setValue:item forKey:userid];
                }
            }
        }
        else
        {
            
            [datam updateMessageFlag:rowid.intValue flag:0 msgIdArray:Nil userIdArray:nil];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"服务器返回错误"];
            [tipView show];
            
        }
        if(self.tableView)
            [self.tableView reloadData];
    }
    if([request.username isEqualToString:@"获取已读状态"] || [request.username isEqualToString:@"更新已读状态"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSArray *keyArray=[dict allKeys];
            NSMutableArray *ReadedArray=[NSMutableArray array];
            for(int i=0;i<keyArray.count;i++)
            {
                
                NSString *msgId=[keyArray objectAtIndex:i];
                NSString *state=[dict objectForKey:msgId];
                if(![state isEqual:[NSNull null]] && [state isEqualToString:@"已读"])
                   [ReadedArray addObject:msgId];
                
            }
            if(ReadedArray.count>0)
            {
                NSArray *indexArray=[datam updateReadFlag:ReadedArray];
                [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
        
    }
    else if (request.username.intValue>=0)
    {
        NSData *datas = [request responseData];
        UIImage *image=[[UIImage alloc]initWithData:datas];
        if(image!=nil)
        {
            NSString *subdir=@"/chatImages/";
            NSString *path=[CommonFunc createPath:subdir];
            NSTimeInterval times=[[NSDate new] timeIntervalSince1970];
            NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.jpg",times]];   // 保存文件的名称
            [datas writeToFile:filePath atomically:YES];
            Message *msg=[datam.messages objectAtIndex:request.username.intValue];
            msg.img=image;
            msg.text=filePath;
            [datam updateMessage:msg];
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
        }
        if([requestArray containsObject:request])
            [requestArray removeObjectIdenticalTo:request];
    }
   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *errMsg;
    if([request.username isEqualToString:@"发消息"])
    {
        errMsg=@"发消息失败";
        NSDictionary *dic=request.userInfo;
        NSNumber *rowid=[dic objectForKey:@"rowid"];
        [datam updateMessageFlag:rowid.intValue flag:0 msgIdArray:nil userIdArray:nil];
        if(self.tableView)
            [self.tableView reloadData];
        
    }
    else if([request.username isEqualToString:@"获取已读状态"])
    {
        errMsg=@"";
    }
    else if(request.username.intValue>=0)
    {
        errMsg=@"接收图片失败";
    }
    if(errMsg && errMsg.length>0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:errMsg];
        [tipView show];
    }
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(datam.messages.count>0 && topTip)
       [topTip removeFromSuperview];
    return datam.messages.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    Message *newMsg=[[Message alloc]init];
    newMsg.respondUser=self.respondUser;
    newMsg.respondName=self.respondName;
    newMsg.msgType=@"txt";
    newMsg.text=text;
    newMsg.date=[NSDate new];
    newMsg.ifReceive=0;
   
    [datam addMessage:newMsg];
    [self postNewMsg:newMsg];
    
    _curMaxId=[datam queryMsgByUserId:_respondUser maxId:-1 minId:_curMaxId];
    [self finishSend];
}

- (void)cameraPressed:(id)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    if(message.ifReceive==1)
        return JSBubbleMessageTypeIncoming;
    else
        return JSBubbleMessageTypeOutgoing;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleDefault;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    
    if([message.msgType isEqualToString:@"img"] || [message.msgType isEqualToString:@"image"])
        return JSBubbleMediaTypeImage;
    else
        return JSBubbleMediaTypeText;

}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyCustom;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleSquare;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat

     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
 - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=(int)indexPath.row;
    if(row>1)
    {
        Message* message1 = [datam.messages objectAtIndex:row-1];
        Message* message2 = [datam.messages objectAtIndex:row];
        NSDate *dt1=message1.date;
        NSDate *dt2=message2.date;
        if([dt2 timeIntervalSinceDate:dt1]>60)
            return true;
        else
            return false;
        
    }
    else
        return true;
}

-(void)reSendFailure:(UIButton *)sender
{
    int row=(int)sender.titleLabel.tag;
    Message* message = [datam.messages objectAtIndex:row];
    if(!message.ifsuc)
    {
        [self postNewMsg:message];
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"消息已重发"];
        [tipView show];
    }
}
#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    if([message.msgType isEqualToString:@"txt"])
    {
        if(message.linkUrl!=nil && message.linkUrl.length>0)
            return [NSString stringWithFormat:@"%@\n[点击查看]", message.text];
        else
            return message.text;
    }
    else
        return nil;
}
- (NSString *)linkUrlForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    if([message.msgType isEqualToString:@"txt"])
    {
        return message.linkUrl;
    }
    else
        return nil;
    
    
}
-(void)updateMsgState
{
    NSMutableArray *haveReadArray=[NSMutableArray array];
    for(int i=0;i<datam.messages.count;i++)
    {
        Message *message=[datam.messages objectAtIndex:i];
        if(message.ifRead==0 && message.ifReceive==1 && message.msgIdArray.count>0)
        {
            NSString *msgid=@"";
            
            for(int j=0;j<message.msgIdArray.count;j++)
            {
                NSDictionary *item=[message.msgIdArray objectAtIndex:j];
                if(msgid.length>0)
                    [msgid stringByAppendingString:@","];
                msgid=[msgid stringByAppendingString:[item objectForKey:@"msgId"]];
            }
           [haveReadArray addObject:msgid];
            
        }
        
    }
    if(haveReadArray.count>0)
    {
        NSString *msgId=[haveReadArray componentsJoinedByString:@","];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        [dic setObject:@"SetInfo" forKey:@"ACTION"];
        [dic setObject:msgId forKey:@"MSG_ID_LIST"];
        
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        
        NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"GeSmsStatus.php"]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
        [dicArray addObject:dic];
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        request.username=@"更新已读状态";
        [request startAsynchronous];
        [requestArray addObject:request];
        [datam updateReadFlag:haveReadArray];
    }
    
    
}
- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    return message.date;
}
- (NSMutableArray *)sendDestForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *destArray=[NSMutableArray array];
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    NSArray *tmpArray=[message.respondUser componentsSeparatedByString:@","];
    NSDictionary *duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
    NSArray *allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
    for(int i=0;i<tmpArray.count;i++)
    {
        NSNumber *key=[duizhaoDic objectForKey:[tmpArray objectAtIndex:i]];
        NSMutableDictionary *linkman=[[NSMutableDictionary alloc]initWithDictionary:[allLinkManArray objectAtIndex:key.intValue]];
        for(int j=0;j<message.msgIdArray.count;j++)
        {
            NSDictionary *item=[message.msgIdArray objectAtIndex:j];
            if([[item objectForKey:@"respondUser"] isEqualToString:[tmpArray objectAtIndex:i]])
                [linkman setObject:[item objectForKey:@"ifRead"] forKey:@"ifRead"];
        }
        [destArray addObject:linkman];
    }
    return destArray;
}

- (UIImage *)avatarImageForIncomingMessage
{
    return _respondManImage;
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return _hostManImage;
}
- (int)messageIfRead:(NSIndexPath *)index
{
    Message *msg=[datam.messages objectAtIndex:index.row];
    return msg.ifRead;
}
-(void)headImageClick:(UIButton *)sender;
{
    NSString *text;
    if([sender.titleLabel.text isEqualToString:@"0"])
    {
        text=_respondUser;
    }
    else
    {
        text=_userWeiYi;
    }
    
    NSArray *textArray=[text componentsSeparatedByString:@"_"];
    int userSchoolId=[[textArray objectAtIndex:6] intValue];
    if([[textArray objectAtIndex:1] isEqualToString:@"学生"] && kUserType==1 && kSchoolId==userSchoolId)
    {
        [self performSegueWithIdentifier:@"theStudentInfor" sender:text];
    }
    else
        [self performSegueWithIdentifier:@"theTeacherInfor" sender:text];
        
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *text=sender;
    if([segue.identifier isEqualToString:@"theTeacherInfor"])
    {
        DDIMyInforView *view=segue.destinationViewController;
        view.userWeiYi=text;
        
    }else if([segue.identifier isEqualToString:@"theStudentInfor"])
    {
        //DDIStudentInfo *view=segue.destinationViewController;
        DDIMyInforView *view=segue.destinationViewController;
        view.userWeiYi=text;
    }
    
}
- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    if([message.msgType isEqualToString:@"img"])
    {
        if (message.img) {
            return message.img;
        }
        else
        {
            message.img=tmpImage;
            NSString *urlStr=message.imageUrl;
            if(urlStr && urlStr.length>0)
            {
                NSURL *url = [NSURL URLWithString:urlStr];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
            }
        }
       
    }
    
    return nil;
    
}

#pragma UIImagePicker Delegate

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    self.willSendImage = [info objectForKey:UIImagePickerControllerOriginalImage];//UIImagePickerControllerEditedImage
    Message *newMsg=[[Message alloc]init];
    newMsg.respondUser=_respondUser;
    newMsg.respondName=_respondName;
    newMsg.date=[NSDate new];
    newMsg.msgType=@"img";
    newMsg.img=self.willSendImage;
    NSString *subdir=@"/chatImages/";
    NSString *path=[CommonFunc createPath:subdir];
    NSTimeInterval times=[[NSDate new] timeIntervalSince1970];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.jpg",times]];   // 保存文件的名称
    
    [UIImageJPEGRepresentation(newMsg.img,0.3) writeToFile: filePath  atomically:YES];

    newMsg.text=filePath;
    newMsg.ifReceive=0;
    [datam addMessage:newMsg];
    [self postNewMsg:newMsg];
    _curMaxId=[datam queryMsgByUserId:_respondUser maxId:-1 minId:_curMaxId];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)reloadTableViewDataSource
{
    int maxid=0;
    if(datam.messages.count>0)
    {
        Message *msg=[datam.messages objectAtIndex:0];
        maxid=msg.rowid;
    }
    
    oldMsgCount=(int)datam.messages.count;
    [datam queryMsgByUserId:_respondUser maxId:maxid minId:0];
    
    int newMsgcount=(int)datam.messages.count;
    if(newMsgcount==oldMsgCount)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有更早的聊天记录了"];
        [tipView show];
    }
    else
        [self updateMsgState];
    
}
- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	[self.tableView reloadData];
    int newMsgcount=(int)datam.messages.count;
    if(newMsgcount>oldMsgCount)
    {
        NSIndexPath *indexpath=[NSIndexPath indexPathForRow:newMsgcount-oldMsgCount inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}
- (int)isMessageSuc:(NSIndexPath *)indexPath
{
    Message* message = [datam.messages objectAtIndex:indexPath.row];
    return message.ifsuc;
    
}
-(void)cellOnTap:(JSBubbleView *)view
{
    if(view.mediaType==JSBubbleMediaTypeImage)
    {
        NSData *imageData=UIImageJPEGRepresentation(view.data,0.3);
        NSString *tmpDir = NSTemporaryDirectory();
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        NSString *fileName=[NSString stringWithFormat:@"%@%@.png",tmpDir,timeStamp];
        [imageData writeToFile:fileName atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:fileName];
        documentInteractionController = [UIDocumentInteractionController                                                      interactionControllerWithURL:url];
        [documentInteractionController setDelegate:self];
        [documentInteractionController presentPreviewAnimated:YES];
    }
    else if(view.mediaType==JSBubbleMediaTypeText)
    {
        if(view.linkUrl!=nil && view.linkUrl.length>0)
        {
             NSString *base64Str=[GTMBase64 base64FromSafeBase64ForURL:view.linkUrl];
             NSString *jumpurl= [GTMBase64 stringByBase64String:base64Str];
             if(jumpurl!=nil && jumpurl.length>0)
             {
                 NSString *template=[CommonFunc findUrlQueryString:jumpurl :@"template"];
                 NSString *templategrade=[CommonFunc findUrlQueryString:jumpurl :@"templategrade"];
                 NSString *targettitle=[CommonFunc findUrlQueryString:jumpurl :@"targettitle"];
                 if(template==nil || template.length==0)
                     template=@"浏览器";
                 if([jumpurl containsString:@"?"])
                     jumpurl=[jumpurl stringByAppendingString:@"&"];
                 else
                     jumpurl=[jumpurl stringByAppendingString:@"?"];
                 jumpurl = [jumpurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                 
                 if([template isEqualToString:@"浏览器"])
                 {
                     DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
                     controller.navigationItem.title=targettitle;
                     NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                     [dic setObject:kUserIndentify forKey:@"用户较验码"];
                     NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                     [dic setObject:timeStamp forKey:@"DATETIME"];
                     NSError *error;
                     NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                     NSString *postStr=[GTMBase64 stringByWebSafeEncodingData:postData padded:YES];
                     jumpurl=[NSString stringWithFormat:@"%@jiaoyanma=%@",jumpurl,postStr];
                     controller.urlStr=jumpurl;
                     [self.navigationController pushViewController:controller animated:YES];
                 }
                 else if([template isEqualToString:@"公告通知"])
                 {
                     if([templategrade isEqualToString:@"main"])
                     {
                         DDINewsTitle *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"newsMain"];
                         controller.newsType=targettitle;
                         controller.interfaceUrl=jumpurl;
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                     else
                     {
                         DDINewsDetail *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"newsDetail"];
                         News *new=[[News alloc]init];
                         new.url=jumpurl;
                         controller.news=new;
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                }
                else if([template isEqualToString:@"成绩"])
                {
                     if([templategrade isEqualToString:@"main"])
                     {
                         DDIChengjiTitle *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiMain"];
                         controller.interfaceUrl=jumpurl;
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                     else
                     {
                         DDIChengjiDetail *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiDetail"];
                         controller.interfaceUrl=jumpurl;
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                }
                else if([template isEqualToString:@"调查问卷"])
                {
                     if([templategrade isEqualToString:@"main"])
                     {
                         DDIWenJuanTitle *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanMain"];
                         controller.interfaceUrl=jumpurl;
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                     else
                     {
                         DDIWenJuanDetail *controller;
                         controller=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
                         controller.interfaceUrl=jumpurl;
                         controller.title=targettitle;
                         controller.examStatus=@"进行中";
                         controller.key=-1;
                         controller.parentTitleArray=nil;
                         controller.autoClose=@"是";
                         [self.navigationController pushViewController:controller animated:YES];
                     }
                }
             }
        }
    }
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}
@end
