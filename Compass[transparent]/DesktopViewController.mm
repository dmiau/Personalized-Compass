//
//  DesktopViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController.h"
#import "AppDelegate.h"
#import "LocationCellView.h"
#import "OpenGLView.h"
#include <cmath>

@implementation DesktopViewController
@synthesize model;

//------------------------------------------------------------------
#pragma mark initialization

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        if((self = [super init])) {
            model = compassMdl::shareCompassMdl();
            self.renderer = compassRender::shareCompassRender();
            
            pinVisible = FALSE;
            
            if (model == NULL)
                throw(runtime_error("compassModel is uninitialized"));
            
            // Collect a list of kml files
            NSString *path = [[[NSBundle mainBundle]
                               pathForResource:@"montreal.kml" ofType:@""]
             stringByDeletingLastPathComponent];
            
            NSArray *dirFiles = [[NSFileManager defaultManager]
                                 contentsOfDirectoryAtPath: path error:nil];
            kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
            
            // Important, initialize NSMutableArray with empty cells
            tableCellCache = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < model->data_array.size(); ++i)
            {
                [tableCellCache addObject:[NSNull null]];
            }
            
        }
    }
    return self;
}



- (void) awakeFromNib
{
    // Insert code here to initialize your application
    
    [[self mapView] setScrollEnabled:YES];
    [self mapView].showsZoomControls =YES;
    //    [self mapView].showsCompass =YES;
    [self mapView].rotateEnabled = YES;
    
    
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
     [[NSString stringWithUTF8String: model->location_filename.c_str()]
      lastPathComponent]];
    
    [self updateMapDisplayRegion];
    
    // Provide the compass centroid information to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: NSMakePoint(self.compassView.frame.size.width/2,
                                            self.compassView.frame.size.height/2)
          fromView:self.compassView];
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
        
        CLLocationCoordinate2D compassCtrCoord = [_mapView convertPoint:
        model->compassCenterXY
    toCoordinateFromView:_mapView];
        // [_mapView centerCoordinate].latitude
        // [_mapView centerCoordinate].longitude
        [self feedModelLatitude: compassCtrCoord.latitude
                      longitude: compassCtrCoord.longitude
                        heading: -_mapView.camera.heading
                           tilt: -_mapView.camera.pitch];
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
    [[self currentCoord] setStringValue: latlon_str];
    
    //[todo] this is too heavy
    model->current_pos.orientation = heading_deg;
    model->tilt = tilt_deg;
    
    model->current_pos.latitude = lat_float;
    model->current_pos.longitude = lon_float;
    model->updateMdl();
    
    // Update distances on the table
    NSScrollView* scrollView = [self.locationTableView enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(concurrentQueue,
                   ^{
                       NSRange range = [self.locationTableView rowsInRect:visibleRect];
                       for (int i = range.location; i < range.location + range.length; ++i){
                           // [todo] This part is ver slow...
                           ((LocationCellView*)[tableCellCache objectAtIndex:i]).infoTextField.stringValue = [NSString stringWithFormat:@"%.2f (m)",self.model->data_array[i].distance];
                       }
                   });
    //        NSLog(@"location: %d, length:  %d", range.location, range.length);
}



//------------------------------------------------------------------
#pragma mark ------------- menu items -------------

