#import <Cocoa/Cocoa.h>
#import <math.h>
#import "MTProfile.h"
#import "MTShell.h"
#import "MTView.h"
#import "Mouse.h"
#import "Terminal.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b));

@implementation NSView (MTView)

static BOOL enabled = YES;

- (NSData*) MouseTerm_codeForEvent: (NSEvent*) event
                            button: (MouseButton) button
                            motion: (BOOL) motion
{
    Position pos = [self MouseTerm_currentPosition: event];
    unsigned int x = pos.x;
    unsigned int y = pos.y;
    char cb = button + 32;
    char modflag = [event modifierFlags];

    if (modflag & NSShiftKeyMask) cb |= 4;
    if (modflag & NSAlternateKeyMask) cb |= 8;
    if (modflag & NSControlKeyMask) cb |= 16;
    if (motion) cb += 32;

    x = MIN(x + 33, 255);
    y = MIN(y + 33, 255);

    char buf[MOUSE_RESPONSE_LEN + 1];
    snprintf(buf, sizeof(buf), MOUSE_RESPONSE, cb, x, y);
    return [NSData dataWithBytes: buf length: MOUSE_RESPONSE_LEN];
}

+ (void) MouseTerm_setEnabled: (BOOL) value
{
    enabled = value;
}

+ (BOOL) MouseTerm_getEnabled
{
    return enabled;
}

- (NSScroller*) MouseTerm_scroller
{
    if ([self respondsToSelector: @selector(pane)])
        return [[(TTView*) self pane] scroller];
    else
        return [(TTTabController*) [(TTView*) self controller] scroller];
}

- (BOOL) MouseTerm_shouldIgnore: (NSEvent*) event button: (MouseButton) button
{
    if (![NSView MouseTerm_getEnabled])
        return YES;

    // Don't handle if alt/option/control is pressed
    if ([event modifierFlags] & (NSAlternateKeyMask | NSControlKeyMask))
        return YES;

    TTLogicalScreen* screen = [(TTView*) self logicalScreen];
    // Don't handle if the scroller isn't at the bottom
    linecount_t scrollback =
        (linecount_t) [screen lineCount] -
        (linecount_t) [(TTView*) self rowCount];
    if (scrollback > 0 && [[self MouseTerm_scroller] floatValue] < 1.0)
    {
        return YES;
    }

    // Don't handle if a profile option is disabled
    MTProfile* profile = [(TTTabController*) [(TTView*) self controller]
                                             profile];
    if (![profile MouseTerm_buttonEnabled: button])
        return YES;

    return NO;
}

- (BOOL) MouseTerm_shouldIgnoreDown: (NSEvent*) event
                             button: (MouseButton) button
{
    if ([self MouseTerm_shouldIgnore: event button: button])
        return YES;

    MTShell* shell = [[(TTView*) self controller] shell];
    if (![shell MouseTerm_getIsMouseDown])
        return YES;

    return NO;
}

- (Position) MouseTerm_currentPosition: (NSEvent*) event
{
    linecount_t scrollback =
        (linecount_t) [[(TTView*) self logicalScreen] lineCount] -
        (linecount_t) [(TTView*) self rowCount];
    NSPoint viewloc = [self convertPoint: [event locationInWindow]
                                fromView: nil];
    Position pos = [(TTView*) self displayPositionForPoint: viewloc];
    // The above method returns the position *including* scrollback,
    // so we have to compensate for that.
    pos.y -= scrollback;
    return pos;
}

- (BOOL) MouseTerm_buttonDown: (NSEvent*) event button: (MouseButton) button
{
    if ([self MouseTerm_shouldIgnore: event button: button])
        goto ignored;

    MTShell* shell = [[(TTView*) self controller] shell];
    switch ([shell MouseTerm_getMouseMode])
    {
    case NO_MODE:
    case HILITE_MODE:
        goto ignored;
    case NORMAL_MODE:
    case BUTTON_MODE:
    case ALL_MODE:
    {
        [shell MouseTerm_setIsMouseDown: YES];
        NSData* data = [self MouseTerm_codeForEvent: event
                                             button: button
                                             motion: NO];
        [(TTShell*) shell writeData: data];

        goto handled;
    }
    }

handled:
    [(TTView*) self clearTextSelection];
    return YES;
ignored:
    return NO;
}

- (BOOL) MouseTerm_buttonDragged: (NSEvent*) event button: (MouseButton) button
{
    if ([self MouseTerm_shouldIgnoreDown: event button: button])
        goto ignored;

    MTShell* shell = [[(TTView*) self controller] shell];
    switch ([shell MouseTerm_getMouseMode])
    {
    case NO_MODE:
        goto ignored;
    case NORMAL_MODE:
    case HILITE_MODE:
        goto handled;
    case BUTTON_MODE:
    case ALL_MODE:
    {
        NSData* data = [self MouseTerm_codeForEvent: event
                                             button: MOUSE_RELEASE
                                             motion: YES];
        [(TTShell*) shell writeData: data];
        goto handled;
    }
    }
handled:
    [(TTView*) self clearTextSelection];
    return YES;
ignored:
    return NO;
}

- (BOOL) MouseTerm_buttonUp: (NSEvent*) event button: (MouseButton) button
{
    if ([self MouseTerm_shouldIgnoreDown: event button: button])
        goto ignored;

    MTShell* shell = [[(TTView*) self controller] shell];
    switch ([shell MouseTerm_getMouseMode])
    {
    case NO_MODE:
    case HILITE_MODE:
        goto ignored;
    case NORMAL_MODE:
    case BUTTON_MODE:
    case ALL_MODE:
    {
        [shell MouseTerm_setIsMouseDown: NO];
        NSData* data = [self MouseTerm_codeForEvent: event
                                             button: MOUSE_RELEASE
                                             motion: NO];
        [(TTShell*) shell writeData: data];

        goto handled;
    }
    }
handled:
    [(TTView*) self clearTextSelection];
    return YES;
ignored:
    return NO;
}

