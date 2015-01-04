#import <Cocoa/Cocoa.h>
#import "Mouse.h"
#import "MouseTerm.h"
#import "MTParserState.h"
#import "MTShell.h"
#import "Terminal.h"

@implementation NSObject (MTShell)

- (NSValue*) MouseTerm_initVars
{
    NSValue* ptr = [NSValue valueWithPointer: self];
    if ([MouseTerm_ivars objectForKey: ptr] == nil)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [MouseTerm_ivars setObject: dict forKey: ptr];
        [dict setObject: [NSNumber numberWithInt: NO_MODE]
                 forKey: @"mouseMode"];
        [dict setObject: [NSNumber numberWithInt: NORMAL_PROTOCOL]
                 forKey: @"mouseProtocol"];
        [dict setObject: [NSNumber numberWithBool: NO]
                 forKey: @"appCursorMode"];
        [dict setObject: [NSNumber numberWithBool: NO]
                 forKey: @"isMouseDown"];
        [dict setObject: [[[MTParserState alloc] init] autorelease]
                 forKey: @"parserState"];
    }
    return ptr;
}

- (void) MouseTerm_setMouseMode: (int) mouseMode
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr]
        setObject: [NSNumber numberWithInt:mouseMode] forKey: @"mouseMode"];
    [self MouseTerm_cachePosition: nil];
}

- (int) MouseTerm_getMouseMode
{
    NSValue *ptr = [self MouseTerm_initVars];
    return [(NSNumber*) [[MouseTerm_ivars objectForKey: ptr]
                            objectForKey: @"mouseMode"] intValue];
}

- (void) MouseTerm_setMouseProtocol: (int) mouseProtocol
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr]
        setObject: [NSNumber numberWithInt:mouseProtocol]
           forKey: @"mouseProtocol"];
    [self MouseTerm_cachePosition: nil];
}

- (int) MouseTerm_getMouseProtocol
{
    NSValue *ptr = [self MouseTerm_initVars];
    return [(NSNumber*) [[MouseTerm_ivars objectForKey: ptr]
                            objectForKey: @"mouseProtocol"] intValue];
}

- (void) MouseTerm_setAppCursorMode: (BOOL) appCursorMode
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr]
        setObject: [NSNumber numberWithBool: appCursorMode]
           forKey: @"appCursorMode"];
}

- (BOOL) MouseTerm_getAppCursorMode
{
    NSValue *ptr = [self MouseTerm_initVars];
    return [(NSNumber*) [[MouseTerm_ivars objectForKey: ptr]
                            objectForKey: @"appCursorMode"] boolValue];
}

- (void) MouseTerm_setIsMouseDown: (BOOL) isMouseDown
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr]
        setObject: [NSNumber numberWithBool:isMouseDown]
           forKey: @"isMouseDown"];
}

- (BOOL) MouseTerm_getIsMouseDown
{
    NSValue *ptr = [self MouseTerm_initVars];
    return [(NSNumber*) [[MouseTerm_ivars objectForKey: ptr]
                            objectForKey: @"isMouseDown"] boolValue];
}

- (void) MouseTerm_setParserState: (MTParserState*) parserState
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr] setObject: parserState
                                            forKey: @"parserState"];
}

- (MTParserState*) MouseTerm_getParserState
{
    NSValue *ptr = [self MouseTerm_initVars];
    return [[MouseTerm_ivars objectForKey: ptr] objectForKey: @"parserState"];
}

- (void) MouseTerm_writeData: (NSData*) data
{
    if ([self MouseTerm_getParserState].handleSda &&
        !strncmp([data bytes], PDA_RESPONSE, PDA_RESPONSE_LEN))
        return;

    [self MouseTerm_writeData: data];
}

- (void) MouseTerm_cachePosition: (Position*) pos
{
    NSValue *ptr = [self MouseTerm_initVars];
    if (pos) {
        [[MouseTerm_ivars objectForKey: ptr]
            setObject: [NSValue valueWithBytes: pos objCType: @encode(Position)]
               forKey: @"positionCache"];
    } else {
        [[MouseTerm_ivars objectForKey: ptr] removeObjectForKey: @"positionCache"];
    }
}

- (BOOL) MouseTerm_positionIsChanged: (Position*) pos;
{
    Position cache;
    NSValue *ptr = [self MouseTerm_initVars];
    NSValue *value = [[MouseTerm_ivars objectForKey: ptr] objectForKey: @"positionCache"];
    if (!value)
        return YES;
    [value getValue: &cache];
    return cache.x != pos->x || cache.y != pos->y;
}

// Deletes instance variables
- (void) MouseTerm_dealloc
{
    [MouseTerm_ivars removeObjectForKey: [NSValue valueWithPointer: self]];
    [self MouseTerm_dealloc];
}

@end
