//
//  iOSViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController ()

@end

@implementation iOSViewController
@synthesize model;

- (void)viewWillAppear:(BOOL)animated {
    
    // Make navigation bar disappeared
    // http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    self.model->updateMdl();
    //---------------
    // Unwind actions
    //---------------
    // There is a bug here. There seems to be an extra shift component.
    if (self.needUpdateDisplayRegion){
        [self updateMapDisplayRegion];
        self.needUpdateDisplayRegion = false;
    }
    
    
    if (self.needUpdateAnnotations){
        self.needUpdateAnnotations = false;
        [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
        [self renderAnnotations];
    }
    
    // This may be an iPad only thing
    // (dismissing the modal dialog)
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if ([self needToggleLocationService]){
        [self toggleLocationService:1];
        self.needToggleLocationService = false;
    }
    
    //---------------
    // Snapshot and history stuff
    //---------------
    if (self.snapshot_id_toshow >= 0){
        [self displaySnapshot:self.snapshot_id_toshow];
        self.snapshot_id_toshow = -1;
    }

    if (self.breadcrumb_id_toshow >= 0){
        [self displayBreadcrumb];
        breadcrumb myBreadcrumb =
        self.model->breadcrumb_array[self.breadcrumb_id_toshow];
        
        [self.mapView setCenterCoordinate:myBreadcrumb.coord2D animated:YES];
        self.breadcrumb_id_toshow = -1;
    }
    
    //---------------
    // Goto the selected location
    //---------------
    if (self.landmark_id_toshow >= 0){
        int id = self.landmark_id_toshow;
        self.model->camera_pos.latitude =
        self.model->data_array[id].latitude;
        self.model->camera_pos.longitude =
        self.model->data_array[id].longitude;
        self.landmark_id_toshow = -1;
        [self updateMapDisplayRegion];
    }
    [self.glkView setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}


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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.model = compassMdl::shareCompassMdl();
        self.renderer = compassRender::shareCompassRender();
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        [self.searchDisplayController setDelegate:self];
        [self.ibSearchBar setDelegate:self];
        
        self.needUpdateDisplayRegion = false;
        self.needUpdateAnnotations = false;
        
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
        
        
        //--------------------
        // Initialize a list of UI configurations
        //--------------------
        [self.model->configurations setObject:[NSNumber numberWithBool:false]
                                       forKey:@"UIRotationLock"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
        }
        [self.view addSubview:aView];
    }

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInterfaceRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

#pragma mark -------Interface rotation stuff------

- (void) didInterfaceRotate:(NSNotification *)notification
{

    // Only need to proceed if the rotation lock is off
    if ([self.model->configurations[@"UIRotationLock"] boolValue]){
        return;
    }
    
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    double width = self.mapView.frame.size.width;
    double height = self.mapView.frame.size.height;

    // Update the viewport
    
    // This line is important.
    // In order to maintain 1-1 OpenGL and screen pixel mapping,
    // the following line is necessary!
    self.renderer->initRenderView(width, height);
    self.renderer->updateViewport(0, 0, width, height);
    
    // Update the frames of views
    // iphone's screen size: 568x320
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSMutableArray* toolbar_items =
    [NSMutableArray arrayWithArray:self.toolbar.items];
    
    if (orientation == UIDeviceOrientationLandscapeLeft ||
        orientation == UIDeviceOrientationLandscapeRight)
    {
        screenWidth = screenRect.size.height;
        screenHeight = screenRect.size.width;
        
#ifdef __IPHONE__
        if ([toolbar_items count] ==5){
            // Modifying toolbar
            UIBarButtonItem *flexiableItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil action:nil];
            [toolbar_items insertObject:flexiableItem atIndex:3];
            
            UIBarButtonItem *lockRotationItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:@"[Lock]"
                                                 style:UIBarButtonItemStyleBordered
                                                 target:self
                                                 action:@selector(rotationLockClicked:)];
            [toolbar_items insertObject:lockRotationItem atIndex:4];
            
            
            [self.toolbar setItems: toolbar_items];
            [self.toolbar setBarStyle:UIBarStyleDefault];
            self.toolbar.backgroundColor = [UIColor clearColor];
            self.toolbar.opaque = NO;
            [self.toolbar setTranslucent:YES];
            
            [self.toolbar setBackgroundImage:[UIImage new]
                          forToolbarPosition:UIBarPositionAny
                                  barMetrics:UIBarMetricsDefault];
            [self.toolbar setShadowImage:[UIImage new]
                      forToolbarPosition:UIToolbarPositionAny];
            [self.toolbar setNeedsDisplay];
        }
#endif
    }else if(orientation == UIDeviceOrientationPortrait){
#ifdef __IPHONE__
        // Modifying toolbar
        if ([toolbar_items count] >5){
            
            [toolbar_items removeObjectAtIndex:4];
            [toolbar_items removeObjectAtIndex:3];
            [self.toolbar setItems: toolbar_items];
            
            [self.toolbar setBarStyle:UIBarStyleDefault];
            self.toolbar.backgroundColor = [UIColor clearColor];
            self.toolbar.opaque = NO;
            [self.toolbar setTranslucent:YES];
            
            [self.toolbar setBackgroundImage:[UIImage new]
                          forToolbarPosition:UIBarPositionAny
                                  barMetrics:UIBarMetricsDefault];
            [self.toolbar setShadowImage:[UIImage new]
                      forToolbarPosition:UIToolbarPositionAny];
            [self.toolbar setNeedsDisplay];
        }
#endif
    }
    for (int i = 0; i < [view_array count]; ++i){
        UIView *aView = view_array[i];
        double view_width = view_size_vector[i].width;
        double view_height = view_size_vector[i].height;
        aView.frame = CGRectMake(0, screenHeight - 44 - view_height,
                                 view_width, view_height);
    }
    
    [self.glkView setNeedsDisplay];
}

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

