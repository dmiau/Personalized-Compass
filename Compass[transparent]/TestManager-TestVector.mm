//
//  TestManager-TestVector.cpp
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManager.h"
#import "CHCSVParser.h"
#include <iterator>
#include <algorithm>

using namespace std;

template <class type>
vector<vector<vector<type>>> permute(vector<vector<type>> input, int leaf_n){
    vector<vector<vector<type>>> output; output.clear();
    
    for (int i = 0; i < input.size(); ++i){
        if (leaf_n > 1){
            vector<vector<type>> temp = input;
            temp.erase(temp.begin() + i);
            
            vector<vector<vector<type>>> t_output = permute(temp, leaf_n-1);
            
            for (int j = 0; j < t_output.size(); ++j){
                t_output[j].insert(t_output[j].begin(), input[i]);
                output.push_back(t_output[j]);
            }
        }else{
            output.push_back({input[i]});
        }
    }
    return output;
}

//---------------
// Pool object
//---------------

template <class type>
pool<type>::pool(vector<type> conditions, POOLMODE mode, int leaf_n){
    counter = 0;
    content.clear();
    // Do one permutation and another special permute
    // example input {1, 2}
    vector<vector<type>> temp; temp.clear();
    
    vector<int> proxy_vector;
    for (int i = 0; i < conditions.size(); ++i){
        proxy_vector.push_back(i);
    }
    
    switch (mode) {
        case FULL:
            do
            {
                // I am not sure why do I need this?
                vector<type> t_conditions;
                for (int i = 0; i < conditions.size(); ++i){
                    t_conditions.push_back(conditions[proxy_vector[i]]);
                }
                temp.push_back(t_conditions);
            }
            while (next_permutation(proxy_vector.begin(),
                                    proxy_vector.end()));
            // At this point {{1, 2}, {2, 1}}
            break;
        case FIXED:
            temp.push_back(conditions);
            break;
        case LATIN:
            throw(runtime_error("LATIN has not been implemented."));
            break;
        default:
            throw(runtime_error("Unknown mode."));
            break;
    }
    
    // Need to use recursion
    content = permute(temp, leaf_n);
    // At this point
    // {{{1, 2}, {2, 1}},
    // {{2, 1}, {1, 2}}}
}

// Next should return the following in sequence
// {1, 2}, {2, 1},   {2, 1}, {1, 2}
// Note that next should be able to go through the boundary of cells.
// so vector<string>

// The items are organized as
// {{{1, 2}, {2, 1}},
// {{2, 1}, {1, 2}}}
// So I will use row_i and col_i to access an item
template <class type> vector<type> pool<type>::next(){
    vector<type> output;
    
    int i = counter % (content.size()*content[0].size());
    
    int row_i = (int) i / content[0].size();
    int col_i = counter % content[0].size();
    output = content[row_i][col_i];
    counter = counter + 1;
    return output;
}

