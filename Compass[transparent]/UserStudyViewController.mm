//
//  UserStudyViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 2/18/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "UserStudyViewController.h"

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
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear{
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
}

//-----------------
// Toggle study mode
//-----------------
- (IBAction)toggleStudyMode:(NSSegmentedControl*)sender {
    
    switch (sender.selectedSegment) {
        case 0:
            // Study mode is switched OFF
            self.rootViewController.testManager->toggleStudyMode(NO);
            break;
        case 1:
            // Study mode is switched ON            
            self.rootViewController.testManager->toggleStudyMode(YES);
            break;
        case 2:
            // Do nothing at the moment
            break;
        default:
            break;
    }
}


//-----------------
// Save the study record
//-----------------
- (IBAction)saveStudyRecords:(id)sender {
    self.rootViewController.testManager->saveRecord();
}

//-----------------
// Change record file name
//-----------------
- (IBAction)changeRecordFileName:(NSTextField*)sender {
    self.rootViewController.testManager->record_filename =
    self.recordFileNameTextField.stringValue;
}
@end
