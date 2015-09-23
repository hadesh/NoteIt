//
//  NIMenulet.m
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "NIMenulet.h"

#define kNIMenuletActiveKVOKeyPath  @"kNIMenuletActiveKVOKeyPath"

static void *kNIMenuletActiveChangedKVO = &kNIMenuletActiveChangedKVO;

@interface NIMenulet ()

@end

@implementation NIMenulet

- (void)setDelegate:(id<NIMenuletDelegate>)newDelegate
{
    if (newDelegate == _delegate)
    {
        return;
    }
    
    [((NSObject *)_delegate) removeObserver:self forKeyPath:kNIMenuletActiveKVOKeyPath context:kNIMenuletActiveChangedKVO];
    
    [(NSObject *)newDelegate addObserver:self forKeyPath:kNIMenuletActiveKVOKeyPath options:NSKeyValueObservingOptionNew context:kNIMenuletActiveChangedKVO];
    
    _delegate = newDelegate;
}

- (void)drawRect:(NSRect)rect
{
#if WITHOUT_IMAGE
    rect = CGRectInset(rect, 2, 2);
    if ([self.delegate isActive]) {
        [[NSColor selectedMenuItemColor] set]; /* blueish */
    } else {
        [[NSColor textColor] set]; /* blackish */
    }
    NSRectFill(rect);
#else
    NSImage *menuletIcon;
    [[NSColor clearColor] set];
    if ([self.delegate isActive]) {
        menuletIcon = [NSImage imageNamed:[self.delegate activeImageName]];
    } else {
        menuletIcon = [NSImage imageNamed:[self.delegate inactiveImageName]];
    }
#if WITH_ANIMATION
    static int n = 0;
    if ([self.delegate isActive]) {
        n++;
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextTranslateCTM(ctx, rect.size.width / 2, rect.size.height / 2);
        CGContextRotateCTM(ctx, M_PI/8 * n);
        rect.origin.x -= rect.size.width / 2;
        rect.origin.y -= rect.size.height / 2;
    } else {
        n = 0;
    }
#endif
    [menuletIcon drawInRect:NSInsetRect(rect, 2, 2) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
#endif
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self anyMouseDown:theEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    [self anyMouseDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self anyMouseDown:theEvent];
}

- (void)anyMouseDown:(NSEvent *)event
{
//    NSLog(@"Mouse down event: %@", event);
    NIButtonType button = NIButtonTypeUnknown;
    switch ([event type])
    {
        case NSLeftMouseDown:
            button = NIButtonTypeLeft;
            break;
        case NSRightMouseDown:
            button = NIButtonTypeRight;
            break;
        default:
            button = NIButtonTypeOther;
            break;
    }
    [self.delegate menuletClicked:button];
    [self setNeedsDisplay:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kNIMenuletActiveChangedKVO)
    {
        [self setNeedsDisplay:YES];
    }
}

@end
