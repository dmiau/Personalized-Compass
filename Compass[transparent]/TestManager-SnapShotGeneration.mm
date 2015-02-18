//
//  TestManager-SnapShotGeneration.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/2/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include <stdio.h>
#import "TestManager.h"

// rootViewController header files
#ifdef __IPHONE__
#import "iOSViewController.h"
#else
#import "DesktopViewController.h"
#endif

//-------------------
// Generate snapshot arrays
//-------------------
void TestManager::generateSnapShots(){
    
    // Reset all_snapshot_vectors first
    all_snapshot_vectors.clear();
    
    for (int ui = 0; ui < all_test_vectors.size(); ++ui){
        // Start with the first user
        vector<string> test_vector = all_test_vectors[ui];
        
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
            
            // Forward declaration
            compassRender *p_render = rootViewController.renderer;

#ifndef __IPHONE__
            coordinateRegion.span.latitudeDelta =
            rootViewController.mapView.region.span.latitudeDelta *
            p_render->emulatediOS.height / p_render->view_height;
            
            coordinateRegion.span.longitudeDelta =
            rootViewController.mapView.region.span.latitudeDelta *
            p_render->emulatediOS.width / p_render->view_width;
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
                // code for t2
                int t_id = location_code_to_id[test_code];
                for (int t2i = 0; t2i < 3; ++t2i){
                    selected_ids.push_back
                    (location_code_to_id[test_code + "-" + to_string(t2i)]);
                }
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
        all_snapshot_vectors.push_back(t_snapshot_array);
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
                (mySnapshot.selected_ids[0], mySnapshot.selected_ids[1]);
            }else if (mySnapshot.selected_ids.size() == 3){
                vector<int> answer = findTwoFurthestLocationIDs(mySnapshot.selected_ids);
                coord_region = calculateCoordRegionFromTwoPoints
                (answer[0], answer[1]);
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
(int dataID1, int dataID2){
    data data_a = model->data_array[dataID1];
    CLLocation *point_a = [[CLLocation alloc]
                           initWithLatitude:data_a.latitude longitude:data_a.longitude];
    
    data data_b = model->data_array[dataID2];
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

vector<int> TestManager::findTwoFurthestLocationIDs(vector<int> location_ids){
    vector<int> answer;
    double max_dist = 0;
    vector<int> t_id_list = location_ids;
    t_id_list.push_back(location_ids[0]);
    
    for (int i = 0; i < t_id_list.size(); ++i){
        
        data data_a = model->data_array[t_id_list[i]];
        CLLocation *point_a = [[CLLocation alloc]
                               initWithLatitude:data_a.latitude longitude:data_a.longitude];
        
        data data_b = model->data_array[t_id_list[i+1]];
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











