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

//-------------------
// Generate snapshot arrays
//-------------------
void TestManager::generateSnapShots(){
    
    // Reset all_snapshot_vectors first
    all_snapshot_vectors.clear();
        for (int ui = 0; ui < all_test_vectors.size(); ++ui){
            vector<string> test_vector = all_test_vectors[ui];
            vector<snapshot> t_snapshot_array =
            generateSnapShotsFromTestvector(test_vector);
            all_snapshot_vectors.push_back(t_snapshot_array);
        }
}

vector<snapshot> TestManager::generateSnapShotsFromTestvector(vector<string> test_vector)
{
        vector<snapshot> t_snapshot_array;
        
        //-------------
        // Go through test case by test case
        //-------------
        for (int ti = 0; ti < test_vector.size(); ++ti){
            
            string test_code = test_vector[ti]; //e.g., watch:wedge:t2:5f
            
            //------------------
            // Calculate coordinate region
            //------------------
            MKCoordinateRegion coordinateRegion;
            coordinateRegion.center = rootViewController.mapView.centerCoordinate;
            
#ifndef __IPHONE__
            if (test_code.find("phone:") != string::npos) {
                //----------------
                // Phone
                //----------------
                coordinateRegion.span =
                [rootViewController calculateCoordinateSpanForDevice:PHONE];
            }else{
                //----------------
                // Watch
                //----------------
                coordinateRegion.span =
                [rootViewController calculateCoordinateSpanForDevice:SQUAREWATCH];
            }
#else
            coordinateRegion.span =
            rootViewController.mapView.region.span;
#endif
            
            //------------------
            // Collect all the selected ids
            //------------------
            vector<int> selected_ids;
            vector<int> is_answer_list;
            // Need to handle the code of t2 slightly different
            if (test_code.find(":t2:") != string::npos) {
                //------------------
                // Localization test requires multiple supports
                //------------------
                for (int t2i = 0; t2i < localize_test_support_n; ++t2i){
                    selected_ids.push_back
                    (location_code_to_id[test_code + "-" + to_string(t2i)]);
                    is_answer_list.push_back(0);
                }
            }else if (test_code.find(":t4:") != string::npos){
                //------------------
                // Locateplus test requires multiple supports
                //------------------
                for (int t4i = 0; t4i < localize_test_support_n; ++t4i){
                    selected_ids.push_back
                    (location_code_to_id[test_code + "-" + to_string(t4i)]);
                    is_answer_list.push_back(0);
                }
                is_answer_list[0] =1;
            }else{
                // code for other tasks
                selected_ids.push_back(location_code_to_id[test_code]);
                is_answer_list.push_back(1);
            }
            
            //------------------
            // Assemble a snapshot
            //------------------
            snapshot t_snapshot;
            
            //------------------
            // Calculate the OSX coordinate region
            // if the test is a localize (triangulation) task
            //------------------
            if (test_code.find(":t2:") != string::npos) {
                MKCoordinateRegion osx_coordinateRegion;
                // Find out pair distance in terms of map point
                
                // We assume there are at most three locations (at the moment)
                if (selected_ids.size() == 2){
                    osx_coordinateRegion = calculateCoordRegionFromTwoPoints
                    (t_data_array, selected_ids[0], selected_ids[1]);
                }else if (selected_ids.size() == 3){
                    vector<int> answer = findTwoFurthestLocationIDs
                    (t_data_array, selected_ids);
                    osx_coordinateRegion = calculateCoordRegionFromTwoPoints
                    (t_data_array, answer[0], answer[1]);
                }else{
                    throw(runtime_error("More than 3 locations are selected for a localize test."));
                    return t_snapshot_array;
                }
                
                t_snapshot.osx_coordinateRegion = osx_coordinateRegion;
            }else if (test_code.find(":t4:") != string::npos) {
                
                CLLocation *center = [[CLLocation alloc]
                                       initWithLatitude: rootViewController.mapView.centerCoordinate.latitude
                                       longitude: rootViewController.mapView.centerCoordinate.longitude];
                CLLocation *support = [[CLLocation alloc]
                                      initWithLatitude:
                                       t_data_array[selected_ids[1]].latitude
                                      longitude:
                                       t_data_array[selected_ids[1]].longitude];
                
                CLLocationDistance distnace = [center distanceFromLocation: support];
                
                CLLocationCoordinate2D centerCoordinate =
                rootViewController.mapView.centerCoordinate;
                
                MKCoordinateRegion coord_region =
                MKCoordinateRegionMakeWithDistance
                (centerCoordinate, distnace * 2.2, distnace * 2.2);
                t_snapshot.osx_coordinateRegion = coord_region;
            }
            
            //------------------
            // Configure visualization type and the device spec
            //------------------
            // Visualization type
            if (test_code.find(":pcompass:") != string::npos) {
                t_snapshot.visualizationType = VIZPCOMPASS;
            }else if (test_code.find(":wedge:") != string::npos) {
                t_snapshot.visualizationType = VIZWEDGE;
            }else{
                t_snapshot.visualizationType = VIZNONE;
            }
            
            // Device type
            if (test_code.find("watch:") != string::npos) {
                t_snapshot.deviceType = WATCH;
            }else{
                t_snapshot.deviceType = PHONE;
            }
            
            t_snapshot.name = [NSString stringWithUTF8String: test_code.c_str()];
            t_snapshot.coordinateRegion = coordinateRegion;
            t_snapshot.selected_ids = selected_ids;
            t_snapshot.is_answer_list = is_answer_list;
            t_snapshot.kmlFilename = test_kml_filename;
            t_snapshot.orientation = 0;
            t_snapshot_array.push_back(t_snapshot);
        }
    return t_snapshot_array;
}