#ifndef __IPHONE__
#import "DesktopViewController.h"
//--------------
// Testvector Generation
//--------------
void TestManager::generateAllTestVectors(
                                         vector<DeviceType> device_list,
                                         vector<VisualizationType> visualization_list,
                                         vector<TaskType> task_list)
{
    pool<VisualizationType> visualization_pool =
    pool<VisualizationType>(visualization_list, FULL, 1); //personalized compass, wedge
    pool<DeviceType> device_pool = pool<DeviceType>({WATCH, PHONE}, FULL, 1); //phone, watch
    pool<TaskType> task_pool = pool<TaskType>(task_list, FULL, 1);
    
    
    pool<TaskType> phone_task_pool = pool<TaskType>(phone_task_list, FULL, 1);
    pool<TaskType> watch_task_pool = pool<TaskType>(watch_task_list, FULL, 1);
    
    pool<DataSetType> dataset_pool = pool<DataSetType>(data_set_list, FULL, 1);
    dataset_pool.content = {{{NORMAL, MUTANT}}, {{NORMAL, MUTANT}},
        {{MUTANT, NORMAL}}, {{MUTANT, NORMAL}}};
    
    string dprefix = "", dvprefix = "", dvtprefix = "", prefix = "";
    vector<string> user_test_vector;
    all_test_vectors.clear();
    all_snapshot_vectors.clear();
    for (int ui = 0; ui < participant_n; ++ui){
        
        //------------------------
        // Generate test vector and snapshot for each participant
        // Note the extensive use of the next method
        //------------------------
        user_test_vector.clear();
        vector<snapshot> t_snapshot_array;
        
        //--------------------
        // Alternative configurations
        //--------------------
        vector<VisualizationType> t_visualization_list = visualization_pool.next();
        vector<DataSetType> t_dataset_list = dataset_pool.next();
        
//        //swap device order
//        iter_swap(t_dataset_list.begin(), t_dataset_list.begin() + 1);
        
        for (int vi = 0; vi < t_visualization_list.size(); ++vi){
            
            vector<DeviceType> t_device_list = device_pool.next();
            for (int di = 0; di < t_device_list.size(); ++di){
                
                vector<TaskType> t_task_list;
                if (t_device_list[di] == PHONE){
                    t_task_list = phone_task_pool.next();
                }else{
                    t_task_list = watch_task_pool.next();
                }
                
                for (int ti = 0; ti < t_task_list.size(); ++ti){
                    // Task code
                    string task_code =
                    toString(t_device_list[di]) + ":" +
                    toString(t_task_list[ti]) + ":" +
                    toString(t_dataset_list[vi]);
                    
                    //--------------------------
                    // Retrive the taskSpec object from taskSpec_dict
                    //--------------------------
                    if (taskSpec_dict.find(task_code) == taskSpec_dict.end()){
                        NSString *t_str = [NSString stringWithUTF8String:task_code.c_str()];
                        [rootViewController displayPopupMessage:
                         [NSString stringWithFormat:@"%@ cannot be found in taskSpec_dict",
                          t_str]];
                    }else{
                        
                        //-------------------
                        // Need to set the visualization here,
                        // because two visualizations may share the same
                        // snapshot
                        //-------------------
                        
                        TaskSpec myTaskSpec = taskSpec_dict[task_code];
                        
                        
                        
                        //-------------------
                        // Insert a set of practice snapshots here
                        //-------------------
                        if (di == 0 && ti == 0){
                            vector<snapshot> t_practice_snapshots =
                            practice_snapshot_dict[t_dataset_list[vi]];
                            
                            // Configure and insert snapshots
                            for (int i = 0; i < t_practice_snapshots.size(); ++i)
                            {
                                string snapshot_name = toString(t_visualization_list[vi])
                                + ":" + string
                                ([t_practice_snapshots[i].name UTF8String]);
                                user_test_vector.push_back(snapshot_name);
                                
                                //-----------
                                // Make a copy of the snapshot object and put it
                                // to t_snapshot_array
                                // Note some extra configurations are needed
                                //-----------
                                t_snapshot_array.push_back(t_practice_snapshots[i]);
                                t_snapshot_array.back().name =
                                [NSString stringWithUTF8String:snapshot_name.c_str()];
                                t_snapshot_array.back().visualizationType =
                                t_visualization_list[vi];
                                
                                // Device type varies by task,
                                // and it is already set when taskType is
                                // initialized
                                t_snapshot_array.back().kmlFilename =
                                test_kml_filename;
                            }
                        }

                        //-------------------
                        // Insert test snapshot
                        //-------------------
                        vector<int> shuffled_order = myTaskSpec.shuffleTests(generator);
                        
                        for (auto it = shuffled_order.begin(); it < shuffled_order.end(); ++it)
                        {
                            string snapshot_name = toString(t_visualization_list[vi])
                            + ":" + string
                            ([myTaskSpec.snapshot_array[*it].name UTF8String]);
                            user_test_vector.push_back(snapshot_name);
                            
                            //-----------
                            // Make a copy of the snapshot object and put it
                            // to t_snapshot_array
                            // Note some extra configurations are needed
                            //-----------
                            t_snapshot_array.push_back(myTaskSpec.snapshot_array[*it]);
                            t_snapshot_array.back().name =
                            [NSString stringWithUTF8String:snapshot_name.c_str()];
                            t_snapshot_array.back().visualizationType =
                            t_visualization_list[vi];
                            t_snapshot_array.back().kmlFilename =
                            test_kml_filename;
                        }
                    }
                }
            }
            
        }
        // Each participant has a code vector
        all_test_vectors.push_back(user_test_vector);
        // Each participant has a snapshot vector
        all_snapshot_vectors.push_back(t_snapshot_array);
    }
    // Save the generated test vectors to a file
    saveAllTestVectorCSV();
}


#endif
//--------------
// Save all test vectors (each participant has a test vector)
//--------------
void TestManager::saveAllTestVectorCSV(){
    
    //--------------
    // Make sure the output folder exists
    setupOutputFolder();
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    
    NSString *out_file = [folder_path
                          stringByAppendingPathComponent:alltest_vector_filename];
    
    CHCSVWriter *w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    // http://stackoverflow.com/questions/1443793/iterate-keys-in-a-c-map
    
    for (int i = 0; i < all_test_vectors.size(); ++i){
        NSMutableArray* t_array = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < all_test_vectors[i].size(); ++j){
            string item = all_test_vectors[i][j];
            [t_array addObject: [NSString stringWithUTF8String:item.c_str()]];
        }
        
        [w writeLineOfFields:t_array];
    }
    //    [w writeLineOfFields:d.lines[0]];
    //    [w writeLineOfFields:d.lines[1]];
    //    [w writeLineOfFields:@[@1, @2, @3, @"91, 5"]];
}
