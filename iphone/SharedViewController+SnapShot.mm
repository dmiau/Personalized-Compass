//
//  SharedViewController+SnapShot.m
//  Compass[transparent]
//
//  Created by dmiau on 7/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#import "xmlParser.h"

#ifdef __IPHONE__
//-------------------
// iOS
//-------------------
#import "iOSViewController.h"
@implementation iOSViewController (SnapShot)

#else

//-------------------
// Desktop (osx)
//-------------------
#import "OSXPinAnnotationView.h"
#import "DesktopViewController.h"
@implementation DesktopViewController (SnapShot)
#endif

//------------------
// displaySnapshot loads and displays a snapshot
// when setup_viz_flag is on, the visualization settings
// at the time when the snap was taken will be loaded too
//------------------
- (bool)displaySnapshot: (int) snapshot_id
      withStudySettings: (TestManagerMode) mode
{

    if (mode != OFF){
        self.testManager->test_counter = snapshot_id;
    }
    
    //-----------
    // Set up snapshot parameters
    //-----------
    snapshot mySnapshot = self.model->snapshot_array[snapshot_id];
    

    // Do not reload the location if it is already loaded
    if (![mySnapshot.kmlFilename isEqualToString: self.model->location_filename]){
        self.model->location_filename = mySnapshot.kmlFilename;
        readLocationKml(self.model, self.model->location_filename);
    }
    
    // indicates which annotation should be added
    vector<int> annotation_id_vector;
    if (mySnapshot.selected_ids.size() == 0){
        // If no landmarks are specified, let the model to decide which
        // landmark to show (use the K_ORIENTATIONS method)
        
        self.model->configurations[@"filter_type"] = @"K_ORIENTATIONS";
    }else{
        //-----------------
        // Reload landmark selection status
        //-----------------
        for (int i = 0; i < self.model->data_array.size(); ++i){
            self.model->data_array[i].isEnabled = false;
        }
        
        // Need to configure the answer status
        for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
            int data_id = mySnapshot.selected_ids[i];
            if (data_id >= self.model->data_array.size()){
                [self displayPopupMessage:[NSString stringWithFormat:
                                           @"Data ID: %d does not exist in %@",
                                           data_id, self.model->location_filename]];
                return false;
            }else{
                self.model->data_array[data_id].isEnabled = true;
                if (mySnapshot.is_answer_list[i] == 0){
                    self.model->data_array[data_id].isAnswer = false;
                    // indicates which annotation should be added
                    annotation_id_vector.push_back(data_id);
                }else{
                    self.model->data_array[data_id].isAnswer = true;
                }
            }
        }
        
        self.model->configurations[@"filter_type"] = @"MANUAL";
    }

    self.UIConfigurations
    [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:NO];

#ifndef __IPHONE__
    // Clean up custom callout
    for (id<MKAnnotation> annotation in
         self.mapView.annotations)
    {
        OSXPinAnnotationView* pinView =
        (OSXPinAnnotationView*)
        [self.mapView
         viewForAnnotation: annotation];
        pinView.canShowCallout = NO;
        [pinView showCustomCallout:NO];

    }
#endif
    
    //-----------
    // Label configuration (for the study only)
    //-----------
    if (mode != OFF)
    {
        NSArray* label_array;
        
        // Depending on the task type, labels will be different
        if (([mySnapshot.name rangeOfString:toNSString(LOCATE)].location != NSNotFound)
            ||([mySnapshot.name rangeOfString:toNSString(DISTANCE)].location != NSNotFound))
        {
            label_array = @[@"[i]Subway"];
        }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound)
        {
            label_array = @[@"Hotel", @"Train St."];
            self.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:YES];
        }else if ([mySnapshot.name rangeOfString:toNSString(ORIENT)].location != NSNotFound){
            label_array = @[@"[i]Subway"];
        }else if ([mySnapshot.name rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound){
            label_array = @[@"[i]Subway", @"Coffee"];
            self.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:YES];
        }
        
        
        for (int i = 0; i < mySnapshot.selected_ids.size(); ++i){
            int data_id = mySnapshot.selected_ids[i];

            if (mySnapshot.is_answer_list[i] == 0){
                self.model->data_array[data_id].my_texture_info =
                self.model->generateTextureInfo(label_array[i]);
                self.model->data_array[data_id].annotation.title = label_array[i];
            }else{
                self.model->data_array[data_id].my_texture_info =
                self.model->generateTextureInfo(label_array[i]);
                self.model->data_array[data_id].annotation.title = label_array[i];                
            }
        }
    }
    
    //-----------
    // Annotation configurations (for desktop only)
    //-----------
