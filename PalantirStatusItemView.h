/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import <Cocoa/Cocoa.h>

#import "PalantirPluggable.h"


@interface PalantirStatusItemView : NSView {

    NSImage                     *alternateImage;
    NSObject<PalantirPluggable> *plugin;
    BOOL                         active;
    NSImage                     *image;
    NSStatusItem                *statusItem;
    NSString                    *title;

}

- (id)initWithFrame:(NSRect)frame andPlugin:(NSObject<PalantirPluggable> *)aPlugin andStatusItem:(NSStatusItem *)aStatusItem;;
- (void)setActive:(BOOL)flag;
- (void)setAlternateImage:(NSImage *)aImage;
- (void)setImage:(NSImage *)aImage;
- (void)setTitle:(NSString *)aTitle;
- (NSDictionary *)textAttributes;
- (NSSize)textSize;

@end
