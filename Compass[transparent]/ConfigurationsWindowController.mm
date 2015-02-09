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
        [self updateConfigurationsPane];
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
    [self updateConfigurationsPane];
    [self updateLocationsPane];
}


@end
