//
//  NIMenulet.h
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, NIButtonType)
{
    NIButtonTypeUnknown = 0,
    NIButtonTypeLeft = NSLeftMouseDown,
    NIButtonTypeRight = NSRightMouseDown,
    NIButtonTypeOther
};

@protocol NIMenuletDelegate <NSObject>

- (NSString *)activeImageName;
- (NSString *)inactiveImageName;
- (BOOL)isActive;
- (void)menuletClicked:(NIButtonType)mouseButton;

@end

@interface NIMenulet : NSView

@property (nonatomic, weak) id<NIMenuletDelegate> delegate;

@end
