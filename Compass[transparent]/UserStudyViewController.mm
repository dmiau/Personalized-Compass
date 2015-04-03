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
        // Watch socket status
        [self.rootViewController addObserver:
         [NSUserDefaults standardUserDefaults]
                                  forKeyPath:@"isTestManagerOn"
                                     options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
        
    }
    return self;
}

//---------------
// KVO code
//---------------
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // [todo] In the browser mode,
    // updates should not come from map! Need to fix this
    if ([keyPath isEqual:@"isTestManagerOn"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isTestManagerOn"])
        {
            [self disableStudyButtons];
        }
    }
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
                                 @"participant%@.dat", self.participant_id];
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
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            // Find the string starting with number
            for (NSString* anItem : [[NSHost currentHost] addresses]){
                if ([anItem rangeOfString:@":"].location == NSNotFound)
                {
                    NSString* ip_string;
                    self.serverInfoString = [NSString stringWithFormat:@"Server IP: %@, port: %d",
                                             ip_string, port];
//                    self.server_ip = anItem;
                    break;
                }
            }
        });
        
//        // Find the string starting with number
//        for (NSString* anItem : [[NSHost currentHost] addresses]){
//            if ([anItem rangeOfString:@":"].location == NSNotFound)
//            {
//                ip_string = anItem;
//                break;
//            }
//        }
        

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
    
    // First of all, disable the dev mode
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // getting an NSInteger
    [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isDevMode"];
    
    // Check if the files exist
    NSString* dbRoot = self.rootViewController.model->desktopDropboxDataRoot;
    self.snapshot_filepath = [dbRoot stringByAppendingPathComponent:
                              [self.rootViewController.testManager->test_snapshot_prefix
                               stringByAppendingFormat:@"%@.snapshot", self.participant_id]];
    
    NSString* record_filename = [NSString stringWithFormat:
                                 @"participant%@.dat", self.participant_id];
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
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
    }
}

//-----------------
// Toggle study mode
//-----------------
- (IBAction)toggleStudyMode:(NSSegmentedControl*)sender {
    
    switch (sender.selectedSegment) {
        case 0:
            // Study mode
            break;
        case 1:
            // Dev
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

- (IBAction)unlockTestManager:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isWaitingAdminCheck"];
}


//-----------------
// Save the study record
//-----------------
- (IBAction)saveStudyRecords:(id)sender {
    self.record_filepath = [self.model->desktopDropboxDataRoot
                            stringByAppendingPathComponent:
                            self.recordFileNameTextField.stringValue];
    self.rootViewController.testManager->saveRecord(
    self.record_filepath, false);
}

//-----------------
// Change record file name
//-----------------
- (IBAction)changeRecordFileName:(NSTextField*)sender {
    self.rootViewController.testManager->record_filename =
    self.recordFileNameTextField.stringValue;
}

- (IBAction)checkPairingAndStartPracticing:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (self.rootViewController.testManager->testManagerMode != OSXSTUDY)
    {
        [self.rootViewController displayPopupMessage:@"Enable the study mode from iOS"];
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
        return;
    }

    if (![[self.snapshot_filepath lastPathComponent] isEqualToString:
          self.model->snapshot_filename])
    {
        [self.rootViewController displayPopupMessage:@"Snapshot files mismatch (between iOS and OSX)"];
        self.rootViewController.testManager->isRecordAutoSaved = NO;
        self.rootViewController.testManager->toggleStudyMode(NO, YES);
        [self.rootViewController setInformationViewVisibility: NO];
        [self.rootViewController.mapView setHidden:NO];
        [self.rootViewController.compassView setHidden:NO];
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
        return;
    }
    [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isWaitingAdminCheck"];
    self.rootViewController.testManager->applyPracticeConfigurations();
    
    if (self.rootViewController.testManager->test_counter != 0){
        // First the very first one we don't need to advance
        self.rootViewController.testManager->showNextTest();
    }
    
    [self.rootViewController displayTestInstructionsByCode:
     self.model->snapshot_array[self.rootViewController.testManager->test_counter].name];
    
    self.isPauseButtonEnabled = [NSNumber numberWithBool:YES];
    self.isResumeButtonEnabled = [NSNumber numberWithBool:YES];
    self.isEndButtonEnabled = [NSNumber numberWithBool:YES];
}

//--------------------
// End practice buttom loads the actual snapshot file
//--------------------
- (IBAction)endPracticingAndStartStudy:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    int test_counter = self.rootViewController.testManager->test_counter;
    if ([self.model->snapshot_array[test_counter].name hasSuffix:@"t"]
        && ![self.model->snapshot_array[test_counter+1].name hasSuffix:@"t"])
    {
        self.rootViewController.testManager->applyStudyConfigurations();
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isWaitingAdminCheck"];
        
        // This is necessary since the test environment is locked at the point.
        self.rootViewController.testManager->showNextTest();
        [self.rootViewController displayTestInstructionsByCode:
         self.model->snapshot_array[self.rootViewController.testManager->test_counter].name];
    }else{
        [self.rootViewController displayPopupMessage:
         @"Something is not quite right. You should be at the boundary of practice block and the timed block, but you are not."];
    }
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
