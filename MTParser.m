#import <Cocoa/Cocoa.h>
#import "MTParser.h"
#import "MTShell.h"
#import "MTView.h"

static void init_param(struct parse_context *ppc)
{
    ppc->params_index = 0;
    ppc->current_param = 0;
}

static void push(struct parse_context *ppc)
{
    if (ppc->params_index < param_bufsize)
        ppc->params[ppc->params_index++] = ppc->current_param;
    ppc->current_param = 0;
}

static void param(struct parse_context *ppc, const char *p)
{
    if (ppc->current_param < 6554)
        ppc->current_param = ppc->current_param * 10 + *p - 0x30;
}

static void init_action(struct parse_context *ppc)
{
    ppc->action = 0;
}

static void collect(struct parse_context *ppc, const char *p)
{
    ppc->action = ppc->action << 8 | *p;
    if (ppc->action > 0x40 << 24) {
        ppc->action = (-1);
    }
}

#if 0
static void handle_ris(struct parse_context *ppc, MTShell *shell)
{
    [shell MouseTerm_setAppCursorMode: NO];
    [shell MouseTerm_setMouseMode: NO_MODE];
    [shell MouseTerm_setMouseProtocol: NORMAL_PROTOCOL];
}
#endif

static void enable_extended_mode(struct parse_context *ppc, MTShell *shell)
{
    int i;

    for (i = 0; i < ppc->params_index; ++i) {
        switch (ppc->params[i]) {
        case 1:
            [shell MouseTerm_setAppCursorMode: YES];
            break;
        case 1000:
            [shell MouseTerm_setMouseMode: NORMAL_MODE];
            break;
        case 1001:
            [shell MouseTerm_setMouseMode: HILITE_MODE];
            break;
        case 1002:
            [shell MouseTerm_setMouseMode: BUTTON_MODE];
            break;
        case 1003:
            [shell MouseTerm_setMouseMode: ALL_MODE];
            break;
        case 1006:
            [shell MouseTerm_setMouseProtocol: SGR_PROTOCOL];
            break;
        case 1015:
            [shell MouseTerm_setMouseProtocol: URXVT_PROTOCOL];
            break;
        default:
            break;
        }
    }
}

static void disable_extended_mode(struct parse_context *ppc, MTShell *shell)
{
    int i;

    for (i = 0; i < ppc->params_index; ++i) {
        switch (ppc->params[i]) {
        case 1:
            [shell MouseTerm_setAppCursorMode: NO];
            break;
        case 1000:
        case 1001:
        case 1002:
        case 1003:
            [shell MouseTerm_setMouseMode: NO_MODE];
            break;
        case 1006:
        case 1015:
            [shell MouseTerm_setMouseProtocol: NORMAL_PROTOCOL];
            break;
        default:
            break;
        }
    }
}

static void esc_dispatch(struct parse_context *ppc, MTShell *shell)
{
    switch (ppc->action) {
#if 0
    case 'c':
        handle_ris(ppc, shell);
        break;
#endif
    default:
        break;
    }
}

static void csi_dispatch(struct parse_context *ppc, char *p, MTShell *shell)
{
    switch (ppc->action) {
    case ('>' << 8) | 'c':
        [(TTShell*) shell writeData: [NSData dataWithBytes: SDA_RESPONSE
                                                    length: SDA_RESPONSE_LEN]];
        *p = 0x7f;
        break;
    case ('?' << 8) | 'h':
        enable_extended_mode(ppc, shell);
        break;
    case ('?' << 8) | 'l':
        disable_extended_mode(ppc, shell);
        break;
    default:
        break;
    }
}

