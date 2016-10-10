//
//  LocationPickerDelegate.h
//  GMWeather
//
//  Created by appleseed on 09.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kGOOGLE_API_KEY @"AIzaSyCtvodnmd5K2yKbzweMWrLHUQoiDYTWDvE"
#define kOPENWEATHER_API_KEY @"c2ad495cb382311d8df17e235e5a5417"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@protocol LocationPickerDelegate <NSObject>
@required
-(void)selectedLocation:(NSMutableDictionary *)newLocation;
@end

@interface LocationPickerViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, weak) id<LocationPickerDelegate> delegate;

-(void) getAutocomplete: (NSString *) searchText;
@end
