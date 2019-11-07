//
//  DDIAlbumPageItem.m
//  掌上校园
//
//  Created by Mac on 15/1/13.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIAlbumPageItem.h"
#define INPUT_HEIGHT 46.0f
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern NSMutableDictionary *teacherInfoDic;//老师数据
@implementation DDIAlbumPageItem

-(void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    savepath=[CommonFunc createPath:@"/utils/"];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    requestArray=[NSMutableArray array];
    indexPathDic=[NSMutableDictionary dictionary];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self setExtraCellLineHidden:self.tableView];
    replyTip=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-inputToolBarView.frame.size.height-24, self.view.frame.size.width, 24)];
    replyTip.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f];
    lbTiptitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 2, 160, 20)];
    lbTiptitle.backgroundColor=[UIColor clearColor];
    lbTiptitle.textColor=[UIColor whiteColor];
    lbTiptitle.font=[UIFont systemFontOfSize:12];
    [replyTip addSubview:lbTiptitle];
    UIButton *closeTip=[[UIButton alloc]initWithFrame:CGRectMake(replyTip.frame.size.width-24, 2, 20, 20)];
    [closeTip setImage:[UIImage imageNamed:@"setting_bn_off"] forState:UIControlStateNormal];
    [closeTip addTarget:self action:@selector(closeTipView) forControlEvents:UIControlEventTouchUpInside];
    [replyTip addSubview:closeTip];
    
    [self initChatToolBar];
    
}
-(void)closeTipView
{
    [replyTip removeFromSuperview];
}
-(void) initChatToolBar
{
    UIButton* mediaButton = nil;
    UIImage* image = [UIImage imageNamed:@"smile_black"];
    CGRect frame = CGRectMake(4, 0, image.size.width, image.size.height);
    CGFloat yHeight = (INPUT_HEIGHT - frame.size.height) / 2.0f;
    frame.origin.y = yHeight;
    
    // make the button
    mediaButton = [[UIButton alloc] initWithFrame:frame];
    [mediaButton setBackgroundImage:image forState:UIControlStateNormal];
    
    // button action
    [mediaButton addTarget:self action:@selector(showIconAction) forControlEvents:UIControlEventTouchUpInside];
    CGSize size=self.view.frame.size;
    CGRect inputFrame = CGRectMake(0.0f, size.height - INPUT_HEIGHT, size.width, INPUT_HEIGHT);
    inputToolBarView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];
    
    // TODO: refactor
    inputToolBarView.textView.dismissivePanGestureRecognizer = self.tableView.panGestureRecognizer;
    inputToolBarView.textView.keyboardDelegate = self;
    inputToolBarView.textView.placeHolder = @"说点什么呢？";
    
    UIButton *sendButton = [UIButton defaultSendButton];
    sendButton.enabled = NO;
    sendButton.frame = CGRectMake(inputToolBarView.frame.size.width - 65.0f, 12.0f, 59.0f, 26.0f);
    [sendButton addTarget:self
                   action:@selector(sendPressed)
         forControlEvents:UIControlEventTouchUpInside];
    [inputToolBarView setSendButton:sendButton];
    [self.view addSubview:inputToolBarView];
    
    // adjust the size of the send button to balance out more with the camera button on the other side.
    frame = inputToolBarView.sendButton.frame;
    frame.size.width -= 16;
    frame.origin.x += 16;
    inputToolBarView.sendButton.frame = frame;
    
    // add the camera button
    [inputToolBarView addSubview:mediaButton];
    
    // move the tet view over
    frame = inputToolBarView.textView.frame;
    frame.origin.x += mediaButton.frame.size.width + mediaButton.frame.origin.x;
    frame.size.width -= mediaButton.frame.size.width + mediaButton.frame.origin.x;
    frame.size.width += 16;		// from the send button adjustment above
    inputToolBarView.textView.frame = frame;
    //定义一个toolBar
    topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    
    lbCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 15)];
    lbCount.font=[UIFont systemFontOfSize:15];
    lbCount.backgroundColor = [UIColor clearColor];
    lbCount.textColor=[UIColor grayColor];
    lbCount.textAlignment=NSTextAlignmentLeft;
    lbCount.text  = @"0/150";
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithCustomView:lbCount];

    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    inputToolBarView.textView.inputAccessoryView=topView;
    

}
//隐藏键盘
- (void)resignKeyboard {
    [inputToolBarView.textView resignFirstResponder];
}

