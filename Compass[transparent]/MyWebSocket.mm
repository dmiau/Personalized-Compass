#import "DesktopViewController.h"
#import "MyWebSocket.h"
#import "AppDelegate.h"
//#import "HTTPLogging.h"

// Log levels: off, error, warn, info, verbose
// Other flags : trace
//static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;

//
@implementation MyWebSocket


- (id) initWithRequest:(HTTPMessage *)request socket:(GCDAsyncSocket *)socket{
    self = [super initWithRequest:request socket:socket];
    if(self){
        
        AppDelegate *temp = [[NSApplication sharedApplication] delegate];
        // Initialize self.
        self.rootViewController = temp.rootViewController;
        
        // Inject myself to DesktopViewController
        self.rootViewController.webSocket = self;
    }
    return self;
}

- (void)didOpen
{
//	HTTPLogTrace();
	
	[super didOpen];
	
	[self sendMessage:@"Welcome to my WebSocket"];
}

- (void)didReceiveMessage:(NSString *)msg
{
//	HTTPLogTrace2(@"%@[%p]: didReceiveMessage: %@", THIS_FILE, self, msg);
	
    NSLog(@"didReceiveMessage: ", msg);
	[self sendMessage:[NSString stringWithFormat:@"%@", [NSDate date]]];
}

- (void)didReceiveData:(NSData *)data
{
//    HTTPLogTrace2(@"%@[%p]: didReceiveData", THIS_FILE, self);


    NSLog(@"didReceiveData!");
    //http://stackoverflow.com/questions/9593803/testing-for-type-of-class-in-objective-c?rq=1
    
//    //Unpack the data
//    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self.rootViewController handlePackage:data];
    });
    //Pass the received data to the data handler

}

- (void)didClose
{
//	HTTPLogTrace();
	
	[super didClose];
}

@end
