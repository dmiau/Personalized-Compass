//
//  DesktopViewController+Search.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Search.h"

@implementation DesktopViewController (Search)

- (void)controlTextDidEndEditing:(NSNotification *)aNotification{
	NSTextView* textView = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];

    NSString *searchString = textView.string;
    

    
    NSEvent *event =  [NSEvent otherEventWithType: NSApplicationDefined
                                         location:
                                CGPointMake(self.view.window.frame.size.width -200,
                                            self.view.window.frame.size.height -55)
                                    modifierFlags: 0
                                        timestamp: 0
                                     windowNumber: [self.view.window windowNumber]
                                          context: [self.view.window graphicsContext]
                                          subtype: NSApplicationDefined
                                            data1: 0
                                            data2: 0];
    //----------------
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = textView.string;
    request.region = self.mapView.region;
    
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    // startWithCompletionHander is a method of localSearch
    // startWithCompletionHander performs the search and puts the output to
    // results, whichi is a (private) property?!
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        if (error != nil) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Alert"];
            [alert setInformativeText:@"Map Error"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Alert"];
            [alert setInformativeText:@"No Result"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
            return;
        }
        results = response;
        
        unsigned int	count;
        count         = min((int)results.mapItems.count, 10);
        NSMenu *menu = [[NSMenu alloc] initWithTitle: @"results"];

        // find any match in our keyword array against what was typed -
        for (int i=0; i< count; i++)
        {
            MKMapItem *item = results.mapItems[i];
            
            NSMenuItem *myMenuItem = [[NSMenuItem alloc]
                                      initWithTitle:item.name
                                      action:@selector(selectedMenuItem:)
                                      keyEquivalent:@""];
            myMenuItem.target = self;
            myMenuItem.representedObject = item;
            [menu addItem:myMenuItem];
        }
        
        [NSMenu popUpContextMenu: menu withEvent: event forView: textView];
    }];
}


- (void)selectedMenuItem: (NSMenuItem*)sender{
    
    MKMapItem *item = sender.representedObject;
    
    //http://stackoverflow.com/questions/17682834/mapview-with-local-search
    
    
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = item.placemark.coordinate;
    annotation.title      = item.name;
    annotation.subtitle   = item.placemark.title;
    annotation.point_type = search_result;
    
    [self.mapView addAnnotation:annotation];
    
    // This line throws an error:
    // ERROR: Trying to select an annotation which has not been added
    //    [self.ibMapView selectAnnotation:item.placemark animated:YES];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    
    //    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
}
@end
