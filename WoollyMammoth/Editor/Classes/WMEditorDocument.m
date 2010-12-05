//
//  WMEditorDocument.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorDocument.h"

#import "WMEditorPreviewController.h"
#import "WMEditorSidebarOutlineController.h"

#import "WMEditorAsset.h"
#import "WMBuild.h"
#import "WMBuildManager.h"
#import "WMEditorSidebarAssetItem.h"
#import "WMEditorAssetManager.h"

#import "WMEditorAssetViewController.h"
#import "WMEditorShaderViewController.h"

@implementation WMEditorDocument

@synthesize sidebarViewController;
@synthesize itemEditorController;
@synthesize assetManager;

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
		buildManager = [[WMBuildManager alloc] init];
		[buildManager startBuildServer];
		
		// NSMutableArray *testAssets = [NSMutableArray array];
		
		// WMEditorAsset *asset = [[[WMEditorAsset alloc] init] autorelease];
		// asset.resourceName = @"scene";
		// asset.relativePath = @"scene.plist";
		// asset.assetType = WMEditorAssetTypeScene;
		
		// [testAssets addObject:asset];
		
		// self.assets = testAssets;	
		
		self.assetManager = [[WMEditorAssetManager alloc] init];
				
    }
    return self;
}


- (void)setFileURL:(NSURL *)inAbsoluteURL;
{
	[super setFileURL:inAbsoluteURL];
	
	NSString *builtProductName = [[[[inAbsoluteURL path] lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"wm"];
	buildManager.outputDirectory = [[[[inAbsoluteURL path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"build"] stringByAppendingPathComponent:builtProductName];
	assetManager.assetBasePath = [[inAbsoluteURL path] stringByAppendingPathComponent:@"assets"];
}

- (void) dealloc
{
	[preview release];
	[assetManager release];

	[itemEditorController release];
	[sidebarViewController release];

	[super dealloc];
}


// - (void)setSelectedSidebarIndexPaths:(NSSet *)inSelectedSidebarIndexPaths {
	// [self willChangeValueForKey:@"selectedSidebarIndexPaths"];
	
	// if (selectedSidebarIndexPaths == inSelectedSidebarIndexPaths) return;
	// [selectedSidebarIndexPaths release];
	// selectedSidebarIndexPaths = [inSelectedSidebarIndexPaths retain];

	// //TODO: do this betetr
	// NSArray *selectedObjects = [sidebarTreeController selectedObjects];
	
	// self.editingSidebarItem = selectedObjects.count > 0 ? [selectedObjects objectAtIndex:0] : nil;

	// [self didChangeValueForKey:@"selectedSidebarIndexPaths"];
// }


- (NSViewController *)viewControllerForAsset:(WMEditorAsset *)inAsset;
{
	WMEditorAssetViewController *assetViewController = nil;
	
	if ([inAsset.assetType isEqualToString:WMEditorAssetTypeShader]) {
		assetViewController = [[[WMEditorShaderViewController alloc] initWithNibName:@"WMEditorShaderViewController" bundle:nil] autorelease];
	} else {
		assetViewController = [[[WMEditorAssetViewController alloc] initWithNibName:@"WMEditorAssetViewController" bundle:nil] autorelease];
	}
	
	assetViewController.document = self;
	assetViewController.item = inAsset;
	return assetViewController;
}



- (void)inspectSidebarItem:(WMEditorSidebarItem *)editingSidebarItem;
{
	if ([editingSidebarItem isKindOfClass:[WMEditorSidebarAssetItem class]]) {
		WMEditorAsset *asset = [(WMEditorSidebarAssetItem *)editingSidebarItem asset];
		
		self.itemEditorController = [self viewControllerForAsset:asset];
	} else {
		self.itemEditorController = nil;
	}

}

- (void)setItemEditorController:(NSViewController *)inItemEditorController {
	if (itemEditorController == inItemEditorController) return;
	
	//Get rid of the current view
	[itemEditorController.view removeFromSuperview];
	
	[itemEditorController release];
	itemEditorController = [inItemEditorController retain];
	
	if (itemEditorController) {
		[contentView addSubview:itemEditorController.view];
		itemEditorController.view.frame = contentView.bounds;
	}
}



- (void)awakeFromNib;
{
	[super awakeFromNib];
}



- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"WMEditorDocument";
}

// - (void)makeWindowControllers;
// {
	// WMEditorMainWindowController *mainWindowController
// }

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError;
{
	NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	
	NSData *xmlData = [assetManager manifestDataWithDocumentTitle:[self displayName]];
	if(xmlData) {
		[fileWrapper addRegularFileWithContents:xmlData preferredFilename:@"manifest.plist"];
	} else {
		return nil;
	}

	return fileWrapper;
}

- (NSDictionary *)fileAttributesToWriteToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)outError;
{
	NSDictionary *sup = [super fileAttributesToWriteToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:outError];
	return sup;
}


- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError;
{
	
	NSFileWrapper *manifestWrapper = [[fileWrapper fileWrappers] objectForKey:@"manifest.plist"];
	
	if (!manifestWrapper || ![manifestWrapper isRegularFile]) {
		//TODO: return error here
		return NO;
	}
	
	NSData *manifestContents = [manifestWrapper regularFileContents];
	if (![assetManager loadManifestFromData:manifestContents error:outError]) {
		return NO;
	}
			
	return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)showPreview:(id)sender;
{
	if (!preview) {	
		preview = [[WMEditorPreviewController alloc] initWithWindowNibName:@"WMEditorPreviewController"];
		[self addWindowController:preview];
	}
	[preview showWindow:nil];
}

- (IBAction)build:(id)sender;
{
	[buildManager buildWithAssetManager:assetManager];
}

@end
