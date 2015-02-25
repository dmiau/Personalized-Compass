//
//  iOSViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 7/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Init.h"

@implementation iOSViewController (Init)
#pragma mark ----Initialization----
- (void) awakeFromNib
{
    // Insert code here to initialize your application
    [self addObserver:self forKeyPath:@"mapUpdateFlag"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    
    //http://stackoverflow.com/questions/10796058/is-it-possible-to-continuously-track-the-mkmapview-region-while-scrolling-zoomin?lq=1
    
#ifndef __IPAD__
    float timer_interval = 0.03;
#else
    float timer_interval = 0.06;
#endif
    
    _updateUITimer = [NSTimer timerWithTimeInterval:timer_interval
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
}


//--------------------
// Init with coder
//--------------------
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.model = compassMdl::shareCompassMdl();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        self.renderer = compassRender::shareCompassRender();
        self.demoManager = DemoManager::shareDemoManager();
        self.testManager = TestManager::shareTestManager();
        self.testManager->rootViewController = self;
                
        [self.searchDisplayController setDelegate:self];
        [self.ibSearchBar setDelegate:self];
        
        // Map related initialization
        self.needUpdateDisplayRegion = false;
        self.needUpdateAnnotations = false;
        self.isBlankMapEnabled = false;
        
        // Initialize location service
        // enable location manager
        self.needToggleLocationService = false;
        self.locationManager =
        [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // These two properties are used by snapshot and history
        self.snapshot_id_toshow     = -1;
        self.breadcrumb_id_toshow   = -1;
        self.landmark_id_toshow     = -1;
        
        self.socket_status = [NSNumber numberWithBool:false];
        self.received_message = @"NONE";
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
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIAcceptsPinCreation"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UICompassTouched"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:true]
                                  forKey:@"UICompassInteractionEnabled"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UIAllowMultipleAnnotations"];
        [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                  forKey:@"UICompassCenterLocked"];
        [self.UIConfigurations setObject:@"Auto"
                                  forKey:@"UIOverviewScaleMode"];
        [self.UIConfigurations setObject:@"All"
                                  forKey:@"ShowPins"];
    }
    return self;
}

//--------------------
// View did load
//--------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //-------------------
    // Initialize the message label
    //-------------------
    self.messageLabel = [[UILabel alloc] initWithFrame:
                    CGRectMake(10, 10, 150, 20)];
    [self.messageLabel setBackgroundColor:[UIColor clearColor]];
    [self.messageLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 16.0f]];
    
    //-------------------
    // Initialize OpenGL ES
    //-------------------
    
    // Create an OpenGL ES context and assign it to the view loaded from storyboard
    [self.glkView initWithFrame:self.glkView.frame
                        context:
     [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1]];
    
    //-------------------
    // Initialize Map View
    //-------------------
    self.mapView.delegate = self;
    self.renderer->mapView = [self mapView];
    [self initMapView];
    mapMask = [CALayer layer];
    
    // Recognize long-press gesture
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:lpgr];
    
    
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(pinchGesture:)];
    pgr.delegate = self;
    [self.mapView addGestureRecognizer:pgr];
    
    //-------------------
    // Add View, Model, Watch and Debug Panels
    //-------------------
    
    // Note this method needs to be here
    view_array =
    [[NSBundle mainBundle] loadNibNamed:@"ExtraPanels"
                                  owner:self options:nil];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    for (UIView *aView in view_array){
        [aView setHidden:YES];
        view_size_vector.push_back(aView.frame.size);
        // iphone's screen size: 568x320
        aView.frame = CGRectMake(0, screenHeight - 44 - aView.frame.size.height,
                                 aView.frame.size.width, aView.frame.size.height);
        if ([[aView restorationIdentifier] isEqualToString:@"ViewPanel"]){
            self.viewPanel = aView;
        }else if ([[aView restorationIdentifier] isEqualToString:@"ModelPanel"]){
            self.modelPanel = aView;
        }else if ([[aView restorationIdentifier] isEqualToString:@"WatchPanel"]){
            self.watchPanel = aView;
        }else if ([[aView restorationIdentifier] isEqualToString:@"DebugPanel"]){
            self.debugPanel = aView;
        }else if ([[aView restorationIdentifier] isEqualToString:@"WatchSidebar"]){
            self.watchSidebar = aView;
        }
    }
    [self.view addSubview:self.watchSidebar];
    [self.view addSubview:self.debugPanel];
    [self.view addSubview:self.watchPanel];
    [self.view addSubview:self.modelPanel];
    [self.view addSubview:self.viewPanel];
    
//    [self.watchPanel removeFromSuperview];
//    [self.view insertSubview:self.watchPanel aboveSubview:self.watchSidebar];
    
    //-------------------
    // Add gesture recognizer to the FindMe button
    //-------------------
    UITapGestureRecognizer *singleTapFindMe = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTapFindMe:)];
    singleTapFindMe.numberOfTapsRequired = 1;
    [self.findMeButton addGestureRecognizer:singleTapFindMe];
    
    UITapGestureRecognizer *doubleTapFindMe = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTapFindMe:)];
    doubleTapFindMe.numberOfTapsRequired = 2;
    [self.findMeButton addGestureRecognizer:doubleTapFindMe];
    
    //-------------------
    // Add gesture recognizer to the FindMe button
    //-------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInterfaceRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    //---------------
    // Construct a default toolbar
    //---------------
    [self constructDebugToolbar: @"Portrait"];
    
    //---------------
    // Initilize socket message array
    //---------------
    _messages = [[NSMutableArray alloc] init];
}

@end
