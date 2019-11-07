//
//  DDIMultiSelLinkMan.m
//  掌上校园
//
//  Created by yons on 14-2-19.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIMultiSelLinkMan.h"
extern Boolean kIOS7;
extern NSDictionary *LinkMandic;
@interface DDIMultiSelLinkMan ()

@end

@implementation DDIMultiSelLinkMan


- (void)viewDidLoad
{
    [super viewDidLoad];
    duizhaoDic=[LinkMandic objectForKey:@"数据源_用户信息列表_对照表"];
    allLinkManArray=[LinkMandic objectForKey:@"数据源_用户信息列表"];
	selectImage=[UIImage imageNamed:@"Selected"];
    unselectImage=[UIImage imageNamed:@"Unselected"];
    selectedArray=[[NSMutableArray alloc]init];
    float height=self.view.bounds.size.height-40;
    if([UIApplication sharedApplication].statusBarFrame.size.height==44)
        height=height-88-20;
    else
        height=height-64;
    [self.mTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.mTableView.frame.size.height, self.view.bounds.size.width, 40)];
    sv  =[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width-80,40)];
    self.view.backgroundColor=[[UIColor alloc]initWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1];
    
    sv.backgroundColor =[UIColor clearColor];
    sv.pagingEnabled = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = YES;
    sv.delegate = Nil;
    [bottomView addSubview:sv];
    
    finishBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-75,4,70,32)];
    finishBtn.backgroundColor=[[UIColor alloc]initWithRed:24/255.0 green:156/255.0 blue:208/255.0 alpha:1];
    [finishBtn.layer setMasksToBounds:YES];
    [finishBtn.layer setCornerRadius:5.0];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(submitSelected) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:finishBtn];
    [self.view addSubview:bottomView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationItem.title=@"选择联系人";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TQMultistageTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        if(kIOS7)
            cell.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);

        UIButton *action = [[UIButton alloc] initWithFrame:CGRectMake(320-60, 0, 60, 44)];
        
        [action addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
         cell.accessoryView=action;
        
        
        [cell.imageView.layer setMasksToBounds:YES];
        [cell.imageView.layer setCornerRadius:5.0];
        
    }
    NSDictionary *linkman=nil;
    if(tableView==self.mTableView.tableView)
    {
        NSArray *linkManOfGroup=[self->friendDic objectForKey:self->groupArray[indexPath.section]];
        linkman=[linkManOfGroup objectAtIndex:indexPath.row];
    }
    else
        linkman=[self->filteredMessages objectAtIndex:indexPath.row];
    
    
    NSString *userid=[linkman objectForKey:@"用户唯一码"];
    NSString *userName=[linkman objectForKey:@"姓名"];
    NSString *sex=[linkman objectForKey:@"性别"];
    NSString *picUrl=[linkman objectForKey:@"用户头像"];
 
    cell.textLabel.text=userName;

    UIImage *img;
    if (img==Nil)
    {
        NSString *userPic=[CommonFunc getImageSavePath:userid ifexist:YES];
        
        if(userPic)
        {
            UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
            CGSize newSize=CGSizeMake(40, 40);
            headImage=[headImage scaleToSize1:newSize];
            headImage=[headImage cutFromImage:CGRectMake(0, 0, 40, 40)];
            cell.imageView.image=headImage;
        }
        else
        {
            if(picUrl && picUrl.length>0)
            {
                NSURL *url = [NSURL URLWithString:picUrl];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=userid;
                NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
                [indexDic setObject:indexPath forKey:@"indexPath"];
                request.userInfo=indexDic;
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
            }
            if([sex isEqualToString:@"女"])
                cell.imageView.image=imageWoman;
            else
                cell.imageView.image=imageMan;
        }
    }
    else
    {
        cell.imageView.image=img;
        
    }
    
    UIButton *btn=(UIButton *)cell.accessoryView;
    btn.titleLabel.text=userid;
    btn.titleLabel.tag=indexPath.section;
    
    if([selectedArray containsObject:userid])
        [btn setImage:selectImage forState:UIControlStateNormal];
    else
        [btn setImage:unselectImage forState:UIControlStateNormal];
    
    return cell;
    
}
-(void)detailButtonClicked:(UIButton *)sender
{

    NSString *userid=sender.titleLabel.text;
    if([selectedArray containsObject:userid])
    {
        [selectedArray removeObject:userid];
        [sender setImage:unselectImage forState:UIControlStateNormal];
    }
    else
    {
        [selectedArray addObject:userid];
        [sender setImage:selectImage forState:UIControlStateNormal];
    }
    [self updateHeadSelImage:sender.titleLabel.tag];

}
- (UIView *)mTableView:(TQMultistageTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[super mTableView:tableView viewForHeaderInSection:section];
    UIButton *selBtn=(UIButton *)[headView viewWithTag:1003];
    if(!selBtn)
    {
        selBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-100, 0, 44, 44)];
        selBtn.tag=1003;
        selBtn.titleLabel.tag=section;
        [selBtn setImage:unselectImage forState:UIControlStateNormal];
        [selBtn addTarget:self action:@selector(headSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:selBtn];
        UILabel *lblCount=(UILabel *)[headView viewWithTag:1002];
        lblCount.text=[NSString stringWithFormat:@"%d/%@",0,lblCount.text];
    }
    return headView;
}
-(void)updateHeadSelImage:(NSInteger)section
{
    BOOL flag=true;
    NSArray *linkManOfGroup=[self->friendDic objectForKey:[self->groupArray objectAtIndex:section]];
    int hasSelNum=0;
    for(int i=0;i<linkManOfGroup.count;i++)
    {
        NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
        NSString *userid=[linkman objectForKey:@"用户唯一码"];
        if(![selectedArray containsObject:userid])
            flag=false;
        else
            hasSelNum++;
    }
    UIView *headView=[self mTableView:self.mTableView viewForHeaderInSection:section];
    UIButton *selBtn=(UIButton *)[headView viewWithTag:1003];
    if(flag)
       [selBtn setImage:selectImage forState:UIControlStateNormal];
    else
       [selBtn setImage:unselectImage forState:UIControlStateNormal];
    UILabel *lblCount=(UILabel *)[headView viewWithTag:1002];
    lblCount.text=[NSString stringWithFormat:@"%d/%lu人",hasSelNum,(unsigned long)linkManOfGroup.count];
    [self reloadScrollViewContent];
}

