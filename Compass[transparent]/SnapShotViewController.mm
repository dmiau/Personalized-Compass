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
    if (self.rootViewController.testManager->testManagerMode == OFF){
        self.studyModeSegmentControl.selectedSegment = 0;
    }else{
        self.studyModeSegmentControl.selectedSegment = 1;
    }
}


- (void)updateSnapshotFileList{
    // Collect a list of files
    NSString *path = self.model->desktopDropboxDataRoot;
    
    NSArray *dirFiles = [[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath: path error:nil];
    
    snapshot_file_array = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.snapshot'"]];
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
    
    if (self.rootViewController.testManager->testManagerMode ==
        OFF)
    {
        //--------------
        // Call displaySnapshot directly when testManager is OFF
        //--------------
        [self.rootViewController displaySnapshot:ind
                               withStudySettings:OFF];
    }else{
        //--------------
        // During the study, need to call showTestNumber to
        // log some extra data and start a new test.
        // This is very important!
        //--------------
        self.rootViewController.testManager->showTestNumber(ind);
    }
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
    string warning_message;
    switch (state) {
        case 0:
            //-------------------
            // Disable study mode
            //-------------------
            self.rootViewController.testManager->toggleStudyMode(NO, YES);
            self.rootViewController.renderer->label_flag = true;

            self.rootViewController.isShowAnswerAvailable = [NSNumber numberWithBool:NO];
            self.rootViewController.isDistanceEstControlAvailable =
            [NSNumber numberWithBool:NO];

            
            break;
        case 1:
            //-------------------
            // Enable study mode
            //-------------------
         
            if (self.rootViewController.socket_status)
            {
                warning_message =
                 string("An open connection is detected.\n") +
                 string("To sync with iOS, iOS needs to be manually put to the study mode (and choose the correct snapshot file).\n\n");
            }
            
            if ([self.rootViewController.model->desktopDropboxDataRoot
                 rangeOfString:@"study"].location != NSNotFound){
                warning_message = warning_message +
                string("You are in a study* folder.") +
                string("You need to manually change the folder on the iOS side and enable the study mode.");
            }

            if (warning_message.length() != 0){
                self.rootViewController.testManager->toggleStudyMode(YES, NO);
                [self.rootViewController displayPopupMessage:
                 [NSString stringWithUTF8String:warning_message.c_str()]];
            }else{
                self.rootViewController.testManager->toggleStudyMode(YES, YES);
            }
            self.rootViewController.testManager->applyDevConfigurations();               
            break;
        default:
            break;
    }
}

- (IBAction)fillInOSXCoordRegion:(id)sender {
    self.rootViewController.testManager->
    calculateMultipleLocationsDisplayRegion();
}

@end
