/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>


@interface NSApplication (Plugins)

- (NSArray *)applicationPlugInsFolders;
- (NSArray *)pluginBundlesWithSuffix:(NSString *)bundleSuffix;

@end
