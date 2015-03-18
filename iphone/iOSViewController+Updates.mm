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
    static bool   hasChanged = false;
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
        hasChanged = true;
    }else{
        // This condition is reached when the map comes to a stop
        // Do a force refresh
        if (hasChanged){
            // Do a force refresh
            [self updateLocationVisibility];
               self.model->updateMdl();
            [self updateCornerLatLon];
            
            [self sendBoundaryLatLon];
            [self updateOverviewMap];
            [self.glkView setNeedsDisplay];
            [self updateFindMeView];
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
        
        [self updateLocationVisibility];
        
        [self updateCornerLatLon];
        
        [self sendBoundaryLatLon];
        
        CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint: self.model->compassRefMapViewPoint
            toCoordinateFromView:self.mapView];
        
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
                           // Update GUI components
                           [self updateOverviewMap];
                           [self.glkView setNeedsDisplay];
                           [self updateFindMeView];
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
    
    if (self.model->tilt == 0 && tilt_deg !=0){
        [self changeCompassLocationTo:@"BL"];
    }
    
    
    self.model->camera_pos.orientation = -camera_heading;
    self.model->tilt = tilt_deg; // no tilt changes on iOS
    
    self.model->camera_pos.latitude = lat_float;
    self.model->camera_pos.longitude = lon_float;
    self.model->updateMdl();
    if (self.renderer->isAnswerLinesEnabled)
        [self updateAnswerLines];
}

- (void) updateAnswerLines{
    if (self.renderer->isAnswerLinesEnabled){
        data centroid_data;
        centroid_data.latitude = self.mapView.centerCoordinate.latitude;
        centroid_data.longitude = self.mapView.centerCoordinate.longitude;
        
        self.renderer->degree_vector.clear();
        double maxDist = 0;
        // Calculat the angles
        for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
            int j = self.model->indices_for_rendering[i];
            
            double degree = -(
                              centroid_data.computeOrientationFromLocation(self.model->data_array[j])
                              -90);
            
            //            cout << self.model->data_array[j].name << endl;
            //            cout << "Degree: " << degree << endl;
            self.renderer->degree_vector.push_back(degree);
            
            data myData = self.model->data_array[j];
            
            // Also update distances here
            CGPoint point = [self.mapView convertCoordinate:
                             CLLocationCoordinate2DMake(myData.latitude, myData.longitude)
                                              toPointToView:self.mapView];
            point.x = point.x - self.mapView.frame.size.width/2;
            point.y = point.y - self.mapView.frame.size.height/2;
            double dist = sqrt(point.x*point.x + point.y * point.y);
            if (dist > maxDist)
                maxDist =dist;
        }
        self.messageLabel.text = [NSString stringWithFormat:@"Dist: %.1fx",
                                  (double)maxDist / (double)self.mapView.frame.size.width*2];
    }
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
    
    true_north_wrt_up = computeOrientationFromA2B(map_s_pt, map_n_pt);
    
    return true_north_wrt_up;
}

- (void) updateMapDisplayRegion: (MKCoordinateRegion) coord_region
                  withAnimation:(bool) animated
{
    // updateMapDisplayRegion syncs parameters from the model to the
    // display map
    
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    static bool isInited = false;
    if (!isInited){
        MKCoordinateRegion region;
        region.center.latitude = self.model->camera_pos.latitude;
        region.center.longitude = self.model->camera_pos.longitude;
        
        region.span.longitudeDelta = self.model->latitudedelta;
        region.span.latitudeDelta = self.model->longitudedelta;
        [self.mapView setRegion:region animated:NO];
        isInited = true;
    }
    

    // Not sure why I need the following two lines.
//    [self.mapView setRegion:coord_region animated:animated];
//    self.mapView.centerCoordinate = coord_region.center;
//    self.mapView.region = coord_region;

    
    // use mapRect instead?
    self.mapView.visibleMapRect =
    [self MKMapRectForCoordinateRegion:coord_region];
    
    
    // Update the model
    CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                              self.model->compassRefMapViewPoint
                                                   toCoordinateFromView:self.mapView];
    self.model->camera_pos.latitude = compassCtrCoord.latitude;
    self.model->camera_pos.longitude = compassCtrCoord.longitude;
    
    [self updateLocationVisibility];
    self.model->updateMdl();
