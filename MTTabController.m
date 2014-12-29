#import <Cocoa/Cocoa.h>
#import "Mouse.h"
#import "MTParser.h"
#import "MTShell.h"
#import "MTTabController.h"
#import "Terminal.h"

@implementation NSObject (MTTabController)

// Intercepts all shell output to look for mouse reporting control codes
- (void) MouseTerm_shellDidReceiveData: (NSData*) data
{
    NSUInteger length = [data length];
    char *chars = (char *)[data bytes];

    MTParser_execute(chars, length, [(TTTabController*) self shell]);

    [self MouseTerm_shellDidReceiveData: data];
}

@end
