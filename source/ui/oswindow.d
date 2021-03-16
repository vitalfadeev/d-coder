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

enum WPARAM IDT_TIMER1 = WM_USER + 1;

/** */
class OSWindow : IRas
{
    /** */
    this( int cd, int gh )
    {
        _cd = cd;
        _gh = gh;
        _createOSWindowClass();
        _createOSWindow();
        _setTimer();
    }


    /** */
    IPen pen()
    {
        return new OSWindowPen( this );
    }


    /** */
    //void sdsh( Point base )
    //{
    //    SetWindowOrgEx( _hdc, -base.d, base.h, NULL );
    //}


    /** */
    void ot( Point praot, int d, int h )
    {
        _ot.d = praot.d +  d;
        _ot.h = praot.h + -h;
    }


    /** */
    Point ot()
    {
        return _ot;
    }


    /** */
    Size cdgh()
    {
        return Size( _cd, _gh );
    }


    /** */
    void clear() nothrow
    {
        RECT crect;
        crect.left   = 0;
        crect.top    = 0;
        crect.right  = _cd;
        crect.bottom = _gh;

        //try {
            //writeln( crect );
        //} catch ( Throwable e ) { assert( 0, e.toString() ); }

        // Color
        HBRUSH brush = CreateSolidBrush( RGB( 0x00, 0x00, 0x0 ) );

        // Rect
        FillRect( _hdc, &crect, brush );

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
        RECT wrect = { 100, 100, 100 + _cd, 100 + _gh };
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

        // Show
        ShowWindow( hwnd, SW_NORMAL );
        UpdateWindow( hwnd );

        return hwnd;
    }


    /** */
    void _setTimer()
    {
        SetTimer( 
            hwnd,
            IDT_TIMER1,
            5,
            cast ( TIMERPROC ) NULL 
        );
    }


private:
    WNDCLASS wc;
    HWND     hwnd;
    HDC      _hdc;
    DWORD    style = STYLE_NORMAL | STYLE_RESIZABLE;
    DWORD    styleEx = 0;
    int      _cd;
    int      _gh;
    Point    _ot;


