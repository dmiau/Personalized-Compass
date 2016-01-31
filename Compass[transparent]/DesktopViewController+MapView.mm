//
//  DesktopViewController+MapView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/2/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+MapView.h"

@implementation DesktopViewController (MapView)

#pragma mark map annotation

- (void) addAnnotationPins{
    //--------------
    // Adding an annotation pin for each location
    //--------------
    CLLocationCoordinate2D coord;
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        
        // [todo] need to reuse annotation
        CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
        coord.latitude = self.model->data_array[i].latitude;
        coord.longitude = self.model->data_array[i].longitude;
        annotation.coordinate = coord;
        annotation.title      = [NSString stringWithCString:self.model->data_array[i].name.c_str() encoding:[NSString defaultCStringEncoding]];
        //        annotation.subtitle   = @"Paris Test";
        
        [self.mapView addAnnotation:annotation];

        if (pinVisible)
            [self.mapView selectAnnotation:annotation animated:YES];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{

}

- (IBAction)togglePins:(id)sender {
    // Adding annotations
    static BOOL once = false;
    if (!once){
        [self addAnnotationPins];
        pinVisible = true;
        once = true;
        return;
    }
    
    NSSet *nearbySet = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    
    for (CustomPointAnnotation *item in nearbySet){
        if (!pinVisible){
            //http://stackoverflow.com/questions/2918154/how-to-hide-mkannotationview-callout

            [[self.mapView viewForAnnotation:item] setHidden:NO];
            //            MKAnnotationView *temp =[self.mapView viewForAnnotation:item];
            //            temp.canShowCallout = NO;
        }else{
            [[self.mapView viewForAnnotation:item] setHidden:YES];
            
            // Print out the camera information
            NSLog(@"%@", self.mapView.camera);
        }
    }
    pinVisible = !pinVisible;
}

- (IBAction)toggleMapMode:(id)sender {
    
    switch([[sender selectedCell] tag]){
        case 1:
            self.mapView.mapType = MKMapTypeStandard;
            self.mapView.showsBuildings = YES;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            self.mapView.showsBuildings = YES;
            break;
        case 3:
            self.mapView.mapType = MKMapTypeSatelliteFlyover;
            self.mapView.showsBuildings = YES;
            break;
    }
    
}

// New annotation will be generated as the map is changed.
// Need to update the annotation appearance status again.
- (void)mapView:(MKMapView *)mapViewHandle regionDidChangeAnimated:(BOOL)animated{
    [self changeAnnotationDisplayMode:self.UIConfigurations[@"ShowPins"]];
}
//------------------
// Blank Overlay
//------------------
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
    polygonRenderer.strokeColor = [NSColor whiteColor];
    polygonRenderer.fillColor   = [NSColor whiteColor];
    return polygonRenderer;
}

//------------------
// Coordinate conversion
//------------------
- (CLLocationCoordinate2D) calculateLatLonFromiOSX: (int) x Y: (int) y {
    CLLocationCoordinate2D result;
    
    // Note: (x, y) are in the iOS OpenGL coordinate system
    
    // The (x, y) coordinates in the OSX screen coordinate frame
    CGPoint osx_xy;
    osx_xy.x = (float)x * self.renderer->emulatediOS.width / self.renderer->emulatediOS.true_ios_width;
    osx_xy.y = (float)y * self.renderer->emulatediOS.height / self.renderer->emulatediOS.true_ios_height;
    
    osx_xy.x = self.renderer->view_width/2 + osx_xy.x;
    osx_xy.y = self.renderer->view_height/2 + osx_xy.y;
    
    result = [self.mapView convertPoint:osx_xy toCoordinateFromView:self.compassView];
    return result;
}

- (CGPoint) calculateOpenGLPointFromMapCoord: (CLLocationCoordinate2D) coord {
    CGPoint result;
    
    CGPoint nsviewPoint =
    [self.mapView convertCoordinate:coord toPointToView:self.compassView];
    result.x = nsviewPoint.x - (double)self.renderer->view_width/(double)2;
    result.y = nsviewPoint.y - (double)self.renderer->view_height/(double)2;
    return result;
}


