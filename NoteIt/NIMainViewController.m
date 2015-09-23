//
//  NIMainViewController.m
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "NIMainViewController.h"
#import "NIFileManager.h"

@interface NIMainViewController ()<NIMenuletDelegate, NIPopoverDelegate>

@end

@implementation NIMainViewController
- (instancetype)init
{
    self = [super init];
    NSAssert(self, @"Fatal: error creating WOMController");
    
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
    self.menulet = [[NIMenulet alloc] initWithFrame:(NSRect){.size={thickness, thickness}}]; /* square item */
    self.menulet.delegate = self;
    [self.item setView:self.menulet];
    [self.item setHighlightMode:NO]; /* blue background when clicked ? */
    
    return self;
}

#pragma mark - Mouse handling

- (void)leftButtonHandler
{
    self.active = ! self.active;
    if (self.isActive)
    {
        [self openPopover];
    }
    else
    {
        [self closePopover];
    }
}

- (void)rightButtonHandler
{
    [self leftButtonHandler];
}

#pragma mark - Popover

- (void)closePopover
{
    self.active = NO;
    [self.popoverController.popover performClose:self];
    [self.menulet setNeedsDisplay:YES];
}

- (void)openPopover
{
    if (!self.popoverController)
    {
        self.popoverController = [[NIPopoverController alloc] init];
        self.popoverController.delegate = self;
    }
    
    [self refreshNoteWithPopover:self.popoverController];
    [self.popoverController.popover showRelativeToRect:[self.menulet frame]
                                             ofView:self.menulet
                                      preferredEdge:NSMinYEdge];
}

- (void)refreshNoteWithPopover:(NIPopoverController *)popover
{
    if (popover == nil)
    {
        return;
    }
    
    [[NIFileManager sharedInstance] updateSelection];
    
    NSString *path = [[NIFileManager sharedInstance] currentSelectedItemPath];
    NINote *note = [[NIFileManager sharedInstance] noteWithItemPath:path];
    
    popover.note = note;
}

#pragma mark - NIMenuletDelegate

- (NSString *)activeImageName
{
    return @"menulet-icon-off.png";
}

- (NSString *)inactiveImageName
{
    return @"menulet-icon-on.png";
}

- (void)menuletClicked:(NIButtonType)mouseButton
{
//    NSLog(@"Menulet clicked");
    if (mouseButton == NIButtonTypeLeft)
    {
        [self leftButtonHandler];
    }
    else
    {
        [self rightButtonHandler];
    }
}

#pragma mark - NIPopoverDelegate

- (void)popover:(NIPopoverController *)popover didClickButtonForAction:(NIPopoverAction)action;
{
    NSLog(@"did click button for action %@", @(action));
    
    switch (action)
    {
        case NIPopoverActionRefresh:
        {
            [self refreshNoteWithPopover:popover];
            break;
        }
        case NIPopoverActionSave:
        {
            [[NIFileManager sharedInstance] saveNoteToFile:popover.note];
            [self closePopover];
            break;
        }
        case NIPopoverActionCancel:
        default:
        {
            [self closePopover];
            break;
        }
    }
}
@end
