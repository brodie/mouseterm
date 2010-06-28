#import <Cocoa/Cocoa.h>
#import "MTEscapeParserState.h"

@interface NSObject (MTShell)
- (NSValue*) MouseTerm_initVars;
- (void) MouseTerm_dealloc;

- (void) MouseTerm_setMouseMode: (int)mouseMode;
- (int) MouseTerm_getMouseMode;

- (void) MouseTerm_setAppCursorMode: (BOOL)appCursorMode;
- (BOOL) MouseTerm_getAppCursorMode;

- (void) MouseTerm_setIsMouseDown: (BOOL)isMouseDown;
- (BOOL) MouseTerm_getIsMouseDown;

- (void) MouseTerm_setParserState: (MTEscapeParserState *)parserState;
- (MTEscapeParserState *) MouseTerm_getParserState;

@end