#ifndef __IPHONE__
    if (mode == OSXSTUDY){
        [self.mapView removeAnnotations:
         self.mapView.annotations];
        
        for (int i = 0; i < annotation_id_vector.size(); ++i)
        {
            int data_id = annotation_id_vector[i];
            [self.mapView addAnnotation:
             self.model->data_array[data_id].annotation];
        }
    }
#endif
//    NSLog(@"SnapShot");
//    NSLog(@"Center:");
//    NSLog(@"latitude: %f, longitude: %f", mySnapshot.coordinateRegion.center.latitude,
//          mySnapshot.coordinateRegion.center.longitude);
//    NSLog(@"latitudeSpan: %f, longitudeSpan: %f", mySnapshot.coordinateRegion.span.latitudeDelta,
//          mySnapshot.coordinateRegion.span.longitudeDelta);
    
    
    self.mapView.camera.heading = -mySnapshot.orientation;
    
#ifdef __IPHONE__
    [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
#else
    if (mySnapshot.osx_coordinateRegion.span.latitudeDelta > 0){
        // Display the desktop of osx_coordinateRegion if the desktop version
        // is available.
        [self updateMapDisplayRegion:mySnapshot.osx_coordinateRegion withAnimation:NO];
    }else{
        [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
    }
#endif

//    NSLog(@"True");
//    NSLog(@"Center:");
//    NSLog(@"latitude: %f, longitude: %f", self.mapView.centerCoordinate.latitude,
//          self.mapView.centerCoordinate.longitude);
//    NSLog(@"latitudeSpan: %f, longitudeSpan: %f", self.mapView.region.span.latitudeDelta,
//          self.mapView.region.span.longitudeDelta);

//    //-----------------
//    // Render annotations (may be too heavy?)
//    //-----------------
//    if (mode == OFF)
//        [self resetAnnotations];
//    else
//        [self changeAnnotationDisplayMode:@"Study"];
    
    //-----------------
    // Set up viz and device
    //-----------------
    if (mode == DEVICESTUDY){
#ifdef __IPHONE__
        //--------------------
        // Phone (iOS)
        //--------------------        
        [self setupVisualization:mySnapshot.visualizationType];
        [self lockCompassRefToScreenCenter:YES];
        self.renderer->isInteractiveLineVisible=false;
        [self enableMapInteraction:NO];


        // Cross is off in watch+compass mode
        self.renderer->cross.isVisible = true;
        
        if (self.renderer->watchMode &&
            [self.model->configurations[@"personalized_compass_status"]
            isEqualToString: @"on"])
            self.renderer->cross.isVisible = false;
        
        
        if (self.mapView.isHidden){
            [self.mapView setHidden:NO];
            [self.glkView setHidden:NO];
        }
        
        // Set up differently, depending on the snapshot code
        if (([mySnapshot.name rangeOfString:toNSString(LOCATE)].location != NSNotFound))
        {
            if ([self.socket_status boolValue])
            {
                [self.mapView setHidden:YES];
                [self.glkView setHidden:YES];
            }
            [self toggleScaleView:NO];
        }else if ([mySnapshot.name rangeOfString:toNSString(DISTANCE)].location != NSNotFound)
        {
            [self toggleScaleView:YES];
        }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound)
        {
            
            [self toggleScaleView:NO];
        }else if ([mySnapshot.name rangeOfString:toNSString(ORIENT)].location != NSNotFound){
            
            self.renderer->isInteractiveLineVisible=true;
            self.renderer->isInteractiveLineEnabled=true;
            self.renderer->interactiveLineRadian   = 0;
            [self toggleScaleView:NO];
        }else if ([mySnapshot.name rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound)
        {
            [self toggleScaleView:NO];
        }
        
        //--------------------
        // Check device setup
        //--------------------
        if (mySnapshot.deviceType == WATCH){
            if (!self.renderer->watchMode){
                [self displayPopupMessage:@"Please change to the watch mode."];
            }
        }else{
            if (self.renderer->watchMode){
                [self displayPopupMessage:@"Please change to the phone mode."];
            }
        }
#endif
    }else if (mode == OSXSTUDY){
        //--------------------
        // Desktop (OSX)
        //--------------------
        [self sendMessage:[NSString stringWithFormat:@"%d", snapshot_id]];
            self.renderer->cross.isVisible = false;
        // Set up differently, depending on the snapshot code
        if (([mySnapshot.name rangeOfString:toNSString(LOCATE)].location != NSNotFound))
        {
            [self showLocateCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:toNSString(DISTANCE)].location
                  != NSNotFound)
        {
            
        }else if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound)
        {
            [self showLocalizeCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:toNSString(ORIENT)].location != NSNotFound){
            [self showOrientCollectMode:mySnapshot];
        }else if ([mySnapshot.name rangeOfString:toNSString(LOCATEPLUS)].location != NSNotFound){
            [self showLocalizeCollectMode:mySnapshot];
            self.renderer->cross.isVisible = true;
        }
    }else if (mode == OFF){
        //--------------------
        // Normal mode
        //--------------------
        self.model->configurations[@"wedge_correction_x"]
        = [NSNumber numberWithFloat: 1];
//        [self scaleiOSMapForDesktopMode:mySnapshot];
        [self setupVisualization:mySnapshot.visualizationType];
    }

    self.mapView.camera.heading = -mySnapshot.orientation;
    [self updateLocationVisibility];
    self.model->updateMdl();
    
    if (mode != OFF){
        self.testManager->updateUITestMessage();
    }
    
#ifndef __IPHONE__
    // Desktop
    [self.compassView display];
#else
    // iOS
    [self.glkView setNeedsDisplay];
#endif
    return true;
}

