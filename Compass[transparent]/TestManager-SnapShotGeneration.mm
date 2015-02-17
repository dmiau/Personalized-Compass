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
