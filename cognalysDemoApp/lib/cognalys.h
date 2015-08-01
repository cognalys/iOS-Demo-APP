//
//  cognalys.h
//  cognalys


/******************************************************************************
 Copyright (c) < Copyight Session>
 
 
 ******************************************************************************/

/**
 * @file cognalys.h
 * @brief This is the header file for the public interface of the Cognalys -> iOS Library.
 *
 * The libcognalys.a acts as a layer between a UI and the
 * Cognalys framework in iOS, providing call verification control specific in Cognalys.
 *
 */


/******************************************************************************
 Section 0: Header File Inclusion
 ******************************************************************************/

#import  <Foundation/Foundation.h>
#import  <CoreLocation/CoreLocation.h>
#include <CoreLocation/CLLocationManagerDelegate.h>
#include <CoreLocation/CLError.h>
#include <CoreLocation/CLLocation.h>
#include <CoreLocation/CLLocationManager.h>

#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

/******************************************************************************
 Section 2: Callback Definitions
 ******************************************************************************/

/** \ Delegate : WebserviceDelegate
 * \brief libcognalys.a will populate this structure while notifying upper layer of
 * asynchronous events through WebserviceDelegate delegate.
 */

@protocol WebserviceDelegate
@optional

/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: cog_CallConnectedSuccessNotif
 * This function, implemented by an upper layer, will be called whenever a
 * notification must be communicated based on an event occurring.
 * This function will get triggred when the init Api functionality returns success status
 * @return: cog_CallbackData - Return data provided by the library.
 * cog_CallbackData is dictionary contains  -
 * @param[out] status                        - Status of init Api
 * @param[out] keymatch                      - This should be requested when you hit the second API ( Second step )
 * @param[out] mobile                        - The mobile number which you requested to verify
 * @param[out] otp_start                     - The first five digits of the cognalys missed call number
 */
-(void)cog_CallConnectedSuccessNotif:(NSDictionary *)cog_CallbackData;



/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: cog_CallConnectedErrorNotif
 * This function, implemented by an upper layer, will be called whenever a
 * notification must be communicated based on an event occurring.
 * This function will get triggred when the init Api functionality returns Failure status
 * @return: cog_CallbackData - Return data provided by the library.
 * cog_CallbackData is dictionary contains  -
 * @param[out] status                        - Status of init Api
 * @param[out] mobile                        - The mobile number which you requested to verify
 * @param[out] errors                        -  return "ERROR_CODE": "ERROR_MESSAGE"
 * ERROR_CODE : if there is any errors occured the status will be failed .And you will get a dictionary of ERROR_CODE along with its message .
 *ERROR_MESSAGE : if there is any errors occured the status will be failed. You will get ERROR_MESSAGE as value of ERROR_CODE
 */
-(void)cog_CallConnectedErrorNotif:(NSDictionary *)cog_CallbackData;



/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: cog_OTPVerificationSuccessNotif
 * This function, implemented by an upper layer, will be called whenever a
 * notification must be communicated based on an event occurring.
 * This function will get triggred when OTP verification functionality returns success status
 * @return: cog_CallbackData - Return data provided by the library.
 * cog_CallbackData is dictionary contains -
 * @param[out] status                       - Status of OTP verification Api
 * @param[out] message                      -  The message when everything went correct
 */
-(void)cog_OTPVerificationSuccessNotif:(NSDictionary *)cog_CallbackData;


/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: cog_OTPVerificationErrorNotif
 * This function, implemented by an upper layer, will be called whenever a
 * notification must be communicated based on an event occurring.
 * This function will get triggred when OTP verification functionality returns failure status
 * @return: cog_CallbackData - Return data provided by the library.
 * cog_CallbackData is dictionary contains  -
 * @param[out] status                        -  Status of OTP verification Api
 * @param[out] mobile                        -  The mobile number which you requested to verify
 * @param[out] errors                        -  "ERROR_CODE": "ERROR_MESSAGE"
 * ERROR_CODE : if there is any errors occured the status will be failed .And you will get a dictionary of ERROR_CODE along with its message .
 * ERROR_MESSAGE : if there is any errors occured the status will be failed. You will get ERROR_MESSAGE as value of ERROR_CODE
 */
-(void)cog_OTPVerificationErrorNotif:(NSDictionary *)cog_CallbackData;



/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: mobileVerificationRetryWithMessage
 * This function, implemented by an upper layer, will be called whenever
 * library starts retrying verification process with the same number
 * if it take more than 10seconds to receive verification missed call
 * @param[out] cog_retryMessage                        -  Message
  */

