//
//  ViewController.m
//  cognalysDemoApp
//
//  Created by Neeraj Apps on 08/07/15.
//  Copyright (c) 2015. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "cognalys.h"
#import "VerifyOTPController.h"

#import "Reachability.h"
#import "VerifiedLocationMap.h"



@interface ViewController ()

@end

@implementation ViewController
@synthesize pageController;
@synthesize lib;
@synthesize status;
@synthesize keymatch;
@synthesize mobile;
@synthesize otp_start;
@synthesize confirmationStatus;
@synthesize confirmationMessage;
@synthesize countryList;
@synthesize countryListingTableView;
@synthesize searchControllerMain;
@synthesize countryListArray;
@synthesize searchResults;
@synthesize countryByCodeDict;
@synthesize messageDisplay_view;
@synthesize activityView;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



-(void)viewWillAppear:(BOOL)animated
{
     self.statusLabel.text=@"";
     self.mobileNumber_textField.text=@"";
    
     self.APICallButton.userInteractionEnabled=YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    [self setUpInitial];

 
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
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}



#pragma mark - COGNALYS API FUNCTIONS

//######################################################################################
//######################################################################################
//#####################  API CALL FOR MOBILE VERIFICATION  #############################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- (IBAction)initAPIButtonPressed:(id)sender {
    
    
    /// Check for network availability
    
    Reachability *reach     = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text=@"";
        });
        
        UIAlertView *alert  =[[UIAlertView alloc]initWithTitle:@"Message" message:@"Internet connection not available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    
    
    // Check all the required fields are filled and validate each
    
    if ([self.countryCodeTextField.text length]==0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please select a country code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
        
    }
    
    
    NSString *numberToVerify   =[NSString stringWithFormat:@"%@",self.mobileNumber_textField.text];
    if ([numberToVerify length]==0) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please enter a valid mobile number to proceed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
        
    }
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text=@"Please wait .. ..";
    });
    
    
    
     self.activityView.hidden=NO;
    [self.activityView startAnimating];
     NSString *numberToInitCall =[NSString stringWithFormat:@"%@%@",self.countryCodeTextField.text,self.mobileNumber_textField.text];
    [self.countryCodeTextField resignFirstResponder];
    [self.mobileNumber_textField resignFirstResponder];

    self.APICallButton.userInteractionEnabled=NO;
    
    
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //^^^^^ Initiate First API Call For Mobile Verification ^^^^^^////
    
      [self.lib initiateAPIWithMobileNumber:numberToInitCall];
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //##################################################################
   //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    [self.mobileNumber_textField resignFirstResponder];
 
 
   
}



//##################################################################
// Asynchronous call back from Cognalys framework
//@fun : cog_CallConnectedSuccessNotif - Called upon successfull verification
-(void)cog_CallConnectedSuccessNotif:(NSDictionary *)cog_CallbackData
{
    
    NSLog(@"%@",cog_CallbackData); // cog_CallbackData is a dictionary value which is returned from the
                                   // library if the verification done successfully .
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text=@"API success. Please wait.";
        
        [self.activityView stopAnimating];
        self.activityView.hidden=YES;
        
    });
    

    
    self.status     =[cog_CallbackData valueForKey:@"status"];
    self.keymatch   =[cog_CallbackData valueForKey:@"keymatch"];
    self.mobile     =[cog_CallbackData valueForKey:@"mobile"];
    self.otp_start  =[cog_CallbackData valueForKey:@"otp_start"];
    
    NSLog(@"============================== OTP START > %@",self.otp_start);
    
    
}


