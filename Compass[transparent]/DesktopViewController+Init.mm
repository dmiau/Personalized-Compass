//
//  DesktopViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Init.h"

@implementation DesktopViewController (Init)

#pragma mark initialization

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        if((self = [super init])) {
            self.model = compassMdl::shareCompassMdl();
            
            // Get the pointer to render
            // At this point the render may not be fully initialized
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
            
            // Important, initialize NSMutableArray with empty cells
            tableCellCache = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < self.model->data_array.size(); ++i)
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
    
    self.renderer->mapView = [self mapView];
    
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
     [self.model->location_filename
      lastPathComponent]];
    
    [self updateMapDisplayRegion];
    
    // Provide the compass centroid information to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: NSMakePoint(self.compassView.frame.size.width/2,
                                            self.compassView.frame.size.height/2)
                      fromView:self.compassView];
    //-----------------
    // Add annotation to the map
    //-----------------
    [self renderAnnotations];
}

@end
