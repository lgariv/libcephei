#import "HBAboutListController.h"
#import "HBAppearanceSettings.h"
#import "HBSupportController.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>

@implementation HBAboutListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"About";
}

+ (NSURL *)hb_websiteURL {
	return [NSURL URLWithString:@"https://hashbang.productions/"];
}

+ (NSURL *)hb_donateURL {
	return [NSURL URLWithString:@"https://hashbang.productions/donate/"];
}

+ (nullable NSString *)hb_supportEmailAddress {
	return nil;
}

+ (id)hb_linkInstruction {
	return nil;
}

+ (nullable NSArray *)hb_supportInstructions {
	return nil;
}

#pragma mark - Callbacks

- (void)hb_openWebsite {
#ifdef THEOS
	[[UIApplication sharedApplication] openURL:[self.class hb_websiteURL]];
#endif
}

- (void)hb_openDonate {
#ifdef THEOS
	[[UIApplication sharedApplication] openURL:[self.class hb_donateURL]];
#endif
}

- (void)hb_sendSupportEmail {
	[self hb_sendSupportEmail:nil];
}

- (void)hb_sendSupportEmail:(nullable PSSpecifier *)specifier {
	UIViewController *viewController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:specifier.properties[@"defaults"] sendToEmail:[self.class hb_supportEmailAddress]];

	if ([viewController respondsToSelector:@selector(tintColor)]) {
		viewController.view.tintColor = self.hb_appearanceSettings.navigationBarTintColor ?: self.view.tintColor;
	}

	if (IS_IOS_OR_NEWER(iOS_13_0)) {
		if (@available(iOS 13, *)) {
			viewController.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle;
		}
	}

	[self.realNavigationController pushViewController:viewController animated:YES];
}

@end