- (void) doSingleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:1];
    NSLog(@"Single tap!");
}

- (void) doDoubleTapFindMe:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleLocationService:2];
    NSLog(@"Double tap!");
}


//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    [self updateMapDisplayRegion];
    
    // Provide the centroid of compass to the model
    [self updateModelCompassCenterXY];

    // Add pin annotations
    [self renderAnnotations];
    
    // Set the conventional compass to be invisible
    self.conventionalCompassVisible = false;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self.mapView];
    NSLog(@"****Touch detected");
    NSLog(@"Display Coordinates: %@", NSStringFromCGPoint(pos));
    
    // Convert it to the real coordinate
    CLLocationCoordinate2D myCoord = [self.mapView convertPoint:pos toCoordinateFromView:self.mapView];
    NSLog(@"Map latitude: %f, longitude: %f", myCoord.latitude, myCoord.longitude);
    
    // pass touch event to super
    [super touchesBegan:touches withEvent:event];
    
    
    
    //------------------
    // Perform hitTest to dismiss dialogs
    //------------------
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel
                              , self.watchPanel, self.debugPanel];
    
    for (UIView* aView in dialog_array){

        UIView* hitView = [aView
                   hitTest:[touch locationInView:aView]
                   withEvent:event];
        if ([aView isHidden] == NO &&
            hitView == nil){
            [aView setHidden:YES];
        }
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    // UIGestureRecognizerStateEnded
    // UIGestureRecognizerStateBegan
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    CustomPointAnnotation *pa = [[CustomPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Dropped Pin";
    pa.point_type = dropped;
    
    if (self.sprinkleBreadCrumbMode){
        [self addBreadcrumb:touchMapCoordinate];
    }
    
    [self.mapView addAnnotation:pa];
    
//    // this line displays the callout
//    [self.mapView selectAnnotation:pa animated:YES];
}


@end

