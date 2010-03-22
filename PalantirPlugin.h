/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>

@class PalantirPlugin;

#import "MAAttachedWindow.h"
#import "PalantirPluggable.h"
#import "PalantirStatusItemView.h"
#import "SettingsManager.h"


@interface PalantirPlugin : NSObject <NSWindowDelegate, PalantirPluggable>  {

    NSView                 *attachedWindowView;
    NSBundle               *bundle;
    NSTabViewItem          *configurationTabViewItem;
    NSView                 *configurationView;
    NSMenu                 *menu;
    NSString               *name;
    NSStatusItem           *statusItem;
    PalantirStatusItemView *statusItemView;

@private
    MAAttachedWindow *attachedWindow;
    NSString         *identifier;
    SettingsManager  *settingsManager;

}

- (id)initWithSettingsManager:(SettingsManager *)settingsManager;
- (NSString *)passwordForService:(NSString *)serviceName andAccount:(NSString *)accountName;
- (void)setAttachedWindowView:(NSView *)aView;
- (void)setPasswordForService:(NSString *)serviceName andAccount:(NSString *)accountName to:(NSString *)aPassword;
- (void)setSettingWithName:(NSString *)aName toValue:(id)aValue;
- (id)settingWithName:(NSString *)aName;
- (void)setStatusItemAlternateImage:(NSImage *)image;
- (void)setStatusItemImage:(NSImage *)image;
- (void)setStatusItemTitle:(NSString *)title;

@property (nonatomic, retain) NSBundle      *bundle;
@property (assign) IBOutlet   NSTabViewItem *configurationTabViewItem;
@property (assign) IBOutlet   NSView        *configurationView;
@property (nonatomic, retain) NSString      *identifier;
@property (nonatomic, retain) NSMenu        *menu;
@property (nonatomic, retain) NSString      *name;
@property (nonatomic, retain) NSStatusItem  *statusItem;

@end
