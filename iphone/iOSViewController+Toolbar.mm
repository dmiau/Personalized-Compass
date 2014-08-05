//
//  iOSViewController+Toolbar.m
//  Compass[transparent]
//
//  Created by dmiau on 6/23/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Toolbar.h"
#import "iOSSettingViewController.h"

@implementation iOSViewController (Toolbar)

#pragma mark ------Toolbar construction------
- (void)constructDebugToolbar:(NSString*) mode{
    
    NSArray* title_list = @[@"[View]", @"[Mdl]", @"[Compass]", @"[Debug]"];
    NSArray* selector_list =
    @[@"toggleViewPanel:", @"toggleModelPanel:",
      @"toggleWatchPanel:", @"toggleDebugView:"];
    
    NSMutableArray* toolbar_items =[[NSMutableArray alloc] init];

    //--------------
    // Add buttons
    //--------------
    for (int i = 0; i < [title_list count]; ++i){
        SEL my_selector = NSSelectorFromString(selector_list[i]);
        
        UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
                                             initWithTitle:title_list[i]
                                             style:UIBarButtonItemStyleBordered                                             target:self
                                             action:my_selector];
        [toolbar_items addObject:anItem];
    }

    //--------------
    // Landscape mode
    //--------------
    if ([mode isEqualToString:@"Landscape"]){
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil action:nil];
        [toolbar_items addObject:flexItem];
        
        UIBarButtonItem *lockItem = [[UIBarButtonItem alloc]
                                     initWithTitle:@"[Lock]"
                                     style:UIBarButtonItemStyleBordered                                             target:self
                                     action:@selector(rotationLockClicked:)];
        [toolbar_items addObject:lockItem];
    }
    
    //--------------
    // Add the bookmark button
    //--------------
    
#ifdef __IPAD__
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil action:nil];
    [toolbar_items addObject:flexItem];
#endif
    
    UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
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
    //            [self.toolbar setShadowImage:[UIImage new]
    //                      forToolbarPosition:UIToolbarPositionAny];
    [self.toolbar setNeedsDisplay];
    
}

-(void) constructDemoToolbar:(NSString*)mode{
    
    NSArray* title_list = @[@"[Pre.]", @"[Next]"];
    
    NSMutableArray* toolbar_items =[[NSMutableArray alloc] init];
    
    // Add the counter
    NSString* counter_str = [NSString stringWithFormat:
                             @"1/%lu", self.model->snapshot_array.size()];
    counter_button = [[UIBarButtonItem alloc]
                      initWithTitle:counter_str
                      style:UIBarButtonItemStyleBordered                                             target:self
                      action:nil];
    [toolbar_items addObject:counter_button];
    
    
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
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil action:nil];
    [toolbar_items addObject:flexItem];
    
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

#pragma mark ------Toolbar Items------
- (void) setFactoryCompassHidden: (BOOL) flag {
    NSArray *mapSubViews = self.mapView.subviews;
    
    for (UIView *view in mapSubViews) {
        // Checks if the view is of class MKCompassView
        if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
            [view setHidden:flag];
            //            // Removes view from mapView
            //            [view removeFromSuperview];
        }
    }
}





//------------------
// Close all panels
//------------------

- (void) hideAllPanels{
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    for (UIView* aView in dialog_array){
        [aView setHidden:YES];
        
    }
}

//------------------
// Show pcomass in big size
//------------------
- (IBAction)toggleWatchPanel:(id)sender {

    if ([[self watchPanel] isHidden]){
        [self hideAllPanels];
        [[self watchPanel] setHidden:NO];
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"personalized_compass_status"]
             isEqualToString:@"on"])
        {
            self.compassSegmentControl.selectedSegmentIndex = 1;
        }else if (self.conventionalCompassVisible){
            self.compassSegmentControl.selectedSegmentIndex = 0;
        }else{
            self.compassSegmentControl.selectedSegmentIndex = 2;
        }
        
    }else{
        [[self watchPanel] setHidden:YES];
    }
}

//------------------
// Show the menu view
//------------------
- (IBAction)toggleModelPanel:(id)sender {

    if ([[self modelPanel] isHidden]){
        [self hideAllPanels];
        [[self modelPanel] setHidden:NO];
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"prefilter_param"]
             isEqualToString:@"NONE"])
        {
            self.dataSegmentControl.selectedSegmentIndex = 0;
        }else if ([self.model->configurations[@"prefilter_param"]
                   isEqualToString:@"CLUSTER"]){
            self.dataSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.dataSegmentControl.selectedSegmentIndex = 2;
        }
        
        if ([self.model->configurations[@"filter_type"]
             isEqualToString:@"K_ORIENTATIONS"])
        {
            self.filterSegmentControl.selectedSegmentIndex = 0;
        }else if ([self.model->configurations[@"filter_type"]
                   isEqualToString:@"NONE"]){
            self.filterSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.filterSegmentControl.selectedSegmentIndex = 2;
        }
                
    }else{
        [[self modelPanel] setHidden:YES];
        
        if (self.needUpdateDisplayRegion)
            [self updateMapDisplayRegion];
    }
}

