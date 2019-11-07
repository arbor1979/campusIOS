//
//  DDIWenJuanDetail.m
//  掌上校园
//
//  Created by yons on 14-3-17.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import "DDIWenJuanDetail.h"
extern NSString *kUserIndentify;//用户登录后的唯一识别码
extern NSString *kInitURL;
extern CLLocationCoordinate2D stuLocation;
extern NSString *stuAddress;
extern int kSchoolId;
@interface DDIWenJuanDetail ()

@end

@implementation DDIWenJuanDetail

- (void)viewDidLoad
{
    [super viewDidLoad];

    requestArray=[NSMutableArray array];
    detailArray= [NSMutableArray array];
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    NSString *urlStr;
    if([[self.interfaceUrl lowercaseString] hasPrefix:@"http"])
        urlStr=self.interfaceUrl;
    else
        urlStr=[NSString stringWithFormat:@"%@InterfaceStudent/%@",kInitURL,self.interfaceUrl];
    self.interfaceUrl=urlStr;
    [self loadDetailData];
    
    myGreen=[UIColor colorWithRed:39/255.0 green:174/255.0 blue:98/255.0 alpha:1];
    //定义一个toolBar
    topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];
    
    
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAnswer)];
    savePath=[CommonFunc createPath:@"/wenJuanPic/"];
    addPhoto=[UIImage imageNamed:@"addPhoto"];
    
    pickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n" delegate:nil  cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    pickerActionSheet.backgroundColor=[UIColor whiteColor];
    [pickerActionSheet setBounds:CGRectMake(0, 0, 100, 160)];
    pickerView= [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 120)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *spacer=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width=20;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(docancel)];
    navItem.leftBarButtonItems = [NSArray arrayWithObjects:spacer,leftButton,nil];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    navItem.rightBarButtonItems =[NSArray arrayWithObjects:spacer,rightButton,nil];
    NSArray *array = [[NSArray alloc] initWithObjects:navItem, nil];
    [navBar setItems:array];
    
    [pickerActionSheet addSubview:navBar];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if([[[UIDevice currentDevice]systemVersion] floatValue] >=8.0)
    {
        alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        pickerView.frame=CGRectMake(0, 40, alertController.view.bounds.size.width-16, 200);
        navBar.frame=CGRectMake(0, 0, alertController.view.bounds.size.width-16, 40);
        
        [alertController.view addSubview:navBar];
        [alertController.view addSubview:pickerView];
    }
    
#endif
    
    //[actionSheet addSubview:pickerView];
    
    dtPickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 200)];
    // [oneDatePicker setDate:[NSDate dateWithTimeIntervalSinceNow:48 * 20 * 18] animated:YES]; // 设置时间，有动画效果
    //dtPickerView.timeZone = [NSTimeZone timeZoneWithName:@"GTM+8"]; // 设置时区，中国在东八区
    //oneDatePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:72 * 60 * 60 * -1]; // 设置最小时间
    //oneDatePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:72 * 60 * 60]; // 设置最大时间
    dtPickerView.datePickerMode = UIDatePickerModeDate; // 设置样式
    // 以下为全部样式
    // typedef NS_ENUM(NSInteger, UIDatePickerMode) {
    //    UIDatePickerModeTime,           // 只显示时间
    //    UIDatePickerModeDate,           // 只显示日期
    //    UIDatePickerModeDateAndTime,    // 显示日期和时间
    //    UIDatePickerModeCountDownTimer  // 只显示小时和分钟 倒计时定时器
    // };

    
}

