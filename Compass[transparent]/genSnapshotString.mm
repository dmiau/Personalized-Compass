#import "compassModel.h"
#include <string>
#include <sstream>

using namespace std;
string genSelectedIDStr(vector<int> id_list){
    string temp_str;
    if (id_list.size() == 0){
        return temp_str;
    }else{
        temp_str = to_string(id_list[0]);
    }
    
    for (int i = 1; i < id_list.size(); ++i){
        temp_str = temp_str + ", " + to_string(id_list[i]);
    }
    return temp_str;
}

NSString* genSnapshotString(vector<snapshot> my_snapshot_array)
{
    
    string temp_str, coord_str;
    std::ostringstream stringStream;
    
    //-------------
    // Header
    //-------------
    temp_str = "<?xml version='1.0' encoding='UTF-8'?>\n";
    temp_str = temp_str + "<kml xmlns='http://www.opengis.net/kml/2.2'>\n";
    temp_str = temp_str + "<Document>\n";
    
    //-------------
    // Body
    //-------------
    
    // Example KML snippet
    /*
     <Placemark>
     <name>Central Park</name>
     <Point>
     <coordinates>-73.973093,40.772352,0.0</coordinates>
     </Point>
     <orientation>30</orientation>
     <kmlFilename>london.kml</kmlFilename>
     </Placemark>
     */
    
    for (int i = 0; i < my_snapshot_array.size(); ++i) {
        temp_str = temp_str + "<Placemark>\n";
        
        
        temp_str = temp_str + "<name>";
        temp_str = temp_str + string([my_snapshot_array[i].name UTF8String]);
        temp_str = temp_str + "</name>\n";
        
        //********************************** iOS
        
        //-----------------
        // Coordinates (longitude, latitude)
        //-----------------
        temp_str = temp_str + "<Point>\n";
        temp_str = temp_str + "<coordinates>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].coordinateRegion.center.longitude << ","
        << my_snapshot_array[i].coordinateRegion.center.latitude << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</coordinates>\n";
        
        //-----------------
        // Coordinates (span)
        //-----------------
        temp_str = temp_str + "<spans>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].coordinateRegion.span.longitudeDelta << ","
        << my_snapshot_array[i].coordinateRegion.span.latitudeDelta << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</spans>\n";
        
        
        temp_str = temp_str + "</Point>\n";
        
        //**********************************
        
        
        
        //********************************** OSX
        
        //-----------------
        // Coordinates (longitude, latitude)
        //-----------------
        temp_str = temp_str + "<OSXPoint>\n";
        temp_str = temp_str + "<osxcoordinates>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].osx_coordinateRegion.center.longitude << ","
        << my_snapshot_array[i].osx_coordinateRegion.center.latitude << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</osxcoordinates>\n";
        
        //-----------------
        // Coordinates (span)
        //-----------------
        temp_str = temp_str + "<osxspans>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].osx_coordinateRegion.span.longitudeDelta << ","
        << my_snapshot_array[i].osx_coordinateRegion.span.latitudeDelta << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</osxspans>\n";
        
        
        temp_str = temp_str + "</OSXPoint>\n";
        
        //**********************************
        
        
        
        
        //-----------------
        // Orientation
        //-----------------
        temp_str = temp_str + "<orientation>";
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].orientation;
        temp_str = temp_str + stringStream.str();
        
        temp_str = temp_str + "</orientation>\n";

        //-----------------
        // kmlFinename
        //-----------------
        temp_str = temp_str + "<kmlFilename>";
        stringStream.clear();
        stringStream.str("");
        stringStream << [[my_snapshot_array[i].kmlFilename lastPathComponent] UTF8String];
        temp_str = temp_str + stringStream.str();
        
        temp_str = temp_str + "</kmlFilename>\n";

        //-----------------
        // Address
        //-----------------
        temp_str = temp_str + "<address>";
        temp_str = temp_str +
        string([my_snapshot_array[i].address UTF8String]);
        temp_str = temp_str + "</address>\n";

        //-----------------
        // selected_ids
        //-----------------
        temp_str = temp_str + "<selected_ids>";
        temp_str = temp_str +
        genSelectedIDStr(my_snapshot_array[i].selected_ids);
        temp_str = temp_str + "</selected_ids>\n";
        

        //-----------------
        // is_answer_list
        //-----------------
        temp_str = temp_str + "<is_answer_list>";
        temp_str = temp_str +
        genSelectedIDStr(my_snapshot_array[i].is_answer_list);
        temp_str = temp_str + "</is_answer_list>\n";
        
        //-----------------
        // ios_display_wh
        //-----------------
        temp_str = temp_str + "<ios_display_wh>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].ios_display_wh.x << ","
        << my_snapshot_array[i].ios_display_wh.y << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</ios_display_wh>\n";
        
        //-----------------
        // eios_display_wh
        //-----------------
        temp_str = temp_str + "<eios_display_wh>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].eios_display_wh.x << ","
        << my_snapshot_array[i].eios_display_wh.y << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</eios_display_wh>\n";
        
        //-----------------
        // osx_display_wh
        //-----------------
        temp_str = temp_str + "<osx_display_wh>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].osx_display_wh.x << ","
        << my_snapshot_array[i].osx_display_wh.y << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</osx_display_wh>\n";
        
        
        //-----------------
        // Notes
        //-----------------
        temp_str = temp_str + "<notes>";
        temp_str = temp_str +
        string([my_snapshot_array[i].notes UTF8String]);
        temp_str = temp_str + "</notes>\n";
        
        //-----------------
        // date_str
        //-----------------
        temp_str = temp_str + "<date>";
        temp_str = temp_str +
        string([my_snapshot_array[i].date_str UTF8String]);
        temp_str = temp_str + "</date>\n";
        
        //-----------------
        // deviceType
        //-----------------
        temp_str = temp_str + "<deviceType>";
        temp_str = temp_str +
        to_string(my_snapshot_array[i].deviceType);
        temp_str = temp_str + "</deviceType>\n";
        
        //-----------------
        // visualizationType
        //-----------------
        temp_str = temp_str + "<visualizationType>";
        temp_str = temp_str +
        to_string(my_snapshot_array[i].visualizationType);
        temp_str = temp_str + "</visualizationType>\n";
                
        temp_str = temp_str + "</Placemark>\n\n";
    }
    
    //-------------
    // Ending
    //-------------
    temp_str = temp_str + "</Document>\n";
    temp_str = temp_str + "</kml>\n";
    
    NSString *out_str = [NSString stringWithUTF8String:temp_str.c_str()];
    return out_str;
}