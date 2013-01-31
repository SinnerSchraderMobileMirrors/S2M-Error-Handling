
//
//  Created by Uli Luckas on 6/04/12.
//  Copyright (c) 2012 SinnerSchrader Mobile GmbH. All rights reserved.
//

#import "S2MServerError.h"
#import "S2MParserError.h"

extern NSString * const kS2MErrorDomain_server;
extern NSString * const kS2MErrorDomain_parser;
extern NSString * const kS2MErrorDomain_nilArgument;

extern NSString * const kS2MErrorUserInfoKey_parameterNames;
extern NSString * const kS2MErrorUserInfoKey_stackSymbols;

extern NSString * const kS2MErrorNotification_showNotification;
extern NSString * const kS2MErrorNotification_key_message;


#define S2MLog NSLog

// Make sure errors can be received
#define S2M_ASSURE_ERROR(error)                                              \
    if (!(error)) (error) = alloca(sizeof(NSError*));                       \
    *(error) = nil;

#define S2M_LOG_SERVER_ERROR(serverError)                                    \
    S2MLog(@"Error from server: %@", (serverError));

#define S2M_LOG_JSON_ERROR(parserError) do {                                 \
    S2MLog(@"Error parsing JSON: %@", (parserError));                        \
    [(parserError) appendLogTraceWithMethod:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__]; \
} while (NO)


#define S2M_LOG_ERROR(error) do {                                            \
    NSError *typeCheckedError = nil;                                        \
    typeCheckedError = (error);                                             \
    if (!typeCheckedError) {                                                \
        ;                                                                   \
    } else if ([typeCheckedError isKindOfClass:[S2MServerError class]]) {    \
        S2M_LOG_SERVER_ERROR((S2MServerError*)typeCheckedError);              \
    } else if ([typeCheckedError isKindOfClass:[S2MParserError class]]) {    \
        S2M_LOG_JSON_ERROR((S2MParserError*)typeCheckedError);                \
    } else {                                                                \
        S2MLog(@"Error: %@", typeCheckedError);                              \
    }                                                                       \
} while (NO)

#define S2M_HANDLE_ERROR(error, handler) do {                                \
    NSError *typeCheckedError = nil;                                        \
    typeCheckedError = (error);                                             \
    id<S2MErrorHandler> typeCheckedHandler = nil;                            \
    typeCheckedHandler = (handler);                                         \
    S2M_LOG_ERROR(typeCheckedError);                                         \
    [typeCheckedError handleErrorWithChainHandler:typeCheckedHandler];      \
} while (NO)

#define S2M_HANDLE_ERROR_WITH_DELEGATE(error, handler, delegate, tag) do { \
    NSError *typeCheckedError = nil;                                        \
    typeCheckedError = (error);                                             \
    id<S2MErrorHandler> typeCheckedHandler = nil;                           \
    typeCheckedHandler = (handler);                                         \
    id<UIAlertViewDelegate> typeCheckedDelegate = nil;                      \
    typeCheckedDelegate = (delegate);										\
    NSInteger typeCheckedTag = nil;											\
    typeCheckedTag = (tag);													\
    S2M_LOG_ERROR(typeCheckedError);                                        \
    [typeCheckedError handleErrorWithChainHandler:typeCheckedHandler		\
				  alertViewDelegate:typeCheckedDelegate					\
				  alertViewTag:typeCheckedTag];							\
} while (NO)

@protocol S2MErrorHandler;


@interface NSError(S2MErrorHandling)

/**
	Indicates whether this error has been handled. If an error is passed through a chain of methods, the method that elects to deal with this error sets this property to `YES`. Methods further up the chain can then determine if an error needs handling. Another approach would be that the handling method doesn't pass the error on, however other methods may still need the information contained whithin the error object.
 */
@property (nonatomic, assign) BOOL handled;
@property (nonatomic, retain) id<UIAlertViewDelegate> alertViewDelegate;

/**
 Provides default error handling.
	Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with default parameters `nil`, `nil`, `0`.
 */
-(void)handleError;

/**
 Provides default error handling.
	Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with the given values for the `delegate` and `tag` parameters, and `nil` for the `chainHandler`.
	@param delegate The delegate for the alertView
	@param tag The tag for the alertView. This may be useful to determine a specific alertView in a delegate callback. Just tag different alertViews differently and query the alertView for its `tag` in a callback method.
 */
-(void)handleErrorWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate
						   alertViewTag:(NSInteger)tag;


/**
 Provides default error handling.
	Calls #handleErrorWithChainHandler:alertViewDelegate:alertViewTag: with the given `chainErrorHandler`, `nil` as the `delegate`, and `0` as the `tag`.
	@param chainErrorHandler 
 */
-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler;


/**
 Provides default error handling.
 If #handled is `YES`, nothing happens. Otherwise, an alertView is shown for normal errors, or an `OfflineNotification` is posted for `NSURLErrorDomain` errors.
 Side effect: #handled will be `YES` afterwards.
 @param chainErrorHandler
 @param delegate The delegate for the alertView
 @param tag The tag for the alertView. This may be useful to determine a specific alertView in a delegate callback. Just tag different alertViews differently and query the alertView for its `tag` in a callback method.
 */
-(void)handleErrorWithChainHandler:(id<S2MErrorHandler>)chainErrorHandler
				 alertViewDelegate:(id<UIAlertViewDelegate>)delegate
					  alertViewTag:(NSInteger)tag;
@end
