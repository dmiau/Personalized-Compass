//
//  iOSViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 7/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Init.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreData/CoreData.h>
#import "Place.h"
#import "AppDelegate.h"

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
        self.needUpdateGmapMarkers = false;
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
        self.system_message = @"";
        [self logSystemMessage:@"System initialized"];
        self.ip_string = @"MacMini.local";
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
        
        // Add the walking man symbol
        
        // Initialization code here.
        NSRect img_rect;
        
        // Some tools I can use to specify the size of a view
        // NSMakeRect, CGRectMake
        img_rect = CGRectMake(0, 0, 320, 503); //orig_x, y, width, height
        
        // Add the scale image
        NSString *fileString =
        [[NSBundle mainBundle] pathForResource:@"walking.tif" ofType:@""];
        self.scaleView = [[UIView alloc]initWithFrame:img_rect];
        [self.scaleView setBackgroundColor:[UIColor colorWithPatternImage:
                                            [UIImage imageNamed:fileString]]];
        
        
        
        // Add the watch scale image
        img_rect = CGRectMake(0, 0, 568, 255); //orig_x, y, width, height
        fileString =
        [[NSBundle mainBundle] pathForResource:@"watchScale.tif" ofType:@""];
        self.watchScaleView = [[UIView alloc]initWithFrame:img_rect];
        [self.watchScaleView setBackgroundColor:[UIColor colorWithPatternImage:
                                                 [UIImage imageNamed:fileString]]];
        
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
         setObject:[NSNumber numberWithDouble:-1] forKey:@"OSX_wedge_max_base"];
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithDouble:-1] forKey:@"iOS_wedge_max_base"];
        [[NSUserDefaults standardUserDefaults]
         setObject:[NSNumber numberWithBool:NO] forKey:@"iOSDevMode"];
    }
    return self;
}

//--------------------
// View did load
//--------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //DM disable CoreData stuff
//    [self loadLocationData];
    // Do any additional setup after loading the view.
    
    //-------------------
    // Initialize the message label
    //-------------------
    self.messageLabel = [[UILabel alloc] initWithFrame:
                         CGRectMake(10, 10, 300, 50)];
    [self.messageLabel setBackgroundColor:[UIColor whiteColor]];
    [self.messageLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 36.0f]];
    
    
    // Development message label
    self.devMessageLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(50, 300, 200, 50)];
    [self.devMessageLabel setBackgroundColor:[UIColor whiteColor]];
    [self.devMessageLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 12.0f]];
    self.devMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.devMessageLabel.numberOfLines = 4;
    
    self.devMessageLabel.text = @"Hello World!";
    // Add the label to view
    [self.mapView addSubview:self.devMessageLabel];
    [self.devMessageLabel setHidden:YES];
    

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
    // Initialize OpenGL ES
    //-------------------
    
    // Create an OpenGL ES context and assign it to the view loaded from storyboard
    [self.glkView initWithFrame:self.glkView.frame
                        context:
     [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1]];
    
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
    self.toolbar.clipsToBounds = YES;
    //---------------
    // Initilize socket message array
    //---------------
    _messages = [[NSMutableArray alloc] init];
    
    //---------------
    // DO NOT lock the compass center by default
    //---------------
    [self lockCompassRefToScreenCenter:NO];
}

//-----------------
// Load data from Core Data
//-----------------
- (void) loadLocationData{
    self.model->data_array.clear();
    std::vector<data> locationData;
    // Fetch the stored data
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSError *error;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    
    NSArray *requestResults = [app.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Place *place in requestResults) {
        data data;
        data.latitude = [place.lat floatValue];
        data.longitude = [place.lon floatValue];
        data.name = [place.name UTF8String];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(data.latitude, data.longitude);
        data.annotation.coordinate = coor;
        locationData.push_back(data);
    }
    self.model->data_array =  locationData;
    self.model->initTextureArray();
}



@end