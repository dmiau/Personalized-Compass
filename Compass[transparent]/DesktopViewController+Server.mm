//
//  DesktopViewController+Server.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Server.h"


// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@implementation DesktopViewController (Server)

-(void)startServer{
	// Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Create server using our custom MyHTTPServer class
	httpServer = [[HTTPServer alloc] init];
	
	// Tell server to use our custom MyHTTPConnection class.
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	// [httpServer setPort:12345];
	
	// Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
	
	// Start the server (and check for problems)
	
	NSError *error;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    self.httpServer = httpServer;
}

//---------------------
// Sync with iOS
//---------------------
-(void)syncWithiOS: (NSDictionary*) myDictionary
{
    NSData *myData;
    //Unpack parameters of the map region
    myData = myDictionary[@"map_region"];
    MKCoordinateRegion temp_region;
    [myData getBytes:&temp_region length:sizeof(temp_region)];
    
    // Update model parameters
    self.model->camera_pos.latitude = temp_region.center.latitude;
    self.model->camera_pos.longitude = temp_region.center.longitude;
//    self.model->camera_pos.orientation =
//    [myDictionary[@"mdl_orientation"] floatValue];
//    self.model->tilt =
//    [myDictionary[@"mdl_tilt"] floatValue];
    
    [self updateMapDisplayRegion: YES];
//    self.mapView.region = mySnapshot.coordinateRegion;
    
    // Not sure why setRegion does not work well...
    //    [self.mapView setRegion: mySnapshot.coordinateRegion animated:YES];

    
    float OSX_iOS_screen_ratio = 5;
    if (self.model->configurations[@"wedge_status"] == @"on"){
        OSX_iOS_screen_ratio = 1.5;
    }
    
    // Make the display region bigger than iOS's
    MKCoordinateRegion expanded_region =
    MKCoordinateRegionMake(temp_region.center,
                           MKCoordinateSpanMake(
                            OSX_iOS_screen_ratio*temp_region.span.latitudeDelta,
                            OSX_iOS_screen_ratio*temp_region.span.longitudeDelta));
    self.mapView.region = expanded_region;
    
    self.model->updateMdl();
    
    
    self.mapView.camera.heading = -[myDictionary[@"mdl_orientation"] floatValue];

    //--------------------------
    // Calculate the four corners of the iOS display
    //--------------------------
    //Unpack parameters of the four corners
    myData = myDictionary[@"ulurbrbl"];
    
    Corners4x2 temp_corner;
    [myData getBytes:&temp_corner length:sizeof(temp_corner)];
    self.corners4x2 = temp_corner;
    for (int i = 0; i < 4; ++i){
        self.renderer->iOSFourCorners[i] =
        [self.mapView convertCoordinate:
         CLLocationCoordinate2DMake(temp_corner.content[i][0],
                                    temp_corner.content[i][1])
                          toPointToView:self.compassView];
    }
}

@end
