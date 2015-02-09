//
//  ConfigurationsWindowController+locations.m
//  Compass[transparent]
//
//  Created by dmiau on 1/12/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController.h"
#import "LocationCellView.h"
#import "OSXPinAnnotationView.h"
#include "xmlParser.h"

@implementation ConfigurationsWindowController (locations)

- (void)updateLocationsPane{
    
    // Collect a list of kml files
    NSString *path = self.model->desktopDropboxDataRoot;
    
    NSArray *dirFiles = [[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath: path error:nil];
    kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
    [self.kmlComboBox reloadData]; // Refresh the KML list
    
    // Initialize the combo box
    [self.kmlComboBox setStringValue:
     [self.model->location_filename
      lastPathComponent]];

    // Update the table
    [self.locationTableView reloadData];
    
    // Update all the controls    

    // Update the state of landmark lock
    self.landmarkLock.state = self.model->lockLandmarks;

    //-----------------
    // Update compass model control
    //-----------------
    
    // Update data pre-filtering control
    NSString *prefilter_type = self.model->configurations[@"prefilter_param"];
    
    if ([prefilter_type isEqualToString:@"NONE"]){
        self.dataPrefilterControl.selectedSegment = 0;
    }else if ([prefilter_type isEqualToString:@"CLUSTER"]){
        self.dataPrefilterControl.selectedSegment = 1;
    }else if ([prefilter_type isEqualToString:@"CLOSEST"]){
        self.dataPrefilterControl.selectedSegment = 2;
    }
    
    // Update data selection control
    NSString *filter_type = self.model->configurations[@"filter_type"];
    
    if ([filter_type isEqualToString:@"K_ORIENTATIONS"]){
        self.dataSelectionControl.selectedSegment = 0;
    }else if ([filter_type isEqualToString:@"NONE"]){
        self.dataSelectionControl.selectedSegment = 1;
    }else if ([filter_type isEqualToString:@"MANUAL"]){
        self.dataSelectionControl.selectedSegment = 2;
    }

    //-----------------
    // Update annotation control
    //-----------------

    // Update showPin segment control
    if ([self.rootViewController.UIConfigurations[@"ShowPins"] isEqualToString:@"None"]){
        self.showPinSegmentControl.selectedSegment = 0;
    }else if ([self.rootViewController.UIConfigurations[@"ShowPins"] isEqualToString:@"Enabled"]){
        self.showPinSegmentControl.selectedSegment = 1;
    }else if([self.rootViewController.UIConfigurations[@"ShowPins"] isEqualToString:@"Dropped"]){
        self.showPinSegmentControl.selectedSegment = 2;
    }else if([self.rootViewController.UIConfigurations[@"ShowPins"] isEqualToString:@"All"]){
        self.showPinSegmentControl.selectedSegment = 3;
    }
    
    // Update pin creation segment control
    if (self.rootViewController.UIConfigurations[@"UIAcceptsPinCreation"]==
        [NSNumber numberWithBool:true])
    {
        self.createPinSegmentControl.selectedSegment = 0;
    }else{
        self.createPinSegmentControl.selectedSegment = 1;
    }
    
    // Update multiple annotation segment control
    if (self.rootViewController.UIConfigurations
        [@"UIAllowMultipleAnnotations"] == [NSNumber numberWithBool:NO]){
        self.multipleAnnotationsControl.selectedSegment = 0;
    }else{
        self.multipleAnnotationsControl.selectedSegment = 1;
    }
}

#pragma mark ------------Annotation Control------------
//-----------------
// Pins
//-----------------
- (IBAction)pinSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    NSString *label = [segmentedControl labelForSegment:
                       [segmentedControl selectedSegment]];
    [self.rootViewController changeAnnotationDisplayMode:label];
}

- (IBAction)createPinSegmentControl:
(NSSegmentedControl*) segmentedControl
{
    int idx = [segmentedControl selectedSegment];
    switch (idx) {
        case 0:
            self.rootViewController.UIConfigurations[@"UIAcceptsPinCreation"]=
            [NSNumber numberWithBool:true];
            break;
        case 1:
            self.rootViewController.UIConfigurations[@"UIAcceptsPinCreation"]=
            [NSNumber numberWithBool:false];
            break;
        case 2:
            NSArray* annotation_array = self.rootViewController.mapView.annotations;
            for (CustomPointAnnotation* annotation in annotation_array){
                if (annotation.point_type == dropped){
                    [self.rootViewController.mapView removeAnnotation:annotation];
                }
            }
            break;
    }
}

