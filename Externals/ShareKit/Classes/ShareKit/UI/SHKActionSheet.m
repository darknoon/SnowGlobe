//
//  SHKActionSheet.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/10/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKActionSheet.h"
#import "SHK.h"
#import "SHKSharer.h"
#import "SHKCustomShareMenu.h"
#import <Foundation/NSObjCRuntime.h>

@implementation SHKActionSheet

@synthesize item, sharers;

- (void)dealloc
{
	[item release];
	[sharers release];
	[super dealloc];
}

+ (SHKActionSheet *)actionSheetForType:(SHKShareType)inType sharers:(NSArray *)inSharers showMoreButton:(BOOL)inShowMoreButton;
{
	SHKActionSheet *as = [[SHKActionSheet alloc] initWithTitle:SHKLocalizedString(@"Share")
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:nil];
	as.item = [[[SHKItem alloc] init] autorelease];
	as.item.shareType = inType;
	
	as.sharers = [NSMutableArray array];
		
	// Add buttons for each favorite sharer
	id class;
	for(NSString *sharerId in inSharers)
	{
		class = NSClassFromString(sharerId);
		if ([class canShare])
		{
			[as addButtonWithTitle: [class sharerTitle] ];
			[as.sharers addObject:sharerId];
		}
	}
	
	// Add More button
	if (inShowMoreButton) [as addButtonWithTitle:SHKLocalizedString(@"More...")];
	
	// Add Cancel button
	[as addButtonWithTitle:SHKLocalizedString(@"Cancel")];
	as.cancelButtonIndex = as.numberOfButtons -1;
	
	return [as autorelease];
}

+ (SHKActionSheet *)actionSheetForType:(SHKShareType)inType
{
	return [self actionSheetForType:inType sharers:[SHK favoriteSharersForType:inType] showMoreButton:YES];
}



+ (SHKActionSheet *)actionSheetForItem:(SHKItem *)i
{
	SHKActionSheet *as = [self actionSheetForType:i.shareType];
	as.item = i;
	return as;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
	// Sharers
	if (buttonIndex >= 0 && buttonIndex < sharers.count)
	{
		[NSClassFromString([sharers objectAtIndex:buttonIndex]) performSelector:@selector(shareItem:) withObject:item];
	}
	
	// More
	else if (buttonIndex == sharers.count && buttonIndex != self.cancelButtonIndex)
	{
		SHKShareMenu *shareMenu = [[SHKCustomShareMenu alloc] initWithStyle:UITableViewStyleGrouped];
		shareMenu.item = item;
		[[SHK currentHelper] showViewController:shareMenu];
		[shareMenu release];
	}
	
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end