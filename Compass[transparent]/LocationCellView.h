//
//  LocationCellView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 3/27/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LocationCellView : NSTableCellView{
    @private
    IBOutlet NSTextField *infoTextField;
}
@property(assign) NSTextField *infoTextField;
@end
