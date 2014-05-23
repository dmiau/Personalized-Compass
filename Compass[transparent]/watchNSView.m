//
//  watchNSView.m
//  testMapKit
//
//  Created by dmiau on 3/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "watchNSView.h"
#import <MapKit/MapKit.h>

@implementation WatchNSView

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Initialization code here.
        NSRect img_rect;
        
        // Some tools I can use to specify the size of a view
        // NSMakeRect, CGRectMake
        img_rect = NSMakeRect(10, 10, 609, 392); //orig_x, y, width, height

        // Read the image
        NSString *fileString =
        [[NSBundle mainBundle] pathForResource:@"smartWatch.tif" ofType:@""];
        NSImage *bgImage = [[NSImage alloc] initWithContentsOfFile:fileString];

        // Create a foreground view
        self.my_foreground = [[NSView alloc] initWithFrame:img_rect];
        self.my_foreground.wantsLayer = true;

        // Crete a layer
        CALayer*    aLayer = [CALayer layer];
        aLayer.contents = bgImage;
        aLayer.frame = NSMakeRect(0, 0, 609, 392); //orig_x, y, width, height
        
        [self.my_foreground.layer setBackgroundColor:CGColorCreateGenericRGB(0.5, 0.5, 0.5, 0.5)];
        //    self.compassView.layer.backgroundColor = [NSColor clearColor].CGColor;
        
        // Insert the layer to the foreground view
        [self.my_foreground.layer insertSublayer:aLayer above:self.my_foreground.layer];


        [self addSubview:self.my_foreground
              positioned:NSWindowAbove relativeTo:nil];
    }
    return self;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        NSArray *my_subviews = self.subviews;
        NSLog(@"# of subviews: %lu", (unsigned long)my_subviews.count);
    }
    return self;
}

- (void)awakeFromNib {

}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
@end
