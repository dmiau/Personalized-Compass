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
    self.supported_filetypes = @[@"'.kml'", @"'.json'"];
    
    //---------------
    // initialize parameters
    //---------------
    self.filesys_type = BUNDLE;
    self.error_str = [[NSMutableString alloc] init];
    
    // Get directory path
    self.bundle_path = [[NSBundle mainBundle] resourcePath];
    self.document_path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return self;
}

- (id) initBUNDLE{
    return [self init];
}

- (id) initIOSDOC{

    self = [self init];
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
            
            [[NSFileManager defaultManager]
             copyItemAtPath:[self.bundle_path stringByAppendingPathComponent:filename]
             toPath:[self.document_path stringByAppendingPathComponent:filename]
             error:&error];
        }
    }
    
    return self;
}

- (id) initDROPBOX: (UIVideoEditorController*) controller{
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
    }else{
        /*
         * Ask the user to link an account.
         */
        [[DBAccountManager sharedManager] linkFromController:controller];
    }
    
    return self;
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
            NSArray *contents = [self.db_filesystem listFolder:[DBPath root] error:&error];

            
            if (!contents){
                return nil;
            }
            NSMutableArray* mutableDirFiles = [[NSMutableArray alloc] init];
            for (DBFileInfo *info in contents) {
                
                [mutableDirFiles addObject:info.path.stringValue];
            }
            dirFiles = [[NSArray alloc] initWithArray:mutableDirFiles];
            break;
    }
    return  dirFiles;
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
    NSData* fileContents = [[NSFileManager defaultManager] contentsAtPath:path];;
    return fileContents;
}

- (NSData*) readDocFileFromName: (NSString*) filename{
    NSString *path = [self.document_path stringByAppendingPathComponent:filename];
    NSData* fileContents = [[NSFileManager defaultManager] contentsAtPath:path];;
    return fileContents;
}


- (NSData*) readDropboxFileFromName: (NSString*) filename{
    
    DBError *error = nil;
    DBPath *path = [[DBPath root] childPath:filename];
    
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
