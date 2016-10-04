//
//  MapViewController.m
//  Map
//
//  Created by C N Soft Net on 30/09/16.
//  Copyright © 2016 C N Soft Net. All rights reserved.
//

#import "MapViewController.h"
#import "DisplayLocationVC.h"

@interface MapViewController ()
{
    CLLocationCoordinate2D usercordinate;
    CLLocationManager *locManager;
    DisplayLocationVC *obj;
    MKCoordinateRegion boundingregion;
}

@property (nonatomic,assign)MKCoordinateRegion boundingregion;
@end

@implementation MapViewController

@synthesize boundingregion,places;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblVw.delegate=self;
    _tblVw.dataSource=self;
    
    _locationSearch.delegate=self;
    self.title=@"Location";
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    locManager=[[CLLocationManager alloc] init];

    locManager.delegate=self;
    locManager.distanceFilter=kCLLocationAccuracyBest;
    locManager.distanceFilter=kCLDistanceFilterNone;
    [locManager requestWhenInUseAuthorization];
    [locManager startMonitoringSignificantLocationChanges];
    [locManager startUpdatingLocation];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [locManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"%s: location services authorization was previously denied by the user.", __PRETTY_FUNCTION__);
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                       message:@"Location services were previously denied by the user. Please enable location services for this app in settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    


}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *userLocation=locations.lastObject;
    usercordinate=userLocation.coordinate;
    [locManager stopUpdatingLocation];
    locManager.delegate=nil;
    [self startSearch:_locationSearch.text];

}

-(void)startSearch:(NSString *)searchLocation
{
    //Apple Places Api
    CLLocationCoordinate2D cordinate=CLLocationCoordinate2DMake(usercordinate.latitude,usercordinate.longitude);
    MKCoordinateSpan span=MKCoordinateSpanMake(1.0, 1.0);
    MKCoordinateRegion region=MKCoordinateRegionMake(cordinate, span);
    
    MKLocalSearchRequest *localsearchReq=[[MKLocalSearchRequest alloc] init];
    localsearchReq.naturalLanguageQuery=_locationSearch.text;
    localsearchReq.region=region;
    MKLocalSearch *localsearch=[[MKLocalSearch alloc] initWithRequest:localsearchReq];
    [localsearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         places=response.mapItems;
         NSLog(@"Places %@",[places description]);
         self.boundingregion=response.boundingRegion;
         NSLog(@"region lati= %f long= %f",self.boundingregion.center.latitude,self.boundingregion.center.longitude);
         [_tblVw reloadData];
         
    }];

}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"get location");
}

#pragma mark - TABLEVIEW

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [places count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    MKMapItem *mapitem=[places objectAtIndex:indexPath.row];
    cell.textLabel.text=mapitem.name;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSIndexPath *selectedRow=tableView.indexPathForSelectedRow;
    [self performSegueWithIdentifier:@"displaylocationID" sender:nil];
}

#pragma mark Searchbar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                      // return NO to not become first responder
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                    // called when text starts editing
{
    [searchBar setShowsCancelButton:YES animated:YES];
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar                        // return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{
    [searchBar setShowsCancelButton:NO animated:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    if (places.count != 0) {
        
        // Set the list of places to be empty.
        places = @[];
        // Reload the tableview.
        [_tblVw reloadData];
 
    }

}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0) // called before text changes
{
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [self startSearch:searchBar.text];

}
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED // called when bookmark button pressed
{
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED   // called when cancel button pressed
{
    [searchBar setShowsCancelButton:NO animated:NO];
    searchBar.text=@"";
    [searchBar resignFirstResponder];
}
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2) __TVOS_PROHIBITED // called when search results button pressed
{

}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0)
{

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"displaylocationID"])
    {
        obj=[segue destinationViewController];
        obj.selectedInd=[_tblVw indexPathForSelectedRow];
        NSIndexPath *iPath=[_tblVw indexPathForSelectedRow];
        MKMapItem *mapitem=[places objectAtIndex:iPath.row];
        MKCoordinateRegion region=self.boundingregion;
        region.center=mapitem.placemark.coordinate;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.015;
        span.longitudeDelta = 0.015;
        region.span = span;
        
        obj.mapboundray=region;
        obj.placesArr=self.places;
        
        
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
