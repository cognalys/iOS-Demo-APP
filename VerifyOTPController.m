//
//  VerifyOTPController.m
//  cognalysDemoApp
//
//  Created by Neeraj Apps on 08/07/15.
//  Copyright (c) 2015. Ltd. All rights reserved.
//

#import "VerifyOTPController.h"
#import "Reachability.h"
#import "VerifiedLocationMap.h"

@interface VerifyOTPController ()

@end

@implementation VerifyOTPController
@synthesize lib;
@synthesize messageDisplay_view;
@synthesize activityView;
@synthesize confirmationMessage,confirmationStatus;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initialSetup];
    
    
  
    
    //##################################################################
    //#################### Input values for testing purpose
    NSString* access_token=@"<YOUR_ACCESS_TOKEN>";//
    NSString* app_ID=@"YOUR_APP_ID";
    
    //##################################################################
    //##################################################################
    //##################################################################
    
    
    //##################################################################
    //##################################################################
    //########### Cognalys library initialization ^^^^^^^^^^^^^^^^^^^^^^
    
    self.lib=[[cognalys alloc]init];
    self.lib.delegate=self;
    self.lib.access_token=access_token;
    self.lib.app_ID=app_ID;
    self.lib.getLocation=TRUE;
    self.lib.canRetryVerification=YES;
    
    //##################################################################
    //##################################################################
    
    
   
    
    // Do any additional setup after loading the view.
}

#pragma mark - COGNALYS API FUNCTIONS

//######################################################################################
//######################################################################################
//#####################  API CALL FOR OTP VERIFICATION  #############################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- (IBAction)verifyNumberButtonPressed:(id)sender {
    
    
    
    [self.verifyNumber_textField resignFirstResponder];
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Internet connection not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    
    
    NSString *numberToVerify=[NSString stringWithFormat:@"%@",self.verifyNumber_textField.text];
    if ([numberToVerify length]==0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter a valid OTP" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
        
    }
    
    NSLog(@"%@",numberToVerify);
    
    
    
    self.backButton.hidden=YES;
    
    self.activityView.hidden=NO;
    [self.activityView startAnimating];
    
    [self.lib verifyOTP_withNumberCopyedFromTheLog:numberToVerify];
}


-(void)cog_OTPVerificationSuccessNotif:(NSDictionary *)cog_CallbackData
{
    
    
    
    NSLog(@"%@",cog_CallbackData);
    
    self.confirmationMessage=[cog_CallbackData valueForKey:@"message"];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.activityView.hidden=YES;
        [self.activityView stopAnimating];
        
        self.verifyNumber_textField.text=@"";
        
        self.OTPStatusLabel.text=@"OTP Verified Successfully";
        
        [self showSuccessMessageView];
        
    });
    
}

-(void)cog_OTPVerificationErrorNotif:(NSDictionary *)cog_CallbackData
{
    
    
    NSString *errorMessage=[[cog_CallbackData valueForKey:@"errors"]valueForKey:@"ERROR_CODE"];
    
    NSLog(@"%@",errorMessage);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.verifyNumber_textField.text=@"";
        
        self.activityView.hidden=YES;
        [self.activityView stopAnimating];
        
        self.OTPStatusLabel.text=[NSString stringWithFormat:@"OTP Verification Error %@",errorMessage ];
        
        [self showFailureMessageView];
    });
    
}

//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//#######################################################################################


#pragma mark - NON API FUNCTIONS


