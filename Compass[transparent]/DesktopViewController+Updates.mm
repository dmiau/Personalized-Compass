//
//  DesktopViewController+Updates.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Updates.h"
#import "ConfigurationsWindowController.h"
#import "LocationCellView.h"
#include <cmath>

@implementation DesktopViewController (Updates)

- (IBAction)refreshConfigurations:(id)sender {
    
    // [todo] update code can be refactored
    self.model->reloadFiles();
    [self initMapView];
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
    static bool hasChanged = false;
    
    double epsilon = 0.0000001;
    
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    
    if ( !MKMapRectEqualToRect(visibleMapRect_cache, visibleMapRect)||
        abs((double)(pitch_cache - self.mapView.camera.pitch)) > epsilon)
    {
//        // debug
//        NSLog(@"cached rect: %@", MKStringFromMapRect(visibleMapRect_cache));
//        NSLog(@"visible rect: %@", MKStringFromMapRect(self.mapView.visibleMapRect));
        
        visibleMapRect_cache = visibleMapRect;
        pitch_cache = self.mapView.camera.pitch;
        
        self.mapUpdateFlag = [NSNumber numberWithDouble:0.0];
        hasChanged = true;
    }else{
        // This condition is reached when the model just comes to a stop.
        if (hasChanged){
            [self updateLocationVisibility];
            self.model->updateMdl();
            [self.compassView setNeedsDisplay:YES];
            hasChanged = false;
        }
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
        
        // TODO
        if (self.renderer->emulatediOS.is_enabled){
            // Update the screen cordinates corresponding to
            // iOS screen's boundary, if iOSSyncFlag is on
            if (!self.iOSSyncFlag){
                float scale = [self.configurationWindowController.iOSScale floatValue];
                self.renderer->emulatediOS.changeSizeByScale(scale);
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
}

- (void) updateMapDisplayRegion: (MKCoordinateRegion) coord_region
                  withAnimation:(bool) animated
{
    // updateMapDisplayRegion syncs parameters from the model to the
    // display map
    
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    
    
    
    [self.mapView setRegion:coord_region animated:animated];
    
    self.mapView.centerCoordinate = coord_region.center;
    self.mapView.region = coord_region;
    
    // Update the model
    CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                              self.model->compassCenterXY
                                                   toCoordinateFromView:self.mapView];
    self.model->camera_pos.latitude = compassCtrCoord.latitude;
    self.model->camera_pos.longitude = compassCtrCoord.longitude;
    
    [self updateLocationVisibility];
    self.model->updateMdl();
    [self.compassView setNeedsDisplay:YES];
}


//------------------
// This function should be called after the user moves the compass
//------------------
- (void)moveCompassCentroidToOpenGLPoint: (CGPoint) OpenGLPoint{
    
    // Update the centroid of the "displayed" compass
    self.renderer->compass_centroid = OpenGLPoint;
    
    // Only called when UICompassCenterLocked is false
    if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){

        // Update compassCenterXY (compass's centroid coordinates in mapView)
        self.model->compassCenterXY =
        [self.mapView convertPoint:
         CGPointMake(self.compassView.frame.size.width/2
                     + self.renderer->compass_centroid.x,
                     self.compassView.frame.size.height/2
                     + self.renderer->compass_centroid.y)
                          fromView:self.compassView];
        // Update compass's (latitude, longitude)
        CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                                  self.model->compassCenterXY
                                                       toCoordinateFromView:self.mapView];
        
        self.model->camera_pos.latitude = compassCtrCoord.latitude;
        self.model->camera_pos.longitude = compassCtrCoord.longitude;
        self.model->updateMdl();
    }
}

//------------------
// Refresh the main GUI
//------------------
- (void)updateMainGUI{
    //    [self.rootViewController updateMapDisplayRegion];
    [self updateLocationVisibility];
    self.model->updateMdl();
    [self renderAnnotations];
    [self.compassView setNeedsDisplay:YES];
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
        myRect = [self.mapView frame];

#ifndef __IPHONE__
        if (self.renderer->emulatediOS.is_enabled){
            // Get the information from iOSFourCornersInNSView
            
            CGPoint coordInNSView =
            [self convertOpenGLCoordToNSView: self.renderer->emulatediOS.centroid_in_opengl];
            coordInNSView.x = coordInNSView.x- self.renderer->emulatediOS.width/2;
            coordInNSView.y = coordInNSView.y- self.renderer->emulatediOS.height/2;
            myRect.origin= coordInNSView;
            myRect.size.width = self.renderer->emulatediOS.width;
            myRect.size.height = self.renderer->emulatediOS.height;
        }
#endif
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
            if (screenP.x > myRect.origin.x && (screenP.x - myRect.origin.x) < myRect.size.width
                && screenP.y > myRect.origin.y && (screenP.y - myRect.origin.y) < myRect.size.height){
                data_ptr->isVisible = true;
            }else{
                data_ptr->isVisible = false;
            }
        }
    }
}
@end
