//
//  generalVC.h
//  Compass[transparent]
//
//  Created by Hong Guo on 12/12/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#import "iOSViewController.h"


@interface generalVC : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *satelliteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *compassSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *widgetSwitch;
@property iOSViewController* rootViewController;




@end
