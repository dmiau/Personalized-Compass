//
//  TestManager-TestVector.cpp
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManager.h"
#import "CHCSVParser.h"
using namespace std;

vector<vector<vector<string>>> permute(vector<vector<string>> input, int leaf_n){
    vector<vector<vector<string>>> output; output.clear();
    
    for (int i = 0; i < input.size(); ++i){
        if (leaf_n > 1){
            vector<vector<string>> temp = input;
            temp.erase(temp.begin() + i);
            
            vector<vector<vector<string>>> t_output = permute(temp, leaf_n-1);
            
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
pool::pool(vector<string> conditions, POOLMODE mode, int leaf_n){
    counter = 0;
    content.clear();
    // Do one permutation and another special permute
    // example input {1, 2}
    vector<vector<string>> temp; temp.clear();
    
    switch (mode) {
        case FULL:
            do {
                temp.push_back(conditions);
            } while (next_permutation(conditions.begin(),conditions.end()));
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
vector<string> pool::next(){
    vector<string> output;
    
    int i = counter % (content.size()*content[0].size());
    
    int row_i = (int) i / content[0].size();
    int col_i = counter % content[0].size();
    output = content[row_i][col_i];
    counter = counter + 1;
    return output;
}

//--------------
// Testvector Generation
//--------------
void TestManager::generateAllTestVectors(
                                               vector<string> device_list,
                                               vector<string> visualization_list,
                                               vector<string> task_list,
                                               vector<string> distance_list,
                                               vector<string> location_list
                                               )
{
    pool device_pool = pool(device_list, FULL, 1); //phone, watch
    pool visualization_pool = pool(visualization_list, FULL, 2); //personalized compass, wedge
    pool task_pool = pool(task_list, FULL, 2);
    pool location_pool = pool(location_list, FIXED, 1);
    
    
    string dprefix = "", dvprefix = "", dvtprefix = "", prefix = "";
    vector<string> user_test_vector;
    all_test_vectors.clear();
    for (int ui = 0; ui < participant_n; ++ui){
        
        user_test_vector.clear();
        vector<string> t_device_list = device_pool.next();
        for (int di = 0; di < device_list.size(); ++di){
            // Device prefix
            dprefix = t_device_list[di];
            
            vector<string> t_visualization_list = visualization_pool.next();
            for (int vi = 0; vi < visualization_list.size(); ++vi){
                // Visualization prefix
                dvprefix = dprefix + ":" + t_visualization_list[vi];
                
                vector<string> t_task_list = task_pool.next();
                for (int ti = 0; ti < task_list.size(); ++ti){
                    // Task prefix
                    dvtprefix = dvprefix + ":" + t_task_list[ti];
                    
                    vector<string> t_location_list = location_pool.next();
                    for (int li = 0; li < t_location_list.size(); ++li){
                        prefix = dvtprefix +  ":" + t_location_list[li];
                        
                        // Need to handle slightly differently for task2
                        if (t_task_list[ti] == "t2"){
                            for (int sli = 0; sli <3; ++sli){
                                user_test_vector.push_back(prefix + "-" + to_string(sli));
                            }
                        }else{
                            user_test_vector.push_back(prefix);
                        }
                    }
                    
                }
            }
        }
        all_test_vectors.push_back(user_test_vector);
    }
    // Save the generated test vectors to a file
    saveAllTestVectorCSV();
}

//--------------
// Save all test vectors (each participant has a test vector)
//--------------
void TestManager::saveAllTestVectorCSV(){
    //--------------
    NSString *out_file = [model->desktopDropboxDataRoot
                          stringByAppendingPathComponent:@"allTestVectors.tests"];
    
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
