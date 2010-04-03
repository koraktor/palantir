/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2009-2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>


@protocol PalantirPluggable

@required

- (void)action;
- (NSTimeInterval)actionInterval;
- (NSBundle *)bundle;
- (NSTabViewItem *)configurationTabViewItem;
- (NSMenu *)menu;
- (NSString *)name;
- (void)reschedule;
- (NSStatusItem *)statusItem;
- (NSTimer *)timer;

@optional

- (void)toggleAttachedWindowAtPoint:(NSPoint)aPoint;

@end
