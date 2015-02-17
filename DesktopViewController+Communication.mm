//
//  DesktopViewController+Communication.m
//  Compass[transparent]
//
//  Created by Daniel on 2/5/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "snapshotParser.h"
#ifdef __IPHONE__
//-------------------
// iOS
//-------------------
#import "iOSViewController.h"
@implementation iOSViewController (Communication)

#else
//-------------------
// Desktop (osx)
//-------------------
#import "DesktopViewController.h"
#import "MyWebSocket.h"
@implementation DesktopViewController (Communication)
#endif


//-------------------
// iOS -> desktop
// Sending package
//-------------------
-(void)sendPackage: (NSDictionary *) package
{
    if (![self.socket_status boolValue]){
        NSLog(@"Communication has not been enabled.");
        return;
    }
    
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:package];
#ifdef __IPHONE__
    //-------------------
    // iOS
    //-------------------
    // Send the data (in the form of NSData)
    //http://stackoverflow.com/questions/5513075/how-can-i-convert-nsdictionary-to-nsdata-and-vice-versa
    [_webSocket send: myData];
#endif
}


//------------------
// Desktop -> iOS
// This is for the desktop to communicate with iOS
//------------------
- (void)sendMessage: (NSString*) message{
    
#ifndef __IPHONE__
    //-------------------
    // OSX
    //-------------------
    [self.webSocket sendMessage:message];
#endif
}

/*
 -----------------------------------
 Desktop
 This is for OSX only, since iOS cannot handle NSData
  -----------------------------------
 */
-(void)handlePackage: (NSData*) data
{
    //Unpack the data
    NSDictionary *myDictionary = (NSDictionary*)
    [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSString* package_type = myDictionary[@"Type"];
    
    if ([package_type isEqualToString:@"Instruction"]){
        NSString* command = myDictionary[@"Command"];
        
        if ([command isEqualToString: @"SetupEnv"]){
            // Load the snapshot file
            
            if (![myDictionary[@"Parameter"] isEqualToString:
                  self.model->snapshot_filename]){
                self.model->snapshot_filename = myDictionary[@"Parameter"];
                
                if (readSnapshotKml(self.model) != EXIT_SUCCESS){
                    throw(runtime_error("Failed to load snapshot files"));
                }
            }
            self.testManager->initTestEnv(COLLECT);

        }else if ([command isEqualToString: @"LoadSnapshot"]){
            int test_id = [myDictionary[@"Parameter"] intValue];
            self.testManager->showTestNumber(test_id);
            
        }else if ([command isEqualToString: @"Start"]){
            
        }else if ([command isEqualToString: @"SwitchControl"]){
            self.testManager->testManagerMode = CONTROL;
            
        }else if ([command isEqualToString: @"End"]){
            
        }else if ([command isEqualToString: @"Sync"]){
#ifndef __IPHONE__
            //    [self sendMessage:[NSString stringWithFormat:@"%@", [NSDate date]]];
            
            // Sync with iOS
            if (self.iOSSyncFlag)
            {
                // UI update needs to be on main queue?
                dispatch_async(dispatch_get_main_queue(),
                               ^{[self syncWithiOS: myDictionary];});
            }
#endif
        }
                
    }else{
        throw(runtime_error("Unknown package type."));
    }
}

//---------------------------
//iOS
// This is for iOS, since iOS cannot handle NSData
//---------------------------
-(void)handleMessage:(NSString*)message{
    
    // 
    self.received_message = message;
    
//    if ([message isEqualToString:@"NONE"]){
//        // Default message
//        
//    }else if ([message isEqualToString:@"OK"]){
//        
//    }else if ([message isEqualToString:@"BAD"]){
//        
//    }else if ([message isEqualToString:@"NEXT"]){
//        
//    }
}


#ifndef __IPHONE__
//---------------------
// Sync with iOS (only on the desktop)
//---------------------
-(void)syncWithiOS: (NSDictionary*) myDictionary
{
    NSData *myData;
    //Unpack parameters of the map region
    myData = myDictionary[@"map_region"];
    MKCoordinateRegion temp_region;
    [myData getBytes:&temp_region length:sizeof(temp_region)];
    

    
    
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
    // Update model parameters
    [self updateMapDisplayRegion:expanded_region withAnimation:YES];
    
    self.mapView.camera.heading = -[myDictionary[@"mdl_orientation"] floatValue];
    
    //--------------------------
    // Calculate the four corners of the iOS display
    //--------------------------
    //Unpack parameters of the four corners
    myData = myDictionary[@"ulurbrbl"];
    
    LatLons4x2 temp_corner;
    [myData getBytes:&temp_corner length:sizeof(temp_corner)];
    self.renderer->emulatediOS.updateFourLatLon(temp_corner.content);
    
}
#endif

#ifdef __IPHONE__
//--------------------
// Send the parameters associated with the current display area
//--------------------
- (void) sendBoundaryLatLon
{
    // Do nothing is the connection is not established yet
    if ([self.socket_status boolValue] == NO)
        return;
    
    LatLons4x2 temp_corner = self.latLons4x2;
    MKCoordinateRegion temp_region = self.mapView.region;
    
    // Package the data
    NSDictionary *myDict = @{@"Type"  :@"Instruction",
                             @"Command"  :@"Sync",
                             @"ulurbrbl" :
                                 [NSData dataWithBytes:&(temp_corner)
                                                length:sizeof(temp_corner)],
                             @"map_region":[NSData dataWithBytes:
                                            &(temp_region)
                                                          length:sizeof(temp_region)],
                             @"mdl_orientation":[NSNumber numberWithFloat:
                                                 self.model->camera_pos.orientation],
                             @"mdl_tilt":[NSNumber numberWithFloat:
                                          self.model->tilt]};
    
    [self sendPackage:myDict];    
//    // Send the data (in the form of NSData)
//    //http://stackoverflow.com/questions/5513075/how-can-i-convert-nsdictionary-to-nsdata-and-vice-versa
//    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:myDict];
//    [_webSocket send: myData];
}
#endif

@end
