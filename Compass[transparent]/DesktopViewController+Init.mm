//
//  DesktopViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Init.h"
#import <CoreMedia/CoreMedia.h>

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
        self.studyIntAnswer = [NSNumber numberWithInt:0];
        self.isDistanceEstControlAvailable = [NSNumber numberWithBool:NO];
        self.testInformationMessage = @"Enable Study Mode from iOS";
        self.studyTitle = @"Welcome";
        self.isInformationViewVisible = [NSNumber numberWithBool:NO];

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
        
        //--------------------
        // Registering Users Defaults from plist
        //--------------------
        NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults"
                                                                 ofType:@"plist"];
        NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] setObject:@"N/A" forKey:@"TestStatus"];
        [[NSUserDefaults standardUserDefaults] setObject:@"N/A" forKey:@"AdminSessionInfo"];
        
        [[NSUserDefaults standardUserDefaults]
         setObject: [NSNumber numberWithBool:NO]
                        forKey:@"isWaitingAdminCheck"];
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO]
         forKey:@"isPracticingMode"];
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO]
         forKey:@"isDevMode"];
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO]
                                                  forKey:@"isAnswerConfirmed"];
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO]
                                                  forKey:@"isTestManagerOn"];
        
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithDouble:-1] forKey:@"OSX_wedge_max_base"];
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithDouble:-1] forKey:@"iOS_wedge_max_base"];
        //--------------------
        // Initialize the video player
        //--------------------
        
        // Load a default file
        NSString *path = [[NSBundle mainBundle]
                          pathForResource:@"pcompass-phone-locate" ofType:@"mp4"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
        
        // Configure video
        self.AVPlayerView.player =
        [AVPlayer playerWithURL:url];
        self.AVPlayerView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.AVPlayerView.player currentItem]];
    }
    return self;
}

//--------------
// Let the video loop infinitely
//--------------
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
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
        
    //-------------------
    // Start the server by default
    //-------------------
    [self startServer];
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
    [self resetAnnotations];
    
    // Set the conventional compass to be invisible
    [self setFactoryCompassHidden:YES];
    
//    // Disable zoom control
//    self.mapView.showsZoomControls = false;
}

@end
