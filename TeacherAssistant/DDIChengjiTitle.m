//
//  DDIChengjiTitle.m
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIChengjiTitle.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码

@interface DDIChengjiTitle ()

@end

@implementation DDIChengjiTitle



- (void)viewDidLoad
{
    [super viewDidLoad];
    savePath=[CommonFunc createPath:@"/utils/"];
    requestArray=[NSMutableArray array];
    titleArray= [NSArray array];
    emptyPhoto=[UIImage imageNamed:@"empty_photo"];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    mygreen=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1.0f];
    page=0;
    allnum=0;
    isLoadingMore=false;
    _reloading=false;
    //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44 - 20, [UIScreen mainScreen].bounds.size.height - 44 - 20, 44, 44);
    //VCFloatingActionButton *addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"plus"] andPressedImage:[UIImage imageNamed:@"cross"] withScrollview:self.tableView];
    //addButton.hideWhileScrolling = YES;
    //addButton.bAsButton=true;
    //addButton.imageArray = @[@"cross"];
    //addButton.labelArray = @[@"Facebook"];
    [self loadTitleData:true page:page];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifiReload)
                                                 name:@"needRefreshTitle"
                                               object:nil];
    
    CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44 - 20, [UIScreen mainScreen].bounds.size.height - 100, 44, 44);
    filterBtn=[[UIButton alloc] initWithFrame:floatFrame];
    [filterBtn addTarget:self action:@selector(popFilterDlg) forControlEvents:UIControlEventTouchUpInside];
    UIImage *normalImage=[UIImage imageNamed:@"plus"];
    UIImage *pressImage=[UIImage imageNamed:@"cross"];
    [filterBtn setImage:normalImage forState:UIControlStateNormal];
    [filterBtn setImage:pressImage forState:UIControlStateHighlighted];
    filterBtn.hidden=YES;
    mainWindow = [UIApplication sharedApplication].keyWindow;
}
-(void)popFilterDlg
{
    if(filterDlg.isFirstResponder)
        return;
    if(filterDlg==nil)
    {
        NSString *message=@"";
        int height=50;
        for(int i=0;i<filterArr.count;i++)
        {
            NSDictionary *item=[filterArr objectAtIndex:i];
            
            if([[item objectForKey:@"类型"] isEqualToString:@"文本框"])
                height+=30;
            else if([[item objectForKey:@"类型"] isEqualToString:@"下拉框"])
                height+=120;
            
        }
        for(int i=0;i<ceil(height/20);i++)
        {
            message=[message stringByAppendingString:@"\n"];
        }
        filterDlg = [UIPopoverDlg alertControllerWithTitle:@"过滤条件" message:message preferredStyle:UIAlertControllerStyleAlert];
        [filterDlg addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
            
        }]];
        [filterDlg addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            self->filterArr=[self->filterDlg saveFilterValue];
            [self loadTitleData:true page:0];
        }]];
        
    }
    [filterDlg initSubViews:filterArr];
    [self presentViewController:filterDlg animated:YES completion:nil];
     
    
}
-(void)notifiReload
{
    [self loadTitleData:false page:page];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [mainWindow addSubview:filterBtn];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [filterBtn removeFromSuperview];
}
-(void)dealloc
{
    filterBtn=nil;
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshTitle" object:nil];
}
-(void)loadTitleData:(Boolean) showtip page:(int) page
{
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    if(filterArr!=nil && filterArr.count>0)
       [dic setObject:filterArr forKey:@"过滤条件"];
    request.username=@"初始化标题";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    if(showtip)
    {
        alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
        [alertTip showInView:self.view];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"初始化标题"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        if(data==nil)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
            return;
        }
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            if(![[dict objectForKey:@"成绩数值"] isEqual:[NSNull null]])
                titleArray=[dict objectForKey:@"成绩数值"];
            else
                titleArray=[NSArray array];
        }
        if(!dict || !titleArray || titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
        }
        NSString *pagestr=[dict objectForKey:@"page"];
        if(pagestr!=nil)
            page=pagestr.intValue;
        NSString *allnumstr=[dict objectForKey:@"allnum"];
        if(allnumstr!=nil)
            allnum=allnumstr.intValue;
        [self.tableView reloadData];
        filterArr=[NSMutableArray arrayWithArray:[dict objectForKey:@"过滤条件"]];
        if(filterArr==nil)
            filterArr=[NSMutableArray array];
        NSString *btName=[dict objectForKey:@"右上按钮"];
        if(btName!=nil)
        {
            
            btnUrl=[dict objectForKey:@"右上按钮URL"];
            btnSubmit=[dict objectForKey:@"右上按钮Submit"];
            if(btnSubmit==nil || btnSubmit.length==0)
                btnSubmit=@"否";
            UIBarButtonItem *rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleDone target:self action:@selector(addNew)];
            
            self.navigationItem.rightBarButtonItem=rightBtn;
        }
        [self performSelector:@selector(doneLoadingTableViewData:) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(resetIsloadingMore) withObject:nil afterDelay:0.5f];
        
        if(filterArr.count>0)
            filterBtn.hidden=NO;
        else
            filterBtn.hidden=YES;
    }
    else if([request.username isEqualToString:@"右上按钮提交"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict && [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作成功"];
            [tipView showInView:self.view];
            NSString *autoClose=[dict objectForKey:@"自动关闭"];
            if([autoClose isEqualToString:@"是"])
            {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
            }
            else
            {
                [self loadTitleData:false page:page];

            }
        }
    }
    else if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSDictionary *indexDic=request.userInfo;
            NSString *filename=[indexDic objectForKey:@"filename"];
            [datas writeToFile:filename atomically:YES];
            //UIView *parent=[indexDic objectForKey:@"parentView"];
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            headImage=[headImage scaleToSize:CGSizeMake(42, 42)];
            /*
            UIActivityIndicatorView *aiv=[indexDic objectForKey:@"aiv"];
            if(aiv)
            {
                [aiv stopAnimating];
                [aiv removeFromSuperview];
            }
            */
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    else if([request.username isEqualToString:@"附加菜单"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict && [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作成功"];
            [tipView showInView:self.view];
            [self loadTitleData:false page:page];
        }
    }
    
}

-(void)addNew
{
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSArray *tmparray=[urlStr componentsSeparatedByString:@"?"];
    urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:btnUrl];
    if(btnSubmit!=nil && [btnSubmit isEqualToString:@"是"])
    {
        NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        request.username=@"右上按钮提交";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
    else
    {
        DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
        detail.title=self.title;
        detail.interfaceUrl=urlStr;
        detail.examStatus=@"进行中";
        detail.key=-1;
        detail.parentTitleArray=nil;
        detail.autoClose=@"是";
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([request.username isEqualToString:@"下载图片"])
    {
        NSDictionary *dic=request.userInfo;
        UIActivityIndicatorView *aiv=[dic objectForKey:@"aiv"];
        if(aiv)
        {
            UIView *view=aiv.superview;
            if([view isKindOfClass:[UIImageView class]])
            {
                UIImageView *parent=(UIImageView *)view;
                parent.image=emptyPhoto;
                
            }
            [aiv removeFromSuperview];
        }
        
    }
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
        [tipView show];
        isLoadingMore=false;
        _reloading=false;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *titleImage=[item objectForKey:@"图标"];
    cell.imageView.image=nil;
    for(UIView *subview in cell.imageView.subviews)
        [subview removeFromSuperview];
    [self loadImageAndSave:titleImage parentView:cell.imageView indexPath:indexPath];
    
    cell.textLabel.text=[item objectForKey:@"第一行"];
    cell.detailTextLabel.layer.cornerRadius =5.0;
    cell.detailTextLabel.backgroundColor=mygreen;
    cell.detailTextLabel.textColor=[UIColor whiteColor];
    NSString *theColor=[item objectForKey:@"颜色"];
    if(theColor!=nil)
    {
        if([theColor isEqualToString:@"red"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:175/255.0f green:40/255.0f blue:49/255.0f alpha:1.0f];
        }
        else if([theColor isEqualToString:@"blue"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:40/255.0f green:49/255.0f blue:175/255.0f alpha:1.0f];
        }
        else if([theColor isEqualToString:@"brown"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:175/255.0f green:98/255.0f blue:40/255.0f alpha:1.0f];
        }
        else if([theColor isEqualToString:@"pink"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:212/255.0f green:64/255.0f blue:148/255.0f alpha:1.0f];
        }
        else if([theColor isEqualToString:@"goldenrod"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:218/255.0f green:165/255.0f blue:32/255.0f alpha:1.0f];
        }
        else if([theColor isEqualToString:@"blueviolet"])
        {
            cell.detailTextLabel.backgroundColor=[UIColor colorWithRed:138/255.0f green:43/255.0f blue:226/255.0f alpha:1.0f];
        }
    }
        
    
    cell.detailTextLabel.text=[NSString stringWithFormat:@" %@ ",[item objectForKey:@"第二行左"]];
    UILabel *rightLbl=(UILabel *)[cell viewWithTag:101];
    
    rightLbl.text=[item objectForKey:@"第二行右"];
    
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    if(!detailURL || detailURL.length==0)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    NSDictionary *addmenu=[item objectForKey:@"附加菜单"];
    if(addmenu!=nil && addmenu.count>0)
    {
        UIButton *addmenubtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [addmenubtn setBackgroundImage:[UIImage imageNamed:@"pop_menu"] forState:UIControlStateNormal];
        cell.accessoryView=addmenubtn;
        [addmenubtn addTarget:self action:@selector(popMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
        cell.accessoryView=nil;
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        
    }
    return cell;
}
-(void)popMenu:(UIButton *)btn
{
    UIView *tmpview=btn.superview;
    while(![tmpview isKindOfClass:[UITableViewCell class]])
        tmpview=tmpview.superview;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:(UITableViewCell *)tmpview];
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    NSDictionary *addmenu=[item objectForKey:@"附加菜单"];
    NSArray *keys=addmenu.allKeys;
    for(NSString *key in keys)
    {
        if(key!=nil && key.length>0)
        {
            NSInteger alertstyle=UIAlertViewStyleDefault;
            if([key isEqualToString:@"删除"])
                alertstyle=UIAlertActionStyleDestructive;
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:key style:alertstyle handler:^(UIAlertAction *action) {
                NSArray *tmpArray=[self->_interfaceUrl componentsSeparatedByString:@"?"];
                NSString *strUrl=[addmenu objectForKey:key];
                strUrl=[tmpArray[0] stringByAppendingString:strUrl];
                NSURL *url = [NSURL URLWithString:strUrl];
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                NSError *error;
                NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
                [dic setObject:kUserIndentify forKey:@"用户较验码"];
                NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
                [dic setObject:timeStamp forKey:@"DATETIME"];
                request.username=@"附加菜单";
                NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                postStr=[GTMBase64 base64StringBystring:postStr];
                [request setPostValue:postStr forKey:@"DATA"];
                [request setDelegate:self];
                [request setTag:indexPath.row];
                [request startAsynchronous];
                [self->requestArray addObject:request];
                self->alertTip = [[OLGhostAlertView alloc] initWithTitle:[@"正在执行" stringByAppendingString:key] message:nil timeout:0 dismissible:NO];
                [self->alertTip show];
            }];
            [alertController addAction:otherAction];
        }
    }
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIView *)parentView indexPath:(NSIndexPath *)indexPath
{
    if(imageUrl && imageUrl.length>0)
    {
        NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
        if(filename.length==0 && sepArray.count>1)
            filename=[sepArray objectAtIndex:sepArray.count-2];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            img=[img scaleToSize:CGSizeMake(42, 42)];
            if([parentView isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)parentView;
                [btn setBackgroundImage:img forState:UIControlStateNormal];
                
            }
            else if([parentView isKindOfClass:[UIImageView class]])
            {
                UIImageView *iv=(UIImageView *)parentView;
                iv.image=img;
            }
        }
        else
        {
            /*
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(parentView.bounds.size.width/2-16, parentView.bounds.size.height/2-16, 32, 32)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [parentView addSubview:aiv];
            [aiv startAnimating];
            */
            imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:imageUrl];
            /*
            for(ASIHTTPRequest *item in requestArray)
            {
                if([item.url isEqual:url])
                    return;
            }
            */
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:filename forKey:@"filename"];
            //[indexDic setObject:aiv forKey:@"aiv"];
            //[indexDic setObject:parentView forKey:@"parentView"];
            [indexDic setObject:indexPath forKey:@"indexPath"];
            request.userInfo=indexDic;
            request.timeOutSeconds=10;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    NSString *moban=[item objectForKey:@"模板"];
    NSString *mobanLevel=[item objectForKey:@"模板级别"];
    if(detailURL && detailURL.length>0)
    {
        if(!moban)
            moban=@"成绩";
        if([moban isEqualToString:@"成绩"])
        {
            if([mobanLevel isEqualToString:@"main"])
            {
                DDIChengjiTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiMain"];
                chengjiMain.title=self.title;
                NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
                //NSString *realname=[CommonFunc getFileRealName:[tmparray objectAtIndex:0]];
                detailURL=[NSString stringWithFormat:@"%@%@",[tmparray objectAtIndex:0],detailURL];
                chengjiMain.interfaceUrl=detailURL;
                [self.navigationController pushViewController:chengjiMain animated:YES];
            }
            else
              [self performSegueWithIdentifier:@"chengjiDetail" sender:indexPath];
        }
        else if([moban isEqualToString:@"调查问卷"])
        {
            NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
            //NSString *realname=[CommonFunc getFileRealName:[tmparray objectAtIndex:0]];
            detailURL=[NSString stringWithFormat:@"%@%@",[tmparray objectAtIndex:0],detailURL];
            if([mobanLevel isEqualToString:@"main"])
            {
                DDIWenJuanTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanMain"];
                chengjiMain.title=self.title;
                chengjiMain.interfaceUrl=detailURL;
                [self.navigationController pushViewController:chengjiMain animated:YES];
            }
            else
            {
                DDIWenJuanDetail *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
                chengjiMain.title=self.title;
                //NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,detailURL];
                chengjiMain.interfaceUrl=detailURL;
                [self.navigationController pushViewController:chengjiMain animated:YES];
            }
        }
        else if([moban isEqualToString:@"通知"])
        {
            NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
            //NSString *realname=[CommonFunc getFileRealName:[tmparray objectAtIndex:0]];
            detailURL=[NSString stringWithFormat:@"%@%@",[tmparray objectAtIndex:0],detailURL];
            DDINewsDetail *dest=[self.storyboard instantiateViewControllerWithIdentifier:@"newsDetail"];
            News *newone=[[News alloc] init];
            newone.newsid=0;
            newone.url=detailURL;
            dest.title=self.title;
            //NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,detailURL];
            dest.news=newone;
            [self.navigationController pushViewController:dest animated:YES];
        }
        else if([moban isEqualToString:@"浏览器"])
        {
            DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
            controller.navigationItem.title=self.title;
            NSArray *tmparray=[detailURL componentsSeparatedByString:@"?"];
            NSString *jumpurl;
            if(tmparray.count>1)
                jumpurl=[NSString stringWithFormat:@"%@&jiaoyanma=%@",detailURL,kUserIndentify];
            else
                jumpurl=[NSString stringWithFormat:@"%@?jiaoyanma=%@",detailURL,kUserIndentify];
            controller.urlStr=jumpurl;
            [self.navigationController pushViewController:controller animated:YES];
        }
            

    }
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath=(NSIndexPath *)sender;
    NSDictionary *item=[titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    //NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    NSString *urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:detailURL];
    DDIChengjiDetail *detial=segue.destinationViewController;
    detial.title=[item objectForKey:@"第一行"];
    detial.interfaceUrl=urlStr;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    float reload_distance = 15;
    if(y > h + reload_distance) {
        //NSLog(@"load more rows");
        
        if(!isLoadingMore && titleArray.count<allnum)
        {
            isLoadingMore=true;
            [self loadTitleData:false page:page+1];
        }
        
    }
    if(filterBtn && filterArr && filterArr.count>0)
    {
        //NSLog(@"pos: %f of %d", offset.y, lastPosition);
        
        if(lastPosition-offset.y>25 || offset.y==-88)
        {
            filterBtn.hidden=NO;
            lastPosition=offset.y;
        }
        else if(offset.y-lastPosition>25)
        {
            filterBtn.hidden=YES;
            lastPosition=offset.y;
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
    [self loadTitleData:false page:0];

}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}


- (void)doneLoadingTableViewData:(NSNumber *)newcount
{
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}
-(void)resetIsloadingMore
{
    isLoadingMore=false;
}

@end
