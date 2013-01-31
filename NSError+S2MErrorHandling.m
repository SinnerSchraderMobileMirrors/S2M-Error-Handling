
//
//  Created by Uli Luckas on 4/06/12.
//  Copyright (c) 2012 SinnerSchrader Mobile GmbH. All rights reserved.
//

#import "NSError+S2MErrorHandling.h"
#import "S2MErrorHandler.h"
#import <objc/runtime.h>

static const NSString *handledKey = @"handled";
static const NSString *delegatesKey = @"delegates";

NSString * const kS2MErrorDomain_server = @"S2MServer";
NSString * const kS2MErrorDomain_parser = @"S2MParser";
NSString * const kS2MErrorDomain_nilArgument = @"S2MErrorDomain_nilArgument";

NSString * const kS2MErrorUserInfoKey_parameterNames = @"parameterNames";
NSString * const kS2MErrorUserInfoKey_stackSymbols = @"stackSymbols";

NSString * const kS2MErrorNotification_showNotification = @"S2MErrorNotification_showNotification";
NSString * const kS2MErrorNotification_key_message = @"S2MErrorNotification_key_message";


@implementation NSError(S2MErrorHandling)

#pragma mark - Accessors

-(void)setHandled:(BOOL)handled {
    objc_setAssociatedObject (self,
                              &handledKey,
                              [NSNumber numberWithBool:handled],
                              OBJC_ASSOCIATION_RETAIN);
}

-(BOOL)handled {
    BOOL handledValue = NO;
    id handled = objc_getAssociatedObject(self, &handledKey);
    if ([handled isKindOfClass:[NSNumber class]]) {
        handledValue = ((NSNumber*)handled).boolValue;
    }
    return handledValue;
}

- (id<UIAlertViewDelegate>)alertViewDelegate {
	return objc_getAssociatedObject(self, &delegatesKey);
}

- (void)setAlertViewDelegate:(id<UIAlertViewDelegate>)alertViewDelegate {
	objc_setAssociatedObject (self,
                              &delegatesKey,
                              alertViewDelegate,
                              OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Error Handling

- (void)handleError {
	[self handleErrorWithChainHandler:nil alertViewDelegate:nil alertViewTag:0];
}

-(void)handleErrorWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate
						   alertViewTag:(NSInteger)tag {
    [self handleErrorWithChainHandler:nil alertViewDelegate:delegate alertViewTag:tag];
}

-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler {
    [self handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:nil alertViewTag:0];
}

-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				 alertViewDelegate:(id<UIAlertViewDelegate>)delegate
					  alertViewTag:(NSInteger)tag {
    // Make sure we are on main thread
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:delegate alertViewTag:tag];
        });
    } else {
        [self _handleErrorWithChainHandler:chainErrorHandler alertViewDelegate:delegate alertViewTag:tag];
    }
}

#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.alertViewDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
	self.alertViewDelegate = nil;
	
	// self has been retained by the -_handleErrorWithAlertViewDelegate:alertViewTag: method
	[self release];
}

#pragma mark - Private Error Handling

// Only call on main thread
-(void)_handleErrorWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate alertViewTag:(NSInteger)tag {
	if (!self.handled && [self.domain isEqualToString:kS2MErrorDomain_nilArgument]) {
		S2MLog(@"nil argument given to parameters %@. Call stack: %@", [self.userInfo objectForKey:kS2MErrorUserInfoKey_parameterNames], [self.userInfo objectForKey:kS2MErrorUserInfoKey_stackSymbols]);
		self.handled = YES;
	}
    if (!self.handled) {
        static UIAlertView *alertView;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *title = NSLocalizedStringFromTable(@"S2M_ERROR_ALERT_TITLE", @"S2M_error_handler",@"");
            NSString *message = NSLocalizedStringFromTable(@"S2M_ERROR_ALERT_MESSAGE", @"S2M_error_handler",@"");
            NSString *button = NSLocalizedStringFromTable(@"S2M_ERROR_ALERT_CANCEL_BUTTON", @"S2M_error_handler",@"");
            
            alertView = [[UIAlertView alloc] initWithTitle:title
                                         message:message
                                        delegate:nil
                               cancelButtonTitle:button
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
        [alertView show];
        self.handled = YES;
    }
}

// Only call on main thread
-(void)_handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				  alertViewDelegate:(id<UIAlertViewDelegate>)delegate
					   alertViewTag:(NSInteger)tag {
    if (chainErrorHandler) {
        [chainErrorHandler handleError:self];
    }
    [self _handleErrorWithAlertViewDelegate:delegate alertViewTag:tag];
}



@end