//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-(void)initialSetup
{
    self.backButton.hidden=YES;
    
    self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityView.center = self.view.center;
    [self.activityView setFrame:CGRectMake(self.activityView.frame.origin.x, self.activityView.frame.origin.y+30, self.activityView.frame.size.width, self.activityView.frame.size.height)];
    self.activityView.hidden = YES;
    [self.view addSubview:self.activityView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteringFromBackground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.OTPStatusLabel.text=@"";

    
    self.userDirectionMessageLabel.text=[NSString stringWithFormat:@"Copy and paste the missed call number received from device call log, starting with %@ to get verified",self.otp_start];
    
    
    [self.verifyNumber_textField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.verifyNumber_textField.layer.borderWidth=1.0;
    self.verifyNumber_textField.layer.sublayerTransform = CATransform3DMakeTranslation(+10, 0, 0);
}
-(void)applicationEnteringFromBackground
{
    
    
    NSLog(@"%@",[[UIPasteboard generalPasteboard] string]);
    
    NSString *origString =[[UIPasteboard generalPasteboard] string];
    
    NSString *newString  = [[origString componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    
    newString            = [NSString stringWithFormat:@"+%@",newString];
    
    NSLog(@"%@",newString);
    
    NSLog(@"%@",self.otp_start);
    
    if ([newString rangeOfString:self.otp_start].location!=NSNotFound) {
        
      
        self.verifyNumber_textField.text=newString;
        
    }
    
    
}



- (IBAction)backButtonPressed:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getLog:(NSString *)log
{
    NSLog(@"%@",log);
}
-(void)dismissMessageBox2
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [self.messageDisplay_view.layer addAnimation:anim forKey:nil];
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.messageDisplay_view.alpha=0;
        
    } completion:^(BOOL finished) {
        
        if (self.messageDisplay_view) {
            [self.messageDisplay_view removeFromSuperview];
        }
        
       self.backButton.hidden=NO;
        
        
    }];
    
}
-(void)dismissMessageBox
{
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [self.messageDisplay_view.layer addAnimation:anim forKey:nil];
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.messageDisplay_view.alpha=0;
        
    } completion:^(BOOL finished) {
        
        if (self.messageDisplay_view) {
            [self.messageDisplay_view removeFromSuperview];
        }
        
       //[self.navigationController popViewControllerAnimated:YES];
        
        
        VerifiedLocationMap *controller    = (VerifiedLocationMap *)[self.storyboard instantiateViewControllerWithIdentifier:@"VerifiedLocationMap"];
        [self.navigationController pushViewController:controller animated:YES];
        
        

        
        
    }];
    
}
-(void)showSuccessMessageView
{
    self.messageDisplay_view=[[UIView alloc]initWithFrame:self.view.bounds];
    self.messageDisplay_view.backgroundColor=[UIColor whiteColor];
    self.messageDisplay_view.alpha=0;
    
    
   
    
    UIImageView *imageLogo=[[UIImageView alloc]initWithFrame:CGRectMake(20, 30, 75, 75)];
    [imageLogo setImage:[UIImage imageNamed:@"logo"]];
    
    
    [self.messageDisplay_view addSubview:imageLogo];
    
    UILabel *classLabel =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, 40,200, 50)];
    classLabel.text=@"Cognalys.com";
    classLabel.font=[UIFont fontWithName:@"Helvetica" size:17];
    classLabel.font=[UIFont boldSystemFontOfSize:17];
    classLabel.textColor=[UIColor blackColor];
    classLabel.textAlignment=NSTextAlignmentLeft;
    [self.messageDisplay_view addSubview:classLabel];
    
    
    
    
    UIImageView *TickLogo=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)-10, 210, 63, 58)];
    [TickLogo setImage:[UIImage imageNamed:@"success"]];
    
    [self.messageDisplay_view addSubview:TickLogo];


    
    
    UILabel *messageLabel =[[UILabel alloc]initWithFrame:CGRectMake(50,(self.view.frame.size.width/2)+90,200, 50)];
    messageLabel.text=@"SUCCESS !";
    messageLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
    //messageLabel.font=[UIFont boldSystemFontOfSize:17];
    // messageLabel.center = self.messageDisplay_view.center;
    messageLabel.textColor=[UIColor blackColor];
    messageLabel.textAlignment=NSTextAlignmentLeft;
    [self.messageDisplay_view addSubview:messageLabel];
    
    
    UILabel *messageSubTitile =[[UILabel alloc]initWithFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y+20,300, 50)];
    messageSubTitile.text=@"YOUR NUMBER IS VERIFIED ";
    messageSubTitile.font=[UIFont fontWithName:@"Helvetica" size:18];
    //messageLabel.font=[UIFont boldSystemFontOfSize:17];
    messageSubTitile.textColor=[UIColor blackColor];
    messageSubTitile.textAlignment=NSTextAlignmentLeft;
    messageSubTitile.backgroundColor=[UIColor clearColor];
    [self.messageDisplay_view addSubview:messageSubTitile];
    
    
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor=[UIColor colorWithRed:0 green:0.8 blue:1 alpha:1];
    [backButton setFrame:CGRectMake(messageSubTitile.frame.origin.x, messageSubTitile.frame.origin.y+messageSubTitile.frame.size.height, 130, 40)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitle:@"Done" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissMessageBox) forControlEvents:UIControlEventTouchUpInside];
    [self.messageDisplay_view addSubview:backButton];
    
    
    
    UILabel *bottomLabel        = [[UILabel alloc]initWithFrame:CGRectMake(3, self.messageDisplay_view.frame.size.height-100,self.messageDisplay_view.frame.size.width, 100)];
    bottomLabel.text            = @"Double tap the message box to go back to the previous page";
    bottomLabel.font            = [UIFont fontWithName:@"Helvetica" size:11];
    bottomLabel.textColor       = [UIColor blackColor];
    bottomLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    bottomLabel.numberOfLines   = 0;
    bottomLabel.textAlignment   = NSTextAlignmentCenter;
    bottomLabel.backgroundColor = [UIColor clearColor];
   // [self.messageDisplay_view addSubview:bottomLabel];
    
    
    [self.view addSubview:self.messageDisplay_view];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.messageDisplay_view.alpha=1;
        
    } completion:^(BOOL finished) {
        
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.125;
        anim.repeatCount = 1;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        [self.messageDisplay_view.layer addAnimation:anim forKey:nil];
        
        
    }];
    

}
-(void)showFailureMessageView
{
    self.messageDisplay_view=[[UIView alloc]initWithFrame:self.view.bounds];
    self.messageDisplay_view.backgroundColor=[UIColor whiteColor];
    self.messageDisplay_view.alpha=0;
    
   
    
    UIImageView *imageLogo=[[UIImageView alloc]initWithFrame:CGRectMake(20, 30, 75, 75)];
    [imageLogo setImage:[UIImage imageNamed:@"logo"]];
    
    
    [self.messageDisplay_view addSubview:imageLogo];
    
    UILabel *classLabel =[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-150, 30,200, 50)];
    classLabel.text=@"Cognalys.com";
    classLabel.font=[UIFont fontWithName:@"Helvetica" size:17];
    classLabel.font=[UIFont boldSystemFontOfSize:17];
    classLabel.textColor=[UIColor blackColor];
    classLabel.textAlignment=NSTextAlignmentLeft;
    [self.messageDisplay_view addSubview:classLabel];
    
    
    
    
    UIImageView *TickLogo=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)-20, 230, 43, 64)];
    [TickLogo setImage:[UIImage imageNamed:@"failure"]];
    
    [self.messageDisplay_view addSubview:TickLogo];

    
    
    UILabel *messageLabel =[[UILabel alloc]initWithFrame:CGRectMake(50,(self.view.frame.size.width/2)+90,200, 50)];
    messageLabel.text=@"SORRY !";
    messageLabel.font=[UIFont fontWithName:@"Helvetica" size:18];
    //messageLabel.font=[UIFont boldSystemFontOfSize:17];
    // messageLabel.center = self.messageDisplay_view.center;
    messageLabel.textColor=[UIColor blackColor];
    messageLabel.textAlignment=NSTextAlignmentLeft;
    [self.messageDisplay_view addSubview:messageLabel];
    
    
   
    
    
    UILabel *messageSubTitile =[[UILabel alloc]initWithFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y-40,250, 200)];
    messageSubTitile.text=@"YOU ENTERED AN INCORRECT NUMBER. PLEASE TRY AGAIN. ";
    messageSubTitile.numberOfLines=0;
    messageSubTitile.lineBreakMode=NSLineBreakByWordWrapping;
    messageSubTitile.font=[UIFont fontWithName:@"Helvetica" size:15];
    //messageLabel.font=[UIFont boldSystemFontOfSize:17];
    messageSubTitile.textColor=[UIColor blackColor];
    messageSubTitile.textAlignment=NSTextAlignmentLeft;
    messageSubTitile.backgroundColor=[UIColor clearColor];
    [self.messageDisplay_view addSubview:messageSubTitile];

    
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor=[UIColor colorWithRed:0 green:0.8 blue:1 alpha:1];
    [backButton setFrame:CGRectMake(messageSubTitile.frame.origin.x, messageSubTitile.frame.origin.y+130, 130, 40)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissMessageBox2) forControlEvents:UIControlEventTouchUpInside];
    [self.messageDisplay_view addSubview:backButton];

    
    
    UILabel *bottomLabel        = [[UILabel alloc]initWithFrame:CGRectMake(3, self.messageDisplay_view.frame.size.height-100,self.messageDisplay_view.frame.size.width, 100)];
    bottomLabel.text            = @"Double tap the message box to go back to the previous page";
    bottomLabel.font            = [UIFont fontWithName:@"Helvetica" size:11];
    bottomLabel.textColor       = [UIColor blackColor];
    bottomLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    bottomLabel.numberOfLines   = 0;
    bottomLabel.textAlignment   = NSTextAlignmentCenter;
    bottomLabel.backgroundColor = [UIColor clearColor];
   // [self.messageDisplay_view addSubview:bottomLabel];
    
    
    [self.view addSubview:self.messageDisplay_view];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.messageDisplay_view.alpha=1;
        
    } completion:^(BOOL finished) {
        
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.125;
        anim.repeatCount = 1;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        [self.messageDisplay_view.layer addAnimation:anim forKey:nil];
        
        
    }];
    
    
}



//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - UITextFieldDelegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.verifyNumber_textField resignFirstResponder];
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView adjustOffsetToIdealIfNeeded];
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        // BasicAlert(@"", @"This field accepts only numeric entries.");
        return NO;
    }
    
    return  YES;
}// return NO to not change text
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)mobileVerificationRetryWithMessage:(NSString *)cog_retryMessage
{
    
}
-(void)mobileVerificationRetryFailedWithMessage:(NSString *)cog_retryMessage
{
    
}

@end
