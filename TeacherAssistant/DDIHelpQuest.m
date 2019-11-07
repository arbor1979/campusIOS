//
//  DDIHelpQuest.m
//  老师助手
//
//  Created by yons on 13-12-20.
//  Copyright (c) 2013年 dandian. All rights reserved.
//

#import "DDIHelpQuest.h"
extern NSString *kInitURL;
extern NSString *kUserIndentify;
extern Boolean kIOS7;

@interface DDIHelpQuest ()

@end

@implementation DDIHelpQuest


- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth =1.0;
    self.textView.layer.cornerRadius =5.0;
    [self.textView setInputAccessoryView:topView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
  
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view1.frame.size.width;
    
    float height = self.view1.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,-80,width,height);
    
    self.view1.frame=rect;
    
    [UIView commitAnimations];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view1.frame.size.width;
    
    float height = self.view1.frame.size.height;
    
    CGRect rect=CGRectMake(0.0f,0.0f,width,height);
    
    self.view1.frame=rect;
    
    [UIView commitAnimations];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
//隐藏键盘
- (void)resignKeyboard {
    [self.textView resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitClick:(id)sender {
    
    NSURL *url = [NSURL URLWithString:[kInitURL stringByAppendingString:@"SendSMS_GUESTBOOK_ALL.php"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSError *error;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [dic setObject:kUserIndentify forKey:@"用户较验码"];
    [dic setObject:self.textView.text forKey:@"CONTENT"];
    [dic setObject:@"DataDeal" forKey:@"action"];
    NSNumber *timeStamp=[[NSNumber alloc] initWithLong:[[NSDate new] timeIntervalSince1970]];
    [dic setObject:timeStamp forKey:@"DATETIME"];
    
    NSData *postData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    postStr=[GTMBase64 base64StringBystring:postStr];
    [request setPostValue:postStr forKey:@"DATA"];
    [request setDelegate:self];
    [request startAsynchronous];
    [self.sendBtn setTitle:@"提交中" forState:UIControlStateNormal];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataStr=[GTMBase64 stringByBase64String:dataStr];
    data = [dataStr dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSString *result=[dict objectForKey:@"MSG_STATUS"];
    
    if([result isEqualToString:@"成功"])
    {
        [self.sendBtn setTitle:@"提交成功，谢谢！" forState:UIControlStateNormal];
        self.textView.text=@"";
        result=@"提交成功";
    }
    else
    {
        result=@"提交失败";
        [self.sendBtn setTitle:result forState:UIControlStateNormal];
        
    }
    
    OLGhostAlertView *tipView = [[OLGhostAlertView alloc] initWithTitle:result];
    [tipView show];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(recoverSaveBtn) userInfo:nil repeats:NO];
}
-(void)recoverSaveBtn
{
    [self.sendBtn setTitle:@"提交" forState:UIControlStateNormal];;
}
@end
