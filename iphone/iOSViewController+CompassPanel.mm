//
//  iOSViewController+CompassPanel.m
//  Compass[transparent]
//
//  Created by dmiau on 7/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+CompassPanel.h"
#import <objc/message.h>

@implementation iOSViewController (WatchPanel)


- (void)setupPhoneViewMode{
    //-----------
    // Normal
    //-----------
    
    self.UIConfigurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:NO];
    
    // rotate the screen
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait);

    self.UIConfigurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:YES];
    
    self.renderer->model->configurations[@"font_size"] =
    self.model->cache_configurations[@"font_size"];

    
    self.renderer->watchMode = false;
    for (int i = 0; i<4; ++i){
        // deep copy
        self.renderer->model->configurations[@"bg_color"][i] =
        [NSNumber numberWithFloat:
         [self.model->cache_configurations[@"bg_color"][i] floatValue]];
    }
    // revert
    // Change compass ctr
    [self changeCompassLocationTo: @"Default"];
    self.model->configurations[@"wedge_style"] = @"modified-orthographic";    
    
    // Reset the compss scale back to the default scale
    self.renderer->adjustAbsoluteCompassScale(1);
    
    UITextField *searchField =
    [self.ibSearchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor blackColor];
    [self toggleWatchMask:NO];
        
    [self.watchSidebar setHidden:YES];
}


//-----------------
// Set up the watch mode
//-----------------
- (void)setupWatchViewMode{
   
    self.UIConfigurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:NO];
    // rotate the screen
    objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeLeft );
    self.UIConfigurations[@"UIRotationLock"] =
    [NSNumber numberWithBool:YES];
    
    self.renderer->model->configurations[@"font_size"] =
    self.model->cache_configurations[@"font_size"];
    
    self.renderer->watchMode = true;
    for (int i = 0; i<4; ++i){
        self.model->configurations[@"bg_color"][i] =
        self.model->cache_configurations[@"bg_color"][i];
    }

    
    // Need some work here
    
    // Change compass ctr
    [self changeCompassLocationTo: @"Center"];
    
    // The wedge has to be in the perspective mode to funciton correctly
    self.model->configurations[@"wedge_style"] = @"modified-perspective";
    
    float watch_scale =
    [self.model->configurations[@"watch_compass_disk_radius"]
                         floatValue] /
    [self.model->configurations[@"compass_disk_radius"]
     floatValue];
    self.renderer->adjustAbsoluteCompassScale(watch_scale);
    
    UITextField *searchField =
    [self.ibSearchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor whiteColor];
    [self toggleWatchMask: YES];
    
    
    //-------------------
    // Add a side panel when the watch mode is on
    // (and when testManagerMode is not in AUTHORING mode
    //-------------------
    if (self.testManager->testManagerMode != AUTHORING){
        self.watchLandmrkLockSwitch.on =self.model->lockLandmarks;
        self.watchCompassInteractionSwitch.on =
        [self.UIConfigurations[@"UICompassInteractionEnabled"] boolValue];
        [self.watchSidebar setHidden:NO];
    }
    
    //Hide all panels
    [self hideAllPanels];
}


- (IBAction)watchModeSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    // need to do a deep copy
    // http://www.cocoanetics.com/2009/09/deep-copying-dictionaries/

    self.renderer->watchMode = false;
    self.renderer->trainingMode = false;
    
    // Initialization
    static BOOL once = false;
    static UISlider *slider;
    if (!once){
        CGRect frame = CGRectMake(28.0,
                                  self.view.frame.size.height - 100
                                  , 200.0, 40.0);
        slider = [[UISlider alloc] initWithFrame:frame];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [slider setBackgroundColor:[UIColor grayColor]];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.continuous = YES;
        slider.value = 0.5;
        once = true;
    }
    [slider removeFromSuperview];
    self.renderer->model->configurations[@"font_size"] =
    self.model->cache_configurations[@"font_size"];
    
    UITextField *searchField =
    [self.ibSearchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor blackColor];
    
    
    // Do not change visualization status
