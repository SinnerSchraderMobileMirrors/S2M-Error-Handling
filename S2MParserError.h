
//
//  Created by Uli Luckas on 7/30/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "NSError+S2MErrorHandling.h"

extern NSInteger const kS2MErrorDomain_parser_protocolError;
extern NSInteger const kS2MErrorDomain_parser_dictionaryExpected;
extern NSInteger const kS2MErrorDomain_parser_arrayExpected;
extern NSInteger const kS2MErrorDomain_parser_numberExpected;
extern NSInteger const kS2MErrorDomain_parser_stringExpected;
extern NSInteger const kS2MErrorDomain_parser_dateExpected;
extern NSInteger const kS2MErrorDomain_parser_keyNotFound;
extern NSInteger const kS2MErrorDomain_parser_indexNotFound;
extern NSInteger const kS2MErrorDomain_parser_valueIsNull;
extern NSInteger const kS2MErrorDomain_parser_dataExpected;


@interface S2MParserError : NSError

-(void)appendLogTraceWithMethod:(const char*)method file:(const char*)file line:(const int)line;

#pragma mark - Lifecycle
+(S2MParserError*)parserErrorWithCode:(NSInteger)code;

@end
