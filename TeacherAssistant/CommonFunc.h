//
//  CommonFunc.h
//  PRJ_base64
//
//  Created by wangzhipeng on 12-11-29.
//  Copyright (c) 2012年 com.comsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/utsname.h"

#define __BASE64( text )        [CommonFunc base64StringFromText:text]
#define __TEXT( base64 )        [CommonFunc textFromBase64String:base64]

@interface CommonFunc : NSObject

/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;

+(NSDate *)todayBegin;
+(NSDate *)yesterdayBegin;
+(NSDate *)theDayBeforeYesterdayBegin;
+(NSDate *)dateFromString:(NSString *)dateString;
+(NSString *)stringFromDate:(NSDate *)date;
+(NSDate *)dateFromStringShort:(NSString *)dateString;
+(NSString *)stringFromDateShort:(NSDate *)date;
+(NSString *)getImageSavePath:(NSString *)userName ifexist:(Boolean)ifexist;
+(NSString *)createPath:(NSString *)subdir;
+(NSString *)getLinkManPath:(NSString *)userid;
+(BOOL)fileIfExist:(NSString *)filePath;
+(BOOL)deleteFile:(NSString *)filePath;
+(BOOL)writeToPlistFile:(NSString*)filename dic:(NSDictionary *)dic;
+(NSDictionary *)readFromPlistFile:(NSString*)filename;
+(NSString *)getFileRealName:(NSString *)filePath;
+(BOOL)copyFile:(NSString *)scrFilePath toFile:(NSString *)toFilePath;
+(NSString *)getFileExeName:(NSString *)filePath;
+(NSString*)deviceString;
+(void) initSegmentOfIOS6;
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+(NSString *)chatDateStr:(NSString *)dateStr;
+(UIViewController *)viewController:(UIView *)view;
+(NSArray *) emojiStringArray;
+(NSInteger) getweekDayWithDate:(NSDate *) date;
+(NSString *) getCacheImagePath:(NSString *)url;
+(void) setCacheImagePath:(NSString *)url localPath:(NSString *)localPath;
+(CGSize) getSizeByText:(NSString *)text width:(CGFloat)width font:(UIFont *)font;
+(UITableView *)getTableViewByCell:(UITableViewCell *)cell;
+(NSString *) getLocalLanguage;
+(BOOL) isValidateMobile:(NSString *)mobile;
+(BOOL)isPureInt:(NSString*)string;
+(BOOL)isPureFloat:(NSString*)string;
+(BOOL)isValidateEmail:(NSString *)email;
+(BOOL)isValidateTel:(NSString *)tel;
+(NSString *)findUrlQueryString:(NSString *)url :(NSString *)queryItem;
@end
