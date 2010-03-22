/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import "PalantirPlugin.h"


@implementation PalantirPlugin

@synthesize bundle, configurationTabViewItem, configurationView, identifier,
            menu, name, statusItem;

- (id)initWithSettingsManager:(SettingsManager *)aSettingsManager {
    self.bundle     = [NSBundle bundleForClass:[self class]];
    self.identifier = [self.bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    self.name       = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    settingsManager = aSettingsManager;
    
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

- (void)dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    [self.statusItem release];
    [self.statusItem dealloc];
    
    [super dealloc];
}

@end
