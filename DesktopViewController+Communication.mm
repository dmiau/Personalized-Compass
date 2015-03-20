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
#ifndef __IPHONE__
    //Unpack the data
    NSDictionary *myDictionary = (NSDictionary*)
    [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSString* package_type = myDictionary[@"Type"];
    
    if ([package_type isEqualToString:@"Instruction"]){
        NSString* command = myDictionary[@"Command"];
        
        if ([command isEqualToString: @"SetupEnv"]){
            
            //-----------------
            // Recevie setup env request from iOS, the dbroot must be in study
            //-----------------
            if (![[self.model->desktopDropboxDataRoot lastPathComponent] isEqualToString:@"study"])
            {
                // Change the folder to the study folder
                self.model->desktopDropboxDataRoot =
                [self.model->desktopDropboxDataRoot stringByAppendingPathComponent: @"study"];
            }else{
                if (self.testManager->testManagerMode == OSXSTUDY){
                    // OSX is already in the study mode, and the directory is
                    // correct
                    
                    if (![self.model->snapshot_filename isEqualToString:
                          myDictionary[@"Parameter"]])
                    {
                        [self displayPopupMessage:
                         [NSString stringWithFormat:@"iOS: %@\nOSX: %@\n Snapshot files mismatch between OSX and iOS.", myDictionary[@"Parameter"],
                          self.model->snapshot_filename]];
                        
                         return;
                    }
                }
            }
            // Load the snapshot file (a forced load)
            self.model->snapshot_filename = myDictionary[@"Parameter"];
            if (readSnapshotKml(self.model) != EXIT_SUCCESS){
                // readSnapshotKml should pop up a dialog alread, so we will return from here
                return;
            }
            
            self.testManager->toggleStudyMode(YES, NO);
            self.testManager->isLocked = YES;            
        }else if ([command isEqualToString: @"LoadSnapshot"]){
            int test_id = [myDictionary[@"Parameter"] intValue];
            self.testManager->showTestNumber(test_id);
            
        }else if ([command isEqualToString: @"Start"]){
            
        }else if ([command isEqualToString: @"SwitchControl"]){
            self.testManager->testManagerMode = DEVICESTUDY;
            
        }else if ([command isEqualToString: @"End"]){
            self.testManager->toggleStudyMode(NO, NO);
        }else if ([command isEqualToString: @"Sync"]){
            // Sync with iOS
            if (self.iOSSyncFlag)
            {
                // UI update needs to be on main queue?
                dispatch_async(dispatch_get_main_queue(),
                               ^{[self syncWithiOS: myDictionary];});
            }
        }
                
    }else if ([package_type isEqualToString:@"Message"]){
        NSString* content = myDictionary[@"Content"];
        
        
        NSCharacterSet* nonNumbers = [NSCharacterSet decimalDigitCharacterSet];
        if ([content rangeOfCharacterFromSet:nonNumbers].location != NSNotFound){
            //-------------
            // Contains a number
            // This only happens in the orient test
            //-------------
            self.testManager->iOSAnswer = [content doubleValue];
            
            if (self.testManager->testManagerMode == OSXSTUDY){
                self.testManager->endTest(CGPointMake(0, 0), [content doubleValue]);
            }
            
            NSLog(@"Received angle: %g", [content doubleValue]);
        }else{
            //-------------
            // Contains message
            //-------------
            [self displayPopupMessage:[NSString stringWithFormat:@"Received message: %@", content]];
        }
    }else if ([package_type isEqualToString:@"Truth"]){
//        // Unpack the data
//        NSData *myData;
//        //Unpack parameters of the map region
//        myData = myDictionary[@"Record"];
//        record myRecord;
//        [myData getBytes:&myRecord length:sizeof(myRecord)];
    
        self.testManager->record_vector[self.testManager->test_counter]
        .doubleTruth = [myDictionary[@"DoubleTruth"] doubleValue];
    }else{
        throw(runtime_error("Unknown package type."));
    }
#endif
}

//---------------------------
//iOS
// This is for iOS, since iOS cannot handle NSData
//---------------------------
-(void)handleMessage:(NSString*)message{
    self.received_message = message;

#ifndef __IPHONE__
    //-----------------
    // OSX
    //-----------------
    
    // Check if the received message is a number
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *temp = [f numberFromString: message];
    if ( temp != nil){
            self.testManager->showTestNumber([temp intValue]);
    }
#else
    //-----------------
    // iPhone
    //-----------------
    
    // Check if the received message is a number
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *temp = [f numberFromString: message];
    if ( temp != nil){
        //-------------------
        // Receive a number, meaning iOS should load a test
        //-------------------
        if (self.testManager->testManagerMode != OFF)
            self.testManager->showTestNumber([temp intValue]);
    }else{
        //-------------------
        // Receive an actual message
        //-------------------
        
        // Handle the message only if the received message is a KML file name
        if ([message rangeOfString:@".snapshot"].location != NSNotFound)
        {
                self.model->snapshot_filename = message;
                
                if (readSnapshotKml(self.model) != EXIT_SUCCESS){
                    [self displayPopupMessage:
                     [NSString stringWithFormat:@"Failed to load %@", message]];
                    return;
                }else{
                    [self displayPopupMessage:
                     [NSString stringWithFormat:@"Successfully loaded %@", message]];
                }
            self.testManager->toggleStudyMode(YES, NO);
        }else if ([message isEqualToString:@"End"]){
            self.testManager->toggleStudyMode(NO, NO);
        }else if ([message isEqualToString:@"ShowAnswers"]){
            // Display the answer
            [self toggleAnswersVisibility:YES];
        }
    }
#endif
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
