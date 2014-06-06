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

- (void) awakeFromNib
{
    // Insert code here to initialize your application
    // Disable compass is somehow tricky in iOS...
//    http://stackoverflow.com/questions/19195936/disable-compass-on-mkmapview
//    [self mapView].showsCompass =NO;
//    [self mapView].rotateEnabled = YES;
    
    
    [self addObserver:self forKeyPath:@"mapUpdateFlag"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    
    
    //http://stackoverflow.com/questions/10796058/is-it-possible-to-continuously-track-the-mkmapview-region-while-scrolling-zoomin?lq=1
    
    _updateUITimer = [NSTimer timerWithTimeInterval:0.015
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
    
   
//    [self updateMapDisplayRegion];
}

-(void)vcTimerFired{
    
    static double latitude_cache = 0.0;
    static double longitude_cache = 0.0;
    static double pitch_cache = 0.0;
    double epsilon = 0.0000001;
    
    if ( abs((double)(latitude_cache - [_mapView centerCoordinate].latitude)) > epsilon ||
        abs((double)(longitude_cache - [_mapView centerCoordinate].longitude)) > epsilon ||
        abs((double)(pitch_cache - _mapView.camera.pitch)) > epsilon)
    {
        latitude_cache = [_mapView centerCoordinate].latitude;
        longitude_cache = [_mapView centerCoordinate].longitude;
        pitch_cache = _mapView.camera.pitch;
        
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
        
        [self feedModelLatitude: [_mapView centerCoordinate].latitude
                      longitude: [_mapView centerCoordinate].longitude
                        heading: -_mapView.camera.heading
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
        
        
        // Redraw the compass
        [self.glkView setNeedsDisplay];
    }
}

//---------------
// This function is called when user actions changes
// the location, heading and tilt.
//---------------
- (void) feedModelLatitude: (float) lat_float
                 longitude: (float) lon_float
                   heading: (float) heading_deg
                      tilt: (float) tilt_deg
{
    NSString *latlon_str = [NSString stringWithFormat:@"%2.4f, %2.4f",
                            lat_float, lon_float];
    
    //[todo] this is too heavy
    model->current_pos.orientation = heading_deg;
//    model->tilt = tilt_deg; // no tilt changes on iOS
    
    model->current_pos.latitude = lat_float;
    model->current_pos.longitude = lon_float;
    model->updateMdl();
}


#pragma mark ----Initialization----

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
        
        pinVisible = FALSE;
        
        if (self.model == NULL)
            throw(runtime_error("compassModel is uninitialized"));
        
        // Collect a list of kml files
        NSString *path = [[[NSBundle mainBundle]
                           pathForResource:@"montreal.kml" ofType:@""]
                          stringByDeletingLastPathComponent];
        
        NSArray *dirFiles = [[NSFileManager defaultManager]
                             contentsOfDirectoryAtPath: path error:nil];
        kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
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