int MTParser_execute(char* data, int len, MTShell *shell)
{
    char *p = data;
    struct parse_context *ppc = [shell MouseTerm_getParseContext];
    if (!ppc) {
        return 0;
    }

    for (p = data; p != data + len; ++p) {
        switch (ppc->state) {
        case PS_GROUND:
            switch (*p) {
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            default:
                break;
            }
            break;
        case PS_ESCAPE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                init_action(ppc);
                ppc->state = PS_ESCAPE_INTERMEDIATE;
                break;
            case 0x30 ... 0x4f:
                init_action(ppc);
                ppc->state = PS_GROUND;
                break;
            case 0x50:
                ppc->state = PS_DCS_ENTRY;
                break;
            case 0x51 ... 0x57:
                init_action(ppc);
                ppc->state = PS_GROUND;
                break;
            case 0x58:
                init_action(ppc);
                ppc->state = PS_SOS_PM_APC_STRING;
                break;
            case 0x59 ... 0x5a:
                init_action(ppc);
                ppc->state = PS_GROUND;
                break;
            case 0x5b:
                init_action(ppc);
                ppc->state = PS_CSI_ENTRY;
                break;
            case 0x5c:
                ppc->state = PS_GROUND;
                break;
            case 0x5d:
                ppc->state = PS_OSC_STRING;
                break;
            case 0x5e ... 0x5f:
                init_action(ppc);
                ppc->state = PS_SOS_PM_APC_STRING;
                break;
            case 0x60 ... 0x7e:
                init_action(ppc);
                collect(ppc, p);
                esc_dispatch(ppc, shell);
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_ESCAPE_INTERMEDIATE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                collect(ppc, p);
                break;
            case 0x30 ... 0x7e:
                collect(ppc, p);
                esc_dispatch(ppc, shell);
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_CSI_ENTRY:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                init_param(ppc);
                collect(ppc, p);
                ppc->state = PS_CSI_INTERMEDIATE;
                break;
            case 0x30 ... 0x39:
                init_param(ppc);
                param(ppc, p);
                ppc->state = PS_CSI_PARAM;
                break;
            case 0x3a:
                ppc->state = PS_CSI_IGNORE;
                break;
            case 0x3b:
                init_param(ppc);
                push(ppc);
                ppc->state = PS_CSI_PARAM;
                break;
            case 0x3c ... 0x3f:
                init_param(ppc);
                collect(ppc, p);
                ppc->state = PS_CSI_PARAM;
                break;
            case 0x40 ... 0x7e:
                init_param(ppc);
                collect(ppc, p);
                csi_dispatch(ppc, p, shell);
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_CSI_PARAM:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                collect(ppc, p);
                ppc->state = PS_CSI_INTERMEDIATE;
                break;
            case 0x30 ... 0x39:
                param(ppc, p);
                break;
            case 0x3a:
                ppc->state = PS_CSI_IGNORE;
                break;
            case 0x3b:
                push(ppc);
                break;
            case 0x3c ... 0x3f:
                ppc->state = PS_CSI_IGNORE;
                break;
            case 0x40 ... 0x7e:
                push(ppc);
                collect(ppc, p);
                csi_dispatch(ppc, p, shell);
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_CSI_INTERMEDIATE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                collect(ppc, p);
                break;
            case 0x30 ... 0x3f:
                ppc->state = PS_CSI_IGNORE;
                break;
            case 0x40 ... 0x7e:
                collect(ppc, p);
                csi_dispatch(ppc, p, shell);
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_CSI_IGNORE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x3f:
                break;
            case 0x40 ... 0x7e:
                ppc->state = PS_GROUND;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_DCS_ENTRY:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                init_param(ppc);
                collect(ppc, p);
                ppc->state = PS_DCS_INTERMEDIATE;
                break;
            case 0x30 ... 0x39:
                init_param(ppc);
                param(ppc, p);
                ppc->state = PS_DCS_PARAM;
                break;
            case 0x3a:
                ppc->state = PS_DCS_IGNORE;
                break;
            case 0x3b:
                init_param(ppc);
                push(ppc);
                ppc->state = PS_DCS_PARAM;
                break;
            case 0x3c ... 0x3f:
                collect(ppc, p);
                ppc->state = PS_DCS_PARAM;
                break;
            case 0x40 ... 0x7e:
                init_param(ppc);
                collect(ppc, p);
                ppc->state = PS_DCS_PASSTHROUGH;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_DCS_PARAM:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                collect(ppc, p);
                ppc->state = PS_DCS_INTERMEDIATE;
                break;
            case 0x30 ... 0x39:
                param(ppc, p);
                ppc->state = PS_DCS_PARAM;
                break;
            case 0x3a:
                ppc->state = PS_DCS_IGNORE;
                break;
            case 0x3b:
                push(ppc);
                ppc->state = PS_DCS_PARAM;
                break;
            case 0x3c ... 0x3f:
                ppc->state = PS_DCS_IGNORE;
                break;
            case 0x40 ... 0x7e:
                collect(ppc, p);
                ppc->state = PS_DCS_PASSTHROUGH;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_DCS_INTERMEDIATE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x1c ... 0x1f:
                break;
            case 0x20 ... 0x2f:
                collect(ppc, p);
                break;
            case 0x30 ... 0x3f:
                ppc->state = PS_DCS_IGNORE;
                break;
            case 0x40 ... 0x7e:
                collect(ppc, p);
                ppc->state = PS_DCS_PASSTHROUGH;
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_DCS_PASSTHROUGH:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x20 ... 0x7e:
                break;
            case 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_DCS_IGNORE:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x20 ... 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_OSC_STRING:
            switch (*p) {
            case 0x00 ... 0x06:
                break;
            case 0x07:
                ppc->state = PS_GROUND;
                break;
            case 0x08 ... 0x17:
                break;
            case 0x18:
                init_action(ppc);
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                init_action(ppc);
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x20 ... 0x7f:
                break;
            default:
                break;
            }
            break;
        case PS_SOS_PM_APC_STRING:
            switch (*p) {
            case 0x00 ... 0x17:
                break;
            case 0x18:
                ppc->state = PS_GROUND;
                break;
            case 0x19:
                break;
            case 0x1a:
                ppc->state = PS_GROUND;
                break;
            case 0x1b:
                ppc->state = PS_ESCAPE;
                break;
            case 0x20 ... 0x7f:
                break;
            default:
                break;
            }
            break;
        }
    }
    return 0;
}

/* EOF */
