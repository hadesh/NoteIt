//
//  NIDataManager.m
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "NIDataManager.h"
#import "NINote.h"
#import <FMDB.h>

#define kNIDBFileName   @"noteit.sqlite"
#define kNITableName    @"t_notes"

#define kNIItemUUID     @"uuid"
#define kNIItemComment  @"comment"
#define kNIItemPath     @"path"
#define kNIItemTime     @"timestamp"

@implementation NIDataManager
{
    FMDatabase *_db;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self openDB];
    }
    
    return self;
}

- (void)dealloc
{
    if (_db)
    {
        [_db close];
        _db = nil;
    }
}

#pragma mark - Helpers

- (NSString *)dbFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:kNIDBFileName];
}

- (void)openDB
{
    _db = [FMDatabase databaseWithPath:[self dbFilePath]];
    if (![_db open])
    {
        NILog(@"database open failed");
    }
    else
    {
        [self createTable];
    }
}

- (void)createTable
{
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ text PRIMARY KEY,%@ text,%@ text NOT NULL,%@ integer);", kNITableName, kNIItemUUID, kNIItemComment, kNIItemPath, kNIItemTime];
    
    if (![_db executeUpdate:sql])
    {
        NILog(@"create table failed");
    }
}

#pragma mark - Interfaces

- (BOOL)isNoteExists:(NINote *)note
{
    NSAssert(_db != nil, @"db handler can not be null");
    
    if (note == nil)
    {
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(%@) AS countNum FROM %@ WHERE %@ = %@", kNIItemUUID, kNITableName, kNIItemUUID, note.uuid];
    
    FMResultSet *rs =[_db executeQuery:sql];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"countNum"];
        return count > 0;
    }
    
    return NO;
}

- (BOOL)updateNote:(NINote *)note
{
    NSAssert(_db != nil, @"db handler can not be null");
    
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, %@, %@, %@) VALUES (?,?,?,?)",  kNITableName, kNIItemUUID, kNIItemComment, kNIItemPath, kNIItemTime];
    return [_db executeUpdate:sql, note.uuid, note.comment, note.path, @(note.timestamp)];
}

- (BOOL)removeNote:(NINote *)note
{
    NSAssert(_db != nil, @"db handler can not be null");
    
    return NO;
}

/// 搜索关键字（comment和path）
- (NSArray *)notesWithKeywords:(NSString *)keywords
{
    NSAssert(_db != nil, @"db handler can not be null");
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ like '%%%@%%' OR %@ like '%%%@%%'", kNITableName, kNIItemComment, keywords, kNIItemPath, keywords];
    FMResultSet *rs = [_db executeQuery:sql];
    
    NSMutableArray *array = [NSMutableArray array];
    while([rs next])
    {
        NINote *obj = [[NINote alloc] init];
        obj.uuid = [rs stringForColumn:kNIItemUUID];
        obj.comment = [rs stringForColumn:kNIItemComment];
        obj.path = [rs stringForColumn:kNIItemPath];
        obj.timestamp = [rs doubleForColumn:kNIItemTime];
        [array addObject: obj];
    }
    
    return array;
}

@end
