//
//  iOSViewController+TypeSelector.h
//  Compass[transparent]
//
//  Created by dmiau on 6/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController (ViewPanel)

- (IBAction)toggleOverviewMap:(id)sender;
- (IBAction)compassSegmentControl:(id)sender;
- (IBAction)toggleWedge:(id)sender;
- (IBAction)mapStyleSegmentControl:(id)sender;
- (IBAction)compassLocationSegmentControl:(id)sender;
- (IBAction)pinSegmentControl:(id)sender;

@end
