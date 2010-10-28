//
//  WMEditorSidebarItem.h
//  WoollyEditor
//
//  Created by Andrew Pouliot on 10/28/10.
//  Copyright 2010 Darknoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WMEditorSidebarItem : NSObject {
	NSString *name;
	NSMutableArray *children;
}

@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, copy) NSString *name;

- (void)insertChildWithName:(NSString *)inName;

@end
