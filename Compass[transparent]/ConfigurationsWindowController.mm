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
    
    self.rootViewController.model->desktopDropboxDataRoot =
    [self.rootViewController.model->desktopDropboxDataRoot stringByAppendingPathComponent:@"study"];
}


- (id)initWithWindowNibName: (NSString *)windowNibName{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        // Initialization code here.
        self.model = compassMdl::shareCompassMdl();
                

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
