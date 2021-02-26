module ui.oswindow;

import core.sys.windows.windows;
import ui;

pragma( lib, "user32.lib" );
pragma( lib, "gdi32.lib" ); 


//
enum DWORD STYLE_BASIC               = ( WS_CLIPSIBLINGS | WS_CLIPCHILDREN );
enum DWORD STYLE_FULLSCREEN          = ( WS_POPUP );
enum DWORD STYLE_BORDERLESS          = ( WS_POPUP );
enum DWORD STYLE_BORDERLESS_WINDOWED = ( WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX );
enum DWORD STYLE_NORMAL              = ( WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX );
enum DWORD STYLE_RESIZABLE           = ( WS_THICKFRAME | WS_MAXIMIZEBOX );
enum DWORD STYLE_MASK                = ( STYLE_FULLSCREEN | STYLE_BORDERLESS | STYLE_NORMAL | STYLE_RESIZABLE );


/** */
class OSWindow : IRas
{
    /** */
    this()
    {
        _createOSWindowClass();
        _createOSWindow();
    }


    /** */
    IPen pen()
    {
        return new OSWindowPen( hdc );
    }


    /** */
    void clear() nothrow
    {
        RECT crect;
        GetClientRect( hwnd, &crect );

        HBRUSH brush = CreateSolidBrush( RGB( 0x00, 0x00, 0x0 ) );

        FillRect( hdc, &crect, brush );

        DeleteObject( brush );
    }


    //
    /** */
    void _createOSWindowClass()
    {   
        import std.file : thisExePath;
        import std.path : baseName;

        static size_t windowNum;

        windowNum += 1;

        auto classname = 
            format!
                "%s-%d"
                ( baseName( thisExePath ),
                  windowNum 
                )
                .toLPWSTR;

        if ( GetClassInfo( GetModuleHandle( NULL ), classname, &wc ) )
        {
            // class exists
            if ( wc.lpfnWndProc != &WindowProc )
            {
                throw new Exception( "Error when window class creation: class exists: " ~ classname.to!string );
            }
        }
        else
        {
            wc.style         = CS_HREDRAW | CS_VREDRAW;
            wc.lpfnWndProc   = &WindowProc;
            wc.cbClsExtra    = 0;
            wc.cbWndExtra    = 0;
            wc.hInstance     = GetModuleHandle( NULL );
            wc.hIcon         = LoadIcon( NULL, IDI_APPLICATION );
            wc.hCursor       = LoadCursor( NULL, IDC_ARROW );
            wc.hbrBackground = NULL;
            wc.lpszMenuName  = NULL;
            wc.lpszClassName = classname;

            if ( !RegisterClass( &wc ) )
                throw new Exception( "Error when window class creation" );
        }
    }


    /** */
    HWND _createOSWindow()
    {
        // Bordered Rectamgle
        RECT wrect = { 100, 100, 400, 300 };
        AdjustWindowRectEx( &wrect, style, false, styleEx );

        //
        hwnd = 
            CreateWindowEx( 
                styleEx, 
                wc.lpszClassName,         // window class name
                "windowName".toLPWSTR,    // window caption
                style,                    //  0x00000008
                wrect.left,               // initial x position
                wrect.top,                // initial y position
                wrect.right - wrect.left, // initial x size
                wrect.bottom - wrect.top, // initial y size
                NULL,                     // parent window handle
                NULL,                     // window menu handle
                GetModuleHandle( NULL ),  // program instance handle
                cast ( void* ) this
            );

        _rememberWindow( hwnd, this );

        ShowWindow( hwnd, SW_NORMAL );
        UpdateWindow( hwnd );

        return hwnd;
    }


private:
    WNDCLASS wc;
    HWND     hwnd;
    HDC      hdc;
    DWORD    style = STYLE_NORMAL | STYLE_RESIZABLE;
    DWORD    styleEx = 0;


    // BackBuefer
    BackBuffer createBackBuffer() nothrow
    {
        RECT crect;
        GetClientRect( hwnd, &crect );

        auto backBuffer = new BackBuffer( hdc, crect.right, crect.bottom );

        return backBuffer;
    }


    // Windows Created by UI
    static OSWindow[ HWND ] _windows;

    static
    void _rememberWindow( HWND hwnd, OSWindow window )
    {
        _windows[ hwnd ] = window;
    }

