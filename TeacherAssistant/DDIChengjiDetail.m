//
//  DDIChengjiDetail.m
//  掌上校园
//
//  Created by yons on 14-3-14.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIChengjiDetail.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;
extern int kUserType;
extern NSMutableDictionary *teacherInfoDic;
@interface DDIChengjiDetail ()

@end

@implementation DDIChengjiDetail



- (void)viewDidLoad
{
    [super viewDidLoad];

    requestArray=[NSMutableArray array];
    detailArray= [NSMutableArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    //savepath=[CommonFunc createPath:@"/utils/"];
    savepath=[CommonFunc createPath:@"/classNotes/"];
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    self.interfaceUrl=urlStr;
    [self loadDetailData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDetailData)
                                                 name:@"needRefreshDetail"
                                               object:nil];
}


-(void)loadDetailData
{
    NSURL *url = [NSURL URLWithString:self.interfaceUrl];
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
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    //alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取明细数据" message:nil timeout:0 dismissible:NO];
    //[alertTip showInView:self.view];
    
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
            leftWidth=[dict objectForKey:@"左边宽度"];
            detailArray=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"成绩数值"]];
            if(!detailArray || detailArray.count==0)
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
                [tipView showInView:self.view];
            }
            
            
            NSString *btName=[dict objectForKey:@"右上按钮"];
            if(btName!=nil)
            {
                
                btnUrl=[dict objectForKey:@"右上按钮URL"];
                UIBarButtonItem *rightBtn;
                if([[dict objectForKey:@"右上按钮Submit"] isEqualToString:@"是"])
                {
                    rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleDone target:self action:@selector(addSubmit)];
                }
                else
                {
                    rightBtn= [[UIBarButtonItem alloc] initWithTitle:btName style:UIBarButtonItemStyleDone target:self action:@selector(addNew)];
                }
                self.navigationItem.rightBarButtonItem=rightBtn;
            }
            else
                self.navigationItem.rightBarButtonItem=nil;
            
            loginUrl=[dict objectForKey:@"登录地址"];
            NSString *bottomBtn=[dict objectForKey:@"底部按钮"];
            if(bottomBtn!=nil && bottomBtn.length>0)
            {
                NSMutableDictionary *bottomDic=[NSMutableDictionary dictionary];
                [bottomDic setObject:bottomBtn forKey:@"左边"];
                NSString *fraction=[NSString stringWithFormat:@"%@|||%@|||%@|||%@|||%@|||%@|||%@|||%@",[dict objectForKey:@"商品单号"],[dict objectForKey:@"商品名称"],[dict objectForKey:@"商品价格"],[dict objectForKey:@"商品描述"],[dict objectForKey:@"partner"],[dict objectForKey:@"seller_id"],[dict objectForKey:@"RSA_PRIVATE"],[dict objectForKey:@"notify_url"]];
                [bottomDic setObject:fraction forKey:@"右边"];
                [detailArray addObject:bottomDic];
            }
            [self.tableView reloadData];
        }
        
        
    }
    else if([request.username isEqualToString:@"删除行"])
    {
        if(alertTip)
           [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict && [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            NSIndexPath *index=[NSIndexPath indexPathForRow:request.tag inSection:0];
            [detailArray removeObjectAtIndex:request.tag];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
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
            
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else if([request.username isEqualToString:@"下载笔记图片"])
    {
        NSData *datas = [request responseData];
        UIImage *img=[[UIImage alloc]initWithData:datas];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"文件名"];
        //filename=[savepath stringByAppendingString:filename];
        [datas writeToFile:filename atomically:YES];
        UIButton *btn=[item objectForKey:@"selBtn"];
        for(UIActivityIndicatorView *v in btn.subviews)
        {
            if([v isKindOfClass:[UIActivityIndicatorView class]])
            {
                [v stopAnimating];
                [v removeFromSuperview];
            }
        }
        [btn setImage:img forState:UIControlStateNormal];
    }
    else if([request.username isEqualToString:@"下载附件"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *datas = [request responseData];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"filename"];
        [datas writeToFile:filename atomically:YES];
        [self openFile:filename];
    }
    else if([request.username isEqualToString:@"右上按钮Submit"])
    {
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *result=[dict objectForKey:@"结果"];
        if(!result) result=[dict objectForKey:@"状态"];
        if([result isEqualToString:@"成功"])
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
                [self loadDetailData];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
            }
                
            
        }
    }
    
}
-(void)addNew
{
 
    //NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    NSString *urlStr=[[tmparray objectAtIndex:0] stringByAppendingString:btnUrl];
    DDIWenJuanDetail *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
    
    detail.title=self.title;
    detail.interfaceUrl=urlStr;
    detail.examStatus=@"进行中";
    detail.key=-1;
    detail.parentTitleArray=nil;
    detail.autoClose=@"是";
    [self.navigationController pushViewController:detail animated:YES];
}
-(void)addSubmit
{
    NSArray *tmpArray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    
    NSString *urlStr=[NSString stringWithFormat:@"%@%@",[tmpArray objectAtIndex:0],btnUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"右上按钮Submit";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"处理中..." message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
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
        [req clearDelegatesAndCancel];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"needRefreshDetail" object:nil];
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

    // Return the number of rows in the section.
    return detailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *leftLbl;
    UILabel *rightLbl;
    UIButton *bottomBtn;
    
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        int width=(self.view.frame.size.width-15)*leftWidth.intValue/100;
        leftLbl=[[UILabel alloc] initWithFrame:CGRectMake(5, 3, width, cell.frame.size.height-6)];
        rightLbl=[[UILabel alloc]initWithFrame:CGRectMake(width+10, 3, self.view.frame.size.width-width-15,cell.frame.size.height-6)];
        
        leftLbl.font=[UIFont systemFontOfSize:15];
        rightLbl.font=[UIFont systemFontOfSize:15];
        leftLbl.backgroundColor=[UIColor clearColor];
        rightLbl.backgroundColor=[UIColor clearColor];
        leftLbl.tag=101;
        rightLbl.tag=102;
        [leftLbl setNumberOfLines:0];
        [rightLbl setNumberOfLines:0];
        leftLbl.textColor=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];;
        [cell addSubview:leftLbl];
        [cell addSubview:rightLbl];
        [leftLbl setLineBreakMode:NSLineBreakByCharWrapping];
        [rightLbl setLineBreakMode:NSLineBreakByCharWrapping];

        UIButton *hiddenBtn=[[UIButton alloc]initWithFrame:CGRectZero];
        hiddenBtn.tag=103;
        [cell addSubview:hiddenBtn];
        [hiddenBtn addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
        
        //leftLbl.translatesAutoresizingMaskIntoConstraints = NO;
        leftLbl.textAlignment=NSTextAlignmentRight;
        
        bottomBtn=[[UIButton alloc]initWithFrame:CGRectZero];
        bottomBtn.tag=104;
        [cell addSubview:bottomBtn];
        [bottomBtn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        /*
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [cell addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:width];
        [cell addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:leftLbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:hiddenBtn attribute:NSLayoutAttributeRight multiplier:1.0f constant:5];
        [cell addConstraint:constraint];
        
        rightLbl.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [cell addConstraint:constraint1];
        constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftLbl attribute:NSLayoutAttributeRight multiplier:1.0f constant:5];
        [cell addConstraint:constraint1];
        constraint1 = [NSLayoutConstraint constraintWithItem:rightLbl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:cell.frame.size.width-width-20];
        [cell addConstraint:constraint1];
         */
        
    }
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    leftLbl=(UILabel *)[cell viewWithTag:101];
    rightLbl=(UILabel *)[cell viewWithTag:102];
    bottomBtn=(UIButton *)[cell viewWithTag:104];
    
    for(UIView *subview in cell.contentView.subviews)
    {
        if(subview.tag>=200 && [subview isKindOfClass:[UIButton class]])
            [subview removeFromSuperview];
    }
    NSString *rightText=[item objectForKey:@"右边"];
    NSArray *orderInfoArray=[rightText componentsSeparatedByString:@"|||"];
    if(orderInfoArray.count==8)
    {
        leftLbl.text=@"";
        rightLbl.text=@"";
        [bottomBtn setHidden:NO];
        [bottomBtn setFrame:CGRectMake(0, 5, self.view.frame.size.width, cell.frame.size.height-10)];
        [bottomBtn setBackgroundColor:[UIColor colorWithRed:212/255.0f green:64/255.0f blue:148/255.0f alpha:1.0f]];
        [bottomBtn setTitle:[item objectForKey:@"左边"] forState:UIControlStateNormal];
        [bottomBtn setTag:indexPath.row];
    }
    else
    {
        [bottomBtn setHidden:YES];
        leftLbl.text=[item objectForKey:@"左边"];
        rightLbl.text=rightText;
        if([CommonFunc isValidateMobile:rightText])
        {
            rightLbl.textColor=rightLbl.tintColor;
            rightLbl.userInteractionEnabled = YES;
            if(rightLbl.gestureRecognizers==nil || rightLbl.gestureRecognizers.count==0)
            {
                UITapGestureRecognizer *labelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealClickURL:)];
                [rightLbl addGestureRecognizer:labelTap];
            }
        }
        else
        {
            rightLbl.textColor=[UIColor blackColor];
            rightLbl.userInteractionEnabled = NO;
            
        }
        CGSize size1 = [CommonFunc getSizeByText:leftLbl.text width:leftLbl.frame.size.width font:leftLbl.font];
        CGSize size2 = [CommonFunc getSizeByText:rightLbl.text width:rightLbl.frame.size.width font:rightLbl.font];
       [leftLbl setFrame:CGRectMake(leftLbl.frame.origin.x, leftLbl.frame.origin.y, leftLbl.frame.size.width, size1.height)];
       [rightLbl setFrame:CGRectMake(rightLbl.frame.origin.x, rightLbl.frame.origin.y, rightLbl.frame.size.width, size2.height)];
        
        if([item objectForKey:@"lat"]==nil && [item objectForKey:@"隐藏按钮"]==nil)
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        /*
        if([item objectForKey:@"隐藏按钮"]!=nil)
        {
            NSString *urlStr=[item objectForKey:@"隐藏按钮"];
            NSArray *iconArray=[urlStr componentsSeparatedByString:@"/"];
            NSString *iconName=[iconArray objectAtIndex:iconArray.count-1];
            
            NSString *filename=[savepath stringByAppendingString:iconName];
            UIButton *hiddenBtn=(UIButton *)[cell viewWithTag:103];
            if([CommonFunc fileIfExist:filename])
            {
                UIImage *img=[UIImage imageWithContentsOfFile:filename];
                [hiddenBtn setImage:img forState:UIControlStateNormal];
            }
            else
            {
                NSURL *url = [NSURL URLWithString:urlStr];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.username=@"下载图片";
                NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
                [indexDic setObject:filename forKey:@"filename"];
                [indexDic setObject:indexPath forKey:@"indexPath"];
                request.userInfo=indexDic;
                [request setDelegate:self];
                [request startAsynchronous];
                [requestArray addObject:request];
            }
        }
        */
        NSArray *photosArray=[item objectForKey:@"图片数组"];
        if(photosArray && photosArray.count>0)
        {
            int maxheight=size2.height;
            if(size1.height>maxheight)
                maxheight=size1.height;
            [self drawImageFromArray:rightLbl.frame.origin.y+maxheight+5 left:rightLbl.frame.origin.x array:photosArray parent:cell];
        }
        NSArray *fujianArray=[item objectForKey:@"附件数组"];
        if(fujianArray && fujianArray.count>0)
        {
            [self drawFujianFromArray:0 left:rightLbl.frame.origin.x array:fujianArray parent:cell];
        }
    }
    return cell;
}
-(void)dealClickURL:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    NSLog(@"text = %@",label.text);
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt:%@",label.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)drawImageFromArray:(int)top left:(int)left array:(NSArray *)photos parent:(UITableViewCell *)parentView
{
    
    int j=(int)photos.count;
    int cols=(self.view.frame.size.width-left)/41;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn;
        if(i<cols)
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+i*41, top, 35, 35)];
        else
        {
            int rows=i/cols;
            int colid=i%cols;
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left+colid*41, top+41*rows, 35, 35)];
        }
        NSString *urlStr=[photos objectAtIndex:i];
        NSString *filename=[CommonFunc getFileRealName:urlStr];
        filename=[savepath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [selBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载笔记图片";
            NSMutableDictionary *item=[NSMutableDictionary dictionary];
            [item setObject:filename forKey:@"文件名"];
            [item setObject:selBtn forKey:@"selBtn"];
            request.userInfo=item;
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [selBtn addSubview:aiv];
            
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            [aiv startAnimating];
        }
        selBtn.tag=200+i;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(popPhotoView:) forControlEvents:UIControlEventTouchUpInside];
        [parentView.contentView addSubview:selBtn];
    }
    //[self.tableView reloadData];
    
}
-(void)drawFujianFromArray:(int)top left:(int)left array:(NSArray *)photos parent:(UITableViewCell *)parentView
{
    
    int j=(int)photos.count;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(left, top+i*30, self.tableView.bounds.size.width-left-15, 25)];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        NSDictionary *item=[photos objectAtIndex:i];
        NSString *filename=[item objectForKey:@"name"];
        
        [selBtn setTitle:filename forState:UIControlStateNormal];
        [selBtn addTarget:self action:@selector(downloadOrOpen:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=200+i;
        [parentView.contentView addSubview:selBtn];
    }
}
-(void)downloadOrOpen:(UIButton *)sender
{
    UITableViewCell *cell=(UITableViewCell *)sender.superview.superview;
    NSIndexPath *indexpath=[self.tableView indexPathForCell:cell];
    int curIndex=(int)indexpath.row;
    NSDictionary *item=[detailArray objectAtIndex:curIndex];
    NSArray *fujianArray=[item objectForKey:@"附件数组"];
    int index=(int)sender.tag-200;
    NSDictionary *fujianItem=[fujianArray objectAtIndex:index];
    NSString *filename=[fujianItem objectForKey:@"name"];
    NSString *urlStr=[fujianItem objectForKey:@"url"];
    filename=[savepath stringByAppendingString:filename];
    if([CommonFunc fileIfExist:filename])
    {
        [self openFile:filename];
    }
    else
        [self downloadFujian:filename urlStr:urlStr];
    
}
-(void)openFile:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    self.documentInteractionController = [UIDocumentInteractionController                                                      interactionControllerWithURL:url];
    [self.documentInteractionController setDelegate:self];
    bool b=[self.documentInteractionController presentPreviewAnimated:YES];
    if(!b)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到可用来打开此课件的程序"];
        [tipView show];
    }
}
- (void) downloadFujian:(NSString *)filename urlStr:(NSString *)urlStr
{

    NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.username=@"下载附件";
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:filename forKey:@"filename"];
    [request setDelegate:self];
    request.userInfo=dic;
    [requestArray addObject:request];
    request.timeOutSeconds=30;
    [request startAsynchronous];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在下载..." message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *detailURL=[item objectForKey:@"内容项URL"];
    NSString *moban=[item objectForKey:@"模板"];
    NSString *mobanLevel=[item objectForKey:@"模板级别"];
    if([item objectForKey:@"lat"]!=nil)
    {
        NSString *lat = [item objectForKey:@"lat"];
        NSString *lon = [item objectForKey:@"lon"];
        
        NSString *address=[item objectForKey:@"右边"];
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=[item objectForKey:@"左边"];
        controller.urlStr=[NSString stringWithFormat:@"http://mo.amap.com/?q=%.10f,%.10f&name=%@&dev=1",lat.doubleValue,lon.doubleValue,address];
        [self.navigationController pushViewController:controller animated:YES];
    }
    /*
    else if([item objectForKey:@"隐藏按钮"]!=nil)
    {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        //UILabel *left=(UILabel *)[cell viewWithTag:101];
        //UILabel *right=(UILabel *)[cell viewWithTag:102];
        UIButton *btn=(UIButton *)[cell viewWithTag:103];
        if(btn.frame.size.width==0)
        {
            [UIView beginAnimations:@"my_own_animation" context:nil];
            [btn setFrame:CGRectMake(5, (cell.frame.size.height-32)/2, 32, 32)];
            //[left setFrame:CGRectMake(left.frame.origin.x+42, left.frame.origin.y, left.frame.size.width, left.frame.size.height)];
            //[right setFrame:CGRectMake(right.frame.origin.x+42, right.frame.origin.y, right.frame.size.width, right.frame.size.height)];
            [UIView commitAnimations];
            [self performSelector:@selector(hideDeleteBtn:) withObject:cell afterDelay:3.0];
        }

    }
    */
    else if([item objectForKey:@"htmlText"]!=nil)
    {
        NSString *htmlText=[item objectForKey:@"htmlText"];
        DDIHelpView *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
        controller.navigationItem.title=self.title;
        controller.htmlStr=htmlText;
        controller.loginUrl=loginUrl;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([item objectForKey:@"编号"]!=nil)
    {
     
        [self performSegueWithIdentifier:@"classAttend1" sender:item];
    }
    else if(detailURL && detailURL.length>0)
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
            {
                DDIChengjiDetail *chengjiDetail=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiDetail"];
                chengjiDetail.title=self.title;
                NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
                detailURL=[NSString stringWithFormat:@"%@%@",[tmparray objectAtIndex:0],detailURL];
                chengjiDetail.interfaceUrl=detailURL;
                [self.navigationController pushViewController:chengjiDetail animated:YES];
            }
        }
        else if([moban isEqualToString:@"调查问卷"])
        {
            NSArray *tmparray=[self.interfaceUrl componentsSeparatedByString:@"?"];
            // NSString *realname=[CommonFunc getFileRealName:[tmparray objectAtIndex:0]];
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
        
    }
    
}
-(void)hideDeleteBtn:(UITableViewCell *)cell
{
    
    //UILabel *left=(UILabel *)[cell viewWithTag:101];
    //UILabel *right=(UILabel *)[cell viewWithTag:102];
    UIButton *btn=(UIButton *)[cell viewWithTag:103];
    if(btn!=nil && btn.frame.size.width!=0)
    {
        [UIView beginAnimations:@"my_own_animation1" context:nil];
        [btn setFrame:CGRectZero];
        //[left setFrame:CGRectMake(left.frame.origin.x-42, left.frame.origin.y, left.frame.size.width, left.frame.size.height)];
        //[right setFrame:CGRectMake(right.frame.origin.x-42, right.frame.origin.y, right.frame.size.width, right.frame.size.height)];
        [UIView commitAnimations];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 列寬
    CGFloat leftwidth =(self.view.frame.size.width-15)*leftWidth.intValue/100;
    CGFloat rightwidth=self.view.frame.size.width-15-leftwidth;
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:15];
    // 該行要顯示的內容
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *leftcontent=[item objectForKey:@"左边"];
    NSString *rightcontent=[item objectForKey:@"右边"];
    NSArray *orderInfoArray=[rightcontent componentsSeparatedByString:@"|||"];
    if(orderInfoArray.count==8)
    {
        rightcontent=@"";
    }
    // 計算出顯示完內容需要的最小尺寸
    CGSize size1=[CommonFunc getSizeByText:leftcontent width:leftwidth font:font];
    CGSize size2=[CommonFunc getSizeByText:rightcontent width:rightwidth font:font];
    // 這裏返回需要的高度
    int height=(size1.height>size2.height?size1.height:size2.height)+6;
    NSArray *photosArray=[item objectForKey:@"图片数组"];
    if(photosArray && photosArray.count>0)
    {
        int cols=(self.view.frame.size.width-leftwidth)/41;
        if(photosArray.count>cols)
        {
            int rows=(int)photosArray.count/cols;
            height=height+41+41*rows+5;
        }
        else
            height=height+41+5;
    }
    photosArray=[item objectForKey:@"附件数组"];
    if(photosArray && photosArray.count>0)
    {
        height=30*(int)photosArray.count+10;
    }
    if(height<40)
        height=40;
    return height;
}
-(void)deleteCell:(UIButton *)btn
{
    UIView *tmpview=btn.superview;
    while(![tmpview isKindOfClass:[UITableViewCell class]])
        tmpview=tmpview.superview;
    NSIndexPath *indexPath=[self.tableView indexPathForCell:(UITableViewCell *)tmpview];
    
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    NSString *strUrl=[item objectForKey:@"隐藏按钮URL"];
    NSArray *tmpArray=[self.interfaceUrl componentsSeparatedByString:@"?"];
    strUrl=[tmpArray[0] stringByAppendingString:strUrl];
    NSURL *url = [NSURL URLWithString:strUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"删除行";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request setTag:indexPath.row];
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在删除" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
}
-(void)bottomBtnClick:(UIButton *)btn
{
    [btn setEnabled:false];
    [self performSelector:@selector(enableBottomBtn:) withObject:btn afterDelay:3.0f];
    //NSDictionary *dict=[detailArray objectAtIndex:btn.tag];
    /*
    if(dict!=nil)
    {
        NSString *rightText=[dict objectForKey:@"右边"];
        NSArray *orderInfoArray=[rightText componentsSeparatedByString:@"|||"];
     
        NSString *partner =[orderInfoArray objectAtIndex:4];
        NSString *seller = [orderInfoArray objectAtIndex:5];
        NSString *privateKey = [orderInfoArray objectAtIndex:6];
     
        //partner和seller获取失败,提示
        if ([partner length] == 0 ||
            [seller length] == 0 ||
            [privateKey length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"缺少partner或者seller或者私钥。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
     
        //将商品信息赋予AlixPayOrder的成员变量
        Order *order = [[Order alloc] init];
        order.partner = partner;
        order.seller = seller;
        order.tradeNO = [orderInfoArray objectAtIndex:0]; //订单ID（由商家自行制定）
        order.productName = [orderInfoArray objectAtIndex:1]; //商品标题
        order.productDescription = [orderInfoArray objectAtIndex:3]; //商品描述
        order.amount = [orderInfoArray objectAtIndex:2]; //商品价格
        order.notifyURL =  [orderInfoArray objectAtIndex:7]; //回调URL
        
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        order.showUrl = @"m.alipay.com";
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        NSString *appScheme = @"alisdkdemo";
        
        //将商品信息拼接成字符串
        NSString *orderSpec = [order description];
        NSLog(@"orderSpec = %@",orderSpec);
        
        //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
        id<DataSigner> signer = CreateRSADataSigner(privateKey);
        NSString *signedString = [signer signString:orderSpec];
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = nil;
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, @"RSA"];
            
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
                NSString *resultStatus=[resultDic objectForKey:@"resultStatus"];
                NSString *resultmsg=@"";
                if([resultStatus isEqualToString:@"9000"])
                    resultmsg=@"支付成功";
                else if([resultStatus isEqualToString:@"8000"])
                    resultmsg=@"正在处理中";
                else if([resultStatus isEqualToString:@"4000"])
                    resultmsg=@"支付失败";
                else if([resultStatus isEqualToString:@"6001"])
                    resultmsg=@"用户中途取消";
                else if([resultStatus isEqualToString:@"6002"])
                    resultmsg=@"网络连接出错";
                if(resultmsg.length>0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:resultmsg];
                    [tipView show];
                }
                if([resultStatus isEqualToString:@"9000"])
                {
                    [self loadDetailData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
                }
                
            }];

        }
    }
     */
}
-(void)enableBottomBtn:(UIButton *)btn
{
    [btn setEnabled:true];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"classAttend1"])
    {
        UINavigationController *NavController=segue.destinationViewController;
        
        UITabBarController *destController=[NavController.childViewControllers objectAtIndex:0];
        NSDictionary *classInfo=(NSDictionary *)sender;
        DDIClassAttend *dest=[destController.childViewControllers objectAtIndex:0];
        DDICourseInfo *dest1=[destController.childViewControllers objectAtIndex:1];
        dest1.className=self.title;
        dest1.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest1.classNo=[classInfo objectForKey:@"编号"];
        
        DDIKeJianDownload *dest2=[destController.childViewControllers objectAtIndex:2];
        dest2.className=self.title;
        dest2.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        dest2.classNo=[classInfo objectForKey:@"编号"];
        
        DDIKeTangExam *dest3=[destController.childViewControllers objectAtIndex:3];
        dest3.className=self.title;
        dest3.classNo=[classInfo objectForKey:@"编号"];
        dest3.banjiName=[teacherInfoDic objectForKey:@"班级"];
        
        DDIKeTangPingJia *dest4=[destController.childViewControllers objectAtIndex:4];
        dest4.banjiName=[teacherInfoDic objectForKey:@"班级"];
        dest4.classNo=[classInfo objectForKey:@"编号"];
        dest4.className=self.title;
        dest4.teacherUserName=[classInfo objectForKey:@"教师用户名"];
        
        [dest removeFromParentViewController];
 
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        destController.navigationItem.leftBarButtonItem = backButtonItem;
    }
    
}
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)popPhotoView:(UIButton *)sender
{

    UIView *parent=sender.superview;
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=parent.superview;
    NSIndexPath *index=[self.tableView indexPathForCell:(UITableViewCell *)parent];
    NSDictionary *item=[detailArray objectAtIndex:index.row];
    NSArray *photos=[item objectForKey:@"图片数组"];
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
    for(int i=0;i<photos.count;i++)
    {
        NSString *strUrl=[photos objectAtIndex:i];
        NSString *filename=[CommonFunc getFileRealName:strUrl];
        filename=[savepath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
    }
    if(picArray.count>0)
    {
        browserView.picArray=picArray;
        [browserView showFromIndex:(int)sender.tag-200];
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
    if([item objectForKey:@"隐藏按钮"]!=nil)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        NSDictionary *item=[detailArray objectAtIndex:indexPath.row];
        NSString *strUrl=[item objectForKey:@"隐藏按钮URL"];
        NSArray *tmpArray=[self.interfaceUrl componentsSeparatedByString:@"?"];
        strUrl=[tmpArray[0] stringByAppendingString:strUrl];
        NSURL *url = [NSURL URLWithString:strUrl];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        request.username=@"删除行";
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        [request setTag:indexPath.row];
        [request startAsynchronous];
        [requestArray addObject:request];
        alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在删除" message:nil timeout:0 dismissible:NO];
        [alertTip showInView:self.view];
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