//@fun : cog_CallConnectedErrorNotif - Called upon verification failure
-(void)cog_CallConnectedErrorNotif:(NSDictionary *)cog_CallbackData
{
    
    
    
    NSLog(@"%@",cog_CallbackData); // cog_CallbackData contains the ERROR list
    
    
    self.keymatch           =@"";
    self.mobile             =@"";
    self.otp_start          =@"";
    
    NSDictionary* errorsDict  =[cog_CallbackData valueForKey:@"errors"];
    
     NSLog(@"%@",[errorsDict allKeys]);
    
     dispatch_async(dispatch_get_main_queue(), ^{
    
    if ([[errorsDict allKeys] count]>0) {
        
        self.APICallButton.userInteractionEnabled=YES;
        [self.activityView stopAnimating];
        [self.activityView setHidesWhenStopped:YES];
        self.activityView.hidden=YES;
            
            
        self.statusLabel.text=[NSString stringWithFormat:@"Error: %@",[errorsDict valueForKey:[NSString stringWithFormat:@"%@",[errorsDict.allKeys objectAtIndex:0]]]];
       
    }
    else
    {
        self.statusLabel.text=@"Failed. Please retry.";
        
    }
     });
    
    
    
}

//@fun : mobileVerificationRetryWithMessage - This method get called when library started retrying verification
-(void)mobileVerificationRetryWithMessage:(NSString *)cog_retryMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"%@",cog_retryMessage);
        
        self.statusLabel.text=@"Retrying. Please wait.";
        
    });
}

//@fun : mobileVerificationRetryFailedWithMessage - This method get called when retry verification process get failed.
-(void)mobileVerificationRetryFailedWithMessage:(NSString *)cog_retryMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        self.APICallButton.userInteractionEnabled=YES;
        self.activityView.hidden=YES;
        [self.activityView stopAnimating];
        
        self.statusLabel.text=@"Retry failed.";
    });
}

//@fun : cog_APISuccessAndReceivedMiscall - This function get called when we receive a misscall after successfull verification process. Developer can display the OTP verification page after this.
-(void)cog_APISuccessAndReceivedMiscall
{
    self.activityView.hidden=YES;
    [self.activityView stopAnimating];
    
    self.APICallButton.userInteractionEnabled=YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text=@"Please enter the OTP";
        
        VerifyOTPController *controller    = (VerifyOTPController *)[self.storyboard instantiateViewControllerWithIdentifier:@"verifyOTPView"];
        controller.lib                     = self.lib ;
        controller.otp_start               = self.self.otp_start;
        [self.navigationController pushViewController:controller animated:YES];
        
        
    });
}

-(void)getLog:(NSString *)log
{
    NSLog(@"%@",log);
}


//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//#######################################################################################



#pragma mark - NON API FUNCTIONS


