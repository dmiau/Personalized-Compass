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
    // Add View Panel
    //-------------------
    
    // Note this method needs to be here
    NSArray *view_array =
    [[NSBundle mainBundle] loadNibNamed:@"ViewPanel"
                                  owner:self options:nil];
    for (UIView *aView in view_array){
        [aView setHidden:YES];
        aView.frame = CGRectMake(0, 267, 320, 255);
        if ([[aView restorationIdentifier] isEqualToString:@"ViewPanel"]){
            self.viewPanel = aView;
            [self.view addSubview:self.viewPanel];
        }else{
            self.modelPanel = aView;
            [self.view addSubview:self.modelPanel];
        }
    }

}

//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    [self updateMapDisplayRegion];
    
    // Provide the centroid of compass to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: CGPointMake(self.glkView.frame.size.width/2
                                            + [self.model->configurations[@"compass_centroid"][0] floatValue],
                                            self.glkView.frame.size.height/2+
                                            - [self.model->configurations[@"compass_centroid"][1] floatValue])
                      fromView:self.glkView];
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


#pragma mark ------update------


-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue
{
    
    // Can I know which segue it is?
//    NSLog(@"Segue id: %@", segue.identifier);
    
    // There is a bug here. There seems to be an extra shift component.
    if (self.needUpdateDisplayRegion){
        [self updateMapDisplayRegion];
        self.needUpdateDisplayRegion = false;
    }

    
    if (self.needUpdateAnnotations){
        [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
        [self renderAnnotations];
    }
    
    // This may be an iPad only thing
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Hello";
    [self.mapView addAnnotation:pa];
    
//    // this line displays the callout
//    [self.mapView selectAnnotation:pa animated:YES];
}


@end

