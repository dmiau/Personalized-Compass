//
//  filesystem.m
//  lab_Dropbox[ios
//
//  Created by Daniel Miau on 6/24/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#import "filesystem.h"


#define APP_KEY     @"mgd5xnagvcee3mj"
#define APP_SECRET  @"8zicwhc2ahtzxys"

@implementation filesystem

//----------------
// initialization
//----------------
- (id) init{
    self = [super init];
    self.supported_filetypes = @[@"'.kml'", @"'.json'",
                                 @"'.snapshot'"];
    
    //---------------
    // initialize parameters
    //---------------
    self.error_str = [[NSMutableString alloc] init];
    
    // Get directory path
    self.bundle_path = [[NSBundle mainBundle] resourcePath];
    self.document_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.isReady = YES;
    self.folder_name = @"";
    return self;
}

- (id) initBUNDLE{
    self = [self init];
    self.filesys_type = BUNDLE;
    return self;
}

- (id) initIOSDOC{
    self = [super init];
    self = [self init];
    self.filesys_type = IOS_DOC;
    // Diff the file to decide if it is necessary to copy all the files
    NSArray* bundle_files = [self listSupportedFilesInDirectory: self.bundle_path];
    NSArray* document_files = [self listSupportedFilesInDirectory: self.document_path];
    
    // Check if the document folder has all the files already
    NSSet* bundle_set = [[NSSet alloc] initWithArray:bundle_files];
    NSSet* document_set = [[NSSet alloc] initWithArray:document_files];
    
    // Only copy files if bundle_set is not a subset of document_set
    if (![bundle_set isSubsetOfSet:document_set]){
        NSMutableArray* diff_file_array = [NSMutableArray arrayWithArray:bundle_files];
        [diff_file_array removeObjectsInArray:document_files];

        // Copy the files to the document folder
        //http://stackoverflow.com/questions/3246109/iphone-ios-copying-files-from-main-bundle-to-documents-folder-error
        for (NSString* filename in diff_file_array){
            NSError* error;
//            NSString* sourcePath = [bundlePath stringByAppendingString:filename];
            
            bool succeed = [[NSFileManager defaultManager]
             copyItemAtPath:[self.bundle_path stringByAppendingPathComponent:filename]
             toPath:[self.document_path stringByAppendingPathComponent:filename]
             error:&error];
            if (!succeed){
                NSLog(@"!!!Failed to copy file");
            }
        }
    }
    
    return self;
}


- (void) copyBundleConfigurations{
    NSString * filename = @"configurations.json";
//    NSError* error;    
//    bool succeed = [[NSFileManager defaultManager]
//     copyItemAtPath:[self.bundle_path stringByAppendingPathComponent:filename]
//     toPath:[self.document_path stringByAppendingPathComponent:filename]
//     error:&error];
    NSData *myData = [self readBundleFileFromName:filename];
    bool succeed = [myData writeToFile:[self.document_path stringByAppendingPathComponent:filename] atomically:YES];
    
    if (!succeed){
        NSLog(@"!!!Failed to copy configurations.json");
    }    
}

- (id) initDROPBOX{
    self = [super init];
    self = [self init];
    self.supported_filetypes = @[@"'.kml'", @"'.json'"];
    
    //---------------
    // initialize parameters
    //---------------
    self.filesys_type = DROPBOX;
    
    // Get directory path
    self.bundle_path = [[NSBundle mainBundle] resourcePath];
    self.document_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    /*
     * Create a DBAccountManager object. This object lets you link to a Dropbox
     * user's account which is the first step to working with data on their
     * behalf.
     */
    
    DBAccountManager* accountMgr = [[DBAccountManager alloc]
                                    initWithAppKey:APP_KEY
                                    secret:APP_SECRET];
    [DBAccountManager setSharedManager:accountMgr];
    
    if (accountMgr.linkedAccount) {
        [self initDropboxWithAccount:accountMgr.linkedAccount];
        self.isReady = YES;
    }else{
        self.isReady = NO;
        // User will need to call linkDropbox
    }
    
    return self;
}