//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - Initial Methods
-(void)setUpInitial
{
    
    
    //[self  setupHelpPageController];
    [self  setupCountryCodes];
    
    self.activityView           = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityView.center    = self.view.center;
    [self.activityView setFrame:CGRectMake(self.activityView.frame.origin.x, self.activityView.frame.origin.y+30, self.activityView.frame.size.width, self.activityView.frame.size.height)];
    self.activityView.hidden    = YES;
    [self.view addSubview:self.activityView];
    
    
    self.countryByCodeDict      = [self countryCodesByName];
    
    NSLog(@"%@",self.countryByCodeDict);
    
    
    self.countryListArray       = [[NSMutableArray alloc]init];
    self.countryListArray       = [NSMutableArray arrayWithArray:self.countryList.allKeys];
    self.searchResults          = [[NSMutableArray alloc]init];
    
    NSSortDescriptor* sortDescriptor;
    sortDescriptor              = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *sortDescriptors    = [NSArray arrayWithObject:sortDescriptor];
    [self.countryListArray sortUsingDescriptors:sortDescriptors];
    
    NSLog(@"%@",self.countryListArray);
    

    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode       = [locale objectForKey: NSLocaleCountryCode];
    NSString *countryName       = [locale displayNameForKey: NSLocaleCountryCode
                                                value: countryCode];
    NSLog(@"code : %@",countryCode);
    NSLog(@"name : %@",countryName);
    
    
    NSLog(@"%@",[self.countryList valueForKey:countryName]);
    
    NSString *mobileCountryCode=[NSString stringWithFormat:@"%@",[self.countryList valueForKey:countryName]];
    
    if (mobileCountryCode.length==0 || mobileCountryCode==NULL) {
        
        self.countryCodeTextField.text=@"";
    }
    else
    {
       self.countryCodeTextField.text=mobileCountryCode;
    }
    
   
    
    self.navigationController.navigationBar.hidden=YES;
    
 
    UILabel *bottomLabel        = [[UILabel alloc]initWithFrame:CGRectMake(3, self.view.frame.size.height-100,self.view.frame.size.width, 100)];
    bottomLabel.text            = @"During verification you will receive a missed call. Please wait.";
    bottomLabel.font            = [UIFont fontWithName:@"Helvetica" size:18];
    bottomLabel.textColor       = [UIColor blackColor];
    bottomLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    bottomLabel.numberOfLines   = 0;
    bottomLabel.textAlignment   = NSTextAlignmentCenter;
    bottomLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomLabel];
    
    
    
    [self.countryCodeTextField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.countryCodeTextField.layer.borderWidth=1.0;
    [self.mobileNumber_textField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.mobileNumber_textField.layer.borderWidth=1.0;
    
    self.mobileNumber_textField.layer.sublayerTransform = CATransform3DMakeTranslation(+10, 0, 0);
    self.countryCodeTextField.layer.sublayerTransform = CATransform3DMakeTranslation(+10, 0, 0);
    
  
}

-(void)dismissMessageBox
{
    
    CABasicAnimation *anim      = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction         = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration               = 0.125;
    anim.repeatCount            = 1;
    anim.autoreverses           = YES;
    anim.removedOnCompletion    = YES;
    anim.toValue                = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [self.messageDisplay_view.layer addAnimation:anim forKey:nil];
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.messageDisplay_view.alpha=0;
        
    } completion:^(BOOL finished) {
        
        if (self.messageDisplay_view) {
            [self.messageDisplay_view removeFromSuperview];
        }
        
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - UITextFieldDelegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  return  YES;
}// return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     self.statusLabel.text=@"";
    
    [self.scrollView adjustOffsetToIdealIfNeeded];
    
}// became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   return  YES;
}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==self.countryCodeTextField) {
        
        
    }
    else
    {
    
    if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        // BasicAlert(@"", @"This field accepts only numeric entries.");
        return NO;
    }
        
    }
    
   return  YES;
}// return NO to not change text

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
   return  YES;
}// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.mobileNumber_textField resignFirstResponder];
    
    return  YES;
    
}

- (IBAction)countrySelectionButtonPressed:(id)sender {
    
    self.navigationController.navigationBar.hidden=NO;
    
   
    
    UIView *baseView                    =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    baseView.backgroundColor            =[UIColor blackColor];
    [baseView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    baseView.tag=200;


    self.countryListingTableView        =[[UITableView alloc]init];
    //[self.countryListingTableView setFrame:CGRectMake(20, 70, 280, 300)];
    [self.countryListingTableView setFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    self.countryListingTableView.delegate           = self;
    self.countryListingTableView.dataSource         = self;
    self.countryListingTableView.layer.borderColor  = [UIColor blackColor].CGColor;
    self.countryListingTableView.layer.borderWidth  = 0.3f;
    [self.countryListingTableView.layer setCornerRadius:0];
    self.countryListingTableView.hidden             = NO;
    
    self.countryListingTableView.delegate           = self;
    self.countryListingTableView.dataSource         = self;
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        // code here
    }
   
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    
    self.searchControllerMain
    = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                        contentsController:self];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.delegate = self;
    searchBar.frame = CGRectMake(0, 0, 0, 38);
    self.definesPresentationContext = YES;
    self.countryListingTableView.tableHeaderView = searchBar;
    
    
    [UIView animateWithDuration:0.4 animations:^{
        
        baseView.alpha=1;
        self.countryListingTableView.alpha=1;
        
        
        
        
    } completion:^(BOOL finished) {
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.125;
        anim.repeatCount = 1;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        [self.countryListingTableView.layer addAnimation:anim forKey:nil];
        

        
    }];

    
    [baseView addSubview:self.countryListingTableView];
    
    [self.view addSubview:baseView];

    
}