-(void)mobileVerificationRetryWithMessage:(NSString *)cog_retryMessage;


/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: mobileVerificationRetryFailedWithMessage
 * This function, implemented by an upper layer, will be called whenever
 * library verification retry fails.
 * @param[out] cog_retryMessage                        -  Message
 */
-(void)mobileVerificationRetryFailedWithMessage:(NSString *)cog_retryMessage;



/** \brief Callback to NOTIFY the upper layer of asynchronous events.
 * @abstract: cog_APISuccessAndReceivedMiscall
 * This function, implemented by an upper layer, will be called whenever
 * library receives a misscall after successfully initializing number verification.
 * developer can display the OTP verification box after this call back.
 * @param[out] cog_retryMessage                        -  Message
 */

-(void)cog_APISuccessAndReceivedMiscall;



//Optional
-(void)getLog:(NSString *)log;

@end



@interface cognalys : NSObject<CLLocationManagerDelegate>
{
    __weak id <WebserviceDelegate> delegate;
}

/**
 * @param delegate <WebserviceDelegate>  Implement this elegate to get asynchronous events in libcognalys.a
 */
@property (weak) id <WebserviceDelegate> delegate;


/**
 * @param locationManager :  CLLocationManager object to access the user location.
 */
@property(nonatomic,retain)CLLocationManager* locationManager;


/**
 * @param Currentlatitude / Currentlongitude :  Can call this to get the current location of device holder.
 */

@property(nonatomic,retain) NSString*    Currentlatitude;
@property(nonatomic,retain) NSString*    Currentlongitude;

/**
 * @param  :  Can call this to get the current device details like Model, OS version, Device id etc.
 */

@property(nonatomic,retain) NSString*    currentDevice;
@property(nonatomic,retain) NSString*    model;
@property(nonatomic,retain) NSString*    systemVersion;
@property(nonatomic,retain) NSString*    DeviceId;




/**
 * @param(in) access_token :  Developer need to set access_token during the initialization of cognalys API.
 */
@property(nonatomic,retain) NSString*    access_token;

/**
 * @param(in) app_ID :  Developer need to set registred app_ID during the initialization of cognalys API.
 */
@property(nonatomic,retain) NSString*    app_ID;

/**
 * @param(in) getLocation :  Developer can set getLocation during the initialization of cognalys API. This is an optional settings for the developer. By default it will set as FALSE.
 */
@property(nonatomic,assign) BOOL         getLocation;


/**
 * @param(in) canRetryVerification :  Developer can set retryVerificationRequest during the initialization of cognalys API. This is an optional settings for the developer to tell the API that the system needs automatic retry. By default it will set as FALSE.
 */
@property(nonatomic,assign) BOOL         canRetryVerification;





/******************************************************************************
 Section 4: Function Declarations
 ******************************************************************************/


/**
 * @abstract: initiateAPIWithMobileNumber:
 * This function, when called, will initialize resources for the. In
 * general, this function will request for a miscall to libcognalys.a.
 * This is an asynchronous process and structure will be returned as the
 * cog_CallConnectedSuccessNotif / cog_CallConnectedErrorNotif
 *
 * before calling initiateAPIWithMobileNumber , developer should pass access_token and app_ID to
 * libcognalys inorder to verify the cognalys account. Optionally developer can set getLocation to
 * access / track the user location
 * Optionally we are sending Device model, Current OS version , Device ID with the url request.
 * track the location through init.
 *
 * @param[in] cog_mobileNumber   	String variable that holds the number
 *									to request miscall.
 *
 * @return                          nill < nothing will return >
 *
 */
-(void)initiateAPIWithMobileNumber:(NSString *) cog_mobileNumber;




/**
 * @abstract: verifyOTP_withNumberCopyedFromTheLog:
 * This function, when called, to verify the OTP. In
 * general, this function will confirm mobile number that we request for miscall.
 * This is an asynchronous process and structure will be returned as the
 * cog_OTPVerificationSuccessNotif / cog_OTPVerificationErrorNotif
 *
 * Developer need to pass only a missed call number which copied from the device.
 * This function will send a request to congalys to verify OTP with the number copyed and key match that.
 * Optionally we are sending Device model, Current OS version , Device ID with the request.
 *
 * @param[in] cog_mobileNumber   	String variable that holds the number
 *									to verify OTP.
 *
 * @return                          nill < nothing will return >
 *
 */
-(void)verifyOTP_withNumberCopyedFromTheLog:(NSString *) cog_mobileNumber;

@end
