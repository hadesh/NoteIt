//
//  NIDataManager.h
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NINote;

/// 操作数据库
@interface NIDataManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isNoteExists:(NINote *)note;

/// 更新note，不存在则insert
- (BOOL)updateNote:(NINote *)note;

/// 删除
- (BOOL)removeNote:(NINote *)note;

/// 搜索关键字（注释和path）
- (NSArray<NINote *> *)notesWithKeywords:(NSString *)keywords;

@end
