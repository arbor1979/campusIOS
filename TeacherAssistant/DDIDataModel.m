//
//  DDIDataModel.m
//  老师助手
//
//  Created by yons on 13-12-30.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIDataModel.h"

#define DBNAME    @"TeacherDB.sqlite"

extern NSMutableDictionary *teacherInfoDic;//老师数据


@implementation DDIDataModel

-(id)init
{
    
    if(db==nil)
    {
        
        //目标路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        //原始路径
        NSString *filePath = [docPath stringByAppendingPathComponent:DBNAME];
        
        /*
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if ([fm fileExistsAtPath:filePath] == NO)//如果doc下没有数据库，从bundle里面拷贝过来
            
        {
            NSString *bundle = [[NSBundle mainBundle]pathForResource:@"classDB" ofType:@"sqlite"];
            
            NSError *err = nil;
            
            if ([fm copyItemAtPath:bundle toPath:filePath error:&err] == NO) //如果拷贝失败
            {
                NSLog(@"%@",[err localizedDescription]);
            }
            
            update messages set toName='杨炳林' where toUser='用户_老师_0038____0'
         select * from messages where fromuser is null or fromuser=''
        }
         */
        if (sqlite3_open([filePath UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
        }
        else
        {
            [self createTable];
            //NSLog(@"数据库已打开");
        }
    }
    return [super init];
}
-(void)initHostUser:(NSString *)userId hostName:(NSString *)userName;
{
    hostUser=[userId copy];
    hostName=[userName copy];
}
-(void) dealloc
{
    if (db)
    {
        sqlite3_close(db);
        //NSLog(@"数据库关闭");
    }
}
-(void) closeDB
{
    if (db)
    {
        sqlite3_close(db);
        //NSLog(@"数据库关闭");
    }
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        //sqlite3_close(db);
        NSLog(@"数据库操作数据失败,sql=%@,err=%@",sql,[[NSString alloc]initWithUTF8String:err]);
    }
}
-(void)createTable
{
    //消息表
    NSString *sqlCreateTable = @"CREATE TABLE IF NOT EXISTS Messages (ID INTEGER PRIMARY KEY AUTOINCREMENT, hostUser TEXT,respondUser TEXT, msgContent TEXT,msgType TEXT, sendTime DATETIME,ifread SMALLINT,hostName TEXT,respondName TEXT,respondUserImage TEXT,ifReceive SMALLINT,ifsuc SMALLINT NOT NULL DEFAULT 1,imageUrl TEXT,linkUrl TEXT)";
    [self execSql:sqlCreateTable];
    char *err;
    //sqlCreateTable=@"ALTER TABLE Messages ADD ifsuc SMALLINT NOT NULL DEFAULT 1";
    //sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    sqlCreateTable=@"ALTER TABLE Messages ADD linkUrl TEXT NULL";
    sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    sqlCreateTable = @"CREATE TABLE IF NOT EXISTS Messages_detail (ID INTEGER PRIMARY KEY AUTOINCREMENT, mainId INTEGER NOT NULL REFERENCES Messages (ID),respondUser TEXT NOT NULL,msgId TEXT NOT NULL,ifRead SMALLINT NOT NULL DEFAULT 0)";
    sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    sqlCreateTable = @"CREATE TABLE IF NOT EXISTS News (ID INTEGER PRIMARY KEY AUTOINCREMENT, newsid INTEGER NOT NULL,title TEXT NOT NULL,image TEXT,time TEXT,content TEXT,url TEXT,ifread SMALLINT NOT NULL DEFAULT 0,newsType TEXT,userId TEXT)";
    sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    // sqlCreateTable=@"ALTER TABLE News ADD newsType TEXT NULL";
    // sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    // sqlCreateTable=@"ALTER TABLE News ADD userId TEXT NULL";
    // sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    
    sqlCreateTable = @"CREATE TABLE IF NOT EXISTS AlbumMsg (ID INTEGER PRIMARY KEY AUTOINCREMENT, fromId TEXT NOT NULL,time TEXT,msg TEXT,fromHeadUrl TEXT,fromName TEXT,toId TEXT,toName TEXT,type TEXT,ifRead SMALLINT NOT NULL DEFAULT 0,imageJson TEXT)";
    sqlite3_exec(db, [sqlCreateTable UTF8String], NULL, NULL, &err);
    
    
    
}
-(void)insertNewAubumMsg:(NSDictionary *)dict
{
    AlbumMsg *newmsg=[[AlbumMsg alloc]initWithDic:dict];
    if(newmsg)
    {
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO 'AlbumMsg' ('fromId', 'time', 'msg','fromHeadUrl','fromName','toId','toName','type','imageJson') VALUES ('%@', '%@', '%@','%@', '%@', '%@', '%@', '%@','%@')",
                     newmsg.fromId, newmsg.time, newmsg.msg, newmsg.fromHeadUrl, newmsg.fromName, newmsg.toId,newmsg.toName,newmsg.type,newmsg.imageJson];
    
    [self execSql:sql];
    }
    
}
-(NSInteger)getAlbumUnreadCount:(NSString *)toId
{
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT count(*) FROM AlbumMsg where ifRead=0 and toId='%@'",toId];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int curId=(int)sqlite3_column_int(statement, 0);
            return curId;
        }
        else
            return 0;
    }
    else
        return 0;
}
-(NSArray *)getAlbumMsgList:(NSString *)toId ifRead:(NSInteger)ifRead
{
    NSMutableArray *resultArray=[NSMutableArray array];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"select * FROM AlbumMsg where ifRead='%ld' and toId='%@' order by ID desc",(long)ifRead,toId];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int rowid=sqlite3_column_int(statement, 0);
            char *fromId = (char*)sqlite3_column_text(statement, 1);
            NSString *sfromId = [[NSString alloc]initWithUTF8String:fromId];
            char *time = (char*)sqlite3_column_text(statement, 2);
            NSString *stime = [[NSString alloc]initWithUTF8String:time];
            char *msg = (char*)sqlite3_column_text(statement, 3);
            NSString *smsg = [[NSString alloc]initWithUTF8String:msg];
            char *fromHeadUrl = (char*)sqlite3_column_text(statement, 4);
            NSString *sfromHeadUrl = [[NSString alloc]initWithUTF8String:fromHeadUrl];
            char *fromName = (char*)sqlite3_column_text(statement, 5);
            NSString *sfromName = [[NSString alloc]initWithUTF8String:fromName];
            char *toId = (char*)sqlite3_column_text(statement, 6);
            NSString *stoId = [[NSString alloc]initWithUTF8String:toId];
            char *toName = (char*)sqlite3_column_text(statement, 7);
            NSString *stoName = [[NSString alloc]initWithUTF8String:toName];
            char *type = (char*)sqlite3_column_text(statement, 8);
            NSString *stype = [[NSString alloc]initWithUTF8String:type];
            char *imageJson = (char*)sqlite3_column_text(statement, 10);
            NSString *simageJson = [[NSString alloc]initWithUTF8String:imageJson];
            AlbumMsg *newmsg=[AlbumMsg new];
            newmsg.rowid=rowid;
            newmsg.fromId=sfromId;
            newmsg.time=stime;
            newmsg.msg=smsg;
            newmsg.fromHeadUrl=sfromHeadUrl;
            newmsg.fromName=sfromName;
            newmsg.toId=stoId;
            newmsg.toName=stoName;
            newmsg.type=stype;
            newmsg.imageJson=simageJson;
            if(simageJson)
            {
                NSData *jsonData = [simageJson dataUsingEncoding:NSUTF8StringEncoding];
                newmsg.imageDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            }
            [resultArray addObject:newmsg];
        }
        
    }
    sqlite3_finalize(statement);
    return resultArray;
}
-(void)updateUnreadAlbumMsg:(NSArray *)msgList
{
    for(int i=0;i<msgList.count;i++)
    {
        AlbumMsg *item=[msgList objectAtIndex:i];
        NSString *sql=[NSString stringWithFormat:@"update AlbumMsg set ifRead=1 where id='%ld'",(long)item.rowid];
        [self execSql:sql];
    }
}
-(void)insertRecord:(NSDictionary *)dict
{
    
    NSString *respondUser=[dict objectForKey:@"FROM_USERID_UNIQUE"];
    NSString *msgContent=[dict objectForKey:@"description"];
    msgContent=[msgContent stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *msgType=[dict objectForKey:@"type"];
    NSString *sendTime=[dict objectForKey:@"FROM_DATETIME"];
    NSString *respondName=[dict objectForKey:@"FROM_USERID_NAME"];
    NSString *respondUserImage=[dict objectForKey:@"FROM_USERID_IMAGE"];
    NSNumber *ifRead=[dict objectForKey:@"ifRead"];
    NSString *msgId=[dict objectForKey:@"MSG_ID"];
    NSString *linkUrl=[dict objectForKey:@"LINKURL"];
    if(linkUrl==nil)
        linkUrl=@"";
    NSString *imageUrl=@"";
    if(![msgType isEqualToString:@"txt"])
        imageUrl=msgContent;
    NSString *sql = [NSString stringWithFormat:
                      @"INSERT INTO 'Messages' ('hostUser', 'respondUser', 'msgContent','msgType','sendTime','ifread','hostName','respondName','respondUserImage','ifReceive','imageUrl','linkUrl') VALUES ('%@', '%@', '%@','%@', '%@', '%d', '%@', '%@','%@','%d','%@','%@')",
                      hostUser, respondUser, msgContent, msgType, sendTime, ifRead.intValue,hostName,respondName,respondUserImage,1,imageUrl,linkUrl];
    
    [self execSql:sql];
    
    sql=@"select last_insert_rowid() from Messages";
    int autoid=0;
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            autoid=(int)sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    sql = [NSString stringWithFormat:
           @"INSERT INTO 'Messages_detail' ('mainId', 'respondUser', 'msgId') VALUES ('%d', '%@', '%@')",
           autoid, respondUser, msgId];
    [self execSql:sql];

}
-(void)insertNewsRecord:(NSDictionary *)dict newsType:(NSString *)newsType
{
    
    NSNumber *newsid=[dict objectForKey:@"编号"];
    NSString *title=[dict objectForKey:@"第一行主题"];
    title=[title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *image=[dict objectForKey:@"第二行图片区URL"];
    NSString *time=[dict objectForKey:@"第一行右边"];
    NSString *content=[dict objectForKey:@"通知内容"];
    NSString *ifread=[dict objectForKey:@"已阅"];
    if(ifread==nil)
        ifread=@"0";
    if([content isEqual:[NSNull null]])
        content=@"";
    content=[content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *url=[dict objectForKey:@"最下边一行URL"];
    NSString *userId=[dict objectForKey:@"用户唯一码"];
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT ID FROM News where newsid=%d and userId='%@' order by ID limit 1",newsid.intValue,userId];
    sqlite3_stmt * statement;
    int rowid=0;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            rowid=sqlite3_column_int(statement, 0);
            if(rowid>0)
            {
                NSString *sql = [NSString stringWithFormat:
                                 @"delete from 'News' where ID<>%d and newsid=%d and userId='%@'",
                                 rowid,newsid.intValue,userId];
                [self execSql:sql];
                sql=[NSString stringWithFormat:@"update News set title='%@',image='%@',time='%@',content='%@',url='%@',ifread='%@' where ID=%d",title,image,time,content,url,ifread,rowid];
                [self execSql:sql];
            }
            
        }
    }
    if(rowid==0)
    {
        NSString *sql = [NSString stringWithFormat:
                         @"INSERT INTO 'News' ('newsid', 'title', 'image','time','content','url','newsType','userId','ifread') VALUES ('%d', '%@', '%@','%@', '%@', '%@','%@','%@','%@')",
                         newsid.intValue, title, image, time, content, url,newsType,userId,ifread];
        [self execSql:sql];
    }
   
    
}
-(int)getMaxNewsId:(NSString *)newsType userId:(NSString *)userId
{
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT max(newsid) FROM News where newsType='%@' and userId='%@'",newsType,userId];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int curId=(int)sqlite3_column_int(statement, 0);
            return curId;
        }
        else
            return 0;
    }
    else
        return 0;
}
-(int)getUnreadNews:(NSString *)newsType userId:(NSString *)userId
{
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT count(*) FROM News where ifread=0 and newsType='%@' and userId='%@'",newsType,userId];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int curId=(int)sqlite3_column_int(statement, 0);
            return curId;
        }
        else
            return 0;
    }
    else
        return 0;
}
-(void) clearUnReadByNewsId:(int)newsId
{
    NSString *sql = [NSString stringWithFormat:@"update News set ifRead=1 where id='%d'",newsId];
    [self execSql:sql];
}
-(void) deleteAllNews
{
    NSString *sql = [NSString stringWithFormat:@"delete from News"];
    [self execSql:sql];
}
-(void)clearUnreadNewsByTypeAndUserId:(NSString *)newsType userId:(NSString *)userId
{
    NSString *sql = [NSString stringWithFormat:@"update News set ifRead=1 where ifread=0 and newsType='%@' and userId='%@'",newsType,userId];
    [self execSql:sql];
}

