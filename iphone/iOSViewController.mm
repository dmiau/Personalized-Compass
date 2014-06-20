//
//  iOSViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"
#include <cmath>

@interface iOSViewController ()

@end

@implementation iOSViewController
@synthesize model;

#pragma mark ---- Timer Functon Stuff ----
-(void)vcTimerFired{
    
    static double latitude_cache = 0.0;
    static double longitude_cache = 0.0;
    static double pitch_cache = 0.0;
    static double camera_heading = 0.0;
    double epsilon = 0.0000001;
    
    // Note that heading is defined as the negative of
    // _mapView.camera.heading
    if ( abs((double)(latitude_cache - [_mapView centerCoordinate].latitude)) > epsilon ||
        abs((double)(longitude_cache - [_mapView centerCoordinate].longitude)) > epsilon ||
        abs((double)(pitch_cache - _mapView.camera.pitch)) > epsilon||
        abs((double)(camera_heading - [self calculateCameraHeading])) > epsilon)
    {
        latitude_cache = [_mapView centerCoordinate].latitude;
        longitude_cache = [_mapView centerCoordinate].longitude;
        pitch_cache = _mapView.camera.pitch;
        camera_heading = [self calculateCameraHeading];
        self.mapUpdateFlag = [NSNumber numberWithDouble:0.0];
    }
    //    NSLog(@"*****tableCellCache size %lu", (unsigned long)[tableCellCache count]);
}

//---------------
// KVO code to update latitude, longitude, tile, heading, etc.
//---------------
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    // [todo] In the browser mode,
    // updates should not come from map! Need to fix this
    if ([keyPath isEqual:@"mapUpdateFlag"]) {
        
        CLLocationCoordinate2D compassCtrCoord = [_mapView convertPoint:
                                                  model->compassCenterXY
                                                   toCoordinateFromView:_mapView];

//        dispatch_queue_t concurrentQueue =
//        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//        dispatch_async(concurrentQueue,
//                       ^{
//                           
//                       });
        
        [self feedModelLatitude: compassCtrCoord.latitude
                      longitude: compassCtrCoord.longitude
                        heading: [self calculateCameraHeading]
                           tilt: -_mapView.camera.pitch];
        
        // [todo] This code should be put into the gesture recognizer
        // Disable the compass
        
        // Gets array of subviews from the map view (MKMapView)
        
        if ([self.glkView isHidden] == NO){
            [self setFactoryCompassHidden:YES];
        }
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue,
                       ^{
                           // Redraw the compass
                           [self.glkView setNeedsDisplay];
                       });

    }
}

- (void) setFactoryCompassHidden: (BOOL) flag {
    NSArray *mapSubViews = self.mapView.subviews;
    
    for (UIView *view in mapSubViews) {
        // Checks if the view is of class MKCompassView
        if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
            [view setHidden:flag];
//            // Removes view from mapView
//            [view removeFromSuperview];
        }
    }
}

//---------------
// This function is called when user actions changes
// the location, heading and tilt.
//---------------
- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) camera_heading
                      tilt: (float) tilt_deg
{    
    //[todo] this is too heavy
    model->current_pos.orientation = -camera_heading;
    model->tilt = tilt_deg; // no tilt changes on iOS
    
    model->current_pos.latitude = lat_float;
    model->current_pos.longitude = lon_float;
    model->updateMdl();
}


- (float) calculateCameraHeading{
    // calculateCameraHeading calculates the heading of camera relative to
    // the magnetic north
    
    float true_north_wrt_up = 0;
    
    //---------------------------
    // fix angle calculation
    //---------------------------
    CLLocationCoordinate2D map_s_pt = [self.mapView centerCoordinate];
    CLLocationCoordinate2D center_pt = [self.mapView convertPoint:CGPointMake(160, 503.0/2) toCoordinateFromView:self.mapView];
    
    CLLocationCoordinate2D map_n_pt = [self.mapView convertPoint:CGPointMake(160, 230) toCoordinateFromView:self.mapView];
    
    true_north_wrt_up = [self computeOrientationFromLocation:(CLLocationCoordinate2D) map_s_pt
                                            toLocation: (CLLocationCoordinate2D) map_n_pt];
    return true_north_wrt_up;
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
    }
    return self;
}

// [todo] This somehow is not working
-(void)rotate:(UIRotationGestureRecognizer *)gesture
{
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        // Gets array of subviews from the map view (MKMapView)
        NSArray *mapSubViews = self.mapView.subviews;
        
        for (UIView *view in mapSubViews) {
            // Checks if the view is of class MKCompassView
            if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
                // Removes view from mapView
                [view removeFromSuperview];
            }
        }
    }
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
    [self updateMapDisplayRegion];
    self.mapView.delegate = self;
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    
    [self.mapView addGestureRecognizer:rotateGesture];
    
    
    // Provide the centroid of compass to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: CGPointMake(self.glkView.frame.size.width/2
                                            + [self.model->configurations[@"compass_centroid"][0] floatValue],
                                            self.glkView.frame.size.height/2+
                                            - [self.model->configurations[@"compass_centroid"][1] floatValue])
                      fromView:self.glkView];    
