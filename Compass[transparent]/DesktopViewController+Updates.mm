//
//  DesktopViewController+Updates.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Updates.h"
#import "LocationCellView.h"
#include <cmath>

@implementation DesktopViewController (Updates)


- (IBAction)refreshConfigurations:(id)sender {
    
    // [todo] update code can be refactored
    self.model->reloadFiles();
    [self updateMapDisplayRegion];
    [self.locationTableView reloadData];
}

//-----------
// Pooling function
// This function keeps watching latitude, longitude and pitch.
// If there is any change, the function touches the observed variable:
// mapUpdateFlag
//-----------
-(void)vcTimerFired{
    static double pitch_cache = 0.0;
    static MKMapRect visibleMapRect_cache = MKMapRectMake(0, 0, 0, 0);
    
    double epsilon = 0.0000001;
    
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    
    if ( !MKMapRectEqualToRect(visibleMapRect_cache, visibleMapRect)||
        abs((double)(pitch_cache - self.mapView.camera.pitch)) > epsilon)
    {
        visibleMapRect_cache = visibleMapRect;
        pitch_cache = self.mapView.camera.pitch;
        
        self.mapUpdateFlag = [NSNumber numberWithDouble:0.0];
    }
    //    NSLog(@"*****tableCellCache size %lu", (unsigned long)[tableCellCache count]);
}

//---------------
// KVO code to update latitude, longitude, tile, heading, etc.
//---------------
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    // [todo] In the browser mode,
    // updates should not come from map! Need to fix this
    if ([keyPath isEqual:@"mapUpdateFlag"]) {
        
        CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                                  self.model->compassCenterXY
                                                   toCoordinateFromView:self.mapView];
        
        [self feedModelLatitude: compassCtrCoord.latitude
                      longitude: compassCtrCoord.longitude
                        heading: -self.mapView.camera.heading
                           tilt: -self.mapView.camera.pitch];
        
        // To invalidate the mouse-held timer,
        // so we can distinguish hold-to-pan, and hold-to-long-press
        [mouseTimer invalidate];
        mouseTimer = nil;
        
        // Update the screen cordinates corresponding to
        // iOS screen's boundary, if iOSSyncFlag is on
        if (self.iOSSyncFlag){
            for (int i = 0; i < 4; ++i){
                self.renderer->iOSFourCorners[i] =
                [self.mapView convertCoordinate:
                 CLLocationCoordinate2DMake(self.corners4x2.content[i][0],
                                            self.corners4x2.content[i][1])
                                  toPointToView:self.compassView];
            }
        }
    }
}


//---------------
// This function is called when user actions changes
// the location, heading and tilt.
//---------------
- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) heading_deg
                      tilt: (float) tilt_deg
{
    NSString *latlon_str = [NSString stringWithFormat:@"%2.4f, %2.4f",
                            lat_float, lon_float];
    [[self currentCoord] setStringValue: latlon_str];
    
    //[todo] this is too heavy
    self.model->camera_pos.orientation = heading_deg;
    self.model->tilt = tilt_deg;
    
    self.model->camera_pos.latitude = lat_float;
    self.model->camera_pos.longitude = lon_float;
    [self updateLocationVisibility];
    self.model->updateMdl();
    
    // Update distances on the table
    NSScrollView* scrollView = [self.locationTableView enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    //concurrentQueue
    // UI update needs to be on main queue?
    
    //---------------------------
    // Update the location table
    // (Do not need to update if the table is hidden!)
    //---------------------------
    if (!self.landmarkTable.isHidden)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           NSRange range = [self.locationTableView rowsInRect:visibleRect];
                           for (int i = range.location; i < range.location + range.length; ++i){
                               // [todo] This part is ver slow...
                               ((LocationCellView*)[tableCellCache objectAtIndex:i]).infoTextField.stringValue = [NSString stringWithFormat:@"%.2f (m)",self.model->data_array[i].distance];
                           }
                       });
    }
    //        NSLog(@"location: %d, length:  %d", range.location, range.length);
    
    //---------------------------
    // Update the configuraiton controller table
    // (Do not need to update if the table is hidden!)
    //---------------------------
    
    
    
}

