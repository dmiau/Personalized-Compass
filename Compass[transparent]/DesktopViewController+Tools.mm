//
//  DesktopViewController+Tools.m
//  Compass[transparent]
//
//  Created by dmiau on 2/8/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "DesktopViewController.h"

@implementation DesktopViewController (Tools)
- (CGPoint) convertOpenGLCoordToNSView: (CGPoint) coordInOpenGL
{
    CGPoint output;
    output.x = coordInOpenGL.x + self.renderer->view_width/2;
    output.y = coordInOpenGL.y + self.renderer->view_height/2;
    return output;
}

- (CGPoint) convertNSViewCoordToOpenGL: (CGPoint) coordInNSView{
    CGPoint output;
    output.x = coordInNSView.x - self.renderer->view_width/2;
    output.y = coordInNSView.y - self.renderer->view_height/2;
    return output;
}

//-------------------
// shiftTestingEnvironmentBy shift the entire environment, including the map,
// the emulated iOS and the compass, by the vector specified in shift (in pixels)
//-------------------
- (void) shiftTestingEnvironmentBy: (CGPoint) shift{

    //-------------------------
    // Shift the emulated iOS, and the map (if necessary)
    //-------------------------
    // Shift the em iOS
    self.renderer->emulatediOS.centroid_in_opengl = shift;
    // 1. Find out the coordinates, coord, corresponding to -shift
    // 2. Make coord the center
    CGPoint neg_shift;
    neg_shift.x = - shift.x + self.renderer->view_width/2;
    neg_shift.y = -shift.y + self.renderer->view_height/2;
    CLLocationCoordinate2D coord = [self.mapView convertPoint:neg_shift toCoordinateFromView:self.compassView];
    [self.mapView setCenterCoordinate:coord animated:NO];

    //-------------------------
    // Shift the compass (to an absolute location)
    //-------------------------
    // update compass location
        [self moveCompassCentroidToOpenGLPoint: shift];
}
@end
