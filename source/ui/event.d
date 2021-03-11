module ui.event;

import core.sys.windows.windows;
import ui : Point;
import ui : GET_X_LPARAM;
import ui : GET_Y_LPARAM;
import ui : IRas;
//import ui.tools : GET_WHEEL_DELTA_WPARAM;


mixin template ControlKeys()
{
    pragma( inline )
    bool ctrlPressed()
    {
        return GetKeyState( VK_LCONTROL ) < 0 || GetKeyState( VK_RCONTROL ) < 0; // Hight-Order bit
    }


    pragma( inline )
    bool altPressed()
    {
        return GetKeyState( VK_MENU ) < 0; // Hight-Order bit
    }


    pragma( inline )
    bool shiftPressed()
    {
        return GetKeyState( VK_LSHIFT ) < 0 || GetKeyState( VK_RSHIFT ) < 0; // Hight-Order bit
    }


    pragma( inline )
    bool winPressed()
    {
        return GetKeyState( VK_LWIN ) < 0 || GetKeyState( VK_RWIN ) < 0; // Hight-Order bit
    }

    /** */
    uint controlKeys()
    {
        return 
            ( ctrlPressed  () << 1 )
         && ( altPressed   () << 2 )
         && ( shiftPressed () << 3 )
         && ( winPressed   () << 4 );
    }
}


struct MouseKeyEvent
{
    HWND   hwnd;
    UINT   message;
    WPARAM wParam;
    LPARAM lParam;
    Point  to;
    IRas   ras;

    alias wParam code;

    mixin ControlKeys;


    bool leftKeyPressed()
    {
        return ( wParam & MK_LBUTTON ) != 0;
    }


    bool rightKeyPressed()
    {
        return ( wParam & MK_RBUTTON ) != 0;
    }


    bool middleKeyPressed()
    {
        return ( wParam & MK_MBUTTON ) != 0;
    }


    bool x1KeyPressed()
    {
        return ( wParam & MK_XBUTTON1 ) != 0;
    }


    bool x2KeyPressed()
    {
        return ( wParam & MK_XBUTTON2 ) != 0;
    }


    //bool ControlKeyPressed()
    //{
    //    return ( wParam &= MK_CONTROL ) != 0;
    //}


    //bool ShiftKeyPressed()
    //{
    //    return ( wParam &= MK_SHIFT ) != 0;
    //}
}


struct MouseMoveEvent
{
    HWND   hwnd;
    UINT   message;
    WPARAM wParam;
    LPARAM lParam;
    Point  to;
    IRas   ras;

    alias wParam code;

    mixin ControlKeys;


    bool leftKeyPressed()
    {
        return ( wParam & MK_LBUTTON ) != 0;
    }


    bool rightKeyPressed()
    {
        return ( wParam & MK_RBUTTON ) != 0;
    }


    bool middleKeyPressed()
    {
        return ( wParam & MK_MBUTTON ) != 0;
    }


    bool x1KeyPressed()
    {
        return ( wParam & MK_XBUTTON1 ) != 0;
    }


    bool x2KeyPressed()
    {
        return ( wParam & MK_XBUTTON2 ) != 0;
    }


    //bool ControlKeyPressed()
    //{
    //    return ( wParam &= MK_CONTROL ) != 0;
    //}


    //bool ShiftKeyPressed()
    //{
    //    return ( wParam &= MK_SHIFT ) != 0;
    //}
}


/** */
struct KeyboardKeyEvent
{
    HWND   hwnd;
    UINT   message;
    WPARAM wParam;
    LPARAM lParam;

    alias wParam code;


    /** */
    uint scanCode()
    {
        //uint scanCode = lParam & 0b00000000_11111111_00000000_00000000; // 16-23 bits
        //scanCode >>= 16;
        //return scanCode;
        return HIWORD( lParam ) & 0b00000000_11111111;
    }


    mixin ControlKeys;


    /** */
    pragma( inline )
    bool isExtended()
    {
        return ( lParam & 0b00000001_00000000_00000000_00000000 ) != 0; // 24 bit
    }


    /** */
    dchar toDChar()
    {
        return .toDChar( this );
    }
}


struct MouseWheelEvent
{
    HWND   hwnd;
    UINT   message;
    WPARAM wParam;
    LPARAM lParam;
    Point  _point;

    alias wParam code;


    mixin ControlKeys;


    int delta()
    {
        return GET_WHEEL_DELTA_WPARAM( wParam );
    }


    Point point()
    {
        _point.d = GET_X_LPARAM( lParam );
        _point.h = GET_Y_LPARAM( lParam );
        return _point;
    }
}


/** */
pragma( inline )
ulong KeyEventHasher( ref KeyboardKeyEvent event )
{
    ulong hash = event.code;

    /** */
    enum ControlKey : ulong
    {
        NONE  = 0b00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000,
        CTRL  = 0b00000001_00000000_00000000_00000000_00000000_00000000_00000000_00000000,
        ALT   = 0b00000010_00000000_00000000_00000000_00000000_00000000_00000000_00000000,
        SHIFT = 0b00000100_00000000_00000000_00000000_00000000_00000000_00000000_00000000,
        WIN   = 0b00001000_00000000_00000000_00000000_00000000_00000000_00000000_00000000
    }

    if ( event.ctrlPressed )
        hash |= ControlKey.CTRL;

    if ( event.altPressed )
        hash |= ControlKey.ALT;

    if ( event.shiftPressed )
        hash |= ControlKey.SHIFT;

    if ( event.winPressed )
        hash |= ControlKey.WIN;

    return hash;
}


/** */
pragma( inline )
dchar toDChar( ref KeyboardKeyEvent event )
{
    import std.utf : toUTF32;
    import std.utf : decode;
    import std.uni : isControl;

    // Insert char into text
    if ( !event.altPressed )
    if ( !event.ctrlPressed )
    if ( !event.winPressed )
    if ( !event.isExtended )
    if ( event.code )
    {
        // To Unicode
        ubyte[ 256 ] keyState;
        GetKeyboardState( keyState.ptr );

        wchar[ 8 ] wszBuff;
        int cchBuff = 8;

        // bit 0 is set, a menu is active..  
        // bit 2 is set, keyboard state is not changed (Windows 10, version 1607 and newer)
        uint wFlags;

        int nChars = 
            ToUnicode( cast( uint ) event.wParam, event.scanCode, keyState.ptr, wszBuff.ptr, cchBuff, wFlags );

        if ( nChars == -1 )
        {
            return 0;  // SKIP
        }
        else
        if ( nChars == 0 )
        {
            return 0;  // SKIP
        }
        else
        {
            // OK
            // Convert to UTF-32 Char
            dchar dc;
            size_t i;

            if ( event.code == VK_RETURN )
                dc = '\n';
            else
                dc = wszBuff[ 0 .. nChars ].decode( i );

            // Skip Control Chars
            if ( dc.isControl && ( event.code != VK_RETURN ) )
            {
                return 0;  // SKIP
            }
            else
            {
                return dc;  // OK
            }
        }
    }

    return 0;  // FAIL
}