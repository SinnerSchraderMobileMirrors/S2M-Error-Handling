
//
//  Created by Uli Luckas on 7/30/12.
//  Copyright (c) 2012 SinnerSchrader Mobile. All rights reserved.
//

#import "S2MParserError.h"

NSInteger const kS2MErrorDomain_parser_protocolError = 1;
NSInteger const kS2MErrorDomain_parser_dictionaryExpected = 2;
NSInteger const kS2MErrorDomain_parser_arrayExpected = 3;
NSInteger const kS2MErrorDomain_parser_numberExpected = 4;
NSInteger const kS2MErrorDomain_parser_stringExpected = 5;
NSInteger const kS2MErrorDomain_parser_dateExpected = 6;
NSInteger const kS2MErrorDomain_parser_keyNotFound = 7;
NSInteger const kS2MErrorDomain_parser_indexNotFound = 8;
NSInteger const kS2MErrorDomain_parser_valueIsNull = 9;
NSInteger const kS2MErrorDomain_parser_dataExpected = 10;

@interface CrashAlertController : NSObject<UIAlertViewDelegate>
@property (nonatomic, retain) S2MParserError *parserError;
@property (nonatomic, retain) UIAlertView *alertView;
@end


@interface S2MParserError() {
@private
    NSMutableString *_logTrace;
}
@property (nonatomic, readonly) NSString *logTrace;
@end

#pragma mark - CrashAlertController
@implementation CrashAlertController

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [NSException raise:@"JSON parsing exception" format:@"Parsing error: %@\nLog Trace:\n%@", self.parserError, self.parserError.logTrace];
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

- (void)willPresentAlertView:(UIAlertView *)alertView {  // before animation and showing view
    
}

- (void)didPresentAlertView:(UIAlertView *)alertView {  // after animation
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex { // before animation and hiding view
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {   // after animation
    
}

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return YES;
}

#pragma mark Lifecycle

- (id)initWithParserError:(S2MParserError*)parserError {
    self = [super init];
    if (self) {
        _parserError = [parserError retain];
#if DEBUG
        _alertView = [[[UIAlertView alloc] initWithTitle:@"JSONParseError"
                                                 message:[parserError description]
                                                delegate:self
                                       cancelButtonTitle:@"Crash"
                                       otherButtonTitles:nil] autorelease];
#endif
    }    
    return self;
}

- (void)dealloc {
    self.alertView = nil;
    self.parserError = nil;
    [super dealloc];
}

@end


static CrashAlertController *crashAlertController = nil;

#pragma mark -
#pragma mark - S2MParserError
@implementation S2MParserError

-(void)appendLogTraceWithMethod:(const char*)method file:(const char*)file line:(const int)line {
    [_logTrace appendFormat:@"\n%s (%s:%d)", method, file, line];
}

// Only call on main thread
-(void)_handleErrorWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate alertViewTag:(NSInteger)tag {
    if (!self.handled) {
        [self showCrashOnJSONErrorAlert];
        self.handled = YES;
    }
    [super handleErrorWithAlertViewDelegate:delegate alertViewTag:0];
}

-(void)showCrashOnJSONErrorAlert {
    if (!crashAlertController) {
        crashAlertController = [[CrashAlertController alloc] initWithParserError:self];
        [crashAlertController.alertView show];
    }
}

#pragma mark - Lifecycle

+(S2MParserError*)parserErrorWithCode:(NSInteger)code {
    S2MParserError *parserError = [self errorWithDomain:kS2MErrorDomain_parser code:code userInfo:nil];
    parserError->_logTrace = [[NSMutableString alloc] initWithString:@""];
    return parserError;
}

-(void)dealloc {
    [_logTrace release];
	
    [super dealloc];
}

@end
