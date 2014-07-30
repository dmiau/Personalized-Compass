//
//  iOSViewController+DebugPanel.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/18/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+DebugPanel.h"

@implementation iOSViewController (DebugPanel)

- (IBAction)takeSnapshot:(id)sender {
    [self takeSnapshot];
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
- (IBAction)removeDroppedPins:(id)sender {
    NSArray* annotation_array = self.mapView.annotations;
    for (CustomPointAnnotation* annotation in annotation_array){
        if (annotation.point_type == dropped){
            [self.mapView removeAnnotation:annotation];
        }
    }
}


- (IBAction)pinSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    NSArray* annotation_array = self.mapView.annotations;
    
    if ([label isEqualToString:@"All"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
    }else if ([label isEqualToString:@"Enabled"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            int i = annotation.data_id;
            if (self.model->data_array[i].isEnabled){
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            }else{
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
            }
        }
    }else if ([label isEqualToString:@"Dropped"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            if (annotation.point_type == dropped){
                [[self.mapView viewForAnnotation:annotation] setHidden:NO];
            }else{
                [[self.mapView viewForAnnotation:annotation] setHidden:YES];
            }
        }
    }else if ([label isEqualToString:@"None"]){
        for (CustomPointAnnotation* annotation in annotation_array){
            [[self.mapView viewForAnnotation:annotation] setHidden:YES];
        }
    }
}

@end
