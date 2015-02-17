//
//  iOSViewController+DemoToolbar.m
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@implementation iOSViewController (DemoToolbar)

//-----------------------
// Construct Demo toolbar
//-----------------------
-(void) constructDemoToolbar:(NSString*)mode{
    
    NSArray* title_list = @[@"[Pre.]", @"[Next]"];
    
    NSMutableArray* toolbar_items =[[NSMutableArray alloc] init];
    
    // Add the counter
    NSString* counter_str = [NSString stringWithFormat:
                             @"*/%lu", self.model->snapshot_array.size()];
    self.counter_button = [[UIBarButtonItem alloc]
                      initWithTitle:counter_str
                      style:UIBarButtonItemStyleBordered                                             target:self
                      action:nil];
    [toolbar_items addObject:self.counter_button];
    
    
    //--------------
    // Add buttons
    //--------------
    
    for (int i = 0; i < [title_list count]; ++i){
        UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
                                   initWithTitle:title_list[i]
                                   style:UIBarButtonItemStyleBordered                                             target:self
                                   action:@selector(runDemoAction:)];
        [toolbar_items addObject:anItem];
    }
    
    UIBarButtonItem *anItem;
    //--------------
    // Add visualization buttons
    //--------------
    anItem = [self resetVisualizationButton];
    [toolbar_items addObject:anItem];
    
    // Set the visualization to the first
    [self loopVisualizations:anItem];
    
    //--------------
    // Add a flexible separator
    //--------------
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil action:nil];
    [toolbar_items addObject:flexItem];
    
    //--------------
    // Add the mask buttons
    //--------------
    anItem = [[UIBarButtonItem alloc]
              initWithTitle:@"[Mask]"
              style:UIBarButtonItemStyleBordered                                             target:self
              action:@selector(runDemoAction:)];
    [toolbar_items addObject:anItem];
    
    //--------------
    // Add the bookmark button
    //--------------
    anItem = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
              target:self
              action:@selector(segueToTabController:)];
    [toolbar_items addObject:anItem];
    
    
    //--------------
    // Set toolboar style
    //--------------
    
    [self.toolbar setItems: toolbar_items];
    //            [self.toolbar setBarStyle:UIBarStyleDefault];
    self.toolbar.backgroundColor = [UIColor clearColor];
    self.toolbar.opaque = NO;
    [self.toolbar setTranslucent:YES];
    
    [self.toolbar setBackgroundImage:[UIImage new]
                  forToolbarPosition:UIBarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.toolbar setNeedsDisplay];
}

- (UIBarButtonItem*) resetVisualizationButton{
    self.demoManager->visualization_counter = 0;
    NSString *visTitle = [NSString stringWithFormat:@"[%@]",
                          self.demoManager->
                          enabled_visualization_vector[0].name];
    static UIBarButtonItem* anItem = [[UIBarButtonItem alloc]
                                      initWithTitle:visTitle
                                      style:UIBarButtonItemStyleBordered                                             target:self
                                      action:@selector(loopVisualizations:)];
    anItem.title = visTitle;
    return anItem;
}

- (void)loopVisualizations:(UIBarButtonItem*) bar_button{
    int idx = self.demoManager->visualization_counter;
    
    VisualizationType current_type = (VisualizationType)
    self.demoManager->enabled_visualization_vector[idx].type;
    
    switch (current_type) {
        case VIZNONE:
            [self toggleOverviewMap:NO];
            [self togglePCompass:NO];
            [self toggleWedge:NO];
            break;
        case VIZPCOMPASS:
            [self toggleOverviewMap:NO];
            [self toggleWedge:NO];
            [self togglePCompass:YES];
            break;
        case VIZWEDGE:
            [self toggleOverviewMap:NO];
            [self togglePCompass:NO];
            [self toggleWedge:YES];
            break;
        case VIZOVERVIEW:
            [self togglePCompass:NO];
            [self toggleWedge:NO];
            [self toggleOverviewMap:YES];
            break;
        default:
            break;
    }
    
    // Calculat the next type
    idx = idx + 1;
    idx = idx % self.demoManager->enabled_visualization_vector.size();
    self.demoManager->visualization_counter = idx;
    // Update the title
    bar_button.title = [NSString stringWithFormat:@"[%@]",
                        self.demoManager->enabled_visualization_vector[idx].name];
}

#pragma mark ------Demo actions------
//-------------------
// Main method to control the demo
//-------------------
- (void)runDemoAction:(UIBarButtonItem*) bar_button{
    
    NSString* label = bar_button.title;
    static int snapshot_id = 0;
    
    if (self.demoManager->device_counter ==-1){
        snapshot_id = 0;
        self.demoManager->device_counter = 0;
        [self setupEnvForTest:self.demoManager->enabled_device_vector[0].type];
    }
    
    if ([label isEqualToString:@"[Pre.]"]){

        snapshot_id = snapshot_id-1;
        if (snapshot_id < 0)
        {
            if (self.demoManager->device_counter != 0){
                // Set up the environment
                snapshot_id = self.model->snapshot_array.size() -1;
                [self setupEnvForTest:self.
                 demoManager->enabled_device_vector
                 [--self.demoManager->device_counter].type];
            }else{
                snapshot_id = 0;
            }
        }
        [self displaySnapshot:snapshot_id withStudySettings:OFF];

        // Set the visualization to the first
        [self loopVisualizations:[self resetVisualizationButton]];
        
    }else if ([label isEqualToString:@"[Next]"]){

        snapshot_id = snapshot_id+1;
        // Set up the environment
        if (snapshot_id == (int)self.model->snapshot_array.size())
        {
            if (self.demoManager->device_counter !=
                self.demoManager->enabled_device_vector.size()-1)
            {
                snapshot_id =0;
                [self setupEnvForTest:self.demoManager->
                 enabled_device_vector[++self.demoManager->device_counter].type];
            }else{
                --snapshot_id;
            }
        }
        
        [self displaySnapshot:snapshot_id withStudySettings:OFF];

        // Set the visualization to the first
        [self loopVisualizations:[self resetVisualizationButton]];
    }else if ([label isEqualToString:@"[Mask]"]){
        
        if (self.isBlankMapEnabled){
            [self toggleBlankMapMode:NO];
        }else{
            [self toggleBlankMapMode:YES];
        }
    }
    self.counter_button.title = [NSString stringWithFormat:
                            @"%d/%lu", snapshot_id+1,
                            self.model->snapshot_array.size()];    
    [self sendBoundaryLatLon];
}


- (void)setupEnvForTest:(int) type{
    if (type == PHONE){
        [self setupPhoneViewMode];
    }else{
        [self setupWatchViewMode];
    }
}

@end
