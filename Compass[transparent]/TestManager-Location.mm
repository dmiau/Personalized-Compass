//
//  TestManager-Location.cpp
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//
#import "TestManager.h"
#import "CHCSVParser.h"
#include <random>

#ifdef __IPHONE__
#import "iOSViewController.h"
#else
#import "DesktopViewController.h"
#endif


map<string, vector<int>> TestManager::generateLocationVector(){
    map<string, vector<int>> out_location_dict;
    
    location_dict.clear();
    
    vector<TaskType> task_list = {LOCATE, TRIANGULATE, ORIENT, LOCATEPLUS};
    vector<DeviceType> device_list = {PHONE, WATCH};
    
    map<string, vector<int>> temp_locations;
    for (int i = 0; i < device_list.size(); ++i){
        for (int j = 0; j < task_list.size(); ++j){
            temp_locations.clear();
            
            //-----------------
            // For each task, we will generate a location dictionary
            //-----------------
            temp_locations = generateLocationsByTask(device_list[i], task_list[j]);
            // Store into location_dict
            location_dict.insert(temp_locations.begin(), temp_locations.end());
        }
    }
    // Save the location to a CSV
    saveLocationCSV();
    
    saveTestLocationsToKML();
    
    return out_location_dict;
}


//--------------
// Methods to generate tests
//--------------
map<string, vector<int>> TestManager::generateLocationsByTask
(DeviceType deviceType, TaskType taskType){
    // locations in close_vector should be witin the display area,
    // so we can perform the old wedge test on the display
    
    map<string, vector<int>> out_location_dict;
    
    // Need to generate the following cases
    //        pcompass | wedge
    // close | desktop | desktop
    // far   | phone   | phone
    
    string device_prefix = "phone";
    vector<vector<pair<float, float>>> boundary_spec = phone_boundaries;
    if (deviceType == WATCH){
        device_prefix = "watch";
        boundary_spec = watch_boundaries;
    }

    
    //-----------------------
    TaskSpec tempTaskSpec(taskType);
    int t_close_n = tempTaskSpec.trial_n_list[0];
    int t_far_n = tempTaskSpec.trial_n_list[1];
    
    // Define the boundaries for the locate tasks
    vector<vector<double>> boundary_spec_list =
    {{boundary_spec[1][0].first, boundary_spec[1][0].second, (double)t_close_n},
        {boundary_spec[1][1].first, boundary_spec[1][1].second, (double)t_far_n}};


    string task_prefix = tempTaskSpec.taskCode;
    switch (taskType) {
        case LOCATE:
            boundary_spec_list =
        {{boundary_spec[0][0].first, boundary_spec[0][0].second, (double)t_close_n},
            {boundary_spec[1][1].first, boundary_spec[1][1].second, (double)t_far_n}};
            break;
        case TRIANGULATE:
            break;
        case ORIENT:
            break;
        default:
            break;
    }
    
    // pcompass:t1:, wedge:t1:
    vector<string> prefix_list = {device_prefix + ":pcompass:" + task_prefix + ":",
        device_prefix + ":wedge:" + task_prefix + ":"};
    //-----------------------
    
    
    for (int i =0; i < prefix_list.size(); ++i){
        int location_counter = 0;
        
        // We may want to have tests in the close range, and tests in the far range,
        // thus there is this boundary_spec_list.
        //
        // However, we want location_counter runs continuously,
        // thus location_counter is set to 0 at the beginning of the loop
        for (int bi = 0; bi < boundary_spec_list.size(); ++bi){

            double t_begin = boundary_spec_list[bi][0];
            double t_end = boundary_spec_list[bi][1];
            double t_n = boundary_spec_list[bi][2]; // how many tests per distanct range

            string location_class_subfix = "a";
            if (bi == 1)
                location_class_subfix = "b";
            
            //------------------
            vector<vector<int>> t_location_vector;
            switch (taskType) {
                case LOCATE:
                    t_location_vector =  generateRandomLocateLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                case TRIANGULATE:
                    t_location_vector =  generateRandomTriangulateLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                case ORIENT:
                    t_location_vector =  generateRandomOrientLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                case LOCATEPLUS:
                    t_location_vector =  generateRandomTriangulateLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                default:
                    break;
            }

            int li = 0;
            while (li < t_location_vector.size()){
                
                // Each TRIANGULATE task requires three landmarks
                if (taskType == TRIANGULATE ||
                    taskType == LOCATEPLUS){
                    //--------------------
                    // Localize tests use multiple supports
                    //--------------------
                    for (int ti = 0; ti < localize_test_support_n; ++ti){
                        string code = prefix_list[i] + to_string(location_counter) +
                        location_class_subfix +  "-" + to_string(ti);
                        
                        out_location_dict[code] = t_location_vector[li];
                        li = li +1;
                    }
                    location_counter = location_counter + 1;
                }else{
                    //--------------------
                    // Other tests use a single support
                    //--------------------
                    string code = prefix_list[i] + to_string(location_counter++) +
                    location_class_subfix;
                    
                    out_location_dict[code] = t_location_vector[li];
                    li = li +1;
                }
            }
            //------------------
        }
    }
    
    return out_location_dict;
}


//--------------
// Generate  close_bounary<  n random locations < far_boundary
// The n random locations fall into n equally distant segments
// btween close_boundary and far_boundary
//--------------
vector<vector<int>> TestManager::generateRandomLocateLocations
(double close_boundary, double far_boundary, int location_n){
    
    vector<vector<int>> output;
    
    double step = (far_boundary - close_boundary) / location_n;
    
    using namespace std;
    // Initialize random number generator
    
    // Need to provide a seed
    std::uniform_int_distribution<int>  distr(0, step);
    
    vector<double> close_vector; close_vector.clear();
    for (int i = 0; i < location_n; ++i){
        int temp = close_boundary + step * i + distr(generator);
        
        // Need to transform to xy coordinate
        vector<int> t_vector; // The first is x, and the second is y
        t_vector.push_back(temp); t_vector.push_back(0);
        output.push_back(t_vector);
    }
    
    return output;
}

//----------------
// Save the locations to CSV
//----------------
void TestManager::saveLocationCSV(){

    // Make sure the output folder exists
    setupOutputFolder();
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    NSString *out_file = [folder_path
                          stringByAppendingPathComponent:test_location_filename];
    CHCSVWriter *w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    
    // http://stackoverflow.com/questions/1443793/iterate-keys-in-a-c-map

    // map<string, vector<int>> location_dict;
    for (const auto &item : location_dict){
        string code = item.first;
        vector<int> xy = item.second;
    [w writeLineOfFields:@[[NSString stringWithUTF8String:code.c_str()],
                           [NSNumber numberWithInteger:xy[0]],
                           [NSNumber numberWithInteger:xy[1]]]];
    }
//    [w writeLineOfFields:d.lines[0]];
//    [w writeLineOfFields:d.lines[1]];
//    [w writeLineOfFields:@[@1, @2, @3, @"91, 5"]];
}

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
    t_data_array.clear();
    
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