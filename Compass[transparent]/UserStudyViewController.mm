//
//  UserStudyViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 2/18/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "UserStudyViewController.h"
#import "snapshotParser.h"
#import "HTTPServer.h"
#import "GCDAsyncSocket.h"

@interface UserStudyViewController ()

@end

@implementation UserStudyViewController

- (id) initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self){
        
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Initialize the object
        AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
        self.rootViewController = appDelegate.rootViewController;
        self.testMessage = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serverInfoString = @"Server info: N/A";
    
    // Initialize GUI parameters here
    self.participant_id = [NSNumber numberWithInt:0];
    
    [self disableStudyButtons];
}

- (void)disableStudyButtons{
    // Make a bunch of buttons disabled at initialization
    self.isPracticeButtonEnabled = [NSNumber numberWithBool:NO];
    self.isResumeButtonEnabled = [NSNumber numberWithBool:NO];
    self.isPauseButtonEnabled = [NSNumber numberWithBool:NO];
    self.isResumeButtonEnabled = [NSNumber numberWithBool:NO];
    self.isEndButtonEnabled = [NSNumber numberWithBool:NO];
}

- (void)viewWillAppear{
    
    if ([self.rootViewController.model->desktopDropboxDataRoot rangeOfString:@"study"].location == NSNotFound){
        // Change the folder to the study folder
        self.rootViewController.model->desktopDropboxDataRoot =
        [self.rootViewController.model->desktopDropboxDataRoot stringByAppendingPathComponent: @"study"];
    }
    
    // Update file path info
    
    // Check if the files exist
    NSString* dbRoot = self.rootViewController.model->desktopDropboxDataRoot;
    
    self.snapshot_filepath = [dbRoot stringByAppendingPathComponent:
                              [self.rootViewController.testManager->test_snapshot_prefix
                               stringByAppendingFormat:@"%@.snapshot", self.participant_id]];
    
    NSString* record_filename = [NSString stringWithFormat:
                                 @"participant%@.record", self.participant_id];
    self.record_filepath = [dbRoot stringByAppendingPathComponent:
                            record_filename];
    
    self.test_kml_path = [dbRoot stringByAppendingPathComponent:
                          self.rootViewController.testManager->test_kml_filename];
    
    
    // Update GUI components
    self.recordFileNameTextField.stringValue =
    self.rootViewController.testManager->record_filename;
    
    // Set up the study mode segment control
    if (self.rootViewController.testManager->testManagerMode == OFF){
        self.studyModeSegmentControl.selectedSegment = 0;
    }else if (self.rootViewController.testManager->testManagerMode == OSXSTUDY){
        self.studyModeSegmentControl.selectedSegment = 1;
    }else if (self.rootViewController.testManager->testManagerMode == REVIEW){
        self.studyModeSegmentControl.selectedSegment = 2;
    }else{
        throw(runtime_error("Unknown testManagerMode"));
    }
    
    
    if ([self.rootViewController.socket_status boolValue]){
        
        //---------------
        // Display port information
        //---------------
        int port = [[self.rootViewController.httpServer asyncSocket] localPort];
        NSString* ip_string;
        // Find the string starting with number
        for (NSString* anItem : [[NSHost currentHost] addresses]){
            if (isnumber([anItem characterAtIndex:0]))
            {
                ip_string = anItem;
                break;
            }
        }
        
        self.serverInfoString = [NSString stringWithFormat:@"Server IP: %@, port: %d",
                                 ip_string, port];
    }
    self.testMessage = [NSString stringWithFormat:@"Dir: %@",
                        self.model->desktopDropboxDataRoot];
}

- (void)viewWillDisappear{
    
    if (self.rootViewController.testManager->testManagerMode == OFF){
        
        if ([self.rootViewController.model->desktopDropboxDataRoot rangeOfString:@"study"].location != NSNotFound){
            // Change the folder to the default folder
            self.rootViewController.model->desktopDropboxDataRoot =
            [self.rootViewController.model->desktopDropboxDataRoot stringByDeletingLastPathComponent];
        }
    }
}


#pragma mark ----------------GUI interaction---------------

