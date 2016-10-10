//
//  LocationPickerDelegate.m
//  GMWeather
//
//  Created by appleseed on 09.10.16.
//  Copyright © 2016 Nodeads. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "Network.h"

@implementation LocationPickerViewController

#pragma mark - Init
-(id)initWithStyle:(UITableViewStyle)style{
    if ([super initWithStyle:style] != nil) {
        _locations = [NSMutableArray array];
        self.clearsSelectionOnViewWillAppear = NO;
        NetworkManager* nm = [NetworkManager sharedManager];
        nm.pickerDelegate = self;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
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

-(void)pasteAutocomplete:(NSMutableArray *)autocomplete{
    _locations = autocomplete;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_delegate != nil) {
        [_delegate selectedLocation:[_locations objectAtIndex:indexPath.row]];
    }
}

@end