    static
    auto _recallWindow( HWND hwnd )
    {
        return hwnd in _windows;
    }


    static
    auto _forgetWindow( HWND hwnd )
    {
        _windows.remove( hwnd );
    }


    // Default Window Proc
    static extern ( Windows )
    LRESULT WindowProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) nothrow
    {
        PAINTSTRUCT ps;
        OSWindow*   window;

        //
        //if ( message == WM_CREATE )
        //    window = cast( OSWindow* ) ( cast( CREATESTRUCT* ) lParam ).lpCreateParams;
        //else
            window = _recallWindow( hwnd );

        //
        if ( window )
        {
            switch ( message )
            {
                // window unaccessable
                //case WM_CREATE: {
                //    try {
                //        //writeln( "onCreated() 1: ", hwnd, ": ", window );
                //        //emit!"onCreated"( window );
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                case WM_PAINT: {
                    version ( DebugCalls ) Writeln( __FUNCTION__, ": WM_PAINT" );
                    //
                    version ( TestRenderTime )
                    {            
                        import core.time;
                        MonoTime t;
                        auto testRenderStartTime = t.currTime;
                    }

                    window.hdc = BeginPaint( hwnd, &ps );

////find update area
//GetUpdateRect(hWnd, &rClientRect, 0);
//if (IsRectEmpty(&rClientRect))
//      GetClientRect(hWnd, &rClientRect);
//
//BitBlt(ps.hdc, rClientRect.left,  rClientRect.top,  rClientRect.right -  rClientRect.left,  rClientRect.bottom - rClientRect.top,
//  hdcScreen, rClientRect.left,  rClientRect.top, SRCCOPY);
    
                    version( DoubleBuffer )
                    {
                        auto backBuffer = window.createBackBuffer();

                        // Drawing
                        backBuffer.clear();

                        try {
                            root.vid( backBuffer );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }


                        // Transfer the off-screen DC to the screen
                        backBuffer.blt( window );
                    }
                    else
                    {
                        RECT crect;
                        GetClientRect( hwnd, &crect );

                        // Drawing
                        window.clear();

                        try {
                            root.vid( *window );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    }

                    //
                    EndPaint( hwnd, &ps );

                    //
                    version( TestRenderTime )
                    {            
                        Writeln( t.currTime - testRenderStartTime );
                    }

                    return 0;
                }
                    
                //case WM_SYSKEYDOWN: 
                //    goto case WM_KEYDOWN;

                //case WM_KEYDOWN: {
                //    try {
                //        KeyEvent event = { hwnd, message, wParam, lParam };
                //        emit!"onKeyDown"( window, event );
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_LBUTTONDOWN : {
                //    try {
                //        MouseKeyEvent event = { hwnd, message, wParam, lParam };
                //        auto curObject = window.objectAtPoint( event.point );
                //        if ( curObject !is null )
                //        {
                //            window.callHierarhically!( "onLeftMouseDown" )( curObject, event );
                //        }
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_RBUTTONDOWN : {
                //    try {
                //        MouseKeyEvent event = { hwnd, message, wParam, lParam };
                //        //auto curObject = window.objectAtPointVSB( event.point );
                //        auto curObject = window.objectAtPoint( event.point );
                //        if ( curObject !is null )
                //        {
                //            window.callHierarhically!( "onRightMouseDown" )( curObject, event );
                //        }
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_LBUTTONUP : {
                //    try {
                //        MouseKeyEvent event = { hwnd, message, wParam, lParam };
                //        //auto curObject = window.objectAtPointVSB( event.point );
                //        auto curObject = window.objectAtPoint( event.point );
                //        if ( curObject !is null )
                //        {
                //            window.callHierarhically!( "onLeftMouseUp" )( curObject, event );
                //        }
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_MOUSEMOVE: {
                //    try {
                //        MouseMoveEvent event = { hwnd, message, wParam, lParam };
                //        //auto curObject = window.objectAtPointVSB( event.point );
                //        auto curObject = window.objectAtPoint( event.point );
                //        if ( curObject !is null )
                //        {
                //            //// hoverColor
                //            //foreach( obj; window.hovers )
                //            //{
                //            //    obj.redraw();
                //            //}
                //            //window.hovers = [];
                //            //window.hovers ~= curObject;
                //            window.callHierarhically!( "onMouseMove" )( curObject, event );
                //        }
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_MOUSEWHEEL: {
                //    try {
                //        MouseWheelEvent event = { hwnd, message, wParam, lParam };
                //        //auto curObject = window.objectAtPointVSB( event.point );
                //        auto curObject = window.objectAtPoint( event.point );
                //        if ( curObject !is null )
                //        {
                //            window.callHierarhically!( "onMouseWheel" )( curObject, event );
                //        }
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_SIZE: {
                //    try {
                //        Rect clientRect;
                //        GetClientRect( hwnd, cast( RECT* ) clientRect );

                //        window.selfArea.rect.size( clientRect.width, clientRect.height );

                //        emit!"onSize"( window, clientRect.width, clientRect.height );

                //        window.redraw();
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_MOVE: {
                //    try {
                //        emit!"onMove"( window, LOWORD( lParam ), HIWORD( lParam ) );
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                //case WM_ACTIVATE: {
                //    try {
                //        if ( LOWORD( wParam ) == WA_INACTIVE )
                //            emit!"onDeactivate"( window );
                //        else
                //            emit!"onActivate"( window );
                //    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                //    return 0;
                //}
                    
                case WM_CLOSE: {
                    try {
                        //emit!"onClose"( window );
                        DestroyWindow( hwnd );
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }
                    
                case WM_DESTROY: {
                    try {
                        _forgetWindow( hwnd );

                        //if ( window.parent )
                        //    window.removeFromParent();

                        //if ( window.quitOnClose )
                        //    PostQuitMessage( 0 );

                        PostQuitMessage( 0 );
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    
                    return 0;
                }
                    
                default:
            }
        }

        return DefWindowProc( hwnd, message, wParam, lParam );
    }
}


/** */
class OSWindowPen : IPen
{
    this( HDC hdc ) nothrow
    {
        _hdc = hdc;
    }


    void init()
    {
        //
    }


    void cursTo( int cd, int gh )
    {
        MoveToEx( _hdc, cd, gh, NULL );
    }


    void lineTo( int cd, int gh )
    {
        LineTo( _hdc, cd, gh );
    }


    void rectangle( int cd, int gh )
    {
        // rectangle cd x gh
        lineTo( -cd,   0 ); 
        lineTo(   0,  gh );
        lineTo(  cd,   0 );
        lineTo(   0, -gh );
    }


    ref int cd()
    {
        return _cd;
    }


    ref int gh()
    {
        return _gh;
    }


private:
    int _cd;
    int _gh;
    HDC _hdc;
}


/** */
class BackBuffer : IRas
{
    /** */
    this( HDC hdc, int cd, int gh ) nothrow
    {
        _hdc                = CreateCompatibleDC( hdc );
        backBufferBitmap    = CreateCompatibleBitmap( hdc, cd, gh );
        oldBackBufferBitmap = SelectObject( hdc, backBufferBitmap );

        _cd = cd;
        _gh = gh;
        _pen = new OSWindowPen( _hdc );
    }


    /** */
    IPen pen()
    {
        return _pen;
    }


    /** */
    void clear()
    {
        RECT rect;
        rect.right  = _cd;
        rect.bottom = _gh;

        //HBRUSH brush = CreateSolidBrush( RGB( 0x44, 0x44, 0x44 ) );
        HBRUSH brush = CreateSolidBrush( RGB( 0x00, 0x00, 0x0 ) );

        FillRect( _hdc, &rect, brush );

        DeleteObject( brush );
    }


    // Transfer the off-screen DC to the screen
    void blt( HDC hdc ) nothrow
    {
        BitBlt( hdc, 0, 0, _cd, _gh, _hdc, 0, 0, SRCCOPY );
    }


    /** */
    void removeBackbuffer() nothrow
    {
        SelectObject( _hdc, oldBackBufferBitmap );
        DeleteObject( backBufferBitmap );
        DeleteDC ( _hdc );
    }    


private:
    HDC  _hdc;
    uint _cd;
    uint _gh;

    HDC  oldBackBufferBitmap;
    HDC  backBufferBitmap;

    OSWindowPen _pen;
}



/** */
pragma( inline )
void emit( string method, T, ARGS... )( T This, ARGS args )
{
    import std.exception : enforce;
    mixin( "enforce( This )." ~  method ~ "( args );" );
}


