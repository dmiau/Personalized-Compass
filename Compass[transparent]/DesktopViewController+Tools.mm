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
    
    // Shift the map
    
    // 1. Find out the coordinates, coord, corresponding to -shift
    // 2. Make coord the center
    CGPoint neg_shift;
    neg_shift.x = - shift.x; neg_shift.y = -shift.y;
    CLLocationCoordinate2D coord = [self.mapView convertPoint:neg_shift toCoordinateFromView:self.compassView];
    
    
    // Shift the em iOS
    
    
    // Shift the compass
}
@end