// This sorting thing does not quite work for some reason
// 
static NSComparisonResult myCustomViewAboveSiblingViewsComparator(id view1, id view2, void *context )
{
    if ([view1 isKindOfClass:[MKMapView class]]){
        NSLog(@"here1!");
        return NSOrderedAscending;
    }else if ([view2 isKindOfClass:[MKMapView class]]){
        NSLog(@"here2!");
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (IBAction)toggleMap:(id)sender {

    // Toggle MapView status
    if ([self.mapView isHidden] == NO){
        [self.mapView setHidden:YES];
        [(NSMenuItem *)sender setTitle:@"Show Map"];
    }else{
        [self.mapView setHidden:NO];
        
        // [4.24.2014]
        // [todo] The following is a hack to make sure views appear
        // in the desired order. It is basically a hack
        // but I couldn't figure out a better solution at the momnet. 
        // We know that map view is always in the bottom
        NSArray *all_views = [[self.mapView superview] subviews];
        NSView *aView;
        for (aView in all_views){
            if (![aView isKindOfClass:[MKMapView class]]){
                [aView setHidden:YES];
                [aView setHidden:NO];
            }
        }
        
//        [[self.mapView superview]
//         sortSubviewsUsingFunction:myCustomViewAboveSiblingViewsComparator
//         context:NULL];
        [(NSMenuItem *)sender setTitle:@"Hide Map"];
    }
}

- (IBAction)toggleCompass:(id)sender {
    // Toggle MapView status
    if ([self.compassView isHidden] == NO){
        [self.compassView setHidden:YES];
        [(NSMenuItem *)sender setTitle:@"Show Compass"];
    }else{
        [self.compassView setHidden:NO];
        [(NSMenuItem *)sender setTitle:@"Hide Compass"];        
    }
}

- (IBAction)rotate:(id)sender {
    // Get the sender title
    NSString *title = [(NSMenuItem *)sender title];
    
    MKMapCamera *mycamera = self.mapView.camera;
    
    CLLocationDirection cur_heading = mycamera.heading;
    
    if ([title rangeOfString:@"CCW"].location == NSNotFound){
        mycamera.heading = cur_heading - 2;
        // Update the compassModel's orientation
        //[todo] need to fix orientation
        model->current_pos.orientation = model->current_pos.orientation +2;
    }else{
        mycamera.heading = cur_heading + 2;
        model->current_pos.orientation = model->current_pos.orientation -2;
    }
    cout << "Orientation: " << model->current_pos.orientation << endl;
    [self.mapView setCamera:mycamera animated:YES];
}

- (IBAction)refreshConfigurations:(id)sender {
    
    // [todo] update code can be refactored 
    model->reloadFiles();
    [self updateMapDisplayRegion];
    [self.locationTableView reloadData];
}

#pragma mark ------------- User Interface -------------
- (void) updateMapDisplayRegion{
    //http://stackoverflow.com/questions/14771197/ios-beginning-ios-tutorial-underscore-before-variable
    static int once = 0;
    if (once==0){
        MKCoordinateRegion region;
        region.center.latitude = model->current_pos.latitude;
        region.center.longitude = model->current_pos.longitude;
        
        region.span.longitudeDelta = model->latitudedelta;
        region.span.latitudeDelta = model->longitudedelta;
        [_mapView setRegion:region];
        once = 1;
    }
    
    CLLocationCoordinate2D coord;
    coord.latitude = model->current_pos.latitude;
    coord.longitude = model->current_pos.longitude;
    [self.mapView setCenterCoordinate:coord animated:YES];
}

- (IBAction)didChangeKMLCombo:(id)sender {
    NSString* astr = [self.kmlComboBox stringValue];
    
    model->location_filename = std::string([ [[NSBundle mainBundle] pathForResource:astr                                                                             ofType:@""] UTF8String]);
    
    NSLog(@"json combon triggered %@", astr);
    
    // The following debug line did work!
    // po ((NSComboBox *)sender).stringValue

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.locationTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    
    //Begin editing of the cell containing the new object
    [self.locationTableView editColumn:0 row:0 withEvent:nil select:YES];
    
    
    [tableCellCache removeAllObjects];
    model->reloadFiles();
    
    
    for (int i = 0; i < model->data_array.size(); ++i)
    {
        [tableCellCache addObject:[NSNull null]];
    }
    
    [self updateMapDisplayRegion];
    [self.locationTableView reloadData];
}


// Combo box control
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return [kml_files count];
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)loc {
    return [kml_files objectAtIndex:loc];
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string {
    return [kml_files indexOfObject: string];
}

@end
