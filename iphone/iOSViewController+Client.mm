//
//  iOSViewController+Client.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/25/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Client.h"

//-----------------
// TCMessage
//-----------------

@interface TCMessage : NSObject

- (id)initWithMessage:(NSString *)message fromMe:(BOOL)fromMe;

@property (nonatomic, retain, readonly) NSString *message;
@property (nonatomic, readonly)  BOOL fromMe;

@end


@implementation TCMessage

@synthesize message = _message;
@synthesize fromMe = _fromMe;

- (id)initWithMessage:(NSString *)message fromMe:(BOOL)fromMe;
{
    self = [super init];
    if (self) {
        _fromMe = fromMe;
        _message = message;
    }
    
    return self;
}

@end

//-----------------
// ViewController
//-----------------
@implementation iOSViewController (Client)

#pragma mark - View lifecycle

- (void)_reconnect;
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"ws://%@:%d/service",
         self.ip_string, self.port_number]]]];
    
    _webSocket.delegate = self;
    
    [_webSocket open];
    
}

- (void) toggleServerConnection: (bool) status{
    if (status){
        [self _reconnect];
    }else{
        _webSocket.delegate = nil;
        [_webSocket close];
        _webSocket = nil;
        @synchronized(self.socket_status){
            self.socket_status = [NSNumber numberWithBool:NO];
        }
        [self logSystemMessage:@"Disconnecting..."];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    
    @synchronized(self.socket_status){
        self.socket_status = [NSNumber numberWithBool:YES];
    }
    [self logSystemMessage:@"Connected!"];
    [self saveSystemMessage];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    @synchronized(self.socket_status){
        // Try reconnect if the previous socket_status was previously true
        if (self.socket_status){
            [self attemptReconnect];
        }else{
            [self displayPopupMessage:
             [NSString stringWithFormat: @"Connection failed with error: %@", error]];
        }
        self.socket_status = [NSNumber numberWithBool:NO];
    }
    [self logSystemMessage:
    [NSString stringWithFormat: @"Connection failed with error: %@", error]];
    [self saveSystemMessage];
    
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}

//--------------
// Make one attempt to reconnect
//--------------
- (void) attemptReconnect{
    [self toggleServerConnection:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    [self logSystemMessage:[NSString stringWithFormat:@"Received \"%@\"", message]];
    
    [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
    
    [self handleMessage:(NSString*)message];
}



- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    
    @synchronized(self.socket_status){
        self.socket_status = [NSNumber numberWithBool:NO];        
        [self displayPopupMessage:@"Connection was dropped."];
        
        if (self.testManager->testManagerMode != OFF){
            // Shutdown the study mode if a connection is dropped
            self.testManager->isRecordAutoSaved = YES;
            self.testManager->toggleStudyMode(NO, NO);
        }
    }
    NSLog(@"WebSocket closed");
    [self logSystemMessage:[NSString
                          stringWithFormat: @"Connection was dropped! %@", reason]];
    [self saveSystemMessage];
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        NSString *message = [[textView.text stringByReplacingCharactersInRange:range withString:text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [_webSocket send:message];
        [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:YES]];
        
        textView.text = @"";
        return NO;
    }
    return YES;
}
@end