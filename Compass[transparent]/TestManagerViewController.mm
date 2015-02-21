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
    self.close_begin_x = [NSNumber numberWithFloat:1.5];
    self.close_end_x = [NSNumber numberWithFloat:3];
    self.far_begin_x = [NSNumber numberWithFloat:3];
    self.far_end_x = [NSNumber numberWithFloat:10];
    
    self.close_n = [NSNumber numberWithInteger:5];
    self.far_n = [NSNumber numberWithInteger:5];
    
    self.participant_n = [NSNumber numberWithInteger:5];
    self.participant_id = [NSNumber numberWithInteger:0];
    
    // Visualization check box
    self.viz_pcompass = [NSNumber numberWithBool:YES];
    self.viz_wedge = [NSNumber numberWithBool:YES];
    self.viz_overview = [NSNumber numberWithBool:YES];
    
    // Display check box
    self.disp_phone = [NSNumber numberWithBool:YES];
    self.disp_watch = [NSNumber numberWithBool:YES];
    
    // Task check box
    self.task_locate = [NSNumber numberWithBool:YES];
    self.task_triangulate = [NSNumber numberWithBool:YES];
    self.task_orient = [NSNumber numberWithBool:YES];
    self.task_closest = [NSNumber numberWithBool:YES];
    
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
    self.rootViewController.testManager->close_begin_x =
    [self.close_begin_x floatValue];
    self.rootViewController.testManager->close_end_x =
    [self.close_end_x floatValue];
    
    self.rootViewController.testManager->far_begin_x =
    [self.far_begin_x floatValue];
    self.rootViewController.testManager->far_end_x =
    [self.far_end_x floatValue];
    
    self.rootViewController.testManager->close_n =
    [self.close_n intValue];
    
    self.rootViewController.testManager->far_n =
    [self.far_n intValue];
    
    self.rootViewController.testManager->participant_n =
    [self.participant_n intValue];
    
    self.rootViewController.testManager->participant_id =
    [self.participant_id intValue];
    
    // Generate tests
    self.rootViewController.testManager->generateTests();
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
