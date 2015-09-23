//
//  NIDataManager.m
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "NIDataManager.h"
#include <sqlite3.h>

#define kNIDBFileName   @"noteit.sqlite"
#define kNITableName    @"t_notes"
#define kNIItemPath     @"path"
#define kNIItemNote     @"note"

@implementation NIDataManager
{
    sqlite3 *_db;
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
        sqlite3_close(_db);
        _db = NULL;
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
    const char *fileName = [self dbFilePath].UTF8String;
    
    int result = sqlite3_open(fileName, &_db);
    if (result == SQLITE_OK)
    {
        NILog(@"open db ok: %s", fileName);
        [self createTable];
    }
    else
    {
        NILog(@"open db failed");
    }
}

- (void)createTable
{
    if (_db == NULL)
    {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer PRIMARY KEY AUTOINCREMENT,%@ text NOT NULL,%@ text NOT NULL);", kNITableName, kNIItemPath, kNIItemNote];
    
    char *errmsg = NULL;
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if (result == SQLITE_OK)
    {
        NILog(@"create table ok");
    }
    else
    {
        NILog(@"create table failed: %s",errmsg);
    }
}

- (BOOL)itemExistsAtPath:(NSString *)path
{
    return YES;
}

#pragma mark - Interfaces

- (void)insertNote:(NSString *)note withItemPath:(NSString *)path
{
    NSAssert(_db != NULL, @"db handler can not be null");
    
    if (note.length == 0 || path.length == 0 || ![self itemExistsAtPath:path])
    {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@) VALUES ('%@','%@');",kNITableName, kNIItemPath, kNIItemNote, path, note];
    
    char *errmsg = NULL;
    sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    
    if (errmsg)
    {
        NILog(@"insert failed: %s",errmsg);
    }
    else
    {
        NILog(@"inser ok");
    }
}

- (void)updateNote:(NSString *)note withItemPath:(NSString *)path
{
    NSAssert(_db != NULL, @"db handler can not be null");
}

- (NSString *)noteForItemAtPath:(NSString *)path
{
    NSAssert(_db != NULL, @"db handler can not be null");
    return nil;
}

- (void)deleteNoteForItemAtPath:(NSString *)path
{
    NSAssert(_db != NULL, @"db handler can not be null");
}

@end
