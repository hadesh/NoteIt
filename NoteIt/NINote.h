//
//  NINote.h
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NINote : NSObject

@property (copy, readonly) NSString *name;
@property (copy) NSString *uuid;
@property (copy) NSString *comment;
@property (copy) NSString *path;
@property (assign) NSTimeInterval timestamp;

+ (instancetype)noteWithPath:(NSString *)path
                        uuid:(NSString *)uuid
                     comment:(NSString *)comment
                   timestamp:(NSTimeInterval)timestamp;
@end
