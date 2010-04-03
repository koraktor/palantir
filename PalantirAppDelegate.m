/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import "PalantirAppDelegate.h"
#import "PalantirPluggable.h"


@implementation PalantirAppDelegate

@synthesize menu, pluginManager, statusItem, window;

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSImage *statusIcon = [NSImage imageNamed:@"palantir-status.png"];
    [statusIcon setSize:NSMakeSize(16, 16)];
    
    NSImage *alternateStatusIcon = [NSImage imageNamed:@"palantir-status-alternate.png"];
    [alternateStatusIcon setSize:NSMakeSize(16, 16)];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setAlternateImage:alternateStatusIcon];   
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setImage:statusIcon];
    [self.statusItem setMenu:self.menu];
    [self.statusItem retain];
    
    [self.window setReleasedWhenClosed:NO];

    [self.pluginManager initialize];

    for(NSObject<PalantirPluggable> *plugin in [self.pluginManager.activePlugins allValues]) {
        [plugin reschedule];
    }
}

-(IBAction)openConfiguration:(id)sender {
	[self.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

-(IBAction)showAboutPanel:(id)sender {
    NSString *gitVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BundleGitVersion"];
    NSMutableDictionary *aboutDictionary = [[NSMutableDictionary alloc] init];
	if(gitVersion) {
		[aboutDictionary addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:gitVersion, @"Version", nil]];
    }

    [NSApp orderFrontStandardAboutPanelWithOptions:aboutDictionary];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)dealloc {
    [[self.statusItem alternateImage] release];
    [[self.statusItem image] release];
    [self.statusItem dealloc];
    [super dealloc];
}

@end
