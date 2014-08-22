//
//  OSXPinAnnotationView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface CalloutViewController : NSViewController
@property (weak) IBOutlet NSView *detailView;
@end


@interface OSXPinAnnotationView : MKPinAnnotationView{
    CalloutViewController *calloutViewController;
}

-(void)showCustomCallout:(bool)status;
-(void)showDetailCallout:(bool)status;
@end
