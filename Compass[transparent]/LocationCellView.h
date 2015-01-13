//
//  LocationCellView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 3/27/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "compassModel.h"
#import "DesktopViewController.h"

@interface LocationCellView : NSTableCellView{
    @private
}
@property (weak, atomic) IBOutlet NSButton *checkbox;
- (IBAction) toggleCheckbox: (id) sender;
@property(weak) IBOutlet NSTextField *infoTextField;

@property DesktopViewController* rootViewController;
@property data* data_ptr;
@property bool isUserLocation;

// Control the visibility of OpenGL view
- (IBAction)flipSingleLandmark:(NSButton*)sender;

@end
