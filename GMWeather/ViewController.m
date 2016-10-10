//
//  ViewController.m
//  GMWeather
//
//  Created by appleseed on 07.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize mapView;
@synthesize locationManager;
@synthesize marker;
@synthesize CurentLocationButton;
@synthesize locationPicker;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.44
                                                            longitude:30.52
                                                                 zoom:9];
    mapView.camera = camera;
    mapView.delegate = self;
    
    NetworkManager* nm = [NetworkManager sharedManager];
    nm.delegate = self;
    [self createMarkerWihPosition:CLLocationCoordinate2DMake(50.44, 30.52) title:@"Kiev" snippet:@"Ukraine"];
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.locationManager requestWhenInUseAuthorization];
    locationPicker = [[LocationPickerViewController alloc] init];
    locationPicker.delegate = self;
    [_searchTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GMSMapViewDelegate
-(void)createMarkerWihPosition:(CLLocationCoordinate2D)position title:(NSString*)title snippet:(NSString*)snippet{
    if(marker == NULL)
    marker = [[GMSMarker alloc] init];
    marker.position = position;
    marker.title = title;
    marker.snippet = snippet;
    marker.map = mapView;
}

-(void)hideMarker{
    marker.map = nil;
}

- (void)mapView:(GMSMapView *)mapView
didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if(self.mapView.myLocationEnabled)
        [self UnselectCurentLocation];
    [self createMarkerWihPosition:coordinate title:@"Point" snippet:@"Weather here"];
    [[NetworkManager sharedManager] reGeocoding:coordinate.latitude lon:coordinate.longitude];
    [[NetworkManager sharedManager] getWeatherWithLat:coordinate.latitude lon:coordinate.longitude];
}

#pragma mark - CLLocationManagerDelegate
- (IBAction)CurentLocation:(UIButton*)sender {
    [self hideMarker];
    if(!sender.selected){
     mapView.myLocationEnabled = YES;
    [self.locationManager startUpdatingLocation];
    [sender setSelected:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NetworkManager sharedManager] getWeatherWithLat:marker.position.latitude lon:marker.position.longitude];
            [[NetworkManager sharedManager] reGeocoding:marker.position.latitude lon:marker.position.longitude];
        });
    }
    else{
        [self UnselectCurentLocation];
    }
}

-(void)UnselectCurentLocation{
    mapView.myLocationEnabled = NO;
    [CurentLocationButton setSelected:NO];
    [self.locationManager stopUpdatingLocation];
    marker.map = mapView;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                            longitude:newLocation.coordinate.longitude
                                                                 zoom:15.0];
    [mapView animateToCameraPosition:camera];
    marker.position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

#pragma mark - search
- (void)showLocationPopover{
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:locationPicker];
    destNav.modalPresentationStyle = UIModalPresentationPopover;
    _locationPopover = destNav.popoverPresentationController;
    _locationPopover.delegate = self;
    _locationPopover.sourceView = self.view;
    _locationPopover.sourceRect = _searchTextField.frame;
    destNav.navigationBarHidden = YES;
    [self presentViewController:destNav animated:YES completion:nil];
}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}
-(void)hideLocationPopover{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)selectedLocation:(NSMutableDictionary *)newLocation{
    _searchTextField.text = [newLocation objectForKey:@"description"];
    _cityLabel.text = [[[newLocation objectForKey:@"terms"] objectAtIndex:0] objectForKey:@"value"];
    [self hideLocationPopover];
    [self textFieldShouldReturn:_searchTextField];
    [[NetworkManager sharedManager] getLocate:[newLocation objectForKey:@"place_id"]];
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    if(theTextField.text.length >0){
        if(self.presentedViewController==nil)
            [self showLocationPopover];
        if(self.mapView.myLocationEnabled)
            [self UnselectCurentLocation];
        [[NetworkManager sharedManager] getAutocomplete:theTextField.text];
    }
    else{
        if(self.presentedViewController!=nil){
            [self hideLocationPopover];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Networking
-(void)pasteWeatherLabel:(NSString*)text{
    _temperatureLabel.text = text;
}
-(void)pasteTemperatureLabel:(NSString*)text{
    _temperatureLabel.text = text;
}
-(void)pasteHumidityLabel:(NSString*)text{
    _humidityLabel.text = text;
}
-(void)pasteCityLabel:(NSString*)text{
    _cityLabel.text = text;
}
-(void)pasteWindLabel:(NSString*)text{
    _windLabel.text = text;
}
-(void)createLocalMarker:(CLLocationCoordinate2D)position{
    [self createMarkerWihPosition:position title:@"Point" snippet:@"Weather here"];
    mapView.camera = [GMSCameraPosition cameraWithLatitude:position.latitude
                                                 longitude:position.longitude
                                                      zoom:9.0];
}

/*-(void)setupConstraints{
    NSLayoutConstraint *leftButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:self.mapView attribute:NSLayoutAttributeCenterX
                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:
                                                 NSLayoutAttributeCenterX multiplier:1.0 constant:-60.0f];
    NSLayoutConstraint *leftButtonYConstraint = [NSLayoutConstraint
                                                 constraintWithItem:self.mapView attribute:NSLayoutAttributeCenterY
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                 NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.view addConstraints:@[ leftButtonXConstraint,
                                 leftButtonYConstraint]];
}*/
@end