-(void)showIconAction
{
    if(ificonshow)
    {
        //[inputToolBarView.textView becomeFirstResponder];
        
        _emtionV.delegate=self;
        [self.view bringSubviewToFront:_emtionV];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        CGRect frame=_emtionV.frame;
        frame.origin.y=self.view.frame.size.height;
        _emtionV.frame=frame;
        frame=inputToolBarView.frame;
        frame.origin.y=self.view.frame.size.height-inputToolBarView.frame.size.height;
        inputToolBarView.frame=frame;
        frame=replyTip.frame;
        frame.origin.y=inputToolBarView.frame.origin.y-24;
        replyTip.frame=frame;
        [UIView commitAnimations];
        
        
        ificonshow=false;
    }
    else
    {
        if(ifkeyshow)
        {
            [self resignKeyboard];
        }
        [_emtionV removeFromSuperview];
        
        [self.view addSubview:_emtionV];
        _emtionV.delegate=self;
        [self.view bringSubviewToFront:_emtionV];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        CGRect frame=_emtionV.frame;
        frame.origin.y=self.view.frame.size.height-frame.size.height;
        _emtionV.frame=frame;
        frame=inputToolBarView.frame;
        frame.origin.y=self.view.frame.size.height-inputToolBarView.frame.size.height-_emtionV.frame.size.height;
        inputToolBarView.frame=frame;
        frame=replyTip.frame;
        frame.origin.y=inputToolBarView.frame.origin.y-24;
        replyTip.frame=frame;
        [UIView commitAnimations];
        ificonshow=true;
    }
}
- (void)emotionBtnOnClick:(NSString*)imageName;
{
    inputToolBarView.textView.text=[NSString stringWithFormat:@"%@[%@]",inputToolBarView.textView.text,imageName];
    [self textViewDidChange:inputToolBarView.textView];
}
-(void)sendPressed
{
    if(inputToolBarView.textView.text.length==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"请输入评论内容"];
        [tipView showInView:self.view];
        return;
    }
    if(inputToolBarView.textView.text.length>150)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"评论内容不能超过150字"];
        [tipView showInView:self.view];
        return;
    }
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"评论" forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:inputToolBarView.textView.text forKey:@"comment"];
    [dic setObject:[_imageItem objectForKey:@"文件名"] forKey:@"imageId"];
    [dic setObject:[_imageItem objectForKey:@"发布人唯一码"] forKey:@"hostId"];
    if(replyTip.superview)
    {
        [dic setObject:replyId forKey:@"replyId"];
    }
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"评论";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    inputToolBarView.textView.text=nil;
    //inputToolBarView.sendButton.enabled=false;
    [self textViewDidChange:inputToolBarView.textView];
    
    if(ificonshow)
        [self showIconAction];
    [self resignKeyboard];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    NSArray *tmpArray=[request.username componentsSeparatedByString:@"_"];
    if(tmpArray.count<4)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
        [tipView showInView:self.view];
    }
}
- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count=2;
    NSArray *praiseList=[_imageItem objectForKey:@"点赞列表"];
    if(praiseList!=nil && praiseList.count>0)
        count=3;
    NSArray *commList=[_imageItem objectForKey:@"评论列表"];
    if(commList!=nil && commList.count>0)
        count=4;
    return count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 1;
    else if(section==1)
        return 2;
    else if(section==2)
        return 1;
    else if(section==3)
    {
        NSArray *commList=[_imageItem objectForKey:@"评论列表"];
        if(commList!=nil && commList.count>0)
            return commList.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section==0)
    {
        static NSString *CellIdentifier = @"itemImageCell";
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        UIImageView *iv=(UIImageView *)[cell viewWithTag:101];
        UIImage* image;
        NSString *iconName=[_imageItem objectForKey:@"文件名"];
        NSString *filename=[savepath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            image=[UIImage imageWithContentsOfFile:filename];
        }
        else
        {
            NSString *urlStr=[_imageItem objectForKey:@"文件地址"];
            [self loadImagetData:urlStr filename:filename indexPath:indexPath];
            image=[UIImage imageNamed:@"empty_photo"];
        }
        [iv setImage:image];
       
    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
        {
            static NSString *CellIdentifier = @"itemHostCell";
            cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.backgroundColor=[UIColor clearColor];
            UIButton *headBtn=(UIButton *)[cell viewWithTag:101];
            headBtn.imageView.layer.cornerRadius = headBtn.frame.size.width / 2;
            headBtn.imageView.layer.masksToBounds = YES;
            
            NSString *userid=[_imageItem objectForKey:@"发布人唯一码"];
            NSString *picUrl=[_imageItem objectForKey:@"发布人头像"];
            headBtn.titleLabel.text=userid;
            [headBtn addTarget:self action:@selector(openPersonalPage:) forControlEvents:UIControlEventTouchUpInside];
            [self getImageByUserIdToButton:userid picUrl:picUrl imageview:headBtn index:indexPath];
            UILabel *faburenName=(UILabel *)[cell viewWithTag:102];
            faburenName.text=[NSString stringWithFormat:@"%@ %@",[_imageItem objectForKey:@"发布人"],[_imageItem objectForKey:@"班级"]];
            UILabel *browseCount=(UILabel *)[cell viewWithTag:103];
            NSNumber *count=[_imageItem objectForKey:@"浏览次数"];
            browseCount.text=[NSString stringWithFormat:@"%d 次浏览",count.intValue+1];
        }
        else if(indexPath.row==1)
        {
            static NSString *CellIdentifier = @"itemDescriptCell";
            cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.backgroundColor=[UIColor clearColor];
            UILabel *description=(UILabel *)[cell viewWithTag:101];
            
            description.text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"描述"]];
            description.numberOfLines=0;
            description.lineBreakMode=NSLineBreakByWordWrapping;
            [description sizeToFit];
            UILabel *address=(UILabel *)[cell viewWithTag:102];
            address.text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"位置"]];
            address.numberOfLines=2;
            address.lineBreakMode=NSLineBreakByWordWrapping;
            [address sizeToFit];

            UILabel *time=(UILabel *)[cell viewWithTag:103];
            time.text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"时间"]];
            UILabel *device=(UILabel *)[cell viewWithTag:104];
            NSString *deviceStr=[_imageItem objectForKey:@"当前设备"];
            if(deviceStr!=nil && ![deviceStr isEqual:@"null"])
                device.text=[NSString stringWithFormat:@"来自:%@",deviceStr];
            else
                device.text=@"";

        }
    }
    else if(indexPath.section==2)
    {
        static NSString *CellIdentifier = @"itemPraiseCell";
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        for(UIButton *btn in cell.subviews)
        {
            if([btn isKindOfClass:[UIButton class]])
               [btn removeFromSuperview];
        }
        NSArray *praiseList=[_imageItem objectForKey:@"点赞列表"];
        if(praiseList!=nil && praiseList.count>0)
        {
            int left=10;
            for(int i=0;i<praiseList.count;i++)
            {
                if(left+i*47+40>=self.view.frame.size.width-20)
                {
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                    UIButton *moreBtn=(UIButton *)[cell viewWithTag:101];
                    if(!moreBtn)
                    {
                        moreBtn=[[UIButton alloc]initWithFrame:CGRectMake(cell.frame.size.width-30,0,30,cell.frame.size.height)];
                        [cell addSubview:moreBtn];
                        [moreBtn addTarget:self action:@selector(gotoMore) forControlEvents:UIControlEventTouchUpInside];
                    }
                    break;
                }
                
                NSDictionary *item=[praiseList objectAtIndex:i];
                UIButton *headBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+i*47, 4, 40, 40)];
                headBtn.imageView.layer.cornerRadius = headBtn.frame.size.width / 2;
                headBtn.imageView.layer.masksToBounds = YES;
                [cell addSubview:headBtn];
                NSString *userid=[item objectForKey:@"点赞人"];
                headBtn.titleLabel.text=userid;
                [headBtn addTarget:self action:@selector(openPersonalPage:) forControlEvents:UIControlEventTouchUpInside];
                NSString *picUrl=[item objectForKey:@"点赞人头像"];
                [self getImageByUserIdToButton:userid picUrl:picUrl imageview:headBtn index:indexPath];
                
            }
        }
        
    }
    else if(indexPath.section==3)
    {
        static NSString *CellIdentifier = @"itemCommentCell";
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor=[UIColor clearColor];
        
        NSArray *commList=[_imageItem objectForKey:@"评论列表"];
        if(commList!=nil && commList.count>0)
        {
            NSDictionary *item=[commList objectAtIndex:indexPath.row];
            UIButton *headBtn=(UIButton *)[cell viewWithTag:101];
            headBtn.imageView.layer.cornerRadius = headBtn.frame.size.width / 2;
            headBtn.imageView.layer.masksToBounds = YES;
            NSString *userid=[item objectForKey:@"评论人"];
            headBtn.titleLabel.text=userid;
            [headBtn addTarget:self action:@selector(openPersonalPage:) forControlEvents:UIControlEventTouchUpInside];
            NSString *picUrl=[item objectForKey:@"评论人头像"];
            [self getImageByUserIdToButton:userid picUrl:picUrl imageview:headBtn index:indexPath];
            
            DDIGifView *view=(DDIGifView *)[cell viewWithTag:102];
            
            view.minWidth=minGifViewWidth;
            view.msgContent=[NSString stringWithFormat:@"%@:%@",[item objectForKey:@"评论人姓名"],[item objectForKey:@"评论内容"]];
            
            UILabel *time=(UILabel *)[cell viewWithTag:103];
            NSString *sendtime=[CommonFunc chatDateStr:[item objectForKey:@"时间"]];
            NSString *toName=[item objectForKey:@"回复目标姓名"];
            NSString *toId=[item objectForKey:@"回复目标"];
            NSString *faburen=[_imageItem objectForKey:@"发布人唯一码"];
            if(toName!=nil && ![toId isEqualToString:faburen])
                time.text=[NSString stringWithFormat:@"%@ 回复 %@",sendtime,toName];
            else
                time.text=sendtime;
            UIButton *coverBtn=(UIButton *)[cell viewWithTag:104];
            coverBtn.titleLabel.tag=indexPath.row;
            coverBtn.backgroundColor=[UIColor clearColor];
            [coverBtn addTarget:self action:@selector(popActionSheet:) forControlEvents:UIControlEventTouchUpInside];
           
        }
    }
    return cell;
}


