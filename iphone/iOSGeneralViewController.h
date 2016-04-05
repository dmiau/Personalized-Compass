//
//  iOSGeneralViewController.h
//  Compass[transparent]
//
//  Created by Daniel on 4/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSViewController.h"
#import <MapKit/MapKit.h>

@interface iOSGeneralViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;

- (IBAction)setMapSegmentControl:(id)sender;

@property iOSViewController* rootViewController;

@end
