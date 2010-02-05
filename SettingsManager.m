/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import "SettingsManager.h"


@implementation SettingsManager

@synthesize pluginManager;

- (void)setSettingWithName:(NSString *)aName toValue:(id)aValue forPlugin:(PalantirPlugin *)aPlugin {
    NSMutableDictionary *plugins = self.pluginManager.availablePlugins;
    NSMutableDictionary *pluginSettings = [[plugins objectForKey:aPlugin.identifier] objectForKey:@"settings"];
    [pluginSettings setObject:aValue forKey:aName];
    [[NSUserDefaults standardUserDefaults] setObject:plugins forKey:@"plugins"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)settingWithName:(NSString *)aName forPlugin:(PalantirPlugin *)aPlugin {
    return [[[self.pluginManager.availablePlugins objectForKey:aPlugin.identifier]
                                                  objectForKey:@"settings"]
                                                  objectForKey:aName];
}

@end
