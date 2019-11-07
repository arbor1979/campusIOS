//
//  DDIMessageList.h
//  老师助手
//
//  Created by yons on 13-12-31.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDIDataModel.h"

#import "UIImage+Scale.h"
#import "ASIHTTPRequest.h"
#import "NSString+URLEncoding.h"
#import "JSBadgeView.h"
#import "DDIChatView.h"
#import "DDIMyInforView.h"
#import "DDIStudentInfo.h"
@interface DDIMessageList : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate>
{

    NSArray *filteredMessages;
    UIBarButtonItem *broadCastBtn;
    UIImage *groupImage;
    
}
@property (strong,nonatomic) NSMutableArray *msgList;
@property (strong,nonatomic) NSMutableDictionary *headImageDic;
@property (strong,nonatomic) NSString *savePath;
@property (strong,nonatomic) NSMutableArray *requestArray;
@property (strong,nonatomic) UIImage *unknowMan;
@property (nonatomic) NSInteger curMaxId;

@property (strong,nonatomic) UISearchBar  *  searchBar;
@property (strong,nonatomic) UISearchDisplayController *  searchDc;

-(void) getHeadImageList:(NSArray *)newMsgList;
-(void) getUnReadNum;
-(void)refreshTableAndBadge;
- (void)getNewMessageFromDB:(NSNotification*)notification;
@end

