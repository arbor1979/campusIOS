//
//  AlbumMsg.m
//  掌上校园
//
//  Created by Mac on 15/1/27.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "AlbumMsg.h"
extern NSMutableDictionary *teacherInfoDic;//老师数据
@implementation AlbumMsg

-(id)initWithDic:(NSDictionary *)dict
{
    self=[super init];
    self.fromId=[dict objectForKey:@"点赞人"];
    if(self.fromId!=nil && self.fromId.length>0)
    {
        self.time=[dict objectForKey:@"时间"];
        self.fromHeadUrl=[dict objectForKey:@"点赞人头像"];
        self.fromName=[dict objectForKey:@"点赞人姓名"];
        self.toId=[teacherInfoDic objectForKey:@"用户唯一码"];
        self.type=@"点赞";
    }
    else
    {
        self.fromId=[dict objectForKey:@"评论人"];
        self.msg=[dict objectForKey:@"评论内容"];
        self.msg=[self.msg stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];
        self.time=[dict objectForKey:@"时间"];
        self.fromHeadUrl=[dict objectForKey:@"评论人头像"];
        self.fromName=[dict objectForKey:@"评论人姓名"];
        self.toId=[dict objectForKey:@"回复目标"];
        self.toName=[dict objectForKey:@"回复目标姓名"];
        self.type=@"评论";
    }
    self.imageDic=[dict objectForKey:@"相片信息"];
    if(self.imageDic)
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.imageDic
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (!jsonData) {
            //Deal with error
        } else {
            NSString *requestJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            self.imageJson=[requestJson stringByReplacingOccurrencesOfString:@"'" withString:@"‘"];;
        }
    }
    return  self;
}
@end
