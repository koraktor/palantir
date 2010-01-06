/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>

@class SettingsManager;

#import "PalantirPlugin.h"
#import "PluginManager.h"


@interface SettingsManager : NSObject {

    PluginManager *pluginManager;

}

@property (assign) IBOutlet PluginManager *pluginManager;

- (void)setSettingWithName:(NSString *)aName toValue:(id)aValue forPlugin:(PalantirPlugin *)aPlugin;
- (id)settingWithName:(NSString *)aName forPlugin:(PalantirPlugin *)aPlugin;

@end