#ifdef __IPHONE__
- (void)toggleScaleView: (bool) state
{
    //---------------
    // Add the scale view
    //---------------
    if (state){
        // Only add if it is NOT a subview
        if (self.renderer->watchMode){
            if (![self.watchScaleView isDescendantOfView:self.glkView])
                [self.glkView addSubview:self.watchScaleView];
        }else{
            if (![self.scaleView isDescendantOfView:self.glkView])
                [self.glkView addSubview:self.scaleView];
        }
    }else{
        //---------------
        // Remove the scale view
        //---------------
        // Only remove if is NOT a subview
        if ([self.watchScaleView isDescendantOfView:self.glkView])
            [self.watchScaleView removeFromSuperview];
        if ([self.scaleView isDescendantOfView:self.glkView])
            [self.scaleView removeFromSuperview];
    }
}
#endif


//----------------------
// Set up the environment to collect the answer for the locate test
//----------------------
- (void)showLocateCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];    
    self.renderer->cross.isVisible = false;
    // Emulate the iOS enironment if on the desktop
    // (if it is in the control mode)
#ifndef __IPHONE__
    [self changeAnnotationDisplayMode:@"None"];
    [self setupVisualization:mySnapshot.visualizationType];
    self.renderer->emulatediOS.is_enabled = true;
    self.renderer->emulatediOS.is_mask_enabled = true;

    switch (mySnapshot.deviceType) {
        case PHONE:
            self.model->configurations[@"wedge_correction_x"]
            = [NSNumber numberWithFloat: 2];
            self.renderer->emulatediOS.changeDeviceType(PHONE);
            break;
        case WATCH:
            self.model->configurations[@"wedge_correction_x"]
            = [NSNumber numberWithFloat: 5.78];
            self.renderer->emulatediOS.changeDeviceType(SQUAREWATCH);
            break;
        default:
            break;
    }
    
    // Scale the map correctly, and shift the eiOS
    [self scaleiOSMapForDesktopMode:mySnapshot];
    [self shiftEmulatorAndMapForLocateCollectMode];
