//
//  iOSViewController+Search.m
//  Compass[transparent]
//
//  Created by dmiau on 6/13/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "iOSViewController+Search.h"


//------------------
// AddInPlaceButton
//------------------
@interface AddInPlaceButton : UIButton
@property int mapItemId;
@end

@implementation AddInPlaceButton

@end


@implementation iOSViewController (Search)
#pragma mark ------Search Related Stuff-----

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    // startWithCompletionHander is a method of localSearch
    // startWithCompletionHander performs the search and puts the output to
    // results, whichi is a (private) property?!
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        // By the time this funciton is called, response has been filled up.
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

// Data presentation
// Three different types of table views


// This is called when the focus is put in the search boxis
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

// This is called when the results are ready to be displayed
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        
        NSLog(@"Cell creation.");
        //-------------
        // Add a button to the cell
        //-------------
        AddInPlaceButton *myButton = [[AddInPlaceButton alloc] initWithFrame:
                              CGRectMake(cell.frame.size.width - 100, 0,
                                         100, cell.frame.size.height)];
        myButton.backgroundColor = [UIColor grayColor];
        [myButton setTitle:@"AddInPlace" forState: UIControlStateNormal];
        [myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        myButton.mapItemId = indexPath.row;

        [myButton addTarget:self
                   action:@selector(addLocationInPlace:)
           forControlEvents:UIControlEventTouchDown];
        
        [cell addSubview:myButton];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

// This is called when a table result is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
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

- (void)addLocationInPlace:(AddInPlaceButton*) sender{
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[sender.mapItemId];
    
    //-------------
    // Construct the annotation
    //-------------
    
    //http://stackoverflow.com/questions/17682834/mapview-with-local-search
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = item.placemark.coordinate;
    annotation.title      = item.name;
    annotation.subtitle   = item.placemark.title;
    annotation.point_type = search_result;
    
    [self.mapView addAnnotation:annotation];
    
    //-------------
    // Add the location to the model
    //-------------
    // Right buttton tapped - add the pin to data_array
    data myData;
    myData.name = [annotation.title UTF8String];
    myData.annotation = annotation;
    myData.annotation.point_type = landmark;
    
    myData.annotation.subtitle =
    [NSString stringWithFormat:@"%lu",
     self.model->data_array.size()];
    
    myData.latitude =  annotation.coordinate.latitude;
    myData.longitude =  annotation.coordinate.longitude;
    
    myData.annotation.data_id = self.model->data_array.size();
    myData.my_texture_info = self.model->generateTextureInfo
    ([NSString stringWithUTF8String:myData.name.c_str()]);
    // Add the new data to data_array
    self.model->data_array.push_back(myData);
    
    //-------------
    // Add the location to the model
    //-------------
    
    for (int i = 0; i < self.model->data_array.size(); ++i){
        self.model->data_array[i].isEnabled = false;
    }

    self.model->indices_for_rendering.
    push_back(self.model->data_array.size()-1);
    for (int i = 0; i < self.model->indices_for_rendering.size(); ++i){
        self.model->data_array[self.model->indices_for_rendering[i]]
        .isEnabled = true;
    }
    
    self.model->configurations[@"filter_type"] = @"MANUAL";
    self.model->updateMdl();
    [self.glkView setNeedsDisplay];
}
@end
