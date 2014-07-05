//
//  locationFilter.cpp
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/17/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "compassModel.h"
#include <algorithm>
#include "commonInclude.h"


#pragma mark ---------Tools

// http://stackoverflow.com/questions/650162/why-switch-statement-cannot-be-applied-on-strings
filter_enum compassMdl::hashFilterStr (NSString *inString) {
    if ([inString isEqualToString:@"DEFAULT_FILTER"]) return DEFAULT_FILTER;
    if ([inString isEqualToString:@"NONE"]) return NONE;
    if ([inString isEqualToString:@"K_NEARESTLOCATIONS"]) return K_NEARESTLOCATIONS;
    if ([inString isEqualToString:@"K_ORIENTATIONS"]) return K_ORIENTATIONS;
    if ([inString isEqualToString:@"FORCE_EQUILIBRIUM"]) return FORCE_EQUILIBRIUM;
    if ([inString isEqualToString:@"MANUAL"]) return MANUAL;    
    throw(runtime_error("Unknown style string."));
}

//---------------------
// Central Filter Dispatcher
//---------------------
vector<int> compassMdl::applyFilter(filter_enum filter_type,
                           int filter_param){
    vector<int> result;
    switch (filter_type) {
        case DEFAULT_FILTER:
            // No change
            result = indices_for_rendering;
            break;
        case NONE:
            result = filter_none();
            break;
        case K_NEARESTLOCATIONS:
            result = filter_kNearestLocations(filter_param);
            break;
        case K_ORIENTATIONS:
            result = filter_kOrientations(filter_param);
            break;
        case FORCE_EQUILIBRIUM:
            result = filter_forceEquilibrium(filter_param);
            break;
        case MANUAL:
            result = filter_manual(filter_param);
            break;
        default:
//            cout << "Unknown filter type";
            throw(runtime_error("Unknown filter type"));
    }
    return result;
}


#pragma mark ---------apply no filters
vector<int> compassMdl::filter_none(){
    return indices_sorted_by_distance;
}

#pragma mark ---------k nearest locations
vector<int> compassMdl::filter_kNearestLocations(int k){
    vector<int> result;
    k = std::min((int)indices_sorted_by_distance.size(), k);
    result.assign(indices_sorted_by_distance.begin(),
                                 indices_sorted_by_distance.begin() + k);
    return result;
}

#pragma mark ---------k locations that spread out
vector<int> compassMdl::filter_kOrientations(int k){
    int i = 0;
    vector<int> result;
    
    // filter_kOrientations generates a new list of
    // indices_for_rendering
    
    vector<pair<double, int>> dist_id_pair_list;
    vector<int> non_zero_id_list;
    // Get rid of the landmarks with 0 distance
    for (i = 0; i < data_array.size(); ++i){
        if (data_array[i].distance > 0 && data_array[i].isEnabled){
            non_zero_id_list.push_back(i);
        }
    }

    // Only need to eliminate if the # of landmarks > k
    if (non_zero_id_list.size() > k){
        vector<pair<float, int>> orient_id_list;
        
        // Randomly pick one landmark as the reference landmark
        //    int primary_ind = rand() % data_array.size();
        int primary_ind = 0;
        
        // Sort all the landmarks wrt the primary landmark
        float primary_orientation = data_array[non_zero_id_list[primary_ind]].orientation;
        
        // Collect all the angles
        for (int i = 0; i < non_zero_id_list.size(); ++i){
            float orient = data_array[non_zero_id_list[i]].orientation;
            
            if (i == primary_ind){
                orient = 0;
            }else{
                orient = orient - primary_orientation;
                if (orient < 0)
                    orient = orient + 360;
            }
            orient_id_list.push_back(make_pair(orient, non_zero_id_list[i]));
        }
        
        // Sort the list based on orientation
        sort(orient_id_list.begin(), orient_id_list.end(), compareAscending);
        
        // Calculate the differences
        // [todo] the end point may need some more works
        vector<pair<double, int>> orient_diff_list;
        for (int i = 1; i<orient_id_list.size(); ++i){
            
            float t_diff = orient_id_list[i].first - orient_id_list[i-1].first;
            orient_diff_list.push_back(
                                       make_pair(t_diff, orient_id_list[i].second));
        }
        
        sort(orient_diff_list.begin(), orient_diff_list.end(), compareAscending);

        // Backwards greedy elimination
        for (i = non_zero_id_list.size() - 1; i > k-1; --i){
            orient_diff_list.erase(orient_diff_list.begin());
        }
        
        // May need to further eliminate if the two landmarks are too close
        // in terms of their angels
        
        
        // Important, don't forget about the first one
        // a bug here before, index of index is extremely confusing
        dist_id_pair_list.push_back(make_pair(data_array[non_zero_id_list[primary_ind]].distance, non_zero_id_list[primary_ind]));
        
        // [todo] why no array out of bound error?
        for (i = 0; i < orient_diff_list.size(); ++i){
            int j = orient_diff_list[i].second;
            dist_id_pair_list.push_back(make_pair(
                                                  data_array[j].distance, j));
        }
    }else{
        for (i = 0; i< non_zero_id_list.size(); ++i){
            dist_id_pair_list.push_back(make_pair(data_array[non_zero_id_list[i]].distance, non_zero_id_list[i]));
        }
    }
    
    // **indices_for_rendering should be sorted by distance
    sort(dist_id_pair_list.begin(), dist_id_pair_list.end(), compareAscending);
    
    for (i = 0; i < dist_id_pair_list.size(); ++i){
        result.push_back(dist_id_pair_list[i].second);
    }
    
    // Need to do something more if the number of selected landmarks < k
    if ( result.size() <= 1){
        throw(runtime_error("# of Lanrmakrs shoudl be > 1!"));
    }
    return result;
}

#pragma mark ---------force equilibrium
vector<int> compassMdl::filter_forceEquilibrium(int k){
    vector<int> result;
    return result;
}

#pragma mark ---------apply manual filter
vector<int> compassMdl::filter_manual(int k){
    
    
    vector<int> id_list;
    id_list.clear();
    for (int i = 0; i < data_array.size(); ++i) {
        if (data_array[i].isEnabled){
            id_list.push_back(i);
        }
    }
    vector<int> out_list = sortIDByDistance(id_list);
    return out_list;
}

#pragma mark ---------tool

// This function sorts ID by distance (in ascending order)
vector<int> compassMdl::sortIDByDistance(vector<int> id_list){

    vector<pair<double, int>> dist_id_pair_list;
    vector<int> output_list;
    dist_id_pair_list.clear();
    for (int i = 0; i<id_list.size(); ++i) {
        int j = id_list[i];
        dist_id_pair_list
        .push_back(make_pair(data_array[j].distance, j));
    }
    
    // **indices_for_rendering should be sorted by distance
    sort(dist_id_pair_list.begin(), dist_id_pair_list.end(), compareAscending);
    
    output_list.clear();
    for (int i = 0; i < dist_id_pair_list.size(); ++i)
    {
        output_list.push_back(dist_id_pair_list[i].second);
    }
    return output_list;
}