//------------------
// Toggle the blank map mode
//------------------
- (void)toggleBlankMapMode:(bool)state{
    self.isBlankMapEnabled = state;
    static MKPolygon* poly;
    
    if (state){
//        vector<CLLocationCoordinate2D> latlon_vector =
//        [self getBoundaryLatLon];
        
        // Define an overlay that covers Colorado.
        CLLocationCoordinate2D  points[4];
        points[0] = CLLocationCoordinate2DMake(1.0, 6.55859375);
        points[1] = CLLocationCoordinate2DMake(940.99609375, 4.6640625);
        points[2] = CLLocationCoordinate2DMake(940.99609375, 627.84765625);
        points[3] = CLLocationCoordinate2DMake(1.0, 603.9765625);
        poly = [MKPolygon polygonWithCoordinates:points count:4];
        poly.title = @"Blank";
        [self.mapView addOverlay:poly];
    }else{
//        [self.mapView removeOverlay:poly];
        // Remove all overlays
        [self.mapView removeOverlays: self.mapView.overlays];
    }
}

-(void)enableMapInteraction:(bool)state{
    if (!state){
        [self.mapView setPitchEnabled:NO];
        [self.mapView setZoomEnabled:NO];
        [self.mapView setRotateEnabled:NO];
        [self.mapView setScrollEnabled:NO];
        
    }else{
        [self.mapView setPitchEnabled:YES];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setRotateEnabled:YES];
        [self.mapView setScrollEnabled:YES];
    }
}

//------------------
// Coordinate conversion
//------------------
- (vector<CLLocationCoordinate2D>) getBoundaryLatLon{
    vector<CLLocationCoordinate2D> output; output.clear();
    
    CLLocationCoordinate2D temp;
    
    // Top left
    temp = [self.mapView convertPoint:CGPointMake(0, 0)
                 toCoordinateFromView:self.mapView];
    output.push_back(temp);
    
    // Top right
    temp = [self.mapView convertPoint:CGPointMake(self.renderer->view_width, 0)
                 toCoordinateFromView:self.mapView];
    output.push_back(temp);
    
    // Bottom right
    temp = [self.mapView convertPoint:CGPointMake(self.renderer->view_width,
                                                  self.renderer->view_height)
                 toCoordinateFromView:self.mapView];
    output.push_back(temp);
    
    // Bottom left
    temp = [self.mapView convertPoint:CGPointMake(0, self.renderer->view_height)
                 toCoordinateFromView:self.mapView];
    output.push_back(temp);
    
    return output;
}

//----------------
// Since all the coordinate span are device specific,
// the map needs to be scaled accordingly when presenting an iOS map on OSX
//----------------
- (MKCoordinateSpan) scaleCoordinateSpanForDeviceInSnapshot: (snapshot)mySnapshot{
    
    MKCoordinateSpan output;
    if (mySnapshot.deviceType == PHONE) {
        //----------------
        // Phone
        //----------------
        output.latitudeDelta =
        mySnapshot.coordinateRegion.span.latitudeDelta *
        (double)self.renderer->view_height/ (double)self.renderer->emulatediOS.height;
        
        output.longitudeDelta =
        mySnapshot.coordinateRegion.span.longitudeDelta *
        (double)self.renderer->view_width/(double)self.renderer->emulatediOS.width;
    }else if (mySnapshot.deviceType == SQUAREWATCH) {
        //----------------
        // Square Watch
        //----------------
        output.latitudeDelta =
        mySnapshot.coordinateRegion.span.latitudeDelta *
        (double) self.renderer->view_height / (double) self.renderer->emulatediOS.cached_square_width;
        
        output.longitudeDelta =
        mySnapshot.coordinateRegion.span.longitudeDelta *
        (double) self.renderer->view_width / (double) self.renderer->emulatediOS.cached_square_width;
    }else if (mySnapshot.deviceType == WATCH){
        //----------------
        // Circular Watch
        //----------------
        output.latitudeDelta =
        mySnapshot.coordinateRegion.span.latitudeDelta *
        (double) self.renderer->view_height / (double) self.renderer->emulatediOS.cached_square_width;
        
        output.longitudeDelta =
        mySnapshot.coordinateRegion.span.longitudeDelta *
        (double) self.renderer->view_width / (double) self.renderer->emulatediOS.cached_square_width;
        // TODO: need to implement circle watch face
    }
    return output;
}

