//
//  DesktopViewController+Interactions.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Interactions.h"

@implementation DesktopViewController (Interactions)

- (IBAction)toggleMap:(id)sender {
    
    // Toggle MapView status
    if ([self.mapView isHidden] == NO){
        [self.mapView setHidden:YES];
        [(NSMenuItem *)sender setTitle:@"Show Map"];
    }else{
        [self.mapView setHidden:NO];
        
        // [4.24.2014]
        // [todo] The following is a hack to make sure views appear
        // in the desired order. It is basically a hack
        // but I couldn't figure out a better solution at the momnet.
        // We know that map view is always in the bottom
        NSArray *all_views = [[self.mapView superview] subviews];
        NSView *aView;
        for (aView in all_views){
            if (![aView isKindOfClass:[MKMapView class]]){
                [aView setHidden:YES];
                [aView setHidden:NO];
            }
        }
        
        //        [[self.mapView superview]
        //         sortSubviewsUsingFunction:myCustomViewAboveSiblingViewsComparator
        //         context:NULL];
        [(NSMenuItem *)sender setTitle:@"Hide Map"];
    }
}

- (IBAction)toggleCompass:(id)sender {
    // Toggle MapView status
    if ([self.compassView isHidden] == NO){
        [self.compassView setHidden:YES];
        [(NSMenuItem *)sender setTitle:@"Show Compass"];
    }else{
        [self.compassView setHidden:NO];
        [(NSMenuItem *)sender setTitle:@"Hide Compass"];
    }
}

- (IBAction)rotate:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    MKMapCamera *mycamera = self.mapView.camera;
    
    CLLocationDirection cur_heading = mycamera.heading;
    
    if ([title rangeOfString:@"CCW"].location == NSNotFound){
        mycamera.heading = cur_heading - 2;
        // Update the compassModel's orientation
        //[todo] need to fix orientation
        self.model->camera_pos.orientation = self.model->camera_pos.orientation +2;
    }else{
        mycamera.heading = cur_heading + 2;
        self.model->camera_pos.orientation = self.model->camera_pos.orientation -2;
    }
    cout << "Orientation: " << self.model->camera_pos.orientation << endl;
    [self.mapView setCamera:mycamera animated:YES];
}

- (IBAction)showSettings:(id)sender {
    
    [self.settingsView setHidden:!self.settingsView.isHidden];
}

#pragma mark ------------- User Interface -------------

- (IBAction)didChangeKMLCombo:(id)sender {
    NSString* astr = [self.kmlComboBox stringValue];
    
    self.model->location_filename = [[NSBundle mainBundle] pathForResource:astr                                                                             ofType:@""];
    
    NSLog(@"json combon triggered %@", astr);
    
    // The following debug line did work!
    // po ((NSComboBox *)sender).stringValue
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.locationTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    
    //Begin editing of the cell containing the new object
    [self.locationTableView editColumn:0 row:0 withEvent:nil select:YES];
    
    
    [tableCellCache removeAllObjects];
    self.model->reloadFiles();
    
    
    for (int i = 0; i < self.model->data_array.size(); ++i)
    {
        [tableCellCache addObject:[NSNull null]];
    }
    
    [self updateMapDisplayRegion];
    [self renderAnnotations];
    [self.locationTableView reloadData];
}

//--------------------
// Combo box control
//--------------------
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [kml_files count];
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc {
    return [kml_files objectAtIndex:loc];
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    return [kml_files indexOfObject: string];
}

//--------------------
// Mouse event
//--------------------
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

- (void)mouseUp:(NSEvent *)theEvent{
}
@end
