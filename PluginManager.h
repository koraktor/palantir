/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>

@class PluginManager;

#import "SettingsManager.h"


@interface PluginManager : NSObject <NSTableViewDataSource> {

    NSMutableDictionary *activePlugins;
    NSMutableDictionary *availablePlugins;
    NSTabView           *configurationTabView;
    NSMutableArray      *pluginIdentifiers;
    SettingsManager     *settingsManager;

}

@property (nonatomic, retain) NSMutableDictionary *activePlugins;
@property (nonatomic, retain) NSMutableDictionary *availablePlugins;
@property (assign) IBOutlet   NSTabView           *configurationTabView;
@property (nonatomic, retain) NSMutableArray      *pluginIdentifiers;
@property (assign) IBOutlet   SettingsManager     *settingsManager;

- (void)activatePlugin:(NSString *)pluginIdentifier;
- (void)checkPlugins;
- (void)deactivatePlugin:(NSString *)pluginIdentifier;
- (void)findPlugins;
- (BOOL)isPluginActive:(NSString *)pluginIdentifier;
- (void)togglePlugin:(NSString *)pluginIdentifier;

@end
