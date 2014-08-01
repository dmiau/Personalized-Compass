//
//  iOSViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController ()

@end

@implementation iOSViewController
@synthesize model;

- (void)viewWillAppear:(BOOL)animated {
    
    // Make navigation bar disappeared
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    self.model->updateMdl();
    
    
    //-------------------
    // Build a toolboar
    //-------------------
    
    if ([self.UIConfigurations[@"UIToolbarNeedsUpdate"]
         boolValue]){
        
        if ([self.UIConfigurations[@"UIToolbarMode"]
             isEqualToString:@"Development"]){
            [self constructDebugToolbar: @"Portrait"];
        }else if ([self.UIConfigurations[@"UIToolbarMode"]
                   isEqualToString:@"Demo"]){
            [self constructDemoToolbar: @"Portrait"];
        }
        self.UIConfigurations[@"UIToolbarNeedsUpdate"]
        = [NSNumber numberWithBool:false];
    }
    //---------------
    // Unwind actions
    //---------------
    // There is a bug here. There seems to be an extra shift component.
    if (self.needUpdateDisplayRegion){
        [self updateMapDisplayRegion];
        self.needUpdateDisplayRegion = false;
    }
    
    
    if (self.needUpdateAnnotations){
        self.needUpdateAnnotations = false;

        [self renderAnnotations];
    }
    
    // This may be an iPad only thing
    // (dismissing the modal dialog)
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if ([self needToggleLocationService]){
        [self toggleLocationService:1];
        self.needToggleLocationService = false;
    }
    
    //---------------
    // Snapshot and history stuff
    //---------------
    if (self.snapshot_id_toshow >= 0){
        [self displaySnapshot:self.snapshot_id_toshow];
        self.snapshot_id_toshow = -1;
    }

    if (self.breadcrumb_id_toshow >= 0){
        [self displayBreadcrumb];
        breadcrumb myBreadcrumb =
        self.model->breadcrumb_array[self.breadcrumb_id_toshow];
        
        [self.mapView setCenterCoordinate:myBreadcrumb.coord2D animated:YES];
        self.breadcrumb_id_toshow = -1;
    }
    
    //---------------
    // Goto the selected location
    //---------------
    if (self.landmark_id_toshow >= 0){
        int id = self.landmark_id_toshow;
        self.model->camera_pos.latitude =
        self.model->data_array[id].latitude;
        self.model->camera_pos.longitude =
        self.model->data_array[id].longitude;
        self.landmark_id_toshow = -1;
        [self updateMapDisplayRegion];
    }
    
    [self.glkView setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark -------Interface rotation stuff------

- (void) didInterfaceRotate:(NSNotification *)notification
{

    // Only need to proceed if the rotation lock is off
    if ([self.UIConfigurations[@"UIRotationLock"] boolValue]){
        return;
    }
    
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    double width = self.glkView.frame.size.width;
    double height = self.glkView.frame.size.height;

    // Update the viewport
    
    // This line is important.
    // In order to maintain 1-1 OpenGL and screen pixel mapping,
    // the following line is necessary!
    self.renderer->initRenderView(width, height);
    self.renderer->updateViewport(0, 0, width, height);
    
    // Update the frames of views
    // iphone's screen size: 568x320
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSMutableArray* toolbar_items =
    [NSMutableArray arrayWithArray:self.toolbar.items];
    
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight)
    {
        screenWidth = screenRect.size.height;
        screenHeight = screenRect.size.width;
        
#ifdef __IPHONE__
        [self constructDebugToolbar:@"Landscape"];
    }else if(orientation == UIDeviceOrientationPortrait){
                [self constructDebugToolbar:@"Portrait"];
#endif
    }

    for (int i = 0; i < [view_array count]; ++i){
        UIView *aView = view_array[i];
        double view_width = view_size_vector[i].width;
        double view_height = view_size_vector[i].height;
        aView.frame = CGRectMake(0, screenHeight - 44 - view_height,
                                 view_width, view_height);
    }
    
    [self.glkView setNeedsDisplay];
}



- (void) doSingleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:1];
    NSLog(@"Single tap!");
}

