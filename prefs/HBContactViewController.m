#import "HBContactViewController.h"
#import "../HBOutputForShellCommand.h"
#import <version.h>
@import MessageUI;

@interface HBContactViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation HBContactViewController {
	BOOL _hasShown;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_hasShown) {
		return;
	}

	// No use doing this if we can’t send email.
	if (![MFMailComposeViewController canSendMail]) {
		NSString *title = LOCALIZE(@"NO_EMAIL_ACCOUNTS_TITLE", @"Support", @"");
		NSString *body = LOCALIZE(@"NO_EMAIL_ACCOUNTS_BODY", @"Support", @"");
		NSBundle *uikitBundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
		NSString *ok = [uikitBundle localizedStringForKey:@"OK" value:@"" table:@"Localizable"];
		if (IS_IOS_OR_NEWER(iOS_9_0)) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
			[alertView show];
			[self _dismiss];
		} else {
			UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:body preferredStyle:UIAlertControllerStyleAlert];
			[alertController addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				[self _dismiss];
			}]];
			[self.navigationController presentViewController:alertController animated:YES completion:nil];
		}
		return;
	}

	MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
	viewController.mailComposeDelegate = self;
	viewController.toRecipients = @[ _to ];
	viewController.subject = _subject;
	[viewController setMessageBody:_messageBody isHTML:NO];
	[viewController addAttachmentData:[HBOutputForShellCommand(@"/usr/bin/dpkg -l") dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:@"Package List.txt"];
	if (_preferencesPlist != nil && _preferencesIdentifier != nil) {
		[viewController addAttachmentData:_preferencesPlist mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"preferences-%@.plist", _preferencesIdentifier]];
	}
	if ([viewController.view respondsToSelector:@selector(tintColor)]) {
		viewController.view.tintColor = self.view.tintColor;
	}

	[self.navigationController presentViewController:viewController animated:YES completion:nil];
	_hasShown = YES;
}

- (void)_dismiss {
	if (self.navigationController.viewControllers.count == 1) {
		[self dismissViewControllerAnimated:NO completion:nil];
	} else {
		[self.realNavigationController popViewControllerAnimated:YES];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)viewController didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[viewController dismissViewControllerAnimated:YES completion:nil];
	[self _dismiss];
}

@end