//----------------
// Since we are generating iOS test cases on the desktop,
// we need to calcualt the true iOS coordspan
//----------------
- (MKCoordinateSpan) calculateCoordinateSpanForDevice: (DeviceType)deviceType{
    
    MKCoordinateSpan output;
    if (deviceType == PHONE) {
        //----------------
        // Phone
        //----------------
        output.latitudeDelta =
        self.mapView.region.span.latitudeDelta *
        (double) self.renderer->emulatediOS.height / (double) self.renderer->view_height;
        
        output.longitudeDelta =
        self.mapView.region.span.longitudeDelta *
        (double) self.renderer->emulatediOS.width / (double) self.renderer->view_width;
    }else if (deviceType == SQUAREWATCH) {
        //----------------
        // Square Watch
        //----------------
        output.latitudeDelta =
        self.mapView.region.span.latitudeDelta *
        (double) self.renderer->emulatediOS.cached_square_width / (double) self.renderer->view_height;
        
        output.longitudeDelta =
        self.mapView.region.span.longitudeDelta *
        (double) self.renderer->emulatediOS.cached_square_width / (double) self.renderer->view_width;
    }else if (deviceType == WATCH){
        //----------------
        // Circle Watch
        //----------------
        
        // It is slightly more complicated for the watch
        // 1. Find out the lat_span within the emulated watch
        // 2. scale up a bit true_radius*2/true_landscape_height
        // or true_radius*2/true_landscape_height for the iPhone
        
        float true_watch_radius =  self.renderer->emulatediOS.true_watch_radius;
        float true_landscape_width = self.renderer->emulatediOS.true_landscape_watch_width;
        float true_landscape_height = self.renderer->emulatediOS.true_landscape_watch_height;
        
        output.latitudeDelta =
        self.mapView.region.span.latitudeDelta *
        (double) self.renderer->emulatediOS.radius /(double) self.renderer->view_height * true_landscape_height / (double)true_watch_radius;
        
        output.longitudeDelta =
        self.mapView.region.span.longitudeDelta *
        (double) self.renderer->emulatediOS.radius /(double) self.renderer->view_width * true_landscape_width / (double)true_watch_radius;
    }
    return output;
}

- (MKCoordinateRegion) calculateOSXCoordinateSpanForTriangulateTask: (snapshot)mySnapshot{
    MKCoordinateRegion osxCoordinateRegion;
    
    if ( NSStringToTaskType(mySnapshot.name) == TRIANGULATE){
        //----------------
        // TRIANGULATE
        //----------------
        
        data data_a = self.model->data_array[mySnapshot.selected_ids[0]];
        CLLocation *point_a = [[CLLocation alloc]
                               initWithLatitude:data_a.latitude longitude:data_a.longitude];
        
        data data_b = self.model->data_array[mySnapshot.selected_ids[1]];
        CLLocation *point_b = [[CLLocation alloc]
                               initWithLatitude:data_b.latitude longitude:data_b.longitude];
        
        CLLocationDistance distnace = [point_a distanceFromLocation: point_b];
        
        CLLocationCoordinate2D centerCoordinate =
        CLLocationCoordinate2DMake(((double)data_a.latitude + (double)data_b.latitude)/(double)2,
                                   ((double)data_a.longitude + (double)data_b.longitude)/(double)2);
        
        
        osxCoordinateRegion =
        MKCoordinateRegionMakeWithDistance
        (centerCoordinate, distnace * 1.1, distnace * 1.1*
         (double)self.mapView.frame.size.width/(double)self.mapView.frame.size.height);
    }else if ( NSStringToTaskType(mySnapshot.name) == LOCATEPLUS){
        
        //----------------
        // LOCATEPLUS
        //----------------
        CLLocation *center = [[CLLocation alloc]
                              initWithLatitude: mySnapshot.coordinateRegion.center.latitude
                              longitude: mySnapshot.coordinateRegion.center.longitude];
        CLLocation *support = [[CLLocation alloc]
                               initWithLatitude:
                               self.model->data_array[mySnapshot.selected_ids[1]].latitude
                               longitude:
                               self.model->data_array[mySnapshot.selected_ids[1]].longitude];
        
        CLLocationDistance distnace = [center distanceFromLocation: support];
        
        CLLocationCoordinate2D centerCoordinate =
        mySnapshot.coordinateRegion.center;
        
        osxCoordinateRegion =
        MKCoordinateRegionMakeWithDistance
        (centerCoordinate, distnace * 2.2,
         distnace * 2.2 *
         (double)self.mapView.frame.size.width/(double)self.mapView.frame.size.height);
        
    }else{
        throw(runtime_error("Unknown task type"));
    }
    
    return osxCoordinateRegion;
}

@end
