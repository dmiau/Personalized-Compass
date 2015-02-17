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
            self.mapView.mapType = MKMapTypeSatellite;
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

//------------------
// Toggle the blank map mode
//------------------
- (void)toggleBlankMapMode:(bool)state{
    self.isBlankMapEnabled = state;
    
    static MKPolygon* poly;
    
    if (state){
        vector<CLLocationCoordinate2D> latlon_vector =
        [self getBoundaryLatLon];
        
        // Define an overlay that covers Colorado.
        CLLocationCoordinate2D  points[4];
        points[0] = latlon_vector[0];
        points[1] = latlon_vector[1];
        points[2] = latlon_vector[2];
        points[3] = latlon_vector[3];
        poly = [MKPolygon polygonWithCoordinates:points count:4];
        poly.title = @"Blank";
        [self.mapView addOverlay:poly];
    }else{
        [self.mapView removeOverlay:poly];
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
@end
