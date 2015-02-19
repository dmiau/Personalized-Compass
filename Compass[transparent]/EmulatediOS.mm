//
//  emulatediOS.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/7/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "EmulatediOS.h"
#import "compassRender.h"
#import "DesktopViewController.h"


/*
 Constructor
 */
EmulatediOS::EmulatediOS(compassMdl* model){
    // Initialize the emulated iOS parameters
    centroid_in_opengl = CGPointMake(0, 0);
    
    // iOS true (width, height): (320, 503)
    deviceType = PHONE;
    width = [model->configurations[@"em_ios_display_wh"][0] floatValue];
    height = [model->configurations[@"em_ios_display_wh"][1] floatValue];
    radius = [model->configurations[@"em_ios_watch_radius"] floatValue];
    
    cached_width = width;
    cached_height = height;
    cached_radius = radius;
    cached_square_width = [model->configurations[@"em_iwatch_display_wh"][0] floatValue];
    
    true_ios_width =
    [model->configurations[@"true_ios_display_wh"][0] floatValue];
    true_ios_height =
    [model->configurations[@"true_ios_display_wh"][1] floatValue];
    true_watch_radius =
    [model->configurations[@"true_ios_watch_radius"] floatValue];
    true_square_watch_width = [model->configurations[@"true_iwatch_display_wh"][1] floatValue];
    
    // Initialize flags
    is_circle = false;
    is_enabled = false;
    is_mask_enabled = false;
    is_touched = false;
}

void EmulatediOS::changeDeviceType(DeviceType dType){
    deviceType = dType;
    switch (dType) {
        case PHONE:
            width = cached_width;
            height = cached_height;
            is_circle = false;
            break;
        case WATCH:
            width = cached_square_width;
            height = cached_square_width;
            is_circle = true;
            break;
        case SQUAREWATCH:
            width = cached_square_width;
            height = cached_square_width;
            is_circle = false;
            break;
        default:
            break;
    }
}

/*
 This method draws the emulated iOS device, including the mask, the background
 (when touched), and the mask (if enabled)
*/
void EmulatediOS::render(compassRender *render){
    if (render->model->tilt < -0.0001)
        return;
    
    // TODO: why -?
    
    // Figure out the four corners (in OpenGL coordinate) to draw
    CGPoint tempFourCorners[4];
    tempFourCorners[0].x = render->view_width/2 - width/2 + centroid_in_opengl.x;
    tempFourCorners[0].y = render->view_height/2 - height/2 - centroid_in_opengl.y;
    
    tempFourCorners[1].x = render->view_width/2 + width/2 + centroid_in_opengl.x;
    tempFourCorners[1].y = render->view_height/2 - height/2 - centroid_in_opengl.y;
    
    tempFourCorners[2].x = render->view_width/2 + width/2 + centroid_in_opengl.x;
    tempFourCorners[2].y = render->view_height/2 + height/2 - centroid_in_opengl.y;
    
    tempFourCorners[3].x = render->view_width/2 - width/2 + centroid_in_opengl.x;
    tempFourCorners[3].y = render->view_height/2 + height/2 - centroid_in_opengl.y;
    
    
    glPushMatrix();
//    glTranslatef(centroid_in_opengl.x, centroid_in_opengl.y, 0);
    
    //--------------
    // Draw a box (to indicate the iOS diaplay area)
    // in the main view
    //--------------
    glPushMatrix();
    // Note UIView's coordinate system is diffrent than OpenGL's
    glTranslatef(-render->view_width/2, render->view_height/2, 0);
    glRotatef(180, 1, 0, 0);
    
    if (is_touched){
        glPushMatrix();
        glTranslatef(0, 0, -3);
        //--------------
        // If touched
        //--------------
        render->drawBoxInView(tempFourCorners, true);
        glPopMatrix();
    }
    
    render->drawBoxInView(tempFourCorners, false);
    glPopMatrix();
    
    //--------------
    // Draw a mask
    //--------------
    if (is_mask_enabled)
    {
        glPushMatrix();
        // Note UIView's coordinate system is diffrent than OpenGL's
        glTranslatef(-render->view_width/2, render->view_height/2, 0);
        glRotatef(180, 1, 0, 0);
        render->drawiOSMask(tempFourCorners);
        glPopMatrix();
    }
    
    glPopMatrix();
}

