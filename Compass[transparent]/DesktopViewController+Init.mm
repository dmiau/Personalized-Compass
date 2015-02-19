//
//  DesktopViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Init.h"

@implementation DesktopViewController (Init)

#pragma mark initialization

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        
        self.model = compassMdl::shareCompassMdl();
        
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Get the pointer of render
        // At this point the render may not be fully initialized
        self.renderer = compassRender::shareCompassRender();
        
        pinVisible = FALSE;
        
        // Important, initialize NSMutableArray with empty cells
        tableCellCache = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < self.model->data_array.size(); ++i)
        {
            [tableCellCache addObject:[NSNull null]];
        }
        
        // Initialize iOSSyncFlag
        self.iOSSyncFlag = false;
        self.isBlankMapEnabled = false;
        //--------------------
        // Initial testManager
        //--------------------        
        self.testManager = TestManager::shareTestManager();
        self.testManager->rootViewController = self;
        
        self.received_message = @"NONE";
        self.socket_status = [NSNumber numberWithBool:NO];
        //--------------------
        // Initialize a list of UI configurations
        //--------------------
        self.UIConfigurations = [[NSMutableDictionary alloc] init];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIRotationLock"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIBreadcrumbDisplay"];
        [self.UIConfigurations setObject:@"Development"
                                  forKey:@"UIToolbarMode"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIToolbarNeedsUpdate"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:true]
                                  forKey:@"UIAcceptsPinCreation"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UICompassTouched"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:true]
                                  forKey:@"UICompassInteractionEnabled"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UICompassCenterLocked"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIAllowMultipleAnnotations"];
        [self.UIConfigurations setObject:@"Auto"
                                  forKey:@"UIOverviewScaleMode"];
        [self.UIConfigurations setObject:@"All"
                                  forKey:@"ShowPins"];
        
    }
    return self;
}



- (void) awakeFromNib
{
    
    // The following lines are only needed for 10.9 SDK.
    // 10.10 now injects ViewController to the reponder chain
//    //http://stackoverflow.com/questions/20061052/how-to-add-nsviewcontroller-to-a-responder-chain
//    [self setNextResponder:self.view];
//    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self]; }];
    
    
    [[self mapView] setScrollEnabled:YES];
    [self mapView].showsZoomControls =YES;
    //    [self mapView].showsCompass =YES;
    [self mapView].rotateEnabled = YES;
    
    self.renderer->mapView = [self mapView];
    
    [self addObserver:self forKeyPath:@"mapUpdateFlag"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    //http://stackoverflow.com/questions/10295515/nswindow-event-when-change-size-of-window
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[[self view] window]];
    
    
    //http://stackoverflow.com/questions/10796058/is-it-possible-to-continuously-track-the-mkmapview-region-while-scrolling-zoomin?lq=1
    
    _updateUITimer = [NSTimer timerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
    
    [self.kmlComboBox setStringValue:
     [self.model->location_filename
      lastPathComponent]];

    //-------------------
    // Initialized the mapView
    //-------------------
    [self initMapView];
    
    // Inject to AppDelegate
    AppDelegate *temp = [[NSApplication sharedApplication] delegate];
    temp.rootViewController = self;    
}


//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    
    MKCoordinateRegion temp;
    if (self.model->data_array.size()>0){
        temp = MKCoordinateRegionMake
        (CLLocationCoordinate2DMake(self.model->data_array[0].latitude, self.model->data_array[0].longitude),MKCoordinateSpanMake(0.01, 0.01));
    }else{
        // Manhattan as the default location
        temp = MKCoordinateRegionMake
        (CLLocationCoordinate2DMake(40.705773, -74.002159),
         MKCoordinateSpanMake(0.01, 0.01));
    }
    [self updateMapDisplayRegion: temp withAnimation:NO];
    
    
    // Provide the centroid of compass to the model
    [self moveCompassCentroidToOpenGLPoint: self.renderer->compass_centroid];
    
    // Add pin annotations
    [self renderAnnotations];
    
    // Set the conventional compass to be invisible
    [self setFactoryCompassHidden:YES];
    
//    // Disable zoom control
//    self.mapView.showsZoomControls = false;
}

@end