- (void) MouseTerm_mouseDown: (NSEvent*) event
{
    MouseButton button;
    if ([event modifierFlags] & NSCommandKeyMask)
        button = MOUSE_BUTTON3;
    else
        button = MOUSE_BUTTON1;

    if (![self MouseTerm_buttonDown: event button: button])
        [self MouseTerm_mouseDown: event];
}

- (void) MouseTerm_mouseDragged: (NSEvent*) event
{
    MouseButton button;
    if ([event modifierFlags] & NSCommandKeyMask)
        button = MOUSE_BUTTON3;
    else
        button = MOUSE_BUTTON1;

    if (![self MouseTerm_buttonDragged: event button: button])
        [self MouseTerm_mouseDragged: event];
}

- (void) MouseTerm_mouseUp: (NSEvent*) event
{
    MouseButton button;
    if ([event modifierFlags] & NSCommandKeyMask)
        button = MOUSE_BUTTON3;
    else
        button = MOUSE_BUTTON1;

    if (![self MouseTerm_buttonUp: event button: button])
        [self MouseTerm_mouseUp: event];
}

- (void) MouseTerm_rightMouseDown: (NSEvent*) event
{
    if (![self MouseTerm_buttonDown: event button: MOUSE_BUTTON2])
        [self MouseTerm_rightMouseDown: event];
}

- (void) MouseTerm_rightMouseDragged: (NSEvent*) event
{
    if (![self MouseTerm_buttonDragged: event button: MOUSE_BUTTON2])
        [self MouseTerm_rightMouseDragged: event];
}

- (void) MouseTerm_rightMouseUp: (NSEvent*) event
{
    if (![self MouseTerm_buttonUp: event button: MOUSE_BUTTON2])
        [self MouseTerm_rightMouseUp: event];
}

- (void) MouseTerm_otherMouseDown: (NSEvent*) event
{
    if (![self MouseTerm_buttonDown: event button: MOUSE_BUTTON3])
        [self MouseTerm_otherMouseDown: event];
}

- (void) MouseTerm_otherMouseDragged: (NSEvent*) event
{
    if (![self MouseTerm_buttonDragged: event button: MOUSE_BUTTON3])
        [self MouseTerm_otherMouseDragged: event];
}

- (void) MouseTerm_otherMouseUp: (NSEvent*) event
{
    if (![self MouseTerm_buttonUp: event button: MOUSE_BUTTON3])
        [self MouseTerm_otherMouseUp: event];
}

// Intercepts all scroll wheel movements (one wheel "tick" at a time)
- (void) MouseTerm_scrollWheel: (NSEvent*) event
{
    TTLogicalScreen* screen = [(TTView*) self logicalScreen];
    MTShell* shell = [[(TTView*) self controller] shell];

    switch ([shell MouseTerm_getMouseMode])
    {
    case NO_MODE:
    {
        MTProfile* profile = [(TTTabController*) [(TTView*) self controller]
                                                 profile];
        if ([NSView MouseTerm_getEnabled] &&
            [profile MouseTerm_emulationEnabled] &&
            [screen isAlternateScreenActive] &&
            [shell MouseTerm_getAppCursorMode])
        {
            // Calculate how many lines to scroll by (takes acceleration
            // into account)
            NSData* data;
            // deltaY returns CGFloat, which can be float or double
            // depending on the architecture. Upcasting floats to doubles
            // seems like an easier compromise than detecting what the
            // type really is.
            double delta = [event deltaY];

            // Trackpads seem to return a lot of 0.0 events, which
            // shouldn't trigger scrolling anyway.
            if (delta == 0.0)
                goto handled;
            else if (delta < 0.0)
            {
                delta = fabs(delta);
                data = [NSData dataWithBytes: DOWN_ARROW_APP
                                      length: ARROW_LEN];
            }
            else
            {
                data = [NSData dataWithBytes: UP_ARROW_APP
                                      length: ARROW_LEN];
            }

            linecount_t i;
            linecount_t lines = lround(delta) + 1;
            for (i = 0; i < lines; ++i)
                [(TTShell*) shell writeData: data];

            goto handled;
        }
        else
            goto ignored;
    }
    // FIXME: Unhandled at the moment
    case HILITE_MODE:
        goto ignored;
    case NORMAL_MODE:
    case BUTTON_MODE:
    case ALL_MODE:
    {
        if ([self MouseTerm_shouldIgnore: event button: MOUSE_WHEEL_UP])
            goto ignored;

        MouseButton button;
        double delta = [event deltaY];
        if (delta == 0.0)
            goto handled;
        else if (delta < 0.0)
        {
            delta = fabs(delta);
            button = MOUSE_WHEEL_DOWN;
        }
        else
            button = MOUSE_WHEEL_UP;

        NSData* data = [self MouseTerm_codeForEvent: event
                                             button: button
                                             motion: NO];

        long i;
        long lines = lround(delta) + 1;
        for (i = 0; i < lines; ++i)
            [(TTShell*) shell writeData: data];

        goto handled;
    }
    }

handled:
    [(TTView*) self clearTextSelection];
    return;
ignored:
    [self MouseTerm_scrollWheel: event];
}

@end

