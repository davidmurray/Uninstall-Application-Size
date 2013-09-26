#import <MobileInstallation/MobileInstallation.h>

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBIcon : NSObject
- (SBApplication *)application;
@end

@interface SBUserInstalledApplicationIcon : SBIcon
@end

static size_t UASGetApplicationSize(SBIcon *icon)
{
	NSString *identifier = [[icon application] bundleIdentifier];

	NSArray *bundleIDs = [NSArray arrayWithObjects:identifier, nil];
	NSArray *returnAttributes = [NSArray arrayWithObjects:@"StaticDiskUsage", @"DynamicDiskUsage", nil];

	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:bundleIDs, @"BundleIDs", returnAttributes, @"ReturnAttributes", nil];
	NSDictionary *data = [(NSDictionary *)MobileInstallationLookup((CFDictionaryRef)attributes) objectForKey:identifier];

	return [[data objectForKey:@"StaticDiskUsage"] longLongValue] + [[data objectForKey:@"DynamicDiskUsage"] longLongValue];
}

// XXX: Maybe there's a better way to do this other than copy the same code three times?

%hook SBUserInstalledApplicationIcon

- (NSString *)uninstallAlertBody
{
	NSString *byteCount = [NSByteCountFormatter stringFromByteCount:UASGetApplicationSize(self) countStyle:NSByteCountFormatterCountStyleFile];
	NSString *replacedBody = [NSString stringWithFormat:@"%@\nApplication Size: %@", %orig, byteCount];

	return replacedBody;
}

- (NSString *)uninstallAlertBodyForAppWithDocumentUpdatesPending
{
	NSString *byteCount = [NSByteCountFormatter stringFromByteCount:UASGetApplicationSize(self) countStyle:NSByteCountFormatterCountStyleFile];
	NSString *replacedBody = [NSString stringWithFormat:@"%@\nApplication Size: %@", %orig, byteCount];

	return replacedBody;
}

- (NSString *)uninstallAlertBodyForAppWithDocumentsInCloud
{
	NSString *byteCount = [NSByteCountFormatter stringFromByteCount:UASGetApplicationSize(self) countStyle:NSByteCountFormatterCountStyleFile];
	NSString *replacedBody = [NSString stringWithFormat:@"%@\nApplication Size: %@", %orig, byteCount];

	return replacedBody;
}

%end
