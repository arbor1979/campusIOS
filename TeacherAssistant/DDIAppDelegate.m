//
//  DDIAppDelegate.m
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIAppDelegate.h"

NSString *kInitURL;//默认单点webServic
NSString *kServiceURL;//学校的webServic
NSString *kUserIndentify;//用户登录后的唯一识别码
NSMutableDictionary *userInfoDic;//用户所有数据
NSMutableDictionary *teacherInfoDic;//老师数据
int kUserType;//1=老师 2=学生 3=家长
NSDictionary *LinkMandic;//所有联系人
NSMutableDictionary *tempLinkMandic; //临时联系人
NSMutableDictionary *lastMsgDic;//最后一次消息记录
NSMutableDictionary *cacheImageDic; //缓存图片地址
NSMutableArray *colorArray;
Boolean kIOS7;
NSString *talkingRespond;
NSString *RecDevToken;
NSString *curVersion;
CLLocationCoordinate2D stuLocation;
NSString *stuCity;
NSString *stuAddress;
DDIDataModel *datam;
int kSchoolId;//学校id

@implementation DDIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    kInitURL = @"http://laoshi.dandian.net/";  //单点webservice
    kServiceURL = @"";  //学校webservice
//    http://42.51.130.102/appserver/appserver.php
//    http://203.195.180.189/GetUserPwdIsRight.php

    kIOS7=[[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0;
    //初始化颜色数组
    colorArray=[[NSMutableArray alloc] init];
    if(kIOS7)
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [CommonFunc initSegmentOfIOS6];
    
    [colorArray addObject:[UIColor colorWithRed:237/255.0f green:165/255.0f blue:115/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:85/255.0f green:180/255.0f blue:186/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:222/255.0f green:225/255.0f blue:136/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:167/255.0f green:175/255.0f blue:56/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:176/255.0f green:180/255.0f blue:203/255.0f alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:238/255.0f green:126/255.0f blue:138/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:247/255.0f green:205/255.0f blue:131/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:103/255.0f green:183/255.0f blue:213/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:249/255.0f green:121/255.0f blue:182/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:145/255.0f green:117/255.0f blue:240/255.0f alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:255/255.0f green:61/255.0f blue:161/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:255/255.0f green:152/255.0f blue:117/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:150/255.0f green:140/255.0f blue:255/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:206/255.0f green:138/255.0f blue:255/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:255/255.0f green:220/255.0f blue:138/255.0f alpha:1.0]];
    
    [colorArray addObject:[UIColor colorWithRed:188/255.0f green:221/255.0f blue:243/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:214/255.0f green:171/255.0f blue:216/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:134/255.0f green:148/255.0f blue:205/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:142/255.0f green:206/255.0f blue:231/255.0f alpha:1.0]];
    [colorArray addObject:[UIColor colorWithRed:186/255.0f green:192/255.0f blue:222/255.0f alpha:1.0]];
    datam=[[DDIDataModel alloc]init];
 
#ifdef __IPHONE_8_0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }  else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
    [application registerForRemoteNotificationTypes:myTypes];
    
#endif
    
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //RecDevToken=[userDefaults objectForKey:@"Token"];
    //if(RecDevToken==nil)
    //    RecDevToken=@"";
    
    //检测新版本
    NSString *urlStr=@"http://itunes.apple.com/lookup?id=";
    urlStr=[urlStr stringByAppendingString:@"799332243"];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    request.username=@"最新版本号";
    [request startAsynchronous];
    ifUpdate=false;
    curVersion=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    
    
    return YES;
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {

    NSString* newToken = [devToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", newToken);
    RecDevToken=newToken;
    
    [self postUpdateTokenRequest];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {

    NSLog(@"Failed to get token, error: %@", err);

}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [application setApplicationIconBadgeNumber:0];
    [self getMsgList];
    NSLog(@"接受到远程消息%@", userInfo);
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if(ifUpdate && !bLocalNotify)
    {
        UILocalNotification * localNotification = [[UILocalNotification alloc] init];
        if (localNotification)
        {
            localNotification.fireDate= [[[NSDate alloc] init] dateByAddingTimeInterval:1];
            localNotification.timeZone=[NSTimeZone defaultTimeZone];
            localNotification.alertBody = @"掌上校园有新的版本，点击到App Store升级。";
            localNotification.alertAction = @"升级";
            localNotification.soundName = @"";
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            bLocalNotify=true;
        }
    }
    NSString *linkManSavePath=[CommonFunc getLinkManPath:@"linkmanAvatar"];
    [CommonFunc writeToPlistFile:linkManSavePath dic:cacheImageDic];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // open app store link
    if([notification.alertAction isEqualToString:@"升级"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
        NSLog(@"%@",updateUrl);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //从服务器接收消息
    [self getMsgList];
    [application setApplicationIconBadgeNumber:0];
    if(kUserType==2)
    {
        [self getGPS];
    }
    [self getAlbumMsg];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadNotice" object:nil];
    NSString *linkManSavePath=[CommonFunc getLinkManPath:@"linkmanAvatar"];
    if([CommonFunc fileIfExist:linkManSavePath])
    {
        cacheImageDic=[NSMutableDictionary dictionaryWithDictionary:[CommonFunc readFromPlistFile:linkManSavePath]];
    }
    if(cacheImageDic==nil)
        cacheImageDic=[NSMutableDictionary dictionary];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)getGPS
{
    stuLocation.latitude=0;
    stuLocation.longitude=0;
    stuAddress=nil;
    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter=100;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            [locationManager requestWhenInUseAuthorization];
        [locationManager startUpdatingLocation]; // 开始定位
        NSLog(@"GPS 启动");
    }
    
    
}
// 定位成功时调用
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation=[locations firstObject];
    [locationManager stopUpdatingLocation];
    if(newLocation!=nil && stuLocation.latitude==0)
    {
        stuLocation = newLocation.coordinate;//手机GPS
        [self postGPS:@"INIT"];
    }
}
-(void) postGPS:(NSString *)action
{
    NSString *urlStr=[kInitURL stringByAppendingString:@"IOSLData_Input.php"];
    NSURL* url = [NSURL URLWithString:urlStr];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:action forKey:@"ACTION"];
    [dic setObject:[NSNumber numberWithDouble:stuLocation.longitude] forKey:@"经度"];
    [dic setObject:[NSNumber numberWithDouble:stuLocation.latitude] forKey:@"纬度"];
    if(stuCity && ![action isEqualToString:@"INIT"])
        [dic setObject:stuCity forKey:@"城市"];
    if(stuAddress && ![action isEqualToString:@"INIT"])
        [dic setObject:stuAddress forKey:@"详细地址"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"更新位置";
    [request startAsynchronous];
}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [locationManager stopUpdatingLocation];
}

- (void)postUpdateTokenRequest
{
    
    //如果用户没有登录则退出
    if(kUserIndentify==nil || kUserIndentify.length==0)
        return;
    //如果令牌未获取则不更新
    if (RecDevToken==nil || RecDevToken.length==0)
        return;
    
    NSString *urlStr=[kInitURL stringByAppendingString:@"IOSSdk_Input.php"];
    NSURL* url = [NSURL URLWithString:urlStr];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    UIDevice* device = [UIDevice currentDevice];
    [dic setObject:device.identifierForVendor.UUIDString forKey:@"设备唯一码"];
    [dic setObject:device.name forKey:@"设备名"];
    [dic setObject:device.model forKey:@"设备类型"];
    [dic setObject:device.localizedModel forKey:@"本地模式"];
    [dic setObject:device.systemName forKey:@"系统名"];
    [dic setObject:device.systemVersion forKey:@"系统版本"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:RecDevToken forKey:@"IosDeviceToken"];
    
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"更新Token";
    [request startAsynchronous];
    
}
- (void)getMsgList
{
    if(kUserIndentify==nil) return;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    NSString *urlStr=[kInitURL stringByAppendingString:@"IOSSDK_Get_MSG_List.php"];
    NSURL* url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取消息";
    [request startAsynchronous];
    
}
- (void)getAlbumMsg
{
    if(kUserIndentify==nil) return;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:@"相册未读消息" forKey:@"action"];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    NSString *urlStr=[kInitURL stringByAppendingString:@"AlbumPraise.php"];
    NSURL* url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"相册未读消息";
    [request startAsynchronous];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"获取消息"] || [request.username isEqualToString:@"更新Token"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *result=[dict objectForKey:@"MSG_STATUS"];
        
        if([result isEqualToString:@"成功"])
        {
            NSLog(@"%@成功",request.username);
            if([request.username isEqualToString:@"更新Token"])
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:RecDevToken forKey:@"Token"];
            }
            else if([request.username isEqualToString:@"获取消息"])
            {
                NSDictionary *tmp=[dict objectForKey:@"MSG_CONTENT"];
                NSString *myUserid=[teacherInfoDic objectForKey:@"用户唯一码"];
                NSArray *msgList=[[NSArray alloc]init];
                if(tmp.count>0)
                    msgList=[tmp objectForKey:myUserid];
                
                
            
                for(int i=0;i<msgList.count;i++)
                {
                    NSMutableDictionary *item=[[NSMutableDictionary alloc] initWithDictionary:[[msgList objectAtIndex:i] objectForKey:@"CONTENT"]];
                    [item setObject:[[[msgList objectAtIndex:i] objectForKey:@"TO_USERID_UNIQUE"] objectAtIndex:0] forKey:@"TO_USERID_UNIQUE"];
                    [item setObject:[[msgList objectAtIndex:i] objectForKey:@"MSG_ID"] forKey:@"MSG_ID"];
                    if(talkingRespond && [[item objectForKey:@"FROM_USERID_UNIQUE"] isEqualToString:talkingRespond])
                       [item setObject:[NSNumber numberWithInt:0] forKey:@"ifRead"];
                    else
                        [item setObject:[NSNumber numberWithInt:0] forKey:@"ifRead"];
                    [datam insertRecord:item];
                }
                if(msgList.count>0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newMessageReach" object:nil];
                    NSDictionary *item=[[msgList objectAtIndex:0] objectForKey:@"CONTENT"];
                    if(talkingRespond==nil || ![[item objectForKey:@"FROM_USERID_UNIQUE"] isEqualToString:talkingRespond])
                    {
                        AudioServicesPlayAlertSound(1016);
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                
            }
     
        }
        else
        {
            NSLog(@"%@失败:%@",request.username,result);
        }
    }
    else if([request.username isEqualToString:@"最新版本号"])
    {
        NSData *datas = [request responseData];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSArray *results=[dict objectForKey:@"results"];
            if(results)
            {
                NSDictionary *appInfo=[results objectAtIndex:0];
                updateUrl=[appInfo objectForKey:@"trackViewUrl"];
                NSString *newVersion=[appInfo objectForKey:@"version"];
                
                if(newVersion.floatValue>curVersion.floatValue)
                    ifUpdate=true;
            }
            
        }

    }
    else if([request.username isEqualToString:@"更新位置"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict && [dict objectForKey:@"LAT"])
        {
            NSString *action=[dict objectForKey:@"ACTION"];
            NSNumber *latitude=[dict objectForKey:@"LAT"];
            NSNumber *longitude=[dict objectForKey:@"LOG"];
            CLLocation *changeLocation = [[CLLocation alloc] initWithLatitude: latitude.doubleValue longitude:longitude.doubleValue];
            stuLocation.latitude=latitude.doubleValue;
            stuLocation.longitude=longitude.doubleValue;
            if([action isEqualToString:@"INIT"])
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getGPSXY" object:nil];
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:changeLocation completionHandler:^(NSArray* placemarks,NSError *error)
             {
                 if (placemarks.count >0   )
                 {
                     CLPlacemark * plmark = [placemarks objectAtIndex:0];
                     //NSString * country = plmark.country;
                     //NSString * city    = plmark.locality;
                     stuCity=plmark.locality;
                     stuAddress=plmark.name;
                     //NSLog(@"%@",plmark);
                     if(kUserType==2)
                       [self postGPS:@""];
                     if([action isEqualToString:@"INIT"])
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"getGPSAddress" object:nil];
                 }
                 
             }];
        }
    }
    if([request.username isEqualToString:@"相册未读消息"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dict)
        {
            NSString *result=[dict objectForKey:@"结果"];
        
            if([result isEqualToString:@"成功"])
            {
                NSArray *unreadDic=[dict objectForKey:@"result"];
                
                if(unreadDic && unreadDic.count>0)
                {
                    for(NSDictionary *item in unreadDic)
                    {
                        if(item)
                            [datam insertNewAubumMsg:item];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"newAlbumMessage" object:nil];
                }
                
            }
        }
    }
    
}
/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
    
    return YES;
}
 */
@end
