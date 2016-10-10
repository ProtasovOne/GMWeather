//
//  Network.m
//  GMWeather
//
//  Created by appleseed on 10.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import "Network.h"

@implementation NetworkManager

@synthesize someProperty;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static NetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}

- (NSURL*)validUrl:(NSString*)url {
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:url];
}

-(void) getLocate: (NSString *) placeId{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?place_id=%@&key=%@",placeId,kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[self validUrl:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedLocaleData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedLocaleData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    double lat = [[[[[[json objectForKey:@"results"]objectAtIndex:0]objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"]doubleValue];
    double lon = [[[[[[json objectForKey:@"results"]objectAtIndex:0]objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"]doubleValue];
    if (_delegate != nil) {
        [_delegate createLocalMarker:CLLocationCoordinate2DMake(lat, lon)];
    }
    [self getWeatherWithLat:lat lon:lon];
}

-(void) reGeocoding: (double) lat lon:(double)lon{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@",lat,lon,kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[self validUrl:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedreGeocodingData:) withObject:data waitUntilDone:YES];
    });
}
- (void)fetchedreGeocodingData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSString* city = [[[[[json objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"] objectAtIndex:0] objectForKey:@"short_name"];
    if (_delegate != nil) {
        [_delegate pasteCityLabel:city];
    }
}

-(void) getWeatherWithLat: (double) lat lon:(double)lon{
    NSString *url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=%@",lat,lon,kOPENWEATHER_API_KEY];
    NSURL *googleRequestURL=[self validUrl:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedWeatherData:) withObject:data waitUntilDone:YES];
    });
}
- (void)fetchedWeatherData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    NSString* wind = [[json objectForKey:@"wind"] objectForKey:@"speed"];
    if (_delegate != nil) {
        [_delegate pasteWindLabel:[NSString stringWithFormat:@"%@ м/с",wind]];
    }
    
    double weather = [[[json objectForKey:@"main"] objectForKey:@"temp"]doubleValue] -273.15;
    if (_delegate != nil) {
        [_delegate pasteWeatherLabel:[NSString stringWithFormat:@"%i C",(int)weather]];
    }
    NSString* humidity = [[json objectForKey:@"main"] objectForKey:@"humidity"];
    if (_delegate != nil) {
        [_delegate pasteHumidityLabel:[NSString stringWithFormat:@"%@ %%",humidity]];
    }
}
//==================== PICKER

-(void) getAutocomplete: (NSString *) searchText{
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=%@",searchText,kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[self validUrl:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    if (_pickerDelegate != nil) {
        [_pickerDelegate pasteAutocomplete:[json objectForKey:@"predictions"]];
    }
}

- (void)dealloc {
}

@end