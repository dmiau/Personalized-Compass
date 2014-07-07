//
//  iOSViewController+Updates.m
//  Compass[transparent]
//
//  Created by dmiau on 6/23/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Updates.h"
#include <cmath>

@implementation iOSViewController (Updates)
#pragma mark ---- Timer Functon Stuff ----
-(void)vcTimerFired{
    
    static double latitude_cache = 0.0;
    static double longitude_cache = 0.0;
    static double pitch_cache = 0.0;
    static double camera_heading = 0.0;
    double epsilon = 0.0000001;
    
    // Note that heading is defined as the negative of
    // _mapView.camera.heading
    if ( abs((double)(latitude_cache - [self.mapView centerCoordinate].latitude)) > epsilon ||
        abs((double)(longitude_cache - [self.mapView centerCoordinate].longitude)) > epsilon ||
        abs((double)(pitch_cache - self.mapView.camera.pitch)) > epsilon||
        abs((double)(camera_heading - [self calculateCameraHeading])) > epsilon)
    {
        latitude_cache = [self.mapView centerCoordinate].latitude;
        longitude_cache = [self.mapView centerCoordinate].longitude;
        pitch_cache = self.mapView.camera.pitch;
        camera_heading = [self calculateCameraHeading];
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
        //        dispatch_queue_t concurrentQueue =
        //        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        //        dispatch_async(concurrentQueue,
        //                       ^{
        //
        //                       });
        
        [self feedModelLatitude: compassCtrCoord.latitude
                      longitude: compassCtrCoord.longitude
                        heading: [self calculateCameraHeading]
                           tilt: -self.mapView.camera.pitch];
        
        // [todo] This code should be put into the gesture recognizer
        // Disable the compass
        
        // Gets array of subviews from the map view (MKMapView)
        
        if (!self.conventionalCompassVisible){
            [self setFactoryCompassHidden:YES];
        }
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue,
                       ^{
                           // Redraw the compass
                           [self updateOverviewMap];
                           [self.glkView setNeedsDisplay];
                       });
        
    }
}

//---------------
// This function is called when user actions changes
// the location, heading and tilt.
//---------------
- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) camera_heading
                      tilt: (float) tilt_deg
{
    //[todo] this is too heavy
    self.model->current_pos.orientation = -camera_heading;
    self.model->tilt = tilt_deg; // no tilt changes on iOS
    
    self.model->current_pos.latitude = lat_float;
    self.model->current_pos.longitude = lon_float;
    self.model->updateMdl();
}


- (float) calculateCameraHeading{
    // calculateCameraHeading calculates the heading of camera relative to
    // the magnetic north
    
    float true_north_wrt_up = 0;
    
    //---------------------------
    // fix angle calculation
    //---------------------------
    double width = self.mapView.frame.size.width;
    double height = self.mapView.frame.size.height;
    
    CLLocationCoordinate2D map_s_pt = [self.mapView centerCoordinate];
    CLLocationCoordinate2D center_pt = [self.mapView convertPoint:CGPointMake(width/2, height/2) toCoordinateFromView:self.mapView];
    
    CLLocationCoordinate2D map_n_pt = [self.mapView convertPoint:CGPointMake(width/2, height/2-30) toCoordinateFromView:self.mapView];
    
    true_north_wrt_up = [self computeOrientationFromLocation:(CLLocationCoordinate2D) map_s_pt
                                                  toLocation: (CLLocationCoordinate2D) map_n_pt];
    return true_north_wrt_up;
}

- (void) updateMapDisplayRegion{
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    static int once = 0;
    if (once==0){
        MKCoordinateRegion region;
        region.center.latitude = self.model->current_pos.latitude;
        region.center.longitude = self.model->current_pos.longitude;
        
        region.span.longitudeDelta = self.model->latitudedelta;
        region.span.latitudeDelta = self.model->longitudedelta;
        [self.mapView setRegion:region];
        once = 1;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = self.model->current_pos.latitude;
    coord.longitude = self.model->current_pos.longitude;
    
    
    //    // The compass may be off-center, thus we need to calculate the
    //    // coordinate of the true center
    //    [self.mapView convertPoint: NSMakePoint(-self.compassView.frame.size.width/2,
    //                                            -self.compassView.frame.size.height/2)
    //                      fromView:self.compassView];
    
    
    
    [self.mapView setCenterCoordinate:coord animated:YES];
}

//------------------
// This function should be called after the user moves the compass
//------------------
-(bool)updateModelCompassCenterXY{
    self.model->compassCenterXY =
    [self.mapView convertPoint: CGPointMake(self.glkView.frame.size.width/2
                                            + [self.model->configurations[@"compass_centroid"][0] floatValue],
                                            self.glkView.frame.size.height/2+
                                            - [self.model->configurations[@"compass_centroid"][1] floatValue])
                      fromView:self.glkView];
    return true;
}
//------------------
// Tools
//------------------
-(double) computeOrientationFromLocation:(CLLocationCoordinate2D) refPt
                              toLocation: (CLLocationCoordinate2D) destPt{
    
    double lat1 = DegreesToRadians(refPt.latitude);
    double lon1 = DegreesToRadians(refPt.longitude);
    
    double lat2 = DegreesToRadians(destPt.latitude);
    double lon2 = DegreesToRadians(destPt.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    return RadiansToDegrees(radiansBearing);
}
@end
