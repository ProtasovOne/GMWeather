//
//  LocationPickerDelegate.h
//  GMWeather
//
//  Created by appleseed on 09.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Definations.h"
#import "Network.h"

@protocol LocationPickerDelegate <NSObject>
@required
-(void)selectedLocation:(NSMutableDictionary *)newLocation;
@end

@interface LocationPickerViewController : UITableViewController<LocationPickerNetworkDelegate>

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, weak) id<LocationPickerDelegate> delegate;
@end
