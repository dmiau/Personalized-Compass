//
//  DesktopViewController+RunStudy.m
//  Compass[transparent]
//
//  Created by Daniel on 2/17/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "DesktopViewController+RunStudy.h"

@implementation DesktopViewController (RunStudy)

- (IBAction)showNextTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.testManager->showNextTest();
    }
}

- (IBAction)showPreviousTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.testManager->showPreviousTest();
    }
}
@end
