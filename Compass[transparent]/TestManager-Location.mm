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
    
    map<string, vector<int>> phone_locations =
    generateLocateTests(PHONE);

    // Store into location_dict
    location_dict.insert(phone_locations.begin(), phone_locations.end());
    
    // Save the location to a CSV
    saveLocationCSV();
    
    return out_location_dict;
}


//--------------
// Methods to generate tests
//--------------
map<string, vector<int>> TestManager::generateLocateTests(DeviceType deviceType){
    // locations in close_vector should be witin the display area,
    // so we can perform the old wedge test on the display
    
    map<string, vector<int>> out_location_dict;
    
    // Need to generate the following cases
    //        pcompass | wedge
    // close | desktop | desktop
    // far   | phone   | phone

    string device_prefix;
    float em_width, em_height;
    float ios_width, ios_height;

    double close_begin, close_end;
    
    double far_begin, far_end;

    //         close_n steps    far_n steps
    // -------|------------|---|---------------|
    // close_begin  close_end far_begin     far_end
    
    
    if (deviceType == PHONE){
        device_prefix = "phone";
        // PHONE
        em_width = 332; em_height = 212;
        ios_width = 320; ios_height = 503;
    }else{
        // WATCH
        device_prefix = "watch";
        em_width = 332; em_height = 212;
        ios_width = 320; ios_height = 503;
    }
    // TODO: need to have better close_begin
    close_begin = em_height/2 * close_begin_x;
    close_end = em_height/2 * close_end_x;
    
    far_begin = ios_height/2 * far_begin_x;
    far_end = ios_height/2 * far_end_x;
    
    
    vector<vector<int>> t_location_vector;
    
    // pcompass:close, wedge:close
    vector<string> prefix_list = {device_prefix + ":pcompass:t1:c",
        device_prefix + ":wedge:t1:c"};
    vector<vector<double>> boundary_spec_list =
    {{close_begin, close_end, (double)close_n},
        {far_begin, far_end, (double)far_n}};
    
    
    for (int bi = 0; bi < boundary_spec_list.size(); ++bi){
        for (int i =0; i < prefix_list.size(); ++i){
            
            double t_begin = boundary_spec_list[bi][0];
            double t_end = boundary_spec_list[bi][1];
            double t_n = boundary_spec_list[bi][2];
            
            t_location_vector =  generateRandomLocations
            (t_begin, t_end, (int)t_n);
            
            for (int li = 0; li < t_location_vector.size(); ++li){
                string code = prefix_list[i] + to_string(li);
                
                
//                out_location_dict.insert(
//                                     pair<string, vector<int>>
//                                     (code, t_location_vector[i]));
                out_location_dict[code] = t_location_vector[li];
            }
        }
    }
    
    return out_location_dict;
}


//--------------
// Generate  close_bounary<  n random locations < far_boundary
// The n random locations fall into n equally distant segments
// btween close_boundary and far_boundary
//--------------
vector<vector<int>> TestManager::generateRandomLocations
(double close_boundary, double far_boundary, int location_n){
    
    vector<vector<int>> output;
    
    double step = (far_boundary - close_boundary) / location_n;
    
    using namespace std;
    // Initialize random number generator
    
    // Need to provide a seed
    std::uniform_int_distribution<int>  distr(0, step);
    
    vector<double> close_vector; close_vector.clear();
    for (int i = 0; i < location_n; ++i){
        int temp = step * i + distr(generator);
        
        // Need to transform to xy coordinate
        vector<int> t_vector; // The first is x, and the second is y
        t_vector.push_back(temp); t_vector.push_back(0);
        output.push_back(t_vector);
    }
    
    return output;
}


map<string, vector<int>> TestManager::generateTriangulateTests(DeviceType deviceType){
    map<string, vector<int>> out_location_dict;

    // Need to generate the following cases
    //        pcompass | wedge
    // close | desktop | desktop
    // far   | phone   | phone
    
    string device_prefix;
    float em_width, em_height;
    float ios_width, ios_height;
    
    double close_begin, close_end;
    
    double far_begin, far_end;
    
    //         close_n steps    far_n steps
    // -------|------------|---|---------------|
    // close_begin  close_end far_begin     far_end
    
    
    if (deviceType == PHONE){
        device_prefix = "phone";
        // PHONE
        em_width = 332; em_height = 212;
        ios_width = 320; ios_height = 503;
    }else{
        // WATCH
        device_prefix = "watch";
        em_width = 332; em_height = 212;
        ios_width = 320; ios_height = 503;
    }
    
    
    //
    //
    //
    
    //generate random float
    //http://stackoverflow.com/questions/5289613/generate-random-float-between-two-floats
    
    for (int i = 0; i < tri_test_n; ++i){
        
        
        
    }
    
    return out_location_dict;
}

map<string, vector<int>> TestManager::generateOrientTests(DeviceType deviceType){
    map<string, vector<int>> out_location_dict;

    return out_location_dict;
}

//----------------
// Save the 
//----------------
void TestManager::saveLocationCSV(){
    //--------------
    NSString *out_file = [model->desktopDropboxDataRoot
                          stringByAppendingPathComponent:@"test.locations"];
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