-(NSArray *)queryNewsList:(NSInteger)curId newsType:(NSString *)newsType userId:(NSString *)userId
{
   
    
    int limit=300;
    if(curId==-1) curId=10000000;
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM News where newsid<%d and newsType='%@' and userId='%@' order by ID desc limit %d",(int)curId,newsType,userId,limit];
    sqlite3_stmt * statement;
    NSMutableArray *keyArray=[[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            News *news=[News new];
            int rowid=sqlite3_column_int(statement, 0);
            int newsid=sqlite3_column_int(statement, 1);
            char *title = (char*)sqlite3_column_text(statement, 2);
            NSString *nstitle = [[NSString alloc]initWithUTF8String:title];
            char *image = (char*)sqlite3_column_text(statement, 3);
            NSString *nsimage = [[NSString alloc]initWithUTF8String:image];
            char *time = (char*)sqlite3_column_text(statement, 4);
            NSString *nstime = [[NSString alloc]initWithUTF8String:time];
            char *content = (char*)sqlite3_column_text(statement, 5);
            NSString *nscontent = [[NSString alloc]initWithUTF8String:content];
            char *url = (char*)sqlite3_column_text(statement, 6);
            NSString *nsurl = [[NSString alloc]initWithUTF8String:url];
            int ifread=sqlite3_column_int(statement, 7);
            news.rowid=rowid;
            news.newsid=newsid;
            news.title=nstitle;
            news.time=nstime;
            news.image=nsimage;
            news.content=nscontent;
            news.url=nsurl;
            news.ifread=ifread;
            [keyArray addObject:news];
            
        }
    }
    //keyArray=[[NSMutableArray alloc] initWithArray:[keyArray sortedArrayUsingFunction:customSortNews context:nil]];
    return keyArray;
}
NSInteger customSortNews(News *obj1, News *obj2,void* context){
    if (obj1.newsid > obj2.newsid) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if (obj1.newsid < obj2.newsid) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
}
- (void)addMessage:(Message*)message
{
    message.text=[message.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:
                     @"INSERT INTO 'Messages' ('hostUser', 'respondUser', 'msgContent','msgType','sendTime','ifread','hostName','respondName','respondUserImage','ifReceive') VALUES ('%@', '%@', '%@','%@', '%@', '%d', '%@', '%@','%@','%d')",
                     hostUser, message.respondUser, message.text, message.msgType,[CommonFunc stringFromDate:message.date], 0,hostName,message.respondName,@"",message.ifReceive];
    
    [self execSql:sql];
    
    sql=@"select last_insert_rowid() from Messages";
    int autoid=0;
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            autoid=(int)sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    message.rowid=autoid;
}
- (void)updateMessage:(Message*)message
{
    
    NSString *sql = [NSString stringWithFormat:
                     @"update Messages set msgContent='%@' where rowid='%d'",message.text,message.rowid];
    
    [self execSql:sql];

}
-(void) deleteMessageByUserId:(NSString *)respondUser
{
    NSString *sql=[NSString stringWithFormat:@"delete from Messages where respondUser='%@' and hostUser='%@'",respondUser,hostUser];
    [self execSql:sql];
}
-(void) clearUnReadByUser:(NSString *)respondUser
{
    NSString *sql = [NSString stringWithFormat:@"update Messages set ifRead=1 where respondUser='%@' and ifRead=0 and ifReceive=1",respondUser];
    [self execSql:sql];
}
-(int)queryMsgByUserId:(NSString *)userId maxId:(int)maxId minId:(int)minId
{
    int limit=20;
    if(maxId==-1)
        maxId=1000000;
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Messages where id<'%d' and id>'%d' and respondUser='%@' and hostUser='%@' order by id desc limit %d",maxId,minId,userId,hostUser,limit];
    sqlite3_stmt * statement;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int curId=(int)sqlite3_column_int(statement, 0);
           
            char *respondUser = (char*)sqlite3_column_text(statement, 2);
            NSString *nsrespondUser = [[NSString alloc]initWithUTF8String:respondUser];
            char *content = (char*)sqlite3_column_text(statement, 3);
            NSString *nscontent = [[NSString alloc]initWithUTF8String:content];
            char *msgType = (char*)sqlite3_column_text(statement, 4);
            NSString *nsmsgType = [[NSString alloc]initWithUTF8String:msgType];
            char *sendTime = (char*)sqlite3_column_text(statement, 5);
            int ifread=(int)sqlite3_column_int(statement, 6);
            
            NSString *nssendTime = [[NSString alloc]initWithUTF8String:sendTime];
            char *respondName = (char*)sqlite3_column_text(statement, 8);
            NSString *nsrespondName = [[NSString alloc]initWithUTF8String:respondName];
            int ifReceive=(bool)sqlite3_column_int(statement, 10);
            int ifsuc=(int)sqlite3_column_int(statement, 11);
            char *imageUrl = (char*)sqlite3_column_text(statement, 12);
            NSString *nsimageUrl=@"";
            if(imageUrl)
                nsimageUrl = [[NSString alloc]initWithUTF8String:imageUrl];
            char *linkUrl = (char*)sqlite3_column_text(statement, 13);
            NSString *nslinkUrl=@"";
            if(linkUrl)
                nslinkUrl = [[NSString alloc]initWithUTF8String:linkUrl];
            Message *msg=[[Message alloc]init];
            msg.rowid=curId;
            msg.respondUser=nsrespondUser;
            msg.respondName=nsrespondName;
            msg.msgType=nsmsgType;
            msg.text=nscontent;
            msg.date=[CommonFunc dateFromString:nssendTime];
            msg.ifReceive=ifReceive;
            msg.ifsuc=ifsuc;
            msg.imageUrl=nsimageUrl;
            msg.ifRead=ifread;
            msg.linkUrl=nslinkUrl;
            if([msg.msgType isEqualToString:@"img"])
            {
                msg.img=[UIImage imageWithContentsOfFile:msg.text];
            }
            [_messages addObject:msg];
        }
    }
    sqlite3_finalize(statement);
    for(int i=0;i<_messages.count;i++)
    {
        Message *msg=[_messages objectAtIndex:i];
        sqlQuery = [NSString stringWithFormat:@"select * from Messages_detail where mainId='%d'",msg.rowid];

        if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
            NSMutableArray *msgIdArray=[NSMutableArray array];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *respondUser = (char*)sqlite3_column_text(statement, 2);
                NSString *nsrespondUser = [[NSString alloc]initWithUTF8String:respondUser];
                char *msgId = (char*)sqlite3_column_text(statement, 3);
                NSString *nsmsgId = [[NSString alloc]initWithUTF8String:msgId];
                int ifRead=(int)sqlite3_column_int(statement, 4);
                NSMutableDictionary *item=[NSMutableDictionary dictionary];
                [item setObject:nsrespondUser forKey:@"respondUser"];
                [item setObject:nsmsgId forKey:@"msgId"];
                [item setObject:[NSNumber numberWithInt:ifRead] forKey:@"ifRead"];
                [msgIdArray addObject:item];
            }
            msg.msgIdArray=msgIdArray;
            [_messages replaceObjectAtIndex:i withObject:msg];
        }
        sqlite3_finalize(statement);
    }
    //sqlite3_close(db);
    _messages=[[NSMutableArray alloc] initWithArray:[_messages sortedArrayUsingFunction:customSort context:nil]];
    
    if(_messages.count==0)
        return 0;
    else
    {
        Message *maxOne=(Message *)[_messages objectAtIndex:_messages.count-1];
        return maxOne.rowid;
    }
}
NSInteger customSort(Message *obj1, Message *obj2,void* context){
    if (obj1.rowid > obj2.rowid) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if (obj1.rowid < obj2.rowid) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
}
-(NSArray *)queryLastMsgGroupByUser:(NSInteger)curId
{
  
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT max(ID) FROM Messages where hostUser='%@' and ID>%ld group by respondUser order by max(ID) desc",hostUser,(long)curId];
    sqlite3_stmt * statement;
    NSMutableArray *keyArray=[[NSMutableArray alloc]init];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int rowid=sqlite3_column_int(statement, 0);
            [keyArray addObject:[NSNumber numberWithInt:rowid]];
            
        }
    }
    sqlite3_finalize(statement);
    
    NSMutableArray *msgList=[[NSMutableArray alloc]init];
    NSDate *today=[CommonFunc todayBegin];
    NSDate *yesterday=[CommonFunc yesterdayBegin];
    NSDate *theDayBeforeYesterday=[CommonFunc theDayBeforeYesterdayBegin];
    for(int i=0;i<keyArray.count;i++)
    {
        sqlQuery = [NSString stringWithFormat:@"SELECT * FROM Messages where id=%@",[keyArray objectAtIndex:i]];
        
        if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int rowid=sqlite3_column_int(statement, 0);
                
                char *respondUser = (char*)sqlite3_column_text(statement, 2);
                NSString *nsrespondUser = [[NSString alloc]initWithUTF8String:respondUser];
                if ([nsrespondUser isEqualToString:@"(null)"])
                    continue;
                char *content = (char*)sqlite3_column_text(statement, 3);
                NSString *nscontent = [[NSString alloc]initWithUTF8String:content];
                char *msgType = (char*)sqlite3_column_text(statement, 4);
                NSString *nsmsgType = [[NSString alloc]initWithUTF8String:msgType];
                char *sendTime = (char*)sqlite3_column_text(statement, 5);
                NSString *nssendTime = [[NSString alloc]initWithUTF8String:sendTime];
                
                char *respondName = (char*)sqlite3_column_text(statement, 8);
                NSString *nsrespondName = [[NSString alloc]initWithUTF8String:respondName];
                char *respondUserImage = (char*)sqlite3_column_text(statement, 9);
                NSString *nsrespondUserImage = [[NSString alloc]initWithUTF8String:respondUserImage];
                if([nsmsgType isEqualToString:@"img"] || [nsmsgType isEqualToString:@"image"])
                    nscontent=@"[图片]";
                int ifReceive=sqlite3_column_int(statement, 10);
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                [dict setObject:[NSNumber numberWithInt:rowid] forKey:@"rowid"];
                
                [dict setObject:nsrespondUser forKey:@"respondUser"];
                [dict setObject:nscontent forKey:@"msgContent"];
                [dict setObject:nsmsgType forKey:@"msgType"];
                NSDate *lastDate=[CommonFunc dateFromString:nssendTime];
                if([lastDate timeIntervalSinceDate:today]>=0)
                    nssendTime=[nssendTime substringWithRange:NSMakeRange(11,5)];
                else if([lastDate timeIntervalSinceDate:yesterday]>=0)
                    nssendTime=[NSString stringWithFormat:@"%@ %@",@"昨天",[nssendTime substringWithRange:NSMakeRange(11,5)]];
                else if([lastDate timeIntervalSinceDate:theDayBeforeYesterday]>=0)
                    nssendTime=[NSString stringWithFormat:@"%@ %@",@"前天",[nssendTime substringWithRange:NSMakeRange(11,5)]];
                else
                    nssendTime=[nssendTime substringWithRange:NSMakeRange(5,11)];
                
                [dict setObject:nssendTime forKey:@"sendTime"];
                [dict setObject:nsrespondName forKey:@"respondName"];
                [dict setObject:nsrespondUserImage forKey:@"respondUserImage"];
                [dict setObject:[NSNumber numberWithInt:ifReceive] forKey:@"ifReceive"];
                
                
                sqlQuery = [NSString stringWithFormat:@"SELECT count(*) FROM Messages where ifread=0 and ifreceive=1 and hostUser='%@' and respondUser='%@'",hostUser,nsrespondUser];
                sqlite3_stmt * statement1;
                if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement1, nil) == SQLITE_OK) {
                    if (sqlite3_step(statement1) == SQLITE_ROW) {
                        int count=sqlite3_column_int(statement1, 0);
                        [dict setObject:[NSNumber numberWithInt:count] forKey:@"unRead"];
                    }
                }
                sqlite3_finalize(statement1);
                [msgList addObject:dict];
            }
        }
        sqlite3_finalize(statement);
    }
    
    //sqlite3_close(db);
    return msgList;
}
- (void)updateMessageFlag:(int)rowid flag:(int)flag msgIdArray:(NSArray *)msgIdArray userIdArray:(NSArray *)userIdArray
{
    
    for(int i=(int)_messages.count-1;i>=0;i--)
    {
        Message *msg=[_messages objectAtIndex:i];
        if(msg.rowid==rowid)
        {
            msg.ifsuc=flag;
            NSMutableArray *tmpArray=[NSMutableArray array];
            for(int j=0;j<msgIdArray.count;j++)
            {
                NSMutableDictionary *item=[NSMutableDictionary dictionary];
                NSString *msgId=[msgIdArray objectAtIndex:j];
                NSString *respondUser=[userIdArray objectAtIndex:j];
                NSNumber *ifRead=[NSNumber numberWithInt:0];
                [item setValue:msgId forKey:@"msgId"];
                [item setValue:respondUser forKey:@"respondUser"];
                [item setValue:ifRead forKey:@"ifRead"];
                [tmpArray addObject:item];
            }
            msg.msgIdArray=tmpArray;
            break;
        }
        
    }
    
    NSString *sql = [NSString stringWithFormat:
                     @"update Messages set ifsuc=%d where rowid='%d'",flag,rowid];
    
    [self execSql:sql];
    
    if(flag && msgIdArray && userIdArray)
    {
        for (int i=0; i<userIdArray.count; i++) {
            NSString *userId=[userIdArray objectAtIndex:i];
            NSString *msgId=[msgIdArray objectAtIndex:i];
            sql = [NSString stringWithFormat:
                   @"insert into Messages_detail (mainId,respondUser,msgId) values ('%d','%@','%@')",rowid,userId,msgId];
            [self execSql:sql];
        }
    }
    
    
}