//    cout << "glk.x: " << self.glkView.frame.size.width << endl;
//    cout << "glk.y: " << self.glkView.frame.size.height << endl;
//    NSLog(@"centroid: %@", NSStringFromCGPoint(self.model->compassCenterXY));
//    NSLog(@"Done!");
    
    // Add pin annotations
    [self renderAnnotations];
    
    //-------------------
    // Connect mapView to render
    //-------------------
    self.renderer->mapView = [self mapView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ------update------
- (void) updateMapDisplayRegion{
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    static int once = 0;
    if (once==0){
        MKCoordinateRegion region;
        region.center.latitude = self.model->current_pos.latitude;
        region.center.longitude = self.model->current_pos.longitude;
        
        region.span.longitudeDelta = self.model->latitudedelta;
        region.span.latitudeDelta = self.model->longitudedelta;
        [_mapView setRegion:region];
        once = 1;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = self.model->current_pos.latitude;
    coord.longitude = self.model->current_pos.longitude;
    
    
//    // The compass may be off-center, thus we need to calculate the
//    // coordinate of the true center
//    [self.mapView convertPoint: NSMakePoint(-self.compassView.frame.size.width/2,
//                                            -self.compassView.frame.size.height/2)
//                      fromView:self.compassView];
    
    
    
    [self.mapView setCenterCoordinate:coord animated:YES];
}

-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue
{
    // There is a bug here. There seems to be an extra shift component.
    if (self.needUpdateDisplayRegion){
        [self updateMapDisplayRegion];
        self.needUpdateDisplayRegion = false;
    }
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


#pragma mark ------Toolbar Items------

//------------------
// Toggle between conventional compass and personalized compass
//------------------
- (IBAction)toggleCompass:(id)sender {
    if ([self.glkView isHidden] == NO){
        [self.glkView setHidden:YES];
        [self setFactoryCompassHidden:NO];
    }else{
        [self.glkView setHidden:NO];
        [self setFactoryCompassHidden:YES];
    }
}

//------------------
// Show pcomass in big size
//------------------
- (IBAction)toggleExplrMode:(id)sender {
    
    static BOOL explr_mode = false;
    // need to do a deep copy
    // http://www.cocoanetics.com/2009/09/deep-copying-dictionaries/
    
    static NSDictionary* cache_configurations =
    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject: self.renderer->model->configurations]];
    
    if (!explr_mode){
        // Change background color
        for (int i = 0; i<4; ++i){
            self.renderer->model->configurations[@"bg_color"][i] =
            [NSNumber numberWithFloat:255];
        }
        // Change compass ctr
        for (int i = 0; i<2; ++i){
            self.renderer->model->configurations[@"compass_centroid"][i] =
            [NSNumber numberWithFloat:0];
        }
        self.renderer->model->configurations[@"compass_scale"] =
        [NSNumber numberWithFloat:0.9];
        
        [self.glkView setNeedsDisplay];
        explr_mode = true;
    }else{
        for (int i = 0; i<4; ++i){
            self.renderer->model->configurations[@"bg_color"][i] =
            cache_configurations[@"bg_color"][i];
        }
        
        // revert
        // Change compass ctr
        for (int i = 0; i<2; ++i){
            self.renderer->model->configurations[@"compass_centroid"][i] =
            cache_configurations[@"compass_centroid"][i];
        }
        self.renderer->model->configurations[@"compass_scale"] =
        cache_configurations[@"compass_scale"];
        
        explr_mode = false;
        [self.glkView setNeedsDisplay];
    }
}

//------------------
// Show the menu view
//------------------
- (IBAction)toggleMenu:(id)sender {
    if ([[self menuView] isHidden])
        [[self menuView] setHidden:NO];
    else
        [[self menuView] setHidden:YES];
}

//------------------
// Tools
//------------------
-(double) computeOrientationFromLocation:(CLLocationCoordinate2D) refPt
                              toLocation: (CLLocationCoordinate2D) destPt{
    
    double lat1 = DegreesToRadians(refPt.latitude);
    double lon1 = DegreesToRadians(refPt.longitude);
    
    double lat2 = DegreesToRadians(destPt.latitude);
    double lon2 = DegreesToRadians(destPt.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    return RadiansToDegrees(radiansBearing);
}
@end

