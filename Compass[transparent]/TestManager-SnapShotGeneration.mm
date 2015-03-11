//
//  TestManager-SnapShotGeneration.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/2/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include <stdio.h>
#import "TestManager.h"
#import "CHCSVParser.h"
#import "xmlParser.h"

// rootViewController header files
#ifdef __IPHONE__
#import "iOSViewController.h"
#else
#import "DesktopViewController.h"
#endif

@interface Delegate : NSObject <CHCSVParserDelegate>

@property (readonly) NSArray *lines;

@end

@implementation Delegate {
    NSMutableArray *_lines;
    NSMutableArray *_currentLine;
}
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    NSLog(@"%@", field);
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    //	NSLog(@"parser ended: %@", csvFile);
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    _lines = nil;
}
@end


#pragma mark ------------------practice snapshot generation------------------

////-------------------
//// Generate custom snapshot from custom test vector
////-------------------
//void TestManager::generateCustomSnapshotFromVectorName(NSString* custom_vector_filename){
//    //TODO: this piece is ugly and needs clean up
//    
//    
//    // Reset all_snapshot_vectors first
//    all_snapshot_vectors.clear();
//
//    NSString *folder_path = [model->desktopDropboxDataRoot
//                             stringByAppendingString:test_foldername];
//    
//    // Load data
//    NSString *cachedDBRoot = rootViewController.model->desktopDropboxDataRoot;
//    rootViewController.model->desktopDropboxDataRoot = folder_path;
//    readLocationKml(rootViewController.model, test_kml_filename);
//    t_data_array = rootViewController.model->data_array;
//    
//    // Change the dropbox root back
//    rootViewController.model->desktopDropboxDataRoot = cachedDBRoot;
//    
//    
//    // Populate the location_code_to_id structure
//    location_code_to_id.clear();
//    for (int i = 0; i < t_data_array.size(); ++i){
//        location_code_to_id[t_data_array[i].name] = i;
//    }
//    
//    NSString *doc_path = [folder_path
//                          stringByAppendingPathComponent:custom_vector_filename];
//    NSStringEncoding encoding = 0;
//    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:doc_path];
//    CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:','];
//    [p setRecognizesBackslashesAsEscapes:YES];
//    [p setSanitizesFields:YES];
//    [p setRecognizesComments:YES];
//    
//    Delegate * d = [[Delegate alloc] init];
//    [p setDelegate:d];
//    [p parse];
//    vector<string> test_vector;
//    
//    // fill the test_vector
//    for (NSString* item in [d lines][0]){
//        test_vector.push_back(string([item UTF8String]));
//    }
//    
//    vector<snapshot> t_snapshot_array =
//    generateSnapShotsFromTestvector(test_vector);
//
//
//    // Make sure the output folder exists
//    setupOutputFolder();
//    
//    //-------------------
//    // Process one participant per iteration
//    //-------------------
//    NSString *snapshot_filename =
//    [NSString stringWithFormat:@"%@.snapshot", custom_vector_filename];
//    
//    NSString *content = genSnapshotString(t_snapshot_array);
//    
//
//    
//    NSError* error;
//    doc_path = [folder_path
//                          stringByAppendingPathComponent:snapshot_filename];
//    
//    if (![content writeToFile:doc_path
//                   atomically:YES encoding: NSASCIIStringEncoding
//                        error:&error])
//    {
//        throw(runtime_error("Failed to write snapshot kml file"));
//    }
//}

void TestManager::configureSnapshots(vector<snapshot> &snapshot_vector){
    
    for (int i = 0; i < snapshot_vector.size(); ++i){
        NSString *code = snapshot_vector[i].name;
        
        // Configure visualization
        if ([code rangeOfString:toNSString(VIZPCOMPASS)].location != NSNotFound){
            snapshot_vector[i].visualizationType = VIZPCOMPASS;
        }else if ([code rangeOfString:toNSString(VIZWEDGE)].location != NSNotFound) {
            snapshot_vector[i].visualizationType = VIZWEDGE;
        }

        // Configure device
        if ([code rangeOfString:@"phone"].location != NSNotFound){
            snapshot_vector[i].deviceType = PHONE;
        }else if ([code rangeOfString:@"watch"].location != NSNotFound) {
            snapshot_vector[i].deviceType = WATCH;
        }
        
        snapshot_vector[i].kmlFilename = test_kml_filename;
    }
}


