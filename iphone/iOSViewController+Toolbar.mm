//
//  iOSViewController+Toolbar.m
//  Compass[transparent]
//
//  Created by dmiau on 6/23/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Toolbar.h"
#import "iOSSettingViewController.h"

@interface iOSViewController () {
    // I should look into this
}
@end


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
// Show pcomass in big size
//------------------
- (IBAction)toggleWatchPanel:(id)sender {
    if ([[self watchPanel] isHidden]){
        [[self viewPanel] setHidden:YES];
        [[self watchPanel] setHidden:NO];
    }else{
        [[self watchPanel] setHidden:YES];
    }
}

//------------------
// Show the menu view
//------------------
- (IBAction)toggleModelPanel:(id)sender {
    if ([[self modelPanel] isHidden]){
        [[self viewPanel] setHidden:YES];
        [[self modelPanel] setHidden:NO];
    }else{
        [[self modelPanel] setHidden:YES];
        
        if (self.needUpdateDisplayRegion)
            [self updateMapDisplayRegion];
    }
}

- (IBAction)toggleViewPanel:(id)sender {
    if ([[self viewPanel] isHidden]){
        [[self modelPanel] setHidden:YES];        
        [[self viewPanel] setHidden:NO];
    }else
        [[self viewPanel] setHidden:YES];
}


- (IBAction)toggleDebugView:(id)sender {
    if ([[self debugPanel] isHidden]){
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


#pragma mark -----Rotation related stuff-----

- (void)rotationLockClicked:(id)sender {
    
    UIBarButtonItem* button = (UIBarButtonItem*) sender;
    
    bool lock_status = [self.model->configurations[@"UIRotationLock"]
                        boolValue];
    
    if (lock_status){
        button.title = @"[Lock]";
    }else{
        button.title = @"[Unlock]";
    }
    
    self.model->configurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:
     ![self.model->configurations[@"UIRotationLock"] boolValue]];
}

@end
