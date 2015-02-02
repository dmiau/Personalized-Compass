//
//  ConfigurationsWindowController+TestManager.m
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController+TestManager.h"

@implementation ConfigurationsWindowController (TestManager)
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
@end