- (void) done{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [pickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:senderBtn.tag]];
    
    if([dtPickerView.superview isKindOfClass:[UIView class]])
    {
        
        NSString *currentDateStr = [CommonFunc stringFromDateShort:dtPickerView.date];
        [senderBtn setTitle:currentDateStr forState:UIControlStateNormal];
        [item setValue:senderBtn.titleLabel.text forKey:@"用户答案"];
    }
    else if([pickerView.superview isKindOfClass:[UIView class]])
    {
        if([pickerView numberOfComponents]==1)
        {
            NSInteger index=[pickerView selectedRowInComponent:0];
            if(pickerArray.count>index)
            {
                NSString *currentDateStr = [pickerArray objectAtIndex:index];
                [senderBtn setTitle:currentDateStr forState:UIControlStateNormal];
                [item setValue:senderBtn.titleLabel.text forKey:@"用户答案"];
            }
        }
        else if([pickerView numberOfComponents]==2 )
        {
            if([[item objectForKey:@"类型"] isEqualToString:@"二级下拉"])
            {
                NSInteger index=[pickerView selectedRowInComponent:0];
                NSString *currentDateStr = [pickerArray objectAtIndex:index];
                [item setValue:currentDateStr forKey:@"用户答案一级"];
                NSInteger index2=[pickerView selectedRowInComponent:1];
                NSDictionary *element=[pickerSubArray objectAtIndex:index2];
                if(element!=nil)
                {
                    [senderBtn setTitle:[element objectForKey:@"name"] forState:UIControlStateNormal];
                    [item setValue:[element objectForKey:@"id"] forKey:@"用户答案"];
                }
            }
            else if([[item objectForKey:@"类型"] isEqualToString:@"弹出列表"])
            {
                NSInteger index2=[pickerView selectedRowInComponent:1];
                NSDictionary *element=[pickerSubArray objectAtIndex:index2];
                NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
                if(element!=nil)
                {
                    NSString *selid=[element objectForKey:@"id"];
                    bool flag=false;
                    for(int i=0;i<answerArray.count;i++)
                    {
                        NSMutableDictionary *answerItem=[NSMutableDictionary dictionaryWithDictionary:[answerArray objectAtIndex:i]];
                        NSString *idstr=[answerItem objectForKey:@"id"];
                        if([idstr isEqualToString:selid])
                        {
                            flag=true;
                            NSString *numstr=[answerItem objectForKey:@"num"];
                            numstr=[NSString stringWithFormat:@"%d",numstr.intValue+1];
                            [answerItem setObject:numstr forKey:@"num"];
                            NSString *pricestr=[answerItem objectForKey:@"price"];
                            NSString *jinestr=[NSString stringWithFormat:@"%.1f",numstr.intValue*pricestr.floatValue];
                            [answerItem setObject:jinestr forKey:@"jine"];
                            [answerArray replaceObjectAtIndex:i withObject:answerItem];
                            [item setObject:answerArray forKey:@"用户答案"];
                            [detailArray replaceObjectAtIndex:senderBtn.tag withObject:item];
                            break;
                        }
                    }
                    if(!flag)
                    {
                        [answerArray addObject:element];
                        [item setObject:answerArray forKey:@"用户答案"];
                        [detailArray replaceObjectAtIndex:senderBtn.tag withObject:item];
                    }
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:senderBtn.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
        else if([pickerView numberOfComponents]==3 )
        {
            if([[item objectForKey:@"类型"] isEqualToString:@"三级下拉"])
            {
                NSInteger index3=[pickerView selectedRowInComponent:2];
                NSDictionary *element=[pickerThirdArray objectAtIndex:index3];
                if(element!=nil)
                {
                    NSString *value1=[pickerArray objectAtIndex:[pickerView selectedRowInComponent:0]];
                    NSString *value2=[pickerSubArray objectAtIndex:[pickerView selectedRowInComponent:1]];
                    NSString *titlename=[NSString stringWithFormat:@"%@%@%@",value1,value2,[element objectForKey:@"name"]];
                    [senderBtn setTitle:titlename forState:UIControlStateNormal];
                    [item setValue:[element objectForKey:@"id"] forKey:@"用户答案"];
                }
            }
        }
        
    }
    
    [detailArray replaceObjectAtIndex:senderBtn.tag withObject:item];
    
}

- (void) docancel{
    if(alertController)
        [alertController dismissViewControllerAnimated:YES completion:nil];
    else
        [pickerActionSheet dismissWithClickedButtonIndex:1 animated:YES];
    
}


-(void) saveAnswer
{
    if(detailArray.count==0)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有可保存的数据"];
        [tipView show];
        return;
    }
    NSMutableArray *result=[NSMutableArray new];
    for (int i=0; i<detailArray.count; i++) {
        NSDictionary *item=[detailArray objectAtIndex:i];
        NSString *ifNeed=[item objectForKey:@"是否必填"];
        if(ifNeed==nil || [ifNeed isEqual:[NSNull null]])
            ifNeed=@"否";
        if([[item objectForKey:@"类型"] isEqualToString:@"图片"] || [[item objectForKey:@"类型"] isEqualToString:@"附件"] || [[item objectForKey:@"类型"] isEqualToString:@"弹出列表"] || [[item objectForKey:@"类型"] isEqualToString:@"弹出多选"])
        {
            NSArray *answer=[item objectForKey:@"用户答案"];
            if((!answer || [answer isEqual:[NSNull null]] || answer.count==0) && [ifNeed isEqualToString:@"是"])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"请填写带*必填项"];
                [tipView show];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            [result addObject:answer];
        }
        else
        {
            NSString *title=[item objectForKey:@"题目"];
            NSString *answer=[item objectForKey:@"用户答案"];
            if((!answer || [answer isEqual:[NSNull null]] || answer.length==0) && [ifNeed isEqualToString:@"是"])
            {
                OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"请填写带*必填项"];
                [tipView show];
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            NSString *validate=[item objectForKey:@"校验"];
            if(validate!=nil && answer!=nil && answer.length>0)
            {
                NSString *errMsg=@"";
                if([validate isEqualToString:@"手机号"] && ![CommonFunc isValidateMobile:answer])
                {
                    errMsg=[NSString stringWithFormat:@"%@,格式必须是11位手机号",title];
                }
                else if([validate isEqualToString:@"浮点型"] && ![CommonFunc isPureFloat:answer])
                    errMsg=[NSString stringWithFormat:@"%@,格式必须是浮点型",title];
                else if([validate isEqualToString:@"整型"] && ![CommonFunc isPureInt:answer])
                    errMsg=[NSString stringWithFormat:@"%@,格式必须是整型",title];
                else if([validate isEqualToString:@"邮箱"] && ![CommonFunc isValidateEmail:answer])
                    errMsg=[NSString stringWithFormat:@"%@,邮箱格式不正确",title];
                if(errMsg.length>0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:errMsg];
                    [tipView show];
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
            
            }
            NSString *lengthLim=[item objectForKey:@"字符数"];
            if(lengthLim!=nil && answer!=nil)
            {
                NSInteger len=lengthLim.intValue;
                if(answer.length>len)
                {
                    NSString *errMsg=[NSString stringWithFormat:@"%@,字符数不能超过%@",title,lengthLim];
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:errMsg];
                    [tipView show];
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:i];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    return;
                }
                
            }
            if(answer==nil)
                answer=@"";
            [result addObject:answer];
        }
        
    }
    rightBtn.enabled=false;
    [rightBtn setTitle:@"保存中"];
    NSArray *tmp=[_interfaceUrl componentsSeparatedByString:@"?"];
    NSString *urlStr=[tmp objectAtIndex:0];
    urlStr=[urlStr stringByAppendingString:saveUrl];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:result forKey:@"选项记录集"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    if([_gpsLocation isEqualToString:@"是"])
    {
        NSString *gps=[NSString stringWithFormat:@"lat=%f;lon=%f\n%@",stuLocation.latitude,stuLocation.longitude,stuAddress];
        [dic setObject:gps forKey:@"GPS定位"];
    }
    NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"保存数据";
    [request startAsynchronous];
    [requestArray addObject:request];
    
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
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *resultstr=[dict objectForKey:@"结果"];
        if(dict && (resultstr==nil || resultstr.length==0))
        {
            self.title=[dict objectForKey:@"标题显示"];
            saveUrl=[dict objectForKey:@"提交地址"];
            detailArray=[NSMutableArray arrayWithArray:[dict objectForKey:@"调查问卷数值"]];
            NSString *autoClose=[dict objectForKey:@"自动关闭"];
            if(autoClose) _autoClose=autoClose;
            NSString *status=[dict objectForKey:@"调查问卷状态"];
            if(status) _examStatus=status;
            NSString *gps=[dict objectForKey:@"GPS定位"];
            if(gps) _gpsLocation=gps;
            if([_examStatus isEqualToString:@"进行中"])
                enabled=true;
            else
                enabled=false;
            if(enabled)
                self.navigationItem.rightBarButtonItem =rightBtn;
            if([_gpsLocation isEqualToString:@"是"])
            {
                DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
                [app getGPS];
            }
        }
        if(!dict || !detailArray || detailArray.count==0)
        {
            enabled=false;
            NSString *errmsg=@"";
            if(resultstr && resultstr.length>0)
                errmsg=resultstr;
            else
                errmsg=@"没有任何数据";
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:errmsg];
            [tipView showInView:self.view];
        }
        else
        {
            for(int i=0;i<detailArray.count;i++)
            {
                NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:i]];
                
                NSString *guanlianStr=[item objectForKey:@"关联更新"];
                NSString *answer=[item objectForKey:@"用户答案"];
                NSArray *options=[item objectForKey:@"选项"];
                
                if(guanlianStr!=nil && guanlianStr.intValue>0)
                {
                    if(answer==nil || answer.length==0)
                        answer=[options objectAtIndex:0];
                    if(answer==nil)
                        answer=@"";
                    NSInteger index=guanlianStr.intValue;
                    NSMutableDictionary *guanlianItem=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:index]];
                    NSDictionary *json=[guanlianItem objectForKey:@"Json过滤"];
                    
                    for(NSString *key in json)
                    {
                        if([key isEqualToString:answer])
                        {
                            NSArray *newoptions=[json objectForKey:key];
                            if(newoptions==nil) newoptions=[NSArray array];
                            [guanlianItem setObject:newoptions forKey:@"选项"];
                            NSString *defsel=[newoptions objectAtIndex:0];
                            if(defsel==nil) defsel=@"";
                            [guanlianItem setObject:defsel forKey:@"用户答案"];
                            [detailArray replaceObjectAtIndex:index withObject:guanlianItem];
                            break;
                        }
                    }
                }
                
            }
            [self.tableView reloadData];
        }
    }
    else if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *result=[dict objectForKey:@"状态"];
        if([result isEqualToString:@"成功"] || [[dict objectForKey:@"结果"] isEqualToString:@"成功"])
        {
            result=@"已保存";
            /*
            NSDictionary *outData=[dict objectForKey:@"输出数据"];
            if(outData && outData.count>0)
            {
                detailArray=[NSMutableArray arrayWithArray:[outData objectForKey:@"调查问卷数值"]];
                _examStatus=[outData objectForKey:@"调查问卷状态"];
                if([_examStatus isEqualToString:@"进行中"])
                    enabled=true;
                else
                    enabled=false;
                if(!enabled)
                    self.navigationItem.rightBarButtonItem =Nil;
                [self.tableView reloadData];
                NSString *secLine=@"";
                outData=[dict objectForKey:@"调查问卷列表"];
                if(outData)
                {
                    NSArray *valueArray=[outData objectForKey:@"调查问卷数值"];
                    if(valueArray)
                    {
                        NSDictionary *tmpDic=[valueArray objectAtIndex:_key];
                        if(tmpDic)
                            secLine=[tmpDic objectForKey:@"第二行之日期"];
                    }
                    
                }
                
                if(_key>-1 && _examStatus)
                {
                    NSMutableDictionary *item=[[NSMutableDictionary alloc]initWithDictionary:[_parentTitleArray objectAtIndex:_key]];
                    [item setObject:_examStatus forKey:@"第二行之状态"];
                    if(secLine && secLine.length>0)
                        [item setObject:secLine forKey:@"第二行之日期"];
                    [_parentTitleArray replaceObjectAtIndex:_key withObject:item];
                    
                }
                
            }
            */
            NSString *autoClose=[dict objectForKey:@"自动关闭"];
            if(autoClose) _autoClose=autoClose;
            if(_autoClose && [_autoClose isEqualToString:@"是"])
            {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshDetail" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"needRefreshTitle" object:nil];
                return;
            }
            
        }
        else
        {
            if([dict objectForKey:@"结果"]!=nil)
                result=[NSString stringWithFormat:@"保存失败:%@",[dict objectForKey:@"结果"]];
        }
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
        [tipView show];
    }
    else if([request.username isEqualToString:@"上传问卷调查"])
    {
        if(rpv) [rpv removeFromSuperview];
        if(alertTip)
            [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            
            NSDictionary *dic=request.userInfo;
            NSData *data=[dic objectForKey:@"data"];
            NSString *filename=[dict objectForKey:@"文件名"];
            NSString *filepath=[savePath stringByAppendingString:filename];
            [data writeToFile:filepath atomically:YES];
            NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:curRowIndex]];
            NSMutableArray *photosArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
            if([[item objectForKey:@"类型"] isEqualToString:@"附件"])
            {
                NSMutableDictionary *newdict=[NSMutableDictionary dictionary];
                [newdict setObject:filename forKey:@"name"];
                [newdict setObject:filename forKey:@"newname"];
                [newdict setObject:[dict objectForKey:@"文件地址"] forKey:@"url"];
                [photosArray addObject:newdict];
            }
            else
                [photosArray addObject:dict];
            [item setObject:photosArray forKey:@"用户答案"];
            [detailArray replaceObjectAtIndex:curRowIndex withObject:item];
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:curRowIndex];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }
    if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *img=[[UIImage alloc]initWithData:datas];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [datas writeToFile:filename atomically:YES];
        UITableViewCell *parentCell=[item objectForKey:@"parentCell"];
        UIButton *btn=(UIButton *)[parentCell.contentView viewWithTag:request.tag];
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
    if([request.username isEqualToString:@"删除图片"])
    {
        NSDictionary *dict=request.userInfo;
        NSString *filename=[dict objectForKey:@"文件名"];
        if(filename==nil || filename.length==0)
            filename=[dict objectForKey:@"newname"];
        filename=[savePath stringByAppendingString:filename];
        [CommonFunc deleteFile:filename];
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:curRowIndex]];
        NSMutableArray *photosArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
        [photosArray removeObject:dict];
        [item setObject:photosArray forKey:@"用户答案"];
        [detailArray replaceObjectAtIndex:curRowIndex withObject:item];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:curRowIndex];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
        [alertTip removeFromSuperview];
    if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
    }
    if([request.username isEqualToString:@"上传问卷调查"])
    {
        if(rpv) [rpv removeFromSuperview];
        if(alertTip) [alertTip removeFromSuperview];
    }
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
    return detailArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rCell";
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 20)];
        [titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [titleLabel setNumberOfLines:0];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        titleLabel.backgroundColor=[UIColor clearColor];
        [titleLabel setTag:201];
        
        [[cell contentView] addSubview:titleLabel];
        
        UILabel *lblResult=[[UILabel alloc]initWithFrame:CGRectZero];
        lblResult.tag=200;
        [lblResult setNumberOfLines:0];
        [lblResult setFont:[UIFont systemFontOfSize:15]];
        lblResult.backgroundColor=[UIColor clearColor];
        [[cell contentView] addSubview:lblResult];
    }
    
    float curY=0;
    NSString *groupId=[NSString stringWithFormat:@"%d",(int)indexPath.section];
    NSDictionary *item=[detailArray objectAtIndex:indexPath.section];
    NSString *type=[item objectForKey:@"类型"];
    Boolean readonly=false;
    if([[item objectForKey:@"只读"] isEqualToString:@"是"])
        readonly=true;
    Boolean thisenabled=true;
    if(enabled && !readonly)
        thisenabled=true;
    else
        thisenabled=false;
    for(UIView *subView in cell.contentView.subviews)
    {
        if([subView isKindOfClass:[QRadioButton class]])
        {
            [subView removeFromSuperview];
        }
        if([subView isKindOfClass:[QCheckBox class]])
        {
            [subView removeFromSuperview];
        }
        if([subView isKindOfClass:[UITextView class]])
            [subView removeFromSuperview];
        if([subView isKindOfClass:[UIButton class]])
            [subView removeFromSuperview];
        
        
    }
    UILabel *titleLabel=(UILabel *)[cell viewWithTag:201];
    [titleLabel setFrame:CGRectMake(10, 10, self.view.frame.size.width-20, cell.frame.size.height-10)];
    NSString *ifneedinput=[item objectForKey:@"是否必填"];
    NSString *titleStr=[item objectForKey:@"题目"];
    NSString *addstr=@"";
    if(ifneedinput!=nil && [ifneedinput isEqualToString:@"是"] && [titleStr rangeOfString:@"*"].location==NSNotFound)
        addstr=@"*";
    //NSLog(@"class name>>%@",NSStringFromClass([titleLabel class]));
    titleLabel.text=[NSString stringWithFormat:@"%d.%@%@",(int)indexPath.section+1,titleStr,addstr];
    [titleLabel sizeToFit];
    curY=titleLabel.frame.size.height+10;
    NSArray *abcArray=[item objectForKey:@"选项"];
    for(int i=0;i<abcArray.count;i++)
    {
        
        NSString *neirong=[abcArray objectAtIndex:i];
        if(neirong==nil || [neirong isKindOfClass:[NSNull class]] || neirong.length==0)
            continue;
        
        if([type isEqualToString:@"单选"])
        {
            
            QRadioButton *bodybtn = [[QRadioButton alloc] initWithDelegate:self groupId:groupId];
            bodybtn.tag=12+i;
            bodybtn.enabled=thisenabled;
            [bodybtn setFrame:CGRectMake(20, curY, self.view.frame.size.width-40, 25)];
            
            UILabel *detailLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, bodybtn.frame.size.width-20, 20)];
            [detailLabel setTextColor:[UIColor darkGrayColor]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            
            [detailLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [detailLabel setNumberOfLines:0];
            detailLabel.tag=100;
            [bodybtn addSubview:detailLabel];
            //bodybtn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
            //[bodybtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:bodybtn];
            
            
            detailLabel.text=neirong;
            [detailLabel sizeToFit];
            
            [bodybtn setFrame:CGRectMake(20, curY, self.view.frame.size.width-40, detailLabel.frame.size.height+10)];
            curY=curY+bodybtn.frame.size.height+5;
            
            NSString *myAnswer=[item objectForKey:@"用户答案"];
            if([myAnswer isEqual:[NSNull null]])
                myAnswer=@"";
            if([myAnswer isEqualToString:neirong])
            {
                bodybtn.checked=YES;
            }
            else
                bodybtn.checked=NO;
        }
        else if([type isEqualToString:@"多选"])
        {

            QCheckBox *bodybtn = [[QCheckBox alloc] initWithDelegate:self];
            bodybtn.enabled=thisenabled;
            [bodybtn setTag:12+i];
            [bodybtn setFrame:CGRectMake(20, curY, self.view.frame.size.width-40, 25)];
            
            UILabel *detailLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, bodybtn.frame.size.width-20, 20)];
            [detailLabel setTextColor:[UIColor darkGrayColor]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            
            [detailLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [detailLabel setNumberOfLines:0];
            detailLabel.tag=100;
            [bodybtn addSubview:detailLabel];
            
            
            bodybtn.titleLabel.tag=indexPath.section;
            
            //[bodybtn addTarget:self action:@selector(answerClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:bodybtn];
            
            detailLabel.text=neirong;
            [detailLabel sizeToFit];
            
            [bodybtn setFrame:CGRectMake(20, curY, self.view.frame.size.width-40, detailLabel.frame.size.height+10)];
            curY=curY+bodybtn.frame.size.height+5;
            
            NSString *myAnswer=[item objectForKey:@"用户答案"];
            if([myAnswer isEqual:[NSNull null]])
                myAnswer=@"";
            NSArray *answerArray=[myAnswer componentsSeparatedByString:@"@"];
            if([answerArray containsObject:neirong])
                bodybtn.checked=YES;
            else
                bodybtn.checked=NO;
            
            
        }
        
    }
    
    if([type isEqualToString:@"单行文本输入框"])
    {
        NSNumber *lines=[item objectForKey:@"行数"];
        CGFloat textVheight=100;
        if(lines.intValue>0)
            textVheight=lines.intValue*20;
        UITextView *txtView=[[UITextView alloc] initWithFrame:CGRectMake(10,curY+5,self.view.frame.size.width-20,textVheight)];
        txtView.tag=indexPath.section;
        txtView.editable=thisenabled;
        txtView.font=[UIFont systemFontOfSize:15];
        txtView.delegate=self;
        [txtView setInputAccessoryView:topView];
        txtView.layer.borderWidth=1.0;
        txtView.layer.borderColor=[UIColor grayColor].CGColor;
        txtView.layer.cornerRadius=5.0;
        [[cell contentView] addSubview:txtView];
        txtView.text=[item objectForKey:@"用户答案"];
        curY=curY+txtView.frame.size.height+15;

    }
    
    if([type isEqualToString:@"日期"])
    {
         UIButton *dateBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,self.view.frame.size.width-20,25)];
        dateBtn.tag=indexPath.section;
        dateBtn.enabled=thisenabled;
        [dateBtn setTitle:[item objectForKey:@"用户答案"] forState:UIControlStateNormal];
        [dateBtn setTitleColor:dateBtn.tintColor forState:UIControlStateNormal];
        [dateBtn addTarget:self action:@selector(popDatePicker:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:dateBtn];
        curY=curY+dateBtn.frame.size.height+15;
    }
    
    if([type isEqualToString:@"下拉"])
    {
        UIButton *comboBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,self.view.frame.size.width-20,25)];
        comboBtn.tag=indexPath.section;
        comboBtn.enabled=thisenabled;
        NSString *daan=[item objectForKey:@"用户答案"];
        if(daan==nil || daan.length==0)
            [comboBtn setTitle:@"请选择"forState:UIControlStateNormal];
        else
            [comboBtn setTitle:[item objectForKey:@"用户答案"] forState:UIControlStateNormal];
        [comboBtn setTitleColor:comboBtn.tintColor forState:UIControlStateNormal];
        [comboBtn addTarget:self action:@selector(popComboPicker:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:comboBtn];
        curY=curY+comboBtn.frame.size.height+15;
    }
    
    if([type isEqualToString:@"图片"])
    {
        float top=curY+5;
        curY=curY+65;
        [self drawImageFromArray:cell curRow:(int)indexPath.section top:top thisenabled:thisenabled];
    }
    if([type isEqualToString:@"附件"])
    {
        float top=curY+5;
        float fujianheight=[self drawFujianFromArray:cell curRow:(int)indexPath.section top:top];
        curY=curY+fujianheight;
    }
    if([type isEqualToString:@"弹出列表"])
    {
        float top=curY+5;
        float fujianheight=[self drawPeijianFromArray:cell curRow:(int)indexPath.section top:top];
        curY=curY+fujianheight;
    }
    if([type isEqualToString:@"二级下拉"])
    {
        UIButton *comboBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,self.view.frame.size.width-20,25)];
        comboBtn.tag=indexPath.section;
        comboBtn.enabled=thisenabled;
        NSString *btntitle=[item objectForKey:@"用户答案"];
        NSString *firstanswer=[item objectForKey:@"用户答案一级"];
        NSDictionary *subitem=[item objectForKey:@"子选项"];
        for(NSString *key in subitem)
        {
            if([key isEqualToString:firstanswer])
            {
                NSArray *subarray=[subitem objectForKey:key];
                for(int i=0;i<subarray.count;i++)
                {
                    NSDictionary *element=[subarray objectAtIndex:i];
                    NSString *idstr=[element objectForKey:@"id"];
                    NSString *namestr=[element objectForKey:@"name"];
                    if(idstr!=nil && [idstr isEqualToString:btntitle])
                    {
                        btntitle=namestr;
                        break;
                    }
                    
                }
                break;
            }
        }
        
        //[comboBtn setImage:dropArrow forState:UIControlStateNormal];
        comboBtn.imageEdgeInsets=UIEdgeInsetsMake(0, comboBtn.frame.size.width-30, 0, 0);
        if(btntitle==nil || btntitle.length==0)
            [comboBtn setTitle:@"请选择"forState:UIControlStateNormal];
        else
            [comboBtn setTitle:btntitle forState:UIControlStateNormal];
        
        [comboBtn setTitleColor:comboBtn.tintColor forState:UIControlStateNormal];
        [comboBtn addTarget:self action:@selector(popComboPickerTwo:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:comboBtn];
        curY=curY+comboBtn.frame.size.height+15;
    }
    if([type isEqualToString:@"三级下拉"])
    {
        UIButton *comboBtn=[[UIButton alloc] initWithFrame:CGRectMake(10,curY+5,self.view.frame.size.width-20,25)];
        comboBtn.tag=indexPath.section;
        comboBtn.enabled=thisenabled;
        NSString *btntitle=[item objectForKey:@"用户答案"];
        NSDictionary *subitem=[item objectForKey:@"子选项"];
        for(NSString *key in subitem)
        {
            NSDictionary *subdic=[subitem objectForKey:key];
            for(NSString *subkey in subdic)
            {
                NSArray *thirdarray=[subdic objectForKey:subkey];
                for(int i=0;i<thirdarray.count;i++)
                {
                    NSDictionary *element=[thirdarray objectAtIndex:i];
                    NSString *idstr=[element objectForKey:@"id"];
                    NSString *namestr=[element objectForKey:@"name"];
                    if(idstr!=nil && [idstr isEqualToString:btntitle])
                    {
                        btntitle=[NSString stringWithFormat:@"%@%@%@",key,subkey,namestr];
                        break;
                    }
                }
            }
        }
        //[comboBtn setImage:dropArrow forState:UIControlStateNormal];
        comboBtn.imageEdgeInsets=UIEdgeInsetsMake(0, comboBtn.frame.size.width-30, 0, 0);
        if(btntitle==nil || btntitle.length==0)
            [comboBtn setTitle:@"请选择"forState:UIControlStateNormal];
        else
            [comboBtn setTitle:btntitle forState:UIControlStateNormal];
        [comboBtn setTitleColor:comboBtn.tintColor forState:UIControlStateNormal];
        [comboBtn addTarget:self action:@selector(popComboPickerThree:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:comboBtn];
        curY=curY+comboBtn.frame.size.height+15;
    }
    if([type isEqualToString:@"弹出多选"])
    {
        float top=curY+5;
        float fujianheight=[self drawStudentFromArray:cell curRow:(int)indexPath.section top:top];
        curY=curY+fujianheight;
    }
    NSString *beizhu=[item objectForKey:@"备注"];
    UILabel *lblResult=(UILabel *)[cell viewWithTag:200];
    if(beizhu!=nil && [beizhu stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length>0)
    {
        [lblResult setFrame:CGRectMake(20, curY, self.view.frame.size.width-40, 20)];
        lblResult.text=beizhu;
        [lblResult sizeToFit];
        curY=curY+lblResult.frame.size.height+5;
        if(lblResult.text.length>=7 && [[lblResult.text substringToIndex:7] isEqualToString:@"答题状态:错误"])
            [lblResult setTextColor:[UIColor redColor]];
        else if(lblResult.text.length>=7 && [[lblResult.text substringToIndex:7] isEqualToString:@"答题状态:正确"])
            [lblResult setTextColor:myGreen];
        else
            [lblResult setTextColor:[UIColor blueColor]];
    }
    else
        [lblResult setFrame:CGRectZero];
    /*
    else
    {
        UILabel *lblResult=(UILabel *)[cell viewWithTag:100];
        lblResult.text=@"";
    }
    */
    [cell setFrame:CGRectMake(0, 0, 320, curY)];
    return cell;
}
-(void)popDatePicker:(UIButton *)sender
{
    senderBtn=sender;
    
    dtPickerView.date = [CommonFunc dateFromStringShort:sender.titleLabel.text]; // 设置初始时间
    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    NSArray *subitem=[item objectForKey:@"选项"];
    if(subitem.count==2)
    {
        NSDate *minDate=[CommonFunc dateFromStringShort:[subitem objectAtIndex:0]];
        NSDate *maxDate=[CommonFunc dateFromStringShort:[subitem objectAtIndex:1]];
        dtPickerView.minimumDate=minDate;
        dtPickerView.maximumDate=maxDate;
    }
    if(alertController)
    {
        for(UIView *item in alertController.view.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [alertController.view addSubview:dtPickerView];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    else
    {
        for(UIView *item in pickerActionSheet.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }

        [pickerActionSheet addSubview:dtPickerView];
        [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}

-(void)popComboPicker:(UIButton *)sender
{
    senderBtn=sender;
    pickerDict=nil;
    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    pickerArray=[item objectForKey:@"选项"];
    if(pickerArray==nil)
        pickerArray=[NSArray arrayWithObject:@""];
    [pickerView reloadAllComponents];
    NSInteger index=0;
    if(sender.titleLabel.text.length>0)
        index=[pickerArray indexOfObject:sender.titleLabel.text];
    if(index>=pickerArray.count)
        index=0;
    [pickerView selectRow:index inComponent:0 animated:NO];
    if(alertController)
    {
        for(UIView *item in alertController.view.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [alertController.view addSubview:pickerView];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    else
    {
        for(UIView *item in pickerActionSheet.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [pickerActionSheet addSubview:pickerView];
        [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
-(void)popComboPickerTwo:(UIButton *)sender
{
    senderBtn=sender;
    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    pickerArray=[item objectForKey:@"选项"];
    if(pickerArray==nil)
        pickerArray=[NSArray array];
    pickerDict=[item objectForKey:@"子选项"];
    [pickerView reloadAllComponents];
    
    NSInteger index1=0;
    NSInteger index2=0;
    NSString *answer=[item objectForKey:@"用户答案"];
    for(NSString *key in pickerDict)
    {
        NSArray *secondarray=[pickerDict objectForKey:key];
        for(int i=0;i<secondarray.count;i++)
        {
            NSDictionary *element=[secondarray objectAtIndex:i];
            NSString *idstr=[element objectForKey:@"id"];
            if(idstr!=nil && [idstr isEqualToString:answer])
            {
                index2=i;
                index1=[pickerArray indexOfObject:key];
                break;
            }
        }
    }
    if(index1<0 || index1>=pickerArray.count)
        index1=0;
    
    [pickerView selectRow:index1 inComponent:0 animated:NO];
    NSString *value1=[pickerArray objectAtIndex:index1];
    pickerSubArray=[pickerDict objectForKey:value1];
    [pickerView reloadComponent:1];
    [pickerView selectRow:index2 inComponent:1 animated:NO];
    if(alertController)
    {
        for(UIView *item in alertController.view.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [alertController.view addSubview:pickerView];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    else
    {
        for(UIView *item in pickerActionSheet.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [pickerActionSheet addSubview:pickerView];
        [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
-(void)popComboPickerThree:(UIButton *)sender
{
    senderBtn=sender;
    NSDictionary *item=[detailArray objectAtIndex:sender.tag];
    pickerArray=[item objectForKey:@"选项"];
    if(pickerArray==nil)
        pickerArray=[NSArray array];
    pickerDict=[item objectForKey:@"子选项"];
    [pickerView reloadAllComponents];
    
    NSInteger index1=0;
    NSInteger index2=0;
    NSInteger index3=0;
    NSString *answer=[item objectForKey:@"用户答案"];
    for(NSString *key in pickerDict)
    {
        NSDictionary *subdic=[pickerDict objectForKey:key];
        for(NSString *subkey in subdic)
        {
            NSArray *thirdarray=[subdic objectForKey:subkey];
            for(int i=0;i<thirdarray.count;i++)
            {
                NSDictionary *element=[thirdarray objectAtIndex:i];
                NSString *idstr=[element objectForKey:@"id"];
                if(idstr!=nil && [idstr isEqualToString:answer])
                {
                    index3=i;
                    index2=[subdic.allKeys indexOfObject:subkey];
                    index1=[pickerArray indexOfObject:key];
                    break;
                }
            }
        }
    }
    if(index1<0 || index1>=pickerArray.count)
        index1=0;
    
    [pickerView selectRow:index1 inComponent:0 animated:NO];
    NSString *value1=[pickerArray objectAtIndex:index1];
    NSDictionary *secondDic=[pickerDict objectForKey:value1];
    pickerSubArray=[secondDic allKeys];
    [pickerView reloadComponent:1];
    
   
    if(index2<0 || index2>=pickerSubArray.count)
        index2=0;
    [pickerView selectRow:index2 inComponent:1 animated:NO];
    
    NSString *value2=[pickerSubArray objectAtIndex:index2];
    pickerThirdArray=[secondDic objectForKey:value2];
    [pickerView reloadComponent:2];
    
    if(index3>=0)
        [pickerView selectRow:index3 inComponent:2 animated:NO];
    
    if(alertController)
    {
        for(UIView *item in alertController.view.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [alertController.view addSubview:pickerView];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        for(UIView *item in pickerActionSheet.subviews)
        {
            if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
            {
                [item removeFromSuperview];
            }
        }
        [pickerActionSheet addSubview:pickerView];
        [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}
-(void)popComboPickerTwoPeijian:(UIButton *)sender
{
    NSInteger delindex=sender.tag-101;
    senderBtn=sender;
    senderBtn.tag=sender.superview.tag;
    NSInteger curindex=sender.superview.tag;
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:curindex]];
    if([sender.titleLabel.text isEqualToString:@"添加一行"])
    {
        NSDictionary *json=[item objectForKey:@"Json过滤"];
        NSMutableArray *keys=[NSMutableArray array];
        
        for(NSString *key in json)
        {
            [keys addObject:key];
        }
        pickerArray=keys;
        pickerDict=json;
        [pickerView reloadAllComponents];
        NSString *value1=[pickerArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        pickerSubArray=[pickerDict objectForKey:value1];
        if(pickerSubArray==nil)
            pickerSubArray=[NSArray array];
        [pickerView reloadComponent:1];
        
        if(alertController)
        {
            for(UIView *item in alertController.view.subviews)
            {
                if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
                {
                    [item removeFromSuperview];
                }
            }
            [alertController.view addSubview:pickerView];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
        else
        {
            for(UIView *item in pickerActionSheet.subviews)
            {
                if([item isKindOfClass:[UIDatePicker class]] || [item isKindOfClass:[UIPickerView class]])
                {
                    [item removeFromSuperview];
                }
            }
            [pickerActionSheet addSubview:pickerView];
            [pickerActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    }
    else
    {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"是否确认删除此行？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
            [answerArray removeObjectAtIndex:delindex];
            [item setObject:answerArray forKey:@"用户答案"];
            [self->detailArray replaceObjectAtIndex:curindex withObject:item];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:curindex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark 实现协议UIPickerViewDataSource方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if(pickerDict!=nil)
    {
        NSString *key=[pickerArray objectAtIndex:0];
        if([[pickerDict objectForKey:key] isKindOfClass:[NSDictionary class]])
            return 3;
        else
            return 2;
    }
    else
        return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if(component==0)
        return pickerArray.count;
    else if(component==1)
    {
        if(pickerSubArray!=nil)
            return pickerSubArray.count;
        else
            return 0;
    }
    else if(component==2)
    {
        if(pickerThirdArray!=nil)
            return pickerThirdArray.count;
        else
            return 0;
    }
    return 0;
}
#pragma mark 实现协议UIPickerViewDelegate方法
-(NSString *)pickerView:(UIPickerView *)pickerView
            titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(component==0)
    {
        if(row>pickerArray.count-1)
            return @"";
        else
            return [pickerArray objectAtIndex:row];
    }
    else if(component==1)
    {
        if(pickerSubArray!=nil)
        {
            if([[pickerSubArray objectAtIndex:row] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *item=[pickerSubArray objectAtIndex:row];
                return [item objectForKey:@"name"];
            }
            else
            {
                NSString *item=[pickerSubArray objectAtIndex:row];
                return item;
            }
        }
        else
            return @"";
    }
    else if(component==2)
    {
        if(pickerThirdArray!=nil)
        {
            NSDictionary *item=[pickerThirdArray objectAtIndex:row];
            return [item objectForKey:@"name"];
        }
        else
            return @"";
    }
    else
        return @"";
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component==0 && pickerDict!=nil)
    {
        NSString *value1=[pickerArray objectAtIndex:row];
        if([[pickerDict objectForKey:value1] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *secondDic=[pickerDict objectForKey:value1];
            pickerSubArray=[secondDic allKeys];
        }
        else
            pickerSubArray=[pickerDict objectForKey:value1];
        [pickerView reloadComponent:1];
        if([pickerView numberOfComponents]==3)
        {
            NSString *value2=[pickerSubArray objectAtIndex:0];
            NSDictionary *secondDic=[pickerDict objectForKey:value1];
            pickerThirdArray=[secondDic objectForKey:value2];
            [pickerView reloadComponent:2];
        }
    }
    else if(component==1 && pickerSubArray!=nil)
    {
        if([[pickerSubArray objectAtIndex:row] isKindOfClass:[NSString class]])
        {
            NSString *value2=[pickerSubArray objectAtIndex:row];
            NSInteger index1=[pickerView selectedRowInComponent:0];
            NSString *value1=[pickerArray objectAtIndex:index1];
            NSDictionary *secondDic=[pickerDict objectForKey:value1];
            pickerThirdArray=[secondDic objectForKey:value2];
            [pickerView reloadComponent:2];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId
{
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:groupId.intValue]];
    UILabel *detailLabel=(UILabel *)[radio viewWithTag:100];
    [item setValue:detailLabel.text forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:groupId.intValue withObject:item];
    NSString *str=[item objectForKey:@"关联更新"];
    if(str!=nil && str.intValue>0)
    {
        NSInteger index=str.intValue;
        NSMutableDictionary *nextItem=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:index]];
        NSDictionary *jsonData=[nextItem objectForKey:@"Json过滤"];
        if(jsonData!=nil && jsonData.count>0)
        {
            NSArray *options=[jsonData objectForKey:detailLabel.text];
            if(options==nil)
                options=[NSArray arrayWithObject:@""];
            
            [nextItem setObject:options forKey:@"选项"];
            NSString *answer=[options objectAtIndex:0];
            if(answer==nil)
                answer=@"";
            [nextItem setObject:answer forKey:@"用户答案"];
            [detailArray replaceObjectAtIndex:index withObject:nextItem];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
        
}
- (void)didSelectedCheckBox:(QCheckBox *)checkbox checked:(BOOL)checked
{
    UILabel *detailLabel=(UILabel *)[checkbox viewWithTag:100];
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:checkbox.titleLabel.tag]];
    NSString *answer=[item objectForKey:@"用户答案"];
    NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[answer componentsSeparatedByString:@"@"]];
    if(checked && ![answerArray containsObject:detailLabel.text])
        [answerArray addObject:detailLabel.text];
    else if(!checked && [answerArray containsObject:detailLabel.text])
        [answerArray removeObject:detailLabel.text];
    answer=[answerArray componentsJoinedByString:@"@"];
    [item setValue:answer forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:checkbox.titleLabel.tag withObject:item];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    activeView=textView;

}
- (void)textViewDidChange:(UITextView *)textView
{
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:textView.tag]];
    [item setValue:textView.text forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:textView.tag withObject:item];

}
- (void)resignKeyboard {
    
    [activeView resignFirstResponder];
}

-(void)drawImageFromArray:(UITableViewCell *)parentCell curRow:(int)curRow top:(float)top thisenabled:(Boolean)thisenabled
{
    for(int i=0;i<10;i++)
    {
        UIView *subview=[parentCell.contentView viewWithTag:100+i];
        if(subview)
            [subview removeFromSuperview];
    }
    parentCell.contentView.tag=curRow;
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    NSString *hangshu=[item objectForKey:@"行数"];
    int maxline=5;
    if(hangshu!=nil && hangshu.intValue>0)
        maxline=hangshu.intValue;
    int j=(int)photosArray.count;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15+i*60, top, 50, 50)];
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [selBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSString *urlStr=[item objectForKey:@"文件地址"];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            request.tag=100+i;
            NSMutableDictionary *newdic=[NSMutableDictionary dictionaryWithDictionary:item];
            [newdic setObject:parentCell forKey:@"parentCell"];
            request.userInfo=newdic;

            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [selBtn addSubview:aiv];
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            [aiv startAnimating];
        }
        selBtn.tag=100+i;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
    }
    if(j<maxline && enabled)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15+j*60, top, 50, 50)];
        [selBtn setImage:addPhoto forState:UIControlStateNormal];
        selBtn.tag=100+j;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
    }
    
}
-(float)drawFujianFromArray:(UITableViewCell *)parentCell curRow:(int)curRow top:(float) top
{
    for(int i=0;i<10;i++)
    {
        UIView *subview=[parentCell.contentView viewWithTag:100+i];
        if(subview)
            [subview removeFromSuperview];
    }
    parentCell.contentView.tag=curRow;
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    Boolean readonly=false;
    if([[item objectForKey:@"只读"] isEqualToString:@"是"])
        readonly=true;
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    NSNumber *lines=[item objectForKey:@"行数"];
    if(lines==nil || lines.intValue>10)
        lines=[NSNumber numberWithInt:10];
    int j=(int)photosArray.count;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, top+i*30, parentCell.bounds.size.width-30, 25)];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *filename=[item objectForKey:@"name"];
        
        [selBtn setTitle:filename forState:UIControlStateNormal];
        if(enabled && !readonly)
            [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=100+i;
        [parentCell.contentView addSubview:selBtn];
        
    }
    if(j<lines.intValue && enabled && !readonly)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, top+j*30, parentCell.bounds.size.width-30, 25)];
        [selBtn setTitle:@"添加附件" forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        selBtn.tag=100+j;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
        j++;
    }
    return j*30;
}
-(float)drawPeijianFromArray:(UITableViewCell *)parentCell curRow:(int)curRow top:(float) top
{
    for(int i=0;i<=400;i++)
    {
        UIView *subview=[parentCell.contentView viewWithTag:100+i];
        if(subview)
            [subview removeFromSuperview];
        
    }
    parentCell.contentView.tag=curRow;
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    Boolean readonly=false;
    if([[item objectForKey:@"只读"] isEqualToString:@"是"])
        readonly=true;
    int j=(int)photosArray.count;
    float alljine=0;
    j++;
    for(int i=0;i<j;i++)
    {
        if(i==0)
        {
            for(int m=1;m<=4;m++)
            {
                UILabel *title1;
                if(m==1)
                {
                    title1=[[UILabel alloc]initWithFrame:CGRectMake(15,top, 150, 25)];
                    [title1 setText:@"名称"];
                    title1.textAlignment=NSTextAlignmentCenter;
                }
                else if(m==2)
                {
                    title1=[[UILabel alloc]initWithFrame:CGRectMake(15+150,top, 50, 25)];
                    [title1 setText:@"单价"];
                    title1.textAlignment=NSTextAlignmentRight;
                }
                else if(m==3)
                {
                    title1=[[UILabel alloc]initWithFrame:CGRectMake(15+210,top, 50, 25)];
                    [title1 setText:@"数量"];
                    title1.textAlignment=NSTextAlignmentRight;
                }
                else if(m==4)
                {
                    title1=[[UILabel alloc]initWithFrame:CGRectMake(15+270,top, 50, 25)];
                    [title1 setText:@"金额"];
                    title1.textAlignment=NSTextAlignmentRight;
                }
                
                title1.font=[UIFont systemFontOfSize:15];
                title1.tag=100*m;
                [parentCell.contentView addSubview:title1];
            }
            continue;
        }
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, top+i*30, 150, 25)];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        NSDictionary *item=[photosArray objectAtIndex:i-1];
        NSString *filename=[item objectForKey:@"name"];
        [selBtn setTitle:filename forState:UIControlStateNormal];
        if(enabled && !readonly)
            [selBtn addTarget:self action:@selector(popComboPickerTwoPeijian:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=100+i;
        [parentCell.contentView addSubview:selBtn];
        
        UILabel *price=[[UILabel alloc]initWithFrame:CGRectMake(15+150, top+i*30, 50, 25)];
        NSString *priceStr=[item objectForKey:@"price"];
        priceStr=[NSString stringWithFormat:@"%.1f",priceStr.floatValue];
        [price setText:priceStr];
        price.textAlignment=NSTextAlignmentRight;
        price.font=[UIFont systemFontOfSize:15];
        price.tag=200+i;
        [parentCell.contentView addSubview:price];
        UITextField *num=[[UITextField alloc]initWithFrame:CGRectMake(15+210, top+i*30, 50, 25)];
        num.borderStyle=UITextBorderStyleRoundedRect;
        num.textAlignment=NSTextAlignmentCenter;
        num.font=[UIFont systemFontOfSize:15];
        num.delegate=self;
        num.keyboardType=UIKeyboardTypeNumberPad;
        num.text=[NSString stringWithFormat:@"%@",[item objectForKey:@"num"]];
        [num setInputAccessoryView:topView];
        num.tag=300+i;
        [parentCell.contentView addSubview:num];
        UILabel *jine=[[UILabel alloc]initWithFrame:CGRectMake(15+270, top+i*30, 50, 25)];
        NSString *jineStr=[item objectForKey:@"jine"];
        jineStr=[NSString stringWithFormat:@"%.1f",jineStr.floatValue];
        alljine=alljine+jineStr.floatValue;
        [jine setText:jineStr];
        jine.font=[UIFont systemFontOfSize:15];
        jine.textAlignment=NSTextAlignmentRight;
        jine.tag=400+i;
        [parentCell.contentView addSubview:jine];
        if(i==99)
            break;
        
    }
    
    if(j<99 && enabled && !readonly)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, top+j*30, parentCell.bounds.size.width-30, 25)];
        [selBtn setTitle:@"添加一行" forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        selBtn.tag=100+j;
        [selBtn addTarget:self action:@selector(popComboPickerTwoPeijian:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
        
        UILabel *jine=[[UILabel alloc]initWithFrame:CGRectMake(15+270, top+j*30, 50, 25)];
        NSString *jineStr=[NSString stringWithFormat:@"%.1f",alljine];
        [jine setText:jineStr];
        jine.font=[UIFont systemFontOfSize:15];
        jine.textAlignment=NSTextAlignmentRight;
        jine.tag=400+j;
        [parentCell.contentView addSubview:jine];
        j++;
    }
    return j*30;
}
-(float)drawStudentFromArray:(UITableViewCell *)parentCell curRow:(int)curRow top:(float) top
{
    parentCell.contentView.tag=curRow;
    NSDictionary *item=[detailArray objectAtIndex:curRow];
    Boolean readonly=false;
    if([[item objectForKey:@"只读"] isEqualToString:@"是"])
        readonly=true;
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    if(photosArray==nil)
        photosArray=[NSArray array];
    
    for(int i=0;i<parentCell.subviews.count;i++)
    {
        UIView *subview=[parentCell.contentView viewWithTag:100+i];
        if(subview && ([subview isKindOfClass:[UIButton class]] || [subview isKindOfClass:[UIImageView class]]))
            [subview removeFromSuperview];
    }
    
    int j=(int)photosArray.count;
    for(int i=0;i<j;i++)
    {
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *usertype=[item objectForKey:@"usertype"];
        if(usertype==nil || usertype.length==0)
            usertype=@"学生";
        NSString *userid =[item objectForKey:@"id"];
        NSString *sex =[item objectForKey:@"sex"];
        NSString *weiyima=[NSString stringWithFormat:@"用户_%@_%@____%d",usertype,userid,kSchoolId];
        UIImageView *selImg=[[UIImageView alloc]initWithFrame:CGRectMake(15, top+i*30, 25, 25)];
        NSString *userPic=[CommonFunc getImageSavePath:weiyima ifexist:YES];
        if(userPic)
        {
            UIImage *headImage=[UIImage imageWithContentsOfFile:userPic];
            CGSize newSize=CGSizeMake(25, 25);
            headImage=[headImage scaleToSize1:newSize];
            headImage=[headImage cutFromImage:CGRectMake(0, 0, 25, 25)];
            selImg.image=headImage;
        }
        else
        {
            if([sex isEqualToString:@"女"])
                selImg.image=[UIImage imageNamed:@"woman"];
            else
                selImg.image=[UIImage imageNamed:@"man"];
        }
        [parentCell.contentView addSubview:selImg];
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(45, top+i*30, parentCell.bounds.size.width-30, 25)];
        selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        NSString *filename=[item objectForKey:@"name"];
        
        [selBtn setTitle:filename forState:UIControlStateNormal];
        if(enabled && !readonly)
            [selBtn addTarget:self action:@selector(addStudentClick:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=100+i;
        [parentCell.contentView addSubview:selBtn];
        
    }
    
    if(enabled && !readonly)
    {
        UIButton *selBtn=[[UIButton alloc]initWithFrame:CGRectMake(15, top+j*30, self.view.frame.size.width-30, 25)];
        [selBtn setTitle:@"弹出多选" forState:UIControlStateNormal];
        //selBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [selBtn setTitleColor:selBtn.tintColor forState:UIControlStateNormal];
        //selBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        //selBtn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        selBtn.tag=100+j;
        [selBtn addTarget:self action:@selector(addStudentClick:) forControlEvents:UIControlEventTouchUpInside];
        [parentCell.contentView addSubview:selBtn];
        j++;
    }
    return j*30;
}
-(void)addStudentClick:(UIButton *)sender
{
    curRowIndex=(int)sender.superview.tag;
    //NSMutableDictionary *item=[detailArray objectAtIndex:curRowIndex];
    NSMutableDictionary *item=[[NSMutableDictionary alloc] initWithDictionary:[detailArray objectAtIndex:curRowIndex]];
    if([sender.titleLabel.text isEqualToString:@"弹出多选"])
    {
        DDIMultiSelStudent *destcontroller=[self.storyboard instantiateViewControllerWithIdentifier:@"selStudent"];
        destcontroller.delegate=self;
        [destcontroller setGroupArray:[item objectForKey:@"选项"]];
        [destcontroller setAllStudentArray:[item objectForKey:@"子选项"]];
        [destcontroller setSelectedArray:[item objectForKey:@"用户答案"]];
        [destcontroller loadLinkMansFromDic];
        [self.navigationController pushViewController:destcontroller animated:YES];
    }
    else
    {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"是否确认删除此行？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
            NSInteger delindex=sender.tag-100;
            [answerArray removeObjectAtIndex:delindex];
            [item setObject:answerArray forKey:@"用户答案"];
            [self->detailArray replaceObjectAtIndex:self->curRowIndex withObject:item];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self->curRowIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
-(void)addPhotoClick:(UIButton *)sender
{
    curRowIndex=(int)sender.superview.tag;
    if([sender.imageView.image isEqual:addPhoto] || [sender.titleLabel.text isEqualToString:@"添加附件"])
    {
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"照相机",@"本地相簿",nil];
        actionSheet.tag=-1;
       
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    else
    {
        if(enabled)
        {
            UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:@"删除"
                                          otherButtonTitles:@"打开",nil];
            actionSheet.tag=sender.tag;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
            [self popPhotoView:[NSNumber numberWithInt:(int)sender.tag-100]];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag==-1)
    {
        
        switch (buttonIndex) {
            case 0://照相机
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            case 1://本地相簿
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
                
            default:
                break;
        }
        
    }
    else
    {
        switch (buttonIndex) {
            case 0://删除
            {
                NSDictionary *item=[detailArray objectAtIndex:curRowIndex];
                NSArray *photosArray=[item objectForKey:@"用户答案"];
                NSDictionary *subitem=[photosArray objectAtIndex:actionSheet.tag-100];
                [self deleteRemoteFile:subitem];
            }
                break;
            case 1://打开
            {
                int index=(int)actionSheet.tag-100;
                [self performSelector:@selector(popPhotoView:) withObject:[NSNumber numberWithInt:index] afterDelay:0.6];
            }
                break;
            default:
                break;
        }
    }
}
-(void) deleteRemoteFile:(NSDictionary *)item
{
    NSString *filename=[item objectForKey:@"文件名"];
    if(filename==nil || filename.length==0)
        filename=[item objectForKey:@"newname"];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:@"问卷调查" forKey:@"图片类别"];
    [dic setObject:filename forKey:@"课件名称"];
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"KeJianDelete.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"删除图片";
    request.userInfo=item;
    [requestArray addObject:request];
    [request startAsynchronous];
    
}
#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(1280, 720);
        img=[img scaleToSize:newsize];
        NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        [self uploadFile:fileData];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void) uploadFile:(NSData *)data
{
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:data withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:self.title forKey:@"课程名称"];
    [request setPostValue:self.title forKey:@"老师上课记录编号"];
    [request setPostValue:@"问卷调查" forKey:@"图片类别"];
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:data forKey:@"data"];
    request.username=@"上传问卷调查";
    request.userInfo=dic;
    request.uploadProgressDelegate=self;
    request.showAccurateProgress=YES;
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    NSDictionary *item=[detailArray objectAtIndex:curRowIndex];
    if([[item objectForKey:@"类型"] isEqualToString:@"附件"])
    {
        alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在上传附件..." message:nil timeout:0 dismissible:NO];
        [alertTip showInView:self.view];
    }
    else
    {
        NSIndexPath *indexpath=[NSIndexPath indexPathForRow:0 inSection:curRowIndex];
        UITableViewCell *parentCell=[self.tableView cellForRowAtIndexPath:indexpath];
        NSArray *photosArray=[item objectForKey:@"用户答案"];
        UIButton *btn=(UIButton *)[parentCell.contentView viewWithTag:photosArray.count+100];
        if(btn)
        {
            if(rpv)
                [rpv removeFromSuperview];
            else
            {
                MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
                newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
                newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
                newTheme.centerColor = [UIColor clearColor];
                newTheme.centerColor = [UIColor colorWithRed:224/255.0 green:248/255.0 blue:216/255.0 alpha:1.0];
                newTheme.sliceDividerHidden = YES;
                newTheme.labelColor = [UIColor blackColor];
                newTheme.labelShadowColor = [UIColor whiteColor];
                rpv = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) andTheme:newTheme];
            }
            rpv.progressTotal = 100;
            rpv.progressCounter = 0;
            [btn addSubview:rpv];
        }
    }
    
}
-(void)setProgress:(float)newProgress;
{
    rpv.progressCounter = newProgress*100;
}
-(void)popPhotoView:(NSNumber *)index
{
    
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
    NSDictionary *item=[detailArray objectAtIndex:curRowIndex];
    NSArray *photosArray=[item objectForKey:@"用户答案"];
    for(int i=0;i<photosArray.count;i++)
    {
        NSDictionary *item=[photosArray objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        if(filename==nil || filename.length==0)
            filename=[item objectForKey:@"newname"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
    }
    if(picArray.count>0)
    {
        browserView.picArray=picArray;
        [browserView showFromIndex:index.intValue];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeView=textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *str=textField.text;
    NSInteger row=textField.superview.tag;
    if(str.intValue<=0)
    {
        OLGhostAlertView *alert = [[OLGhostAlertView alloc] initWithTitle:@"数量必须大于0"];
        [alert show];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:row] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    NSInteger index=textField.tag-301;
    NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[detailArray objectAtIndex:row]];
    NSMutableArray *answerArray=[NSMutableArray arrayWithArray:[item objectForKey:@"用户答案"]];
    NSMutableDictionary *subitem=[NSMutableDictionary dictionaryWithDictionary:[answerArray objectAtIndex:index]];
    [subitem setObject:str forKey:@"num"];
    NSString *jinestr=[subitem objectForKey:@"price"];
    jinestr=[NSString stringWithFormat:@"%.1f",str.intValue*jinestr.floatValue];
    [subitem setObject:jinestr forKey:@"jine"];
    [answerArray replaceObjectAtIndex:index withObject:subitem];
    [item setObject:answerArray forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:row withObject:item];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:row] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
-(void)setListValue:(NSArray *)selectedList
{
    NSMutableDictionary *item=[[NSMutableDictionary alloc] initWithDictionary:[detailArray objectAtIndex:curRowIndex]];
    [item setObject:selectedList forKey:@"用户答案"];
    [detailArray replaceObjectAtIndex:curRowIndex withObject:item];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:curRowIndex];
    //[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}
@end