//---------------
// Compute Dropbox path
//---------------
- (DBPath*) computeDBPath{
    DBPath* outpath;
    if ([self.folder_name length]==0)
        outpath = [DBPath root];
    else
        outpath = [[DBPath alloc] initWithString:self.folder_name];
    return outpath;
}

- (void) linkDropbox: (UIVideoEditorController*) controller{
    /*
     * Ask the user to link an account.
     */
    [[DBAccountManager sharedManager] linkFromController:controller];
    self.isReady = YES;
}

- (NSArray*) listSupportedFilesInDirectory: (NSString*) dir_path{
    // Collect a list of the supported files from the bundle
    NSArray *dirFiles = [[NSFileManager defaultManager]
                         contentsOfDirectoryAtPath: dir_path error:nil];
    
    NSMutableString* predicate_str = [NSMutableString stringWithFormat:@"self ENDSWITH "];
    NSMutableArray * bundle_files = [[NSMutableArray alloc] init];
    
    for (NSString* file_ext in self.supported_filetypes){
        NSMutableString* temp_predicate = [predicate_str mutableCopy];
        [temp_predicate appendString:file_ext];
        
        NSArray* files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:temp_predicate]];
        [bundle_files addObjectsFromArray:files];
    }
    return bundle_files;
}

//----------------
// list files
//----------------
- (NSArray*) listFiles{
    
    //---------------
    // Get directory path
    //---------------
    NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray* dirFiles;
    switch (self.filesys_type) {
        case BUNDLE:
            dirFiles = [[NSFileManager defaultManager]
                        contentsOfDirectoryAtPath: bundlePath error:nil];
            break;
        case IOS_DOC:
            dirFiles = [[NSFileManager defaultManager]
                        contentsOfDirectoryAtPath: documentsDirectory error:nil];
            break;
        case DROPBOX:
            /*
             * Read contents of Dropbox app folder
             */
            DBError *error = nil;
            NSArray *contents = [self.db_filesystem listFolder:[self computeDBPath]
                                                         error:&error];

            
            if (!contents){
                return nil;
            }
            NSMutableArray* mutableDirFiles = [[NSMutableArray alloc] init];
            for (DBFileInfo *info in contents) {
                // Otherwise there is a / prefix...
                [mutableDirFiles addObject:[info.path.stringValue lastPathComponent]];
            }
            dirFiles = [[NSArray alloc] initWithArray:mutableDirFiles];
            break;
    }
    return  dirFiles;
}

//----------------
// check existence
//----------------
- (bool) fileExists:(NSString *)filename{
    bool fileStatus;
    NSString *path;
    
    switch (self.filesys_type) {
        case BUNDLE:
            path = [self.bundle_path stringByAppendingPathComponent:filename];
            fileStatus = [[NSFileManager defaultManager] fileExistsAtPath:path];
            break;
        case IOS_DOC:
            path = [self.document_path stringByAppendingPathComponent:filename];
            fileStatus = [[NSFileManager defaultManager] fileExistsAtPath:path];
            break;
        case DROPBOX:
            DBPath *path = [[self computeDBPath] childPath:filename];
            DBError *error = nil;
            DBFileInfo *info = [self.db_filesystem fileInfoForPath:path error:&error];
            if (!info)
                fileStatus = false;
            else
                fileStatus = true;
            break;
    }
    return fileStatus;
}


//----------------
// read files
//----------------
- (NSData*) readFileFromName: (NSString*) filename{
    NSData* outData;
    
    switch (self.filesys_type) {
        case BUNDLE:
            outData = [self readBundleFileFromName:filename];
            break;
        case IOS_DOC:
            outData = [self readDocFileFromName:filename];
            break;
        case DROPBOX:
            outData = [self readDropboxFileFromName:filename];
            break;
    }
    return outData;
}

- (NSData*) readBundleFileFromName: (NSString*) filename{
    NSString *path = [self.bundle_path stringByAppendingPathComponent:filename];
    NSData* fileContents = [[NSFileManager defaultManager] contentsAtPath:path];
    return fileContents;
}

- (NSData*) readDocFileFromName: (NSString*) filename{
    NSString *path = [self.document_path stringByAppendingPathComponent:filename];
    NSData* fileContents = [[NSFileManager defaultManager] contentsAtPath:path];
    return fileContents;
}


