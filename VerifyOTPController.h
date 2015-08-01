//
//  VerifyOTPController.h
//  cognalysDemoApp
//
//  Created by Neeraj Apps on 08/07/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cognalys.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface VerifyOTPController : UIViewController<WebserviceDelegate>

@property (strong, nonatomic) IBOutlet UILabel*     OTPStatusLabel;
@property (strong, nonatomic) IBOutlet UITextField* verifyNumber_textField;
@property (strong, nonatomic) IBOutlet UIButton*    verifyButton;
@property(nonatomic,retain)   cognalys*             lib;
@property(nonatomic,retain)   NSString*             confirmationStatus;
@property(nonatomic,retain)   NSString*             confirmationMessage;
@property(nonatomic,retain)   NSString*             otp_start;
@property(nonatomic,retain)   UIView*               messageDisplay_view;

@property(nonatomic,retain)   UIActivityIndicatorView* activityView;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UILabel *userDirectionMessageLabel;

- (IBAction)verifyNumberButtonPressed:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
@end