-(void)headSelectClick:(UIButton *)sender
{
    NSInteger section=sender.titleLabel.tag;
    NSString *groupName=[self->groupArray objectAtIndex:section];
    NSArray *linkManOfGroup=[self->friendDic objectForKey:groupName];
    
    if([sender.imageView.image isEqual:selectImage])
    {

        for(int i=0;i<linkManOfGroup.count;i++)
        {
            NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
            NSString *userid=[linkman objectForKey:@"用户唯一码"];
            if(userid && [selectedArray containsObject:userid])
                [selectedArray removeObject:userid];
        }
        
    }
    else
    {

        for(int i=0;i<linkManOfGroup.count;i++)
        {
            NSDictionary *linkman=[linkManOfGroup objectAtIndex:i];
            NSString *userid=[linkman objectForKey:@"用户唯一码"];
            if(userid && ![selectedArray containsObject:userid])
                [selectedArray addObject:userid];
        }
        
    }
    NSLog(@"%@",selectedArray);
    [self updateHeadSelImage:section];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:section];
    [self.mTableView.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}
-(void)reloadScrollViewContent
{
    NSArray *subviews=[sv.subviews copy];
    for(int i=0;i<subviews.count;i++)
    {
        [[subviews objectAtIndex:i] removeFromSuperview];
    }
    for(int i=0;i<selectedArray.count;i++)
    {
        UIButton *imgv=[[UIButton alloc]initWithFrame:CGRectMake(5+i*37, 4, 32, 32)];
        [imgv.layer setMasksToBounds:YES];
        [imgv.layer setCornerRadius:5.0];
        NSString *userid=[selectedArray objectAtIndex:i];
        UIImage *img;
        if(!img)
        {
            NSString *userPic=[CommonFunc getImageSavePath:userid ifexist:YES];
            if(userPic)
            {
                UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
                CGSize newSize=CGSizeMake(32, 32);
                headImage=[headImage scaleToSize1:newSize];
                headImage=[headImage cutFromImage:CGRectMake(0, 0, 32, 32)];
                img=headImage;
            }
            else
            {
                NSNumber *key=[duizhaoDic objectForKey:userid];
                NSDictionary *linkman=[allLinkManArray objectAtIndex:key.intValue];
                if([[linkman objectForKey:@"性别"] isEqualToString:@"女"])
                    img=imageWoman;
                else
                    img=imageMan;
            }
            
        }
        [imgv setImage:img forState:UIControlStateNormal];
        imgv.titleLabel.text=userid;
        [imgv addTarget:self action:@selector(removeFromSelected:) forControlEvents:UIControlEventTouchUpInside];
        [sv addSubview:imgv];
    }
    CGSize newSize = CGSizeMake(selectedArray.count*37+10, sv.frame.size.height);
    [sv setContentSize:newSize];
    [finishBtn setTitle:[NSString stringWithFormat:@"确定(%d)",(int)selectedArray.count] forState:UIControlStateNormal];
    if(selectedArray.count>0)
        finishBtn.enabled=true;
    else
        finishBtn.enabled=false;
}
-(void)removeFromSelected:(UIButton *)sender
{
    
    [UIView animateWithDuration:0.5
         animations:^{
             sender.alpha = 0;
             [sender setFrame:CGRectMake(sender.frame.origin.x, sender.frame.origin.y-36, sender.frame.size.width, sender.frame.size.height)];
         }
         completion:^(BOOL finished) {
         
             NSString *userid=sender.titleLabel.text;
             if([self->selectedArray containsObject:userid])
             {
                 [self->selectedArray removeObject:userid];
                 [self reloadScrollViewContent];
                 [self.mTableView.tableView reloadData];
                 NSNumber *key=[self->duizhaoDic objectForKey:userid];
                 NSDictionary *linkman=[self->allLinkManArray objectAtIndex:key.intValue];
                 NSString *groupName;
                 if([[linkman objectForKey:@"用户类型"] isEqualToString:@"老师"])
                     groupName=[linkman objectForKey:@"部门"];
                 else
                     groupName=[linkman objectForKey:@"班级"];
                 int section=(int)[self->groupArray indexOfObject:groupName];
                 if(section>=0)
                     [self updateHeadSelImage:section];
             }
             
         }];
    
    
}
-(void)submitSelected
{
    [self performSegueWithIdentifier:@"gotoChat" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *userid=@"";
    
    for(int i=0;i<selectedArray.count;i++)
    {
        if(userid.length>0)
            userid=[userid stringByAppendingString:@","];
        userid=[userid stringByAppendingString:[selectedArray objectAtIndex:i]];
        
        
    }
    NSNumber *key=[duizhaoDic objectForKey:[selectedArray objectAtIndex:0]];
    NSDictionary *linkman=[allLinkManArray objectAtIndex:key.intValue];
    NSString *userName=[linkman objectForKey:@"姓名"];
    DDIChatView *chatView=segue.destinationViewController;
    chatView.respondName=[NSString stringWithFormat:@"%@等%u人",userName,(int)selectedArray.count];
    chatView.respondUser=userid;
    [self.searchDc setActive:NO];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
    UIButton *action =(UIButton *)cell.accessoryView;
    [self detailButtonClicked:action];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [super searchDisplayControllerDidEndSearch:controller];
    for(int i=0;i<groupArray.count;i++)
        [self updateHeadSelImage:i];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
