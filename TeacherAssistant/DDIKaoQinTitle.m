//
//  DDIKaoQinTitle.m
//  掌上校园
//
//  Created by yons on 14-3-12.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIKaoQinTitle.h"
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern int kUserType;
extern Boolean kIOS7;
extern NSMutableDictionary *userInfoDic;
@interface DDIKaoQinTitle ()

@end

@implementation DDIKaoQinTitle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    savePath=[CommonFunc createPath:@"/utils/"];
    requestArray=[NSMutableArray array];
    self.view.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    self.headImage.layer.cornerRadius = self.headImage.frame.size.width / 2;
    self.headImage.layer.masksToBounds = YES;
    UIColor *mygreen=[UIColor colorWithRed:34/255.0 green:177/255.0 blue:98/255.0 alpha:1];
    self.searchView.layer.borderColor = mygreen.CGColor;
    self.searchView.layer.borderWidth =1.0;
    self.searchView.layer.cornerRadius =5.0;
    
    if(!kIOS7)
    {
        [_segWeekOrMonth.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.8].CGColor];
        [_segWeekOrMonth.layer setBorderWidth:1.0f];
        [_segWeekOrMonth.layer setCornerRadius:4.0f];
        [_segWeekOrMonth.layer setMasksToBounds:YES];
    }
    NSString *weiyima=[teacherInfoDic objectForKey:@"用户唯一码"];
    if(kUserType==1)
    {
        self.lblName.text=[teacherInfoDic objectForKey:@"姓名"];
        self.lblXuehao.text=[NSString stringWithFormat:@"用户类型:%@",[teacherInfoDic objectForKey:@"用户类型"]];
        self.lblBanji.text=[NSString stringWithFormat:@"部门:%@",[teacherInfoDic objectForKey:@"部门"]];
        self.thirdviewheight.constant=0;
    }
    else
    {
        NSString *name=[teacherInfoDic objectForKey:@"姓名"];
        self.lblName.text=[name stringByReplacingOccurrencesOfString:@"[家长]" withString:@""];
        NSString *xuehao=[teacherInfoDic objectForKey:@"学号"];
        self.lblXuehao.text=[NSString stringWithFormat:@"学号:%@",[xuehao stringByReplacingOccurrencesOfString:@"jz" withString:@""]];
        NSString *banji=[teacherInfoDic objectForKey:@"班级"];
        self.lblBanji.text=[NSString stringWithFormat:@"班级:%@",[banji stringByReplacingOccurrencesOfString:@"[家长]" withString:@""]];
        weiyima=[weiyima stringByReplacingOccurrencesOfString:@"jz" withString:@""];
        weiyima=[weiyima stringByReplacingOccurrencesOfString:@"家长" withString:@"学生"];
    }
    NSString *filename=[CommonFunc getImageSavePath:weiyima ifexist:YES];
    if(filename)
    {
        UIImage *img=[UIImage imageWithContentsOfFile:filename];
        [self.headImage setBackgroundImage:img forState:UIControlStateNormal];
    }
    else
    {
        NSString *url=[teacherInfoDic objectForKey:@"用户头像"];
        [self loadImageAndSave:url parentView:self.headImage];
    }
    [self loadTitleData:@""];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    actionSheet.backgroundColor=[UIColor whiteColor];
    [actionSheet setBounds:CGRectMake(0, 0, 100, 150)];
    pickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 120)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    //[navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(docancel)];
    navItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    navItem.rightBarButtonItem = rightButton;
    NSArray *array = [[NSArray alloc] initWithObjects:navItem, nil];
    [navBar setItems:array];
    weekArray=[NSMutableArray array];
    
    [actionSheet addSubview:navBar];
    [actionSheet addSubview:pickerView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if([[[UIDevice currentDevice]systemVersion] floatValue] >=8.0)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        pickerView.frame=CGRectMake(0, 40, alertController.view.bounds.size.width-16, 120);
        navBar.frame=CGRectMake(0, 0, alertController.view.bounds.size.width-16, 40);
        
        [alertController.view addSubview:navBar];
        [alertController.view addSubview:pickerView];
    }
    
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadTitleData:(NSString *)searchParam
{
    NSString *urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@%@",kInitURL,self.interfaceUrl,searchParam];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:[userInfoDic objectForKey:@"当前学期"] forKey:@"当前学期"];
    [dic setObject:[userInfoDic objectForKey:@"当前周次"] forKey:@"当前周"];

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
        titleArray= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(!titleArray)
            titleArray=[NSDictionary dictionary];
        if(titleArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有任何数据"];
            [tipView showInView:self.view];
        }
        else
        {
            [self drawDataFromDic];
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
-(void)drawDataFromDic
{
    
    
    NSDictionary *tmpDic=[titleArray objectForKey:@"快捷查询"];
    NSDictionary *startDic=[tmpDic objectForKey:@"最近一周"];
    NSDictionary *endDic=[tmpDic objectForKey:@"最近一月"];
    [self.segWeekOrMonth setTitle:[startDic objectForKey:@"名称"] forSegmentAtIndex:0];
    [self.segWeekOrMonth setTitle:[endDic objectForKey:@"名称"] forSegmentAtIndex:1];
    segUrl0=[startDic objectForKey:@"内容项URL"];
    segUrl1=[endDic objectForKey:@"内容项URL"];
    
    tmpDic=[titleArray objectForKey:@"按周查询"];
    startDic=[tmpDic objectForKey:@"开始周"];
    endDic=[tmpDic objectForKey:@"结束周"];
    NSNumber *num1=[startDic objectForKey:@"值"];
    NSNumber *num2=[endDic objectForKey:@"值"];
    [weekArray removeAllObjects];
    for(int i=1;i<=num2.intValue;i++)
        [weekArray addObject:[NSNumber numberWithInt:i]];
    [pickerView reloadAllComponents];
    num1=[startDic objectForKey:@"默认"];
    num2=[endDic objectForKey:@"默认"];
    NSString *btnTilte=[NSString stringWithFormat:@"第%d周-第%d周",num1.intValue,num2.intValue];
    [self.pickWeeks setTitle:btnTilte forState:UIControlStateNormal];
    
    NSDictionary *kaoqinData=[titleArray objectForKey:@"考勤数值"];
    NSArray *keyArray=[[titleArray objectForKey:@"顺序"] componentsSeparatedByString:@","];
    
    for(int i=0;i<keyArray.count;i++)
    {
        NSDictionary *item=[kaoqinData objectForKey:[keyArray objectAtIndex:i]];
        NSString *bgChuqin=[item objectForKey:@"图片背景"];
        UIButton *btn=[self.btnChuqins objectAtIndex:i];
        [self loadImageAndSave:bgChuqin parentView:btn];
        btn.titleLabel.text=[NSString stringWithFormat:@"%@&Week1=%d&Week2=%d",[item objectForKey:@"内容项URL"],num1.intValue,num2.intValue];
        btn.tag=100+i;
        CGRect frame=btn.frame;
        frame.size.width=self.view.frame.size.width/2-15;
        [btn setFrame:frame];
        NSString *iconChuqin=[item objectForKey:@"考勤图标"];
        UIImageView *iv=[self.imgChuqins objectAtIndex:i];
        [self loadImageAndSave:iconChuqin parentView:iv];
        UILabel *value=[self.lblValue objectAtIndex:i];
        value.text=[NSString stringWithFormat:@"%@",[item objectForKey:@"值"]];
        UILabel *itemName=[self.lblItemName objectAtIndex:i];
        itemName.text=[item objectForKey:@"名称"];
        if(i==5) break;
    }
    
}
-(void)loadImageAndSave:(NSString *)imageUrl parentView:(UIView *)parentView
{
    if(imageUrl && imageUrl.length>0)
    {
        NSArray *sepArray=[imageUrl componentsSeparatedByString:@"/"];
        NSString *filename=[sepArray objectAtIndex:sepArray.count-1];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
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
            request.userInfo=indexDic;
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            
        }
    }
}
- (IBAction)showBigPic:(id)sender {
    
    UIImageView *imageView = [UIImageView new];
    imageView.bounds = CGRectMake(0,0,0,0);
    imageView.backgroundColor=[UIColor blackColor];
    
    imageView.center = CGPointMake(60, 60);
    //imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.headImage.currentBackgroundImage;
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture1:)];
    UIPanGestureRecognizer *gesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    [imageView addGestureRecognizer:gesture1];
    [imageView addGestureRecognizer:gesture2];
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    }];
    
}
- (void)handleGesture1:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    
    [UIView animateWithDuration:0.5 animations:^{
        view.bounds = CGRectMake(0,0,0,0);
        view.center = CGPointMake(60, 60);
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
- (IBAction)showDetail:(id)sender
{
 
    [self performSegueWithIdentifier:@"kaoqinDetail" sender:sender];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    urlStr=[urlStr stringByAppendingString:btn.titleLabel.text];
    UILabel *itemName=[self.lblItemName objectAtIndex:btn.tag-100];
    DDIKaoQinDetail *detial=segue.destinationViewController;
    detial.title=[NSString stringWithFormat:@"%@",itemName.text];
    detial.interfaceUrl=urlStr;
}
- (void) done{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    
    NSInteger row1 = [pickerView selectedRowInComponent:0];
	NSInteger row2 = [pickerView selectedRowInComponent:2];

	NSNumber *selected1 = [weekArray objectAtIndex:row1];
	NSNumber *selected2 = [weekArray objectAtIndex:row2];
    
    NSString *theTime=[NSString stringWithFormat:@"第%d周-第%d周",selected1.intValue,selected2.intValue];
    [self.pickWeeks setTitle:theTime forState:UIControlStateNormal];
    NSString *searchParam=[NSString stringWithFormat:@"?Week1=%d&Week2=%d",selected1.intValue,selected2.intValue];
    [self loadTitleData:searchParam];
    
}

- (void) docancel{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    
    
}
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 3;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if(component==0 || component==2)
        return weekArray.count;
    else
        return 1;
	
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
			titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component==0 || component==2)
    {
        NSNumber *sel=[weekArray objectAtIndex:row];
        return [NSString stringWithFormat:@"第%d周",sel.intValue];
    }
    else
        return @"至";
}


- (IBAction)openAcSheet:(id)sender {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSArray *strArray=[self.pickWeeks.titleLabel.text componentsSeparatedByString:@"-"];
    NSString *sel1=[strArray objectAtIndex:0];
    NSString *sel2=[strArray objectAtIndex:1];
    NSString *string1 = [sel1 substringWithRange:NSMakeRange(1, sel1.length-2)];
    NSString *string2 = [sel2 substringWithRange:NSMakeRange(1, sel2.length-2)];
    
    NSNumber *num1=[f numberFromString:string1];
    NSNumber *num2=[f numberFromString:string2];
    NSInteger row1=[weekArray indexOfObject:num1];
    NSInteger row2=[weekArray indexOfObject:num2];
   
    [pickerView selectRow:row1 inComponent:0 animated:NO];
    [pickerView selectRow:row2 inComponent:2 animated:NO];
    
    if(alertController)
        [self presentViewController:alertController animated:YES completion:nil];
    else
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    
}
-(IBAction)segmentAction:(UISegmentedControl *)Seg
{
    
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index) {
            
        case 0:
    
            [self loadTitleData:segUrl0];
            break;
        case 1:
      
            [self loadTitleData:segUrl1];
            break;
        default:
            break;
            
    }
    
}
@end
