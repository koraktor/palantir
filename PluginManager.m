/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import "NSApplication+Plugins.h"
#import "PalantirPluggable.h"
#import "PluginManager.h"
#import "SettingsManager.h"

@implementation PluginManager

@synthesize activePlugins, availablePlugins, configurationTabView,
            pluginIdentifiers, settingsManager;

- (void)initialize {
    self.activePlugins = [NSMutableDictionary dictionary];
    self.availablePlugins = [[NSUserDefaults standardUserDefaults] objectForKey:@"plugins"];
    if(self.availablePlugins == nil) {
        self.availablePlugins = [NSMutableDictionary dictionaryWithCapacity:10];
    }

    [self checkPlugins];
    [self findPlugins];

    self.pluginIdentifiers = [NSMutableArray arrayWithArray:[self.availablePlugins allKeys]];

    [[NSUserDefaults standardUserDefaults] setObject:self.availablePlugins
                                           forKey:@"plugins"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)activatePlugin:(NSString *)pluginIdentifier {
    NSDictionary *pluginDictionary = [self.availablePlugins objectForKey:pluginIdentifier];
    NSBundle *pluginBundle = [NSBundle bundleWithPath:[pluginDictionary objectForKey:@"path"]];
    NSObject<PalantirPluggable> *plugin = [[[pluginBundle principalClass] alloc] initWithSettingsManager:self.settingsManager];
    NSNib *pluginNib = [[NSNib alloc] initWithNibNamed:@"Configuration" bundle:pluginBundle];
    [pluginNib instantiateNibWithOwner:plugin topLevelObjects:nil];
    [pluginNib release];
    [pluginDictionary setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
    [self.activePlugins setValue:plugin forKey:pluginIdentifier];
    [self.configurationTabView addTabViewItem:[plugin configurationTabViewItem]];
}

- (void)checkPlugins {
    for(NSString *pluginIdentifier in [self.availablePlugins allKeys]) {
        NSDictionary *pluginDictionary = [self.availablePlugins objectForKey:pluginIdentifier];
        NSBundle *pluginBundle = [NSBundle bundleWithPath:[pluginDictionary objectForKey:@"path"]];
        if(pluginBundle == nil) {
            [self.availablePlugins removeObjectForKey:pluginIdentifier];
        }
    }
}

- (void)deactivatePlugin:(NSString *)pluginIdentifier {
    NSDictionary *pluginDictionary = [self.availablePlugins objectForKey:pluginIdentifier];
    NSObject<PalantirPluggable> *plugin = [self.activePlugins objectForKey:pluginIdentifier];
    [self.configurationTabView removeTabViewItem:[plugin configurationTabViewItem]];
    [plugin dealloc];
    [pluginDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"active"];
    [self.activePlugins setValue:nil forKey:pluginIdentifier];
}

- (void)findPlugins {
    NSError *loadError;
	NSArray *pluginBundlePaths = [NSApp pluginBundlesWithSuffix:@"pal"];
	for(NSString *pluginBundlePath in pluginBundlePaths) {
        NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginBundlePath];

		if(pluginBundle != nil) {
            if([pluginBundle loadAndReturnError:&loadError]) {
                Class pluginClass = [pluginBundle principalClass];
                if([pluginClass conformsToProtocol:@protocol(PalantirPluggable)]) {
                    NSString *pluginIdentifier = [pluginBundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
                    if(![[self.availablePlugins allKeys] containsObject:pluginIdentifier]) {
                        NSMutableDictionary *pluginDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                 [NSNumber numberWithBool:NO], @"active",
                                                                 pluginIdentifier, @"identifier",
                                                                 [pluginBundle objectForInfoDictionaryKey:@"CFBundleName"], @"name",
                                                                 pluginBundlePath, @"path",
                                                                 [NSMutableDictionary dictionary], @"settings",
                                                                 [pluginBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"], @"version",
                                                                 nil];
                        [self.availablePlugins setValue:pluginDictionary forKey:pluginIdentifier];
                        [self.pluginIdentifiers addObject:pluginIdentifier];
                    } else {
                        if([[[self.availablePlugins objectForKey:pluginIdentifier] objectForKey:@"active"] boolValue]) {
                            [self activatePlugin:pluginIdentifier];
                        }
                    }
                }
            } else {
                NSLog(@"%@", loadError);
            }
		}
	}
}

- (BOOL)isPluginActive:(NSString *)pluginIdentifier {
    return [[[self.availablePlugins objectForKey:pluginIdentifier] objectForKey:@"active"] boolValue];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.availablePlugins count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString* pluginIdentifier = [self.pluginIdentifiers objectAtIndex:rowIndex];
    if([[aTableColumn identifier] isEqualToString:@"active"]) {
        return [NSNumber numberWithBool:[self isPluginActive:pluginIdentifier]];
    } else if ([[aTableColumn identifier] isEqualToString:@"name"]) {
        NSString *pluginName = [[self.availablePlugins objectForKey:pluginIdentifier] objectForKey:@"name"];
        NSString *pluginVersion = [[self.availablePlugins objectForKey:pluginIdentifier] objectForKey:@"version"];
        pluginName = [NSString stringWithFormat:@"<span style=\"font-family: sans-serif\"><strong>%@</strong><br />Version: %@</span>", pluginName, pluginVersion];
        return [[NSMutableAttributedString alloc] initWithHTML:[pluginName dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:NULL];
    } else {
        return nil;
    }
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    [self togglePlugin:[self.pluginIdentifiers objectAtIndex:rowIndex]];
}

- (void)togglePlugin:(NSString *)pluginIdentifier {
    if([self isPluginActive:pluginIdentifier]) {
        [self deactivatePlugin:pluginIdentifier];
    } else {
        [self activatePlugin:pluginIdentifier];
    }

    [[NSUserDefaults standardUserDefaults] setObject:self.availablePlugins
                                           forKey:@"plugins"];
}

@end
