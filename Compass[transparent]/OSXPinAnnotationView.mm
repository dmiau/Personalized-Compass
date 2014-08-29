//
//  OSXPinAnnotationView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "OSXPinAnnotationView.h"

//-----------------------------
// CalloutViewController
//-----------------------------
@implementation CalloutViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBund
           annotation: (CustomPointAnnotation*) annotation
{
    self = [super initWithNibName:nibName bundle:nibBund];
    [self loadView];
    self.model = compassMdl::shareCompassMdl();
    self.annotation = annotation;

    //------------------
    
    // Do any additional setup after loading the view.
    self.titleTextField.stringValue = self.annotation.title;
    self.noteTextField.stringValue = self.annotation.notes;
    self.addressView.stringValue = self.annotation.subtitle;

    NSString *address;
    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:[self.annotation coordinate].latitude
                            longitude:[self.annotation coordinate].longitude];

    if ([self.addressView.stringValue isEqualToString:@""]){
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(placemarks && placemarks.count > 0)
             {
                 CLPlacemark *placemark= [placemarks objectAtIndex:0];
                 //address is NSString variable that declare in .h file.
                 NSString* address =
                 [NSString stringWithFormat:@"%@ %@ , %@ , %@",
                  [placemark subThoroughfare],
                  [placemark thoroughfare],[placemark locality],[placemark administrativeArea]];
                 NSLog(@"New Address Is:%@",address);
                 self.addressView.stringValue = address;
             }
         }];
    }

    //-------------
    // Configure the add and remove buttons
    //-------------
    if (self.annotation.point_type != landmark){
        self.addButton.enabled = YES;
    }else{
        self.addButton.enabled = NO;
        self.removeButton.enabled = YES;
    }

    //-------------
    // Configure the enable/disable status
    //-------------
    if (self.annotation.point_type == landmark){
        int i = self.annotation.data_id;
        if (self.model->data_array[i].isEnabled)
            self.statusSegmentControl.selectedSegment = 0;
        else
            self.statusSegmentControl.selectedSegment = 1;
    }else{
        self.statusSegmentControl.enabled = false;
    }
    
    return self;
}


- (void) awakeFromNib{
    

    
    
//    //-------------------
//    // Set the rootViewController
//    //-------------------
//    AppDelegate *app = [[UIApplication sharedApplication] delegate];
//    
//    UINavigationController *myNavigationController =
//    app.window.rootViewController;
//    
//    self.rootViewController =
//    [myNavigationController.viewControllers objectAtIndex:0];
    
    
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


//-----------------------------
// OSXPinAnnotationView
//-----------------------------
@implementation OSXPinAnnotationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customCalloutStatus = false;
        
        //------------------------
        // Initialize the view controller
        //------------------------
        calloutViewController =
        [[CalloutViewController alloc]
         initWithNibName:@"OSXCalloutView" bundle:nil
         annotation:self.annotation];
        
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
    self.customCalloutStatus = status;
}

//---------------
// showDetailCallout toggles detail view
//---------------
-(void)showDetailCallout:(bool)status{
//    [self showCustomCallout:NO];
    
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
