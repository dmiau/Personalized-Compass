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
        
        
        
    }else if ([package_type isEqualToString:@"Message"]){

        
    }else{
        throw(runtime_error("Unknown package type."));
    }
    
    
    // Not sure if the following is necessary.
    
    
#ifdef __IPHONE__
    //------------
    // iOS
    //------------
    
#else
    //------------
    // OSX
    //------------
    
    //    // Sync with iOS
    //    if (self.rootViewController.iOSSyncFlag)
    //    {
    //        // UI update needs to be on main queue?
    //        dispatch_async(dispatch_get_main_queue(),
    //                       ^{[self.rootViewController syncWithiOS: myDictionary];});
    //    }
#endif
}

@end