-(void)getImageByUserIdToButton:(NSString *)userid picUrl:(NSString *)picUrl imageview:(UIButton *)headBtn index:(NSIndexPath *)index
{
    NSString *userPic=[CommonFunc getCacheImagePath:picUrl];
    //NSString *userPic=[CommonFunc getImageSavePath:userid ifexist:YES];
    if(userPic)
    {
        UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
        /*
        CGSize newSize=CGSizeMake(80, 80);
        headImage=[headImage scaleToSize1:newSize];
        headImage=[headImage cutFromImage:CGRectMake(0, 0, 80, 80)];
         */
        [headBtn setImage:headImage forState:UIControlStateNormal];
    }
    else
    {
        [headBtn setImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
        if(picUrl && ![picUrl isEqual:[NSNull null]] && picUrl.length>0)
        {
            NSURL *url = [NSURL URLWithString:picUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=userid;
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:index forKey:@"indexPath"];
            [indexDic setObject:headBtn forKey:@"btn"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
        }
    }
}
-(void)gotoMore
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DDIPraiseDetail *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"praiseDetail"];
    NSMutableArray *albumMsgArray=[NSMutableArray array];
    NSArray *praiseArray=[_imageItem objectForKey:@"点赞列表"];
    for(NSDictionary *item in praiseArray)
    {
        AlbumMsg *newMsg=[[AlbumMsg alloc]initWithDic:item];
        newMsg.imageDic=nil;
        [albumMsgArray addObject:newMsg];
    }
    itemController.praiseList=albumMsgArray;
    [self.myNav pushViewController:itemController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *v = nil;
    if (section == 2) {
        NSArray *praiseList=[_imageItem objectForKey:@"点赞列表"];
        if(praiseList!=nil && praiseList.count>0)
        {
            v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            [v setBackgroundColor:[UIColor lightGrayColor]];
            
            UIImageView *iv=[[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 14, 12)];
            UIImage *image=[UIImage imageNamed:@"heart_fill"];
            [iv setImage:image];
            [v addSubview:iv];
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 100, 20)];
            [labelTitle setBackgroundColor:[UIColor clearColor]];
            labelTitle.font=[UIFont systemFontOfSize:13];
            labelTitle.text = [NSString stringWithFormat:@"%lu",(unsigned long)praiseList.count];
            [v addSubview:labelTitle];
        }
    }
    if (section == 3) {
        NSArray *commList=[_imageItem objectForKey:@"评论列表"];
        if(commList!=nil && commList.count>0)
        {
            v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
            [v setBackgroundColor:[UIColor lightGrayColor]];
            
            UIImageView *iv=[[UIImageView alloc]initWithFrame:CGRectMake(15, 9, 14, 12)];
            UIImage *image=[UIImage imageNamed:@"chat_fill"];
            [iv setImage:image];
            [v addSubview:iv];
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 100, 20)];
            [labelTitle setBackgroundColor:[UIColor clearColor]];
            labelTitle.font=[UIFont systemFontOfSize:13];
            labelTitle.text = [NSString stringWithFormat:@"%lu",(unsigned long)commList.count];
            [v addSubview:labelTitle];
        }
    }
    return v;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        NSArray *praiseList=[_imageItem objectForKey:@"点赞列表"];
        if(praiseList!=nil && praiseList.count>0)
            return 30;
    }
    else if(section==3)
    {
        NSArray *commList=[_imageItem objectForKey:@"评论列表"];
        if(commList!=nil && commList.count>0)
           return 30;
    }
    return 0;
}
-(void)openPersonalPage:(UIButton *)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DDIMyInforView *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"MyInforView"];
    itemController.userWeiYi=sender.titleLabel.text;
    if(sender.imageView.image)
        itemController.headImage=sender.imageView.image;
    [self.myNav pushViewController:itemController animated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"评论"])
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
                
                NSMutableArray *commonList=[NSMutableArray arrayWithArray:[_imageItem objectForKey:@"评论列表"]];
                [commonList insertObject:newItem atIndex:0];
                [_imageItem setObject:commonList forKey:@"评论列表"];
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"评论成功！"];
                [tipView showInView:self.view];
                [indexPathDic removeAllObjects];
              
                [self.tableView reloadData];
                
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                [dict setObject:@"评论" forKey:@"action"];
                [dict setObject:newItem forKey:@"commonItem"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageUpload" object:nil userInfo:dict];
            }
        }
    }
    if([request.username isEqualToString:@"举报评论"])
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
    if([request.username isEqualToString:@"删除评论"])
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
                AlbumMsg *theMsg=[[AlbumMsg alloc]initWithDic:[res objectForKey:@"返回"]];
                NSMutableArray *commonList=[NSMutableArray arrayWithArray:[_imageItem objectForKey:@"评论列表"]];
                for(NSDictionary *item in commonList)
                {
                    NSString *fromId=[item objectForKey:@"评论人"];
                    NSString *time=[item objectForKey:@"时间"];
                    NSString *content=[item objectForKey:@"评论内容"];
                    if([fromId isEqualToString:theMsg.fromId] && [time isEqualToString:theMsg.time] && [content isEqualToString:theMsg.msg])
                    {
                        [commonList removeObject:item];
                        break;
                    }
                }
                [_imageItem setObject:commonList forKey:@"评论列表"];
                [indexPathDic removeAllObjects];
                if(commonList.count>0)
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
                else
                    [self.tableView reloadData];
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"评论删除成功！"];
                [tipView showInView:self.view];
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                [dict setObject:@"删除评论" forKey:@"action"];
                [dict setObject:theMsg forKey:@"commonItem"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageUpload" object:nil userInfo:dict];
                
            }
        }
    }
    else
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSString *path=[CommonFunc getImageSavePath:request.username ifexist:NO];
            [datas writeToFile:path atomically:YES];
            [CommonFunc setCacheImagePath:request.url.absoluteString localPath:path];
            NSDictionary *indexDic=request.userInfo;
            
            UIButton *btn=[indexDic objectForKey:@"btn"];
            if(btn)
            {
                [btn setImage:headImage forState:UIControlStateNormal];
            }
            else
            {
                NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
                if(indexPath)
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }
    if([requestArray containsObject:request])
        [requestArray removeObjectIdenticalTo:request];
    request=nil;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UIImage* image;
        NSString *iconName=[_imageItem objectForKey:@"文件名"];
        NSString *filename=[savepath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            image=[UIImage imageWithContentsOfFile:filename];
        }
        if(image==nil)
        {
            image=[UIImage imageNamed:@"empty_photo"];
        }
        float rate=image.size.height/image.size.width;
        int width=self.view.bounds.size.width;
        int height=width*rate;
        return height;

    }
    else if(indexPath.section==1)
    {
        if(indexPath.row==0)
            return 50;
        else if(indexPath.row==1)
        {
            int height=5;
            UIFont *font=[UIFont systemFontOfSize:13];
            CGSize size=CGSizeMake(self.view.frame.size.width-16, 1000.0f);
            NSString *text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"描述"]];
            
            if(text.length==0)
                height=height+0;
            else
            {
                CGSize size1=[text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
                height=height+size1.height+5;
            }
            text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"位置"]];
            if(text.length==0)
                height=height+0;
            else
                height=height+[text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping].height+5;
            text=[NSString stringWithFormat:@"%@",[_imageItem objectForKey:@"时间"]];
            height=height+[text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping].height;
            return height;
        }
    }else if(indexPath.section==2)
    {
        NSArray *praiseList=[_imageItem objectForKey:@"点赞列表"];
        if(praiseList!=nil && praiseList.count>0)
            return 48;
    }
    else if(indexPath.section==3)
    {
        
        NSArray *commList=[_imageItem objectForKey:@"评论列表"];
        if(commList!=nil && commList.count>0)
        {
            NSNumber *num=[indexPathDic objectForKey:[NSNumber numberWithInt:(int)indexPath.row]];
            if(num==nil && self.view.frame.size.width>0)
            {
                minGifViewWidth=self.view.frame.size.width-56-10;
                if(tempview==nil)
                    tempview=[[DDIGifView alloc]initWithFrame:CGRectMake(0, 0, minGifViewWidth, 0)];
                tempview.minWidth=minGifViewWidth;
                NSArray *commList=[_imageItem objectForKey:@"评论列表"];
                NSDictionary *item=[commList objectAtIndex:indexPath.row];
                tempview.msgContent=[NSString stringWithFormat:@"%@:%@",[item objectForKey:@"评论人姓名"],[item objectForKey:@"评论内容"]];
                [indexPathDic setObject:[NSNumber numberWithFloat:tempview.frame.size.height] forKey:[NSNumber numberWithInt:(int)indexPath.row]];
                num=[indexPathDic objectForKey:[NSNumber numberWithInt:(int)indexPath.row]];
                //NSLog(@"row:%d width:%f height:%f",indexPath.row,tempview.frame.size.width,tempview.frame.size.height);
            }

            CGFloat height=num.floatValue;
            height=height+25;
            if(height<48)
                height=48;
            return height;
            
        }
    }
    return 0;
    
}
- (void)loadImagetData:(NSString *)URLPath filename:(NSString *)filename indexPath:(NSIndexPath *)indexPath
{
    // Request
    
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200)
        {
            UIImage *headImage=[[UIImage alloc]initWithData:data];
            if(headImage!=nil)
            {
                [data writeToFile:filename atomically:YES];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                NSLog(@"图片下载成功,%@",[CommonFunc getFileRealName:filename]);
            }
        }
        else
            NSLog(@"图片下载失败");
    }];
}
- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    oldPoint=scrollView.contentOffset;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint newPoint=scrollView.contentOffset;
    if(newPoint.y>oldPoint.y && !ifkeyshow && !ificonshow)
    {
        inputToolBarView.hidden=YES;
        replyTip.hidden=YES;
    }
    else
    {
        inputToolBarView.hidden=NO;
        replyTip.hidden=NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [inputToolBarView resignFirstResponder];
    [self setEditing:NO animated:YES];
}
#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    if(!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = textView.contentSize.height;

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(text.length==0)
    {
        NSRange range=textView.selectedRange;
        if(range.location==0)
            return YES;
        NSString *lastChar=[textView.text substringWithRange:NSMakeRange(range.location-1, 1)];
        
        if(range.location>=6 && [lastChar isEqualToString:@"]"])
        {
            range.location-=6;
            range.length=6;
            NSString *str=[textView.text substringWithRange:range];
            str=[str substringWithRange:NSMakeRange(1, 4)];
            NSArray *imageArray=[CommonFunc emojiStringArray];
            if([imageArray containsObject:str])
            {
                NSString *newStr=[textView.text substringToIndex:range.location];
                if(textView.text.length>range.location+6)
                {
                    textView.text=[newStr stringByAppendingString:[textView.text substringFromIndex:range.location+6]];
                    [textView setSelectedRange:NSMakeRange(range.location, 0)];
                }
                else
                    textView.text=newStr;
                
                [self textViewDidChange:inputToolBarView.textView];
                return NO;
            }
            
        }
    }
    if (range.location>=150)
    {
        //控制输入文本的长度
        if(text.length>0)
            return  NO;
        else
        {
            
            return YES;
        }
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat maxHeight = [JSMessageInputView maxHeight];
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if(changeInHeight != 0.0f) {
        //        if(!isShrinking)
        //            [self.inputToolBarView adjustTextViewHeightBy:changeInHeight];
        
        [UIView animateWithDuration:0.25f
                         animations:^{
                             UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,
                                                                    0.0f,
                                                                    self.tableView.contentInset.bottom + changeInHeight,
                                                                    0.0f);
                             
                             self.tableView.contentInset = insets;
                             self.tableView.scrollIndicatorInsets = insets;
                            
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [inputToolBarView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = inputToolBarView.frame;
                             inputToolBarView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [inputToolBarView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect frame=replyTip.frame;
                             frame.origin.y=inputToolBarView.frame.origin.y-24;
                             replyTip.frame=frame;
                         }
                         completion:^(BOOL finished) {
                         }];
        
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
    
    inputToolBarView.sendButton.enabled = ([textView.text trimWhitespace].length > 0);
    lbCount.text=[NSString stringWithFormat:@"%lu/150",(unsigned long)inputToolBarView.textView.text.length];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    //static CGFloat normalKeyboardHeight = 216.0f;
    
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //CGFloat distanceToMove = kbSize.height - normalKeyboardHeight;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect newFrame=inputToolBarView.frame;
    newFrame.origin.y=self.view.frame.size.height-inputToolBarView.frame.size.height-kbSize.height;
    inputToolBarView.frame=newFrame;
    inputToolBarView.hidden=NO;
    replyTip.hidden=NO;
    CGRect frame=replyTip.frame;
    frame.origin.y=inputToolBarView.frame.origin.y-24;
    replyTip.frame=frame;
    [UIView commitAnimations];
    ifkeyshow=true;
    if(ificonshow)
    {
        CGRect frame=_emtionV.frame;
        frame.origin.y=self.view.frame.size.height;
        _emtionV.frame=frame;
        ificonshow=false;
    }
    

    curKeyboardHeight=kbSize.height;
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    CGRect newFrame=inputToolBarView.frame;
    newFrame.origin.y=self.view.frame.size.height-inputToolBarView.frame.size.height;
    inputToolBarView.frame=newFrame;
    inputToolBarView.hidden=NO;
    replyTip.hidden=NO;
    [self.view bringSubviewToFront:inputToolBarView];
    CGRect frame=replyTip.frame;
    frame.origin.y=inputToolBarView.frame.origin.y-24;
    replyTip.frame=frame;
    [UIView commitAnimations];
    ifkeyshow=false;
}
-(void) popActionSheet:(UIButton *)sender
{
    NSInteger row=sender.titleLabel.tag;
    NSArray *commList=[_imageItem objectForKey:@"评论列表"];
    NSDictionary *item=[commList objectAtIndex:row];
    NSString *pinglunren=[item objectForKey:@"评论人"];
    NSString *userid=[teacherInfoDic objectForKey:@"用户唯一码"];
    UIActionSheet *as;
    if([userid isEqualToString:pinglunren])
    {
        as=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    }
    else
    {
        as=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"举报", nil];
    }
    as.tag=row;
    [as showInView:[UIApplication sharedApplication].keyWindow];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger row=actionSheet.tag;
    NSArray *commList=[_imageItem objectForKey:@"评论列表"];
    NSDictionary *item=[commList objectAtIndex:row];
    NSString *toName=[item objectForKey:@"评论人姓名"];
    NSString *btnTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([btnTitle isEqualToString:@"回复"])
    {
        lbTiptitle.text=[NSString stringWithFormat:@"回复:%@",toName];
        [replyTip removeFromSuperview];
        [self.view addSubview:replyTip];
        replyId=[item objectForKey:@"评论人"];
        inputToolBarView.hidden=NO;
        replyTip.hidden=NO;
        [inputToolBarView.textView becomeFirstResponder];
    }
    else if([btnTitle isEqualToString:@"举报"])
    {
        [self sendCommontAction:@"举报评论" item:item];
    }
    else if([btnTitle isEqualToString:@"删除"])
    {
        [self sendCommontAction:@"删除评论" item:item];
    }
}
-(void)sendCommontAction:(NSString *)action item:(NSDictionary *)item
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:action forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[_imageItem objectForKey:@"文件名"] forKey:@"imageId"];
    [dic setObject:[item objectForKey:@"评论人"] forKey:@"评论人"];
    [dic setObject:[item objectForKey:@"时间"] forKey:@"评论时间"];
    [dic setObject:[item objectForKey:@"评论内容"] forKey:@"评论内容"];
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
@end
