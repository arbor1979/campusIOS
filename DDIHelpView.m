//
//  DDIHelpView.m
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIHelpView.h"

static NSDate *loginDate;
extern CLLocationCoordinate2D stuLocation;
extern NSString *stuAddress;
extern NSString *kInitURL;
extern NSString *kUserIndentify;
@interface DDIHelpView ()

@end

@implementation DDIHelpView


+(NSDate *)getLoginDate
{
    return loginDate;
}
+(void)setLoginDate:(NSDate *)newDate
{
    loginDate=newDate;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    requestArray=[NSMutableArray array];
    savePath=[CommonFunc createPath:@"/webbrowers/"];
    self.webView.delegate=self;
    if(loginDate==nil)
        loginDate=[NSDate dateWithTimeIntervalSince1970:0];
    if(self.loginUrl!=nil)
    {
        NSArray *tempArray=[self.loginUrl componentsSeparatedByString:@"/"];
        baseUrl=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/",[tempArray objectAtIndex:2]]];
        NSDate *expiredDate=[loginDate dateByAddingTimeInterval:20*60];
        if([expiredDate timeIntervalSinceNow]<0)
        {
            NSURL *url = [NSURL URLWithString: self.loginUrl];
            userDefaultes = [NSUserDefaults standardUserDefaults];
            NSString *userName = [userDefaultes stringForKey:@"用户名"];
            NSArray *tempArray=[userName componentsSeparatedByString:@"@"];
            userName=[tempArray objectAtIndex:0];
            NSString *password = [userDefaultes stringForKey:@"密码"];
            NSString *body = [NSString stringWithFormat: @"username=%@&password=%@", userName,password];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
            [request setHTTPMethod: @"POST"];
            
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
            
            [self.webView loadRequest: request];
            islogin=true;
            self.webView.hidden=YES;
        }
        else
        {
            self.webView.hidden=YES;
            //[self.webView loadHTMLString:self.htmlStr baseURL:nil];
            //[self performSelector:@selector(showWebView) withObject:nil afterDelay:1.0f];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: baseUrl];
            [self.webView loadRequest: request];
        }
        

    }
    else
    {
        
        NSURL *url =[NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
        if([self.urlStr hasSuffix:@".html"])
        {
            request.cachePolicy=NSURLRequestReloadIgnoringCacheData;
        }
        [self.webView loadRequest:request];
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];//延迟加载,执行
        
        
    }
    self.btnBack.enabled=NO;
    self.btnForward.enabled=NO;
    [self.btnBack setAction:@selector(backClick)];
    [self.btnForward setAction:@selector(forwardClick)];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    mediaFormat=[[NSArray alloc] initWithObjects:@"avi",@"mov",@"asf",@"mpg",@"mpeg",@"flv",@"mp4",@"wmv",@"3gp",@"rm",@"rmvb",@"mkv", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setGPSXY)
                                                 name:@"getGPSXY"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setGPSAddress)
                                                 name:@"getGPSAddress"
                                               object:nil];
    
    [self setNewBackBtn];
    
}
-(void)setNewBackBtn
{
    if(!newbackItem)
    {
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 26.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"bg_btn_left_nor"] forState:UIControlStateNormal];
        backBtn.imageEdgeInsets=UIEdgeInsetsMake(3, 3, 3, 3);
        [backBtn addTarget:self action:@selector(webnaviback) forControlEvents:UIControlEventTouchUpInside];
        UIView *tmpview=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 30.0, 26.0)];
        [tmpview addSubview:backBtn];
        newbackItem = [[UIBarButtonItem alloc] initWithCustomView:tmpview];
    }
    if(!closeItem)
    {
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"closebtn"] forState:UIControlStateNormal];
        backBtn.imageEdgeInsets=UIEdgeInsetsMake(3, 3, 3, 3);
        [backBtn addTarget:self action:@selector(closewindow) forControlEvents:UIControlEventTouchUpInside];
        UIView *tmpview=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
        [tmpview addSubview:backBtn];
        closeItem = [[UIBarButtonItem alloc] initWithCustomView:tmpview];
        
    }
    UIBarButtonItem *spaceItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width=20;
    if(self.webView.canGoBack)
        self.navigationItem.leftBarButtonItems=@[newbackItem,spaceItem,closeItem];
    else
        self.navigationItem.leftBarButtonItems=@[closeItem];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
   
    
    
}
-(void)webnaviback
{
    if(self.webView.canGoBack)
        [self.webView goBack];
    else
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)closewindow
{
    if(self.navigationController.viewControllers.count>1)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)backClick
{
    self.webView.hidden=YES;
    [self.webView goBack];
}
-(void)forwardClick
{
    self.webView.hidden=YES;
    [self.webView goForward];
}
-(void)modifyConstant
{
    self.bottomBarHeight.constant=0.0f;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*) reuqest navigationType:(UIWebViewNavigationType)navigationType;
