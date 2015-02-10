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

map<string, vector<int>> TestManager::generateLocationVector(){
    map<string, vector<int>> out_location_dict;
    
    location_dict.clear();
    
    vector<TaskType> task_list = {LOCATE, TRIANGULATE, ORIENT};
    vector<DeviceType> device_list = {PHONE, WATCH};
    
    map<string, vector<int>> temp_locations;
    for (int i = 0; i < device_list.size(); ++i){
        for (int j = 0; j < task_list.size(); ++j){
            temp_locations.clear();
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
    // Define the boundaries for the locate tasks
    vector<vector<double>> boundary_spec_list =
    {{boundary_spec[1][0].first, boundary_spec[1][0].second, (double)close_n},
        {boundary_spec[1][1].first, boundary_spec[1][1].second, (double)far_n}};
    
    string task_prefix;
    switch (taskType) {
        case LOCATE:
            task_prefix = "t1";
            boundary_spec_list =
        {{boundary_spec[0][0].first, boundary_spec[0][0].second, (double)close_n},
            {boundary_spec[1][1].first, boundary_spec[1][1].second, (double)far_n}};
            break;
        case TRIANGULATE:
            task_prefix = "t2";
            break;
        case ORIENT:
            task_prefix = "t3";
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
        for (int bi = 0; bi < boundary_spec_list.size(); ++bi){
            double t_begin = boundary_spec_list[bi][0];
            double t_end = boundary_spec_list[bi][1];
            double t_n = boundary_spec_list[bi][2];

            string location_class_subfix = "c";
            if (bi == 1)
                location_class_subfix = "f";
            
            //------------------
            vector<vector<int>> t_location_vector;
            int step = 1;
            switch (taskType) {
                case LOCATE:
                    t_location_vector =  generateRandomLocateLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                case TRIANGULATE:
                    step = 3;
                    t_location_vector =  generateRandomTriangulateLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                case ORIENT:
                    t_location_vector =  generateRandomOrientLocations
                    (t_begin, t_end, (int)t_n);
                    break;
                default:
                    break;
            }

            
            for (int li = 0; li < t_location_vector.size(); li += step){
                
                // Each TRIANGULATE task requires three landmarks
                if (taskType == TRIANGULATE){
                    for (int ti = 0; ti < 3; ++ti){
                        string code = prefix_list[i] + to_string(location_counter) +
                        location_class_subfix +  "-" + to_string(ti);
                        
                        out_location_dict[code] = t_location_vector[li];
                    }
                    location_counter = location_counter + 1;
                }else{
                    string code = prefix_list[i] + to_string(location_counter++) +
                    location_class_subfix;
                    
                    out_location_dict[code] = t_location_vector[li];
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

//--------------
// place holder...
//--------------
vector<vector<int>> TestManager::generateRandomOrientLocations
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

//--------------
// place holder...
//--------------
vector<vector<int>> TestManager::generateRandomTriangulateLocations
(double close_boundary, double far_boundary, int location_n){
    
    vector<vector<int>> output;
    
    double step = (far_boundary - close_boundary) / location_n;
    
    using namespace std;
    // Initialize random number generator
    
    // Need to provide a seed
    std::uniform_int_distribution<int>  distr(0, step);
    
    vector<double> close_vector; close_vector.clear();
    for (int i = 0; i < 3*location_n; ++i){
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

//---------------
    // Initialize watch_boundaries and phone_boundaries
//---------------
void TestManager::initializeDeviceBoundaries(){
    
    float em_width, em_height;
    float ios_width, ios_height;

    double close_begin, close_end;
    double far_begin, far_end;
    
    //         close_n steps    far_n steps
    // -------|------------|---|---------------|
    // close_begin  close_end far_begin     far_end
    

    // In the study, there are two devices (environments) to be tested: phone and watch
    // However, in the locate task, phone and watch might be tested on a desktop
    // So this can be a bit confusing.
    // Here will call phone and watch as devices
    // desktop and ios as platform

    //------------
    // Phone
    //------------
    em_width = 212; em_height = 332;
    ios_width = 320; ios_height = 503;
    vector<float> two_heights = {em_height, ios_height};
    
    // First populate the desktop, second populate the ios
    for (int i = 0; i < two_heights.size(); ++i){
        float platform_height = two_heights[i];
        close_begin = platform_height/2 * close_begin_x;
        close_end = platform_height/2 * close_end_x;
        
        far_begin = platform_height/2 * far_begin_x;
        far_end = platform_height/2 * far_end_x;
        
        // Need to initialize the vector
        vector<pair<float, float>> temp =
        {pair<float, float>(close_begin, close_end), pair<float, float>(far_begin, far_end)};
        
        phone_boundaries.push_back(temp);
    }
    
    //------------
    // Watch
    //------------
    em_width = 212 * 0.7; em_height = 332 * 0.7;
    ios_width = 320 * 0.7; ios_height = 503 * 0.7;
    two_heights = {em_height, ios_height};
    // First populate the desktop, second populate the ios
    for (int i = 0; i < two_heights.size(); ++i){
        float platform_height = two_heights[i];
        close_begin = platform_height/2 * close_begin_x;
        close_end = platform_height/2 * close_end_x;
        
        far_begin = platform_height/2 * far_begin_x;
        far_end = platform_height/2 * far_end_x;
 
        // Need to initialize the vector
        vector<pair<float, float>> temp =
        {pair<float, float>(close_begin, close_end), pair<float, float>(far_begin, far_end)};
        watch_boundaries.push_back(temp);
    }
}
