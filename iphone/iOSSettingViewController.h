//
//  iOSSettingViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GLKit/GLKit.h>
#include "compassModel.h"
#include "compassRender.h"
#include <iostream>
#import "iOSGLKView.h"

#import "iOSViewController.h"

@interface iOSSettingViewController : UIViewController
{
    BOOL pinVisible;
    NSArray *kml_files;
}

@property compassMdl* model;
@property compassRender* renderer;
@property iOSViewController* mainViewController;
@property (weak, nonatomic) IBOutlet UIPickerView *dataPicker;

@end
