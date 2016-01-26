//
//  AppDelegate.m
//  NoteIt
//
//  Created by xiaoming han on 15/3/24.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "AppDelegate.h"
#import "NIMainViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) NIMainViewController *controller;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self.window setTitle:@"NoteIt"];
    [self.window setReleasedWhenClosed:NO];
    [self.window setMinSize:NSMakeSize(610, 400)];
    
//    [self.window close];
    
    self.controller = [[NIMainViewController alloc] initWithNibName:@"NIMainViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.controller.view];
    self.controller.view.frame = ((NSView*)self.window.contentView).bounds;
    
    [self.window setContentSize:self.window.minSize];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self.window setIsVisible:YES];
    return YES;
}

@end
