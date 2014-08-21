//
//  SettingsViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}

- (IBAction)compassSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    int idx = [segmentedControl selectedSegment];
    switch (idx) {
        case 0:
            self.rootViewController.conventionalCompassVisible = NO;
            self.model->configurations[@"personalized_compass_status"] = @"off";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 1:
            self.rootViewController.conventionalCompassVisible = NO;
            self.model->configurations[@"personalized_compass_status"] = @"on";
            [self.rootViewController setFactoryCompassHidden:YES];
            break;
        case 2:
            self.rootViewController.conventionalCompassVisible = YES;
            self.model->configurations[@"personalized_compass_status"] = @"off";
            //        [self.glkView setHidden:YES];
            [self.rootViewController setFactoryCompassHidden:NO];
            break;
    }
    [self.rootViewController.compassView setNeedsDisplay:YES];
}

- (IBAction)wedgeSegmentControl:(id)sender {
    NSSegmentedControl *segmentedControl = (NSSegmentedControl *)sender;
    
    switch (segmentedControl.selectedSegment) {
        case 0:
            //-----------
            // None
            //-----------
            self.model->configurations[@"wedge_status"] = @"off";
            break;
        case 1:
            //-----------
            // Original
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"original";
            break;
        case 2:
            //-----------
            // Modified-Orthographic
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified-orthographic";
            break;
        case 3:
            //-----------
            // Modified-Perspctive
            //-----------
            self.model->configurations[@"wedge_status"] = @"on";
            self.model->configurations[@"wedge_style"] = @"modified-perspective";
            break;
        default:
            throw(runtime_error("Undefined control, update needed"));
            break;
            
    }
    [self.rootViewController.compassView setNeedsDisplay:YES];
}
@end
