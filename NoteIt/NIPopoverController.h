//
//  NIPopoverController.h
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NIPopoverController;
@class NINote;

typedef NS_ENUM(NSInteger, NIPopoverAction)
{
    NIPopoverActionRefresh,
    NIPopoverActionSave,
    NIPopoverActionCancel,
};

@protocol NIPopoverDelegate <NSObject>

- (void)popover:(NIPopoverController *)popover didClickButtonForAction:(NIPopoverAction)action;

@end

@interface NIPopoverController : NSViewController

@property (weak) id<NIPopoverDelegate> delegate;
@property (strong) NSPopover *popover;
@property (nonatomic, strong) NINote *note;

@end
