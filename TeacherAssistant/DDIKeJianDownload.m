//
//  DDIKeJianDownload.m
//  老师助手
//
//  Created by yons on 13-12-7.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIKeJianDownload.h"



extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kInitURL;//默认单点webServic
extern NSString *kUserIndentify;
extern NSMutableDictionary *teacherInfoDic;
extern int kUserType;


@interface DDIKeJianDownload ()

@end

@implementation DDIKeJianDownload

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    if(kUserType==1)
        rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStyleDone target:self action:@selector(uploadKeJian)];
    else
        rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(reloadKeJian)];
    _savePath=[CommonFunc createPath:@"/courseware/"];
    _keJianArray=[[NSMutableArray alloc] init];
    _fileManager=[NSFileManager defaultManager];
    _formatter = [[NSNumberFormatter alloc] init];
    [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [_formatter setPositiveFormat:@"##0.00"];
    /*
    if(kUserType==1)
    {
        _kejianData=[[NSMutableDictionary alloc] initWithDictionary:[userInfoDic objectForKey:@"课件下载"]];
        _allKeJianArray=[[NSMutableArray alloc] initWithArray:[_kejianData objectForKey:@"数据"]];
        
        for(int i=0;i<_allKeJianArray.count;i++)
        {
            NSDictionary *item=[_allKeJianArray objectAtIndex:i];
            if([[item objectForKey:@"课程名称"] isEqualToString:self.className])
                [_keJianArray addObject:item];
        }
        [self ifFileExist];
        if(_keJianArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到课件，请先上传"];
            [tipView showInView:self.view];
        }
    }
    else
    {
        [self reloadKeJian];
    }
     */
    [self reloadKeJian];
    _imageHead=[[NSMutableDictionary alloc]init];
    [_imageHead setObject:[UIImage imageNamed:@"默认"] forKey:@"默认"];
    [_imageHead setObject:[UIImage imageNamed:@"excel"] forKey:@"xls"];
    [_imageHead setObject:[UIImage imageNamed:@"excel"] forKey:@"xlsx"];
    [_imageHead setObject:[UIImage imageNamed:@"ppt"] forKey:@"ppt"];
    [_imageHead setObject:[UIImage imageNamed:@"word"] forKey:@"doc"];
    [_imageHead setObject:[UIImage imageNamed:@"zip"] forKey:@"zip"];
    [_imageHead setObject:[UIImage imageNamed:@"txt"] forKey:@"txt"];
    [_imageHead setObject:[UIImage imageNamed:@"rmvp"] forKey:@"rmvp"];
    [_imageHead setObject:[UIImage imageNamed:@"rmvp"] forKey:@"rmvb"];
    [_imageHead setObject:[UIImage imageNamed:@"avi"] forKey:@"mov"];
    [_imageHead setObject:[UIImage imageNamed:@"rar"] forKey:@"rar"];
    [_imageHead setObject:[UIImage imageNamed:@"png"] forKey:@"png"];
    [_imageHead setObject:[UIImage imageNamed:@"jpg"] forKey:@"jpeg"];
    [_imageHead setObject:[UIImage imageNamed:@"jpg"] forKey:@"jpg"];
    [_imageHead setObject:[UIImage imageNamed:@"gif"] forKey:@"gif"];
    [_imageHead setObject:[UIImage imageNamed:@"avi"] forKey:@"avi"];
    [_imageHead setObject:[UIImage imageNamed:@"ic_file_amr"] forKey:@"amr"];
    [_imageHead setObject:[UIImage imageNamed:@"avi"] forKey:@"3gp"];
    [_imageHead setObject:[UIImage imageNamed:@"avi"] forKey:@"mp4"];
    [_imageHead setObject:[UIImage imageNamed:@"ic_file_pdf"] forKey:@"pdf"];
    [_imageHead setObject:[UIImage imageNamed:@"ic_file_mp3"] forKey:@"mp3"];
    [_imageHead setObject:[UIImage imageNamed:@"ic_file_amr"] forKey:@"ogg"];
    _requestArray=[[NSMutableArray alloc]init];
   
    
    _downImage=[UIImage imageNamed:@"已下载"];
    _downImage=[_downImage scaleToSize:CGSizeMake(24, 24)];
}

