//
//  DDILinkManGroup.h
//  老师助手
//
//  Created by yons on 14-1-13.
//  Copyright (c) 2014年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "GTMBase64.h"
#import "OLGhostAlertView.h"
#import "TQMultistageTableView.h"
#import "CommonFunc.h"
#import "UIImage+Scale.h"
#import "DDIChatView.h"
#import "pinyin.h"
#import "ASIFormDataRequest.h"
#import "LFCGzipUtillity.h"
#import "DDIDataModel.h"
#import "LinkMan.h"
#import "CommonFunc.h"

@interface DDILinkManGroup : UIViewController<TQTableViewDataSource, TQTableViewDelegate>
{
    UIImage *arrayRight;
    UIImage *arrayDown;
    UIImage *greenTel;
    
    NSString *hostUser;

    NSMutableDictionary *headViewArray;
    UIImage *imageMan;  //默认男生头像
    UIImage *imageWoman; //默认女生头像
    
    NSMutableArray *requestArray;
    
    NSString *linkManSavePath;
    NSArray *filteredMessages;
    OLGhostAlertView *alertTip;
    
    NSArray *groupArray;
    NSMutableDictionary *friendDic;
}

@property (nonatomic, strong) TQMultistageTableView *mTableView;
@property (strong,nonatomic) UISearchBar  *  searchBar;
@property (strong,nonatomic) UISearchDisplayController *  searchDc;

- (void)getLinkManGroup;
-(void)loadLinkMansFromDic;

@end
