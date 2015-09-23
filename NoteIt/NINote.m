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

@end
