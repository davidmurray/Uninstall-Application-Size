//#import <MobileInstallation/MobileInstallation.h>

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray *)allInstalledApplications;
@end

@interface LSApplicationProxy : NSObject
@property(nonatomic, readonly) NSNumber *dynamicDiskUsage;
@property(nonatomic, readonly) NSNumber *staticDiskUsage;
+ (instancetype)applicationProxyForIdentifier:(NSString *)identifier;
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBIcon : NSObject
- (SBApplication *)application;
@end

@interface SBUserInstalledApplicationIcon : SBIcon
@end

static CFDictionaryRef (*MobileInstallationLookup)(CFDictionaryRef options);

static size_t UASGetApplicationSize(SBIcon *icon)
{
	NSString *identifier = [[icon application] bundleIdentifier];

	// iOS 8+
	if ([LSApplicationProxy instancesRespondToSelector:@selector(staticDiskUsage)]) {
		LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:identifier];
		if (!proxy)
			return 0;

		return [[proxy staticDiskUsage] longLongValue] + [[proxy dynamicDiskUsage] longLongValue];
	} else {
		NSArray *bundleIDs = [NSArray arrayWithObjects:identifier, nil];
		NSArray *returnAttributes = [NSArray arrayWithObjects:@"StaticDiskUsage", @"DynamicDiskUsage", nil];

		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:bundleIDs, @"BundleIDs", returnAttributes, @"ReturnAttributes", nil];
		if (MobileInstallationLookup != NULL) {
			CFDictionaryRef ret = (*MobileInstallationLookup)((CFDictionaryRef)attributes);
			NSDictionary *data = [(NSDictionary *)ret objectForKey:identifier];

			return [[data objectForKey:@"StaticDiskUsage"] longLongValue] + [[data objectForKey:@"DynamicDiskUsage"] longLongValue];
		} else {
			return 0;
		}
	}
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

%ctor
{
	MSImageRef image = MSGetImageByName("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation");
	MobileInstallationLookup = (CFDictionaryRef(*)(CFDictionaryRef))MSFindSymbol(image, "_MobileInstallationLookup");
}
