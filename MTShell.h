#import <Cocoa/Cocoa.h>
#import "Terminal.h"

@class MTParserState;

@interface NSObject (MTShell)
- (NSValue*) MouseTerm_initVars;
- (void) MouseTerm_writeData: (NSData*) data;
- (void) MouseTerm_dealloc;

- (void) MouseTerm_setMouseMode: (int) mouseMode;
- (int) MouseTerm_getMouseMode;

- (void) MouseTerm_setMouseProtocol: (int) mouseProtocol;
- (int) MouseTerm_getMouseProtocol;

- (void) MouseTerm_setAppCursorMode: (BOOL) appCursorMode;
- (BOOL) MouseTerm_getAppCursorMode;

- (void) MouseTerm_setIsMouseDown: (BOOL) isMouseDown;
- (BOOL) MouseTerm_getIsMouseDown;

- (void) MouseTerm_setParserState: (MTParserState*) parserState;
- (MTParserState*) MouseTerm_getParserState;

- (void) MouseTerm_cachePosition: (Position*) pos;
- (BOOL) MouseTerm_positionIsChanged: (Position*) pos;
@end
