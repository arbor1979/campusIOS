//
//  DDIAppDelegate.h
//  TeacherAssistant
//
//  Created by yons on 13-11-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMBase64.h"
#import "ASIFormDataRequest.h"
#import "DDIDataModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
//#import <AlipaySDK/AlipaySDK.h>
@interface DDIAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
{
    BOOL ifUpdate;
    NSString *updateUrl;
    CLLocationManager *locationManager;
    BOOL bLocalNotify;
}
@property (strong, nonatomic) UIWindow *window;

- (void)postUpdateTokenRequest;
- (void)getMsgList;
-(void)getGPS;
- (void)getAlbumMsg;
@end
