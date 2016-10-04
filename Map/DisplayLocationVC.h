//
//  DisplayLocationVC.h
//  Map
//
//  Created by C N Soft Net on 03/10/16.
//  Copyright © 2016 C N Soft Net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DisplayLocationVC : UIViewController <MKMapViewDelegate,UISearchBarDelegate>



@property (nonatomic,assign) MKCoordinateRegion mapboundray;
@property (atomic,copy) NSIndexPath *selectedInd;
@property (nonatomic,strong) NSArray *placesArr;
@property (nonatomic, weak) id <MKMapViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UISearchBar *destinationSearchbar;

@property (strong, nonatomic) IBOutlet MKMapView *mapVw;

@end