-(void)compareLastMsg:(Message *)lastMsg
{
    NSString *sqlQuery = [NSString stringWithFormat:
                     @"select msgContent,sendTime FROM Messages where respondUser='%@' order by rowid desc limit 1",lastMsg.respondUser];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if(sqlite3_step(statement) == SQLITE_ROW) {
            char *content = (char*)sqlite3_column_text(statement, 0);
            NSString *sContent = [[NSString alloc]initWithUTF8String:content];
            char *sendTime = (char*)sqlite3_column_text(statement, 1);
            NSString *ssendTime = [[NSString alloc]initWithUTF8String:sendTime];
            NSDate *dt=[CommonFunc dateFromString:ssendTime];
            if([lastMsg.date timeIntervalSinceDate:dt]>0 && ![lastMsg.text isEqual:sContent] && [lastMsg.msgType isEqualToString:@"txt"])
            {
                [self addMessage:lastMsg];
            }
        }
        else
            [self addMessage:lastMsg];
    }
    sqlite3_finalize(statement);
}
-(NSArray *)updateReadFlag:(NSArray *)readedArray
{
    NSMutableArray *ids=[NSMutableArray array];
    NSString *msgIds=[readedArray componentsJoinedByString:@"','"];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"select distinct mainId FROM Messages_detail where msgId in ('%@')",msgIds];
    sqlite3_stmt * statement;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int rowid=sqlite3_column_int(statement, 0);
            [ids addObject:[NSNumber numberWithInt:rowid]];
        }
    }
    sqlite3_finalize(statement);
    sqlQuery = [NSString stringWithFormat:
                @"update Messages_detail set ifRead=1 where msgId in ('%@')",msgIds];
    [self execSql:sqlQuery];
    sqlQuery = [NSString stringWithFormat:
                @"update Messages set ifRead=1 where ifRead=0 and (select count(*) from Messages_detail where Messages.ID=mainId)=(select count(*) from Messages_detail where Messages.ID=mainId and ifRead=1)"];
    [self execSql:sqlQuery];
    
    NSMutableArray *indexArray=[NSMutableArray array];
    for(int i=0;i<_messages.count;i++)
    {
        Message *msg=[_messages objectAtIndex:i];
        if([ids containsObject:[NSNumber numberWithInt:msg.rowid]])
        {
            BOOL flag=true;
            for(int j=0;j<msg.msgIdArray.count;j++)
            {
                NSDictionary *item=[msg.msgIdArray objectAtIndex:j];
                NSString *msgId=[item objectForKey:@"msgId"];
                if([readedArray containsObject:msgId])
                {
                   [item setValue:[NSNumber numberWithInt:1]  forKey:@"ifRead"];
                    //[msg.msgIdArray replaceObjectAtIndex:j withObject:item];
                }
                NSNumber *ifread=[item objectForKey:@"ifRead"];
                if(ifread.intValue==0)
                    flag=false;
            }
            if(flag)
               [msg setValue:[NSNumber numberWithInt:1] forKey:@"ifRead"];
            //[_messages replaceObjectAtIndex:i withObject:msg];
            NSIndexPath *index=[NSIndexPath indexPathForRow:i inSection:0];
            [indexArray addObject:index];
        }
    }
    return indexArray;
}
@end