//-----------------
// Load study files
//-----------------
- (IBAction)loadStudyFiles:(id)sender {
    // Check if the files exist
    NSString* dbRoot = self.rootViewController.model->desktopDropboxDataRoot;
    
    
    self.snapshot_filepath = [dbRoot stringByAppendingPathComponent:
                              [self.rootViewController.testManager->test_snapshot_prefix
                               stringByAppendingFormat:@"%@.snapshot", self.participant_id]];
    
    NSString* record_filename = [NSString stringWithFormat:
                                 @"participant%@.record", self.participant_id];
    self.record_filepath = [dbRoot stringByAppendingPathComponent:
                            record_filename];
    
    self.test_kml_path = [dbRoot stringByAppendingPathComponent:
                          self.rootViewController.testManager->test_kml_filename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:
          self.snapshot_filepath]){
        [self.rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"%@ was not found.", self.snapshot_filepath]];
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:
          self.test_kml_path]){
        [self.rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"%@ was not found.", self.test_kml_path]];
        return;
    }
    

    // Check if a record file already exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:
          self.record_filepath])
    {
        [self.rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"%@ already exists.", self.record_filepath]];
        return;
    }else{
        // Update record filename
        self.rootViewController.testManager->record_filename =
        record_filename;
        self.recordFileNameTextField.stringValue = record_filename;
    }
    
    // Load the snapshot file and enable other buttons
    self.rootViewController.model->snapshot_filename =
    [self.snapshot_filepath lastPathComponent];
    
    if (readSnapshotKml(self.rootViewController.model) != EXIT_SUCCESS){
        [self.rootViewController displayPopupMessage:
         [NSString stringWithFormat:@"Failed to laod %@",
          self.rootViewController.model->snapshot_filename]];
        return;
    }else{
        self.isPracticeButtonEnabled = [NSNumber numberWithBool:YES];
        self.rootViewController.testManager->applyPracticeConfigurations();
        self.rootViewController.testManager->isLocked = YES;
    }
}

//-----------------
// Toggle study mode
//-----------------
- (IBAction)toggleStudyMode:(NSSegmentedControl*)sender {
    
    switch (sender.selectedSegment) {
        case 0:
            // Study mode
            self.rootViewController.isVerboseMessageOn =
            [NSNumber numberWithBool:NO];
            break;
        case 1:
            // Dev
            self.rootViewController.isVerboseMessageOn =
            [NSNumber numberWithBool:YES];
            break;
        case 2:
            // Do nothing at the moment
            break;
        default:
            break;
    }
}

- (IBAction)resetTestEnv:(id)sender {
    self.rootViewController.testManager->toggleStudyMode(OFF, YES);
    [self disableStudyButtons];
}


//-----------------
// Save the study record
//-----------------
- (IBAction)saveStudyRecords:(id)sender {
    self.record_filepath = [self.model->desktopDropboxDataRoot
                            stringByAppendingPathComponent:
                            self.recordFileNameTextField.stringValue];
    self.rootViewController.testManager->saveRecord(
    self.record_filepath);
}

//-----------------
// Change record file name
//-----------------
- (IBAction)changeRecordFileName:(NSTextField*)sender {
    self.rootViewController.testManager->record_filename =
    self.recordFileNameTextField.stringValue;
}

- (IBAction)checkPairingAndStartPracticing:(id)sender {
    if (self.rootViewController.testManager->testManagerMode != OSXSTUDY)
    {
        [self.rootViewController displayPopupMessage:@"Enable the study mode from iOS"];
        self.rootViewController.testManager->isLocked = YES;
        return;
    }

    if (![[self.snapshot_filepath lastPathComponent] isEqualToString:
          self.model->snapshot_filename])
    {
        [self.rootViewController displayPopupMessage:@"Snapshot files mismatch (between iOS and OSX)"];
        self.rootViewController.testManager->isRecordAutoSaved = NO;
        self.rootViewController.testManager->toggleStudyMode(NO, NO);
        [self.rootViewController.informationView setHidden:YES];
        [self.rootViewController.mapView setHidden:NO];
        [self.rootViewController.compassView setHidden:NO];

        self.rootViewController.testManager->applyPracticeConfigurations();
        self.rootViewController.testManager->isLocked = YES;
        return;
    }
    
    self.rootViewController.testManager->isLocked = NO;
    
    self.rootViewController.testManager->applyPracticeConfigurations();    
    self.isEndPracticeButtonEnabled = [NSNumber numberWithBool:YES];
    self.isPauseButtonEnabled = [NSNumber numberWithBool:YES];
    self.isResumeButtonEnabled = [NSNumber numberWithBool:YES];
    self.isEndButtonEnabled = [NSNumber numberWithBool:YES];
}

//--------------------
// End practice buttom loads the actual snapshot file
//--------------------
- (IBAction)endPracticingAndStartStudy:(id)sender {
    self.rootViewController.testManager->applyStudyConfigurations();
    self.rootViewController.testManager->isLocked = NO;
    
    // This is necessary since the test environment is locked at the point.
    self.rootViewController.testManager->showNextTest();
}


- (IBAction)pauseStudy:(id)sender {
}

- (IBAction)resumeStudy:(id)sender {
}

- (IBAction)endStudy:(id)sender {
    self.rootViewController.testManager->toggleStudyMode(OFF, YES);
    [self disableStudyButtons];
}
@end
