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
@end
