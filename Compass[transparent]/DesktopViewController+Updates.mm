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
    self.model->updateMdl();
    
    // Update distances on the table
    NSScrollView* scrollView = [self.locationTableView enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(concurrentQueue,
                   ^{
                       NSRange range = [self.locationTableView rowsInRect:visibleRect];
                       for (int i = range.location; i < range.location + range.length; ++i){
                           // [todo] This part is ver slow...
                           ((LocationCellView*)[tableCellCache objectAtIndex:i]).infoTextField.stringValue = [NSString stringWithFormat:@"%.2f (m)",self.model->data_array[i].distance];
                       }
                   });
    //        NSLog(@"location: %d, length:  %d", range.location, range.length);
}

- (void) updateMapDisplayRegion{
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
}
@end
