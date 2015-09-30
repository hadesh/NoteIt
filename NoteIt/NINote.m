//
//  NINote.m
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "NINote.h"

@implementation NINote

+ (instancetype)noteWithPath:(NSString *)path
                        uuid:(NSString *)uuid
                     comment:(NSString *)comment
                   timestamp:(NSTimeInterval)timestamp
{
    NINote *note = [[NINote alloc] init];
    note.path = path;
    note.uuid = uuid;
    note.comment = comment;
    note.timestamp = timestamp;
    
    return note;
}

- (NSString *)name
{
    return [_path lastPathComponent];
}

- (NSString *)textValueForKey:(NSString *)key
{
    if (key == nil)
    {
        return nil;
    }
    
    id obj = [self valueForKey:key];
    
    if (obj == nil)
    {
        return nil;
    }
    
    NSString *value = nil;
    
    if ([key isEqualToString:@"timestamp"])
    {
        NSDateFormatter *fommatter = [[NSDateFormatter alloc] init];
        [fommatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        value = [fommatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.timestamp]];
    }
    else
    {
        value = (NSString *)obj;
    }
    return value;
}

@end
