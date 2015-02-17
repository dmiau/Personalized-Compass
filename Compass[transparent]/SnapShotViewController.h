//
//  SnapShotViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 2/2/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Forward declaration
class compassMdl;
@class DesktopViewController;

@interface SnapShotViewController : NSViewController
<NSTableViewDataSource, NSTableViewDelegate>{
    int selected_snapshot_id;
    
    NSArray* snapshot_file_array;
    bool dirty_flag;
}

@property (weak) IBOutlet NSTableView *myTableView;
@property compassMdl* model;
@property DesktopViewController *rootViewController;
@property (weak) IBOutlet NSComboBox *kmlComboBox;
@property (weak) IBOutlet NSSegmentedControl *studyModeSegmentControl;

//-----------
// kml combo box
//-----------
- (IBAction)didChangeKMLCombo:(id)sender;

- (IBAction)saveKML:(id)sender;
- (IBAction)saveSnspahotAs:(id)sender;
- (IBAction)reloadSnapshotFile:(id)sender;

- (IBAction)toggleStudyMode:(id)sender;

@end
