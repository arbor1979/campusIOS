//
//  DDINewsTitle.m
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDINewsTitle.h"
extern DDIDataModel *datam;
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;//默认单点webServic
@interface DDINewsTitle ()

@end

@implementation DDINewsTitle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    savePath=[CommonFunc createPath:@"/News/"];
    requestArray=[NSMutableArray array];
    
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    unreadColor=[UIColor colorWithRed:246/255.0 green:247/255.0 blue:231/255.0 alpha:1];
    firstLoad=true;
    
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
    if(newsList.count>0)
    {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否清除所有未读状态?"
                                                             delegate:self
                                                    cancelButtonTitle:@"否"
                                               destructiveButtonTitle:@"是"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }

}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=[actionSheet cancelButtonIndex]){
        
        [datam clearUnreadNewsByTypeAndUserId:self.newsType userId:kUserIndentify];
        newsList=[datam queryNewsList:-1 newsType:self.newsType userId:kUserIndentify];
        [self.tableView reloadData];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    newsList=[datam queryNewsList:-1 newsType:self.newsType userId:kUserIndentify];
    [self.tableView reloadData];
    /*
    if(firstLoad && newsList.count>0)
    {
        NSIndexPath *index=[NSIndexPath indexPathForRow:1 inSection:newsList.count-1];
        [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
     */
    firstLoad=false;
    if(newsList.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[NSString stringWithFormat:@"没有%@",_newsType]];
        [tipView show];
    }