/*
 Given a point in OpenGL coordinate system, this method check if the 
 emulated device is touched.
*/
bool EmulatediOS::isTouched(CGPoint pointInOpenGL){

    if (is_circle){
        throw(runtime_error("circle test has not been implemented."));
    }
    
    if ( abs(pointInOpenGL.x - centroid_in_opengl.x) < width/2 &&
        abs(pointInOpenGL.y - centroid_in_opengl.y) < height/2)
    {
        is_touched = true;
        return true;
    }else{
        is_touched = false;
        return false;
    }
}

// Calculate the coordinates of the four corners of the emulated iOS display
// in OSX's screen coordinate system

void EmulatediOS::changeSizeByScale(float scale){

    switch (deviceType) {
        case PHONE:
            //iOS screen size is 320x503
            width = cached_width * scale;
            height = cached_height * scale;
            is_circle = false;
            break;
        case WATCH:
            //iOS screen size is 320x503
            radius = cached_radius * scale;
            is_circle = true;
            break;
        case SQUAREWATCH:
            width = cached_square_width * scale;
            height = cached_square_width * scale;
            is_circle = false;
            break;
        default:
            break;
    }
    
}

//-----------------
// updateFourLatLon updates the (lat, lon) of the four cornes of the emulated iOS
// device. In the case of the watch mode, the (lat, lon) of
// the right most and left most (lat, lon) are filled into the structure
//-----------------
void EmulatediOS::updateFourLatLon(double labLon4x2Double[4][2]){
    for (int i = 0; i < 4; ++i){
        four_latlon[i] = CLLocationCoordinate2DMake
        (labLon4x2Double[i][0], labLon4x2Double[i][1]);
    }
}

/*
 This method will be called by DesktopViewController to determine the proper
 zoome level to satisfy the width and height of the emulated iOS, as well as 
 the (lat, lon) at the four corners
*/
MKCoordinateRegion EmulatediOS::caculateCoordinateRegionForDesktop
(DesktopViewController *rootViewController)
{
    MKCoordinateRegion output;
    
//    [self.mapView convertCoordinate:
//     CLLocationCoordinate2DMake(self.latLons4x2.content[i][0],
//                                self.latLons4x2.content[i][1])
//                      toPointToView:self.compassView];
    
    return output;
}

/*
 Calculate four_latlon based on the current boundary
 */
void EmulatediOS::calculateFourLatLon(MKMapView *mapView){
    CGPoint ptInNSView;
    float view_width, view_height;
    CLLocationCoordinate2D coord;

    // Upper left
    ptInNSView.x = centroid_in_opengl.x - width/2 + view_width/2;
    ptInNSView.y = centroid_in_opengl.y + height/2 + view_height/2;
    
    coord = [mapView convertPoint:ptInNSView
           toCoordinateFromView:mapView];
    four_latlon[0] = coord;

    // Upper right
    ptInNSView.x = centroid_in_opengl.x + width/2 + view_width/2;
    ptInNSView.y = centroid_in_opengl.y + height/2 + view_height/2;
    
    coord = [mapView convertPoint:ptInNSView
                                toCoordinateFromView:mapView];
    four_latlon[1] = coord;

    // Lower right
    ptInNSView.x = centroid_in_opengl.x + width/2 + view_width/2;
    ptInNSView.y = centroid_in_opengl.y - height/2 + view_height/2;
    
    coord = [mapView convertPoint:ptInNSView
                                toCoordinateFromView:mapView];
    four_latlon[2] = coord;
    
    // Lower left
    ptInNSView.x = centroid_in_opengl.x - width/2 + view_width/2;
    ptInNSView.y = centroid_in_opengl.y - height/2 + view_height/2;
    
    coord = [mapView convertPoint:ptInNSView
                                toCoordinateFromView:mapView];
    four_latlon[3] = coord;
}