-(void)reloadKeJian
{
    rightBtn.enabled=false;
    [_keJianArray removeAllObjects];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.className forKey:@"课程名称"];
    [dic setObject:self.teacherUserName forKey:@"老师用户名"];
    NSString *remoteInterface;
    if(kUserType==1)
        remoteInterface=@"KeJianDownload.php";
    else
        remoteInterface=@"KeJianDownload_student.php";
    
        
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:remoteInterface] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"课件列表";
    [_requestArray addObject:request];
    [request startAsynchronous];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取课件列表" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.tableView];
    
}
-(void)ifFileExist
{
    
    
    for(int i=0;i<_keJianArray.count;i++)
    {
        NSMutableDictionary *item=[[NSMutableDictionary alloc] initWithDictionary:[_keJianArray objectAtIndex:i]];
        NSString *fileName=[item objectForKey:@"文件名"];
        fileName=[_savePath stringByAppendingString:fileName];
        if([_fileManager fileExistsAtPath:fileName])
        {
            [item setObject:@"已下载" forKey:@"是否下载"];
            double size=[[_fileManager attributesOfItemAtPath:fileName error:nil] fileSize];
            NSNumber *numberSize = [NSNumber numberWithFloat:(size/(1024*1024))];
            [item setObject:[_formatter stringFromNumber:numberSize] forKey:@"文件大小"];
        }
        else
        {
            NSNumber *numberSize=[item objectForKey:@"文件大小"];
            numberSize = [NSNumber numberWithFloat:(numberSize.doubleValue/(1024*1024))];
            [item setObject:[_formatter stringFromNumber:numberSize] forKey:@"文件大小"];
        }
        [_keJianArray replaceObjectAtIndex:i withObject:item];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.parentViewController.navigationItem.title=self.className;
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    if(_currentRequest)
        [_currentRequest clearDelegatesAndCancel];
    for(ASIHTTPRequest *req in _requestArray)
    {
        [req setDownloadProgressDelegate:nil];
        [req clearDelegatesAndCancel];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSThread cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _keJianArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *item=[_keJianArray objectAtIndex:indexPath.row];
    NSString *titleName=[item objectForKey:@"名称"];
    NSNumber *downTimes=[item objectForKey:@"下载次数"];
    NSString *lastTime=[item objectForKey:@"最后一次下载"];
    if(lastTime==nil) lastTime=@"";
    NSString *ifexist=[item objectForKey:@"是否下载"];
    NSString *filesize=[item objectForKey:@"文件大小"];
    NSString *filename=[item objectForKey:@"文件名"];
    NSString *lastComponent = [filename pathExtension].lowercaseString;
    
    if([_imageHead objectForKey:lastComponent]==nil)
        lastComponent=@"默认";
    cell.imageView.image=[_imageHead objectForKey:lastComponent];

    cell.textLabel.text=titleName;
    UIImageView *downImageView=(UIImageView *)[cell viewWithTag:13];
    UILabel *sizeLabel=(UILabel *)[cell viewWithTag:12];
    for(UIProgressView *view in cell.subviews)
    {
        if([view isKindOfClass:[UIProgressView class]])
           [view removeFromSuperview];
    }
    cell.detailTextLabel.hidden=NO;
    if(ifexist!=nil)
    {
        
        cell.detailTextLabel.text=@" ";
        sizeLabel.text=[NSString stringWithFormat:@"大小:%@ MB  下载次数:%d",filesize,downTimes.intValue];
        downImageView.image=_downImage;
        
    }
    else
    {
        cell.detailTextLabel.text=[NSString stringWithFormat:@"大小:%@ MB  下载次数:%d",filesize,downTimes.intValue];
        sizeLabel.text=@"";
        downImageView.image=nil;
        
        UIProgressView *progress=[item objectForKey:@"progress"];
        if(progress)
        {
           [cell addSubview:progress];
           cell.detailTextLabel.hidden=YES;
        }
       
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    _curRow=indexPath.row;
    if(cell.detailTextLabel.hidden==YES)
    {
        for(ASIHTTPRequest *req in _requestArray)
        {
            if(req.tag==_curRow)
                [req cancel];
        }
    }
    else
    {
        NSDictionary *item=[_keJianArray objectAtIndex:indexPath.row];
        
        _urlStr=[item objectForKey:@"文件地址"];
        NSString *ifdown=[item objectForKey:@"是否下载"];
        if(ifdown!=nil)
        {
            UIActionSheet *actionSheet;
            if(kUserType==1)
                actionSheet= [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:@"删除服务器文件"
                                          otherButtonTitles:@"删除本地文件",@"打开文件",nil];
            else
                actionSheet= [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:@"取消"
                              destructiveButtonTitle:@"删除本地文件"
                              otherButtonTitles:@"打开文件",nil];
            actionSheet.actionSheetStyle =  UIActionSheetStyleAutomatic;
            actionSheet.tag=indexPath.row;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
        {
            [self download];
        }
    }
}
-(void)uploadKeJian
{
    if([rightBtn.title isEqualToString:@"终止"])
    {
        [_currentRequest cancel];
    }
    if(![rightBtn.title isEqualToString:@"上传"])
        return;
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"摄像机",@"本地相簿",@"本地视频",nil];
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
            case 1://摄像机
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
                imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            case 2://本地相簿
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
               
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.allowsEditing=false;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            case 3://本地视频
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            }
                break;
            default:
                break;
        }
        
    }
    else
    {
        NSMutableDictionary *item=[_keJianArray objectAtIndex:actionSheet.tag];
        NSString *filename=[item objectForKey:@"文件名"];
        NSString *path=[_savePath stringByAppendingString:filename];
        if(kUserType!=1)
            buttonIndex=buttonIndex+1;
        switch (buttonIndex) {
            case 0:
            {
                NSError *err;
                [_fileManager removeItemAtPath:path error:&err];
                //删除服务器文件
                [self deleteRemoteFile:item];
                break;
            }
            case 1:
            {
                //删除本地文件
                NSError *err;
                [_fileManager removeItemAtPath:path error:&err];
                [item removeObjectForKey:@"是否下载"];
                [self.tableView reloadData];
                break;
            }
            case 2:
            {
                //打开文件
                
                NSURL *url = [NSURL fileURLWithPath:path];
                self.documentInteractionController = [UIDocumentInteractionController                                                      interactionControllerWithURL:url];
                [self.documentInteractionController setDelegate:self];
                bool b=[self.documentInteractionController presentPreviewAnimated:YES];
                if(!b)
                {
                    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到可用来打开此课件的程序"];
                    [tipView show];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(1280, 720);
        img=[img scaleToSize:newsize];
        self.fileData = UIImageJPEGRepresentation(img, 0.6);
        self.extName=@"jpeg";
        
    } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        NSString *videoPath =(NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        self.fileData = [NSData dataWithContentsOfFile:videoPath];
        self.extName=[videoPath pathExtension];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
  
    [self uploadFile];
}
- (void) download{
    
    NSURL *url = [NSURL URLWithString:[_urlStr URLEncodedString]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_curRow inSection:0];
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.hidden=YES;
    UIProgressView *progress=[[UIProgressView alloc]initWithFrame:CGRectMake(65, 35, 210, 2)];
    NSMutableDictionary *item=[_keJianArray objectAtIndex:_curRow];
    [item setObject:progress forKey:@"progress"];
    [_keJianArray replaceObjectAtIndex:_curRow withObject:item];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    request.tag = _curRow;
    request.username=@"下载课件";
    [request setDownloadProgressDelegate:progress];
    [request setDelegate:self];
    request.showAccurateProgress=YES;
    [_requestArray addObject:request];
    request.timeOutSeconds=0;
    [request startAsynchronous];
    
}

-(void) uploadFile
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"为上传的文件起一个名字" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    NSString *teacherName=[teacherInfoDic objectForKey:@"姓名"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"[MM-dd HH:mm:ss]"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    textField.text=[NSString stringWithFormat:@"%@%@",teacherName,currentDateStr];
    [alert show];
}

-(void) deleteRemoteFile:(NSDictionary *)item
{
    NSString *filename=[item objectForKey:@"文件名"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:filename forKey:@"课件名称"];
    
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"KeJianDelete.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"删除课件";
    request.userInfo=item;
    [_requestArray addObject:request];
    [request startAsynchronous];
    
}

-(void) updateDownloadCount:(NSDictionary *)item
{
    NSString *filename=[item objectForKey:@"文件名"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:filename forKey:@"课件名称"];
    [dic setObject:self.teacherUserName forKey:@"老师用户名"];
    
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"KeJianCounter.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"更新课件";
    request.userInfo=item;
    [_requestArray addObject:request];
    [request startAsynchronous];
    
}

-(void) alertView : (UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
        return;
    //得到输入框
    UITextField *tf=[alertView textFieldAtIndex:0];
    self.uploadFileName=[NSString stringWithFormat:@"%@.%@", [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],self.extName];
    if (self.uploadFileName.length>0) {
        NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
        NSURL *url =[NSURL URLWithString:uploadUrl];
        if(_currentRequest)
            [_currentRequest cancel];
        _currentRequest =[ASIFormDataRequest requestWithURL:url];
        [_currentRequest setPostFormat:ASIMultipartFormDataPostFormat];
        [_currentRequest setRequestMethod:@"POST"];
        
        [_currentRequest addData:self.fileData withFileName:self.uploadFileName andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
        [_currentRequest
         setPostValue:kUserIndentify forKey:@"用户较验码"];
        [_currentRequest
         setPostValue:self.className forKey:@"课程名称"];
        
        uploadProgress=[[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 3)];
        [self.view addSubview:uploadProgress];
        
        [_currentRequest setUploadProgressDelegate:uploadProgress];
        [_currentRequest setDelegate:self];
        _currentRequest.username=@"上传课件";
        _currentRequest.timeOutSeconds=0;
        [_currentRequest startAsynchronous];
        _currentRequest.showAccurateProgress=YES;
        [rightBtn setTitle:@"终止"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}
-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{

    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    if([request.username isEqualToString:@"上传课件"])
    {
        if(uploadProgress) [uploadProgress removeFromSuperview];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
        
            NSString *filePath=[_savePath stringByAppendingString:[dict objectForKey:@"文件名"]];
            [self.fileData writeToFile:filePath atomically:YES];
            
            NSMutableDictionary *item=[[NSMutableDictionary alloc]init];
            [item setObject:[dict objectForKey:@"名称"] forKey:@"名称"];
            [item setObject:@"已下载" forKey:@"是否下载"];
            [item setObject:[dict objectForKey:@"文件地址"] forKey:@"文件地址"];
            [item setObject:[dict objectForKey:@"文件名"] forKey:@"文件名"];
            [item setObject:self.className forKey:@"课程名称"];
            double size=[[_fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
            NSNumber *numberSize = [NSNumber numberWithFloat:(size/(1024*1024))];
            [item setObject:[_formatter stringFromNumber:numberSize] forKey:@"文件大小"];
            [item setObject:[[NSNumber alloc]initWithInt:1] forKey:@"下载次数"];
            [_keJianArray addObject:item];
            //[_allKeJianArray addObject:item];
            //[_kejianData setObject:_allKeJianArray forKey:@"数据"];
            //[userInfoDic setObject:_kejianData forKey:@"课件下载"];
            [self.tableView reloadData];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_keJianArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            [rightBtn setTitle:@"已上传"];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverSaveBtn) userInfo:nil repeats:NO];
            
            NSString *filename=[item objectForKey:@"名称"];
            NSString *msg=[NSString stringWithFormat:@"课件<%@>上传成功",filename];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:msg];
            [tipView show];
            NSLog(@"上传成功:%@",self.uploadFileName);
            [self scrollToBottomAnimated:YES];
        }
        
    }
    else if([request.username isEqualToString:@"下载课件"])
    {
        NSString *filename;
        if(data)
        {
            NSMutableDictionary *item=[_keJianArray objectAtIndex:request.tag];
            
            filename=[item objectForKey:@"文件名"];
            NSString *path=[_savePath stringByAppendingString:filename];
            [data writeToFile:path atomically:YES];
            
            [item setObject:@"已下载" forKey:@"是否下载"];
            double size=[[_fileManager attributesOfItemAtPath:path error:nil] fileSize];
            NSNumber *numberSize = [NSNumber numberWithFloat:(size/(1024*1024))];
            [item setObject:[_formatter stringFromNumber:numberSize] forKey:@"文件大小"];
            NSNumber *cishu=[item objectForKey:@"下载次数"];
            [item setObject:[[NSNumber alloc] initWithInt:cishu.intValue+1] forKey:@"下载次数"];
            UIProgressView *progress=[item objectForKey:@"progress"];
            [progress removeFromSuperview];
            [item removeObjectForKey:@"progress"];
            [_keJianArray replaceObjectAtIndex:request.tag withObject:item];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:request.tag inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSLog(@"下载成功:%@",filename);
            [self updateDownloadCount:item];
            
        }
        
        
    }
    else if([request.username isEqualToString:@"删除课件"])
    {
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *result=[dict objectForKey:@"STATUS"];
        if([result isEqualToString:@"成功"])
        {
            NSDictionary *item=request.userInfo;
            [_keJianArray removeObject:item];
            for (int i=0; i<_allKeJianArray.count;i++) {
                NSDictionary *listItem=[_allKeJianArray objectAtIndex:i];
                NSString *listUrl=[listItem objectForKey:@"文件地址"];
                NSString *url=[item objectForKey:@"文件地址"];
                if([listUrl isEqualToString:url])
                {
                    [_allKeJianArray removeObjectAtIndex:i];
                    break;
                }
            }
            NSString *filename=[item objectForKey:@"名称"];
            NSString *msg=[NSString stringWithFormat:@"服务器端课件<%@>已删除",filename];
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:msg];
            [tipView show];
            //[_kejianData setObject:_allKeJianArray forKey:@"数据"];
            //[userInfoDic setObject:_kejianData forKey:@"课件下载"];
            [self.tableView reloadData];
        }
        
        NSLog(@"删除课件%@",result);
    }
    else if([request.username isEqualToString:@"更新课件"])
    {
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *result=[dict objectForKey:@"STATUS"];
        if([result isEqualToString:@"成功"])
        {
            
        }
        NSLog(@"更新课件%@",result);
    }
    else if([request.username isEqualToString:@"课件列表"])
    {
        rightBtn.enabled=true;
        [alertTip removeFromSuperview];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if(resultArray.count==0)
        {
            OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"没有找到课件"];
            [tipView showInView:self.view];
        }
        else
        {
            for(int i=0;i<resultArray.count;i++)
            {
                NSMutableDictionary *item=[[NSMutableDictionary alloc]initWithDictionary:[resultArray objectAtIndex:i]];
                if([item objectForKey:@"文件名"])
                   [_keJianArray addObject:item];
            }
            [self ifFileExist];
            [self.tableView reloadData];
        }
    }
    if([_requestArray containsObject:request])
        [_requestArray removeObjectIdenticalTo:request];
    request=nil;
    
}
-(void)recoverSaveBtn
{
    if(rightBtn)
        [rightBtn setTitle:@"上传"];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    if([request.username isEqualToString:@"上传课件"])
    {
        if(uploadProgress) [uploadProgress removeFromSuperview];
        [rightBtn setTitle:@"上传失败"];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverSaveBtn) userInfo:nil repeats:NO];
        
    }
    else if([request.username isEqualToString:@"下载课件"])
    {
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:request.tag inSection:0];
        NSMutableDictionary *item=[_keJianArray objectAtIndex:request.tag];
        UIProgressView *progress=[item objectForKey:@"progress"];
        [progress removeFromSuperview];
        [item removeObjectForKey:@"progress"];
        [_keJianArray replaceObjectAtIndex:request.tag withObject:item];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if([_requestArray containsObject:request])
            [_requestArray removeObjectIdenticalTo:request];
        
    }
    NSString *errorStr;
    if([error.localizedDescription isEqualToString:@"The request was cancelled"])
        errorStr=@"操作被取消";
    else if([error.localizedDescription isEqualToString:@"The request timed out"])
        errorStr=@"请求超时";
    else
        errorStr=[error localizedDescription];
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:errorStr];
    [tipView show];
    request=nil;
}



/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
