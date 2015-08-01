//
//  VerifiedLocationMap.m
//  cognalysDemoApp
//
//  Created by MFluid Apps on 31/07/15.
//  Copyright (c) 2015 Mfluid Mobile Apps Pvt. Ltd. All rights reserved.
//

#import "VerifiedLocationMap.h"
#import "cognalys.h"
#import "ViewController.h"

@interface VerifiedLocationMap ()

@end

@implementation VerifiedLocationMap
@synthesize locatedAddress,locationManager,activityViewController,lattitude,longitude;
@synthesize activityView;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locatedAddress=@"";
    
    self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityView.center = self.view.center;
    [self.activityView setFrame:CGRectMake(self.activityView.frame.origin.x, self.activityView.frame.origin.y+30, self.activityView.frame.size.width, self.activityView.frame.size.height)];
    self.activityView.hidden = YES;
    [self.view addSubview:self.activityView];
    
    
    
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate=self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    
    
   
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    self.lattitude =[NSString stringWithFormat:@"%f",coordinate.latitude];
    self.longitude =[NSString stringWithFormat:@"%f",coordinate.longitude];
    
    MKCoordinateSpan span1= MKCoordinateSpanMake(.0045, .0057);
    MKCoordinateRegion region1 = {coordinate, span1};
    [self.mapView setRegion:region1];
    self.mapView.showsUserLocation=YES;

    
    
    points = [[MKPointAnnotation alloc] init];
    if(coordinate.latitude!=0)
    {
        points.coordinate=coordinate;
    }
    points.title=[NSString stringWithFormat:@"Verified Location"];
    pointsA = [[MKPinAnnotationView alloc] initWithAnnotation:points reuseIdentifier:nil] ;
    pointsA.pinColor = MKPinAnnotationColorGreen;
    pointsA.draggable=NO;
    pointsA.userInteractionEnabled=NO;
    pointsA.canShowCallout = YES;
    pointsA.canShowCallout=YES;
    [self.mapView addAnnotation:pointsA.annotation];
    
    
    [self reverseGeoCodingWithLocation:location];
    
    
    // Do any additional setup after loading the view.
}
-(void)reverseGeoCodingWithLocation:(CLLocation *)newLocation
{
    NSLog(@"%@",self.locatedAddress);
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            // NSLog(@"%@",placemark);
            
            NSString * addressName = [placemark name];
            NSString * city = [placemark locality]; // locality means "city"
            NSString * administrativeArea = [placemark administrativeArea]; // which is "state" in the U.S.A.
            
            NSString *locality = [placemark locality];
            
            
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            NSString *Address = [[NSString alloc]initWithString:locatedAt];
            
            self.locatedAddress=Address;
            
            [self.activityView stopAnimating];
            [self.activityView setHidesWhenStopped:YES];
        
            
                 }
    }];

}
- (MKAnnotationView *)mapView:(MKMapView *)mapView2 viewForAnnotation:(id<MKAnnotation>)annotation{
    
    MKPinAnnotationView *annView=nil;
    
    if( annotation == self.mapView.userLocation ){
        return nil;
    }
    else{
        
        
       
            
            annView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:Nil];
            if( annView == nil ){
                annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
            }
            
            // annView.pinColor =  [UIColor redColor]CGColor;
            //NSLog(@"Pin color: %d", [defaults integerForKey:@"currPinColor"]);
            annView.animatesDrop=TRUE;
            annView.canShowCallout = YES;
            annView.draggable=YES;
            
            
        
            UIButton *leftIconView = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftIconView addTarget:self action:@selector(goToHomePage:) forControlEvents:UIControlEventTouchUpInside];
            [leftIconView setFrame:CGRectMake(0, 0, 24, 24)];
            [leftIconView setImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];            annView.leftCalloutAccessoryView=leftIconView;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton addTarget:self action:@selector(shareLocation:) forControlEvents:UIControlEventTouchUpInside];
            [rightButton setFrame:CGRectMake(0, 0, 24, 24)];
            [rightButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
            
            annView.rightCalloutAccessoryView=rightButton;
            
            
            annView.canShowCallout = YES;
            CGRect endFrame = annView.frame;
            
            annView.frame = CGRectMake(annView.frame.origin.x, annView.frame.origin.y - 230.0, annView.frame.size.width, annView.frame.size.height);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.45];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [annView setFrame:endFrame];
            [UIView commitAnimations];
            
            
            annView.calloutOffset = CGPointMake(-5, 5);
            
       
            
    }
    
    
    
    
    
    return annView;
    
}

-(void)shareLocation:(id)sender
{
    
    if ( [self.locatedAddress length]==0) {
        
        
        self.activityView.hidden=NO;
        [self.activityView startAnimating];

        
        [self performSelector:@selector(copyAddressToShare) withObject:nil afterDelay:4];
    }
    else
    {
        NSString *str=[NSString stringWithFormat:@"Cognalys verification is done at location %@ , Lattitude : %@ , Longitude :%@ ",self.locatedAddress,self.lattitude,self.longitude];
        
        NSLog(@"%@",str);
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[str] applicationActivities:nil];
        
        [self.activityViewController setValue:@"Cognalys - Verifies Location" forKey:@"subject"];
        
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }
    
   
}

-(void)copyAddressToShare
{
    [self.activityView stopAnimating];
    [self.activityView setHidesWhenStopped:YES];
    

    
    
    NSString *str=[NSString stringWithFormat:@"Cognalys verification is done at location %@ , Lattitude : %@ , Longitude :%@ ",self.locatedAddress,self.lattitude,self.longitude];
    
    NSLog(@"%@",str);
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[str] applicationActivities:nil];
    
    [self.activityViewController setValue:@"Cognalys - Verifies Location" forKey:@"subject"];
    
    [self presentViewController:self.activityViewController animated:YES completion:nil];
    
}
-(void)goToHomePage:(id)sender
{
    for (UIViewController *view in [self.navigationController viewControllers]) {
        
        if ([view isKindOfClass:[ViewController class]]) {
            
            [self.navigationController popToViewController:view animated:YES];
        }
    }
}
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

@end
