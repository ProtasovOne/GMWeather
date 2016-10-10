//
//  LocationPickerDelegate.m
//  GMWeather
//
//  Created by appleseed on 09.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import "LocationPickerViewController.h"

@implementation LocationPickerViewController

#pragma mark - Init
-(id)initWithStyle:(UITableViewStyle)style
{
    if ([super initWithStyle:style] != nil) {
        _locations = [NSMutableArray array];
        self.clearsSelectionOnViewWillAppear = NO;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [[_locations objectAtIndex:indexPath.row ]objectForKey:@"description"];
    
    return cell;
}

- (NSURL*)validUrl:(NSString*)url {
    url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:url];
}

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
    _locations = [json objectForKey:@"predictions"];
    [self.tableView reloadData];
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate != nil) {
        [_delegate selectedLocation:[_locations objectAtIndex:indexPath.row]];
    }
}

@end
