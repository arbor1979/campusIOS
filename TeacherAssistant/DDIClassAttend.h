//
//  DDIClassAttend.h
//  老师助手
//
//  Created by yons on 13-11-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "NSString+URLEncoding.h"
#import "GTMBase64.h"
#import "LFCGzipUtillity.h"
#import "UIImage+Scale.h"
#import "OLGhostAlertView.h"
@interface DDIClassAttend : UIViewController <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate>
{
    UIBarButtonItem *rightBtn;
    NSFileManager *fileManager;
    NSString *curJieci;
}
@property (strong,nonatomic) NSString *banjiName;
@property (strong,nonatomic) NSString *classNo;
@property (strong,nonatomic) NSNumber *classIndex;
@property (strong,nonatomic) NSMutableArray *requestArray;

@property (strong,nonatomic) NSMutableArray *scheduleArray; //上课记录
@property (strong,nonatomic) NSMutableDictionary *classInfoDic;//本节课信息
@property (strong,nonatomic) NSMutableArray *studentArray;  //本班学生信息
@property (strong,nonatomic) NSMutableArray *stuKaoQinArray; //本班学生本节课缺勤记录
@property (strong,nonatomic) NSMutableDictionary *headImageDic;

@property (strong,nonatomic) NSMutableArray *kaoqinNameArray;//考勤名称数组


@property (strong,nonatomic) NSMutableArray *imageSel; //绿色选中图片
@property (strong,nonatomic) NSMutableArray *imageDes; //灰色未选中图片
@property (strong,nonatomic) UIImage *imageMan;  //默认男生头像
@property (strong,nonatomic) UIImage *imageWoman; //默认女生头像
@property (strong,nonatomic) NSString *savePath;//头像保存位置

- (IBAction)dingMingClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end
