//
//  CustomPointAnnotation.h
//  Compass[transparent]
//
//  Created by dmiau on 7/6/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

enum location_enum {
    landmark,
    dropped,
    search_result,
    heading
};

@interface CustomPointAnnotation : MKPointAnnotation

@property enum location_enum point_type;
@property int data_id;
@property NSString* address;
@property NSString* notes;
@end
