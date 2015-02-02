//
//  xmlParser.m
//  playCocoa
//
//  Created by Daniel Miau on 3/20/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import "xmlParser.h"
#import "CustomPointAnnotation.h"
#include <stdexcept>


vector<data> readLocationKml(compassMdl* mdl, NSString* filename){
    xmlParser *myParser;
    vector<data> data_array;
    data_array.clear();
    
#ifdef __IPHONE__
    // iOS
    NSData* data = nil;
    if (mdl->dbFilesystem.isReady &&
        mdl->filesys_type == DROPBOX){
        data = [mdl->dbFilesystem readFileFromName:
                [filename lastPathComponent]];
    }
    
    if (!data){
        data = [mdl->docFilesystem readFileFromName:
                [filename lastPathComponent]];
        mdl->filesys_type = IOS_DOC;
    }

    if (!data){
        data = [mdl->docFilesystem readBundleFileFromName:
                [filename lastPathComponent]];
        mdl->filesys_type = BUNDLE;
    }
    
    if (!data){
        throw(runtime_error("Failed to read the location file."));
        return data_array;
    }else{
        myParser = [[xmlParser alloc] initWithData: data];
    }
    
    
#else
    // Desktop
    myParser = [[xmlParser alloc]
                initWithFileURL: [NSURL fileURLWithPath:
                [mdl->desktopDropboxDataRoot stringByAppendingPathComponent:[filename lastPathComponent]]]];
#endif
    
    myParser.parseFile;
    
//    mdl->camera_pos.name = myParser.data_array[0].name;
//    // Set the initial orientation to 0
//    mdl->camera_pos.orientation = 0;
//    mdl->camera_pos.latitude = myParser.data_array[0].latitude;
//    mdl->camera_pos.longitude = myParser.data_array[0].longitude;
//    
//    mdl->data_array = myParser.data_array;

    data_array = myParser.data_array;
    return data_array;
}


@implementation xmlParser

@synthesize data_array;

-(id)initWithFileURL: (NSURL*) in_fileurl{
    self = [super init];
    fileurl = in_fileurl;
    in_data = nil;
    place_flag = false;
    name_flag = false;
    coord_flag = false;
    return self;
}

-(id)initWithData: (NSData*) inData{
    self = [super init];
    fileurl = nil;
    in_data = inData;
    place_flag = false;
    name_flag = false;
    coord_flag = false;
    return self;
}

-(int) parseFile{
    
    if (!in_data){
        parser = [[NSXMLParser alloc]
                  initWithContentsOfURL: fileurl];
    }else{
        parser = [[NSXMLParser alloc] initWithData: in_data];
    }
    
    [parser setDelegate:self];
    BOOL success = [parser parse];
    
    // test the result
    if (!success){
        throw(std::runtime_error("Failed to parse the document!"));
    }
    return success;
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    if ([elementName isEqualToString:@"Placemark"]) {
        data _data;

        data_array.push_back(_data);
        place_flag = true;
    }else if ([elementName isEqualToString:@"name"]){
        name_flag = true;
    }else if ([elementName isEqualToString:@"coordinates"]){
        coord_flag = true;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (place_flag){
        if (name_flag){
            data_array[data_array.size()-1].name = [string UTF8String];
            data_array[data_array.size()-1].annotation.title
            = string;
            data_array[data_array.size()-1].annotation.point_type = landmark;
            data_array[data_array.size()-1].annotation.data_id =
            data_array.size()-1;
        }else if (coord_flag){
            // Need to somehow split the sting
            
            NSArray *_coord = [string componentsSeparatedByString:@","];
            // Note that in KML coordinates order are (lon, lat)
            data_array[data_array.size()-1].latitude = [_coord[1] floatValue];
            data_array[data_array.size()-1].longitude = [_coord[0] floatValue];
            
            // Populate MKPointAnnotation
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake
            (data_array[data_array.size()-1].latitude,
             data_array[data_array.size()-1].longitude);
            data_array[data_array.size()-1].annotation.coordinate = coord2D;
        }
    }
}


-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"Placemark"]) {
        place_flag = false;
    }else if ([elementName isEqualToString:@"name"]) {
        name_flag = false;
    }else if ([elementName isEqualToString:@"coordinates"]) {
        coord_flag = false;
    }
}

@end
