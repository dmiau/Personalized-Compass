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
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue,
                   ^{
                       
                       [self toggleScaleView:NO];
                       //-----------
                       // Normal
                       //-----------
                       self.renderer->cross.applyDeviceStyle(PHONE);
                       
                       if (self.testManager->testManagerMode != OFF){
                           self.renderer->cross.isVisible = true;
                       }
                       
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
                       
                       self.renderer->compassRefDot.deviceType = PHONE;
                       // Change compass ctr
                       [self lockCompassRefToScreenCenter:NO];
                       [self changeCompassLocationTo: @"Default"];
                       self.model->configurations[@"wedge_style"] = @"modified-orthographic";    
                       [self lockCompassRefToScreenCenter:YES];
                       // Reset the compss scale back to the default scale
                       self.renderer->adjustAbsoluteCompassScale(1);
                       
                       UITextField *searchField =
                       [self.ibSearchBar valueForKey:@"_searchField"];
                       searchField.textColor = [UIColor blackColor];
                       [self.ibSearchBar setHidden:NO];
                       
                       [self toggleWatchMask:NO];
                       
                       [self.watchSidebar setHidden:YES];
                       
                       if (self.testManager->testManagerMode != OFF){
                           self.testManager->showTestNumber
                           (self.testManager->test_counter);
                       }
                       
                       //--------------------
                       // Notify the server
                       //--------------------
                       // Package the data
                       NSDictionary *myDict = @{@"Type"  :@"Message",
                                                @"Content"  :@"PHONE"};
                       
                       [self sendPackage:myDict];
                       
                   });
    
}


