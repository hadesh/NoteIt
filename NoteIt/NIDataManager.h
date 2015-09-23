//
//  NIDataManager.h
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 操作数据库
@interface NIDataManager : NSObject

+ (instancetype)sharedInstance;

- (void)insertNote:(NSString *)note withItemPath:(NSString *)path;
- (void)updateNote:(NSString *)note withItemPath:(NSString *)path;

- (NSString *)noteForItemAtPath:(NSString *)path;

- (void)deleteNoteForItemAtPath:(NSString *)path;

@end