//-----------------
// annotationNumberSegmentControl controls whether multiple callouts
// can be shown at the same time or not.
//-----------------
- (IBAction)annotationNumberSegmentControl:(NSSegmentedControl*)sender {
    
    bool canShowCallout = false;
    
    switch (sender.selectedSegment) {
        case 0:
            self.rootViewController.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:NO];
            canShowCallout = true;
            break;
        case 1:
            self.rootViewController.UIConfigurations
            [@"UIAllowMultipleAnnotations"] = [NSNumber numberWithBool:YES];
            canShowCallout = false;
            break;
    }
    
    for (id<MKAnnotation> annotation in
         self.rootViewController.mapView.annotations){
        OSXPinAnnotationView* pinView =
        (OSXPinAnnotationView*)
        [self.rootViewController.mapView
         viewForAnnotation: annotation];
        pinView.canShowCallout = canShowCallout;
        
        if (canShowCallout){
            [pinView showCustomCallout:NO];
        }
    }
}


#pragma mark ------------table------------
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
    [self.rootViewController updateMapDisplayRegion: YES];
    //    [tableView reloadData];
}

- (IBAction)refreshLocationTable:(id)sender {
    [self.locationTableView reloadData];
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
    [self.rootViewController updateMainGUI];
}

//-----------------------
// Combo box control
//-----------------------
- (IBAction)didChangeKMLCombo:(id)sender {
    NSString* astr = [self.kmlComboBox stringValue];
    
    if ([self.model->location_filename isEqualToString:
         [self.model->desktopDropboxDataRoot stringByAppendingPathComponent:astr]])
    {
        // Somehow this method is called whenever a tab is switched.Do nothing
        // if the selection of location_file does not change
        return;
    }
    
    // Load the file from the Dropbox root
    self.model->location_filename = [self.model->desktopDropboxDataRoot
                                     stringByAppendingPathComponent:astr];
    readLocationKml(self.model, self.model->location_filename);
    
    self.model->camera_pos.name = self.model->data_array[0].name;
    // Set the initial orientation to 0
    self.model->camera_pos.orientation = 0;
    self.model->camera_pos.latitude = self.model->data_array[0].latitude;
    self.model->camera_pos.longitude = self.model->data_array[0].longitude;
    
    self.model->updateMdl();
    NSLog(@"json combo triggered %@", astr);
        
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
//    [self.locationTableView selectRowIndexes:indexSet byExtendingSelection:NO];
//    
//    //Begin editing of the cell containing the new object
//    [self.locationTableView editColumn:0 row:0 withEvent:nil select:YES];

    [self.rootViewController updateMapDisplayRegion: NO];
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


#pragma mark ------------Data Export------------
//-------------
// Save file
//-------------
- (IBAction)saveKML:(id)sender {
    
    NSString *filename =
    [self.model->location_filename lastPathComponent];
    [self saveKMLWithFilename:filename];
    
}

- (IBAction)saveKMLAs:(id)sender {
    
    NSString* filename =
    [self input: @"Please input a file name:" defaultValue:@"nweKml.kml"];
    if ([filename rangeOfString:@".kml"].location == NSNotFound) {
        filename = [filename stringByAppendingString:@".kml"];
    }
    [self saveKMLWithFilename:filename];
    
    // There are some more works to do at the point
    
    // At this point we are operating on the new file
    self.model->location_filename = filename;
    // Initialize the combo box
    [self.kmlComboBox setStringValue:
     [self.model->location_filename
      lastPathComponent]];
}

- (BOOL) saveKMLWithFilename:(NSString*) filename{
    bool hasError = false;
    NSString *content = genKMLString(self.model->data_array);
    
    NSError* error;
    NSString *doc_path = [self.model->desktopDropboxDataRoot stringByAppendingPathComponent:filename];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSASCIIStringEncoding
                        error:&error])
    {
        
        NSAlert *alert = [NSAlert alertWithMessageText:
                          [NSString stringWithFormat:@"Write %@ failed", doc_path]
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        [alert runModal];
        return false;
    }
    return true;
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %d", button);
        return nil;
    }
}
@end
