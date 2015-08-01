//
//  ViewController.h
//  cognalysDemoApp
//
//  Created by Neeraj Apps on 08/07/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cognalys.h"
#import "TPKeyboardAvoidingScrollView.h"

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface ViewController : UIViewController<WebserviceDelegate,UIActionSheetDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>
{
    NSMutableArray *dummyArray;
}

//Library initialization 
@property(nonatomic,strong)cognalys *lib;

@property (strong, nonatomic) IBOutlet      UIButton*                       countrySelectionButton;
@property (strong, nonatomic) IBOutlet      UILabel*                        statusLabel;
@property (strong, nonatomic) IBOutlet      UIButton*                       APIButton;
@property (strong, nonatomic) IBOutlet      UIButton*                       verifyButton;
@property (strong, nonatomic) IBOutlet      UITextField*                    mobileNumber_textField;
@property (strong, nonatomic) IBOutlet      UITextField*                    countryCodeTextField;
@property (strong, nonatomic) IBOutlet      TPKeyboardAvoidingScrollView*   scrollView;

@property (strong, nonatomic) IBOutlet UIButton *APICallButton;



- (IBAction)initAPIButtonPressed:(id)sender;
- (IBAction)countrySelectionButtonPressed:(id)sender;


@property(nonatomic,retain)   UIActivityIndicatorView* activityView;
@property (nonatomic,retain)  UITableView*          countryListingTableView;
@property (nonatomic,retain)  UISearchDisplayController*   searchControllerMain;
@property (strong,nonatomic)  UIPageViewController* pageController;
@property (nonatomic,retain)  UIView*               messageDisplay_view;
@property (nonatomic,retain)  NSString*             status;
@property (nonatomic,retain)  NSString*             keymatch;
@property (nonatomic,retain)  NSString*             mobile;
@property (nonatomic,retain)  NSString*             otp_start;
@property (nonatomic,retain)  NSString*             confirmationStatus;
@property (nonatomic,retain)  NSString*             confirmationMessage;
@property (nonatomic,retain)  NSDictionary*         countryList;
@property (nonatomic,retain)  NSMutableArray*       countryListArray;
@property (nonatomic,retain)  NSMutableArray*       searchResults;
@property (nonatomic,retain)  NSDictionary*         countryByCodeDict;
@end

