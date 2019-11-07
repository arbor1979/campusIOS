//
//  DDIKeTangPingJia.m
//  老师助手
//
//  Created by yons on 13-12-19.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIKeTangPingJia.h"

extern NSMutableDictionary *userInfoDic;
extern Boolean kIOS7;
extern NSString *kServiceURL;
extern NSString *kUserIndentify;
extern int kUserType;
extern NSString *kInitURL;
extern NSMutableDictionary *teacherInfoDic;
@interface DDIKeTangPingJia ()

@end

@implementation DDIKeTangPingJia


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.neiRongText.layer.borderColor = [UIColor grayColor].CGColor;
    self.neiRongText.layer.borderWidth =1.0;
    self.neiRongText.layer.cornerRadius =5.0;
    self.zuoYeText.layer.borderColor = [UIColor grayColor].CGColor;
    self.zuoYeText.layer.borderWidth =1.0;
    self.zuoYeText.layer.cornerRadius =5.0;
    self.summaryText.layer.borderColor = [UIColor grayColor].CGColor;
    self.summaryText.layer.borderWidth =1.0;
    self.summaryText.layer.cornerRadius =5.0;
    rightBtn= [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(savePingJia)];
    bWanzixi=false;
    if(kUserType==1)
    {
        
        _dengjiArray=[[NSArray alloc] initWithObjects:@"优",@"良",@"中",@"差", nil];
        _imageSel=[[NSMutableArray alloc] init];
        [_imageSel addObject:[UIImage imageNamed:@"优_on"]];
        [_imageSel addObject:[UIImage imageNamed:@"良_on"]];
        [_imageSel addObject:[UIImage imageNamed:@"中_on"]];
        [_imageSel addObject:[UIImage imageNamed:@"差_on"]];
        _imageDes=[[NSMutableArray alloc] init];
        [_imageDes addObject:[UIImage imageNamed:@"优_off"]];
        [_imageDes addObject:[UIImage imageNamed:@"良_off"]];
        [_imageDes addObject:[UIImage imageNamed:@"中_off"]];
        [_imageDes addObject:[UIImage imageNamed:@"差_off"]];
        
        _scheduleArray=[[NSMutableArray alloc] initWithArray:[userInfoDic objectForKey:@"教师上课记录"]];
        _classInfoDic=[[NSMutableDictionary alloc] initWithDictionary:[_scheduleArray objectAtIndex:self.classIndex.intValue]];
        NSArray *shouduanarr=[userInfoDic objectForKey:@"教学日志_信息化手段"];
        if(shouduanarr!=nil && shouduanarr.count>0)
        {
            for(int i=0;i<shouduanarr.count;i++)
            {
                NSString *item=[shouduanarr objectAtIndex:i];
                if([item isEqualToString:@"其他"] || [item isEqualToString:@"其它"])
                {
                    UITextField *txtField=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
                    [txtField setPlaceholder:item];
                    [txtField setBackgroundColor:[UIColor whiteColor]];
                    txtField.layer.borderColor = [UIColor grayColor].CGColor;
                    txtField.layer.borderWidth =1.0;
                    txtField.layer.cornerRadius =5.0;
                    [_stackShouduan addArrangedSubview:txtField];
                }
                else
                {
                    QCheckBox *bodybtn = [[QCheckBox alloc] initWithDelegate:self];
                    [bodybtn setTitle:item forState:UIControlStateNormal];
                    [bodybtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    bodybtn.titleLabel.text=item;
                    [_stackShouduan addArrangedSubview:bodybtn];
                }
            }
        }
        NSArray *pingtaiarr=[userInfoDic objectForKey:@"教学日志_教学平台"];
        if(pingtaiarr!=nil && pingtaiarr.count>0)
        {
            for(int i=0;i<pingtaiarr.count;i++)
            {
                NSString *item=[pingtaiarr objectAtIndex:i];
                QCheckBox *bodybtn = [[QCheckBox alloc] initWithDelegate:self];
                [bodybtn setTitle:item forState:UIControlStateNormal];
                [bodybtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                bodybtn.titleLabel.text=item;
                [_stackPingtai addArrangedSubview:bodybtn];
            }
            UITextField *txtField=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            [txtField setPlaceholder:@"资源课程库名称"];
            [txtField setBackgroundColor:[UIColor whiteColor]];
            txtField.layer.borderColor = [UIColor grayColor].CGColor;
            txtField.layer.borderWidth =1.0;
            txtField.layer.cornerRadius =5.0;
            [_stackPingtai addArrangedSubview:txtField];
        }
        NSArray *sectionTimeArray=[[userInfoDic objectForKey:@"课表规则"] objectForKey:@"节次时间"];
        NSString *jieciStr=[_classInfoDic objectForKey:@"节次"];
        NSArray *jieciarr=[jieciStr componentsSeparatedByString:@"-"];
        if(sectionTimeArray!=nil)
        {
            for (NSDictionary *item in sectionTimeArray)
            {
                NSString *tmpStr=[item objectForKey:@"是否晚自习"];
                NSString *jieci=[jieciarr objectAtIndex:0];
                NSString *jieciNO=[item objectForKey:@"名称"];
                if(tmpStr!=nil && [tmpStr isEqualToString:@"是"] && jieci.intValue==jieciNO.intValue)
                {
                    bWanzixi=true;
                    break;
                }
            }
        }
        [self fillData];
        
    }
    else
    {
        goldStar=[UIImage imageNamed:@"goldStar"];
        grayStar=[UIImage imageNamed:@"star"];
    }
    
    
    [self getPingJiaData];
    if(kUserType==3)
    {
       rightBtn=Nil;
        self.neiRongText.editable=false;
        self.zuoYeText.editable=false;
        self.summaryText.editable=false;
    }
    //定义一个toolBar
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    
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
    
    [self.neiRongText setInputAccessoryView:topView];
    [self.zuoYeText setInputAccessoryView:topView];
    [self.summaryText setInputAccessoryView:topView];
    
    addPhoto=[UIImage imageNamed:@"addPhoto"];
    
    
    photosArray=[NSMutableArray array];
    photosArray1=[NSMutableArray array];
    photosArray2=[NSMutableArray array];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    savePath=[[documentPaths objectAtIndex:0] stringByAppendingString:@"/classNotes/"];
    BOOL fileExists = [fileManager fileExistsAtPath:savePath];
    if(!fileExists)
        [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:nil];
    
 
}
-(void)fillData
{
    NSUInteger  index=[_dengjiArray indexOfObject:[_classInfoDic objectForKey:@"课堂纪律"]];
    if(index==NSNotFound)
        iJiLvIndex=1;
    else
        iJiLvIndex=(int)index;
    index=[_dengjiArray indexOfObject:[_classInfoDic objectForKey:@"教室卫生"]];
    if(index==NSNotFound)
        iWeiShengIndex=1;
    else
        iWeiShengIndex=(int)index;
    
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    for(UIView *view in cell.contentView.subviews)
    {
        if([view isKindOfClass:UIButton.class])
        {
            UIButton *btn=(UIButton *)view;
            if(btn.tag-11==iJiLvIndex)
                [btn setImage:[_imageSel objectAtIndex:iJiLvIndex] forState:UIControlStateNormal];
            else
                [btn setImage:[_imageDes objectAtIndex:btn.tag-11] forState:UIControlStateNormal];
        }
    }
    cell=[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    for(UIView *view in cell.contentView.subviews)
    {
        if([view isKindOfClass:UIButton.class])
        {
            UIButton *btn=(UIButton *)view;
            if(btn.tag-11==iWeiShengIndex)
                [btn setImage:[_imageSel objectAtIndex:iWeiShengIndex] forState:UIControlStateNormal];
            else
                [btn setImage:[_imageDes objectAtIndex:btn.tag-11] forState:UIControlStateNormal];
        }
    }
    
    self.neiRongText.text=[_classInfoDic objectForKey:@"授课内容"];
    self.zuoYeText.text=[_classInfoDic objectForKey:@"作业布置"];
    self.summaryText.text=[_classInfoDic objectForKey:@"课堂情况简要"];
    NSString *shouduanStr=[_classInfoDic objectForKey:@"信息化手段"];
    NSString *pingtaiStr=[_classInfoDic objectForKey:@"教学平台"];
    if(shouduanStr!=nil)
    {
        shouduanStr=[shouduanStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSArray *tmparr= [shouduanStr componentsSeparatedByString:@","];
        for(UIView *subview in _stackShouduan.subviews)
        {
            if([subview isKindOfClass:QCheckBox.class])
            {
                QCheckBox *check=(QCheckBox *)subview;
                NSString *title=check.titleLabel.text;
                if([tmparr containsObject:title])
                {
                    check.checked=true;
                }
                else
                    check.checked=false;
            }
            else if([subview isKindOfClass:UITextField.class])
            {
                UITextField *field=(UITextField *)subview;
                field.text=@"";
                NSArray *shouduanarr=[userInfoDic objectForKey:@"教学日志_信息化手段"];
                for(NSString *item in tmparr)
                {
                    if(![shouduanarr containsObject:item])
                    {
                        field.text=item;
                        break;
                    }
                }
            }
        }
        
    }
    if(pingtaiStr!=nil)
    {
        pingtaiStr=[pingtaiStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        NSArray *tmparr= [pingtaiStr componentsSeparatedByString:@","];
        for(UIView *subview in _stackPingtai.subviews)
        {
            if([subview isKindOfClass:QCheckBox.class])
            {
                QCheckBox *check=(QCheckBox *)subview;
                NSString *title=check.titleLabel.text;
                if([tmparr containsObject:title])
                {
                    check.checked=true;
                }
                else
                    check.checked=false;
            }
        }
    }
    NSString *ziyuanStr=[_classInfoDic objectForKey:@"资源库课程库名称"];
    for(UIView *subview in _stackPingtai.subviews)
    {
        if([subview isKindOfClass:UITextField.class])
        {
            UITextField *field=(UITextField *)subview;
            field.text=@"";
            if(ziyuanStr!=nil && ziyuanStr.length>0)
            {
                field.text=ziyuanStr;
            }
        }
    }
    
}
-(void)drawImageFromArray:(NSArray *)photos parent:(UIView *)parent
{
    for(int i=0;i<10;i++)
    {
        UIView *subview=[parent viewWithTag:100+i];
        if(subview)
           [subview removeFromSuperview];
    }
    int j=(int)photos.count;
    int cols=(self.view.frame.size.width-15)/60;
    for(int i=0;i<j;i++)
    {
        UIButton *selBtn;
        if(i<=cols-1)
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(10+i*60, 120, 50, 50)];
        else
        {
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(10+(i-cols)*60, 120+60, 50, 50)];
        }
        NSMutableDictionary *item=[NSMutableDictionary dictionaryWithDictionary:[photos objectAtIndex:i]];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [selBtn setImage:img forState:UIControlStateNormal];
        }
        else
        {
            NSString *urlStr=[item objectForKey:@"文件地址"];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            request.username=@"下载图片";
            [item setObject:selBtn forKey:@"curBtn"];
            request.userInfo=item;
            request.tag=100+i;
            UIActivityIndicatorView *aiv=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
            aiv.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
            [selBtn addSubview:aiv];
            
            [request setDelegate:self];
            [request startAsynchronous];
            [requestArray addObject:request];
            [aiv startAnimating];
        }
        selBtn.tag=100+i;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parent addSubview:selBtn];
    }
    if(j<10 && kUserType!=3)
    {
        UIButton *selBtn;
        if(j<cols)
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(10+j*60, 120, 50, 50)];
        else
            selBtn=[[UIButton alloc]initWithFrame:CGRectMake(10+(j-cols)*60, 180, 50, 50)];
        [selBtn setImage:addPhoto forState:UIControlStateNormal];
        selBtn.tag=100+j;
        [selBtn.layer setMasksToBounds:YES];
        [selBtn.layer setCornerRadius:5];
        selBtn.layer.borderColor = [UIColor grayColor].CGColor;
        selBtn.layer.borderWidth =1.0;
        [selBtn addTarget:self action:@selector(addPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [parent addSubview:selBtn];
    }
    [self.tableView reloadData];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=[super tableView:tableView heightForRowAtIndexPath:indexPath];
    int j=(int)photosArray.count;
    int m=(int)photosArray1.count;
    int n=(int)photosArray2.count;
    int cols=(self.view.frame.size.width-20)/60;
    if(kUserType==1)
    {
        if(indexPath.section==4)
        {
            if(cols<j)
                return 240;
            else
                return 180;
        }
        else if(indexPath.section==5)
        {
            if(cols<m)
                return 240;
            else
                return 180;
        }
        else if(indexPath.section==6)
        {
            if(cols<n)
                return 240;
            else
                return 180;
        }
        else if(indexPath.section==7)
        {
            NSArray *shouduanarr=[userInfoDic objectForKey:@"教学日志_信息化手段"];
            if(shouduanarr!=nil && shouduanarr.count>0 && !bWanzixi)
                return shouduanarr.count*30;
            else
                return 0;
        }
        else if(indexPath.section==8)
        {
            NSArray *pingtaiarr=[userInfoDic objectForKey:@"教学日志_教学平台"];
            if(pingtaiarr!=nil && pingtaiarr.count>0 && !bWanzixi)
                return (pingtaiarr.count+1)*30;
            else
                return 0;
        }
        return height;
    }
    else if (indexPath.section==5 && kUserType!=1)
    {
        if(cols<m)
            return 240;
        else
            return 180;
    }
    else
        return height;
}

-(void)addPhotoClick:(UIButton *)sender
{
    if([sender.superview isEqual:_neiRongText.superview])
        curIndex=1;
    else if([sender.superview isEqual:_zuoYeText.superview])
        curIndex=2;
    else if([sender.superview isEqual:_summaryText.superview])
        curIndex=3;
    if([sender.imageView.image isEqual:addPhoto])
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
    else
    {
        if(kUserType ==3)
        {
            [self popPhotoView:[NSNumber numberWithInt:(int)sender.tag-100]];
        }
        else
        {
            UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:@"删除"
                                      otherButtonTitles:@"打开",nil];
            actionSheet.tag=sender.tag;
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    }
    
}
-(void)popPhotoView:(NSNumber *)index;
{
    NSArray *photos;
    if(curIndex==1)
        photos=photosArray;
    else if(curIndex==2)
        photos=photosArray1;
    else if(curIndex==3)
        photos=photosArray2;
    DDIPictureBrows *browserView = [[DDIPictureBrows alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSMutableArray *picArray=[NSMutableArray array];
    for(int i=0;i<photos.count;i++)
    {
        NSDictionary *item=[photos objectAtIndex:i];
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        if([CommonFunc fileIfExist:filename])
        {
            UIImage *img=[UIImage imageWithContentsOfFile:filename];
            [picArray addObject:img];
        }
    }
    if(picArray.count>0)
    {
        browserView.picArray=picArray;
        [browserView showFromIndex:index.intValue];
    }
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
    else
    {
        switch (buttonIndex) {
            case 0://删除
            {
                NSDictionary *item;
                if(curIndex==1)
                    item=[photosArray objectAtIndex:actionSheet.tag-100];
                else if(curIndex==2)
                    item=[photosArray1 objectAtIndex:actionSheet.tag-100];
                else if(curIndex==3)
                    item=[photosArray2 objectAtIndex:actionSheet.tag-100];
                [self deleteRemoteFile:item];
            }
                break;
            case 1://打开
            {
                int index=(int)actionSheet.tag-100;
                [self performSelector:@selector(popPhotoView:) withObject:[NSNumber numberWithInt:index] afterDelay:0.6];
            }
                break;
            default:
                break;
        }
    }
}
-(void) deleteRemoteFile:(NSDictionary *)item
{
    NSString *filename=[item objectForKey:@"文件名"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    if(kUserType==1)
    {
        if(curIndex==1)
            [dic setObject:@"课堂笔记" forKey:@"图片类别"];
        else if(curIndex==2)
            [dic setObject:@"课堂作业" forKey:@"图片类别"];
        else if(curIndex==3)
            [dic setObject:@"课堂情况" forKey:@"图片类别"];
    }
    else
            [dic setObject:@"课堂笔记" forKey:@"图片类别"];
    [dic setObject:filename forKey:@"课件名称"];
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"KeJianDelete.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"删除图片";
    request.userInfo=item;
    [requestArray addObject:request];
    [request startAsynchronous];
    
}
#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize newsize=CGSizeMake(1280, 720);
        img=[img scaleToSize:newsize];
        NSData *fileData = UIImageJPEGRepresentation(img, 0.5);
        [self uploadFile:fileData];

    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void) uploadFile:(NSData *)data
{
    NSString *uploadUrl= [kInitURL stringByAppendingString:@"upload.php"];
    NSURL *url =[NSURL URLWithString:uploadUrl];
    
    ASIFormDataRequest *request =[ASIFormDataRequest requestWithURL:url];
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [request setRequestMethod:@"POST"];
    
    [request addData:data withFileName:@"jpg" andContentType:@"image/jpeg" forKey:@"filename"];//This would be the file name which is accepting image object on server side e.g. php page accepting file
    [request setPostValue:kUserIndentify forKey:@"用户较验码"];
    [request setPostValue:self.className forKey:@"课程名称"];
    [request setPostValue:self.classNo forKey:@"老师上课记录编号"];
    UIView *parent;
    int addBtnTag;
    if(kUserType==1)
    {
        if(curIndex==1)
        {
            [request setPostValue:@"课堂笔记" forKey:@"图片类别"];
            parent=_neiRongText.superview;
            addBtnTag=(int)photosArray.count+100;
        }
        else if(curIndex==2)
        {
            [request setPostValue:@"课堂作业" forKey:@"图片类别"];
            parent=_zuoYeText.superview;
            addBtnTag=(int)photosArray1.count+100;
        }
        else
        {
            [request setPostValue:@"课堂情况" forKey:@"图片类别"];
            parent=_summaryText.superview;
            addBtnTag=(int)photosArray2.count+100;
        }
        
    }
    else
    {
        [request setPostValue:@"课堂笔记" forKey:@"图片类别"];
        parent=_zuoYeText.superview;
        addBtnTag=(int)photosArray1.count+100;
    }
    [request setDelegate:self];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:data forKey:@"data"];
    request.username=@"上传课堂笔记";
    request.userInfo=dic;
    request.uploadProgressDelegate=self;
    request.showAccurateProgress=YES;
    request.timeOutSeconds=300;
    [request startAsynchronous];
    [requestArray addObject:request];

    UIButton *btn=(UIButton *)[parent viewWithTag:addBtnTag];
    if(btn)
    {
        if(rpv)
            [rpv removeFromSuperview];
        else
        {
            MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
            newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
            newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
            newTheme.centerColor = [UIColor clearColor];
            newTheme.centerColor = [UIColor colorWithRed:224/255.0 green:248/255.0 blue:216/255.0 alpha:1.0];
            newTheme.sliceDividerHidden = YES;
            newTheme.labelColor = [UIColor blackColor];
            newTheme.labelShadowColor = [UIColor whiteColor];
            rpv = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) andTheme:newTheme];
        }
        rpv.progressTotal = 100;
        rpv.progressCounter = 0;
        [btn addSubview:rpv];
    }
    
}
-(void)setProgress:(float)newProgress;
{
    rpv.progressCounter = newProgress*100;
}

