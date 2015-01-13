//
//  ConfigurationsWindowController+locations.m
//  Compass[transparent]
//
//  Created by dmiau on 1/12/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController+locations.h"
#import "LocationCellView.h"

@implementation ConfigurationsWindowController (locations)
#pragma mark table

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView{
    if ([[tableView identifier] isEqualToString:@"LocationTable"])
    {
        return self.model->data_array.size();
    }else{
        return 0;
    }
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Get the row ID
    
    LocationCellView *result;
    
    // check if a cached copy already exists

    // Retrieve to get the @"LocationTable" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    result =
    [tableView    makeViewWithIdentifier:@"LocationTable" owner:self];
    
    string location_name;
    location_name = self.model->data_array[row].name;
    
    result.textField.backgroundColor = [NSColor
                                        colorWithCalibratedRed: (float)self.model->color_map[row][0]/256
                                        green: (float)self.model->color_map[row][1]/256
                                        blue: (float)self.model->color_map[row][2]/256
                                        alpha: 1];
    
    result.textField.stringValue = [NSString stringWithCString:
                                    location_name.c_str()
                                                      encoding:
                                    [NSString defaultCStringEncoding]];
    // connect data_ptr and rootViewController
    result.data_ptr = &(self.model->data_array[row]);
    result.rootViewController = self.rootViewController;
    
    // Update dist here
    result.infoTextField.stringValue = @"N/A";
//    [NSString stringWithFormat:@"%.2f (m)", self.model->data_array[row].distance];
    [result.checkbox setState:result.data_ptr->isEnabled];
    result.isUserLocation = false;
//    // Important--replacing, not insering
//    [tableCellCache replaceObjectAtIndex: row withObject: result];
    return result;
}


//// We make the "group rows" have the standard height, while all other image rows have a larger height
//- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
//    return 70;
//}


- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification{
    NSTableView* tableView = [aNotification object];
    NSIndexSet *idx = [tableView selectedRowIndexes];
    //    NSLog(@"Selected Row: %@", idx);
    
    // Assume only one row is clicked
    int ind = (int)[idx firstIndex];
    
    //[todo] hwo to improve?
    self.model->camera_pos.name = self.model->data_array[ind].name;
    self.model->camera_pos.latitude = self.model->data_array[ind].latitude;
    self.model->camera_pos.longitude = self.model->data_array[ind].longitude;
    
    //    self.model->updateMdl();
    [self.rootViewController updateMapDisplayRegion];
    //    [tableView reloadData];
}


//-------------
// Table selection control
//-------------

- (IBAction)toggleLandmarkSelection:(NSButton*)sender {
    
    if ([[sender title] rangeOfString:@"All"].location != NSNotFound){
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = true;
        }
    }else{
        for (int i = 0; i < self.model->data_array.size(); ++i) {
            self.model->data_array[i].isEnabled = false;
        }
    }
    [self.locationTableView reloadData];
    self.rootViewController.renderAnnotations;
}

//-----------------------
// Combo box control
//-----------------------
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
    
    
//    [tableCellCache removeAllObjects];
    self.model->reloadFiles();
    
    
//    for (int i = 0; i < self.model->data_array.size(); ++i)
//    {
//        [tableCellCache addObject:[NSNull null]];
//    }
    
    [self.rootViewController updateMapDisplayRegion];
    [self.rootViewController renderAnnotations];
    [self.locationTableView reloadData];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [kml_files count];
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc {
    return [kml_files objectAtIndex:loc];
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    return [kml_files indexOfObject: string];
}
@end
