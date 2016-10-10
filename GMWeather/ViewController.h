//
//  ViewController.h
//  GMWeather
//
//  Created by appleseed on 07.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;
#import <CoreLocation/CoreLocation.h>
#import "LocationPickerViewController.h"
#import "Network.h"

@interface ViewController : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, LocationPickerDelegate,NetworkLocationDelegate>{
    CLLocationManager *locationManager;
}
@property (nonatomic, weak) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *CurentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMarker *marker;
@property (nonatomic, strong) LocationPickerViewController *locationPicker;
@property(nonatomic,strong)UIPopoverPresentationController *locationPopover;

@end

