//
//  Network.h
//  GMWeather
//
//  Created by appleseed on 10.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definations.h"
@import GoogleMaps;

@protocol LocationPickerNetworkDelegate <NSObject>
@required
-(void)pasteAutocomplete:(NSMutableArray *)autocomplete;
@end

@protocol NetworkLocationDelegate <NSObject>
@required
-(void)pasteWeatherLabel:(NSString*)text;
-(void)pasteTemperatureLabel:(NSString*)text;
-(void)pasteHumidityLabel:(NSString*)text;
-(void)pasteCityLabel:(NSString*)text;
-(void)pasteWindLabel:(NSString*)text;
-(void)createLocalMarker:(CLLocationCoordinate2D)position;

@end

@interface NetworkManager : NSObject {
    NSString *someProperty;
}
@property (nonatomic, weak) id<LocationPickerNetworkDelegate> pickerDelegate;
@property (nonatomic, weak) id<NetworkLocationDelegate> delegate;

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;

-(void) getLocate: (NSString *) placeId;
-(void) reGeocoding: (double) lat lon:(double)lon;
-(void) getWeatherWithLat: (double) lat lon:(double)lon;
-(void) getAutocomplete: (NSString *) searchText;

@end