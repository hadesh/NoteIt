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

/// note 是否存在于数据库
- (BOOL)isNoteExists:(NINote *)note;

/// 更新note，不存在则insert
- (BOOL)updateNote:(NINote *)note;

/// 删除
- (BOOL)removeNote:(NINote *)note;

/**
 *  搜索note 如果keywords为空，则显示所有
 *
 *  @param keywords 关键字
 *
 *  @return note数组
 */
- (NSArray<NINote *> *)notesWithKeywords:(NSString *)keywords;

@end
