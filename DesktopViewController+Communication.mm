//
//  DesktopViewController+Communication.m
//  Compass[transparent]
//
//  Created by Daniel on 2/5/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

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
// Sending package
//-------------------
-(void)sendPackage: (NSDictionary *) package
{
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:package];
#ifdef __IPHONE__
    //-------------------
    // iOS
    //-------------------
    // Send the data (in the form of NSData)
    //http://stackoverflow.com/questions/5513075/how-can-i-convert-nsdictionary-to-nsdata-and-vice-versa
    [_webSocket send: myData];
#else
    //-------------------
    // OSX
    //-------------------
    
    [self.webSocket sendData:myData];
#endif
}

//-------------------
// Handling package
//-------------------
-(void)handlePackage: (NSData*) data
{
    //Unpack the data
    NSDictionary *myDictionary = (NSDictionary*)
    [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //NSLog(@"Dictionary content:");
    //    for (id key in myDictionary) {
    //        NSLog(@"key: %@, value: %@ \n", key, [myDictionary objectForKey:key]);
    //    }
    
    //    [self sendMessage:[NSString stringWithFormat:@"%@", [NSDate date]]];

    // Design:
//    Data package:
//    Type: Instruction, Message
//    
//    - Instruction
//    *command: SetupEnv, LoadSnapshot, Start, SwitchControl, End, Sync
//    *parameter: filename, snapshot_id
//    *switchContorl: yes, no
//    
//    - Message
//    * status: OK, BAD, NEXT
//    * notes:
    
    NSString* package_type = myDictionary[@"Type"];
    
    if ([package_type isEqualToString:@"Instruction"]){
        NSString* command = myDictionary[@"Command"];
        
        if ([command isEqualToString: @"SetupEnv"]){
            self.testManager->initTestEnv(COLLECT);            
        }else if ([command isEqualToString: @"LoadSnapshot"]){
            int test_id = [myDictionary[@"SsnapshotID"] intValue];
            self.testManager->showTestNumber(test_id);
            
        }else if ([command isEqualToString: @"Start"]){
            
        }else if ([command isEqualToString: @"SwitchControl"]){
            self.testManager->testManagerMode = CONTROL;
            
        }else if ([command isEqualToString: @"End"]){
            
        }else if ([command isEqualToString: @"Sync"]){
#ifndef __IPHONE__
            //    NSLog(@"Dictionary content:");
            //    for (id key in myDictionary) {
            //        NSLog(@"key: %@, value: %@ \n", key, [myDictionary objectForKey:key]);
            //    }
            
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
                
    }else if ([package_type isEqualToString:@"Message"]){

        
    }else{
        throw(runtime_error("Unknown package type."));
    }
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
