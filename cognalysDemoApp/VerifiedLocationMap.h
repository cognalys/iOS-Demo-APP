//
//  VerifiedLocationMap.h
//  cognalysDemoApp
//
//  Created by MFluid Apps on 31/07/15.
//  Copyright (c) 2015 Mfluid Mobile Apps Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VerifiedLocationMap : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKPinAnnotationView *pointsA ;
    MKPointAnnotation *points;
}
@property(nonatomic,retain) UIActivityIndicatorView *activityView;
@property(nonatomic,retain)UIActivityViewController *activityViewController;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,retain)  CLLocationManager* locationManager;
@property(nonatomic,retain) NSString *locatedAddress,*lattitude,*longitude;

@end
