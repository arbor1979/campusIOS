//
//  DDIKaoQinDetail.m
//  掌上校园
//
//  Created by yons on 14-3-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIKaoQinDetail.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
@interface DDIKaoQinDetail ()

@end

@implementation DDIKaoQinDetail


- (void)viewDidLoad
{
    [super viewDidLoad];
    savePath=[CommonFunc createPath:@"/utils/"];
    requestArray=[NSMutableArray array];
    detailArray= [NSArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    [self loadDetailData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadDetailData
{
   
    NSURL *url = [NSURL URLWithString:[self.interfaceUrl URLEncodedString]];
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
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取明细数据" message:nil timeout:0 dismissible:NO];
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
        {
            detailArray=[dict objectForKey:@"考勤数值"];
        }
        if(!dict || !detailArray || detailArray.count==0)
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
-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return detailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"detailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *titleImage=[item objectForKey:@"图片背景"];
    [self loadImageAndSave:titleImage parentView:cell.imageView indexPath:indexPath];
    cell.textLabel.text=[item objectForKey:@"第一行"];
    cell.detailTextLabel.text=[item objectForKey:@"第二行"];
    NSString *rightType=[item objectForKey:@"右边显示类型"];
    cell.accessoryView=nil;
    UILabel *rightLbl=(UILabel *)[cell viewWithTag:11];
    rightLbl.text=@"";
    
    if([rightType isEqualToString:@"图片"])
    {
        NSString *rightUrl=[item objectForKey:@"右边显示内容"];
        UIImageView *rightImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        rightImage.contentMode=UIViewContentModeScaleToFill;
        [self loadImageAndSave:rightUrl parentView:rightImage indexPath:indexPath];
        cell.accessoryView=rightImage;
    }
    else
    {
        rightLbl.text=[item objectForKey:@"右边显示内容"];
    }
    
    return cell;
}

-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIView *)parentView indexPath:(NSIndexPath *)indexPath
{
    if(imageUrl && imageUrl.length>0)
    {
        NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
