//
//  NIMainViewController.m
//  NoteIt
//
//  Created by xiaoming han on 15/9/23.
//  Copyright © 2015年 AutoNavi. All rights reserved.
//

#import "NIMainViewController.h"
#import "NIFileManager.h"
#import "NIDataManager.h"
#import "NINote.h"

@interface NIMainViewController ()<NIMenuletDelegate, NIPopoverDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) NSMutableArray<NINote *> *notes;
@property (strong) NSArray<NSString *> *colunmIds;
@property (strong) NSArray<NSString *> *colunmNames;

@end

@implementation NIMainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.

        _colunmIds = @[@"uuid", @"name", @"comment", @"path", @"timestamp"];
        _colunmNames = @[@"UUID", @"文件名", @"注释", @"路径", @"更新时间"];
    }
    
    return self;
}

- (void)initMenuButton
{
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
    self.menulet = [[NIMenulet alloc] initWithFrame:(NSRect){.size={thickness, thickness}}]; /* square item */
    self.menulet.delegate = self;
    [self.item setView:self.menulet];
    [self.item setHighlightMode:NO];
}

- (void)initTableView
{
    
    [self.tableView removeTableColumn:self.tableView.tableColumns.firstObject];
    
    for (int i = 0; i < self.colunmIds.count; ++i)
    {
        NSTableColumn *tc = [[NSTableColumn alloc] init];
        
        tc.editable = NO;
        
        [[tc headerCell ] setStringValue: self.colunmNames[i]];
        tc.identifier = self.colunmIds[i];
        [self.tableView addTableColumn:tc];
    }
    
    self.tableView.headerView.needsDisplay = YES;
    [self.tableView reloadData];
    
    //
    [self.tableView setDoubleAction:@selector(tableDoubleClick:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initMenuButton];
    [self initTableView];
}

#pragma mark - Helpers

- (void)showItemNotExistsAlertWithNote:(NINote *)note
{
    NSString *prompt = [NSString stringWithFormat:@"Item [%@] dose not exists at path [%@]", note.name, note.path];
    
    NILog(@"%@", prompt);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Delete this record"];
    [alert setMessageText:@"Warning"];
    [alert setInformativeText:prompt];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        
//        enum {
//            NSAlertFirstButtonReturn	= 1000,
//            NSAlertSecondButtonReturn	= 1001,
//            NSAlertThirdButtonReturn	= 1002
//        };
        NILog(@"return code %ld",returnCode);
        if (returnCode == NSAlertSecondButtonReturn)
        {
            [self deleteRecordWithNote:note];
        }
    }];
}

- (void)deleteRecordWithNote:(NINote *)note
{
    [[NIDataManager sharedInstance] removeNote:note];
    [self.notes removeObject:note];
    [self.tableView reloadData];
}

#pragma mark - Mouse handling

- (void)tableDoubleClick:(NSTableView *)sender
{
    NSInteger row = [sender clickedRow];
    NINote *note = self.notes[row];
    
    if ([NIFileManager isItemExistsAtPath:note.path])
    {
        [NIFileManager openFinderAtPath:note.path];
    }
    else
    {
        [self showItemNotExistsAlertWithNote:note];
    }
}

- (void)leftButtonHandler
{
    self.active = ! self.active;
    if (self.isActive)
    {
        [self openPopover];
    }
    else
    {
        [self closePopover];
    }
}

- (void)rightButtonHandler
{
    [self leftButtonHandler];
}

#pragma mark - Popover

- (void)closePopover
{
    self.active = NO;
    [self.popoverController.popover performClose:self];
    [self.menulet setNeedsDisplay:YES];
}

- (void)openPopover
{
    if (!self.popoverController)
    {
        self.popoverController = [[NIPopoverController alloc] init];
        self.popoverController.delegate = self;
    }
    
    [self refreshNoteWithPopover:self.popoverController];
    [self.popoverController.popover showRelativeToRect:[self.menulet frame]
                                             ofView:self.menulet
                                      preferredEdge:NSMinYEdge];
}

- (void)refreshNoteWithPopover:(NIPopoverController *)popover
{
    if (popover == nil)
    {
        return;
    }
    
    [[NIFileManager sharedInstance] updateSelection];
    
    NSString *path = [[NIFileManager sharedInstance] currentSelectedItemPath];
    NINote *note = [[NIFileManager sharedInstance] noteWithItemPath:path];
    
    popover.note = note;
}

- (void)savingNote:(NINote *)note
{
    [[NIFileManager sharedInstance] saveNoteToFile:note];
    
    [[NIDataManager sharedInstance] updateNote:note];
}

#pragma mark - NIMenuletDelegate

- (NSString *)activeImageName
{
    return @"menulet-icon-off.png";
}

- (NSString *)inactiveImageName
{
    return @"menulet-icon-on.png";
}

- (void)menuletClicked:(NIButtonType)mouseButton
{
    if (mouseButton == NIButtonTypeLeft)
    {
        [self leftButtonHandler];
    }
    else
    {
        [self rightButtonHandler];
    }
}

#pragma mark - NIPopoverDelegate

- (void)popover:(NIPopoverController *)popover didClickButtonForAction:(NIPopoverAction)action;
{
    NILog(@"did click button for action %@", @(action));
    
    switch (action)
    {
        case NIPopoverActionRefresh:
        {
            [self refreshNoteWithPopover:popover];
            break;
        }
        case NIPopoverActionSave:
        {
            [self savingNote:popover.note];
            [self closePopover];
            break;
        }
        case NIPopoverActionCancel:
        default:
        {
            [self closePopover];
            
            NILog(@"notes :%@", [[NIDataManager sharedInstance] notesWithKeywords:@"test"]);
            break;
        }
    }
}

#pragma mark - search

- (IBAction)searchAction:(id)sender
{
    NSString *text = [self.searchField stringValue];
    
    self.notes = [NSMutableArray arrayWithArray:[[NIDataManager sharedInstance] notesWithKeywords:text]];
    [self.tableView reloadData];
}

#pragma mark - tableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.notes.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *columnId = tableColumn.identifier;
    
    NINote *note = self.notes[row];
    
    NSString *value = [note textValueForKey:columnId];
    
    return value;
}

//- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
//{
// // something wrong here...
//}

@end
