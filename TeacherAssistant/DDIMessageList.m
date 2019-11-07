//
//  DDIMessageList.m
//  老师助手
//
//  Created by yons on 13-12-31.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIMessageList.h"
extern Boolean kIOS7;
extern NSMutableDictionary *userInfoDic;//课表数据
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern NSDictionary *LinkMandic;//联系人数据
extern int kUserType;
extern DDIDataModel *datam;
extern int kSchoolId;
@interface DDIMessageList ()

@end

@implementation DDIMessageList


- (void)viewDidLoad
{
    [super viewDidLoad];
    _headImageDic=[[NSMutableDictionary alloc]init];
 
    _requestArray=[[NSMutableArray alloc]init];
    _curMaxId=0;
    _unknowMan=[UIImage imageNamed:@"unknowMan"];
    groupImage=[UIImage imageNamed:@"group"];
    _msgList=[[NSMutableArray alloc]init];
    //_aTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewMessageFromDB:)
                                                 name:@"newMessageReach"
                                               object:nil];
    
    //用户自己的头像
    NSString *userWeiYi=[teacherInfoDic objectForKey:@"用户唯一码"];
    NSString *picPath=[CommonFunc getImageSavePath:userWeiYi ifexist:YES];
    if(picPath==nil)
    {
        NSString *urlStr=[teacherInfoDic objectForKey:@"用户头像"];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=userWeiYi;
        [request setDelegate:self];
        [request startAsynchronous];
        [_requestArray addObject:request];
    }
    
    //在这里创建搜索栏和搜索显示控制器
    self.searchBar=[[UISearchBar  alloc] initWithFrame:CGRectMake(0.0f, 0.0f,320, 44)];
    self.searchBar.placeholder=[NSString stringWithCString:"请输入姓名搜索"  encoding: NSUTF8StringEncoding];
    self.tableView.tableHeaderView=self.searchBar;
    
    
    self.searchDc=[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDc.searchResultsDataSource=self;
    self.searchDc.searchResultsDelegate=self;
    self.searchDc.delegate=self;
    [self.searchDc  setActive:NO];
    
    broadCastBtn=[[UIBarButtonItem alloc]initWithTitle:@"群发" style:UIBarButtonItemStyleDone target:self action:@selector(broadCastMsg:)];
    
}
-(void)broadCastMsg:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"gotoMultiSel" sender:sender];
}
-(void)viewDidAppear:(BOOL)animated
{

    self.parentViewController.navigationItem.title=@"消息";
    self.parentViewController.navigationItem.rightBarButtonItem=broadCastBtn;
    _curMaxId=0;
    [_msgList removeAllObjects];
    [self getNewMessageFromDB:nil];
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
    [super viewDidDisappear:animated];
}
- (void)getNewMessageFromDB:(NSNotification*)notification
{
    NSArray *newMsgList=[datam queryLastMsgGroupByUser:_curMaxId];
    for (int i=(int)newMsgList.count-1; i>=0; i--)
    {
        NSDictionary *item1=[newMsgList objectAtIndex:i];
        NSString *respondUser1=[item1 objectForKey:@"respondUser"];
        
        for(int j=0;j<_msgList.count;j++)
        {
            NSDictionary *item2=[_msgList objectAtIndex:j];
            NSString *respondUser2=[item2 objectForKey:@"respondUser"];
            if([respondUser1 isEqualToString:respondUser2])
            {
                [_msgList removeObjectAtIndex:j];
                break;
            }
        }
        [_msgList insertObject:[newMsgList objectAtIndex:i] atIndex:0];
    }
    [self getHeadImageList:newMsgList];
    [self refreshTableAndBadge];
    [self getUnReadNum];
}
-(void)refreshTableAndBadge
{
    
    [self.tableView reloadData];
}
-(void) getUnReadNum
{
    int allUnRead=0;
    for(int i=0;i<_msgList.count;i++)
    {
        NSDictionary *item=[_msgList objectAtIndex:i];
        NSNumber *unRead=[item objectForKey:@"unRead"];
        NSNumber *ifReceive=[item objectForKey:@"ifReceive"];
        if(unRead!=nil && ifReceive.intValue==1)
            allUnRead=allUnRead+unRead.intValue;
    }
    if(allUnRead>0)
        self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d",allUnRead];
    else
        self.tabBarItem.badgeValue=nil;
}
-(void) getHeadImageList:(NSArray *)newMsgList
{
    for(int i=0;i<newMsgList.count;i++)
    {
        
        //获取已保存的头像
        NSDictionary *item=[newMsgList objectAtIndex:i];
        if(i==0)
            _curMaxId=[(NSNumber *)[item objectForKey:@"rowid"] intValue];
        NSString *respondUser=[item objectForKey:@"respondUser"];
        NSArray *destArray=[respondUser componentsSeparatedByString:@","];
        if(destArray.count>1)
        {
            [_headImageDic setObject:groupImage forKey:respondUser];
            continue;
        }
        
    }
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *datas = [request responseData];
    UIImage *img=[[UIImage alloc]initWithData:datas];
    if(img!=nil)
    {
        NSString *savePath=[CommonFunc getImageSavePath:request.username ifexist:NO];
        [datas writeToFile:savePath atomically:YES];
        img=[img scaleToSize1:CGSizeMake(40, 40)];
        CGRect newSize=CGRectMake(0, 0,40,40);
        img=[img cutFromImage:newSize];
        [_headImageDic setObject:img forKey:request.username];
        NSIndexPath *index=[request.userInfo objectForKey:@"indexPath"];
        if(index)
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    if([_requestArray containsObject:request])
        [_requestArray removeObjectIdenticalTo:request];
    request=nil;
}
- (void)dealloc
{
    
    for(ASIHTTPRequest *req in _requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newMessageReach" object:nil];
    self.searchDc.delegate = nil;
    self.searchDc.searchResultsDelegate = nil;
    self.searchDc.searchResultsDataSource = nil;
    self.searchDc=nil;
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
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.tableView)
    {
        return _msgList.count;
    }
    else
    {
        return filteredMessages.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier1 = @"Cell1";
    UITableViewCell *cell=nil;
    
    NSMutableDictionary *item=nil;
    if (tableView == self.tableView)
    {
         cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        item=[_msgList objectAtIndex:indexPath.row];
        UIButton *btn=(UIButton *)[cell viewWithTag:104];
        if(btn==nil)
        {
            btn=[[UIButton alloc]initWithFrame:CGRectMake(15, 4, 40, 40)];
            btn.tag=104;
            [btn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            [btn.layer setMasksToBounds:YES];
            [btn.layer setCornerRadius:5.0];
            [cell addSubview:btn];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if(cell==nil)
        {
        
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier1];
            cell.textLabel.tag=11;
            cell.detailTextLabel.tag=12;
            cell.detailTextLabel.textColor=[UIColor darkGrayColor];
            UILabel *lastTime=[[UILabel alloc]initWithFrame:CGRectMake(219, 6, 81, 11)];
            lastTime.textAlignment=NSTextAlignmentRight;
            lastTime.textColor=[UIColor darkGrayColor];
            lastTime.font=[UIFont systemFontOfSize:12];
            lastTime.tag=13;
            [cell addSubview:lastTime];
            UIButton *btn=(UIButton *)[cell viewWithTag:104];
            if(btn==nil)
            {
                btn=[[UIButton alloc]initWithFrame:CGRectMake(15, 4, 40, 40)];
                btn.tag=104;
                [btn addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
                
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:5.0];
                [cell addSubview:btn];
            }
            
        }
        item=[filteredMessages objectAtIndex:indexPath.row];
    }
    //[cell.imageView.layer setMasksToBounds:YES];
    //[cell.imageView.layer setCornerRadius:5.0];
    
    
    UILabel *title=(UILabel *)[cell viewWithTag:101];
    title.text=[item objectForKey:@"respondName"];
    //UILabel *detail=(UILabel *)[cell viewWithTag:102];
    cell.detailTextLabel.text=[item objectForKey:@"msgContent"];
    NSString *msgType=[item objectForKey:@"msgType"];
    if([msgType isEqualToString:@"image"])
        cell.detailTextLabel.text=@"[图片]";
    UILabel *lastTime=(UILabel *)[cell viewWithTag:103];
    lastTime.text=[item objectForKey:@"sendTime"];
    
    NSString *respondUser=[item objectForKey:@"respondUser"];
    
    UIImage *img=[_headImageDic objectForKey:respondUser];
    if(img==nil)
    {
        NSString *picPath=[CommonFunc getImageSavePath:respondUser ifexist:YES];
        if(picPath!=nil)
        {
            img=[UIImage imageWithContentsOfFile:picPath];
            img=[img scaleToSize1:CGSizeMake(40, 40)];
            CGRect newSize=CGRectMake(0, 0,40,40);
            img=[img cutFromImage:newSize];
            [_headImageDic setObject:img forKey:respondUser];
        }
        else
        {
            img=_unknowMan;
            
            NSString *urlStr=[item objectForKey:@"respondUserImage"];
            if(urlStr!=nil && urlStr.length>0 && ![urlStr isEqualToString:@"<null>"])
            {
                NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [_requestArray addObject:request];
                request.username=respondUser;
                request.userInfo=[NSDictionary dictionaryWithObject:indexPath forKey:@"indexPath"];
                [request setDelegate:self];
                [request startAsynchronous];
            }
            
        }
    }
    cell.imageView.image=img;
    
    UIButton *btn=(UIButton *)[cell viewWithTag:104];
    //[btn setImage:img forState:UIControlStateNormal];
    btn.titleLabel.text=[item objectForKey:@"respondUser"];
    btn.frame=cell.imageView.frame;
    [cell bringSubviewToFront:btn];
    
    NSNumber *unRead=[item objectForKey:@"unRead"];
    NSNumber *ifReceive=[item objectForKey:@"ifReceive"];
    JSBadgeView *badgeView=nil;
    for(id item in cell.imageView.subviews)
    {
        if([item isKindOfClass:[JSBadgeView class]])
        {
            badgeView=item;
            break;
        }
    }
    if(badgeView==nil)
    {
        badgeView = [[JSBadgeView alloc] initWithParentView:cell.imageView alignment:JSBadgeViewAlignmentTopRight];
        
    }
    badgeView.badgePositionAdjustment=CGPointMake(0,5);
    if(unRead.intValue>0 && ifReceive.intValue==1)
        badgeView.badgeText = [NSString stringWithFormat:@"%d",unRead.intValue];
    else
        badgeView.badgeText =nil;
        
    return cell;
}
-(void)showUserInfo:(UIButton *)sender
{
    NSString *text=sender.titleLabel.text;
    NSArray *textArray=[text componentsSeparatedByString:@"_"];
    int userSchoolId=[[textArray objectAtIndex:6] intValue];
    if([[textArray objectAtIndex:1] isEqualToString:@"学生"] && kUserType==1 && kSchoolId==userSchoolId)
    {
        [self performSegueWithIdentifier:@"showStudentInfo" sender:sender];
    }
    else
        [self performSegueWithIdentifier:@"teacherInfo" sender:sender];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"gotoChat" sender:cell];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if([segue.identifier isEqualToString:@"teacherInfo"])
    {
        DDIMyInforView *view=segue.destinationViewController;
        NSArray *destArray=[btn.titleLabel.text componentsSeparatedByString:@","];
        view.userWeiYi=[destArray objectAtIndex:0];
    }else if([segue.identifier isEqualToString:@"showStudentInfo"])
    {
        //DDIStudentInfo *view=segue.destinationViewController;
        DDIMyInforView *view=segue.destinationViewController;
        NSArray *destArray=[btn.titleLabel.text componentsSeparatedByString:@","];
        view.userWeiYi=[destArray objectAtIndex:0];
    }
    else if([segue.identifier isEqualToString:@"gotoChat"])
    {
        UITableViewCell *cell=(UITableViewCell *)sender;
        NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
        NSMutableDictionary *item=[_msgList objectAtIndex:indexPath.row];
        NSString *respondUser=[item objectForKey:@"respondUser"];
        NSString *respondName=[item objectForKey:@"respondName"];
        DDIChatView *chatView=segue.destinationViewController;
        chatView.respondName=respondName;
        chatView.respondUser=respondUser;
        [self.searchDc setActive:NO];
    }
        
}


#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    filteredMessages = _msgList;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    filteredMessages = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    filteredMessages = [_msgList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.respondName contains[cd] %@", searchString]];
    
    return YES;
}


@end
