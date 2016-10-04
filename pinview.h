//
//  pinview.h
//  Map
//
//  Created by C N Soft Net on 03/10/16.
//  Copyright © 2016 C N Soft Net. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface pinview : NSObject<MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,retain) NSURL *url;

@end