- (void) doDoubleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:2];
    
    if([self.model->configurations[@"UIBreadcrumbDisplay"] boolValue]){
        [self.mapView removeOverlays: self.mapView.overlays];
        [self displayBreadcrumb];
    }
    NSLog(@"Double tap!");
}


//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    [self updateMapDisplayRegion];
    
    // Provide the centroid of compass to the model
    [self updateModelCompassCenterXY];

    // Add pin annotations
    [self renderAnnotations];
    
    // Set the conventional compass to be invisible
    self.conventionalCompassVisible = false;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self.mapView];
    NSLog(@"****Touch detected");
    NSLog(@"Display Coordinates: %@", NSStringFromCGPoint(pos));
    
    // Convert it to the real coordinate
    CLLocationCoordinate2D myCoord = [self.mapView convertPoint:pos toCoordinateFromView:self.mapView];
    NSLog(@"Map latitude: %f, longitude: %f", myCoord.latitude, myCoord.longitude);
    
    // pass touch event to super
    [super touchesBegan:touches withEvent:event];
    
    
    
    //------------------
    // Perform hitTest to dismiss dialogs
    //------------------
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    
    for (UIView* aView in dialog_array){

        UIView* hitView = [aView
                   hitTest:[touch locationInView:aView]
                   withEvent:event];
        if ([aView isHidden] == NO &&
            hitView == nil){
            [aView setHidden:YES];
        }
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    static bool compassTouched = false;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
    
    if (compassTouched){
        //-------------------------
        // When the compass is pressed,
        // enter here to continuously update the compass's position
        //-------------------------
        
        // update compass location
        recVec compassXY = self.renderer->compass_centroid;
        compassXY.x = touchPoint.x - self.glkView.frame.size.width/2;
        compassXY.y = self.glkView.frame.size.height/2 - touchPoint.y;
        
        self.model->configurations[@"compass_centroid"][0] =
        [NSNumber numberWithInt:compassXY.x];
        self.model->configurations[@"compass_centroid"][1] =
        [NSNumber numberWithInt:compassXY.y];
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:150];
            compassTouched = false;
        }
        // The order is important
        self.renderer->loadParametersFromModelConfiguration();
        [self updateModelCompassCenterXY];
        [self.glkView setNeedsDisplay];
        return;
    }else if (gestureRecognizer.state != UIGestureRecognizerStateBegan){
        //----------------
        // Do nothing is the compress is not pressed
        // and the recognition mode is not begin
        //----------------
        return;
    }

    //----------------------------
    // Do nothing when the creation mode is off
    //----------------------------
    if (![self.UIConfigurations[@"UIAcceptsPinCreation"] boolValue])
        return;
    
    //--------------------
    // Move the compass
    //--------------------
    recVec compassXY = self.renderer->compass_centroid;
    compassXY.x = compassXY.x + self.glkView.frame.size.width/2;
    compassXY.y = self.glkView.frame.size.height/2 - compassXY.y;
    double dist = sqrt(pow((touchPoint.x - compassXY.x), 2) +
                       pow((touchPoint.y - compassXY.y), 2));
    double radius = self.renderer->half_canvas_size
    * [self.model->configurations[@"outer_disk_ratio"] floatValue]
    * [self.model->configurations[@"compass_scale"] floatValue];
    if (dist <= radius)
    {
        compassTouched = true;
        model->configurations[@"disk_color"][3] = [NSNumber numberWithInt:255];
        [self.glkView setNeedsDisplay];
        return;
    };
    
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    CustomPointAnnotation *pa = [[CustomPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Dropped Pin";
    pa.point_type = dropped;
    
    if (self.sprinkleBreadCrumbMode){
        [self addBreadcrumb:touchMapCoordinate];
    }
    
    [self.mapView addAnnotation:pa];
}

@end

