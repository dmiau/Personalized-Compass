//
//  filesystem.h
//  lab_Dropbox[ios
//
//  Created by Daniel Miau on 6/24/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

typedef enum{
    BUNDLE,
    IOS_DOC,
    DROPBOX
} FILESYS_TYPE;

@interface filesystem : NSObject
@property FILESYS_TYPE filesys_type;
@property NSArray *supported_filetypes;
@property NSString *bundle_path;
@property NSString *document_path;
@property DBFilesystem* db_filesystem;
@property NSMutableString* error_str;
@property bool isReady;

//--------------
// Methods
//--------------

- (id) initBUNDLE;
- (id) initIOSDOC;
- (id) initDROPBOX;
- (void) linkDropbox: (UIVideoEditorController*) controller;

- (NSArray*) listFiles;
- (NSData*) readFileFromName: (NSString*) filename;
- (NSData*) readBundleFileFromName: (NSString*) filename;
- (BOOL) writeFileWithName: (NSString*) filename
                   Content: (NSString*) content;
- (BOOL) renameFilename: (NSString*) old_name
               withName: (NSString*) new_name;
- (BOOL) deleteFilename: (NSString*) filename;

- (BOOL) fileExists: (NSString*) filename;

- (void) copyBundleConfigurations;
@end
