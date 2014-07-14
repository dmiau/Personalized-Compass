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

// Make navigation bar disappeared
// http://stackoverflow.com/questions/845583/iphone-hide-navigation-bar-only-on-first-page

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if ([self needToggleLocationService]){
        [self toggleLocationService:1];
        self.needToggleLocationService = false;
    }
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
        // Do something
        
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
    
    // Recognize long-press gesture
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:lpgr];
    
    
    //-------------------
    // Add a debug view
    //-------------------
    [self addDebugView];
    [self.debugView setHidden:YES];
    
    //-------------------
    // Add View and Model Panels
    //-------------------
    
    // Note this method needs to be here
    NSArray *view_array =
    [[NSBundle mainBundle] loadNibNamed:@"ViewPanel"
                                  owner:self options:nil];
    for (UIView *aView in view_array){
        [aView setHidden:YES];
        // iphone's screen size: 568x320
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        aView.frame = CGRectMake(0, screenHeight - 44 - aView.frame.size.height,
                                 aView.frame.size.width, aView.frame.size.height);
        if ([[aView restorationIdentifier] isEqualToString:@"ViewPanel"]){
            self.viewPanel = aView;
            [self.view addSubview:self.viewPanel];
        }else{
            self.modelPanel = aView;
            [self.view addSubview:self.modelPanel];
        }
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

//-----------------
// initialize debug view
//-----------------
- (void) addDebugView{
    
    self.debugView = [[UIView alloc] initWithFrame:
                      CGRectMake(0, self.view.frame.size.height - 144,
                                 320, 100)];
    self.debugView.backgroundColor = [UIColor redColor];
    self.debugView.alpha = 0.6;
    [self.view addSubview:self.debugView];
    
    
    // add a textview to the debug view
    UITextView *textView = [[UITextView alloc] initWithFrame:
                            self.debugView.bounds];
    textView.text = @"Hello World!\n";
    [textView setFont:[UIFont systemFontOfSize:25]];
    textView.editable = NO;
    self.debugTextView = textView;
    [self.debugView addSubview:textView];
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
    NSArray* dialog_array = @[self.viewPanel, self.modelPanel];
    
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
    [self.mapView addAnnotation:pa];
    
//    // this line displays the callout
//    [self.mapView selectAnnotation:pa animated:YES];
}


@end

