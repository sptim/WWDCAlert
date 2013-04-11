//
//  ViewController.m
//  WWDCAlert
//
//  Created by Tim Mecking on 4/2/13.
//  Copyright (c) 2013 Tim Mecking. All rights reserved.
//

#import "ViewController.h"
#import "WWDCPageLoader.h"

@interface ViewController ()
@property (nonatomic,weak) UIToolbar* toolbar;
@property (nonatomic,strong) UIBarButtonItem* refreshBarButtonItem;
@property (nonatomic,strong) UIBarButtonItem* spinnerBarButtonItem;
@property (nonatomic,strong) UILabel* statusLabel;
@property (nonatomic,strong) UIBarButtonItem* statusBarButtonItem;
@property (nonatomic,strong) UIBarButtonItem* spaceBarButtonItem;
@property (nonatomic,weak) UIWebView* webView;
@end

@implementation ViewController

-(UIToolbar *)toolbar {
	if(!_toolbar) {
		UIToolbar* toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height-44.0, self.view.bounds.size.width, 44.0)];
		toolbar.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		[self.view addSubview:toolbar];
		_toolbar=toolbar;
	}
	return _toolbar;
}

-(UIBarButtonItem *)refreshBarButtonItem {
	if(!_refreshBarButtonItem) {
		_refreshBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:[WWDCPageLoader sharedLoader] action:@selector(refresh)];
	}
	return _refreshBarButtonItem;
}

-(UIBarButtonItem *)spinnerBarButtonItem {
	if(!_spinnerBarButtonItem) {
		UIActivityIndicatorView* spinner=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[spinner startAnimating];
		_spinnerBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:spinner];
	}
	return _spinnerBarButtonItem;
}

-(UIBarButtonItem *)statusBarButtonItem {
	if(!_statusBarButtonItem) {
		_statusBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.statusLabel];
	}
	return _statusBarButtonItem;
}

-(UIBarButtonItem *)spaceBarButtonItem {
	if(!_spaceBarButtonItem) {
		_spaceBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	}
	return _spaceBarButtonItem;
}

-(UILabel *)statusLabel {
	if(!_statusLabel) {
		_statusLabel=[[UILabel alloc] initWithFrame:CGRectZero];
		_statusLabel.font=[UIFont systemFontOfSize:14.0];
		_statusLabel.backgroundColor=[UIColor clearColor];
		_statusLabel.textColor=[UIColor blackColor];
	}
	return _statusLabel;
}

-(UIWebView *)webView {
	if(!_webView) {
		UIWebView* webView=[[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height-44.0)];
		webView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		webView.scalesPageToFit=YES;
		[self.view addSubview:webView];
		_webView=webView;
	}
	return _webView;
}

-(void)loadView {
	UIView* view=[[UIView alloc] initWithFrame:CGRectZero];
	self.view=view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:WWDCPageLoaderUpdateNotification object:nil];
}

-(void)update {
	if([[UIApplication sharedApplication] applicationState]!=UIApplicationStateBackground) {
		WWDCPageLoader* loader=[WWDCPageLoader sharedLoader];
		if(loader.loading) {
			self.toolbar.items=@[self.spinnerBarButtonItem];
		}
		else {
			if(loader.htmlString) {
				[self.webView loadHTMLString:loader.htmlString baseURL:loader.url];
				if(loader.lastCheck) {
					self.statusLabel.text = [NSString stringWithFormat:@"Last checked on: %@",
											 [NSDateFormatter localizedStringFromDate:loader.lastCheck
																			dateStyle:NSDateFormatterShortStyle
																			timeStyle:NSDateFormatterMediumStyle]];
				}
				else {
					self.statusLabel.text = [NSString stringWithFormat:@"Page loaded on: %@",
											 [NSDateFormatter localizedStringFromDate:loader.loadDate
																			dateStyle:NSDateFormatterShortStyle
																			timeStyle:NSDateFormatterMediumStyle]];
				}
				[self.statusLabel sizeToFit];
				self.toolbar.items=@[self.refreshBarButtonItem,self.spaceBarButtonItem,self.statusBarButtonItem];
			}
			if(loader.lastError) {
				self.statusLabel.text = [NSString stringWithFormat:@"Failed to load page on: %@",
										 [NSDateFormatter localizedStringFromDate:loader.lastCheck
																		dateStyle:NSDateFormatterShortStyle
																		timeStyle:NSDateFormatterMediumStyle]];
				[self.statusLabel sizeToFit];
				self.toolbar.items=@[self.refreshBarButtonItem,self.spaceBarButtonItem,self.statusBarButtonItem];
			}
		}
	}
}

-(void)applicationDidEnterBackground {
	if(_webView.superview) [_webView removeFromSuperview];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
		CGFloat toolbarHeight=UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 44.0 : 32.0;
		self.toolbar.frame=CGRectMake(0.0, self.view.bounds.size.height-toolbarHeight, self.view.bounds.size.width, toolbarHeight);
		self.webView.frame=CGRectMake(0.0,0.0,self.view.bounds.size.width,self.view.bounds.size.height-toolbarHeight);
	}
}

@end
