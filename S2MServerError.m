
//
//  Created by Uli Luckas on 7/30/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MServerError.h"

@implementation S2MServerError

-(NSError*)underlyingError {
    return [self.userInfo objectForKey:NSUnderlyingErrorKey];
}

-(NSString*)errorMessage {
    NSAssert(false, @"you must implement you own serverMessage parsing");
    return @"";
}

- (NSString*)alertTitle{
    return NSLocalizedStringFromTable(@"S2M_SERVER_ERROR_TITLE", @"S2M_error_handler",@"");
}


// Only call on main thread
-(void)_handleErrorWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate alertViewTag:(NSInteger)tag {
	if (!self.handled && [self.underlyingError.domain isEqualToString:NSURLErrorDomain]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:[self.class offlineNotificationName] object:self];
		self.handled = YES;
	}
	if (!self.handled) {
        static UIAlertView *alertView;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
			alertView = [[UIAlertView alloc] initWithTitle:@""
													message:@""
												   delegate:delegate
										  cancelButtonTitle:[self.class alertButtonOkTitle]
										  otherButtonTitles:nil];
        });
		
		// this method may be dispatched. The delegate is retained by the block closure, but
		// may be released before the alert view is dismissed. CRASH!!!
		// We need to keep an owning reference until after the alert view is dismissed:
		self.alertViewDelegate = delegate;
		
		// We set ourself as the alert view delegate.
		// The -alertView:didDismissWithButtonIndex: method (see NSError+S2MErrorHandling.m)
		// will act as a trampoline and send the delegate callback message to the original delegate.
		// afterwards it will clean up by setting self.delegate = nil and [self release].
		alertView.delegate = self;
		// the error object must not disappear until the alert sends the delegate callback:
		[self retain];
		
		alertView.tag = tag;
        alertView.title = self.alertTitle;
		alertView.message = self.errorMessage;

		[alertView show];
        self.handled = YES;
    }
}

#pragma mark - Lifecycle

+(S2MServerError*)serverErrorWithError:(NSError*)error
								  code:(NSInteger)code
                              userInfo:(NSDictionary*)userInfo
                                  data:(id)data {
    if (!userInfo) {
        userInfo = [NSMutableDictionary dictionary];
    } else if (![userInfo isKindOfClass:[NSMutableDictionary class]]) {
        userInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    }
    [userInfo setValue:error forKey:NSUnderlyingErrorKey];
    S2MServerError *serverError = [self errorWithDomain:kS2MErrorDomain_server code:code userInfo:userInfo];
    serverError.data = data;
    return serverError;
}

+ (NSString*)alertButtonOkTitle{
    return NSLocalizedStringFromTable(@"S2M_SERVER_ERROR_OK_BUTTON", @"S2M_error_handler",@"");
}

+ (NSString*)offlineNotificationName{
    return nil;
}

+ (NSString*)onlineNotificationName{
    return nil;
}


-(void)dealloc {
    self.data = nil;
    
    [super dealloc];
}

@end
