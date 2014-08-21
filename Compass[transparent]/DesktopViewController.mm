//
//  DesktopViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController.h"
#import "AppDelegate.h"
#import "LocationCellView.h"
#import "OpenGLView.h"
#include <cmath>

@implementation DesktopViewController
@synthesize model;

#pragma mark ------------- menu items -------------

// This sorting thing does not quite work for some reason
// 
static NSComparisonResult myCustomViewAboveSiblingViewsComparator(id view1, id view2, void *context )
{
    if ([view1 isKindOfClass:[MKMapView class]]){
        NSLog(@"here1!");
        return NSOrderedAscending;
    }else if ([view2 isKindOfClass:[MKMapView class]]){
        NSLog(@"here2!");
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (void)mouseDown:(NSEvent *)theEvent{
    //----------------
    //http://lists.apple.com/archives/mac-opengl/2003/Feb/msg00069.html
    NSPoint mouseLoc = [self.compassView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // This reports the correct mouse position.
    NSLog(@"ViewController: %@", NSStringFromPoint(mouseLoc));
    
    
    //    NSLog(@"***Mouse down");
    //	GLint viewport[4];
    //	GLubyte pixel[3];
    //
    //	glReadPixels(mouseLoc.x,mouseLoc.y,1,1,
    //                 GL_RGB,GL_UNSIGNED_BYTE,(void *)pixel);
    //
    //    // Print pixel colors
    //    printf("%d %d %d\n",pixel[0],pixel[1],pixel[2]);
    
    // http://stackoverflow.com/questions/6590763/mouse-events-bleeding-through-nsview
    // I want the event to bleed.
    [super mouseDown:theEvent];
}
@end
