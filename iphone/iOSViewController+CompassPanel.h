//
//  iOSViewController+CompassPanel.h
//  Compass[transparent]
//
//  Created by dmiau on 7/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController (WatchPanel)
- (IBAction)watchModeSegmentControl:(id)sender;


- (IBAction)compassSegmentControl:(id)sender;
- (IBAction)compassLocationSegmentControl:(id)sender;
- (IBAction)labelSegmentControl:(id)sender;
@end
