//
//  DDIAlbumPersonal.m
//  掌上校园
//
//  Created by Mac on 15/1/19.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIAlbumPersonal.h"
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern NSMutableDictionary *teacherInfoDic;//老师数据
extern DDIDataModel *datam;
@implementation DDIAlbumPersonal

-(void)viewDidLoad
{
    [super viewDidLoad];
    imageList=[NSMutableArray array];
    requestArray=[NSMutableArray array];
    savepath=[CommonFunc createPath:@"/utils/"];
    self.title=[NSString stringWithFormat:@"%@的相册",_username];
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        
    }
    
    if([_userid isEqualToString:[teacherInfoDic objectForKey:@"用户唯一码"]])
    {
        //设置导航栏菜单
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
        [backBtn setTitle:@"" forState:UIControlStateNormal];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(beginPhotograph) forControlEvents:UIControlEventTouchUpInside];
        cameraBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        
        UIButton *exportBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0, 26.0)];
        [exportBtn setTitle:@"" forState:UIControlStateNormal];
        [exportBtn setBackgroundImage:[UIImage imageNamed:@"album_message_history"] forState:UIControlStateNormal];
        [exportBtn addTarget:self action:@selector(historyMsgBtnClick) forControlEvents:UIControlEventTouchUpInside];
       
        UIBarButtonItem *spaceBtn= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceBtn.width=20;
        UIBarButtonItem *shareBtn= [[UIBarButtonItem alloc] initWithCustomView:exportBtn];
        self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:cameraBtn,shareBtn,spaceBtn,nil];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewImage:)
                                                 name:@"newImageUpload"
                                               object:nil];
    
    [self getPersonalAlbum];
}
-(void)historyMsgBtnClick
{
    NSArray *historyMsgList=[datam getAlbumMsgList:[teacherInfoDic objectForKey:@"用户唯一码"] ifRead:1];
    if(historyMsgList && historyMsgList.count>0)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DDIPraiseDetail *itemController=[mainStoryboard instantiateViewControllerWithIdentifier:@"praiseDetail"];
        itemController.praiseList=historyMsgList;
        itemController.title=@"相册已读消息";
        [self.navigationController pushViewController:itemController animated:YES];
    }
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"相册消息为空"];
        [tipView showInView:self.view];
    }
}
-(void)beginPhotograph
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
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  *img;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(800, 800);
        img=[img scaleToSize:newsize];
        //NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        
        
        
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
    if(img)
        [self performSegueWithIdentifier:@"popSendView" sender:img];
    else
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"获取图片失败"];
        [tipView showInView:self.view];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"popSendView"])
    {
        UINavigationController *NavController=segue.destinationViewController;
        
        DDIAlbumSend *dest1=[NavController.childViewControllers objectAtIndex:0];
        dest1.image=sender;
        
    }
    
}
-(void)addNewImage:(NSNotification *)notification
{
    if(notification)
    {
        NSDictionary *item=[notification userInfo];
        NSString *action=[item objectForKey:@"action"];
        if([action isEqualToString:@"新增"])
        {
            
            NSString *faburen=[item objectForKey:@"发布人唯一码"];
            if([faburen isEqualToString:_userid])
            {
                [imageList insertObject:item atIndex:0];
                [self.tableView reloadData];
            }
        }
        else if ([action isEqualToString:@"点赞"])
        {
            NSArray *praisedArray=[item objectForKey:@"praisedArray"];
            BOOL flag=false;
            for(NSDictionary *item in praisedArray)
            {
                NSString *faburen=[item objectForKey:@"发布人唯一码"];
                if([faburen isEqualToString:_userid])
                {
                    NSString *imageId=[item objectForKey:@"文件名"];
                    for(int i=0;i<imageList.count;i++)
                    {
                        NSDictionary *subitem=[imageList objectAtIndex:i];
                        NSString *imageName=[subitem objectForKey:@"文件名"];
                        if([imageName isEqualToString:imageId])
                        {
                            NSArray *praiseList=[item objectForKey:@"点赞列表"];
                            NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:subitem];
                            [newItem setObject:[NSNumber numberWithInt:(int)praiseList.count] forKey:@"被赞次数"];
                            [imageList replaceObjectAtIndex:i withObject:newItem];
                            flag=true;
                            break;
                        }
                    }
                }
                
            }
            if(flag)
            {
                [self.tableView reloadData];
            }
        }
        else if ([action isEqualToString:@"评论"])
        {
            NSDictionary *imageDic=[item objectForKey:@"相片信息"];
            NSString *faburen=[imageDic objectForKey:@"发布人唯一码"];
            if([faburen isEqualToString:_userid])
            {
                NSString *imageId=[item objectForKey:@"imageId"];
                for(int i=0;i<imageList.count;i++)
                {
                    NSDictionary *subitem=[imageList objectAtIndex:i];
                    NSString *imageName=[subitem objectForKey:@"文件名"];
                    if([imageName isEqualToString:imageId])
                    {
                        NSNumber *num=[subitem objectForKey:@"评论次数"];
                        NSMutableDictionary *newItem=[NSMutableDictionary dictionaryWithDictionary:subitem];
                        [newItem setObject:[NSNumber numberWithInt:num.intValue+1] forKey:@"评论次数"];
                        [imageList replaceObjectAtIndex:i withObject:newItem];
                        [self.tableView reloadData];
                        break;
                    }
                }
                
            }
        }
        else if([action isEqualToString:@"删除"])
        {
            NSArray *deleteArray=[item objectForKey:@"deleteArray"];
            for(NSDictionary *item in deleteArray)
            {
                NSString *imageName=[item objectForKey:@"文件名"];
                for(NSMutableDictionary *wItem in imageList)
                {
                    NSString *wImageName=[wItem objectForKey:@"文件名"];
                    if([imageName isEqualToString:wImageName])
                    {
                        [imageList removeObject:wItem];
                        break;
                    }
                }
            }
            if(deleteArray.count>0)
            {
                [self.tableView reloadData];
            }
        }
    }
}
-(void)getPersonalAlbum
{
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"AlbumPraise.php?IsZip=1"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:@"个人相册" forKey:@"action"];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:_userid forKey:@"hostId"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    request.username=@"个人相册";
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [requestArray addObject:request];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"个人相册"])
    {
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        data   = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        NSData *upzipData = [LFCGzipUtillity uncompressZippedData:data];
        id res = [NSJSONSerialization JSONObjectWithData:upzipData options:NSJSONReadingMutableContainers error:nil];
        if (res && [res isKindOfClass:[NSDictionary class]])
        {
            NSString *jieguo=[res objectForKey:@"结果"];
            if([jieguo isEqualToString:@"成功"])
            {
                imageList=[NSMutableArray arrayWithArray:[res objectForKey:@"相册"]];
                [self.tableView reloadData];
                if(imageList==nil || imageList.count==0)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"还没有上传照片"];
                    [tipView showInView:self.view];
                }
                [self performSelector:@selector(doneLoadingTableViewData:) withObject:[NSNumber numberWithInt:(int)imageList.count] afterDelay:0.5];
            }
        }
    }
    else if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *headImage=[[UIImage alloc]initWithData:datas];
        if(headImage!=nil)
        {
            NSDictionary *indexDic=request.userInfo;
            NSString *path=[indexDic objectForKey:@"filename"];
            [datas writeToFile:path atomically:YES];
            NSIndexPath *indexPath=[indexDic objectForKey:@"indexPath"];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
        
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView showInView:self.view];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"newImageUpload" object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return imageList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    UILabel *day=(UILabel *)[cell viewWithTag:101];
    UILabel *month=(UILabel *)[cell viewWithTag:102];
    UILabel *year=(UILabel *)[cell viewWithTag:108];
    NSDictionary *item=[imageList objectAtIndex:indexPath.row];
    NSString *time=[item objectForKey:@"时间"];
    time=[time substringToIndex:10];
    day.text=[time substringWithRange:NSMakeRange(8, 2)];
    month.text=[[time substringWithRange:NSMakeRange(5, 2)] stringByAppendingString:@"月"];
    year.text=[[time substringWithRange:NSMakeRange(0, 4)] stringByAppendingString:@"年"];
    if(indexPath.row>0)
    {
        NSDictionary *itemlast=[imageList objectAtIndex:indexPath.row-1];
        NSString *timelast=[itemlast objectForKey:@"时间"];
        timelast=[timelast substringToIndex:10];
        if([time isEqualToString:timelast])
        {
            day.text=@"";
            month.text=@"";
            year.text=@"";
        }
        
    }
    UIImageView *iv=(UIImageView *)[cell viewWithTag:103];
    iv.clipsToBounds=YES;
    NSString *iconName=[item objectForKey:@"文件名"];
    UIImage *image;
   
    NSString *filename=[savepath stringByAppendingString:iconName];
    if([CommonFunc fileIfExist:filename])
    {
        image=[UIImage imageWithContentsOfFile:filename];
    }
    else
    {
        NSString *urlStr=[item objectForKey:@"文件地址"];
        image=[UIImage imageNamed:@"empty_photo"];
        
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.username=@"下载图片";
        NSMutableDictionary *indexDic=[[NSMutableDictionary alloc]init];
        [indexDic setObject:indexPath forKey:@"indexPath"];
        [indexDic setObject:filename forKey:@"filename"];
        request.userInfo=indexDic;
        [request setDelegate:self];
        [request startAsynchronous];
        [requestArray addObject:request];
    }
    /*
    int m=image.size.width;
    if(image.size.height<m)
        m=image.size.height;
    image=[image cutFromImage:CGRectMake(0, 0, m, m)];
     */
    [iv setImage:image];
    
    UILabel *address=(UILabel *)[cell viewWithTag:104];
    if([[item objectForKey:@"位置"] isEqual:[NSNull null]])
        address.text=@"";
    else
        address.text=[item objectForKey:@"位置"];
    UILabel *description=(UILabel *)[cell viewWithTag:105];
    if([[item objectForKey:@"描述"] isEqual:[NSNull null]])
        description.text=@"";
    else
        description.text=[item objectForKey:@"描述"];
    UILabel *pCount=(UILabel *)[cell viewWithTag:106];
    NSNumber *num=[item objectForKey:@"被赞次数"];
    pCount.text=[NSString stringWithFormat:@"%d",num.intValue];
    UILabel *CCount=(UILabel *)[cell viewWithTag:107];
    num=[item objectForKey:@"评论次数"];
    CCount.text=[NSString stringWithFormat:@"%d",num.intValue];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *imageArray=[NSMutableArray array];
    for(int i=(int)indexPath.row;i<imageList.count;i++)
    {
        [imageArray addObject:[imageList objectAtIndex:i]];
        if(imageArray.count>=20)
            break;
    }
    
    DDIAlbumScrollPage *asp=[[DDIAlbumScrollPage alloc]init];
    asp.imageArray=imageArray;
    [self.navigationController pushViewController:asp animated:YES];
    
}
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _reloading = YES;
    [self getPersonalAlbum];
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (void)doneLoadingTableViewData:(NSNumber *)newcount
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}
@end