//-------------------
// Generate custom snapshot from custom test vector
//-------------------
void TestManager::generateCustomSnapshotFromVectorName(NSString* custom_vector_filename){
    //TODO: this piece is ugly and needs clean up
    
    
    // Reset all_snapshot_vectors first
    all_snapshot_vectors.clear();

    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    
    // Load data
    NSString *cachedDBRoot = rootViewController.model->desktopDropboxDataRoot;
    rootViewController.model->desktopDropboxDataRoot = folder_path;
    readLocationKml(rootViewController.model, test_kml_filename);
    t_data_array = rootViewController.model->data_array;
    
    // Change the dropbox root back
    rootViewController.model->desktopDropboxDataRoot = cachedDBRoot;
    
    
    // Populate the location_code_to_id structure
    location_code_to_id.clear();
    for (int i = 0; i < t_data_array.size(); ++i){
        location_code_to_id[t_data_array[i].name] = i;
    }
    
    NSString *doc_path = [folder_path
                          stringByAppendingPathComponent:custom_vector_filename];
    NSStringEncoding encoding = 0;
    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:doc_path];
    CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:stream usedEncoding:&encoding delimiter:','];
    [p setRecognizesBackslashesAsEscapes:YES];
    [p setSanitizesFields:YES];
    [p setRecognizesComments:YES];
    
    Delegate * d = [[Delegate alloc] init];
    [p setDelegate:d];
    [p parse];
    vector<string> test_vector;
    
    // fill the test_vector
    for (NSString* item in [d lines][0]){
        test_vector.push_back(string([item UTF8String]));
    }
    
    vector<snapshot> t_snapshot_array =
    generateSnapShotsFromTestvector(test_vector);


    // Make sure the output folder exists
    setupOutputFolder();
    
    //-------------------
    // Process one participant per iteration
    //-------------------
    NSString *snapshot_filename =
    [NSString stringWithFormat:@"%@.snapshot", custom_vector_filename];
    
    NSString *content = genSnapshotString(t_snapshot_array);
    

    
    NSError* error;
    doc_path = [folder_path
                          stringByAppendingPathComponent:snapshot_filename];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSASCIIStringEncoding
                        error:&error])
    {
        throw(runtime_error("Failed to write snapshot kml file"));
    }
}

//-------------------
// Save each snapshot to a snapshot_*.kml
//-------------------
void TestManager::saveSnapShotsToKML(){
    // Make sure the output folder exists
    setupOutputFolder();
    
    for (int ui = 0; ui < all_snapshot_vectors.size(); ++ui){
        //-------------------
        // Process one participant per iteration
        //-------------------
        NSString *snapshot_filename =
        [NSString stringWithFormat:@"%@%d.snapshot", test_snapshot_prefix, ui];
        
        NSString *content = genSnapshotString(all_snapshot_vectors[ui]);

        

        NSString *folder_path = [model->desktopDropboxDataRoot
                                 stringByAppendingString:test_foldername];
        
        NSError* error;
        NSString *doc_path = [folder_path
                              stringByAppendingPathComponent:snapshot_filename];
        
        if (![content writeToFile:doc_path
                       atomically:YES encoding: NSASCIIStringEncoding
                            error:&error])
        {
            throw(runtime_error("Failed to write snapshot kml file"));
        }
        
        
    }
}

//-------------------
// Calculate the display region for the tests involving multiple locations
//-------------------
void TestManager::calculateMultipleLocationsDisplayRegion(){
    
    for (int i = 0; i < model->snapshot_array.size(); ++i){
        snapshot mySnapshot = model->snapshot_array[i];
        
        if ([mySnapshot.name rangeOfString:@"t2"].location != NSNotFound){
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











