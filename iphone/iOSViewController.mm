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
        
        [self.searchDisplayController setDelegate:self];
        [self.ibSearchBar setDelegate:self];
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
    // There is a bug here. There seems to be an extra shift component.
    
    [self updateMapDisplayRegion];
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

- (IBAction)getCurrentLocation:(id)sender {
    
    // enable location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [self feedModelLatitude: newLocation.coordinate.latitude
                  longitude: newLocation.coordinate.longitude
                    heading: 0
                       tilt: 0];
    [self updateMapDisplayRegion];
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
}


#pragma mark ------Search Related Stuff-----
#pragma mark - Search Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    // startWithCompletionHander is a method of localSearch
    // startWithCompletionHander performs the search and puts the output to
    // results, whichi is a (private) property?!
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        // By the time this funciton is called, response has been filled up.
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

// Data presentation
// Three different types of table views


// This is called when the focus is put in the search boxis
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

// This is called when the results are ready to be displayed
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

// This is called when a table result is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    //http://stackoverflow.com/questions/17682834/mapview-with-local-search
    
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = item.placemark.coordinate;
    annotation.title      = item.name;
    annotation.subtitle   = item.placemark.title;
    //    [mapView addAnnotation:annotation];
    
    // Can you do that--add placemark directly as an annotation?
    //    [self.ibMapView addAnnotation:item.placemark];
    [self.mapView addAnnotation:annotation];
    
    // This line throws an error:
    // ERROR: Trying to select an annotation which has not been added
    //    [self.ibMapView selectAnnotation:item.placemark animated:YES];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
}

@end
