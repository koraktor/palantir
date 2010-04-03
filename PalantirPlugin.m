/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import "PalantirPlugin.h"
#import "PalantirStatusItemView.h"


@implementation PalantirPlugin

@synthesize bundle, configurationTabViewItem, configurationView, identifier,
            menu, name, statusItem, timer;

- (id)initWithSettingsManager:(SettingsManager *)aSettingsManager {
    self.bundle        = [NSBundle bundleForClass:[self class]];
    self.identifier    = [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    self.name          = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    attachedWindowView = nil;
    settingsManager    = aSettingsManager;

    return self;
}

- (void)action {
    @throw [NSException exceptionWithName:@"Not implemented"
                        reason:@"This method has to be implemented in a subclass"
                        userInfo:nil];
}

- (NSTimeInterval)actionInterval {
    return 600;
}

- (void)awakeFromNib {
    self.configurationTabViewItem = [[NSTabViewItem alloc] init];
    [self.configurationTabViewItem setLabel:self.name];
    [self.configurationTabViewItem setView:self.configurationView];

    self.menu = [[NSMenu alloc] init];

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:self.menu];

    [self.statusItem retain];
}

- (NSString *)passwordForService:(NSString *)serviceName andAccount:(NSString *)accountName {
    char *passwordData;
    UInt32 passwordLength;
    SecKeychainFindGenericPassword(NULL,
                                   [serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                   [serviceName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                   [accountName cStringUsingEncoding:NSUTF8StringEncoding],
                                   &passwordLength,
                                   (void **)&passwordData,
                                   NULL);

    return [[[NSString alloc] initWithCStringNoCopy:passwordData length:passwordLength freeWhenDone:YES] autorelease];
}

- (void)reschedule {
    if(timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:[self actionInterval] target:self selector:@selector(action) userInfo:nil repeats:YES];
}

- (void)setAttachedWindowView:(NSView *)aView {
    attachedWindowView = aView;

    if(attachedWindowView == nil) {
        [attachedWindow orderOut:self];
        [attachedWindow release];
        attachedWindow = nil;

        [self.statusItem setMenu:self.menu];
        [self.statusItem setView:nil];
    } else {
        NSRect viewFrame = NSMakeRect(0, 0, 50, [[NSStatusBar systemStatusBar] thickness]);
        statusItemView = [[PalantirStatusItemView alloc] initWithFrame:viewFrame andPlugin:self andStatusItem:statusItem];

        [statusItemView setAlternateImage:[self.statusItem alternateImage]];
        [statusItemView setImage:[self.statusItem image]];
        [statusItemView setTitle:[self.statusItem title]];

        [self.statusItem setMenu:nil];
        [self.statusItem setView:statusItemView];
    }
}

- (void)setPasswordForService:(NSString *)serviceName andAccount:(NSString *)accountName to:(NSString *)aPassword {
    SecKeychainItemRef keychainItemRef;
    OSStatus result = SecKeychainFindGenericPassword(NULL,
                                   [serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                   [serviceName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                   [accountName cStringUsingEncoding:NSUTF8StringEncoding],
                                   0,
                                   NULL,
                                   &keychainItemRef);
    if(result == errSecItemNotFound) {
        SecKeychainAddGenericPassword(NULL,
                                      [serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                      [serviceName cStringUsingEncoding:NSUTF8StringEncoding],
                                      [accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                      [accountName cStringUsingEncoding:NSUTF8StringEncoding],
                                      [aPassword lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                      [aPassword cStringUsingEncoding:NSUTF8StringEncoding],
                                      NULL);
    } else {
        SecKeychainItemModifyAttributesAndData(keychainItemRef,
                                               NULL,
                                               [aPassword lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                               [aPassword cStringUsingEncoding:NSUTF8StringEncoding]);
        CFRelease(keychainItemRef);
    }
}

- (void)setSettingWithName:(NSString *)aName toValue:(id)aValue {
    [settingsManager setSettingWithName:aName toValue:aValue forPlugin:self];
}

- (id)settingWithName:(NSString *)aName {
    return [settingsManager settingWithName:aName forPlugin:self];
}

- (void)setStatusItemImage:(NSImage *)image {
    if(attachedWindowView == nil) {
        [self.statusItem setImage:image];
    } else {
        [statusItemView setImage:image];
    }
}

- (void)setStatusItemAlternateImage:(NSImage *)image {
    if(attachedWindowView == nil) {
        [self.statusItem setAlternateImage:image];
    } else {
        [statusItemView setAlternateImage:image];
    }
}

- (void)setStatusItemTitle:(NSString *)title {
    if(attachedWindowView == nil) {
        [self.statusItem setTitle:title];
    } else {
        [statusItemView setTitle:title];
    }
}

- (void)toggleAttachedWindowAtPoint:(NSPoint)aPoint {
    if (attachedWindow == nil) {
        [NSApp activateIgnoringOtherApps:YES];
        attachedWindow = [[MAAttachedWindow alloc] initWithView:attachedWindowView
                                                attachedToPoint:aPoint
                                                       inWindow:nil
                                                         onSide:MAPositionBottom
                                                     atDistance:5.0];
        [attachedWindow orderFrontRegardless];
        [attachedWindow setDelegate:self];
        [attachedWindow makeKeyWindow];
    } else {
        [attachedWindow resignKeyWindow];
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [statusItemView setActive:YES];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [statusItemView setActive:NO];

    if(attachedWindow != nil) {
        [attachedWindow release];
        attachedWindow = nil;
    }
}

- (void)dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    [self.statusItem release];
    [self.statusItem dealloc];

    if(attachedWindow != nil) {
        [attachedWindowView release];
        [attachedWindowView dealloc];
    }

    if(statusItemView != nil) {
        [statusItemView release];
        [statusItemView dealloc];
    }

    if(timer != nil) {
        [timer invalidate];
        [timer release];
    }

    [super dealloc];
}

@end
