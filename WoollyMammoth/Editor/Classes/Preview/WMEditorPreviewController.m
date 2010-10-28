//
//  WMEditorPreviewController.m
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/23/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import "WMEditorPreviewController.h"

@interface WMEditorPreviewController ()
- (NSRect)frameForDevice:(NSDictionary *)device;
@end


@implementation WMEditorPreviewController

@synthesize currentDevice;

- (void)dealloc
{
	[currentDevice release];
	currentDevice = nil;

	[super dealloc];
}


- (void)windowDidLoad;
{

	[outputPopUpButton removeAllItems];

	for (NSDictionary *device in [self devices]) {
		NSString *name = [device objectForKey:@"name"];
		float width = [[device objectForKey:@"width"] floatValue];
		float height = [[device objectForKey:@"height"] floatValue];
		
		NSString *title = [NSString stringWithFormat:@"%@ (%.0f x %.0f)", name, width, height];
		
		[outputPopUpButton addItemWithTitle:title];
	}	
	
	[[self window] setFrame:[self frameForDevice:self.currentDevice] display:YES animate:NO];
}

- (NSRect)frameForDevice:(NSDictionary *)device;
{
	float width = [[device objectForKey:@"width"] floatValue];
	float height = [[device objectForKey:@"height"] floatValue];
	
	NSRect currentWindowFrame = [[self window] frame];
	NSRect currentPreviewFrame = [previewView frame];
	
	return NSMakeRect(currentWindowFrame.origin.x - 0.5 * (width - currentWindowFrame.size.width),
					  currentWindowFrame.origin.y,
					  width,
					  height + currentWindowFrame.size.height - currentPreviewFrame.size.height);

}

- (NSArray *)devices;
{
	if (!devices) {
		NSString *deviceDefinitionsFile = [[NSBundle mainBundle] pathForResource:@"WMDevices" ofType:@"plist"];
		devices = [[NSArray arrayWithContentsOfFile:deviceDefinitionsFile] retain];
		if (devices.count > 0) self.currentDevice = [devices objectAtIndex:0];
	}
	return devices;
}

- (IBAction)selectOutput:(id)sender;
{
	self.currentDevice = [devices objectAtIndex:[(NSPopUpButton *)sender indexOfSelectedItem]];
	[[self window] setFrame:[self frameForDevice:self.currentDevice] display:YES animate:YES];
}

@end
