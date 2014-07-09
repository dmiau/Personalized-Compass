//
//  DesktopViewController+TableAddition.m
//  Compass[transparent]
//
//  Created by dmiau on 4/1/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+TableAddition.h"
#import "LocationCellView.h"

@implementation DesktopViewController (TableAddition)


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
    
    LocationCellView *result;
    // check if a cached copy already exists
    if ([tableCellCache objectAtIndex:row] != (id)[NSNull null]){
        result = [tableCellCache objectAtIndex:row];
    }else{
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
        
        // Update dist here
        result.infoTextField.stringValue = [NSString stringWithFormat:@"%.2f (m)",
                                            self.model->data_array[row].distance];
        
        // Important--replacing, not insering
        [tableCellCache replaceObjectAtIndex: row withObject: result];
    }
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
    [self updateMapDisplayRegion];
//    [tableView reloadData];
}

@end