//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //return [self.firstName count];
    
    // return [self.contactsToDisplay count];
    
    return self.searchResults.count;
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] init];
    }
    
  
    
    UILabel *createdTimeTitle=[[UILabel alloc]init];
    createdTimeTitle.textColor=[UIColor blackColor];
    [createdTimeTitle setFrame:CGRectMake(45, 5, 110, 30)];
    createdTimeTitle.font=[UIFont fontWithName:@"Helvetica" size:14];
    //[createdTimeTitle setText:[self.deviceContactNames objectAtIndex:indexPath.row]];
    [createdTimeTitle setText:[self.searchResults objectAtIndex:indexPath.row]];
    createdTimeTitle.backgroundColor=[UIColor clearColor];
    // [createdTimeTitle setBackgroundColor:[UIColor grayColor]];
    [cell addSubview:createdTimeTitle];
    

    NSString *selectedCountry =[NSString stringWithFormat:@"%@",[self.searchResults objectAtIndex:indexPath.row]];
    NSString *countryCode = [self.countryByCodeDict valueForKey:selectedCountry];
    
    NSString *imagePath = [NSString stringWithFormat:@"CountryPicker.bundle/%@", countryCode];
    
    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imagePath]];
    [img setFrame:CGRectMake(3, 3, img.frame.size.width,  img.frame.size.height)];
    [cell addSubview:img];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.navigationController.navigationBar.hidden=YES;
    
    NSString *selectedCountry =[NSString stringWithFormat:@"%@",[self.searchResults objectAtIndex:indexPath.row]];
    NSString *selectedCountryCode = [self.countryList valueForKey:selectedCountry];
    
    self.countryCodeTextField.text = selectedCountryCode;
    
    NSString *countryCode = [self.countryByCodeDict valueForKey:selectedCountry];
    
    
    [searchControllerMain setActive:NO];
    [searchControllerMain.searchBar resignFirstResponder];
    
    
    UIView *baseView=(UIView *)[self.view viewWithTag:200];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [self.countryListingTableView.layer addAnimation:anim forKey:nil];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        baseView.alpha=0;
        self.countryListingTableView.alpha=0;
        
        
        
        
    } completion:^(BOOL finished) {
        
        if (baseView) {
            [baseView removeFromSuperview];
        }
        if (self.countryListingTableView) {
            [self.countryListingTableView removeFromSuperview];
        }
        
    }];

    
    self.navigationController.navigationBar.hidden=YES;
    
    self.navigationController.navigationBar.hidden=YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}




//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - UISearchBarDelegate
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"WillEndSearch");
    
    [searchControllerMain.searchBar resignFirstResponder];
    self.searchResults=self.countryListArray;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.countryListingTableView reloadData];
        self.navigationController.navigationBar.hidden=YES;
    });

}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
   
    

    
    if (searchString.length ==0) {
        
        self.searchResults=self.countryListArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.countryListingTableView reloadData];
        });
    }
    else
    {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchString];
    NSArray *newArray = [self.countryListArray filteredArrayUsingPredicate:predicate];
    NSLog(@"%@", newArray );
    
    self.searchResults=[NSMutableArray arrayWithArray:newArray];
    NSLog(@"%@",self.searchResults);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.countryListingTableView reloadData];
    });
        
    }
    
    
    
 
    
    return YES;
}