-(void)dealloc
{
    for(ASIHTTPRequest *req in requestArray)
    {
        [req clearDelegatesAndCancel];
    }
}
//隐藏键盘
- (void) resignKeyboard{
    [self.neiRongText resignFirstResponder];
    [self.zuoYeText resignFirstResponder];
    [self.summaryText resignFirstResponder];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(kUserType==1)
    {
        if(section==2 || section==3)
            return 0;
    }
    else
    {
        if(section==0 || section==1 || section==6 || section==7 || section==8)
            return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(kUserType==1)
    {
        if(section==2 || section==3)
            return 0;
        else if(section==7)
        {
            NSArray *shouduanarr=[userInfoDic objectForKey:@"教学日志_信息化手段"];
            if(shouduanarr==nil || shouduanarr.count==0 || bWanzixi)
                return 0;
        }
        else if(section==8)
        {
            NSArray *pingtaiarr=[userInfoDic objectForKey:@"教学日志_教学平台"];
            if(pingtaiarr==nil || pingtaiarr.count==0 || bWanzixi)
                return 0;
        }
    }
    else
    {
        if(section==0 || section==1 || section==6 || section==7 || section==8)
            return 0;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==4)
    {
        if(kUserType==1)
            return @"授课内容";
        else
            return @"我的建议";
    }
    else if(section==5)
    {
        if(kUserType==1)
            return @"作业布置";
        else
            return @"课堂笔记";
    }
   
    else
        return [super tableView:tableView titleForHeaderInSection:section];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(kUserType==1)
        self.parentViewController.navigationItem.title=self.banjiName;
    else
        self.parentViewController.navigationItem.title=self.className;
    
    self.parentViewController.navigationItem.rightBarButtonItem =rightBtn;
    
}

- (IBAction)pingJiaClick:(id)sender {
    if(kUserType!=1)
        return;
    UIView *parent=[(UIButton *)sender superview];
    NSArray *controls=[parent subviews];
    
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    NSUInteger section = [indexPath section];

    for(int i=0;i<controls.count;i++)
    {
        UIControl *ctl=[controls objectAtIndex:i];
        UIButton *btn=nil;
        if([ctl isKindOfClass:[UIButton class]])
            btn=(UIButton *)ctl;
        else
            continue;
        if(btn==sender)
        {
            [btn setImage:[_imageSel objectAtIndex:btn.tag-11]  forState:UIControlStateNormal];
            if(section==0)
                iJiLvIndex=(int)btn.tag-11;
            else if(section==1)
                iWeiShengIndex=(int)btn.tag-11;
        }
        else
        {
            if(btn.tag>10)
                [btn setImage:[_imageDes objectAtIndex:btn.tag-11]  forState:UIControlStateNormal];
        }
    }
}
- (IBAction)starPingJiaClick:(id)sender
{
    if(kUserType!=2)
        return;
    UIView *parent=[(UIButton *)sender superview];
    NSArray *controls=[parent subviews];
        
    while(![parent isKindOfClass:[UITableViewCell class]])
        parent=[parent superview];
    UITableViewCell *cell=(UITableViewCell *)parent;
    
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    NSUInteger section = [indexPath section];
    for(int i=0;i<5;i++)
    {
        UIButton *item=(UIButton *)[parent viewWithTag:11+i];
        [item setImage:grayStar  forState:UIControlStateNormal];
    }
    for(int i=0;i<controls.count;i++)
    {
        UIControl *ctl=[controls objectAtIndex:i];
        UIButton *btn=nil;
        if([ctl isKindOfClass:[UIButton class]])
            btn=(UIButton *)ctl;
        else
            continue;
        if(btn==sender)
        {
            int m=(int)btn.tag-10;
            for(int j=0;j<m;j++)
            {
                UIButton *item=(UIButton *)[parent viewWithTag:11+j];
                [item setImage:goldStar  forState:UIControlStateNormal];
            }
            
            if(section==2)
                teacherGrade=m;
            else if(section==3)
                classGrade=m;
            break;
        }
        
    }
}
-(void) getPingJiaData
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.classNo forKey:@"老师上课记录编号"];
    [dic setObject:@"GetInfo" forKey:@"ACTION"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    [dic setObject:self.teacherUserName forKey:@"老师用户名"];
    [dic setObject:self.className forKey:@"课程名称"];
    
    NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"GetPingjiaByStudent.php"] URLEncodedString]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    request.userInfo=dic;
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    request.username=@"获取数据";
    [request startAsynchronous];
    [requestArray addObject:request];
    alertTip = [[OLGhostAlertView alloc] initWithTitle:@"正在获取数据" message:nil timeout:0 dismissible:NO];
    [alertTip showInView:self.view];
}
-(void) savePingJia
{
    rightBtn.enabled=false;
    if(kUserType==1)
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        [dic setObject:self.classNo forKey:@"编号"];
        
        [dic setObject:[_dengjiArray objectAtIndex:iJiLvIndex]  forKey:@"课堂纪律"];
        [dic setObject:[_dengjiArray objectAtIndex:iWeiShengIndex]  forKey:@"教室卫生"];
        [dic setObject:self.neiRongText.text  forKey:@"授课内容"];
        [dic setObject:self.zuoYeText.text  forKey:@"作业布置"];
        [dic setObject:self.summaryText.text  forKey:@"课堂情况简要"];
        NSString *shouduanStr=@"";
        for(UIView *subview in _stackShouduan.subviews)
        {
            if([subview isKindOfClass:QCheckBox.class])
            {
                QCheckBox *check=(QCheckBox *)subview;
                if(check.checked)
                {
                    NSString *title=check.titleLabel.text;
                    shouduanStr=[NSString stringWithFormat:@"%@,%@",shouduanStr,title];
                }
                
            }
            else if([subview isKindOfClass:UITextField.class])
            {
                UITextField *field=(UITextField *)subview;
                if(field.text.length>0)
                    shouduanStr=[NSString stringWithFormat:@"%@,%@",shouduanStr,field.text];
            }
        }
        NSString *pingtaiStr=@"";
        NSString *ziyuankuStr=@"";
        for(UIView *subview in _stackPingtai.subviews)
        {
            if([subview isKindOfClass:QCheckBox.class])
            {
                QCheckBox *check=(QCheckBox *)subview;
                if(check.checked)
                {
                    NSString *title=check.titleLabel.text;
                    pingtaiStr=[NSString stringWithFormat:@"%@,%@",pingtaiStr,title];
                }
                
            }
            else if([subview isKindOfClass:UITextField.class])
            {
                UITextField *field=(UITextField *)subview;
                if(field.text.length>0)
                    ziyuankuStr=field.text;
            }
        }
        [dic setObject:shouduanStr  forKey:@"备注1"];
        [dic setObject:pingtaiStr  forKey:@"备注2"];
        [dic setObject:ziyuankuStr  forKey:@"资源库课程库名称"];
        
        NSURL *url = [NSURL URLWithString:[[kServiceURL stringByAppendingString:@"appserver.php?action=changezongjieinfo"] URLEncodedString]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        request.userInfo=dic;
        NSMutableArray *dicArray=[[NSMutableArray alloc] init ];
        [dicArray addObject:dic];
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        request.username=@"保存数据";
        [request startAsynchronous];
        [rightBtn setTitle:@"执行中"];
        [requestArray addObject:request];
    }
    else if(kUserType==2)
    {
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:kUserIndentify forKey:@"用户较验码"];
        [dic setObject:self.classNo forKey:@"老师上课记录编号"];
        [dic setObject:@"SetStatus" forKey:@"ACTION"];
        NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
        [dic setObject:timeStamp forKey:@"DATETIME"];
        [dic setObject:self.teacherUserName forKey:@"老师用户名"];
        [dic setObject:self.className forKey:@"课程名称"];
        
        [dic setObject:[NSNumber numberWithInt:teacherGrade] forKey:@"老师评价"];
        [dic setObject:[NSNumber numberWithInt:classGrade] forKey:@"课程评价"];
        [dic setObject:self.neiRongText.text forKey:@"我的建议"];
        [dic setObject:self.zuoYeText.text forKey:@"课堂笔记"];
        
        NSURL *url = [NSURL URLWithString:[[kInitURL stringByAppendingString:@"GetPingjiaByStudent.php"] URLEncodedString]];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        NSError *error;
        request.userInfo=dic;
        NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        postStr=[GTMBase64 base64StringBystring:postStr];
        [request setPostValue:postStr forKey:@"DATA"];
        [request setDelegate:self];
        request.username=@"保存数据";
        [request startAsynchronous];
        [requestArray addObject:request];
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.username isEqualToString:@"获取数据"])
    {
        if(alertTip)
           [alertTip removeFromSuperview];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(kUserType!=1)
        {
            if([dict objectForKey:@"老师评价"])
            {
                NSNumber *grade=[dict objectForKey:@"老师评价"];
                teacherGrade=grade.intValue;
                for(int i=0;i<teacherGrade;i++)
                {
                    UIButton *btn=[self.teacherBtns objectAtIndex:i];
                    [btn setImage:goldStar forState:UIControlStateNormal];
                }
                grade=[dict objectForKey:@"课程评价"];
                if(grade)
                    classGrade=grade.intValue;
                for(int i=0;i<classGrade;i++)
                {
                    UIButton *btn=[self.classBtns objectAtIndex:i];
                    [btn setImage:goldStar forState:UIControlStateNormal];
                }
                
                if([dict objectForKey:@"我的建议"])
                    _neiRongText.text=[dict objectForKey:@"我的建议"];
                if([dict objectForKey:@"课堂笔记"])
                    _zuoYeText.text=[dict objectForKey:@"课堂笔记"];
                
            }
            photosArray1=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"课堂笔记图片"]];
            [self drawImageFromArray:photosArray1 parent:_zuoYeText.superview];
                   }
        else
        {
            
            [_classInfoDic setObject:[dict objectForKey:@"课堂纪律"]forKey:@"课堂纪律"];
            [_classInfoDic setObject:[dict objectForKey:@"教室卫生"]forKey:@"教室卫生"];
            [_classInfoDic setObject:[dict objectForKey:@"授课内容"]forKey:@"授课内容"];
            [_classInfoDic setObject:[dict objectForKey:@"作业布置"]forKey:@"作业布置"];
            [_classInfoDic setObject:[dict objectForKey:@"课堂情况简要"]forKey:@"课堂情况简要"];
            [_classInfoDic setObject:[dict objectForKey:@"信息化手段"]forKey:@"信息化手段"];
            [_classInfoDic setObject:[dict objectForKey:@"教学平台"]forKey:@"教学平台"];
            [_classInfoDic setObject:[dict objectForKey:@"资源库课程库名称"]forKey:@"资源库课程库名称"];
            [_scheduleArray setObject:_classInfoDic atIndexedSubscript:self.classIndex.intValue];
            [userInfoDic setObject:_scheduleArray forKey:@"教师上课记录"];
            [self fillData];
            photosArray=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"课堂笔记图片"]];
            photosArray1=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"课堂作业图片"]];
            photosArray2=[[NSMutableArray alloc] initWithArray:[dict objectForKey:@"课堂情况图片"]];
            [self drawImageFromArray:photosArray parent:_neiRongText.superview];
            [self drawImageFromArray:photosArray1 parent:_zuoYeText.superview];
            [self drawImageFromArray:photosArray2 parent:_summaryText.superview];
            
            NSString *beginStr=[_classInfoDic objectForKey:@"应该填写时间"];
            NSString *endStr=[_classInfoDic objectForKey:@"最迟填写时间"];
            if(beginStr.length<=10)
                beginStr=[beginStr stringByAppendingString:@" 00:00:00"];
            if(endStr.length<=10)
                endStr=[endStr stringByAppendingString:@" 23:59:59"];
            NSDate *beginDate=[CommonFunc dateFromString:beginStr];
            NSDate *endDate=[CommonFunc dateFromString:endStr];
            NSDate *now=[NSDate date];
            if([beginDate compare:now]==NSOrderedAscending && [endDate compare:now]==NSOrderedDescending)
            {
                
            }
            else
            {
                NSString *message=[NSString stringWithFormat:@"请在 %@ 至 %@ 之间填写",beginStr,endStr];
                alertTip = [[OLGhostAlertView alloc] initWithTitle:message message:nil];
                [alertTip showInView:self.view];
                _neiRongText.editable=false;
                _zuoYeText.editable=false;
                _summaryText.editable=false;
                self.parentViewController.navigationItem.rightBarButtonItem =nil;
            }
            NSString *teacherkaoqinstate=[dict objectForKey:@"教师考勤情况"];
            if(teacherkaoqinstate!=nil && ![teacherkaoqinstate isEqual:@"正常"])
            {
                alertTip = [[OLGhostAlertView alloc] initWithTitle:teacherkaoqinstate message:nil];
                [alertTip showInView:self.view];
                _neiRongText.editable=false;
                _zuoYeText.editable=false;
                _summaryText.editable=false;
                self.parentViewController.navigationItem.rightBarButtonItem =nil;
            }
        }
        

    }
    else if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
        NSData *data = [request responseData];
        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSString *result=[dict objectForKey:@"结果"];
        if(kUserType==1)
        {
            NSNumber *suc=[dict objectForKey:@"成功"];
            NSLog(@"%@",result);
            if(suc.intValue==1)
            {
                [_classInfoDic setObject:[_dengjiArray objectAtIndex:iJiLvIndex]  forKey:@"课堂纪律"];
                [_classInfoDic setObject:[_dengjiArray objectAtIndex:iWeiShengIndex]  forKey:@"教室卫生"];
                [_classInfoDic setObject:self.neiRongText.text  forKey:@"授课内容"];
                [_classInfoDic setObject:self.zuoYeText.text  forKey:@"作业布置"];
                [_classInfoDic setObject:self.summaryText.text  forKey:@"课堂情况简要"];
                [_scheduleArray setObject:_classInfoDic atIndexedSubscript:self.classIndex.intValue];
                [userInfoDic setObject:_scheduleArray forKey:@"教师上课记录"];
                result=@"已保存";
                
            }
            
        }
        else if(kUserType==2)
        {
            if([result isEqualToString:@"成功"])
                result=@"已保存";
            
        }
        OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
        [tipView show];
    }
    if([request.username isEqualToString:@"上传课堂笔记"])
    {
        if(rpv) [rpv removeFromSuperview];
        NSData *data = [request responseData];
        NSString *dataStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataStr=[GTMBase64 stringByBase64String:dataStr];
        data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
        NSMutableDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * status=[dict objectForKey:@"STATUS"];
        if([status.lowercaseString isEqualToString:@"ok"])
        {
            
            NSDictionary *dic=request.userInfo;
            NSData *data=[dic objectForKey:@"data"];
            NSString *filename=[dict objectForKey:@"文件名"];
            filename=[savePath stringByAppendingString:filename];
            [data writeToFile:filename atomically:YES];
            if(curIndex==1)
            {
                [photosArray addObject:dict];
                [self drawImageFromArray:photosArray parent:_neiRongText.superview];
            }
            else if(curIndex==2)
            {
                [photosArray1 addObject:dict];
                [self drawImageFromArray:photosArray1 parent:_zuoYeText.superview];
            }
            else
            {
                [photosArray2 addObject:dict];
                [self drawImageFromArray:photosArray2 parent:_summaryText.superview];
            }
        }
    }
    if([request.username isEqualToString:@"下载图片"])
    {
        NSData *datas = [request responseData];
        UIImage *img=[[UIImage alloc]initWithData:datas];
        NSDictionary *item=request.userInfo;
        NSString *filename=[item objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [datas writeToFile:filename atomically:YES];
        UIButton *btn=(UIButton *)[item objectForKey:@"curBtn"];
        for(UIActivityIndicatorView *v in btn.subviews)
        {
            if([v isKindOfClass:[UIActivityIndicatorView class]])
            {
                [v stopAnimating];
                [v removeFromSuperview];
            }
        }
        [btn setImage:img forState:UIControlStateNormal];
    }
    if([request.username isEqualToString:@"删除图片"])
    {
        NSDictionary *dict=request.userInfo;
        NSString *filename=[dict objectForKey:@"文件名"];
        filename=[savePath stringByAppendingString:filename];
        [CommonFunc deleteFile:filename];
        if(curIndex==1)
        {
            [photosArray removeObject:dict];
            [self drawImageFromArray:photosArray parent:_neiRongText.superview];
        }
        else if(curIndex==2)
        {
            [photosArray1 removeObject:dict];
            [self drawImageFromArray:photosArray1 parent:_zuoYeText.superview];
        }
        else
        {
            [photosArray2 removeObject:dict];
            [self drawImageFromArray:photosArray2 parent:_summaryText.superview];
        }
        
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(alertTip)
       [alertTip removeFromSuperview];
    if([request.username isEqualToString:@"保存数据"])
    {
        rightBtn.enabled=true;
        [rightBtn setTitle:@"保存"];
    }
    if([request.username isEqualToString:@"上传课堂笔记"])
    {
        if(rpv) [rpv removeFromSuperview];
    }
    NSError *error = [request error];
    NSLog(@"请求失败:%@",[error localizedDescription]);
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:@"操作失败" message:[error localizedDescription]];
    [tipView show];
    request=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
