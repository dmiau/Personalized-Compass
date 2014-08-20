//
//  OSXPinAnnotationView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "OSXPinAnnotationView.h"

@implementation OSXPinAnnotationView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        calloutViewController =
        [[NSViewController alloc]
         initWithNibName:@"OSXCalloutView" bundle:nil];
    }
    return self;
}

//http://stackoverflow.com/questions/1565828/how-to-customize-the-callout-bubble-for-mkannotationview
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {

        [self addSubview:calloutViewController.view];
    }
    else
    {
        //Remove your custom view...
//        [calloutViewController.view removeFromSuperview];
    }
}


@end
