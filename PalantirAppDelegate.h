/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>

#import "PluginManager.h"


@interface PalantirAppDelegate : NSObject <NSApplicationDelegate, NSTabViewDelegate> {

    NSMenu        *menu;
    PluginManager *pluginManager;
    NSStatusItem  *statusItem;
    NSWindow      *window;

}

-(IBAction)openConfiguration:(id)sender;
-(IBAction)showAboutPanel:(id)sender;

@property (assign) IBOutlet   NSMenu        *menu;
@property (assign) IBOutlet   PluginManager *pluginManager;
@property (nonatomic, retain) NSStatusItem  *statusItem;
@property (assign) IBOutlet   NSWindow      *window;

@end