//    [self toggleWedge:NO];
//    [self toggleOverviewMap:NO];
//    [self togglePCompass:YES];
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            //-----------
            // Normal
            //-----------
            [self setupPhoneViewMode];
            break;
        case 1:
            //-----------
            // Watch Mode
            //-----------
            [self setupWatchViewMode];
            break;
        case 2:
            //-----------
            // Training Mode
            //-----------
            self.renderer->trainingMode = true;
            
            // Change compass ctr
            [self changeCompassLocationTo: @"Center"];
            
            self.renderer->model->configurations[@"font_size"] =
            [NSNumber numberWithFloat:14];
            [self.view addSubview:slider];
            break;
    }
    
    if (self.renderer->trainingMode){
        [self toggleBlankMapMode:YES];
        mapMask.opacity = 0.5;
    }else{
        [self toggleBlankMapMode:NO];
    }
    [self.glkView setNeedsDisplay];
}

-(void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    float value = slider.value;
    mapMask.opacity = value;
}

- (void) toggleWatchMask: (bool) isWatchOn{
    
    float radius = [self.model->configurations[@"watch_radius"] floatValue];
    
    if (isWatchOn){
        double fwidth = self.glkView.frame.size.width;
        double fheight = self.glkView.frame.size.height;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height) cornerRadius:0];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:
                                    CGRectMake(fwidth/2-radius, fheight/2-radius,2*radius, 2*radius) cornerRadius:radius];
        [path appendPath:circlePath];
        [path setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor blackColor].CGColor;
        
        if (self.testManager->testManagerMode == AUTHORING)
            fillLayer.opacity = 0.5;
        else
            fillLayer.opacity = 1;
        
        [self.glkView.layer addSublayer:fillLayer];
        self.view.backgroundColor = [UIColor blackColor];
    }else{
        self.view.backgroundColor = [UIColor clearColor];
        self.glkView.layer.sublayers = nil;
    }
}

//------------------
// Select compass type
//------------------
- (IBAction)compassSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Conventional"]){
        self.conventionalCompassVisible = YES;
        //        [self.glkView setHidden:YES];
        self.model->configurations[@"personalized_compass_status"] = @"off";
        [self setFactoryCompassHidden:NO];
    }else if ([label isEqualToString:@"Personalized"]){
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"on";
        [self setFactoryCompassHidden:YES];
    }else{
        self.conventionalCompassVisible = NO;
        self.model->configurations[@"personalized_compass_status"] = @"off";
        //        [self.glkView setHidden:YES];
        [self setFactoryCompassHidden:YES];
    }
    [self.glkView setNeedsDisplay];
}


////-----------------------
//// Compass Lcoation Control
////-----------------------
//- (IBAction)resetUICompass:(id)sender {
//    
//    if (self.renderer->watchMode){
//            [self changeCompassLocationTo:@"Center"];
//    }else{
//            [self changeCompassLocationTo:@"UR"];
//    }
//}


- (void) changeCompassLocationTo: (NSString*) label{
    // Need to perform a deep copy
    static bool cached_flag = false;
    static CGPoint defaultCentroidParams;
    static CGRect default_rect;
    
    if (!cached_flag){
        defaultCentroidParams = self.renderer->compass_centroid;
        default_rect = self.glkView.frame;
        cached_flag = true;
    }
    
    
    //---------------
    // iPhone case
    //---------------
#ifndef __IPAD__
    if ([label isEqualToString:@"Default"]){
        self.renderer->compass_centroid = defaultCentroidParams;
    }else if ([label isEqualToString:@"UR"]){
        self.renderer->compass_centroid.x = 90;
        self.renderer->compass_centroid.y = 180;
    }else if ([label isEqualToString:@"Center"]){
        self.renderer->compass_centroid.x = 0;
        self.renderer->compass_centroid.y = 0;
    }else if ([label isEqualToString:@"BL"]){
        self.renderer->compass_centroid.x = -70;
        self.renderer->compass_centroid.y = -150;
    }
#endif
    
#ifdef __IPAD__
    //---------------
    // iPad case
    //---------------
    default_rect = CGRectMake(425, -43,
                              default_rect.size.width, default_rect.size.height);
    if ([label isEqualToString:@"Default"]){
        self.renderer->compass_centroid = defaultCentroidParams;
        self.glkView.frame = default_rect;
    }else if ([label isEqualToString:@"UR"]){
        self.glkView.frame = default_rect;
    }else if ([label isEqualToString:@"Center"]){
        self.glkView.frame = CGRectMake(176, 314,
                                        default_rect.size.width,
                                        default_rect.size.height);
    }else if ([label isEqualToString:@"BL"]){
        self.glkView.frame = CGRectMake(13, 644,
                                        default_rect.size.width,
                                        default_rect.size.height);
    }
    
#endif
    
    // The order is important
    [self moveCompassCentroidToOpenGLPoint: self.renderer->compass_centroid];
    [self.glkView setNeedsDisplay];
}