    // BackBuefer
    BackBuffer createBackBuffer() nothrow
    {
        auto backBuffer = new BackBuffer( _hdc, _cd, _gh );

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

                    window._hdc = BeginPaint( hwnd, &ps );


////find update area
//GetUpdateRect(hWnd, &rClientRect, 0);
//if (IsRectEmpty(&rClientRect))
//      GetClientRect(hWnd, &rClientRect);
//
//BitBlt(ps.hdc, rClientRect.left,  rClientRect.top,  rClientRect.right -  rClientRect.left,  rClientRect.bottom - rClientRect.top,
//  hdcScreen, rClientRect.left,  rClientRect.top, SRCCOPY);
    
                    version ( DoubleBuffer )
                    {
                        scope auto backBuffer = window.createBackBuffer();

                        // Clear
                        backBuffer.clear();

                        // Center
                        try {
                            auto p = Point( backBuffer._cd / 2, backBuffer._gh / 2 );
                            backBuffer.ot( p, 0, 0 );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }

                        // Drawing
                        try {
                            import ui.mag : set;
                            import ui.mag : vid;
                            set();
                            vid( backBuffer );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }


                        // Transfer the off-screen DC to the screen
                        backBuffer.blt( window );

                        backBuffer.removeBackbuffer();
                    }
                    else
                    {
                        //    +1
                        // -1  . +1
                        //    -1
                        SetGraphicsMode( window._hdc, GM_ADVANCED );
                        try {
                            auto p = Point( window._cd / 2, window._gh / 2 );
                            window.ot( p, 0, 0 );
                        } catch ( Throwable e ) { assert( 0, e.toString() ); }

                        // Drawing
                        window.clear();

                        try {
                            //root.vid( *window );
                            //vidPipe.vid( *window );
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

                case WM_KEYDOWN: {
                    try {
                        KeyboardKeyEvent event = { hwnd, message, wParam, lParam };
                        process( event );
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }
                    
                case WM_LBUTTONDOWN: {
                    try {
                        MouseKeyEvent event = { hwnd, message, wParam, lParam };
                        event.ras = *window;

                        // center
                        auto cdgh = window.cdgh();
                        event.to.d =    GET_X_LPARAM( lParam ) - cdgh.cd / 2;
                        event.to.h = -( GET_Y_LPARAM( lParam ) - cdgh.gh / 2 );
                        
                        //
                        process( event );

                        // update window
                        //InvalidateRect( hwnd, NULL, 0 );
                        //UpdateWindow( hwnd );

                        //auto curObject = root.objectAtPoint( event.point );
                        //if ( curObject !is null )
                        //{
                        //    window.callHierarhically!( "onLeftMouseDown" )( curObject, event );
                        //}
                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }
                    
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
                    
                case WM_MOUSEMOVE: {
                    try {
                        MouseMoveEvent event = { hwnd, message, wParam, lParam };
                        event.ras = *window;

                        // center
                        auto cdgh = window.cdgh();
                        event.to.d =    GET_X_LPARAM( lParam ) - cdgh.cd / 2;
                        event.to.h = -( GET_Y_LPARAM( lParam ) - cdgh.gh / 2 );
                        
                        //
                        process( event );

                        // update window
                        //InvalidateRect( hwnd, NULL, 0 );
                        //UpdateWindow( hwnd );

                    } catch ( Throwable e ) { assert( 0, e.toString() ); }
                    return 0;
                }
                    
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

                case WM_TIMER: {
                    if ( wParam == IDT_TIMER1 )
                    {
                        //InvalidateRect( hwnd, NULL, 0 );
                        RedrawWindow( hwnd, NULL, NULL, RDW_INVALIDATE | RDW_UPDATENOW );
                    }
                    break;
                }

                    
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
    this( OSWindow ras ) nothrow
    {
        this.ras  = ras;
        this._hdc = ras._hdc;
    }


    void init()
    {
        //
    }


    void ra( Ra ra )
    {
        this.ra( ra, 3 );
    }


    void ra( Ra ra, int cd )
    {
        HPEN hpen = CreatePen( PS_SOLID, cd, ra.windowsCOLORREF );
        auto praPen = SelectObject( _hdc, hpen );
        DeleteObject( praPen );
    }


    void to( int d, int h )
    {
        Point p = ras.ot + Point( d, h );
        MoveToEx( _hdc, p.d, p.h, NULL );
    }


    void lineTo( int d, int h )
    {
        Point p = ras.ot + Point( d, h );
        LineTo( _hdc, p.d, p.h );
    }


    void rectangle( int cd, int gh )
    {
        // Center ot the Vid
        Point ot = ras.ot;

        version ( Polyline )
        {
            // top left
            Point point = ot - Point( cd / 2, gh / 2 );

            SetPolyFillMode( _hdc, WINDING );
            auto brush = CreateSolidBrush( GetDCPenColor( _hdc ) );
            auto oldBrush = SelectObject( _hdc, brush ); 

            // rectangle cd x gh
            Point[5] points;
            points[0] = point + Point(  0,  0 );  // start
            points[1] = point + Point( cd,  0 );  // to right
            points[2] = point + Point( cd, gh );  // to bottom
            points[3] = point + Point(  0, gh );  // to left
            points[4] = point + Point(  0,  0 );  // to top
            Polyline( _hdc, cast( POINT* ) points.ptr, 5 );
        }
        else
        {
            RECT rect = { ot.d - cd/2, ot.h - gh/2, ot.d + cd/2, ot.h + gh/2 };
            auto brush = CreateSolidBrush( GetDCPenColor( _hdc ) );
            FrameRect( _hdc, &rect, brush );
            DeleteObject( brush );
        }

        //MoveToEx( _hdc, 0, 0, NULL );
        //LineTo( _hdc, 100, 100 );
    }


    void rectangle( int c, int h, int d, int g )
    {
        import std.math : abs;

        // Center ot the Vid
        Point point = ras.ot;

        // rectangle cd x gh
        Point[5] points;
        points[0] = point + Point( c, -h );  // start
        points[1] = point + Point( d, -h );  // to right
        points[2] = point + Point( d, -g );  // to bottom
        points[3] = point + Point( c, -g );  // to left
        points[4] = point + Point( c, -h );  // to top

        // 
        Polyline( _hdc, cast( POINT* ) points.ptr, 5 );
    }


    void rectangleFilled( int cd, int gh, Ra ra )
    {
        // Center ot the Vid
        Point p = ras.ot;

        // top left
        Point point = p - Point( cd / 2, gh / 2 );

        // rectangle cd x gh
        Point[5] points;
        points[0] = point + Point(  0,  0 );  // start
        points[1] = point + Point( cd,  0 );  // to right
        points[2] = point + Point( cd, gh );  // to bottom
        points[3] = point + Point(  0, gh );  // to left
        points[4] = point + Point(  0,  0 );  // to top

        // Fill Mode
        SetPolyFillMode( _hdc, WINDING );
        auto brush = CreateSolidBrush( ra.windowsCOLORREF );
        auto oldBrush = SelectObject( _hdc, brush ); 

        // 
        Polygon( _hdc, cast( POINT* ) points.ptr, 5 );

        // 
        SelectObject( _hdc, oldBrush ); 
        DeleteObject( brush);

        //MoveToEx( _hdc, 0, 0, NULL );
        //LineTo( _hdc, 100, 100 );
    }


    void rectangleFilled( int c, int h, int d, int g, Ra ra )
    {
        import std.math : abs;

        // Center ot the Vid
        Point point = ras.ot;

        // rectangle cd x gh
        Point[5] points;
        points[0] = point + Point( c, -h );  // start
        points[1] = point + Point( d, -h );  // to right
        points[2] = point + Point( d, -g );  // to bottom
        points[3] = point + Point( c, -g );  // to left
        points[4] = point + Point( c, -h );  // to top

        // Fill Mode
        SetPolyFillMode( _hdc, WINDING );
        auto brush = CreateSolidBrush( ra.windowsCOLORREF );
        auto oldBrush = SelectObject( _hdc, brush ); 

        // 
        //Polyline( _hdc, points.ptr, 5 );
        Polygon( _hdc, cast( POINT* ) points.ptr, 5 );

        // 
        SelectObject( _hdc, oldBrush ); 
        DeleteObject( brush);
    }


    void font( string name, uint size )
    {
        //
    }


    void symbol( wchar wc, int c, int h, int d, int g )
    {
        //
    }


    void text( string s, int cd, int gh, ref TextSet textSet )
    {
        _text_nowrap( s, cd, gh, textSet );
    }


    void _text_nowrap( string s, int cd, int gh, ref TextSet textSet )
    {
        import std.encoding : codePoints;
        import std.range    : lockstep;
        import ui.text      : LineSet;

        textSet.cdghs.length = s.length;

        int cur_c = 0;
        int cur_d = 0;
        int cur_g = 0;
        int cur_h = 0;
        int next_d = 0;
        int next_g = 0;

        int text_c = 0;
        int text_d = 0;
        int text_g = 0;
        int text_h = 0;
        size_t charsCount = 0;

        string line;
        int line_c = 0;
        int line_d = 0;
        int line_g = 0;
        int line_h = 0;
        size_t lineStart = 0;

        Size charcdgh;
        auto rectPtr = textSet.cdghs.ptr;

        foreach ( i, c; s.codePoints )
        {
            // char cd, gh
            _fontCharCDGH( cast( wchar ) c, charcdgh );

            next_d = cur_c + charcdgh.cd;
            next_g = cur_h - charcdgh.gh;

            // limit
            // wrap
            if ( next_d > cd )
            {
                // trim char rects
                textSet.cdghs.length = charsCount;
                // line
                line = s[ lineStart .. i ];
                line_d = cur_d;
                line_g = cur_g;
                textSet.lines ~= LineSet( line, line_c, line_d, line_g, line_h );
                // text
                text_d = max( text_d, line_d );
                text_g = line_g;
                textSet.c  = text_c;
                textSet.d  = text_d;
                textSet.cd = text_d - text_c;
                textSet.g  = text_g;
                textSet.h  = text_h;
                textSet.gh = text_h - text_g;
                break;
            }

            //
            cur_g = cur_h - charcdgh.gh;
            cur_d = cur_c - charcdgh.cd;

            // save char c, d, g, h
            rectPtr.c = cur_c;
            rectPtr.d = cur_d;
            rectPtr.g = cur_g;
            rectPtr.h = cur_h;

            // update cursor
            cur_c = cur_d;
            cur_h = cur_g;

            charsCount += 1;
            rectPtr += 1;
        }
    }


    void _text_wrap_char( string s, int cd, int gh, ref TextSet textSet )
    {
        //
    }


    ref uint cd()
    {
        return _cd;
    }


    ref uint gh()
    {
        return _gh;
    }


    OSWindow ras;
private:
    uint     _cd;
    uint     _gh;
    HDC      _hdc;

    void _fontCharCDGH( wchar wc, ref Size cdgh )
    {
        GetTextExtentPoint32( _hdc, cast( LPWSTR ) &wc, 1, &cdgh.windowsSIZE );
    }
}


/** */
class BackBuffer : IRas
{
    /** */
    this( HDC hdc, int cd, int gh ) nothrow
    {
        _cd = cd;
        _gh = gh;

        //try {
        //    writeln( cd );
        //    writeln( gh );
        //} catch ( Throwable e ) { assert( 0, e.toString() ); }

        //
        _hdc                = CreateCompatibleDC( hdc );
        backBufferBitmap    = CreateCompatibleBitmap( hdc, cd, gh );
        oldBackBufferBitmap = SelectObject( _hdc, backBufferBitmap );

        //    +1
        // -1  . +1
        //    -1
        SetGraphicsMode( _hdc, GM_ADVANCED );
        _ot.d = cd / 2;
        _ot.h = gh / 2;

        //
        _pen = new BackBufferPen( this );
    }


    /** */
    IPen pen()
    {
        return _pen;
    }


    /** */
    void ot( Point praot, int d, int h )
    {
        _ot.d = praot.d +  d;
        _ot.h = praot.h + -h;
    }


    /** */
    Point ot()
    {
        return _ot;
    }


    /** */
    Size cdgh()
    {
        return Size( _cd, _gh );
    }


    /** */
    void clear() nothrow
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
    void blt( OSWindow* window ) nothrow
    {
        BitBlt( window._hdc, 0, 0, _cd, _gh, _hdc, 0, 0, SRCCOPY );
    }


    /** */
    void removeBackbuffer() nothrow
    {
        SelectObject( _hdc, oldBackBufferBitmap );
        DeleteObject( backBufferBitmap );
        DeleteDC ( _hdc );
    }    


    HDC   _hdc;
private:
    uint  _cd;
    uint  _gh;
    Point _ot;

    HDC  oldBackBufferBitmap;
    HDC  backBufferBitmap;

    BackBufferPen _pen;
}



/** */
pragma( inline )
void emit( string method, T, ARGS... )( T This, ARGS args )
{
    import std.exception : enforce;
    mixin( "enforce( This )." ~  method ~ "( args );" );
}



/** */
class BackBufferPen : IPen
{
    this( BackBuffer ras ) nothrow
    {
        this._ras = ras;
        this._hdc = ras._hdc;
    }


    void init()
    {
        //
    }


    void ra( Ra ra )
    {
        this.ra( ra, 3 );
    }


    void ra( Ra ra, int cd )
    {
        HPEN hpen = CreatePen( PS_SOLID, cd, ra.windowsCOLORREF );
        auto praPen = SelectObject( _hdc, hpen );
        DeleteObject( praPen );
    }


    void to( int d, int h )
    {
        Point p = _ras.ot + Point( d, h );
        MoveToEx( _hdc, p.d, p.h, NULL );
    }


    void lineTo( int d, int h )
    {
        Point p = _ras.ot + Point( d, h );
        LineTo( _hdc, p.d, p.h );
    }


    void rectangle( int cd, int gh )
    {
        // Center ot the Vid
        Point ot = _ras.ot;

        version ( Polyline )
        {
            // top left
            Point p = ot - Point( cd / 2, gh / 2 );

            SetPolyFillMode( _hdc, WINDING );
            auto brush = CreateSolidBrush( GetDCPenColor( _hdc ) );
            auto oldBrush = SelectObject( _hdc, brush ); 

            // rectangle cd x gh
            Point[5] points;
            points[0] = p + Point(  0,  0 );  // start
            points[1] = p + Point( cd,  0 );  // to right
            points[2] = p + Point( cd, gh );  // to bottom
            points[3] = p + Point(  0, gh );  // to left
            points[4] = p + Point(  0,  0 );  // to top
            Polyline( _hdc, cast( POINT* ) points.ptr, 5 );
        }
        else
        {
            RECT rect = { 
                ot.d - cd/2, 
                ot.h - gh/2, 
                ot.d + cd/2, 
                ot.h + gh/2 
            };
            //auto brush = CreateSolidBrush( GetDCPenColor( _hdc ) );
            //auto brush = CreateSolidBrush( RGB( 0xCC, 0xCC, 0xCC ) );
            auto pen = GetCurrentObject( _hdc, OBJ_PEN );
            LOGPEN logpen;
            GetObject( pen, logpen.sizeof, &logpen );
            auto brush = CreateSolidBrush( logpen.lopnColor );
            FrameRect( _hdc, &rect, brush );
            DeleteObject( brush );
        }
    }


    void rectangle( int c, int h, int d, int g )
    {
        import std.math : abs;

        // Center ot the Vid
        Point ot = _ras.ot;

        version ( Polyline )
        {
            // rectangle cd x gh
            Point[5] points;
            points[0] = ot + Point( c, -h );  // start
            points[1] = ot + Point( d, -h );  // to right
            points[2] = ot + Point( d, -g );  // to bottom
            points[3] = ot + Point( c, -g );  // to left
            points[4] = ot + Point( c, -h );  // to top

            // 
            Polyline( _hdc, cast( POINT* ) points.ptr, 5 );
        }
        else
        {
            RECT rect = { 
                ot.d + c, 
                ot.h + h, 
                ot.d + d, 
                ot.h + g 
            };
            //auto brush = CreateSolidBrush( GetDCPenColor( _hdc ) );
            //auto brush = CreateSolidBrush( RGB( 0xCC, 0xCC, 0xCC ) );
            auto pen = GetCurrentObject( _hdc, OBJ_PEN );
            LOGPEN logpen;
            GetObject( pen, logpen.sizeof, &logpen );
            auto brush = CreateSolidBrush( logpen.lopnColor );
            FrameRect( _hdc, &rect, brush );
            DeleteObject( brush );
        }
    }


    void rectangleFilled( int cd, int gh, Ra ra )
    {
        // Center ot the Vid
        Point ot = _ras.ot;

        version ( Polyline )
        {
            // top left
            Point p = ot - Point( cd / 2, gh / 2 );

            // rectangle cd x gh
            Point[5] points;
            points[0] = p + Point(  0,  0 );  // start
            points[1] = p + Point( cd,  0 );  // to right
            points[2] = p + Point( cd, gh );  // to bottom
            points[3] = p + Point(  0, gh );  // to left
            points[4] = p + Point(  0,  0 );  // to top

            // Fill Mode
            SetPolyFillMode( _hdc, WINDING );
            auto brush = CreateSolidBrush( ra.windowsCOLORREF );
            auto oldBrush = SelectObject( _hdc, brush ); 

            // 
            Polygon( _hdc, cast( POINT* ) points.ptr, 5 );

            // 
            SelectObject( _hdc, oldBrush ); 
            DeleteObject( brush);
        }
        else
        {
            // Fill Mode
            auto brush = CreateSolidBrush( ra.windowsCOLORREF );
            auto oldBrush = SelectObject( _hdc, brush ); 

            Rectangle( 
                _hdc, 
                ot.d - cd/2, 
                ot.h - gh/2, 
                ot.d + cd/2, 
                ot.h + gh/2 
            );

            // 
            SelectObject( _hdc, oldBrush ); 
            DeleteObject( brush);
        }
    }


    void rectangleFilled( int c, int h, int d, int g, Ra ra )
    {
        import std.math : abs;

        // Center ot the Vid
        Point ot = _ras.ot;

        version ( Polyline )
        {
            // rectangle cd x gh
            Point[5] points;
            points[0] = ot + Point( c, -h );  // start
            points[1] = ot + Point( d, -h );  // to right
            points[2] = ot + Point( d, -g );  // to bottom
            points[3] = ot + Point( c, -g );  // to left
            points[4] = ot + Point( c, -h );  // to top

            // Fill Mode
            SetPolyFillMode( _hdc, WINDING );
            auto brush = CreateSolidBrush( ra.windowsCOLORREF );
            auto oldBrush = SelectObject( _hdc, brush ); 

            // 
            //Polyline( _hdc, points.ptr, 5 );
            Polygon( _hdc, cast( POINT* ) points.ptr, 5 );

            // 
            SelectObject( _hdc, oldBrush ); 
            DeleteObject( brush);
        }
        else
        {
            // Fill Mode
            auto brush = CreateSolidBrush( ra.windowsCOLORREF );
            auto oldBrush = SelectObject( _hdc, brush ); 

            Rectangle( 
                _hdc, 
                ot.d + c, 
                ot.h + h, 
                ot.d + d, 
                ot.h + g 
            );

            // 
            SelectObject( _hdc, oldBrush ); 
            DeleteObject( brush);            
        }
    }


    void symbol( wchar wc, int c, int h, int d, int g )
    {
        import std.math : abs;

        // Center ot the Vid
        Point ot = _ras.ot;

        RECT rect = {
            ot.d + c, 
            ot.h + h, 
            ot.d + d, 
            ot.h + g 
        };

        HFONT font = Font( "Arial", abs( g ) + abs( h ) ).toWindowsFont();
        HFONT prafont = SelectObject( _hdc, font );

        ExtTextOutW(
            _hdc,
            rect.left,
            rect.top,
            0,
            &rect,
            cast( LPCWSTR ) &wc,
            1,
            NULL
        );

        SelectObject( _hdc, prafont );
        DeleteObject( font );
    }


    void text( string s, int cd, int gh, ref TextSet textSet )
    {
        //
    }


    ref uint cd()
    {
        return _cd;
    }


    ref uint gh()
    {
        return _gh;
    }


private:
    uint _cd;
    uint _gh;
    HDC  _hdc;
    BackBuffer _ras;
}
