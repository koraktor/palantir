/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import "NSApplication+Plugins.h"


@implementation NSApplication (Plugins)

- (NSArray *)applicationPlugInsFolders {
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"];
    NSMutableArray *pluginPaths = [NSMutableArray arrayWithCapacity:3];

    // PlugIns folder inside the application bundle
    NSString *bundlePluginPath = [[NSBundle mainBundle] builtInPlugInsPath];
    [pluginPaths addObject:bundlePluginPath];

#ifndef NDEBUG
    // Application parent folder (for convenience while developing)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;

    NSString *pathToProjectsParentFolder = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSArray  *siblings = [fileManager contentsOfDirectoryAtPath:pathToProjectsParentFolder error:NULL];
    for(NSString *sibling in siblings) {
        NSString *siblingPath = [pathToProjectsParentFolder stringByAppendingPathComponent:[sibling stringByAppendingPathComponent:@"build/Development"]];
        if([fileManager fileExistsAtPath:siblingPath isDirectory:&isDirectory] && isDirectory) {
            [pluginPaths addObject:siblingPath];
        }
    }
#endif

    if(applicationName != nil) {
        FSRef folder;
        OSErr err = noErr;
        CFURLRef url;

        // The PlugIns folder inside the user's Application Support folder
        err = FSFindFolder(kUserDomain, kApplicationSupportFolderType, false, &folder);
        if(noErr == err) {
            url = CFURLCreateFromFSRef(kCFAllocatorDefault, &folder);
            if(url != NULL) {
                NSString *userAppSupportPluginFolder = [NSString stringWithFormat:@"%@/%@/PlugIns", [(NSURL *)url path], applicationName];
                [pluginPaths addObject:userAppSupportPluginFolder];
            }
        }

        // The PlugIns folder inside the system's Application Support folder
        err = FSFindFolder(kLocalDomain, kApplicationSupportFolderType, false, &folder);
        if(noErr == err) {
            url = CFURLCreateFromFSRef(kCFAllocatorDefault, &folder);
            if(url != NULL) {
                NSString *systemAppSupportPluginFolder = [NSString stringWithFormat:@"%@/%@/PlugIns", [(NSURL *)url path], applicationName];
                [pluginPaths addObject:systemAppSupportPluginFolder];
            }
        }
    }

    return pluginPaths;
}

- (NSArray *)pluginBundlesWithSuffix:(NSString *)bundleSuffix {
    NSArray *pluginFolderPaths = [NSApp applicationPlugInsFolders];
    NSMutableArray *pluginBundlePaths = [NSMutableArray arrayWithCapacity:10];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;

    for(NSString *currentFolder in pluginFolderPaths) {
        if([fileManager fileExistsAtPath:currentFolder isDirectory:&isDirectory] && isDirectory) {
            NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:currentFolder];
            for(NSString *directoryContent in dirEnum) {
                NSDictionary *itemInfo = [dirEnum fileAttributes];
                if([itemInfo objectForKey:NSFileType] == NSFileTypeDirectory) {
                    if([directoryContent hasSuffix:bundleSuffix]) {
                        NSString *pluginPath = [NSString stringWithFormat:@"%@/%@", currentFolder, directoryContent];
                        [pluginBundlePaths addObject:pluginPath];
                    }
                    [dirEnum skipDescendents];
                }
            }
        }
    }

    return (NSArray *)pluginBundlePaths;
}

@end
