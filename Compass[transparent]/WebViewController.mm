//
//  WebViewController.m
//  lab_webkit
//
//  Created by dmiau on 4/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "WebViewController.h"
#include <stdexcept>

@implementation WebViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Initialization code here.
//    }
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder*)aDecoder
//{
//    if(self = [super initWithCoder:aDecoder]) {
//        // Do something
//        if((self = [super init])) {
//
//        }
//    }
//    return self;
//}

- (void) awakeFromNib
{
    // Insert code here to initialize your application
    self.URL = @"http://maps.google.com";
    preURL = self.URL;
    self.textField.stringValue = self.URL;
    // Insert code here to initialize your application
    [[self.webView mainFrame]
     loadRequest:[NSURLRequest requestWithURL:
                  [NSURL URLWithString:self.URL]]];
    // The following key-vlaue observing code does not seem to work...
    //    //    [[[[[self.webView mainFrame] dataSource] request] URL] absoluteString]
    //    // Observe URL changes
    //    [self.webView
    //     addObserver:self forKeyPath:@"mainFrameURL"
    //     options:(NSKeyValueObservingOptionNew) context:NULL];
    
    _updateUITimer = [NSTimer timerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
    
    
    //---------------
    // Tricks to make Google Map believe that the browser is supported
    //---------------
    WebPreferences *preferences = [self.webView preferences];
    if([preferences respondsToSelector:@selector(setWebGLEnabled:)]){
        [preferences performSelector:@selector(setWebGLEnabled:)
                          withObject:[NSNumber numberWithBool:YES]];
    }
    
    [self.webView setCustomUserAgent:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"];
}


//-------------------
// Timer function to check if the URL has changed
//-------------------
-(void)vcTimerFired{
    self.URL = [[[[[self.webView mainFrame] dataSource] request] URL] absoluteString];
    if ([self.URL length]){
        if (![preURL isEqualToString:self.URL]){
            preURL = self.URL;
            NSLog(@"New URL: %@", preURL);
            self.textField.stringValue = self.URL;
            
            // Need to update compass model here
            [self updateCompassModel];
        }
    }
}

//http://stackoverflow.com/questions/4003232/how-to-code-a-modulo-operator-in-c-c-obj-c-that-handles-negative-numbers
float mod (float a, float b)
{
    float ret = fmod(a, b);
    if(ret < 0)
        ret+=b;
    return ret;
}

- (void) updateCompassModel
{
    NSURL* url = [NSURL URLWithString:self.URL];
    NSString* lonlat_str;
    bool url_contains_latlon = false;
    
    
    NSString* pattern;
    // Extract the string that contains latitude and longitude
    for (NSString *component in url.pathComponents){
        //        NSLog(@"%@", component);
        if ([component rangeOfString:@"@"].location != NSNotFound){
            lonlat_str = component;
            url_contains_latlon = true;
            
            
            if (([component rangeOfString:@"a"].location != NSNotFound) &&
                ([component rangeOfString:@"t"].location != NSNotFound))
            {
                pattern = @"@(.*),(.*),3a.*y,(.*)h,(.*)t?";
            }else{
                pattern = @"@(.*),(.*),";
            }
            
            NSLog(@"Lonlat found : %@", component);
            break;
        }
    }
    
    if (!url_contains_latlon)
        return;
    
    // Regular expression
    NSRange   searchedRange = NSMakeRange(0, [lonlat_str length]);
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:lonlat_str options:0 range: searchedRange];
    
    if ([matches count] == 0){
        NSLog(@"***URL regexp returns no match.");
        return;
    }
    
    for (NSTextCheckingResult* match in matches) {
        NSString* matchText = [lonlat_str substringWithRange:[match range]];
        //        NSLog(@"match: %@", matchText);
        
        float t_value = 0,
        lat_float =0, lon_float = 0, head_deg = 0, tilt_deg = 0;
        
        // [todo] Update compass model here
        for (int i = 1; i < [match numberOfRanges]; ++i){
            NSRange group = [match rangeAtIndex:i];
            
            if ((group.location < [lonlat_str length]) &&
                (group.length != 0)){
                
                NSLog(@"group%d: %f", i,
                      [[lonlat_str substringWithRange:group] floatValue]);
                t_value = [[lonlat_str substringWithRange:group] floatValue];
                // The updating code is in desktop view controller
                // How can I have two different data sources?
                // One from mapView and another from URL?
                // think about it
                
                switch (i) {
                    case 1:
                        lat_float = t_value;
                        break;
                    case 2:
                        lon_float = t_value;
                        break;
                    case 3:
                        head_deg = mod(t_value, 360);
                        cout << "head_deg: " << head_deg << endl;
                        break;
                    case 4:
                        tilt_deg = t_value;
                        break;
                    default:
                        break;
                }
            }
        }
        
        
        // The heading and tilt are extremely confusing.
        // I need to fix that
        [self.desktopViewController
         feedModelLatitude: lat_float
         longitude: lon_float
         heading: -head_deg
         tilt: -tilt_deg];
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    //   if ([keyPath isEqual:@"mainFrameURL"]) {
//    self.URL = [[[[[self.webView mainFrame] dataSource] request] URL] absoluteString];
//    self.textField.stringValue = self.URL;
//    //    }
//}

#pragma mark   -----URL bar
- (IBAction)updateURL:(id)sender {
    self.URL = [self.textField stringValue];
    [[self.webView mainFrame]
     loadRequest:[NSURLRequest requestWithURL:
                  [NSURL URLWithString:self.URL]]];
}

#pragma mark   -----Menu bar item
- (IBAction)fetchURL:(id)sender {
    self.URL = [[[[[self.webView mainFrame] dataSource] request] URL] absoluteString];
    
    self.textField.stringValue = self.URL;
}

- (IBAction)goBack:(id)sender {
    [self.webView goBack:sender];
}

- (IBAction)goForward:(id)sender {
    [self.webView goForward:sender];
}

#pragma mark   -----WebView related stuff
- (NSURLRequest *) webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource{
    
    NSLog(@"New URL: %@", [[request URL] absoluteString]);
    //    self.URL = [[request URL] absoluteString];
    //    self.textField.stringValue = self.URL;
    return request;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    self.URL = [[[[[self.webView mainFrame] dataSource] request] URL] absoluteString];
    self.textField.stringValue = self.URL;
}
@end
