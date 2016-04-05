//
//  iOSViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface iOSViewController ()

@end

@implementation iOSViewController
@synthesize model;

- (void)viewWillAppear:(BOOL)animated {
    
    // Make navigation bar disappeared
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    //    [super viewWillAppear:animated];
    
    self.model->updateMdl();
    
    //-------------------
    // Hide all panels
    //-------------------
    [self hideAllPanels];
    
    //-------------------
    // Build a toolboar for a specific mode
    //-------------------
    if ([self.UIConfigurations[@"UIToolbarNeedsUpdate"]
         boolValue]){
        
        self.mapView.layer.borderWidth
        = 0.0f;
        self.mapView.layer.borderColor =
        [UIColor clearColor].CGColor;
        
        if ([self.UIConfigurations[@"UIToolbarMode"]
             isEqualToString:@"Development"])
        {
            [self constructDebugToolbar: @"Portrait"];
        }else if ([self.UIConfigurations[@"UIToolbarMode"]
                   isEqualToString:@"Demo"])
        {
            //-------------
            // A blue border will be shown in the demo mode
            //-------------
            self.mapView.layer.borderColor =
            [UIColor blueColor].CGColor;
            self.mapView.layer.borderWidth
            = 2.0f;
            [self constructDemoToolbar: @"Portrait"];
        }else if ([self.UIConfigurations[@"UIToolbarMode"]
                   isEqualToString:@"Study"])
        {
            [self constructStudyToolbar: @"Portrait"];
        }else if ([self.UIConfigurations[@"UIToolbarMode"]
                   isEqualToString:@"Authoring"])
        {
            //-------------
            // A magentaColor border will be shown in the authoring mode
            //-------------
            self.mapView.layer.borderColor =
            [UIColor magentaColor].CGColor;
            self.mapView.layer.borderWidth
            = 2.0f;
        }
        
        self.UIConfigurations[@"UIToolbarNeedsUpdate"]
        = [NSNumber numberWithBool:false];
    }
    
    
    if (self.needUpdateGmapMarkers) {
        [self resetGmapMarkers];
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
        if (self.testManager->testManagerMode ==
            OFF)
        {
            //--------------
            // Call displaySnapshot directly when testManager is OFF
            //--------------
            [self displaySnapshot:self.snapshot_id_toshow
                withStudySettings:OFF];

            [self updateGMapBasedOnAMap];
        }else{
            //--------------
            // During the study, need to call showTestNumber to
            // log some extra data and start a new test.
            // This is very important!
            //--------------
            self.testManager->showTestNumber(self.snapshot_id_toshow);
        }
        self.needUpdateAnnotations = true;
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
    // Unwind actions
    //---------------
    if (self.needUpdateAnnotations){
        self.needUpdateAnnotations = false;
        
        [self resetAnnotations];
        //        [self updateDataAnnotations];
    }
    
    //---------------
    // Goto the selected location
    //---------------
    if (self.landmark_id_toshow >= 0){
        
        if (self.model->data_array.size() >0){
            int lid = self.landmark_id_toshow;
            MKCoordinateRegion temp = MKCoordinateRegionMake
            (CLLocationCoordinate2DMake(self.model->data_array[lid].latitude, self.model->data_array[lid].longitude),self.mapView.region.span);
            
            [self updateMapDisplayRegion: temp withAnimation:NO];
        }
        self.landmark_id_toshow = -1;
    }
        
    [self.glkView setNeedsDisplay];
}

-(void)viewDidLayoutSubviews{
    //-------------------
    // Configure a small view (experimental)
    //-------------------
    if ([self.UIConfigurations[@"UIToolbarMode"]
         isEqualToString:@"Web"]){
        
        [self.mapView setFrame:
         CGRectMake(0, 0,
                    200, 200)];
        
        NSLog(@"done!");
    }
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
        //#ifdef __IPHONE__
        if ([self.UIConfigurations[@"UIToolbarMode"]
             isEqualToString: @"Development"])
            [self constructDebugToolbar:@"Landscape"];
    }else if(orientation == UIDeviceOrientationPortrait){
        if ([self.UIConfigurations[@"UIToolbarMode"]
             isEqualToString: @"Development"])
            [self constructDebugToolbar:@"Portrait"];
        //#endif
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


//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    MKCoordinateRegion temp;
    
    if (self.model->data_array.size()>0){
        temp = MKCoordinateRegionMake
        (CLLocationCoordinate2DMake(self.model->data_array[0].latitude, self.model->data_array[0].longitude),MKCoordinateSpanMake(0.01, 0.01));
        NSLog(@"%f", self.model->data_array[0].longitude);
        NSLog(@"%f", self.model->data_array[0].latitude);
    }else{
        // Manhattan as the default location
        temp = MKCoordinateRegionMake
        (CLLocationCoordinate2DMake(40.705773, -74.002159),
         MKCoordinateSpanMake(0.01, 0.01));
    }
    [self updateMapDisplayRegion: temp withAnimation:NO];
    
    // Provide the centroid of compass to the model
    [self moveCompassCentroidToOpenGLPoint:self.renderer->compass_centroid];
    
    // Add pin annotations
    [self resetAnnotations];
    
    // Set the conventional compass to be invisible
    self.conventionalCompassVisible = false;
    
}

- (GMSMapView *) createGmap {
    GMSMapView *mapView_;
    if (self.model->data_array.size()>0) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.model->data_array[0].latitude longitude:self.model->data_array[0].longitude zoom:15];
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        mapView_.myLocationEnabled = YES;
        
        GMSMarker *marker = [[GMSMarker alloc]init];
        marker.position = CLLocationCoordinate2DMake(self.model->data_array[0].latitude, self.model->data_array[0].longitude);
        marker.map = mapView_;
    }
    return mapView_;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end