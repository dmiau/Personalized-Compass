//
//  SnapShotViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 2/2/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "SnapShotViewController.h"
#import "AppDelegate.h"
#import "DesktopViewController.h"
#import "compassModel.h"
#import "snapshotParser.h"

@interface SnapShotViewController ()

@end

//--------------------
// The class is responsible for the loading of snapshots
//--------------------
@implementation SnapShotViewController

- (id) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Initialize the object
        AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
        self.rootViewController = appDelegate.rootViewController;
        
        selected_snapshot_id = -1;
        [self updateSnapshotFileList];
        
        self.isStudyMode = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

}

- (void)viewWillAppear{
    [self updateSnapshotFileList];
    
    // Initialize the combo box
    [self.kmlComboBox setStringValue:
     [self.model->snapshot_filename
      lastPathComponent]];
    
    // Update the table
    [self.myTableView reloadData];
    
    // Set the study mode
    self.studyModeSegmentControl.selectedSegment = (int) self.isStudyMode;
}


- (void)updateSnapshotFileList{
    // Collect a list of files
    NSString *path = self.model->desktopDropboxDataRoot;
    
    NSArray *dirFiles = [[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath: path error:nil];
    
    snapshot_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS 'snapshot'"]];
    [self.kmlComboBox reloadData];
}

#pragma mark -----Combo Box-----
//-----------------------
// Combo box control
//-----------------------
- (IBAction)didChangeKMLCombo:(id)sender {
    NSString* astr = [self.kmlComboBox stringValue];
    [self loadSnapshotWithName:astr];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [snapshot_file_array count];
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc {
    return [snapshot_file_array objectAtIndex:loc];
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    return [snapshot_file_array indexOfObject: string];
}


#pragma mark -----Table View Data Source Methods-----
- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView{
    return self.model->snapshot_array.size();
}

//----------------
// Populate each row of the table
//----------------
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView *cell;
    
    cell = [tableView makeViewWithIdentifier:@"myTableCell" owner:self];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Configure Cell
    cell.textField.stringValue = self.model->snapshot_array[row].name;
    
    //        cell.textLabel.text =
    //        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", row];
    
    return cell;
}


//----------------
// A cell is selected
//----------------
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification{
    NSTableView* tableView = [aNotification object];
    NSIndexSet *idx = [tableView selectedRowIndexes];
    //    NSLog(@"Selected Row: %@", idx);
    int ind = (int)[idx firstIndex];
        
    // Display a snapshot
    [self.rootViewController displaySnapshot:ind
                           withStudySettings: self.isStudyMode];
}

//----------------
// Load a new snapshot
//----------------
- (void)loadSnapshotWithName: (NSString*) filename{
    NSString* filename_cache = self.model->snapshot_filename;
    self.model->snapshot_filename = filename;
    if (readSnapshotKml(self.model)!= EXIT_SUCCESS){
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Fail to read the snapshot file."];
        self.model->snapshot_filename = filename_cache;
        [alert runModal];        
    }else{
        [self.myTableView reloadData];
    }
}

//----------------
// Toggle study mode
//----------------
- (IBAction)toggleStudyMode:(NSSegmentedControl*)sender {
    int state = [sender selectedSegment];
    switch (state) {
        case 0:
            self.isStudyMode = false;
            break;
        case 1:
            self.isStudyMode = true;
            break;
        default:
            break;
    }
}
@end
