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
    [self.window close];
    
    self.controller = [[NIMainViewController alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
