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
    
    
    
//    self.title = @"Opening Connection...";
    [_webSocket open];
    
}

- (void) toggleServerConnection: (bool) status{
    if (status){
        [self _reconnect];
    }else{
        _webSocket.delegate = nil;
        [_webSocket close];
        _webSocket = nil;
        self.socket_status = [NSNumber numberWithBool:NO];
    }
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    self.socket_status = [NSNumber numberWithBool:YES];
    
    self.system_message = @"Connected!";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    self.socket_status = [NSNumber numberWithBool:NO];
    self.system_message = @"Connection Failed! (see logs)";
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    self.system_message = [NSString stringWithFormat:@"Received \"%@\"", message];
    [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    self.socket_status = [NSNumber numberWithBool:NO];
    NSLog(@"WebSocket closed");
    self.system_message = @"Connection Closed! (see logs)";
    _webSocket = nil;
}

//--------------------
// Send the parameters associated with the current display area
//--------------------
- (void) sendData
{
    // Do nothing is the connection is not established yet
    if ([self.socket_status boolValue] == NO)
        return;
    
    Corners4x2 temp = self.corners4x2;
    
    // Package the data
    NSDictionary *myDict = @{@"ulurbrbl" :
                        [NSData dataWithBytes:&(temp)
                                       length:sizeof(temp)],
                             @"latitude": [NSNumber numberWithDouble:
                                           [self.mapView centerCoordinate].latitude],
                             @"longitude": [NSNumber numberWithDouble:
                                           [self.mapView centerCoordinate].longitude]};
    
    // Send the data (in the form of NSData)
    //http://stackoverflow.com/questions/5513075/how-can-i-convert-nsdictionary-to-nsdata-and-vice-versa
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:myDict];
    [_webSocket send: myData];
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