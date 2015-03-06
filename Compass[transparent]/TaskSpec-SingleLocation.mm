//
//  TaskSpec-Generation.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/4/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TaskSpec.h"
using namespace std;

//------------------
// Desktop only implementation
//------------------
#ifndef __IPHONE__
#import "DesktopViewController.h"

//--------------------
// TestGeneration Dispatcher
//--------------------
void TaskSpec::generateLocationAndSnapshots(vector<data> &t_data_array)
{
    switch (taskType) {
        case LOCATE:
            generateLocateTests(t_data_array);
            break;
        case TRIANGULATE:
            generateTriangulateTests(t_data_array);
            break;
        case ORIENT:
            generateOrientTests(t_data_array);
            break;
        case LOCATEPLUS:
            generateLocatePlusTests(t_data_array);
            break;
        case DISTANCE:
            generateDistanceTests(t_data_array);
            break;
        default:
            break;
    }
};


//-----------------------
// Locate tests
//-----------------------
void TaskSpec::generateLocateTests(vector<data> &t_data_array)
{
    float device_width;
    float monitor_width = 1920;
    int location_n = 5;
    //-------------------
    // Parameters
    //-------------------
    if (deviceType == PHONE){
        device_width = rootViewController.renderer->emulatediOS.width;
    }else{
        device_width = rootViewController.renderer->emulatediOS.radius;
    }

    snapshot_array.clear();
    code_location_vector.clear();
    
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    double step = (monitor_width - device_width) / location_n;
    for (int i = 1; i <= location_n; ++i){
        addOneDataAndSnapshot
        (to_string(i), CGPointMake((int)(step*i), 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + to_string(i),
                                                 vector<int>{(int)(step*i), 0}));
    }

    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_dist = {20, 100, 200};
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        string trialString = to_string(i) + "t";
        addOneDataAndSnapshot
        (trialString, CGPointMake(practice_dist[i], 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + trialString,
                                                 vector<int>{practice_dist[i], 0}));
    }
}

//-----------------------
// Distance tests
//-----------------------
void TaskSpec::generateDistanceTests(vector<data> &t_data_array)
{
    float device_width;
    float monitor_width = 1920;
    int location_n = 5;
    //-------------------
    // Parameters
    //-------------------
    if (deviceType == PHONE){
        device_width = rootViewController.renderer->emulatediOS.width;
    }else{
        device_width = rootViewController.renderer->emulatediOS.radius;
    }
    
    snapshot_array.clear();
    code_location_vector.clear();
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    double step = (monitor_width - device_width) / location_n;
    
    for (int i = 1; i <= location_n; ++i){

        code_location_vector.push_back(make_pair(identifier + ":" + to_string(i),
                                                 vector<int>{(int)(step*i), 0}));
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(step*i, 0), t_data_array);
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_dist = {100, 200, 300};
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        string trialString = to_string(i) + "t";
        addOneDataAndSnapshot
        (trialString, CGPointMake(practice_dist[i], 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + trialString,
                                                 vector<int>{practice_dist[i], 0}));
    }
}

//-----------------------
// Orient tests
//-----------------------
void TaskSpec::generateOrientTests(vector<data> &t_data_array)
{
    //-------------------
    // Parameters
    //-------------------
    vector<int> base_length_vector = {300, 900, 1200};
    int location_n_per_ring = 5;
    
    // At this point we have location_n lengths
    std::uniform_int_distribution<int>  distr2(0, 359);
    
    // 0 degree is in the positie x direction
    vector<int> theta_vector;
    for (int i = 0; i < location_n_per_ring; ++i){
        theta_vector.push_back(distr2(generator));
    }
    
    snapshot_array.clear();
    code_location_vector.clear();
    //-------------------------
    // Generate point (x, y) here
    //-------------------------
    for (int i = 0; i < base_length_vector.size(); ++i)
    {
        for (int j = 0; j < location_n_per_ring; ++j)
        {
            int x, y;
            // Calculate point 1
            int pt1_length = base_length_vector[i];
            int theta =  theta_vector[j];
            x = (float)pt1_length * cos((float)theta/180 * M_PI);
            y = (float)pt1_length * sin((float)theta/180 * M_PI);
            code_location_vector.push_back(
            make_pair(identifier + ":" + to_string(i * location_n_per_ring + j),
                                                     vector<int>{pt1_length, theta}));
            addOneDataAndSnapshot
            (to_string(i * location_n_per_ring + j), CGPointMake(x, y), t_data_array);

        }
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_theta = {30, 100, 290};
    for (int i = 1; i <= practice_theta.size(); ++i)
    {
        string trialString = to_string(i) + "t";
        
        int x, y;
        // Calculate point 1
        int pt1_length = 100;
        int theta =  practice_theta[i];
        x = (float)pt1_length * cos((float)theta/180 * M_PI);
        y = (float)pt1_length * sin((float)theta/180 * M_PI);
        code_location_vector.push_back(
                                       make_pair(identifier + ":" + trialString,
                                                 vector<int>{pt1_length, theta}));
        addOneDataAndSnapshot(trialString, CGPointMake(x, y), t_data_array);
    }
    
}

void TaskSpec::addOneDataAndSnapshot(string trialString,
                                     CGPoint openGLPoint,
                       vector<data> &t_data_array)
{
    //--------------
    // Generate a new test location
    //--------------
    CGPoint mapViewPoint =
    CGPointMake(openGLPoint.x + rootViewController.renderer->view_width/2,
                rootViewController.renderer->view_height/2 - openGLPoint.y);
    
    data t_data;
    CLLocationCoordinate2D coord =
    [rootViewController.mapView convertPoint: mapViewPoint
                        toCoordinateFromView:rootViewController.mapView];
    t_data.latitude = coord.latitude;
    t_data.longitude = coord.longitude;
    t_data.name = identifier + ":" + trialString;
    t_data_array.push_back(t_data);
    
    //--------------
    // Generate a new snapshot
    //--------------
    
    // Calculate coordinate region
    MKCoordinateRegion coordinateRegion;
    coordinateRegion.center = rootViewController.mapView.centerCoordinate;
    
    if (deviceType == PHONE){
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
        [rootViewController calculateCoordinateSpanForDevice:WATCH];
    }
    
    //------------------
    // Collect all the selected ids
    //------------------
    vector<int> selected_ids = {(int)t_data_array.size() - 1};
    vector<int> is_answer_list = {1};
    
    //------------------
    // Assemble a snapshot
    //------------------
    snapshot t_snapshot;
    t_snapshot.name = [NSString stringWithUTF8String:
                       (identifier + ":" + trialString).c_str()];
    t_snapshot.coordinateRegion = coordinateRegion;
    t_snapshot.selected_ids = selected_ids;
    t_snapshot.is_answer_list = is_answer_list;
    t_snapshot.orientation = 0;
    
    if (trialString.find("t") == string::npos)
        snapshot_array.push_back(t_snapshot);
    else
        practice_snapshot_array.push_back(t_snapshot);
}
#endif