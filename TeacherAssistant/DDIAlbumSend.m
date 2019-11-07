//
//  DDIAlbumSend.m
//  掌上校园
//
//  Created by Mac on 15/1/9.
//  Copyright (c) 2015年 dandian. All rights reserved.
//

#import "DDIAlbumSend.h"
extern NSString *stuAddress;
extern int kUserType;
extern Boolean kIOS7;
extern NSString *kInitURL;
extern NSString *kUserIndentify;
@interface DDIAlbumSend ()

@end

@implementation DDIAlbumSend

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"发布图片";
    self.tableView.backgroundColor=[UIColor colorWithRed:228/255.0 green:244/255.0 blue:234/255.0 alpha:1];
    requestArray=[NSMutableArray array];
    //定义一个toolBar
    topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    //设置style
    [topView setBarStyle:UIBarStyleDefault];
    
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * button1 =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    [topView setItems:buttonsArray];

    if(stuAddress!=nil && stuAddress.length>0)
    {
        _lbAddress.text=stuAddress;
    }
    DDIAppDelegate *app=(DDIAppDelegate *)[UIApplication sharedApplication].delegate;
    [app getGPS];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setGPSAddress)
                                                 name:@"getGPSAddress"
                                               object:nil];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 100.0, 29.0, 29.0)];
    [backBtn setTitle:@"" forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    saveBtn=[[UIBarButtonItem alloc]initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(uploadImage)];
    self.navigationItem.rightBarButtonItem=saveBtn;
    [_sgFanwei addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
    if(!kIOS7)
    {
        [_sgFanwei.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.8].CGColor];
        [_sgFanwei.layer setBorderWidth:1.0f];
        [_sgFanwei.layer setCornerRadius:4.0f];
        [_sgFanwei.layer setMasksToBounds:YES];
        _textView.backgroundColor=[UIColor whiteColor];
    }
    _sgFanwei.tintColor = [UIColor blackColor];
    
    fileData = UIImageJPEGRepresentation(_image, 0.5);
    CGSize newsize=CGSizeMake(250, 250);
    
    _image=[_image scaleToSize:newsize];
    _imageView.contentMode = UIViewContentModeTopLeft;
    
    [_imageView setImage:_image];
    [_textView setInputAccessoryView:topView];
    _textView.layer.borderWidth=0.5;
    _textView.layer.borderColor=[UIColor blackColor].CGColor;
    _textView.layer.cornerRadius=5.0;
    _textView.delegate=self;
    _lbDevice.text=[NSString stringWithFormat:@"来自:%@",[CommonFunc deviceString]];
    if(kUserType==1)
    {
        [_sgFanwei setTitle:@"本部门" forSegmentAtIndex:1];
    }
    
    lockView=[[UIView alloc]initWithFrame:self.view.frame];
    [lockView setBackgroundColor:[UIColor blackColor]];
    [lockView setAlpha:0.5];
   
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _lbholderText.hidden=YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(!_textView.hasText)
        _lbholderText.hidden=NO;
}
-(void)textViewDidChange:(UITextView *)textView
{
    _lbTxtCount.text=[NSString stringWithFormat:@"%lu/150",(unsigned long)_textView.text.length];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location>=150)
    {
        //控制输入文本的长度
        if(text.length>0)
            return  NO;
        else
            return YES;
    }
    return YES;
}
-(void)uploadImage
{
    if(_textView.text.length>150)
    {
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"描述文字不能超过150字"];
        [tipView showInView:self.view];
        return;
    }
    saveBtn.enabled=NO;
    [self.view addSubview:lockView];
    progressView=[[OLGhostAlertView alloc] initWithIndicator:@"正在上传..." timeout:0 dismissible:NO];
    [progressView showInView:self.view];
    
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:fileData withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:@"相册" forKey:@"TuPianLeiBie"];
    [request setPostValue:_textView.text forKey:@"Description"];
    [request setPostValue:stuAddress forKey:@"Address"];
    NSString *fanwei;
    if(_sgFanwei.selectedSegmentIndex==0)
        fanwei=@"全校";
    else
        fanwei=@"本班";
    [request setPostValue:fanwei forKey:@"ShowLimit"];
    [request setPostValue:[CommonFunc deviceString] forKey:@"device"];
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:fileData forKey:@"data"];
    request.username=@"上传图片";
    request.userInfo=dic;
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];
    
    
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"上传图片"])
    {
        saveBtn.enabled=YES;
        if(lockView) [lockView removeFromSuperview];
        if(progressView) [progressView removeFromSuperview];
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            NSString *savePath=[CommonFunc createPath:@"/utils/"];
            NSDictionary *dic=request.userInfo;
            NSData *data=[dic objectForKey:@"data"];
            NSString *filename=[dict objectForKey:@"文件名"];
            filename=[savePath stringByAppendingString:filename];
            [data writeToFile:filename atomically:YES];
           
            [self dismissViewControllerAnimated:YES completion:^(void){
                [dict setObject:@"新增" forKey:@"action"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageUpload" object:nil userInfo:dict];
            }];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    saveBtn.enabled=YES;
    if(lockView) [lockView removeFromSuperview];
    if(progressView) [progressView removeFromSuperview];
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:[error localizedDescription]];
    [tipView showInView:self.view];
}
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)setGPSAddress
{
    _lbAddress.text=stuAddress;
}

- (void)resignKeyboard
{
    
    [_textView resignFirstResponder];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getGPSAddress" object:nil];
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
-(void)segmentAction:(UISegmentedControl *)Seg
{
    
    //NSInteger Index = Seg.selectedSegmentIndex;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        return _image.size.height+12;
    }
    else if(indexPath.row==2)
    {
        CGSize size=[_lbAddress.text sizeWithFont:_lbAddress.font constrainedToSize:CGSizeMake(_lbAddress.frame.size.width, 1000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        return size.height+6;
    }
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
