//
//  OSXPinAnnotationView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface OSXPinAnnotationView : MKPinAnnotationView{
    NSViewController *calloutViewController;
}
@end
