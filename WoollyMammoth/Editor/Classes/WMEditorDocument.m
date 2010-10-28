//
//  WMEditorDocument.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorDocument.h"

#import "WMEditorPreviewController.h"
#import "WMEditorAssetOutlineController.h"

@implementation WMEditorDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (void) dealloc
{
	[preview release];
	[super dealloc];
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
	
	NSDictionary *testmanifiest = [NSDictionary dictionaryWithObject:@"test" forKey:@"title"];
	NSString *error;
	NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:testmanifiest
														 format:NSPropertyListXMLFormat_v1_0
											   errorDescription:&error];
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

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
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

@end
