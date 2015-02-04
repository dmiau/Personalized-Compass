//
//  ConfigurationsWindowController.m
//  Compass[transparent]
//
//  Created by dmiau on 12/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "ConfigurationsWindowController.h"


@interface ConfigurationsWindowController ()

@end

@implementation ConfigurationsWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    // Important, initialize NSMutableArray with empty cells
//    tableCellCache = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < self.rootViewController.model->data_array.size(); ++i)
//    {
//        [tableCellCache addObject:[NSNull null]];
//    }
}


- (id)initWithWindowNibName: (NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        // Initialization code here.
        self.model = compassMdl::shareCompassMdl();
        
        // Collect a list of kml files
        NSString *path = self.model->desktopDropboxDataRoot;
        
        NSArray *dirFiles = [[NSFileManager defaultManager]
                             contentsOfDirectoryAtPath: path error:nil];
        kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
        
        //-------------
        // Initialize test parameters
        //-------------
        self.close_begin_x = [NSNumber numberWithFloat:1.5];
        self.close_end_x = [NSNumber numberWithFloat:3];
        self.far_begin_x = [NSNumber numberWithFloat:3];
        self.far_end_x = [NSNumber numberWithFloat:10];
        
        self.close_n = [NSNumber numberWithInteger:5];
        self.far_n = [NSNumber numberWithInteger:5];
        
        self.participant_n = [NSNumber numberWithInteger:100];
        self.participant_id = [NSNumber numberWithInteger:0];
    }
    return self;
}

//---------------------
// Tab is switched
//---------------------
- (void)tabView:(NSTabView *)tabView
willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSString *tab_label = tabViewItem.label;
    
    if ([tab_label isEqualToString:@"Configurations"]){
        
    }else if ([tab_label isEqualToString:@"Locations"]){
        // Need to refresh the Locations pane
        [self updateLocationsPane];
    }else if ([tab_label isEqualToString:@"SnapShots"]){
    
    }else if ([tab_label isEqualToString:@"Test Manager"]){
        
    }else if ([tab_label isEqualToString:@"Test Cases"]){
        
    }

}

//---------------------
// This method is called to prepare the location window
//---------------------
- (void) prepareWindow{
        
    // Update all the switches
    
    
    // Initialize the combo box
    [self.kmlComboBox setStringValue:
     [self.model->location_filename
      lastPathComponent]];
    
    // Update the dropbox root
    [self.desktopDropboxDataRoot setStringValue:
    self.model->desktopDropboxDataRoot];

    // Update the table
    [self.locationTableView reloadData];
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
    //    [self.rootViewController.compassView setNeedsDisplay:YES];
    [self.rootViewController.compassView display];
}


@end
