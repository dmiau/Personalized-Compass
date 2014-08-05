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
    vector<int> result;
    
    // filter_kOrientations generates a new list of
    // indices_for_rendering
    
    vector<pair<double, int>> dist_id_pair_list;
    vector<int> qualified_id_list;
    // Get rid of the landmarks with 0 distance,
    // visible, or disabled
    
    for (int i = 0; i < data_array.size(); ++i){
        if (data_array[i].distance > 0
            && data_array[i].isEnabled
            && !data_array[i].isVisible)
        {
            qualified_id_list.push_back(i);
        }
    }

    //-----------------
    // Apply prefilter
    //-----------------
    qualified_id_list = prefilterDataByDistance(qualified_id_list);
    
    
    
    // Only need to eliminate if the # of landmarks > k
    if (qualified_id_list.size() > k){
        
        vector<pair<double, int>> orient_diff_list =
        generateOrientDiffList(qualified_id_list);
        
        
        // Backward greedy selection
        sort(orient_diff_list.begin(), orient_diff_list.end(), compareDecending);


        orient_diff_list.erase(orient_diff_list.begin()+k,
                               orient_diff_list.end());
        
        qualified_id_list.clear();
        
        for (int i = 0; i < orient_diff_list.size(); ++i){
            int j = orient_diff_list[i].second;
            qualified_id_list.push_back(j);
        }
    }

    //-------------------
    // Need to further eliminate potential overlaps
    //-------------------
    vector<pair<double, int>> orient_diff_list =
    generateOrientDiffList(qualified_id_list);
    sort(orient_diff_list.begin(), orient_diff_list.end(), compareAscending);
    qualified_id_list.clear();
    for (int i = 0; i < orient_diff_list.size(); ++i){
        //[todo] need to remove the far landmark
        //not just a random one!
        if (orient_diff_list[i].first > 40){
            qualified_id_list.push_back(orient_diff_list[i].second);
        }
    }
    
    for (int i = 0; i< qualified_id_list.size(); ++i){
        dist_id_pair_list.push_back(make_pair(data_array[qualified_id_list[i]].distance, qualified_id_list[i]));
    }
    
    // **indices_for_rendering should be sorted by distance
    sort(dist_id_pair_list.begin(), dist_id_pair_list.end(), compareAscending);
    
    for (int i = 0; i < dist_id_pair_list.size(); ++i){
        result.push_back(dist_id_pair_list[i].second);
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


#pragma mark ---------apply data prefilter
vector<int> compassMdl::prefilterDataByDistance(vector<int> qualified_id_list)
{
    
    if ([configurations[@"prefilter_param"] isEqualToString: @"CLUSTER"]){
        //-----------------
        // Choose the close landmark if possible
        //-----------------
        qualified_id_list = sortIDByDistance(qualified_id_list);
        indices_sorted_by_distance = qualified_id_list;
        
        vector<double> mode_dist_list = clusterData(qualified_id_list);
        vector<int> temp_list;
        if (mode_dist_list.size() > 1){

            for(int i = 0; i < qualified_id_list.size(); ++i){
                int j = qualified_id_list[i];
                if (data_array[j].distance <= mode_dist_list[0])
                {
                    temp_list.push_back(j);
                }
            }
        }
        
        if (temp_list.size() > 5){            
            qualified_id_list = temp_list;
        }else{
            // Sometimes the cluster code only returns 1 item in the first cluster...
            
            double value = [configurations[@"prefilter_value"] floatValue];
            qualified_id_list = filter_kNearestLocations
            (ceil( value * qualified_id_list.size()));
        }
        
    }else if ([configurations[@"prefilter_param"] isEqualToString: @"CLOSEST"])
    {
        qualified_id_list = sortIDByDistance(qualified_id_list);
        indices_sorted_by_distance = qualified_id_list;
        double value = [configurations[@"prefilter_value"] floatValue];
        qualified_id_list = filter_kNearestLocations
        (ceil( value * qualified_id_list.size()));
    }
    
    return qualified_id_list;
}










