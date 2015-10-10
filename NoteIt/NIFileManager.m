//
//  NIFileManager.m
//  NoteIt
//
//  Created by xiaoming han on 15/3/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "NIFileManager.h"
#import "NINote.h"
#import <Cocoa/Cocoa.h>

NSString *const AppleScriptForSelectedItems = @"set biglist to {}\n tell application \"Finder\" to set theSeletion to (get selection)\n if (count of theSeletion) > 0 then\n repeat with i from 1 to number of items in theSeletion\n set this_item to POSIX path of (item i of theSeletion as alias)\n copy this_item to end of biglist\n end repeat\n return biglist\n  end if\n  ";


#define kNoteItUUIDKey              @"com.nevernil.noteit:kNoteItUUIDKey"
#define kNoteItLastModifyTimeKey    @"com.nevernil.noteit:kNoteItLastModifyTimeKey"
#define kNoteItCommnetKey           @"com.nevernil.noteit:kNoteItCommnetKey"


//#define kNoteItFinderCommentKey         @"com.apple.metadata:kMDItemFinderComment"
#define kNoteItExtendedAttributesKey    @"NSFileExtendedAttributes"

@interface NIFileManager ()

@property (strong) NSArray *selectedItems;

@end

@implementation NIFileManager

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
        _selectedItems = [NIFileManager selectedItems];
    }
    return self;
}

+ (NSArray *)selectedItems
{
    NSMutableArray * pathArray = [NSMutableArray array];
    NSDictionary* errorMessage = [NSDictionary dictionary];
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:AppleScriptForSelectedItems];
    NSAppleEventDescriptor *result = [script executeAndReturnError:&errorMessage];
    
    NSInteger count = [result numberOfItems];
    for (int i = 1; i <= count; ++i)
    {
        NSAppleEventDescriptor *desc =  [result descriptorAtIndex:i]  ;
        id thisPath = [desc stringValue];
        [pathArray addObject:thisPath];
    }
    
    if (script == nil)
    {
        NILog(@"failed to create script!");
    }
//    
//    for (id key in errorMessage)
//    {
//        NILog(@"key: %@, value: %@", key, [errorMessage objectForKey:key]);
//    }
//    
    return pathArray;
}

//为文件增加一个扩展属性
- (BOOL)setExtendedAttributesWithPath:(NSString *)path key:(NSString *)key value:(NSData *)value
{
    if (key.length == 0)
    {
        return NO;
    }
    
    NSDictionary *extendedAttributes = @{kNoteItExtendedAttributesKey: [NSDictionary dictionaryWithObject:value forKey:key]};
    
    NSError *error = NULL;
    BOOL sucess = [[NSFileManager defaultManager] setAttributes:extendedAttributes
                                                   ofItemAtPath:path error:&error];
    return sucess;
}

//读取文件扩展属性
- (NSData *)extendedAttributesWithPath:(NSString *)path key:(NSString *)key
{
    NSError *error = NULL;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (!attributes)
    {
        return nil;
    }
    NSDictionary *extendedAttributes = [attributes objectForKey:kNoteItExtendedAttributesKey];
    if (!extendedAttributes)
    {
        return nil;
    }
    return [extendedAttributes objectForKey:key];
}

/// 获取更新时间
- (NSTimeInterval)timestampForItemAtPath:(NSString *)path
{
    NSData *data = [self extendedAttributesWithPath:path key:kNoteItLastModifyTimeKey];
    
    NSTimeInterval time = 0;
    
    if (data)
    {
        [data getBytes:&time length:sizeof(NSTimeInterval)];
    }
    
    return time;
}

/// 获取uuid
- (NSString *)uuidForItemAtPath:(NSString *)path
{
    NSData *uuidData = [self extendedAttributesWithPath:path key:kNoteItUUIDKey];
    
    NSString *uuid = [[NSString alloc] initWithData:uuidData encoding:NSUTF8StringEncoding];
    
    return uuid;
}

/// 获取注释
- (NSString *)commentForItemAtPath:(NSString *)path
{
    NSData *data = [self extendedAttributesWithPath:path key:kNoteItCommnetKey];
    
    NSString *comment = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return comment;
}

//TODO: 这个是取系统的注释，暂时不用，研究出怎么写的。
///// 获得注释，这个使用的方法比较特殊。
//- (NSString *)finderCommentForItemAtPath:(NSString *)path
//{
//    if (path.length == 0)
//    {
//        return nil;
//    }
//    
//    NSURL *fileURL = [NSURL fileURLWithPath:path];
//    
//    MDItemRef item = MDItemCreateWithURL(kCFAllocatorDefault, (__bridge CFURLRef)fileURL);
//    NSString *comment = CFBridgingRelease(MDItemCopyAttribute(item, kMDItemFinderComment));
//    
//    return comment;
//}

#pragma mark - Interfaces

/// 更新选中项目
- (void)updateSelection
{
    _selectedItems = [NIFileManager selectedItems];
}

/// 当前选中的项目的路径，若选中多个则返回第一个。
- (NSString *)currentSelectedItemPath
{
    return [_selectedItems firstObject];
}

- (NINote *)noteWithItemPath:(NSString *)path
{
    if (path.length == 0)
    {
        return nil;
    }
 
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (!isExists)
    {
        return nil;
    }
    
    NSString *comment = [self commentForItemAtPath:path];
    NSString *uuid = [self uuidForItemAtPath:path];
    NSTimeInterval timestamp = [self timestampForItemAtPath:path];
    
    NINote *note = [NINote noteWithPath:path uuid:uuid comment:comment timestamp:timestamp];

    return note;
}

- (BOOL)saveNoteToFile:(NINote *)note
{
    if (note == nil || note.path.length == 0)
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExists = [fileManager fileExistsAtPath:note.path isDirectory:&isDirectory];
    
    if (!isExists)
    {
        return NO;
    }

    // 创建uuid
    if (note.uuid.length == 0)
    {
        note.uuid = [[NSUUID UUID] UUIDString];
    }
    note.timestamp = [[NSDate date] timeIntervalSince1970];
    
    [self setExtendedAttributesWithPath:note.path key:kNoteItUUIDKey value:[note.uuid dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSTimeInterval time = note.timestamp;
    NSData *timeData = [NSData dataWithBytes:&time length:sizeof(NSTimeInterval)];
    [self setExtendedAttributesWithPath:note.path key:kNoteItLastModifyTimeKey value:timeData];
    
    [self setExtendedAttributesWithPath:note.path key:kNoteItCommnetKey value:[note.comment dataUsingEncoding:NSUTF8StringEncoding]];

    return YES;
}

#pragma mark - Class Helpers

+ (BOOL)isItemExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    
    return isExists;
}

+ (void)openFinderAtPath:(NSString *)path
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    if ([fileURL isFileURL])
    {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[fileURL]];
    }
}

@end