/*当网页视图被指示载入内容而得到通知。应当返回YES，这样会进行加载。通过导航类型参数可以得到请求发起的原因，可以是以下任意值：
UIWebViewNavigationTypeLinkClicked
UIWebViewNavigationTypeFormSubmitted
UIWebViewNavigationTypeBackForward
UIWebViewNavigationTypeReload
UIWebViewNavigationTypeFormResubmitted
UIWebViewNavigationTypeOther
*/
{
    NSString *url = [reuqest.URL absoluteString];
    if(navigationType==UIWebViewNavigationTypeLinkClicked)
    {
        url=[url stringByReplacingOccurrencesOfString:@"pda/attach_show.php" withString:@"pda2014/attach_show.php"];
        if ([url rangeOfString:@"pda2014/attach_show.php"].location != NSNotFound)
        {
            //跳转到你想跳转的页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            return NO; //返回NO，此页面的链接点击不会继续执行，只会执行跳转到你想跳转的页面
        }
        
    }
    if([url hasPrefix:@"js://PersonInfo"])
    {
        NSString *weiyima=[[CommonFunc findUrlQueryString:url :@"weiyima"] URLDecodedString];
        DDIMyInforView *itemController=[self.storyboard instantiateViewControllerWithIdentifier:@"MyInforView"];
        itemController.userWeiYi=weiyima;
        [self.navigationController pushViewController:itemController animated:YES];
        return NO;
    }
    else if([url hasPrefix:@"js://OpenTemplateMain"])
    {
        NSString *templateName=[[CommonFunc findUrlQueryString:url :@"templateName"] URLDecodedString];
        NSString *title=[[CommonFunc findUrlQueryString:url :@"title"] URLDecodedString];
        NSString *interfaceName=[[CommonFunc findUrlQueryString:url :@"interfaceName"] URLDecodedString];
        if([templateName isEqualToString:@"成绩"])
        {
            DDIChengjiTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiMain"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"考勤"])
        {
            DDIKaoQinTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"kaoqinMain"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"通知"])
        {
            DDINewsTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"newsMain"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            chengjiMain.newsType=title;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"调查问卷"])
        {
            DDIWenJuanTitle *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanMain"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"博客"])
        {
            DDILiuYan *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"liuyanMain"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        return NO;
    }
    else if([url hasPrefix:@"js://OpenTemplateDetail"])
    {
        NSString *templateName=[[CommonFunc findUrlQueryString:url :@"templateName"] URLDecodedString];
        NSString *title=[[CommonFunc findUrlQueryString:url :@"title"] URLDecodedString];
        NSString *interfaceName=[[CommonFunc findUrlQueryString:url :@"interfaceName"] URLDecodedString];
        if([templateName isEqualToString:@"成绩"])
        {
            DDIChengjiDetail *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"chengjiDetail"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"考勤"])
        {
            DDIKaoQinDetail *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"kaoqinDetail"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"通知"])
        {
            DDINewsDetail *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"newsDetail"];
            chengjiMain.title=title;
            News *news=[[News alloc]init];
            [news setUrl:interfaceName];
            chengjiMain.news=news;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        else if([templateName isEqualToString:@"调查问卷"])
        {
            DDIWenJuanDetail *chengjiMain=[self.storyboard instantiateViewControllerWithIdentifier:@"wenjuanDetail"];
            chengjiMain.title=title;
            chengjiMain.interfaceUrl=interfaceName;
            [self.navigationController pushViewController:chengjiMain animated:YES];
        }
        return NO;
    }
    else if([url hasPrefix:@"js://closeWebWindow"])
    {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return true;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(view)
        [view removeFromSuperview];
    view=[[UIView alloc]initWithFrame:self.webView.frame];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    [self.indicator startAnimating];
    [self.view bringSubviewToFront:self.indicator];
    NSLog(@"start load");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finish load:%@",[webView request].URL);
    if(self.htmlStr!=nil)
    {
        if(webView.canGoForward)
            self.btnForward.enabled=YES;
        else
            self.btnForward.enabled=NO;
        if(webView.canGoBack)
            self.btnBack.enabled=YES;
        else
            self.btnBack.enabled=NO;
        //[webView stringByEvaluatingJavaScriptFromString:@"if(document.getElementById('region-main')) {document.body.innerHTML=document.getElementById('region-main').innerHTML;var tags=document.getElementsByTagName('a');for(var i=0;i<tags.length;i++){tags[i].innerHTML=decodeURIComponent(tags[i].innerHTML);tags[i].href=tags[i].href.replace('pluginfile.php', 'pluginfile_dandian.php?');}}"];
    }
    
    [self setNewBackBtn];
    NSURL *curURL=webView.request.URL;
    NSURL *myURL=[NSURL URLWithString:[[NSString stringWithFormat:@"%@",baseUrl] stringByAppendingString:@"my/"]];
    if([curURL isEqual:baseUrl] || [curURL isEqual:myURL])
    {
        
        [self.webView loadHTMLString:self.htmlStr baseURL:nil];
        //[self performSelector:@selector(showWebView) withObject:nil afterDelay:1.0f];
    }
    else
    {
        [self.indicator stopAnimating];
        if(view)
            [view removeFromSuperview];
        self.webView.hidden=NO;
    }
    
    if(islogin)
    {
        islogin=false;
        loginDate=[NSDate date];
        
    }
    //js接口调用
    jscontext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 可以定义供js调用的方法, testMethod为js调用的方法名
    jscontext[@"testMethod"] = ^ NSString *() {
        if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            return @"请打开位置权限";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
            [app getGPS];
        });
        return nil;
    };
    jscontext[@"openCameral"] = ^ NSString *() {
        NSArray *args=[JSContext currentArguments];
        
        if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]==AVAuthorizationStatusDenied) {
            return @"请打开拍照权限";
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if(args.count>0 && [args objectAtIndex:0]!=nil)
           [imagePicker setTitle:[args objectAtIndex:0]];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if(args.count>1 && [args objectAtIndex:1]!=nil && [[args objectAtIndex:1] isEqualToString:@"1"])
            imagePicker.allowsEditing=true;
        else
            imagePicker.allowsEditing=false;
        imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:imagePicker animated:YES completion:nil];
        });
        return nil;
    };
    jscontext[@"getScanCode"] = ^ NSString *() {
        if([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]==AVAuthorizationStatusDenied) {
            return @"请打开拍照权限";
        }
        QRCodeController *qrcodeVC = [[QRCodeController alloc] init];
        qrcodeVC.view.alpha = 0;
        [qrcodeVC setDidReceiveBlock:^(NSString *result) {
            NSMutableDictionary *resultdic=[NSMutableDictionary dictionary];
            [resultdic setObject:result forKey:@"result"];
            [self performSelector:@selector(handleScanResult:) withObject:resultdic afterDelay:0.1f];
        }];
        DDIAppDelegate *del = (DDIAppDelegate *)[UIApplication sharedApplication].delegate;
        [del.window.rootViewController addChildViewController:qrcodeVC];
        [del.window.rootViewController.view addSubview:qrcodeVC.view];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            qrcodeVC.view.alpha = 1;
        } completion:^(BOOL finished) {
        }];
        return nil;
    };
    [webView stringByEvaluatingJavaScriptFromString:@"javascript:if(typeof $ !='undefined'){$(document).ready(function(){$('body').on('click','a',function(){ var _href = $(this).attr('_href');if(_href!=null && _href!='')  {location.href = _href;}});});}"];
}
-(void) handleScanResult:(NSDictionary *)resultDic
{
    NSString *result=[resultDic objectForKey:@"result"];
    [jscontext evaluateScript:[NSString stringWithFormat:@"callbackScanCode('%@')",result]];
}
-(void)setGPSXY
{
    if(stuLocation.latitude!=0 && jscontext)
        [jscontext evaluateScript:[NSString stringWithFormat:@"callbackGPSXY(%f,%f)",stuLocation.latitude,stuLocation.longitude]];
}
-(void)setGPSAddress
{
    if(jscontext && stuAddress!=nil && stuAddress.length>0)
        [jscontext evaluateScript:[NSString stringWithFormat:@"callbackRealAddress('%@')",stuAddress]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([error code] == NSURLErrorCancelled)
    {
        return;
    }
    [self.indicator stopAnimating];
    if(view)
        [view removeFromSuperview];
    
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
    {
        NSURL *newUrl=[error.userInfo objectForKey:@"NSErrorFailingURLKey"];
        
        NSString *urlstr=newUrl.absoluteString;
        NSString *lastComponent = [urlstr pathExtension].lowercaseString;
        BOOL onlineVideo=false;
        for(NSString *item in mediaFormat)
        {
            if([item isEqualToString:lastComponent])
            {
                onlineVideo=true;
                break;
            }
        }
        if(onlineVideo)
        {
            NSString *urlscheme=[NSString stringWithFormat:@"aceplayer://%@",newUrl.absoluteString];
            newUrl=[NSURL URLWithString:urlscheme];
            BOOL hasApp=[[UIApplication sharedApplication] canOpenURL:newUrl];
            if(hasApp)
                [[UIApplication sharedApplication] openURL:newUrl];
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"播放此视频需安装aceplayer,是否安装？" delegate:self cancelButtonTitle:@"否"  otherButtonTitles:@"是", nil];
                [alert show];
                
                //[self createMPPlayerController:urlstr];
                    
            }
        }
        else
        {
            NSString *filename=[[CommonFunc getFileRealName:urlstr] URLDecodedString];
            NSString *path=[savePath stringByAppendingString:filename];
            NSURL *fileUrl=[NSURL fileURLWithPath:path];
            if([CommonFunc fileIfExist:path])
                [self openFile:fileUrl];
            else
                [self download:newUrl];
        }
        return;
    }
    NSString *msg=[NSString stringWithFormat:@"无法打开此页面，%@",error];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)createMPPlayerController:(NSString *)sFileNamePath{
    MPMoviePlayerViewController *moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:sFileNamePath]];
    [moviePlayer.moviePlayer prepareToPlay];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    [moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [moviePlayer.view setFrame:self.view.bounds];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer.moviePlayer];
    
}
-(void)movieFinishedCallback:(NSNotification *)notify{
    MPMoviePlayerController *theMovie=[notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [self dismissMoviePlayerViewControllerAnimated];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        NSURL *url=[NSURL URLWithString:@"https://itunes.apple.com/cn/app/aceplayer/id480881925?mt=8"];
        [[UIApplication sharedApplication] openURL:url];
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

- (void) download:(NSURL *)downUrl
{
    if(progress!=nil)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"上个下载还未完成"];
        [tipView show];
        return;
    }
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"此链接需要下载才能打开，已开始下载.."];
    [tipView show];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:downUrl];
    request.timeOutSeconds=300;
    progress=[[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
    [self.bottomBar addSubview:progress];
    NSMutableArray *buttons =[NSMutableArray arrayWithArray:self.bottomBar.items];
    btnStopDownload=[[UIBarButtonItem alloc] initWithTitle:@"停止下载" style:UIBarButtonItemStyleDone target:self action:@selector(stopDown)];
    [buttons addObject:btnStopDownload];
    [self.bottomBar setItems:buttons];
    request.username=@"下载文件";
    [request setDownloadProgressDelegate:progress];
    [request setDelegate:self];
    request.showAccurateProgress=YES;
    [requestArray addObject:request];
    request.timeOutSeconds=0;
    [request startAsynchronous];
}
-(void)stopDown
{
    for(ASIHTTPRequest *req in requestArray)
    {
        if([req.username isEqualToString:@"下载文件"])
        {
            [req clearDelegatesAndCancel];
            [self clearDownTag];
        }
    }
}
-(void)clearDownTag
{
    [progress removeFromSuperview];
    progress=nil;
    NSMutableArray *buttons =[NSMutableArray arrayWithArray:self.bottomBar.items];
    for(NSObject *item in buttons)
    {
        if([item isKindOfClass:[UIBarButtonItem class]])
        {
            UIBarButtonItem *btn=(UIBarButtonItem *)item;
            if([btn.title isEqualToString:@"停止下载"])
            {
                [buttons removeObject:item];
                [self.bottomBar setItems:buttons];
            }
        }
    }
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    if([request.username isEqualToString:@"下载文件"])
    {

        if(data)
        {
            NSString *filename=[[CommonFunc getFileRealName:[NSString stringWithFormat:@"%@",request.url]] URLDecodedString];
            NSString *path=[savePath stringByAppendingString:filename];
            BOOL flag=[data writeToFile:path atomically:YES];
            [self clearDownTag];
            if(flag)
            {
                NSLog(@"下载成功:%@",filename);
                NSURL *fileUrl=[NSURL fileURLWithPath:path];
                [self openFile:fileUrl];
            }
            
        }
        
    }
    else if([request.username isEqualToString:@"上传图片"])
    {
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            NSString *fileurl=[dict objectForKey:@"文件地址"];
            if(jscontext && fileurl!=nil && fileurl.length>0)
                [jscontext evaluateScript:[NSString stringWithFormat:@"callbackCamera('%@')",fileurl]];
        }
    }
}
-(void)openFile:(NSURL *)fileUrl
{
    //UISaveVideoAtPathToSavedPhotosAlbum(fileUrl.absoluteString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    
    NSString *exeName=[CommonFunc getFileExeName:fileUrl.absoluteString];
    NSURL *newUrl=fileUrl;
    NSString *filename=[[CommonFunc getFileRealName:fileUrl.absoluteString] URLDecodedString];
    NSString *srcPath=[savePath stringByAppendingString:filename];
    if([exeName.lowercaseString isEqualToString:@"flv"])
    {
        
        NSRange rang=[filename rangeOfString:exeName];
        NSString *newName=[NSString stringWithFormat:@"%@.mp4",[filename substringToIndex:rang.location-1 ]];
        NSString *toPath=[savePath stringByAppendingString:newName];
        if(![CommonFunc fileIfExist:toPath])
        {
            [CommonFunc copyFile:srcPath toFile:toPath];
   
        }
        newUrl=[NSURL URLWithString:toPath];
    }
    if([CommonFunc fileIfExist:srcPath])
    {
        documentInteractionController = [UIDocumentInteractionController                                                      interactionControllerWithURL:newUrl];
        [documentInteractionController setDelegate:self];
        bool b=[documentInteractionController presentPreviewAnimated:YES];
        if(!b)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到可用来打开此文件的程序"];
            [tipView show];
        }
    }
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"文件不存在"];
        [tipView show];
    }

}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([request.username isEqualToString:@"下载课件"])
    {
        
        [self clearDownTag];
        if([requestArray containsObject:request])
            [requestArray removeObjectIdenticalTo:request];
        
    }
    NSString *errorStr;
    if([error.localizedDescription isEqualToString:@"The request was cancelled"])
        errorStr=@"操作被取消";
    else if([error.localizedDescription isEqualToString:@"The request timed out"])
        errorStr=@"请求超时";
    else
        errorStr=[error localizedDescription];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:errorStr];
    [tipView show];
    request=nil;
}
- (void)dealloc
{
    self.navigationItem.rightBarButtonItem=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGPSXY" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGPSAddress" object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(1280, 720);
        img=[img scaleToSize:newsize];
        NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        [self uploadFile:fileData coursename:picker.title];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void) uploadFile:(NSData *)data coursename:(NSString *)coursename
{
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:data withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:coursename forKey:@"课程名称"];
    [request setPostValue:@"0" forKey:@"老师上课记录编号"];
    [request setPostValue:@"问卷调查" forKey:@"图片类别"];
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:data forKey:@"data"];
    request.username=@"上传图片";
    request.userInfo=dic;
    request.timeOutSeconds=30;
    [request startAsynchronous];
    [requestArray addObject:request];
    
}
@end
