//
//  NIPopoverController.m
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "NIPopoverController.h"
#import "NINote.h"

@interface NIPopoverController ()<NSTextViewDelegate>

@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSScrollView *commentField;
@property (weak) IBOutlet NSTextField *timeLabel;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *cancelButton;
@property (unsafe_unretained) IBOutlet NSTextView *commentTextView;

@property (strong) NSDateFormatter *fommatter;

@end

@implementation NIPopoverController

- (instancetype)init
{
    self = [super initWithNibName:@"NIPopoverController" bundle:nil];
    NSAssert(self, @"Fatal: error loading nib WOMPopover");
    
    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = self;
    self.fommatter = [[NSDateFormatter alloc] init];
    [self.fommatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.commentTextView setRichText:NO];
    self.commentTextView.delegate = self;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self updatePopoverUIWithNote:_note];
}

- (void)setNote:(NINote *)note
{
    _note = note;
    [self updatePopoverUIWithNote:note];
}

#pragma mark - Helpers

- (void)updatePopoverUIWithNote:(NINote *)note
{
    if (self.note == nil)
    {
        self.titleLabel.stringValue = @"未选中文件";
        self.timeLabel.stringValue = @"----";
        [self.commentTextView.textStorage.mutableString setString:@""];
        self.commentTextView.editable = NO;
    }
    else
    {
        self.titleLabel.stringValue = note.name;
        self.timeLabel.stringValue = [NSString stringWithFormat:@"更新时间 : %@", [self.fommatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:note.timestamp]]];
        [self.commentTextView.textStorage.mutableString setString:note.comment];
        self.commentTextView.editable = YES;
    }
}

#pragma mark - Actions

- (IBAction)refreshAction:(id)sender
{
    NILogMethod();
    [self.delegate popover:self didClickButtonForAction:NIPopoverActionRefresh];
}

- (IBAction)saveAction:(id)sender
{
    NILogMethod();
    [self.delegate popover:self didClickButtonForAction:NIPopoverActionSave];
}

- (IBAction)cancelAction:(id)sender
{
    NILogMethod();
    [self.delegate popover:self didClickButtonForAction:NIPopoverActionCancel];
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(nullable NSString *)replacementString
{
    NSString *originalString = [textView.textStorage.mutableString copy] ?: @"";
    
    NSString *finalString = [originalString stringByReplacingCharactersInRange:affectedCharRange withString:replacementString];
    
    self.note.comment = finalString;
    
    NILog(@"finalString :%@", finalString);
    return YES;
}

@end
