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

@property (strong) NSArray<NINote *> *notes;
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
    [self.item setHighlightMode:NO]; /* blue background when clicked ? */
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initMenuButton];
    [self initTableView];
}

#pragma mark - Mouse handling

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
//    NSLog(@"Menulet clicked");
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
    NSLog(@"did click button for action %@", @(action));
    
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
            
            NSLog(@"notes :%@", [[NIDataManager sharedInstance] notesWithKeywords:@"test"]);
            break;
        }
    }
}

#pragma mark - search

- (IBAction)searchAction:(id)sender
{
    NSString *text = [self.searchField stringValue];
//    NSLog(@"%@", text);
    
    self.notes = [[NIDataManager sharedInstance] notesWithKeywords:text];
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
