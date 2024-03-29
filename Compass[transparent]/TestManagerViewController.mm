//
//  TestManagerViewController.m
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManagerViewController.h"

@interface TestManagerViewController ()

@end

@implementation TestManagerViewController

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
    //-------------
    // Initialize test parameters
    //-------------
   
    self.participant_n = [NSNumber numberWithInteger:50];
    
    // File names
    // Initialize default output filenames
    self.test_foldername     = self.rootViewController.testManager->test_foldername;
    self.test_kml_filename   =self.rootViewController.testManager->test_kml_filename;
    self.test_location_filename  = self.rootViewController.testManager->test_location_filename;
    self.alltest_vector_filename = self.rootViewController.testManager->alltest_vector_filename;
    self.test_snapshot_prefix = self.rootViewController.testManager->test_snapshot_prefix;
    self.practice_filename = self.rootViewController.testManager->practice_filename;
    self.record_filename = self.rootViewController.testManager->record_filename;
    self.test_specs_filename = self.rootViewController.testManager->test_specs_filename;

    self.custom_test_vectorname = @"practice";
}

//--------------------------
// Generate tests automatically
//--------------------------
- (IBAction)generateTests:(id)sender {
    // Initial testManager if it is not initialized yet
    if (self.rootViewController.testManager == NULL){
        self.rootViewController.testManager =
        TestManager::shareTestManager();
        self.rootViewController.testManager->rootViewController
        = self.rootViewController;
    }
    
    // Populate the parameters to Testmanager
//    self.rootViewController.testManager->close_begin_x =
//    [self.close_begin_x floatValue];
//    self.rootViewController.testManager->close_end_x =
//    [self.close_end_x floatValue];
//    
//    self.rootViewController.testManager->far_begin_x =
//    [self.far_begin_x floatValue];
//    self.rootViewController.testManager->far_end_x =
//    [self.far_end_x floatValue];
//    
//    self.rootViewController.testManager->close_n =
//    [self.close_n intValue];
//    
//    self.rootViewController.testManager->far_n =
//    [self.far_n intValue];
    
    self.rootViewController.testManager->participant_n =
    [self.participant_n intValue];
    
    [self assignNamesToTestManager];
    
    // Generate tests
    self.rootViewController.testManager->generateTests();
}

- (IBAction)generateTestFromCustomVector:(id)sender {
    [self assignNamesToTestManager];
//    self.rootViewController.testManager->
//    generateCustomSnapshotFromVectorName(self.custom_test_vectorname);
}

- (IBAction)reloadTaskSpec:(id)sender {
    self.rootViewController.testManager->test_specs_filename = self.test_specs_filename;
    self.rootViewController.testManager->loadTestSpecPlist();
}

- (void) assignNamesToTestManager{
    // Assign the names
    self.rootViewController.testManager->test_foldername = self.test_foldername;
    self.rootViewController.testManager->test_kml_filename = self.test_kml_filename;
    self.rootViewController.testManager->test_location_filename = self.test_location_filename;
    self.rootViewController.testManager->alltest_vector_filename = self.alltest_vector_filename;
    self.rootViewController.testManager->test_snapshot_prefix = self.test_snapshot_prefix;
    self.rootViewController.testManager->record_filename = self.record_filename;
    self.rootViewController.testManager->test_specs_filename = self.test_specs_filename;
}
//--------------------------
// Manually test creation
//--------------------------

- (IBAction)resetManualTestCreation:(id)sender {
}

- (IBAction)addTestLocations:(id)sender {
}

- (IBAction)addiOSCoordRegion:(id)sender {
}

- (IBAction)addOSXCoordRegion:(id)sender {
}

- (IBAction)commitTestToMemory:(id)sender {
}

- (IBAction)generateManualTests:(id)sender {
}

- (IBAction)addiOSSnapshot:(id)sender {
}
@end