- (NSData*) readDropboxFileFromName: (NSString*) filename{
    
    DBError *error = nil;
    DBPath *path = [[self computeDBPath] childPath:filename];
    
    DBFileInfo *info = [self.db_filesystem fileInfoForPath:path error:&error];
    if (!info){
        [self.error_str appendString:@"File does not exist."];
        return nil;
    }
    
    if ([info isFolder]) {
        [self.error_str appendFormat:@"\n%@ is a folder.\n", [path stringValue]];
        return nil;
    } else {
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&error];
        if (!file){
            [self.error_str appendString:@"Error opening file."];
            return nil;
        }
        //- (NSData *)readData:(DBError **)error
        NSData *fileContents = [file readData:&error];
        if (!fileContents){
            [self.error_str appendString:@"Error reading file."];
        }
        [file close];
        return fileContents;
    }
}

//----------------
// write files
//----------------
- (BOOL) writeFileWithName: (NSString*) filename
                   Content: (NSString*) content
{
    NSError* error;
    NSString *doc_path = [self.document_path stringByAppendingPathComponent:filename];

    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSUTF8StringEncoding
                        error:&error])
    {
        NSLog(@"KML write failed");
        return false;
    }
    
    // Always write to the Documentation folder first
    if (self.filesys_type == DROPBOX)
    {
        // Dropbox case
        DBError *error = nil;
        DBPath *path = [[self computeDBPath] childPath:filename];

        DBFileInfo *info = [self.db_filesystem fileInfoForPath:path error:&error];

        DBFile *file;
        // Check whether the file exists or not
        if (!info){
            file = [self.db_filesystem createFile:path error:&error];
        }else{
            file = [[DBFilesystem sharedFilesystem]
               openFile:path error:&error];
        }
        
        if (!file){
            [self.error_str appendString:@"Error opening file."];
            return false;
        }else{
            if (![file writeString:content error:&error]){
            [self.error_str appendString:@"Failed to write file to dropbox."];
                return false;
            }
        }
    }
    return true;
}

//----------------
// Rename a file
//----------------
- (BOOL) renameFilename: (NSString*) old_name
               withName: (NSString*) new_name
{
    bool rename_status;
    NSString *old_doc_path = [self.document_path
                              stringByAppendingPathComponent:old_name];
    NSString *new_doc_path = [self.document_path
                              stringByAppendingPathComponent:new_name];

    
    rename_status = [[NSFileManager defaultManager] moveItemAtPath:old_doc_path
                                            toPath:new_doc_path
                                             error:nil];
    if (self.filesys_type == DROPBOX)
    {
        DBError *error = nil;
        DBPath *old_path = [[self computeDBPath] childPath:old_name];
        DBPath *new_path = [[self computeDBPath] childPath:new_name];
        rename_status = [self.db_filesystem movePath:old_path toPath:new_path error:&error];
    }
    
    return rename_status;
}

//----------------
// Delete a file
//----------------
- (BOOL) deleteFilename: (NSString*) old_name
{
    bool delete_status;
    NSString *doc_path = [self.document_path
                              stringByAppendingPathComponent:old_name];
    
    
    delete_status = [[NSFileManager defaultManager]
                     removeItemAtPath:doc_path error:nil];
    if (self.filesys_type == DROPBOX)
    {
        DBError *error = nil;
        DBPath *db_path = [[self computeDBPath] childPath:old_name];
        delete_status = [self.db_filesystem deletePath:db_path error:&error];
    }
    return delete_status;
}

#pragma mark ----Dropbox related stuff----

- (BOOL)initDropboxWithAccount:(DBAccount *)account
{
    DBError *error = nil;
    
    /*
     * Check that we're given a linked account.
     */
    if (!account) {
        return NO;
    }
    
    /*
     * Check if shared filesystem already exists - can't create more than
     * one DBFilesystem on the same account.
     */
    
    self.db_filesystem = [DBFilesystem sharedFilesystem];
    
    if (!self.db_filesystem || self.db_filesystem.isShutDown) {
        self.db_filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:self.db_filesystem];
    }
    return YES;
}

@end
