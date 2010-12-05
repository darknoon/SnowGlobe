//
//  WMEditorAssetOutlineController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorSidebarOutlineController.h"

#import "WMEditorSidebarItem.h"
#import "WMEditorAsset.h"
#import "WMEditorSidebarAssetItem.h"
#import "WMEditorDocument.h"
#import "WMEditorAssetManager.h"

NSString *WMEditorSidebarOutlineControllerSelectionChangedNotification = @"WMEditorSidebarOutlineControllerSelectionChanged";


@interface WMEditorSidebarOutlineController ()
@property (nonatomic, copy) NSArray *items;
- (void)refreshItems;
@end


@implementation WMEditorSidebarOutlineController

@synthesize outlineView;
@synthesize document;
@synthesize items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
		
	//TODO: make this document-specific
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshItems) name:WMEditorAssetManagerAssetsChangedNotification object:nil];
	
	return self;
}

- (void)dealloc;
{
	[items release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[outlineView release];
	outlineView = nil;

	[super dealloc];
}

- (void)awakeFromNib;
{
	[super awakeFromNib];
	[self refreshItems];
	[outlineView expandItem:nil expandChildren:YES];
}

- (void)refreshItems;
{
	NSMutableArray *mutableItems = [NSMutableArray array];
	
	WMEditorSidebarItem *assetsItem = [[[WMEditorSidebarItem alloc] init] autorelease];
	assetsItem.name = @"Assets";
	
	for (WMEditorAsset *asset in document.assetManager.assets) {
		WMEditorSidebarAssetItem *assetItem = [[[WMEditorSidebarAssetItem alloc] init] autorelease];
		assetItem.asset = asset;
		[assetsItem insertChild: assetItem];
	}
	
	[mutableItems addObject:assetsItem];
	
	self.items = mutableItems;
	[outlineView reloadData];
}


#pragma mark -
#pragma mark Outline View Data Source

- (id)outlineView:(NSOutlineView *)inOutlineView child:(NSInteger)index ofItem:(id)inItem;
{
	if (!inItem) {
		return [items objectAtIndex:index];
	}
	WMEditorSidebarItem *item = inItem;
	return [item.children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)inOutlineView isItemExpandable:(id)inItem;
{
	if (!inItem) {
		return YES;
	}
	return [self outlineView:inOutlineView numberOfChildrenOfItem:inItem] > 0;
}

- (NSInteger)outlineView:(NSOutlineView *)inOutlineView numberOfChildrenOfItem:(id)inItem;
{
	if (!inItem) {
		return [items count];
	}
	WMEditorSidebarItem *item = inItem;
	return item.children.count;
}

- (id)outlineView:(NSOutlineView *)inOutlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)inItem;
{
	WMEditorSidebarItem *item = inItem;
	return item.name;
}

#pragma mark -
#pragma mark Outline View Delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	NSIndexSet *selectedIndices = [outlineView selectedRowIndexes];
	if ([selectedIndices count] == 1) {
		[document inspectSidebarItem:[outlineView itemAtRow:[selectedIndices firstIndex]]];
	} else {
		[document inspectSidebarItem:nil];
	}
}

#pragma mark -

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row;
{
	return YES;
}




@end
