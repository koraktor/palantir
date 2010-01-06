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

    NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
    for(NSObject<PalantirPluggable> *plugin in [self.pluginManager.activePlugins allValues]) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:[plugin actionInterval] target:plugin selector:@selector(action) userInfo:nil repeats:YES];
        [mainRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

-(IBAction)openConfiguration:(id)sender
{
	[self.window makeKeyAndOrderFront:self];
    [self.window display];
}

- (void)dealloc {
    [[self.statusItem alternateImage] release];
    [[self.statusItem image] release];
    [super dealloc];
}

@end