- (void)updateFilteredContentForProductName1:(NSString *)productName type:(NSString *)typeName {
    
    
    // Update the filtered array based on the search text and scope.
    if ((productName == nil) || [productName length] == 0) {
        // If there is no search string and the scope is "All".
        if (typeName == nil) {
            self.searchResults = [self.countryListArray mutableCopy];
        } else {
            // If there is no search string and the scope is chosen.
            NSMutableArray *searchResults1 = [[NSMutableArray alloc] init];
            for (NSString *product in self.countryListArray) {
                if ([product isEqualToString:typeName]) {
                    [searchResults1 addObject:product];
                }
            }
            self.searchResults = searchResults1;
        }
        return;
    }
    
    [self.searchResults removeAllObjects]; // First clear the filtered array.
    
    NSLog(@"%@",self.countryListArray);
    /*  Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    for (NSString *product in self.countryListArray) {
        if ((typeName == nil) || [product isEqualToString:typeName]) {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange productNameRange = NSMakeRange(0, product.length);
            NSRange foundRange = [product rangeOfString:productName options:searchOptions range:productNameRange];
            if (foundRange.length > 0) {
                [self.searchResults addObject:product];
            }
        }
    }
    
    
    NSLog(@"%@",self.searchResults);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.countryListingTableView reloadData];
    });
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText length] == 0) {
        
        self.searchResults=self.countryListArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.countryListingTableView reloadData];
        });
       }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.searchResults=self.countryListArray;
    
  dispatch_async(dispatch_get_main_queue(), ^{
        [self.countryListingTableView reloadData];
        self.navigationController.navigationBar.hidden=YES;
    });
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}




//#######################################################################################
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#pragma mark - Methods To Get Country Codes
- (NSDictionary *)countryNamesByCode
{
    static NSDictionary *_countryNamesByCode = nil;
    if (!_countryNamesByCode)
    {
        NSMutableDictionary *namesByCode = [NSMutableDictionary dictionary];
        for (NSString *code in [NSLocale ISOCountryCodes])
        {
            NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:code];
            
            //workaround for simulator bug
            if (!countryName)
            {
                countryName = [[NSLocale localeWithLocaleIdentifier:@"en_US"] displayNameForKey:NSLocaleCountryCode value:code];
            }
            
            namesByCode[code] = countryName ?: code;
        }
        _countryNamesByCode = [namesByCode copy];
    }
    return _countryNamesByCode;
}
-(NSDictionary *)countryCodesByName
{
    static NSDictionary *_countryCodesByName = nil;
    if (!_countryCodesByName)
    {
        NSDictionary *countryNamesByCode = [self countryNamesByCode];
        NSMutableDictionary *codesByName = [NSMutableDictionary dictionary];
        for (NSString *code in countryNamesByCode)
        {
            codesByName[countryNamesByCode[code]] = code;
        }
        _countryCodesByName = [codesByName copy];
    }
    return _countryCodesByName;
}
-(void)setupCountryCodes
{
    self.countryList = @{
                         @"Canada"                                       : @"+1",
                         @"China"                                        : @"+86",
                         @"France"                                       : @"+33",
                         @"Germany"                                      : @"+49",
                         @"India"                                        : @"+91",
                         @"Japan"                                        : @"+81",
                         @"Pakistan"                                     : @"+92",
                         @"United Kingdom"                               : @"+44",
                         @"United States"                                : @"+1",
                         @"Abkhazia"                                     : @"+7 840",
                         @"Abkhazia"                                     : @"+7 940",
                         @"Afghanistan"                                  : @"+93",
                         @"Albania"                                      : @"+355",
                         @"Algeria"                                      : @"+213",
                         @"American Samoa"                               : @"+1 684",
                         @"Andorra"                                      : @"+376",
                         @"Angola"                                       : @"+244",
                         @"Anguilla"                                     : @"+1 264",
                         @"Antigua and Barbuda"                          : @"+1 268",
                         @"Argentina"                                    : @"+54",
                         @"Armenia"                                      : @"+374",
                         @"Aruba"                                        : @"+297",
                         @"Ascension"                                    : @"+247",
                         @"Australia"                                    : @"+61",
                         @"Australian External Territories"              : @"+672",
                         @"Austria"                                      : @"+43",
                         @"Azerbaijan"                                   : @"+994",
                         @"Bahamas"                                      : @"+1 242",
                         @"Bahrain"                                      : @"+973",
                         @"Bangladesh"                                   : @"+880",
                         @"Barbados"                                     : @"+1 246",
                         @"Barbuda"                                      : @"+1 268",
                         @"Belarus"                                      : @"+375",
                         @"Belgium"                                      : @"+32",
                         @"Belize"                                       : @"+501",
                         @"Benin"                                        : @"+229",
                         @"Bermuda"                                      : @"+1 441",
                         @"Bhutan"                                       : @"+975",
                         @"Bolivia"                                      : @"+591",
                         @"Bosnia and Herzegovina"                       : @"+387",
                         @"Botswana"                                     : @"+267",
                         @"Brazil"                                       : @"+55",
                         @"British Indian Ocean Territory"               : @"+246",
                         @"British Virgin Islands"                       : @"+1 284",
                         @"Brunei"                                       : @"+673",
                         @"Bulgaria"                                     : @"+359",
                         @"Burkina Faso"                                 : @"+226",
                         @"Burundi"                                      : @"+257",
                         @"Cambodia"                                     : @"+855",
                         @"Cameroon"                                     : @"+237",
                         @"Canada"                                       : @"+1",
                         @"Cape Verde"                                   : @"+238",
                         @"Cayman Islands"                               : @"+ 345",
                         @"Central African Republic"                     : @"+236",
                         @"Chad"                                         : @"+235",
                         @"Chile"                                        : @"+56",
                         @"China"                                        : @"+86",
                         @"Christmas Island"                             : @"+61",
                         @"Cocos-Keeling Islands"                        : @"+61",
                         @"Colombia"                                     : @"+57",
                         @"Comoros"                                      : @"+269",
                         @"Congo"                                        : @"+242",
                         @"Congo, Dem. Rep. of (Zaire)"                  : @"+243",
                         @"Cook Islands"                                 : @"+682",
                         @"Costa Rica"                                   : @"+506",
                         @"Ivory Coast"                                  : @"+225",
                         @"Croatia"                                      : @"+385",
                         @"Cuba"                                         : @"+53",
                         @"Curacao"                                      : @"+599",
                         @"Cyprus"                                       : @"+537",
                         @"Czech Republic"                               : @"+420",
                         @"Denmark"                                      : @"+45",
                         @"Diego Garcia"                                 : @"+246",
                         @"Djibouti"                                     : @"+253",
                         @"Dominica"                                     : @"+1 767",
                         @"Dominican Republic"                           : @"+1 809",
                         @"Dominican Republic"                           : @"+1 829",
                         @"Dominican Republic"                           : @"+1 849",
                         @"East Timor"                                   : @"+670",
                         @"Easter Island"                                : @"+56",
                         @"Ecuador"                                      : @"+593",
                         @"Egypt"                                        : @"+20",
                         @"El Salvador"                                  : @"+503",
                         @"Equatorial Guinea"                            : @"+240",
                         @"Eritrea"                                      : @"+291",
                         @"Estonia"                                      : @"+372",
                         @"Ethiopia"                                     : @"+251",
                         @"Falkland Islands"                             : @"+500",
                         @"Faroe Islands"                                : @"+298",
                         @"Fiji"                                         : @"+679",
                         @"Finland"                                      : @"+358",
                         @"France"                                       : @"+33",
                         @"French Antilles"                              : @"+596",
                         @"French Guiana"                                : @"+594",
                         @"French Polynesia"                             : @"+689",
                         @"Gabon"                                        : @"+241",
                         @"Gambia"                                       : @"+220",
                         @"Georgia"                                      : @"+995",
                         @"Germany"                                      : @"+49",
                         @"Ghana"                                        : @"+233",
                         @"Gibraltar"                                    : @"+350",
                         @"Greece"                                       : @"+30",
                         @"Greenland"                                    : @"+299",
                         @"Grenada"                                      : @"+1 473",
                         @"Guadeloupe"                                   : @"+590",
                         @"Guam"                                         : @"+1 671",
                         @"Guatemala"                                    : @"+502",
                         @"Guinea"                                       : @"+224",
                         @"Guinea-Bissau"                                : @"+245",
                         @"Guyana"                                       : @"+595",
                         @"Haiti"                                        : @"+509",
                         @"Honduras"                                     : @"+504",
                         @"Hong Kong SAR China"                          : @"+852",
                         @"Hungary"                                      : @"+36",
                         @"Iceland"                                      : @"+354",
                         @"India"                                        : @"+91",
                         @"Indonesia"                                    : @"+62",
                         @"Iran"                                         : @"+98",
                         @"Iraq"                                         : @"+964",
                         @"Ireland"                                      : @"+353",
                         @"Israel"                                       : @"+972",
                         @"Italy"                                        : @"+39",
                         @"Jamaica"                                      : @"+1 876",
                         @"Japan"                                        : @"+81",
                         @"Jordan"                                       : @"+962",
                         @"Kazakhstan"                                   : @"+7 7",
                         @"Kenya"                                        : @"+254",
                         @"Kiribati"                                     : @"+686",
                         @"North Korea"                                  : @"+850",
                         @"South Korea"                                  : @"+82",
                         @"Kuwait"                                       : @"+965",
                         @"Kyrgyzstan"                                   : @"+996",
                         @"Laos"                                         : @"+856",
                         @"Latvia"                                       : @"+371",
                         @"Lebanon"                                      : @"+961",
                         @"Lesotho"                                      : @"+266",
                         @"Liberia"                                      : @"+231",
                         @"Libya"                                        : @"+218",
                         @"Liechtenstein"                                : @"+423",
                         @"Lithuania"                                    : @"+370",
                         @"Luxembourg"                                   : @"+352",
                         @"Macau SAR China"                              : @"+853",
                         @"Macedonia"                                    : @"+389",
                         @"Madagascar"                                   : @"+261",
                         @"Malawi"                                       : @"+265",
                         @"Malaysia"                                     : @"+60",
                         @"Maldives"                                     : @"+960",
                         @"Mali"                                         : @"+223",
                         @"Malta"                                        : @"+356",
                         @"Marshall Islands"                             : @"+692",
                         @"Martinique"                                   : @"+596",
                         @"Mauritania"                                   : @"+222",
                         @"Mauritius"                                    : @"+230",
                         @"Mayotte"                                      : @"+262",
                         @"Mexico"                                       : @"+52",
                         @"Micronesia"                                   : @"+691",
                         @"Midway Island"                                : @"+1 808",
                         @"Micronesia"                                   : @"+691",
                         @"Moldova"                                      : @"+373",
                         @"Monaco"                                       : @"+377",
                         @"Mongolia"                                     : @"+976",
                         @"Montenegro"                                   : @"+382",
                         @"Montserrat"                                   : @"+1664",
                         @"Morocco"                                      : @"+212",
                         @"Myanmar"                                      : @"+95",
                         @"Namibia"                                      : @"+264",
                         @"Nauru"                                        : @"+674",
                         @"Nepal"                                        : @"+977",
                         @"Netherlands"                                  : @"+31",
                         @"Netherlands Antilles"                         : @"+599",
                         @"Nevis"                                        : @"+1 869",
                         @"New Caledonia"                                : @"+687",
                         @"New Zealand"                                  : @"+64",
                         @"Nicaragua"                                    : @"+505",
                         @"Niger"                                        : @"+227",
                         @"Nigeria"                                      : @"+234",
                         @"Niue"                                         : @"+683",
                         @"Norfolk Island"                               : @"+672",
                         @"Northern Mariana Islands"                     : @"+1 670",
                         @"Norway"                                       : @"+47",
                         @"Oman"                                         : @"+968",
                         @"Pakistan"                                     : @"+92",
                         @"Palau"                                        : @"+680",
                         @"Palestinian Territory"                        : @"+970",
                         @"Panama"                                       : @"+507",
                         @"Papua New Guinea"                             : @"+675",
                         @"Paraguay"                                     : @"+595",
                         @"Peru"                                         : @"+51",
                         @"Philippines"                                  : @"+63",
                         @"Poland"                                       : @"+48",
                         @"Portugal"                                     : @"+351",
                         @"Puerto Rico"                                  : @"+1 787",
                         @"Puerto Rico"                                  : @"+1 939",
                         @"Qatar"                                        : @"+974",
                         @"Reunion"                                      : @"+262",
                         @"Romania"                                      : @"+40",
                         @"Russia"                                       : @"+7",
                         @"Rwanda"                                       : @"+250",
                         @"Samoa"                                        : @"+685",
                         @"San Marino"                                   : @"+378",
                         @"Saudi Arabia"                                 : @"+966",
                         @"Senegal"                                      : @"+221",
                         @"Serbia"                                       : @"+381",
                         @"Seychelles"                                   : @"+248",
                         @"Sierra Leone"                                 : @"+232",
                         @"Singapore"                                    : @"+65",
                         @"Slovakia"                                     : @"+421",
                         @"Slovenia"                                     : @"+386",
                         @"Solomon Islands"                              : @"+677",
                         @"South Africa"                                 : @"+27",
                         @"South Georgia and the South Sandwich Islands" : @"+500",
                         @"Spain"                                        : @"+34",
                         @"Sri Lanka"                                    : @"+94",
                         @"Sudan"                                        : @"+249",
                         @"Suriname"                                     : @"+597",
                         @"Swaziland"                                    : @"+268",
                         @"Sweden"                                       : @"+46",
                         @"Switzerland"                                  : @"+41",
                         @"Syria"                                        : @"+963",
                         @"Taiwan"                                       : @"+886",
                         @"Tajikistan"                                   : @"+992",
                         @"Tanzania"                                     : @"+255",
                         @"Thailand"                                     : @"+66",
                         @"Timor Leste"                                  : @"+670",
                         @"Togo"                                         : @"+228",
                         @"Tokelau"                                      : @"+690",
                         @"Tonga"                                        : @"+676",
                         @"Trinidad and Tobago"                          : @"+1 868",
                         @"Tunisia"                                      : @"+216",
                         @"Turkey"                                       : @"+90",
                         @"Turkmenistan"                                 : @"+993",
                         @"Turks and Caicos Islands"                     : @"+1 649",
                         @"Tuvalu"                                       : @"+688",
                         @"Uganda"                                       : @"+256",
                         @"Ukraine"                                      : @"+380",
                         @"United Arab Emirates"                         : @"+971",
                         @"United Kingdom"                               : @"+44",
                         @"United States"                                : @"+1",
                         @"Uruguay"                                      : @"+598",
                         @"U.S. Virgin Islands"                          : @"+1 340",
                         @"Uzbekistan"                                   : @"+998",
                         @"Vanuatu"                                      : @"+678",
                         @"Venezuela"                                    : @"+58",
                         @"Vietnam"                                      : @"+84",
                         @"Wake Island"                                  : @"+1 808",
                         @"Wallis and Futuna"                            : @"+681",
                         @"Yemen"                                        : @"+967",
                         @"Zambia"                                       : @"+260",
                         @"Zanzibar"                                     : @"+255",
                         @"Zimbabwe"                                     : @"+263"
                         };
    
    
    NSLog(@"%@",[self.countryList allKeys]);
}




@end
