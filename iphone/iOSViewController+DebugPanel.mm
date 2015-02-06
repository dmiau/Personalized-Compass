//
//  iOSViewController+DebugPanel.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+DebugPanel.h"

@implementation iOSViewController (DebugPanel)

//------------------
// Update the control of the debug pane
//------------------
-(void)updateDebugPanel{
    // Update showPin segment control
    if ([self.UIConfigurations[@"ShowPins"] isEqualToString:@"All"]){
        self.showPinSegmentControl.selectedSegmentIndex = 0;
    }else if ([self.UIConfigurations[@"ShowPins"] isEqualToString:@"Enabled"]){
        self.showPinSegmentControl.selectedSegmentIndex = 1;
    }else if([self.UIConfigurations[@"ShowPins"] isEqualToString:@"Dropped"]){
        self.showPinSegmentControl.selectedSegmentIndex = 2;
    }else if([self.UIConfigurations[@"ShowPins"] isEqualToString:@"None"]){
        self.showPinSegmentControl.selectedSegmentIndex = 3;
    }
    
    // Update pin creation segment control
    if (self.UIConfigurations[@"UIAcceptsPinCreation"]==
        [NSNumber numberWithBool:true])
    {
        self.createPinSegmentControl.selectedSegmentIndex = 0;
    }else{
        self.createPinSegmentControl.selectedSegmentIndex = 1;
    }

    // Update snapshot information text   
    self.snapshotStatusTextView.text =
    [NSString stringWithFormat:@"%@\n %lu",
     [self.model->snapshot_filename lastPathComponent],
     self.model->snapshot_array.size()];
}


- (IBAction)takeSnapshot:(id)sender {
    [self takeSnapshot];
    self.snapshotStatusTextView.text =
    [NSString stringWithFormat:@"%@\n %lu",
     [self.model->snapshot_filename lastPathComponent],
     self.model->snapshot_array.size()];
}

- (IBAction)breadcrumbSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // Hide
            //-----------
            self.sprinkleBreadCrumbMode = false;
            [self.mapView removeOverlays: self.mapView.overlays];
            
            self.model->configurations[@"UIBreadcrumbDisplay"] =
            [NSNumber numberWithBool:false];
            
            break;
        case 1:
            //-----------
            // Show
            //-----------
            self.sprinkleBreadCrumbMode = false;
            self.model->configurations[@"UIBreadcrumbDisplay"] =
            [NSNumber numberWithBool:true];
            [self displayBreadcrumb];
            break;
        case 2:
            //-----------
            // Clear
            //-----------
            self.sprinkleBreadCrumbMode = false;
            [self removeBreadcrumbPins];
            self.model->breadcrumb_array.clear();
            [self.mapView removeOverlays: self.mapView.overlays];
            break;
        case 3:
            //-----------
            // Create
            //-----------
            self.sprinkleBreadCrumbMode = true;
            break;
        default:
            break;
    }
}

- (void) removeBreadcrumbPins{
    NSArray* annotation_array = self.mapView.annotations;
    for (CustomPointAnnotation* annotation in annotation_array){
        if (annotation.point_type == dropped){
            [self.mapView removeAnnotation:annotation];
        }
    }
}

//-----------------
// Pins
//-----------------

- (IBAction)pinSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    [self changeAnnotationDisplayMode:label];
}

- (IBAction)createPinSegmentControl:
(UISegmentedControl*) segmentedControl{
    int idx = [segmentedControl selectedSegmentIndex];
    switch (idx) {
        case 0:
            self.UIConfigurations[@"UIAcceptsPinCreation"]=
            [NSNumber numberWithBool:true];
            break;
        case 1:
            self.UIConfigurations[@"UIAcceptsPinCreation"]=
            [NSNumber numberWithBool:false];
            break;
        case 2:
            NSArray* annotation_array = self.mapView.annotations;
            for (CustomPointAnnotation* annotation in annotation_array){
                if (annotation.point_type == dropped){
                    [self.mapView removeAnnotation:annotation];
                }
            }
            break;
    }
    
    
}

@end
