//
//  ViewController.h
//  Map
//
//  Created by C N Soft Net on 30/09/16.
//  Copyright © 2016 C N Soft Net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <UISearchBarDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *locationSearch;
@property (strong, nonatomic) IBOutlet UITableView *tblVw;

@property (nonatomic,strong)NSArray *places;


-(void)startSearch:(NSString *)searchLocation;


@end

