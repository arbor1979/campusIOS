//
//  DDIDiaoChaWenJuan.m
//  掌上校园
//
//  Created by yons on 14-3-17.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIWenJuanTitle.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern Boolean kIOS7;
@interface DDIWenJuanTitle ()

@end

@implementation DDIWenJuanTitle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [super viewDidLoad];
    savePath=[CommonFunc createPath:@"/utils/"];
    requestArray=[NSMutableArray array];
    _titleArray= [NSMutableArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    [self loadTitleData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTitleData)
                                                 name:@"needRefreshTitle"
                                               object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    if(_titleArray.count>0)
        [self.tableView reloadData];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshTitle" object:nil];
}

-(void)loadTitleData
{
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"初始化标题";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    
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
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
            _titleArray=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"调查问卷数值"]];
        if(!dict || !_titleArray || _titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
        }
        else
        {
            [self.tableView reloadData];
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
            UIView *parent=[indexDic objectForKey:@"parentView"];
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            headImage=[headImage scaleToSize:CGSizeMake(42, 42)];
            if([parent isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)parent;
                [btn setBackgroundImage:headImage forState:UIControlStateNormal];
            }
            else if([parent isKindOfClass:[UIImageView class]])
            {
                UIImageView *iv=(UIImageView *)parent;
                iv.image=headImage;
            }
            
            UIActivityIndicatorView *aiv=[indexDic objectForKey:@"aiv"];
            if(aiv)
            {
                [aiv stopAnimating];
                [aiv removeFromSuperview];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item=[_titleArray objectAtIndex:indexPath.row];
    NSString *titleImage=[item objectForKey:@"图标"];
    [self loadImageAndSave:titleImage parentView:cell.imageView indexPath:indexPath];
    
    cell.textLabel.text=[item objectForKey:@"第一行"];
    cell.detailTextLabel.text=[NSString stringWithFormat:@" %@ ",[item objectForKey:@"第二行之状态"]];
    cell.detailTextLabel.textColor=[UIColor whiteColor];
    cell.detailTextLabel.layer.cornerRadius=5;
    /*
    UILabel *leftLbl=[[UILabel alloc]initWithFrame:cell.detailTextLabel.frame];
    leftLbl.font=[UIFont systemFontOfSize:12];
    [cell addSubview:leftLbl];
     */
    
    UIColor *bgcolor;
    if([[item objectForKey:@"第二行之状态"] isEqualToString:@"进行中"])
       bgcolor=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];
    else if([[item objectForKey:@"第二行之状态"] isEqualToString:@"已结束"])
       bgcolor=[UIColor colorWithRed:36/255.0 green:91/255.0 blue:177/255.0 alpha:1];
    else
        bgcolor=[UIColor colorWithRed:211/255.0 green:145/255.0 blue:43/255.0 alpha:1];
    if(kIOS7)
        cell.detailTextLabel.backgroundColor=bgcolor;
    else
    {
        cell.detailTextLabel.font=[UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.textColor=bgcolor;
    }
    
    UILabel *rightLbl=(UILabel *)[cell viewWithTag:101];
    rightLbl.text=[item objectForKey:@"第二行之日期"];
    
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    if(!detailURL || detailURL.length==0)
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIView *)parentView indexPath:(NSIndexPath *)indexPath
{
    if(imageUrl && ![imageUrl isEqual:[NSNull null]] && imageUrl.length>0)
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
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(parentView.bounds.size.width/2-16, parentView.bounds.size.height/2-16, 32, 32)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [parentView addSubview:aiv];
            [aiv startAnimating];
            imageUrl = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:imageUrl];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
            [indexDic setObject:filename forKey:@"filename"];
            [indexDic setObject:aiv forKey:@"aiv"];
            [indexDic setObject:parentView forKey:@"parentView"];
            [indexDic setObject:indexPath forKey:@"indexPath"];
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[_titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    if(detailURL && detailURL.length>0)
        [self performSegueWithIdentifier:@"wenjuanDetail" sender:indexPath];
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath=(NSIndexPath *)sender;
    NSDictionary *item=[_titleArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    urlStr=[urlStr stringByAppendingString:detailURL];
    
    
    DDIWenJuanDetail *detail=segue.destinationViewController;
    detail.title=[item objectForKey:@"第一行"];
    detail.interfaceUrl=urlStr;
    detail.examStatus=[item objectForKey:@"第二行之状态"];
    detail.key=(int)indexPath.row;
    detail.parentTitleArray=_titleArray;
    detail.autoClose=[item objectForKey:@"保存后关闭"];
}

@end
