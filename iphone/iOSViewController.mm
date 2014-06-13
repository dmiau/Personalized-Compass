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
        NSArray *mapSubViews = self.mapView.subviews;
        
        for (UIView *view in mapSubViews) {
            // Checks if the view is of class MKCompassView
            if ([view isKindOfClass:NSClassFromString(@"MKCompassView")]) {
                // Removes view from mapView
                [view removeFromSuperview];
            }
        }
        
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue,
                       ^{
                           // Redraw the compass
                           [self.glkView setNeedsDisplay];
                       });

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
    NSString *latlon_str = [NSString stringWithFormat:@"%2.4f, %2.4f",
                            lat_float, lon_float];
    
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
    
    CLLocationCoordinate2D map_s_pt = {40.762959, -73.981161};
    CLLocationCoordinate2D map_n_pt = {42.762959, -73.981161};
    
    CGPoint screen_s_pt = [self.mapView convertCoordinate:map_s_pt toPointToView:self.mapView];

    CGPoint screen_n_pt = [self.mapView convertCoordinate:map_n_pt toPointToView:self.mapView];

    //  Here is the screen coordinate system
    //  -------------- +x
    //  |
    //  |
    //  |
    //  +y
    
    // As a result, there is a negative sign after the difference in y
    
    // Second the heading is defined such that the north is 0,
    // as a result, we need to use 90 to substract the calculated heading
    
    true_north_wrt_up = 90 - atan2(-(screen_n_pt.y - screen_s_pt.y),
                       screen_n_pt.x - screen_s_pt.x)* 180 / M_PI;
    return -true_north_wrt_up;
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
    
    // Create an OpenGL ES context and assign it to the view loaded from storyboard
    [self.glkView initWithFrame:self.glkView.frame
                context:
     [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1]];

    [self updateMapDisplayRegion];
    
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    
    [self.mapView addGestureRecognizer:rotateGesture];
    
    
    // Provide the centroid of compass to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: CGPointMake(self.glkView.frame.size.width/2
                                            + [self.model->configurations[@"compass_centroid"][0] floatValue],
                                            self.glkView.frame.size.height/2+
                                            - [self.model->configurations[@"compass_centroid"][1] floatValue])
                      fromView:self.glkView];
    
    cout << "glk.x: " << self.glkView.frame.size.width << endl;
    cout << "glk.y: " << self.glkView.frame.size.height << endl;
    NSLog(@"centroid: %@", NSStringFromCGPoint(self.model->compassCenterXY));
    NSLog(@"Done!");
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
    [self.mapView setCenterCoordinate:coord animated:YES];
}

-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue
{
    [self updateMapDisplayRegion];
     // Nothing needed here.
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

@end
