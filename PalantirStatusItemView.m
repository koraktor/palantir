/**
 * This code is free software; you can redistribute it and/or modify it under
 * the terms of the new BSD License.
 *
 * Copyright (c) 2010, Sebastian Staudt
 */

#import "PalantirStatusItemView.h"


@implementation PalantirStatusItemView

- (id)initWithFrame:(NSRect)frame andPlugin:(NSObject<PalantirPluggable> *)aPlugin andStatusItem:(NSStatusItem *)aStatusItem {
    if (self = [super initWithFrame:frame]) {
        plugin = aPlugin;
        statusItem = aStatusItem;
    }

    return self;
}

- (void)drawRect:(NSRect)rect {
    [statusItem setLength:[self frame].size.width];

    if(active) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(rect);
    }

    NSSize msgSize = [self textSize];
    NSRect msgRect = NSMakeRect(0, 2, msgSize.width, msgSize.height);

    if(image != nil) {
        NSSize imageSize = [image size];

        msgRect.origin.x = imageSize.width + 5;
        msgRect.size.width += 5;

        NSRect imageSrcRect = NSMakeRect(0, 0, imageSize.width, imageSize.height);
        [image drawAtPoint:NSMakePoint(3, 3) fromRect:imageSrcRect operation:NSCompositeCopy fraction:1.0];
    }

    if(title != nil) {
        [title drawInRect:msgRect withAttributes:[self textAttributes]];
    }
}

- (NSRect)frame {
    NSSize msgSize = [self textSize];
    if(image == nil) {
        return NSMakeRect(2, 2, msgSize.width, msgSize.height);
    } else {
        NSSize imageSize = [image size];

        if(msgSize.width == 0) {
            return NSMakeRect(0, 0, imageSize.width + 6, imageSize.height);
        } else {
            return NSMakeRect(0, 0, imageSize.width + 9 + msgSize.width, MAX(imageSize.height, msgSize.height));
        }
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSRect frame = [[self window] frame];
    NSPoint pt = NSMakePoint(NSMidX(frame), NSMinY(frame));
    [plugin toggleAttachedWindowAtPoint:pt];
    [self setNeedsDisplay:YES];
}

- (void)setActive:(BOOL)flag {
    active = flag;
    [self setNeedsDisplay:YES];
}

- (void)setAlternateImage:(NSImage *)aImage {
    alternateImage = aImage;
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)aImage {
    image = aImage;
    [self setNeedsDisplay:YES];
}

- (void)setTitle:(NSString *)aTitle {
    title = aTitle;
    [self setNeedsDisplay:YES];
}

- (NSDictionary *)textAttributes {
    NSColor *textColor = [NSColor controlTextColor];
    if(active) {
        textColor = [NSColor selectedMenuItemTextColor];
    }

    NSFont *msgFont = [NSFont menuBarFontOfSize:15.0];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [paraStyle setAlignment:NSCenterTextAlignment];
    [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    NSMutableDictionary *msgAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     msgFont, NSFontAttributeName,
                                     textColor, NSForegroundColorAttributeName,
                                     paraStyle, NSParagraphStyleAttributeName,
                                     nil];
    [paraStyle release];

    return msgAttrs;
}

- (NSSize)textSize {
    if(title == nil){
        return NSMakeSize(0, 0);
    } else {
        return [title sizeWithAttributes:[self textAttributes]];
    }
}

@end