#ifndef __IPHONE__
    [self.compassView setNeedsDisplay:YES];
#else
    [self.glkView setNeedsDisplay];
#endif
}

- (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

//------------------
// This function should be called after the user moves the compass
//------------------
- (void)moveCompassCentroidToOpenGLPoint: (CGPoint) OpenGLPoint{
    
    // Update the centroid of the "displayed" compass
    self.renderer->compass_centroid = OpenGLPoint;
    
    // Only called when UICompassCenterLocked is false
    if (![self.UIConfigurations[@"UICompassCenterLocked"] boolValue]){
        
        // Update compassRefMapViewPoint (compass's centroid coordinates in mapView)
        self.model->compassRefMapViewPoint =
        [self.mapView convertPoint:
         CGPointMake(self.glkView.frame.size.width/2
                     + self.renderer->compass_centroid.x,
                     self.glkView.frame.size.height/2
                     - self.renderer->compass_centroid.y)
                          fromView:self.glkView];
        // Update compass's (latitude, longitude)
        CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                                  self.model->compassRefMapViewPoint
                                                       toCoordinateFromView:self.mapView];
        
        self.model->camera_pos.latitude = compassCtrCoord.latitude;
        self.model->camera_pos.longitude = compassCtrCoord.longitude;
        self.model->updateMdl();
    }
}

- (void)moveCompassRefToMapViewPoint:(CGPoint) MapViewPoint{
    // Update compassRefMapViewPoint (compass's centroid coordinates in mapView)
    self.model->compassRefMapViewPoint = MapViewPoint;
    // Update compass's (latitude, longitude)
    CLLocationCoordinate2D compassCtrCoord = [self.mapView convertPoint:
                                              self.model->compassRefMapViewPoint
                                                   toCoordinateFromView:self.mapView];
    
    self.model->camera_pos.latitude = compassCtrCoord.latitude;
    self.model->camera_pos.longitude = compassCtrCoord.longitude;
    self.model->updateMdl();
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
        CGRect myRect = [self.mapView frame];
        
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
            if (screenP.x > 0 && screenP.x < myRect.size.width
                && screenP.y > 0 && screenP.y < myRect.size.height){
                data_ptr->isVisible = true;
            }else{
                data_ptr->isVisible = false;
            }
        }
    }
}

//----------------------------
// Update the (latitude, longitude) of the four corners
// of MapView
//----------------------------
- (void) updateCornerLatLon{
    
//    =====================
//    iOS (u, v), note: the coordinate system is flipped
//    =====================
//    v
//    |
//    |
//    |
//    --------u
    
    //First we need to calculate the corners of the map so we get the points
    CGPoint ulPoint = CGPointMake(self.mapView.bounds.origin.x,
                                  self.mapView.bounds.origin.y);
    CGPoint urPoint = CGPointMake(self.mapView.bounds.origin.x
                                  + self.mapView.bounds.size.width
                                  , self.mapView.bounds.origin.y);
    CGPoint brPoint = CGPointMake(self.mapView.bounds.origin.x
                                  + self.mapView.bounds.size.width,
                                  self.mapView.bounds.origin.y+
                                  self.mapView.bounds.size.height);
    CGPoint blPoint = CGPointMake(self.mapView.bounds.origin.x,
                                  self.mapView.bounds.origin.y+
                                  self.mapView.bounds.size.height);
    
    // Note the order in coord_array is reversed so the order in OSX is correct.
    
    //Then transform those points into lat,lng values
    CLLocationCoordinate2D coord_array[4];
    coord_array[3]
    = [self.mapView convertPoint:ulPoint toCoordinateFromView:self.mapView];
    coord_array[2]
    = [self.mapView convertPoint:urPoint toCoordinateFromView:self.mapView];
    
    coord_array[1]
    = [self.mapView convertPoint:brPoint toCoordinateFromView:self.mapView];
    coord_array[0]
    = [self.mapView convertPoint:blPoint toCoordinateFromView:self.mapView];
    
    //http://stackoverflow.com/questions/17548425/objective-c-property-for-c-array
    
    LatLons4x2 temp;
    
    for (int i = 0; i <4; ++i){
        temp.content[i][0] = coord_array[i].latitude;
        temp.content[i][1] = coord_array[i].longitude;
    }
    self.latLons4x2 = temp;
}

@end
