//
//  iOSViewController+TypeSelector.h
//  Compass[transparent]
//
//  Created by dmiau on 6/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController (ViewPanel)

- (IBAction)overviewSegmentControl:(id)sender;


- (IBAction)mapStyleSegmentControl:(id)sender;


- (IBAction)wedgeSegmentControl:(id)sender;

- (IBAction)scaleSlider:(id)sender;

- (IBAction)toggleOverviewScaleSegmentControl:(id)sender;

- (IBAction)togglePOI:(id)sender;


@end