- (IBAction)toggleCompassInteraction:(UISwitch*)sender {
    
    if (sender.on){
        self.UIConfigurations[@"UICompassInteractionEnabled"] =
        [NSNumber numberWithBool:true];
    }else{
        self.UIConfigurations[@"UICompassInteractionEnabled"] =
        [NSNumber numberWithBool:false];
    }
}

- (IBAction)toggleCompassCenterLock:(UISwitch*)sender {
    if (sender.on){
        [self lockCompassRefToScreenCenter:YES];
    }else{
        [self lockCompassRefToScreenCenter:NO];
    }
}

- (void)lockCompassRefToScreenCenter: (bool)state{
    if (state){
        self.renderer->isCompassRefPointEnabled = YES;
        [self moveCompassRefToMapViewPoint:
         CGPointMake(self.mapView.frame.size.width/2,
                     self.mapView.frame.size.height/2)
         ];
        
        self.UIConfigurations[@"UICompassCenterLocked"] =
        [NSNumber numberWithBool:true];
        
    }else{
        self.renderer->isCompassRefPointEnabled = NO;
        self.UIConfigurations[@"UICompassCenterLocked"] =
        [NSNumber numberWithBool:false];
        [self moveCompassRefToMapViewPoint:
         CGPointMake(self.renderer->compass_centroid.x +
                     self.mapView.frame.size.width/2,
                     self.mapView.frame.size.height/2 -
                     self.renderer->compass_centroid.y)
         ];
    }
    [self.glkView setNeedsDisplay];
}

//--------------------
// Toggle Study Related Tools
//--------------------
- (IBAction)toggleStudySegmentControl:(UISegmentedControl*)sender {

    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.messageLabel removeFromSuperview];
            [self enableMapInteraction:YES];
            self.renderer->isAnswerLinesEnabled = NO;
            self.renderer->isCrossEnabled = NO;
            self.renderer->isInteractiveLineVisible = NO;
            break;
        case 1:
            //-------------
            // Truth
            //-------------
            [self addMessageLabelToView];
            self.renderer->isAnswerLinesEnabled = YES;
            [self updateAnswerLines];
            [self enableMapInteraction:YES];
            self.renderer->isCrossEnabled = YES;
            self.renderer->isInteractiveLineVisible = NO;
            break;
        case 2:
            //-------------
            // IT Line
            //-------------
            [self addMessageLabelToView];
            [self enableMapInteraction:NO];
            self.renderer->isAnswerLinesEnabled = NO;
            self.renderer->isCrossEnabled = YES;
            self.renderer->isInteractiveLineVisible = YES;
            self.renderer->isInteractiveLineEnabled = YES;
            break;
        case 3:
            //-------------
            // Truth+IT Line
            //-------------
            [self addMessageLabelToView];
            self.renderer->isAnswerLinesEnabled = YES;
            [self updateAnswerLines];
            [self enableMapInteraction:NO];
            self.renderer->isCrossEnabled = YES;
            self.renderer->isInteractiveLineVisible = YES;
            self.renderer->isInteractiveLineEnabled = NO;
            break;
        default:
            break;
    }
    [self.glkView setNeedsDisplay];
}

- (void) addMessageLabelToView{
    if (![self.messageLabel isDescendantOfView:self.glkView]){
        [self.glkView addSubview:self.messageLabel];
    }
}

@end
