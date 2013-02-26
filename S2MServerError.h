
//
//  Created by Uli Luckas on 7/30/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "NSError+S2MErrorHandling.h"
#import "AFHTTPRequestOperation.h"

@interface S2MServerError : NSError

@property (nonatomic, retain) id data; // deprecated?
@property (nonatomic, retain) AFHTTPRequestOperation *operation;

- (NSError*)underlyingError;
- (NSString*)errorMessage;

+ (NSString*)alertButtonOkTitle;
+ (NSString*)offlineNotificationName;
+ (NSString*)onlineNotificationName;

- (NSString*)alertTitle;

#pragma mark - Lifecycle
+ (S2MServerError*)serverErrorWithError:(NSError*)error
                                   code:(NSInteger)code
                               userInfo:(NSDictionary*)userInfo
                                   data:(id)data;

+(S2MServerError*)serverErrorWithError:(NSError*)error
								  code:(NSInteger)code
							  userInfo:(NSDictionary*)userInfo
							 operation:(AFHTTPRequestOperation*)operation;

@end