//-----------------
// Set up the watch mode
//-----------------
- (void)setupWatchViewMode{

    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue,
                   ^{
                       
                       [self toggleScaleView:NO];
                       self.renderer->cross.applyDeviceStyle(WATCH);
                       
                       if (self.testManager->testManagerMode != OFF){
                           if ([self.model->configurations[@"personalized_compass_status"] isEqualToString:@"on"])
                           {
                               self.renderer->cross.isVisible = false;
                           }else{
                               self.renderer->cross.isVisible = true;
                           }
                       }
                       
                       
                       
                       
                       self.UIConfigurations[@"UIRotationLock"] =
                       [NSNumber numberWithBool:NO];
                       // rotate the screen
                       objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeLeft );
                       
                       //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                       
                       self.UIConfigurations[@"UIRotationLock"] =
                       [NSNumber numberWithBool:YES];
                       
                       
                       
                       self.renderer->model->configurations[@"font_size"] =
                       self.model->cache_configurations[@"font_size"];
                       
                       self.renderer->watchMode = true;
                       for (int i = 0; i<4; ++i){
                           self.model->configurations[@"bg_color"][i] =
                           self.model->cache_configurations[@"bg_color"][i];
                       }
                       
                       self.renderer->compassRefDot.deviceType = WATCH;
                       
                       [self lockCompassRefToScreenCenter:NO];
                       // Change compass ctr
                       [self changeCompassLocationTo: @"Center"];
                       //    [self lockCompassRefToScreenCenter:YES];
                       
                       // The wedge has to be in the perspective mode to funciton correctly
                       self.model->configurations[@"wedge_style"] = @"modified-perspective";
                       
                       
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
                       
                       if (self.testManager->testManagerMode == DEVICESTUDY)
                       {
                           [self.watchSidebar setHidden:YES];
                           [self.ibSearchBar setHidden:YES];
                       }else{
                           [self.watchSidebar setHidden:NO];
                           [self.ibSearchBar setHidden:NO];
                       }
                       
                       //    // Print screen size
                       //    cout << "wxh: " << self.renderer->view_width << " x "
                       //    << self.renderer->view_height << endl;
                       
                       //Hide all panels
                       [self hideAllPanels];
                       
                       if (self.testManager->testManagerMode != OFF){
                           self.testManager->showTestNumber
                           (self.testManager->test_counter);
                       }
                       
                       
                       //--------------------
                       // Notify the server
                       //--------------------
                       // Package the data
                       NSDictionary *myDict = @{@"Type"  :@"Message",
                                                @"Content"  :@"WATCH"};
                       
                       [self sendPackage:myDict];
                   });
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
        self.renderer->compass_centroid.x = 80;
        self.renderer->compass_centroid.y = 175;
    }else if ([label isEqualToString:@"Center"]){
        self.renderer->compass_centroid.x = 0;
        self.renderer->compass_centroid.y = 0;
        
        self.renderer->compassRefDot.isVisible = NO;
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
    bool origLockStatus = [self.UIConfigurations[@"UICompassCenterLocked"]
                           boolValue];
    
    self.UIConfigurations[@"UICompassCenterLocked"] =
    [NSNumber numberWithBool:false];
    
    // The order is important
    [self moveCompassCentroidToOpenGLPoint: self.renderer->compass_centroid];
    self.UIConfigurations[@"UICompassCenterLocked"] =
    [NSNumber numberWithBool:origLockStatus];
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
        self.renderer->compassRefDot.isVisible = NO;
        [self moveCompassRefToMapViewPoint:
         CGPointMake(self.mapView.frame.size.width/2,
                     self.mapView.frame.size.height/2)
         ];
        
        self.UIConfigurations[@"UICompassCenterLocked"] =
        [NSNumber numberWithBool:true];
        
    }else{
        self.renderer->compassRefDot.isVisible = NO;
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
            //-------------
            // None
            //-------------
            [self.messageLabel removeFromSuperview];
            [self enableMapInteraction:YES];
            self.renderer->isAnswerLinesEnabled = NO;
            self.renderer->cross.isVisible = NO;
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
            self.renderer->cross.isVisible = YES;
            self.renderer->isInteractiveLineVisible = NO;
            break;
        case 2:
            //-------------
            // IT Line
            //-------------
            [self addMessageLabelToView];
            [self enableMapInteraction:NO];
            self.renderer->isAnswerLinesEnabled = NO;
            self.renderer->cross.isVisible = YES;
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
            self.renderer->cross.isVisible = YES;
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

//-----------------
// Controls whether the answers will be shown or not
//-----------------
- (void) toggleAnswersVisibility: (bool) state{
    if (state){
        [self updateAnswerLines];
        //----------------
        // Show answers
        //----------------
        if ((self.testManager->testManagerMode == OFF) ||
            (NSStringToTaskType(self.model->snapshot_array
                                [self.testManager->test_counter].name)  ==
             DISTANCE))
        {
            [self addMessageLabelToView];
        }
        
        if ((self.testManager->testManagerMode == OFF) ||
            (NSStringToTaskType(self.model->snapshot_array
                                [self.testManager->test_counter].name)  ==
             ORIENT))
        {
            self.renderer->isAnswerLinesEnabled = YES;
            [self enableMapInteraction:NO];
            self.renderer->cross.isVisible = YES;
            self.renderer->isInteractiveLineVisible = YES;
            self.renderer->isInteractiveLineEnabled = NO;
            [self.glkView setNeedsDisplay];
        }
    }else{
        //----------------
        // Do NOT how answers
        //----------------
        if ([self.messageLabel isDescendantOfView:self.glkView]){
            [self.messageLabel removeFromSuperview];
        }
        self.renderer->isAnswerLinesEnabled = NO;
        self.renderer->cross.isVisible = NO;
        self.renderer->isInteractiveLineVisible = NO;
    }
}

- (void)pressOKToSwitchToWatchMode{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Attention"
                                message:@"Please slide the phone into the wrist band pocket, then press OK to switch to the watch mode." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {[alert dismissViewControllerAnimated:YES completion:nil];
         [self setupWatchViewMode];
     }];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)pressOKToSwitchToPhoneMode{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Attention"
                                message:@"Please take the phone out of the wrist band pocket, then press OK to switch to the phone mode." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {[alert dismissViewControllerAnimated:YES completion:nil];
         [self setupPhoneViewMode];
     }];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
@end
