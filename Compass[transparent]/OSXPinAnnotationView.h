//
//  OSXPinAnnotationView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"
#import "compassModel.h"

@interface CalloutViewController : NSViewController

@property CustomPointAnnotation *annotation;
@property (weak) IBOutlet NSView *detailView;
@property (weak) IBOutlet NSTextField *landmark_name;
@property compassMdl* model;
@property (weak) IBOutlet NSSegmentedControl *statusSegmentControl;


- (IBAction)dismissDialog:(id)sender;
- (IBAction)addLocation:(id)sender;
- (IBAction)removeLocation:(id)sender;
- (IBAction)toggleEnable:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end


@interface OSXPinAnnotationView : MKPinAnnotationView{
    CalloutViewController *calloutViewController;
    bool detailViewVisible;
}

-(void)showCustomCallout:(bool)status;
-(void)showDetailCallout:(bool)status;
@end
