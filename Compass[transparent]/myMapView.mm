//
//  myMapView.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "myMapView.h"

@implementation myMapView

//- (BOOL)acceptsFirstResponder
//{
//    return NO;
//}
//
//- (BOOL)becomeFirstResponder
//{
//    return  NO;
//}
//
//- (BOOL)resignFirstResponder
//{
//    return YES;
//}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent{
    //----------------
    //http://lists.apple.com/archives/mac-opengl/2003/Feb/msg00069.html
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // This reports the correct mouse position.
    NSLog(@"MyMapView: %@", NSStringFromPoint(mouseLoc));
    
    // http://stackoverflow.com/questions/6590763/mouse-events-bleeding-through-nsview
    // I want the event to bleed.
    [super mouseDown:theEvent];
//    [self.superview mouseDown:theEvent];
    [super.nextResponder mouseDown:theEvent];
}
@end
