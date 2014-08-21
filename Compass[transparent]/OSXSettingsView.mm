//
//  OSXSettingsView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/21/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "OSXSettingsView.h"

@implementation OSXSettingsView

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return  YES;
}

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

@end