//    self.tableView.contentOffset=CGPointMake(0, 10000);
    [super viewDidAppear:animated];
}
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}
- (void)scrollToBottomAnimated
{
    NSInteger rows = [self.tableView numberOfSections];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:rows-1]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
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

    return newsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"titleCell";
    static NSString *CellIdentifier2 = @"detailCell";
    UITableViewCell *cell;
    News *news=[newsList objectAtIndex:indexPath.section];
    if(indexPath.row==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        
       
        
        //UIImageView *imagev=(UIImageView *)[cell viewWithTag:103];
        //UILabel *content=(UILabel *)[cell viewWithTag:104];
        for(UIView *subview in cell.contentView.subviews)
        {
            if(subview.tag>100)
                [subview removeFromSuperview];
        }
        UIFont *font=[UIFont boldSystemFontOfSize:15];
        int width=self.view.frame.size.width-35;
        
        DDIGifView *title=[[DDIGifView alloc]initWithFrame:CGRectMake(18, 10, width, 0)];
        title.minWidth=width;
        title.gifWidth=18;
        //title.imageZoom=0.8;
        title.tag=101;
        title.font=font;
        title.backgroundColor=[UIColor clearColor];
        //NSLog(@"%@",news.title);
        title.msgContent=news.title;
        
        [cell.contentView addSubview:title];
        
        UIImageView *imagev=[[UIImageView alloc]initWithFrame:CGRectMake(18, 10+title.frame.size.height+8, width, 100)];
        imagev.tag=103;
        [cell.contentView addSubview:imagev];
        UILabel *content=[[UILabel alloc]initWithFrame:CGRectMake(20, imagev.frame.origin.y+108, width, 55)];
        content.backgroundColor=[UIColor clearColor];
        content.tag=104;
        content.font=[UIFont systemFontOfSize:14];
        //content.lineBreakMode=NSLineBreakByCharWrapping;
        content.numberOfLines=0;
        [cell.contentView addSubview:content];
       
        content.text=news.content;
        if(news.image && news.image.length>0)
        {
            NSArray *sepArray=[news.image componentsSeparatedByString:@"/"];
            NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
            filename=[savePath stringByAppendingString:filename];
            if([CommonFunc fileIfExist:filename])
            {
                UIImage *img=[UIImage imageWithContentsOfFile:filename];
                float rate=img.size.height/img.size.width;
                int height=imagev.frame.size.width*rate;
                imagev.frame=CGRectMake(imagev.frame.origin.x,imagev.frame.origin.y, width, height);
                content.frame=CGRectMake(20, imagev.frame.origin.y+height+8, width, 55);
                imagev.image=img;
            }
            else
            {
                UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(imagev.bounds.size.width/2-16, imagev.bounds.size.height/2-16, 32, 32)];
                aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
                [imagev addSubview:aiv];
                [aiv startAnimating];
                
                NSURL *url = [NSURL URLWithString:news.image];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=@"下载图片";
                NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
                [indexDic setObject:filename forKey:@"filename"];
                [indexDic setObject:indexPath forKey:@"indexPath"];
                [indexDic setObject:aiv forKey:@"aiv"];
                request.userInfo=indexDic;
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
                
            }
        }
        else
        {
            imagev.image=nil;
            [content setFrame:CGRectMake(imagev.frame.origin.x,imagev.frame.origin.y,content.frame.size.width,content.frame.size.height)];
            
        }
        
    }
    else if(indexPath.row==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        cell.textLabel.text=news.time;
        
    }
    if(news.ifread==0)
        cell.backgroundColor=unreadColor;
    else
        cell.backgroundColor=[UIColor whiteColor];
    return cell;
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
   if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSDictionary *indexDic=request.userInfo;
            NSString *filename=[indexDic objectForKey:@"filename"];
            [datas writeToFile:filename atomically:YES];
            UIActivityIndicatorView *aiv=[indexDic objectForKey:@"aiv"];
            if(aiv)
            {
                [aiv stopAnimating];
                [aiv removeFromSuperview];
            }
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            NSIndexSet *indexset=[[NSIndexSet alloc]initWithIndex:indexPath.section];
            [self.tableView reloadSections:indexset withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
   else if([request.username isEqualToString:@"获取新通知"])
   {
       NSData *data = [request responseData];
       NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
       dataStr=[GTMBase64 stringByBase64String:dataStr];
       data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
       NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
       if(dict)
       {
           NSArray *tmpArray=[dict objectForKey:@"通知项"];
           NSString *newsType=self.title;
           for(NSDictionary *item in tmpArray)
           {
               NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:item];
               NSString *newUrl=[NSString stringWithFormat:@"%@",[newItem objectForKey:@"最下边一行URL"]];
               [newItem setObject:newUrl forKey:@"最下边一行URL"];
               [newItem setObject:kUserIndentify forKey:@"用户唯一码"];
               [datam insertNewsRecord:newItem newsType:newsType];
           }
           
           [self performSelector:@selector(doneLoadingTableViewData:) withObject:[NSNumber numberWithInt:(int)tmpArray.count] afterDelay:0.5];
       }
       
       
   }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        News *news=[newsList objectAtIndex:indexPath.section];
        int width=self.view.frame.size.width-35;
        UIFont *font=[UIFont boldSystemFontOfSize:15];
        if(!temptitle)
        {
            temptitle=[[DDIGifView alloc]initWithFrame:CGRectMake(18, 10, width, 0)];
            temptitle.minWidth=width;
            temptitle.font=font;
            temptitle.gifWidth=18;
        }
        temptitle.msgContent=news.title;
        int titleHeight=temptitle.frame.size.height+8;
        int imageHeight=0;
        int contentHeight=65;
        if(news.image && news.image.length>0)
        {
            NSArray *sepArray=[news.image componentsSeparatedByString:@"/"];
            NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
            filename=[savePath stringByAppendingString:filename];
            if([CommonFunc fileIfExist:filename])
            {
                UIImage *img=[UIImage imageWithContentsOfFile:filename];
                float rate=img.size.height/img.size.width;
                int height=width*rate;
                imageHeight=height+8;
            }
            else
                imageHeight=108;
        }
        return 10+titleHeight+imageHeight+contentHeight;
    }
    else
        return 32;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    News *news=[newsList objectAtIndex:indexPath.section];
    if([[[news.url substringToIndex:4] lowercaseString] isEqualToString:@"http"])
    {
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=[NSString stringWithFormat:@"%@详情",self.title];
        controller.urlStr=news.url;
        [self.navigationController pushViewController:controller animated:YES];
        if(news.ifread==0)
            [datam clearUnReadByNewsId:news.rowid];
    }
    else
    {
        NSRange range=[news.url rangeOfString:self.interfaceUrl];
        if(range.location== NSNotFound)
            news.url=[NSString stringWithFormat:@"%@%@",self.interfaceUrl,news.url];
        [self performSegueWithIdentifier:@"newsDetail" sender:news];
    }
    if(news.ifread==0)
        [self updateOANewsIfRead:news.newsid];
}
-(void)updateOANewsIfRead:(int)news_id
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[NSNumber numberWithInt:news_id]  forKey:@"news_id"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@?action=ifread",kInitURL,self.interfaceUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"同步OA已读状态";
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDINewsDetail *detial=segue.destinationViewController;
    detial.title=[NSString stringWithFormat:@"%@%@",self.title,@"详情"];
    detial.news=(News *)sender;
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	_reloading = YES;
	[self reloadTableViewDataSource];
    
    
    
	
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}
- (void)reloadTableViewDataSource
{
    int maxId=0;
    if(newsList.count>0)
    {
        News *news=[newsList objectAtIndex:0];
        maxId=news.newsid;
    }
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:[NSNumber numberWithInt:maxId]  forKey:@"LASTID"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取新通知";
    [request startAsynchronous];
    [requestArray addObject:request];
}

- (void)doneLoadingTableViewData:(NSNumber *)newcount
{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	[self.tableView reloadData];
    
    if(newcount.intValue>0)
    {
        newsList=[datam queryNewsList:-1 newsType:self.newsType userId:kUserIndentify];
        [self.tableView reloadData];
        [self.tableView scrollsToTop];
    }
}

@end
