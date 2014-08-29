//
//  OSXPinAnnotationView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "OSXPinAnnotationView.h"

@implementation CalloutViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBund
{
    self = [super initWithNibName:nibName bundle:nibBund];
    [self loadView];
    self.model = compassMdl::shareCompassMdl();
    return self;
}


- (IBAction)dismissDialog:(id)sender {
}

- (IBAction)addLocation:(id)sender {
}

- (IBAction)removeLocation:(id)sender {
}

- (IBAction)toggleEnable:(id)sender {
    if (self.annotation.point_type == landmark){
        int i = self.annotation.data_id;
        self.model->data_array[i].isEnabled =
        !self.model->data_array[i].isEnabled;
        
        // Update the pin color
//        self.rootViewController.needUpdateAnnotations = YES;
    }
}

- (IBAction)doneEditing:(id)sender {
}
@end

@implementation OSXPinAnnotationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        calloutViewController =
        [[CalloutViewController alloc]
         initWithNibName:@"OSXCalloutView" bundle:nil];
        calloutViewController.annotation = self.annotation;
 
        //------------------------
        // Set up the detail view
        //------------------------
        CALayer *viewLayer = [CALayer layer];
        [viewLayer setBackgroundColor:CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1)]; //RGB plus Alpha Channel
        [calloutViewController.detailView setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
        [calloutViewController.detailView setLayer:viewLayer];
        
        CGRect orig_frame = calloutViewController.detailView.frame;
        calloutViewController.detailView.frame =
        CGRectMake(0, -orig_frame.size.height,
                   orig_frame.size.width, orig_frame.size.height);
        
        detailViewVisible = false;
    }
    return self;
}

-(void)showCustomCallout:(bool)status{
    if (status) {
        [calloutViewController.landmark_name
         setStringValue: [self.annotation title]];

        [self addSubview:calloutViewController.view];
    }else{
        //Remove your custom view...
        [calloutViewController.view removeFromSuperview];
    }
}

//---------------
// showDetailCallout toggles detail view
//---------------
-(void)showDetailCallout:(bool)status{
    [self showCustomCallout:NO];
    
    if (status) {
        [self addSubview:calloutViewController.detailView];
        
                detailViewVisible = true;
    }else{
        //Remove your custom view...
                detailViewVisible = false;
        [calloutViewController.detailView removeFromSuperview];
    }
}

// http://stackoverflow.com/questions/9064348/mkannotationview-with-uibutton-as-subview-button-dont-respond
- (NSView*)hitTest:(NSPoint)aPoint{
    if (detailViewVisible){
//        NSLog(@"Origin: %@", NSStringFromPoint(calloutViewController.detailView.superview.frame.origin));
        CGPoint origin = calloutViewController.detailView.superview.frame.origin;
        CGPoint bPoint;
        bPoint.x = aPoint.x - origin.x;
        bPoint.y = aPoint.y - origin.y;
//        NSView *aView = [calloutViewController.detailView
//                         hitTest:  bPoint];
        return [calloutViewController.detailView hitTest:bPoint];
    }else{
        return [super hitTest:aPoint];
    }
}

@end
