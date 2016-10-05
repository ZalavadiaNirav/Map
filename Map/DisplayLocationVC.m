//
//  DisplayLocationVC.m
//  Map
//
//  Created by C N Soft Net on 03/10/16.
//  Copyright © 2016 C N Soft Net. All rights reserved.
//

#import "DisplayLocationVC.h"
#import "pinview.h"

@interface DisplayLocationVC () 
{
    NSArray *searchArr;
    MKMapItem *itm1,*itm2;
}

@property (nonatomic , strong) pinview *objpin;
//@property (nonatomic ,retain) NSArray *routeCoordinates;
@end

@implementation DisplayLocationVC

@synthesize placesArr,selectedInd,mapboundray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationItem setHidesBackButton:NO animated:YES];
//    self.navigationItem.backBarButtonItem.title=@"Located";
//    self.navigationItem.title=@"Located Here";
    
    self.mapVw.delegate=self;
    [self.mapVw setRegion:mapboundray animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    _destinationSearchbar.delegate=self;

    //first annotation (previous searchbar)
    
     self.objpin=[[pinview alloc] init];

    itm1=[placesArr objectAtIndex:selectedInd.row];
    self.objpin.title=[itm1 name];
    self.objpin.coordinate=itm1.placemark.location.coordinate;
    NSLog(@"coordinate %f %f",itm1.placemark.location.coordinate.latitude,itm1.placemark.location.coordinate.longitude);
    self.objpin.url=[itm1 url];
    
    [self.mapVw addAnnotation:self.objpin];
    [self.mapVw selectAnnotation:[self.mapVw.annotations objectAtIndex:0] animated:YES];
    
    
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{

    NSLog(@"added pin");
}

#pragma mark - Searchbar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                      // return NO to not become first responder
{
    [searchBar setShowsCancelButton:YES];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                   // called when text starts editing
{

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO];

    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    [searchBar setClearsContextBeforeDrawing:YES];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0) // called before text changes
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                    // called when keyboard search button pressed
{
    [searchBar resignFirstResponder];
    if(searchBar.text)
    {
        NSString *location =searchBar.text;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:location
                     completionHandler:^(NSArray* placemarks, NSError* error){
                         
                         if (placemarks.count > 0)
                         {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             MKCoordinateRegion region = self.mapVw.region;
                             [self.mapVw setRegion:region animated:YES];
                            [self.mapVw selectAnnotation:[self.mapVw.annotations objectAtIndex:0] animated:YES];
                             
                             
                             
                             
                             
                             CLLocationCoordinate2D sourceCoordinate;
                             sourceCoordinate.latitude = _objpin.coordinate.latitude;
                             sourceCoordinate.longitude = _objpin.coordinate.longitude;
                             
                             CLLocationCoordinate2D destinationCoordinate;
                             destinationCoordinate.latitude=placemark.location.coordinate.latitude;
                             destinationCoordinate.longitude=placemark.location.coordinate.longitude;
                             
                             /*
                             int Coordinates=2;
                             CLLocationCoordinate2D *coordinateArray=malloc(Coordinates * sizeof(CLLocationCoordinate2D));
                             coordinateArray[0]=firstCoords;
                             coordinateArray[1] = secondCoords;
                             NSLog(@"first %f second %f",coordinateArray[0].longitude,coordinateArray[0].latitude);
                           */
                             
                             
                         // This Direction code not work for India ... Apple Not provide this facility In India
                         // Below code show path for getting to destination
                             
                             MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:sourceCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
                             MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:source];
                             
                             MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
                             MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
                             
                             
                             MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
                             [request setSource:sourceMapItem];
                             [request setDestination:distMapItem];
                             [request setTransportType:MKDirectionsTransportTypeAutomobile];
                             
                             MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
                             
                             [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                                 
                                 if (!error) {
                                     for (MKRoute *route in [response routes])
                                     {
                                         [self.mapVw addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
                                         
                                         // this will return lat - long between two notation
                                         NSUInteger pointCount = route.polyline.pointCount;
                                         //allocate a C array to hold this many points/coordinates...
                                         CLLocationCoordinate2D *routeCoordinates= malloc(pointCount * sizeof(CLLocationCoordinate2D));
                                         
                                         //get the coordinates (all of them)...
                                         [route.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];
                                         
                                         //this part just shows how to use the results...
                                         NSLog(@"route pointCount = %lu", (unsigned long)pointCount);
                                         for (int c=0; c < pointCount; c++)
                                         {
                                             NSLog(@"routeCoordinates[%d] = %f, %f", 
                                                   c, routeCoordinates[c].latitude, routeCoordinates[c].longitude);
                                         }
                                         
                                         //free the memory used by the C array when done with it...
                                         free(routeCoordinates);
                                     }
                                 }
                                 else
                                     NSLog(@"Error to get direction %@",[error description]);
                                 
                             }];
                            
                             /*
                              
                            //  Draw Polyline between two point
                              
                             MKPolyline *routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:Coordinates] ;
                             [self.mapVw addOverlay:routeLine];
                             [self.mapVw addAnnotation:placemark];
                             free(coordinateArray);

//                             [self.mapVw setVisibleMapRect:[routeLine boundingMapRect]];
                             */
        

                             
                        }
                         else
                         {
                             NSLog(@"It is invalid Destination");
                             [searchBar becomeFirstResponder];
                         }
                     }
         ];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED // called when bookmark button pressed
{

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED   // called when cancel button pressed
{
    
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2) __TVOS_PROHIBITED // called when search results button pressed
{

}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0)
{

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