#endif
}

-(void)scaleiOSMapForDesktopMode: (snapshot)mySnapshot{
#ifndef __IPHONE__
    MKCoordinateSpan scaledSpan =
    [self scaleCoordinateSpanForSnapshot:mySnapshot];
    
    MKCoordinateRegion osxCoordRegion = MKCoordinateRegionMake
    (mySnapshot.coordinateRegion.center, scaledSpan);
    [self updateMapDisplayRegion:osxCoordRegion withAnimation:NO];
#endif
}

- (void)shiftEmulatorAndMapForLocateCollectMode{
#ifndef __IPHONE__
    // There could be a bug somewhere.
    // Also need to set up the positions of the em iOS
    // and the compass
    CGPoint shift;
    shift.x = -self.renderer->view_width/2 +
    self.renderer->emulatediOS.width/2;
    shift.y = 0;
    [self shiftTestingEnvironmentBy:shift];
#endif
}

//----------------------
// Set up the environment to collect the answer for the localize test
//----------------------
- (void)showLocalizeCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
#ifndef __IPHONE__
    [self setupVisualization:VIZNONE];
    self.renderer->emulatediOS.is_enabled = FALSE;
    self.renderer->emulatediOS.is_mask_enabled = FALSE;
    
    // Need to display the region correctly
    [self changeAnnotationDisplayMode:@"Study"];
    if (mySnapshot.osx_coordinateRegion.span.latitudeDelta > 0){
        [self updateMapDisplayRegion:mySnapshot.osx_coordinateRegion withAnimation:NO];
    }else{
        [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
    }

    // Need to display the pins correctly
    // All pins should be displayed in this case

#endif
}

//----------------------
// Set up the environment to collect the answer for the locate plus test
//----------------------
- (void)showLocatePlusCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
}

//----------------------
// Set up the environment to collect the answer for the orient test
//----------------------
- (void)showOrientCollectMode: (snapshot) mySnapshot{
    [self enableMapInteraction:NO];
#ifndef __IPHONE__
    [self setupVisualization:VIZNONE];
    self.renderer->emulatediOS.is_enabled = FALSE;
    self.renderer->emulatediOS.is_mask_enabled = FALSE;
    
    // Need to display the region correctly
    [self changeAnnotationDisplayMode:@"None"];
    [self updateMapDisplayRegion:mySnapshot.coordinateRegion withAnimation:NO];
#endif
}

//----------------------
// Set up visualization
//----------------------
- (void)setupVisualization: (VisualizationType) visualizationType{
    switch(visualizationType)
    {
        case VIZPCOMPASS:
            // Turn off the personalized compass and the conventional compass
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self setFactoryCompassHidden:YES];
            
            // Turn off the wedge
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        case VIZWEDGE:
            // Turn off the personalized compass and the conventional compass
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self setFactoryCompassHidden:YES];
            
            // Turn off the wedge
            self.model->configurations[@"wedge_status"] = @"on";
            
            
            if (!self.renderer->watchMode){
                self.model->configurations[@"wedge_style"] = @"modified-orthographic";
            }else{
                self.model->configurations[@"wedge_style"] = @"modified-perspective";
            }
            break;
        case VIZOVERVIEW:
            // Do nothing
            break;
        case VIZNONE:
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self setFactoryCompassHidden:YES];
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        default:
            cout << "Default" <<endl;
    }
}
@end
