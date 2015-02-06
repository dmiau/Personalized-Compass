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
//-----------------------
// Construct Debug toolbar
//-----------------------
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
        
        if ([title_list[i] isEqualToString:@"[Debug]"]){
            UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                         target:nil action:nil];
            [toolbar_items addObject:flexItem];
        }
        
        
        UIBarButtonItem *anItem = [[UIBarButtonItem alloc]
                                             initWithTitle:title_list[i]
                                             style:UIBarButtonItemStyleBordered                                             target:self
                                             action:my_selector];
        [toolbar_items addObject:anItem];
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

//-----------------------
// Construct Demo toolbar
//-----------------------
-(void) constructDemoToolbar:(NSString*)mode{
    
    NSArray* title_list = @[@"[Pre.]", @"[Next]"];
    
    NSMutableArray* toolbar_items =[[NSMutableArray alloc] init];
    
    // Add the counter
    NSString* counter_str = [NSString stringWithFormat:
                             @"*/%lu", self.model->snapshot_array.size()];
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
// Compass (Watch) Panel
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
            self.compassSegmentControl.selectedSegmentIndex = 2;
        }else{
            self.compassSegmentControl.selectedSegmentIndex = 0;
        }
        
        //Configure mode
        if (self.renderer->watchMode == false)
        {
            self.compassModeSegmentControl.selectedSegmentIndex = 0;
        }else if (self.renderer->watchMode == true){
            self.compassModeSegmentControl.selectedSegmentIndex = 2;
        }
        
        self.compassInteractionSwitch.on =
        [self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue];
        
        self.compassCenterLockSwitch.on =
        [self.UIConfigurations[@"UICompassCenterLocked"] boolValue];
    }else{
        [[self watchPanel] setHidden:YES];
    }
}

//------------------
// Model Panel
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
        
        //Configure lock
        if (self.model->lockLandmarks){
            // Disable controls if the lock is on
            self.dataSegmentControl.enabled = false;
            self.filterSegmentControl.enabled = false;
        }else{
            self.dataSegmentControl.enabled = true;
            self.filterSegmentControl.enabled = true;
        }
        self.landmarkLock.on = self.model->lockLandmarks;
        
    }else{
        [[self modelPanel] setHidden:YES];
        
        if (self.needUpdateDisplayRegion)
            [self updateMapDisplayRegion: NO];
    }
}

//------------------
// View Panel
//------------------

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
        
        // Configure wedge status
        if ([self.model->configurations[@"wedge_status"]
             isEqualToString:@"on"])
        {
            if ([self.model->configurations[@"wedge_style"]
                 isEqualToString:@"modified-perspective"])
                self.wedgeSegmentControl.selectedSegmentIndex = 3;
            else if ([self.model->configurations[@"wedge_style"]
                      isEqualToString:@"modified-orthographic"])
                self.wedgeSegmentControl.selectedSegmentIndex = 2;
            else
                self.wedgeSegmentControl.selectedSegmentIndex = 1;
        }else{
            self.wedgeSegmentControl.selectedSegmentIndex = 0;
        }

        // Configure the scale slider
        float scale = [self.model->configurations[@"overview_map_scale"]
                        floatValue];
        self.scaleSlider.value = scale;
        self.scaleIndicator.text = [NSString stringWithFormat:@"%2.1f",
                                    scale];
    }else
        [[self viewPanel] setHidden:YES];
}

//-----------------
// Debug panel
//-----------------
- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugPanel] isHidden]){
        [self hideAllPanels];
        [[self debugPanel] setHidden:NO];
        
        // Update the information on the debug pane
        [self updateDebugPanel];
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
//-------------------
// Main method to control the demo
//-------------------
- (void)runDemoAction:(UIBarButtonItem*) bar_button{

    NSString* label = bar_button.title;
    static int snapshot_id = 0;
    static bool mask_status = false;
    
    if (self.demoManager->device_counter ==-1){
        snapshot_id = 0;
        self.demoManager->device_counter = 0;
        [self setupEnvForTest:self.demoManager->enabled_device_vector[0].type];
    }
        
    if ([label isEqualToString:@"[Pre.]"]){
        self.model->lockLandmarks = false;
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
        [self displaySnapshot:snapshot_id
              withVizSettings: false withPins:YES];
        self.model->lockLandmarks = true;
        // Set the visualization to the first
        [self loopVisualizations:[self resetVisualizationButton]];
        
    }else if ([label isEqualToString:@"[Next]"]){
        self.model->lockLandmarks = false;
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
        
        [self displaySnapshot:snapshot_id
              withVizSettings: false withPins:YES];
        self.model->lockLandmarks = true;
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
    
    //
    [self sendData];
}


- (void)setupEnvForTest:(int) type{
    if (type == PHONE){
        [self setupPhoneViewMode];
    }else{
        [self setupWatchViewMode];
    }
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
@end
