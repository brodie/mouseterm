#import <Cocoa/Cocoa.h>
#import "Mouse.h"
#import "MouseTerm.h"
#import "MTShell.h"

@implementation NSObject (MTShell)

- (NSValue*) MouseTerm_initVars
{
    NSValue* ptr = [NSValue valueWithPointer: self];
    if ([MouseTerm_ivars objectForKey: ptr] == nil) {
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
        [dict setObject: [[[NSMutableData alloc] initWithLength:sizeof(struct parse_context)] autorelease]
                 forKey: @"parseContext"];
    }
    return ptr;
}

- (void) MouseTerm_setMouseMode: (int) mouseMode
{
    NSValue *ptr = [self MouseTerm_initVars];
    [[MouseTerm_ivars objectForKey: ptr]
        setObject: [NSNumber numberWithInt:mouseMode] forKey: @"mouseMode"];
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

- (struct parse_context*) MouseTerm_getParseContext
{
    NSValue *ptr = [self MouseTerm_initVars];
    return (struct parse_context*)[[[MouseTerm_ivars objectForKey: ptr] objectForKey:@"parseContext"] bytes];
}

- (void) MouseTerm_writeData: (NSData*) data
{
    [self MouseTerm_writeData: data];
}

// Deletes instance variables
- (void) MouseTerm_dealloc
{
    [MouseTerm_ivars removeObjectForKey: [NSValue valueWithPointer: self]];
    [self MouseTerm_dealloc];
}

@end
