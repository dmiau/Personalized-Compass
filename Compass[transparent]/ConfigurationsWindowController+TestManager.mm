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
    }
    
    // Generate tests
    self.rootViewController.testManager->generateTests();
}
@end
