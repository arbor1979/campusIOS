//
//  DDINewsDetail.m
//  掌上校园
//
//  Created by yons on 14-3-10.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDINewsDetail.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern Boolean kIOS7;
extern DDIDataModel *datam;
@interface DDINewsDetail ()

@end

@implementation DDINewsDetail


- (void)viewDidLoad
{
    [super viewDidLoad];
    savePath=[CommonFunc createPath:@"/News/"];
    requestArray=[NSMutableArray array];
    picArray=[NSMutableArray array];
    
    float height=self.view.bounds.size.height-44;
    if(kIOS7)
        height=height-20;
	scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,height)];
    [self.view addSubview:scrollView];
    [self getNewsDetail:_news.newsid];
    if(_news.ifread==0 && _news.rowid>0)
        [datam clearUnReadByNewsId:_news.rowid];
    
    
}


-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
- (void)getNewsDetail:(int)newsid
{
    NSString *urlStr;
    if([[_news.url lowercaseString] hasPrefix:@"http"])
        urlStr=_news.url;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,_news.url];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"新闻详情";
    [request startAsynchronous];
    [requestArray addObject:request];
    aiv=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(scrollView.bounds.size.width/2-16, scrollView.bounds.size.height/2-16, 32, 32)];
    aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    [scrollView addSubview:aiv];
    [aiv startAnimating];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"新闻详情"])
    {
        if(aiv)
        {
            [aiv startAnimating];
            [aiv removeFromSuperview];
        }
        NSData *datas = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:datas encoding:NSUTF8StringEncoding];
        datas   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];;
        if(dic)
        {
            if([[dic objectForKey:@"标题"] isEqual:[NSNull null]])
            {
                _news.title=@"";
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"原文可能已被删除"];
                [tipView show];
            }
            else
                _news.title=[dic objectForKey:@"标题"];
            _news.time=[dic objectForKey:@"第二行"];
            _news.image=[dic objectForKey:@"第二行图片区URL"];
            if([[dic objectForKey:@"通知内容"] isEqual:[NSNull null]])
                _news.content=@"";
            else
                _news.content=[dic objectForKey:@"通知内容"];
            _news.picArray=[dic objectForKey:@"图片数组"];
            _news.fujianArray=[dic objectForKey:@"附件"];
            [self drawScrollContent];
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
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
            if(picArray.count==_news.picArray.count)
            {
                if(tip)
                    [tip removeFromSuperview];
                DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                browserView.picArray=picArray;
                [browserView showFromIndex:0];
            }
        }
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(aiv)
    {
        [aiv startAnimating];
        [aiv removeFromSuperview];
    }
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView show];
}
-(void)drawScrollContent
{
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(18, 18, scrollView.bounds.size.width-36, 25)];
    title.font=[UIFont boldSystemFontOfSize:18];
    title.textAlignment=NSTextAlignmentCenter;
    [title setNumberOfLines:0];
    title.text=_news.title;
    [title sizeToFit];
    title.frame=CGRectMake(18, 18, scrollView.bounds.size.width-36, title.frame.size.height);
    [scrollView addSubview:title];
    float y=title.frame.size.height+title.frame.origin.y+10;
    UILabel *time=[[UILabel alloc]initWithFrame:CGRectMake(18, y, scrollView.bounds.size.width-36, 18)];
    time.font=[UIFont systemFontOfSize:15];
    time.textAlignment=NSTextAlignmentRight;
    time.text=_news.time;
    
    [scrollView addSubview:time];
    y=y+time.frame.size.height+10;
    UIButton *imagev=nil;
    int width=self.view.frame.size.width-35;
    if(_news.image && _news.image.length>0)
    {
        
        imagev=[[UIButton alloc]initWithFrame:CGRectMake(18, y, width, 100)];
        NSArray *sepArray=[_news.image componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
        
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            float rate=img.size.height/img.size.width;
            int height=imagev.frame.size.width*rate;
            imagev.frame=CGRectMake(imagev.frame.origin.x,imagev.frame.origin.y, width, height);
            [imagev setBackgroundImage:img forState:UIControlStateNormal];
            [imagev addTarget:self action:@selector(popPhotoView) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:imagev];
            y=y+imagev.frame.size.height+10;
        }
        
    }
    UILabel *content=[[UILabel alloc]initWithFrame:CGRectMake(18, y, scrollView.bounds.size.width-32, 25)];
    content.font=[UIFont systemFontOfSize:16];
    [content setNumberOfLines:0];
    //content.text=_news.content;
    NSAttributedString *attstr=[[NSAttributedString alloc] initWithData:[_news.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    content.attributedText=attstr;
    [content sizeToFit];
    [scrollView addSubview:content];
    y=y+content.frame.size.height+10;
    
    if(_news.fujianArray!=nil && _news.fujianArray.count>0)
    {
        for(int i=0;i<_news.fujianArray.count;i++)
        {
            NSDictionary *item=[_news.fujianArray objectAtIndex:i];
            NSString *name=[item objectForKey:@"name"];
            
            UIFont *font=[UIFont systemFontOfSize:16];
            CGSize size1 = [name sizeWithFont:font constrainedToSize:CGSizeMake(width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
            UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(18, y, scrollView.bounds.size.width-32, size1.height)];
            btn.titleLabel.textColor=[UIColor blueColor];
            btn.titleLabel.font=font;
            [btn setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
            btn.titleLabel.numberOfLines=0;
            
            [btn setTitle:name forState:UIControlStateNormal];
           
            btn.tag=100+i;
            [btn addTarget:self action:@selector(openurl:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:btn];
            y=y+size1.height+5;
        }
    }
    
    scrollView.contentSize=CGSizeMake(self.view.bounds.size.width, y);
    
    if(_news.picArray!=nil && _news.picArray.count>0)
    {
        UILabel *tiplab=[[UILabel alloc]initWithFrame:CGRectMake(2, 2, 65, 18)];
        tiplab.backgroundColor=[UIColor colorWithRed:0/255.0 green:180/255.0 blue:0/255.0 alpha:0.5];
        tiplab.text=@"点击查看图集";
        tiplab.font=[UIFont systemFontOfSize:10];
        [imagev addSubview:tiplab];
       
        
    }
    
}
-(void)openurl:(UIButton *)sender
{
    NSDictionary *item=[_news.fujianArray objectAtIndex:sender.tag-100];
    NSString *urlStr=[item objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}
-(void)popPhotoView
{
    
    
    NSArray *photosArray=_news.picArray;
    if(photosArray==nil || photosArray.count==0)
        return;
    [picArray removeAllObjects];
    NSMutableArray *needDownload=[NSMutableArray array];
    for(int i=0;i<photosArray.count;i++)
    {
        NSString *urlStr=[photosArray objectAtIndex:i];
        NSArray *iconArray=[urlStr componentsSeparatedByString:@"/"];
        NSString *iconName=[iconArray objectAtIndex:iconArray.count-1];
        
        NSString *filename=[savePath stringByAppendingString:iconName];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
        else
            [needDownload addObject:urlStr];
    }
    if(picArray.count<photosArray.count)
    {
        if(!tip)
            tip= [[OLGhostAlertView alloc] initWithTitle:@"正在下载图片.." message:nil timeout:0 dismissible:NO];
        [tip showInView:self.view];
        [self downloadPics:needDownload];
        
    }
    else
    {
        DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        browserView.picArray=picArray;
        [browserView showFromIndex:0];
    }
}
-(void)downloadPics:(NSArray *)needDownload
{
    for(int i=0;i<needDownload.count;i++)
    {
        NSString *urlStr=[needDownload objectAtIndex:i];
        NSArray *iconArray=[urlStr componentsSeparatedByString:@"/"];
        NSString *filename=[iconArray objectAtIndex:iconArray.count-1];
        filename=[savePath stringByAppendingString:filename];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=@"下载图片";
        NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
        [indexDic setObject:filename forKey:@"filename"];
        request.userInfo=indexDic;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
