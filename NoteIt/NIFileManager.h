//
//  NIFileManager.h
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NINote;
@interface NIFileManager : NSObject

+ (instancetype)sharedInstance;

/// 更新选中项目
- (void)updateSelection;

/// 当前选中的项目的路径，若选中多个则返回第一个。
- (NSString *)currentSelectedItemPath;

- (NINote *)noteWithItemPath:(NSString *)path;

/// 保存note到文件，如果路径有问题则返回NO。
- (BOOL)saveNoteToFile:(NINote *)note;

@end