- (IBAction)toggleViewPanel:(id)sender {

    if ([[self viewPanel] isHidden]){
        [self hideAllPanels];
        [[self viewPanel] setHidden:NO];
        
        
        //--------------
        // Reconfigure the panel
        //--------------
        if ([self.model->configurations[@"personalized_compass_status"]
             isEqualToString:@"on"])
        {
            self.overviewSegmentControl.selectedSegmentIndex = 2;
        }else if (![self.overviewMapView isHidden]){
            self.overviewSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.overviewSegmentControl.selectedSegmentIndex = 0;
        }
        
    }else
        [[self viewPanel] setHidden:YES];
}


- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugPanel] isHidden]){
        [self hideAllPanels];
        [[self debugPanel] setHidden:NO];
    }else{
        [[self debugPanel] setHidden:YES];
    }
}

- (IBAction)refreshApp:(id)sender {
    [self initMapView];
}

- (void)segueToTabController:(id)sender{
    [self performSegueWithIdentifier:@"Go2TabBarController" sender:nil];
}

#pragma mark ------Demo actions------
- (void)runDemoAction:(UIBarButtonItem*) bar_button{

    NSString* label = bar_button.title;
    static int snapshot_id = 0;
    static bool mask_status = false;
    
    if ([label isEqualToString:@"[Pre.]"]){
        snapshot_id = max(snapshot_id-1, 0);
        [self displaySnapshot:snapshot_id];
        // Set the visualization to the first
        [self loopVisualizations:[self resetVisualizationButton]];
    }else if ([label isEqualToString:@"[Next]"]){
        snapshot_id = min(snapshot_id+1,
                          (int)self.model->snapshot_array.size()-1);
        [self displaySnapshot:snapshot_id];
        // Set the visualization to the first
        [self loopVisualizations:[self resetVisualizationButton]];
        
    }else if ([label isEqualToString:@"[Mask]"]){
        
        if (mask_status){
            [mapMask removeFromSuperlayer];
        }else{
            mapMask.backgroundColor = [[UIColor whiteColor] CGColor];
            mapMask.frame = CGRectMake(0, 0,
                                       self.mapView.frame.size.width,
                                       self.mapView.frame.size.height);
            mapMask.opacity = 1;
            
            [self.mapView.layer addSublayer:mapMask];
        }
        mask_status = !mask_status;
    }
    counter_button.title = [NSString stringWithFormat:
                     @"%d/%lu", snapshot_id+1,
                     self.model->snapshot_array.size()];
}

- (UIBarButtonItem*) resetVisualizationButton{
    self.testManager->visualization_counter = 0;
    NSString *visTitle = [NSString stringWithFormat:@"[%@]",
                          self.testManager->visualizationEnum2String
                          [self.testManager->visualization_for_test[0]]];
    static UIBarButtonItem* anItem = [[UIBarButtonItem alloc]
              initWithTitle:visTitle
              style:UIBarButtonItemStyleBordered                                             target:self
              action:@selector(loopVisualizations:)];
    anItem.title = visTitle;
    return anItem;
}

- (void)loopVisualizations:(UIBarButtonItem*) bar_button{
    int idx = self.testManager->visualization_counter;
    
    CPVisualizationType current_type =
    self.testManager->visualization_for_test[idx];
    
    switch (current_type) {
        case CPNone:
            [self toggleOverviewMap:NO];
            [self togglePCompass:NO];
            [self toggleWedge:NO];
            break;
        case CPPCompass:
            [self toggleOverviewMap:NO];
            [self toggleWedge:NO];
            [self togglePCompass:YES];
            break;
        case CPWedge:
            [self toggleOverviewMap:NO];
            [self togglePCompass:NO];
            [self toggleWedge:YES];
            break;
        case CPOverview:
            [self togglePCompass:NO];
            [self toggleWedge:NO];
            [self toggleOverviewMap:YES];
            break;
        default:
            break;
    }
    
    // Calculat the next type
    idx = idx + 1;
    idx = idx % self.testManager->visualization_for_test.size();
    self.testManager->visualization_counter = idx;
    // Update the title
    bar_button.title = [NSString stringWithFormat:@"[%@]",
    self.testManager->visualizationEnum2String
    [self.testManager->visualization_for_test[idx]]];
}

#pragma mark -----Rotation related stuff-----

- (void)rotationLockClicked:(id)sender {
    
    UIBarButtonItem* button = (UIBarButtonItem*) sender;
    
    bool lock_status = [self.UIConfigurations[@"UIRotationLock"]
                        boolValue];
    
    if (lock_status){
        button.title = @"[Lock]";
    }else{
        button.title = @"[Unlock]";
    }
    
    self.UIConfigurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:
     ![self.UIConfigurations[@"UIRotationLock"] boolValue]];
}

@end
