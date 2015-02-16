//
//  iOSViewController+StudyToolbar.m
//  Compass[transparent]
//
//  Created by Daniel on 2/11/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@implementation iOSViewController (StudyToolbar)
//-----------------------
// Construct Study toolbar
//-----------------------
-(void) constructStudyToolbar:(NSString*)mode{
    
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
                                   action:@selector(runStudyAction:)];
        [toolbar_items addObject:anItem];
    }
    
    //--------------
    // Add a flexible separator
    //--------------
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil action:nil];
    [toolbar_items addObject:flexItem];
    
    //--------------
    // Add the bookmark button
    //--------------
    UIBarButtonItem *anItem;
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

#pragma mark ------Demo actions------
//-------------------
// Main method to control the demo
//-------------------
- (void)runStudyAction:(UIBarButtonItem*) bar_button{
    
    NSString* label = bar_button.title;
    
    if ([label isEqualToString:@"[Pre.]"]){
        self.testManager->showPreviousTest();
    }else if ([label isEqualToString:@"[Next]"]){
        self.testManager->showNextTest();
    }
    
    self.counter_button.title = [NSString stringWithFormat:
                            @"%d/%lu", self.testManager->test_counter+1,
                            self.model->snapshot_array.size()];
}
@end
