//
//  iOSViewController+Client.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/25/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController.h"

@interface iOSViewController (Client)

- (IBAction) joinChat;
- (void) initNetworkCommunication;
- (IBAction) sendMessage;
- (void) messageReceived:(NSString *)message;

@end
