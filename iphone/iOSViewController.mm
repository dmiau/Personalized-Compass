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
//    [super viewWillAppear:animated];
    
    self.model->updateMdl();
    
    //-------------------
    // Hide all panels
    //-------------------
    [self hideAllPanels];
    
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
        [self updateMapDisplayRegion:YES];
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
        [self updateMapDisplayRegion:NO];
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
    [self updateMapDisplayRegion:YES];
    
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

@end