//
//  LocationCellView.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 3/27/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "LocationCellView.h"

@implementation LocationCellView

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


- (IBAction)flipSingleLandmark:(NSButton*)sender{
    if ([sender state] == NSOnState) {
        self.data_ptr->isEnabled = true;
    } else {
        self.data_ptr->isEnabled = false;
    }
}
@end
