//
//  NIMainViewController.h
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NIPopoverController.h"
#import "NIMenulet.h"

@interface NIMainViewController : NSViewController

@property (strong) NIPopoverController *popoverController;
@property (strong) NIMenulet *menulet;
@property (strong) NSStatusItem *item;
@property (assign, getter = isActive) BOOL active;

@end