//-------------------
// Save each snapshot to a snapshot_*.kml
//-------------------
void TestManager::saveSnapShotsToKML(){
    // Make sure the output folder exists
    setupOutputFolder();
    
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    NSError* error;
    
    // Snapshot generation date
    NSDate *startDate = [NSDate date];
    NSDateFormatter *formatter =
    [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //Optionally for time zone conversions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"NYC"]];
    
    for (int ui = 0; ui < all_snapshot_vectors.size(); ++ui){
        //-------------------
        // Process one participant per iteration
        //-------------------
        NSString *snapshot_filename =
        [NSString stringWithFormat:@"%@%d.snapshot", test_snapshot_prefix, ui];
        
        // Store the generated time into the note of the first snapshot
        

        all_snapshot_vectors[ui][0].notes = [formatter stringFromDate:startDate];
        all_snapshot_vectors[ui][0].date_str = [formatter stringFromDate:startDate];
        
        NSString *content = genSnapshotString(all_snapshot_vectors[ui]);
        NSString *doc_path = [folder_path
                              stringByAppendingPathComponent:snapshot_filename];
        
        if (![content writeToFile:doc_path
                       atomically:YES encoding: NSUTF8StringEncoding
                            error:&error])
        {
            throw(runtime_error("Failed to write snapshot kml file"));
        }
    }
    
    //-------------------
    // Save the practice snapshot
    //-------------------
    configureSnapshots(practice_snapshot_vector);
    NSString *content = genSnapshotString(practice_snapshot_vector);
    NSString *doc_path = [folder_path
                          stringByAppendingPathComponent:
                          @"practice.snapshot"];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSUTF8StringEncoding
                        error:&error])
    {
        throw(runtime_error("Failed to write snapshot kml file"));
    }
    
    
    //-------------------
    // Save the dummy snapshot
    //-------------------
    doc_path = [folder_path
                          stringByAppendingPathComponent:
    [NSString stringWithFormat:@"%@.snapshot", [formatter stringFromDate:startDate]]];

    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSUTF8StringEncoding
                        error:&error])
    {
        throw(runtime_error("Failed to write dummy kml file"));
    }
}

#pragma mark -------------- Distance Calculation Tools --------------
//-------------------
// Calculate the display region for the tests involving multiple locations
//-------------------
void TestManager::calculateMultipleLocationsDisplayRegion(){
    
    for (int i = 0; i < model->snapshot_array.size(); ++i){
        snapshot mySnapshot = model->snapshot_array[i];
        
        if ([mySnapshot.name rangeOfString:toNSString(TRIANGULATE)].location != NSNotFound){
            // A localize test was found
            
            // Find out pair distance in terms of map point
            
            MKCoordinateRegion coord_region;
            // We assume there are at most three locations (at the moment)
            if (mySnapshot.selected_ids.size() == 2){
                coord_region = calculateCoordRegionFromTwoPoints
                (model->data_array, mySnapshot.selected_ids[0], mySnapshot.selected_ids[1]);
            }else if (mySnapshot.selected_ids.size() == 3){
                vector<int> answer = findTwoFurthestLocationIDs
                (model->data_array, mySnapshot.selected_ids);
                coord_region = calculateCoordRegionFromTwoPoints
                (model->data_array, answer[0], answer[1]);
            }else{
                
                cout << "# of locations: " << mySnapshot.selected_ids.size() << endl;
                return;
            }
            model->snapshot_array[i].osx_coordinateRegion = coord_region;
        }
    }
    
    // Save the snapshot
    [rootViewController saveKMLwithType:SNAPSHOT];
}

MKCoordinateRegion TestManager::calculateCoordRegionFromTwoPoints
(vector<data> &data_array, int dataID1, int dataID2){
    data data_a = data_array[dataID1];
    CLLocation *point_a = [[CLLocation alloc]
                           initWithLatitude:data_a.latitude longitude:data_a.longitude];
    
    data data_b = data_array[dataID2];
    CLLocation *point_b = [[CLLocation alloc]
                           initWithLatitude:data_b.latitude longitude:data_b.longitude];
    
    CLLocationDistance distnace = [point_a distanceFromLocation: point_b];
    
    CLLocationCoordinate2D centerCoordinate =
    CLLocationCoordinate2DMake((data_a.latitude + data_b.latitude)/2,
                               (data_a.longitude + data_b.longitude)/2);
    
    
    MKCoordinateRegion coord_region =
    MKCoordinateRegionMakeWithDistance
    (centerCoordinate, distnace * 1.3, distnace * 1.3);
    return coord_region;
}

vector<int> TestManager::findTwoFurthestLocationIDs
(vector<data> &data_array, vector<int> location_ids)
{
    vector<int> answer;
    double max_dist = 0;
    vector<int> t_id_list = location_ids;
    t_id_list.push_back(location_ids[0]);
    
    for (int i = 0; i < t_id_list.size(); ++i){
        
        data data_a = data_array[t_id_list[i]];
        CLLocation *point_a = [[CLLocation alloc]
                               initWithLatitude:data_a.latitude longitude:data_a.longitude];
        
        data data_b = data_array[t_id_list[i+1]];
        CLLocation *point_b = [[CLLocation alloc]
                               initWithLatitude:data_b.latitude longitude:data_b.longitude];
        
        CLLocationDistance distnace = [point_a distanceFromLocation: point_b];
        if (distnace > max_dist){
            answer.clear();
            answer.push_back(t_id_list[i]);
            answer.push_back(t_id_list[i+1]);
        }
    }

    return answer;
}











