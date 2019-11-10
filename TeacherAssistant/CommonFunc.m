//
//  CommonFunc.m
//  PRJ_base64
//
//  Created by wangzhipeng on 12-11-29.
//  Copyright (c) 2012年 com.comsoft. All rights reserved.
//

#import "CommonFunc.h"
extern Boolean kIOS7;
extern NSMutableDictionary *cacheImageDic;
//引入IOS自带密码库
#import <CommonCrypto/CommonCryptor.h>

//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation CommonFunc

+ (NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY  改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin  改动了此处
        //data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY   改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        //data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:@""];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}
+(NSDate *)todayBegin
{
NSCalendar *cal = [NSCalendar currentCalendar];
NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];

[components setHour:-[components hour]];
[components setMinute:-[components minute]];
[components setSecond:-[components second]];
NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    return today;
}
+(NSDate *)yesterdayBegin
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setHour:-[components hour]-24];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];

    NSDate *yesterday = [cal dateByAddingComponents:components toDate: [[NSDate alloc] init] options:0];
    return  yesterday;
}
+(NSDate *)theDayBeforeYesterdayBegin
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    [components setHour:-[components hour]-48];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: [[NSDate alloc] init] options:0];
    return  yesterday;
}
+(NSDate *)dateFromString:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
 
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    if(destDate==nil)
        destDate=[NSDate date];
    return destDate;
    
}
+(NSDate *)dateFromStringShort:(NSString *)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    if(destDate==nil)
        destDate=[NSDate date];
    return destDate;
    
}
+(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr=[dateformatter stringFromDate:date];
    return dateStr;
}
+(NSString *)stringFromDateShort:(NSDate *)date
{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr=[dateformatter stringFromDate:date];
    return dateStr;
}
+(NSInteger) getweekDayWithDate:(NSDate *) date
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; // 指定日历的算法
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    // 0 是周日，1是周一 2.以此类推
    return [comps weekday]-1;
}
+(NSString *)getImageSavePath:(NSString *)userName ifexist:(Boolean)ifexist
{
    NSString *savePath=@"/";
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSArray *splitArray=[userName componentsSeparatedByString:@"_"];
    if([[splitArray objectAtIndex:1] isEqualToString:@"老师"])
        savePath=@"/teachers/";
    else if([[splitArray objectAtIndex:1] isEqualToString:@"学生"])
    {
        savePath=@"/students/";
    }
    else if([[splitArray objectAtIndex:1] isEqualToString:@"家长"])
    {
        savePath=@"/parents/";
    }
    savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:savePath];
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *fileName=[NSString stringWithFormat:@"%@%@.jpg",savePath,userName];
    if(ifexist)
    {
        if([fileManager fileExistsAtPath:fileName])
            return fileName;
        else
            return nil;
    }
    else
        return fileName;
}
+(NSString *)createPath:(NSString *)subdir
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:subdir];
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
    return savePath;
}
+(NSString *)getLinkManPath:(NSString *)userid
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *savePath=[NSString stringWithFormat:@"%@/%@.plist",[documentPaths objectAtIndex:0],userid];
    return savePath;
}
+(BOOL)fileIfExist:(NSString *)filePath
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    return fileExists;
}
+(BOOL)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if(fileExists)
    {
        NSError *err;
        return [fileManager removeItemAtPath:filePath error:&err];
    }
    else
        return false;
}
+(BOOL)writeToPlistFile:(NSString*)filename dic:(NSDictionary *)dic
{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    BOOL didWriteSuccessfull = [data writeToFile:filename atomically:YES];
    return didWriteSuccessfull;
}
+(NSDictionary *)readFromPlistFile:(NSString*)filename
{
    @try
    {
        NSData * data = [NSData dataWithContentsOfFile:filename];
        return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch(NSException * e)
    {
        NSLog(@"Exception: %@", e);
    }
    return nil;
}
+(NSString *)getFileRealName:(NSString *)filePath
{
    NSArray *array=[filePath componentsSeparatedByString:@"/"];
    if(array.count>0)
    {
        NSString *filename=[array objectAtIndex:array.count-1];;
        NSRange range=[[filename lowercaseString] rangeOfString:@".php"];
        if(range.location!= NSNotFound)
        {
            NSArray *temparray=[filename componentsSeparatedByString:@"="];
            filename=[temparray objectAtIndex:temparray.count-1];
        }
        return filename;
    }
    else
        return @"";
}
+(NSString *)getFileExeName:(NSString *)filePath
{
    NSArray *array=[filePath componentsSeparatedByString:@"."];
    if(array.count>0)
        return [array objectAtIndex:array.count-1];
    else
        return @"";
}
+(BOOL)copyFile:(NSString *)scrFilePath toFile:(NSString *)toFilePath
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists=[fileManager fileExistsAtPath:scrFilePath];
    if(!fileExists)
        NSLog(@"源文件不存在");
    BOOL iscopy = [fileManager copyItemAtPath:scrFilePath toPath:toFilePath error:&error];
    if(!iscopy)
        NSLog(@"copy error:%@",error.description);
    return fileExists;
    
}
+ (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4 GSM";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4 CDMA";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C CDMA";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C GSM";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S CDMA";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S GSM";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6S";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6S Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (Wi-Fi rev_a)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WIFI)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (Wi-Fi+3G+GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (Wi-Fi+3G+GSM)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (Wi-Fi+3G+4G+GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (Wi-Fi+3G+4G+GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (Wi-Fi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (Wi-Fi+3G+4G+GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (Wi-Fi+3G+4G+GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air 4G";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air 4G";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air 4G";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad mini2";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad mini2";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad mini2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad mini3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad mini3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad mini3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad mini4";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad mini4";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air2";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}
+(void) initSegmentOfIOS6;
{
    if (!kIOS7) {
        UIImage *image = [self imageWithColor:[UIColor colorWithWhite:0 alpha:0.8]
                                         size:CGSizeMake(1, 28)];
        [[UISegmentedControl appearance] setBackgroundImage:image
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearance] setDividerImage:image
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        image = [self imageWithColor:[UIColor clearColor]
                                size:CGSizeMake(1, 28)];
        [[UISegmentedControl appearance] setBackgroundImage:image
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
   
    }
    
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIViewController *)viewController:(UIView *)view {
         for (UIView* next = [view superview]; next; next = next.superview) {
                 UIResponder *nextResponder = [next nextResponder];
                 if ([nextResponder isKindOfClass:[UIViewController class]]) {
                         return (UIViewController *)nextResponder;
                     }
             }
         return nil;
}
+(NSString *)chatDateStr:(NSString *)dateStr
{
    NSString *result=@"";
    NSDate *date=[self dateFromString:dateStr];
    NSDate *now=[NSDate date];
    NSDate *yesterDay=[self yesterdayBegin];
    NSDate *beforeYesterday=[self theDayBeforeYesterdayBegin];
    int hours=[now timeIntervalSinceDate:date]/3600;
    if(hours<1)
    {
        int minute=[now timeIntervalSinceDate:date]/60;
        if(minute==0)
            result=@"刚刚";
        else
            result=[NSString stringWithFormat:@"%d分钟前",minute];
    }
    else if(hours<24)
        result=[NSString stringWithFormat:@"%d小时前",hours];
    else
    {
        NSString *shortDateStr=[dateStr substringWithRange:NSMakeRange(11, 5)];
        if([date timeIntervalSinceDate:yesterDay]>0)
        {
            result=[NSString stringWithFormat:@"昨天 %@",shortDateStr];
        }
        else if([date timeIntervalSinceDate:beforeYesterday]>0)
        {
            result=[NSString stringWithFormat:@"前天 %@",shortDateStr];
        }
        else
            result=[dateStr substringToIndex:16];
    }
    return result;
}
+(NSArray *) emojiStringArray
{
    NSMutableArray *array=[NSMutableArray array];
    for(int i=0;i<=106;i++)
    {
        NSString *imageName;
        if(i<10)
            imageName=[NSString stringWithFormat:@"f00%d",i];
        else if(i<100)
            imageName=[NSString stringWithFormat:@"f0%d",i];
        else
            imageName=[NSString stringWithFormat:@"f%d",i];
        [array addObject:imageName];
    }
    return array;
    
}
+(NSString *) getCacheImagePath:(NSString *)url
{
    NSString *path=[cacheImageDic objectForKey:url];
    if(path==nil)
        return nil;
    else
    {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
        NSString *prePath=[documentPaths objectAtIndex:0];
        NSString *fileName=[prePath stringByAppendingString:path];
        if([fileManager fileExistsAtPath:fileName])
            return fileName;
        else
        {
            [cacheImageDic removeObjectForKey:url];
            return nil;
        }
    }
}
+(void) setCacheImagePath:(NSString *)url localPath:(NSString *)localPath
{

    NSArray *tmpArray=[localPath componentsSeparatedByString:@"/"];
    NSString *shortPath=[NSString stringWithFormat:@"/%@/%@",[tmpArray objectAtIndex:tmpArray.count-2],[tmpArray objectAtIndex:tmpArray.count-1]];
    NSArray *allKeys=[cacheImageDic allKeys];
    for(NSString *key in allKeys)
    {
        NSString *value=[cacheImageDic objectForKey:key];
        if([value isEqualToString:shortPath])
        {
            [cacheImageDic removeObjectForKey:key];
            break;
        }
    }
    [cacheImageDic setObject:shortPath forKey:url];
}
+(CGSize) getSizeByText:(NSString *)text width:(CGFloat)width font:(UIFont *)font
{
    if(!text) text=@"";
    //NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text];
    //NSRange range = NSMakeRange(0, attrStr.length);
    //NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];   // 获取该段attributedString的属性字典
    NSDictionary *dic = @{NSFontAttributeName: font};
    // 计算文本的大小  ios7.0
    CGSize labelSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                       attributes:dic        // 文字的属性
                                          context:nil].size;
    return labelSize;
}
+(UITableView *)getTableViewByCell:(UITableViewCell *)cell
{
    UIView *tableView=cell.superview;
    while(![tableView isKindOfClass:[UITableView class]] && tableView)
        tableView=tableView.superview;
    return (UITableView *)tableView;
}
+(NSString *) getLocalLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if([currentLanguage isEqualToString:@"zh-Hans"])
        currentLanguage=@"cn";
    else if ([currentLanguage isEqualToString:@"zh-Hant"] || [currentLanguage isEqualToString:@"zh-HK"])
        currentLanguage=@"tw";
    else
        currentLanguage=@"us";
    return currentLanguage;
}
+(BOOL) isValidateMobile:(NSString *)mobile
{
    NSPredicate* phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"1[3456789]([0-9]){9}"];
    return [phoneTest evaluateWithObject:mobile];
}
+(BOOL) isValidateTel:(NSString *)tel
{
    NSPredicate* phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(0[\\d]{2,3}-?\\d{7,8}$)"];
    NSPredicate* phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(\\d{7,8}$)"];
    return ([phoneTest evaluateWithObject:tel] ||[phoneTest1 evaluateWithObject:tel]);
}
//判断是否为整形：
+(BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}
//判断是否为浮点形：
+(BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
//验证邮箱格式
+(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}
//从url中查询参数的值
+(NSString *)findUrlQueryString:(NSString *)url :(NSString *)queryItem
{
    NSArray *tmparray=[url componentsSeparatedByString:@"?"];
    NSString *querystr=[tmparray objectAtIndex:tmparray.count-1];
    tmparray=[querystr componentsSeparatedByString:@"&"];
    for(NSString *item in tmparray)
    {
        NSArray *subarray=[item componentsSeparatedByString:@"="];
        if([[subarray objectAtIndex:0] isEqualToString:queryItem])
            return [subarray objectAtIndex:1];
    }
    return @"";
}

@end