- (void) updateMapDisplayRegion{
    // updateMapDisplayRegion syncs parameters from the model to the
    // display map
    
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    static int once = 0;
    if (once==0){
        MKCoordinateRegion region;
        region.center.latitude = self.model->camera_pos.latitude;
        region.center.longitude = self.model->camera_pos.longitude;
        
        region.span.longitudeDelta = self.model->latitudedelta;
        region.span.latitudeDelta = self.model->longitudedelta;
        [self.mapView setRegion:region];
        once = 1;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = self.model->camera_pos.latitude;
    coord.longitude = self.model->camera_pos.longitude;
    [self.mapView setCenterCoordinate:coord animated:YES];
    
//    self.mapView.camera.pitch = -self.model->tilt;
//    self.mapView.camera.heading = -self.model->camera_pos.orientation;
}


//------------------
// This function should be called after the user moves the compass
//------------------
-(bool)updateModelCompassCenterXY{
    self.model->compassCenterXY =
    [self.mapView convertPoint:
     CGPointMake(self.compassView.frame.size.width/2
                 + [self.model->configurations[@"compass_centroid"][0] floatValue],
                 self.compassView.frame.size.height/2
                 + [self.model->configurations[@"compass_centroid"][1] floatValue])
                      fromView:self.compassView];
    return true;
}
//------------------
// Tools
//------------------

-(void) updateLocationVisibility{
    
    CLLocationCoordinate2D orig_coord2d =
    [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width/2,
                                           self.mapView.frame.size.height/2)
          toCoordinateFromView:self.mapView];
    CLLocation* orig_location = [[CLLocation alloc]
                                 initWithLatitude:orig_coord2d.latitude
                                 longitude:orig_coord2d.longitude];
    
    
    double true_radius_dist = self.renderer->getMapWidthInMeters() *
    [self.model->configurations[@"watch_radius"] floatValue] /
    self.mapView.frame.size.width;
    
    for (int i = -1; i < (int)self.model->data_array.size(); ++i){
        
        data *data_ptr;
        if (i == -1 && !self.model->user_pos.isEnabled){
            continue;
        }else if (i == -1 && self.model->user_pos.isEnabled){
            data_ptr = &(self.model->user_pos);
        }else{
            data_ptr = &(self.model->data_array[i]);
        }
        
        CLLocationCoordinate2D coord2d =
        data_ptr->annotation.coordinate;
        
        // Visibility calculation differs
        // when isiOSBoxEnabled is true
        
        //TODO: need to fix watch mode with isiOSBoxEnabled is true
        CGRect myRect;
        if (self.renderer->isiOSBoxEnabled){
            // Get the information from iOSFourCorners
            myRect.origin= self.renderer->iOSFourCorners[0];
            myRect.size.width = self.renderer->iOSFourCorners[1].x -
            self.renderer->iOSFourCorners[0].x;
            myRect.size.height = self.renderer->iOSFourCorners[2].y -
            self.renderer->iOSFourCorners[1].y;
        }else{
            myRect = [self.mapView frame];
        }

        
        if (self.renderer->watchMode){
            
            CLLocation *point_location = [[CLLocation alloc]
                                          initWithLatitude:coord2d.latitude
                                          longitude:coord2d.longitude];
            CLLocationDistance dist = [orig_location distanceFromLocation:point_location];
            
            if (dist <= true_radius_dist)
                data_ptr->isVisible= true;
            else
                data_ptr->isVisible = false;
        }else{
            // testing if someLocation is on rotating mapView
            CGPoint screenP = [self.mapView convertCoordinate:
                               coord2d toPointToView:self.mapView];
            if (screenP.x > myRect.origin.x && screenP.x < myRect.size.width
                && screenP.y > myRect.origin.y && screenP.y < myRect.size.height){
                data_ptr->isVisible = true;
            }else{
                data_ptr->isVisible = false;
            }
        }
    }
}
@end
