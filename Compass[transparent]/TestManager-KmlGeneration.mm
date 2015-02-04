//
//  TestManager-KmlGeneration.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/1/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//
#include <stdio.h>
#import "TestManager.h"

#ifdef __IPHONE__
#import "iOSViewController.h"
#else
#import "DesktopViewController.h"
#endif


//--------------------
// saveTestLocationsToKML save location_dict into a .kml file
//--------------------
void TestManager::saveTestLocationsToKML(){
    
//    data(){
//        name = "";
//        latitude = 0;
//        longitude = 0;
//        distance = 0;
//        orientation = 0;
//        isEnabled = YES;
//        isVisible = NO;
//        annotation = [[CustomPointAnnotation alloc] init];
//    };
    
    data t_data;
    vector<data> t_data_array;
    
    
    // Generate a data_array
    int i = 0;
    for (auto &item : location_dict){
     
        vector<int> ios_xy = item.second;
        
        CLLocationCoordinate2D coord;
        
#ifndef __IPHONE__
        coord =
        [rootViewController calculateLatLonFromiOSX: ios_xy[0] Y: ios_xy[1]];
#endif
        
        t_data.longitude = coord.longitude;
        t_data.latitude = coord.latitude;
        t_data.name = item.first;
        t_data_array.push_back(t_data);
        
        // Populate location_code_to_id, for code to id look up
        location_code_to_id[item.first] = i++;
    }    
    
    NSString *content = genKMLString(t_data_array);

    //--------------------
    // Make sure the output folder exists
    setupOutputFolder();
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    
    NSError* error;
    NSString *doc_path = [folder_path
                          stringByAppendingPathComponent:test_kml_filename];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSASCIIStringEncoding
                        error:&error])
    {
        throw(runtime_error("Failed to write test kml file"));
    }
}