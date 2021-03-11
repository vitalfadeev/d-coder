import std.stdio;

import ui;
import ui.oswindow : OSWindow;


void main()
{
	auto list = new List();
    list.set();
    
    //
    list.c = 1.px;
    list.cd = 100.px;
    list.gh = 100.px;
    list.compute_c_d_cd();
    list.compute_g_h_gh();

/*
    //
    import ui.files : Files;
    auto files = new Files();
    //files.read( "." );

    //
    import ui.list : ListItem;
    ListItem li;
    li = new ListItem();
    list.om( li );
    
    li = new ListItem();
    list.om( li );
    
    li = new ListItem();
    list.om( li );

    // Thread locals
    Root root1;
    root = root1 = new Root();
    root.om( list );
*/

    version ( IN )
    {
        // Thread locals
        MyRoot root1;
        root = root1 = new MyRoot();

        VidPipe vidPipe1;
        vidPipe = vidPipe1 = new VidPipe();

        // Box
        import ui.box : Box;
        auto b1 = new Box();
        b1.cd = 400.px;
        b1.gh = 400.px;
        root1.om( b1 );

        // Magnet 1
        import ui.magnet : Magnet;
        auto m1 = new Magnet();
        m1.cd = 100.px;
        m1.gh = 100.px;
        m1.otd = 50;
        b1.om( m1 );

        root1.set();
    }
    else
    {
        import ui.mag : mag_app;
        mag_app();
    }

    auto ras = new MyWindow( 640, 480 );

    // Event loop
    eventLoop();
}


bool doLoop = true;

/** */
void eventLoop()
{
    import core.sys.windows.windows;

    MSG msg;

   while ( doLoop && GetMessage( &msg, NULL, 0, 0 ) )
   {
       //TranslateMessage( &msg );
       DispatchMessage( &msg );
   }
}


/** */
class MyWindow : OSWindow
{
    this( int cd, int gh )
    {
        super( cd, gh );
    }
}


/** */
class MyRoot : Vid, IRoot
{
    /** */
    override
    void set()
    {
        vos.set();
        //set_magnets();
    }


    /** */
    void set_magnets()
    {
        import ui.magnet : Magnet;
        import ui.magnet : TO;

        Magnet m1 = null;
        Magnet m2 = null;
        int    v;

        foreach ( vo; vos )
        {
            assert( vo.instanceof!Magnet );

            m2 = cast( Magnet ) vo;

            //
            if ( m1 !is null )
            {
                v = Magnet.m( m1.mto, m2.mto );

                //final
                switch ( v )
                {
                    case TO.G: break;
                    case TO.H: break;
                    case TO.C: break;
                    case TO.D: break;
                    default:
                }
            }
            else
            {
                m2.set();
            }

            //
            m1 = m2;
        }
    }


    /** */
    override
    void vid( IRas ras )
    {
        vos.vid( ras );
    }


    /** */
    override
    void process( ref MouseKeyEvent event )
    {
        //writeln( __FUNCTION__, ": ", event, ": ", event.leftKeyPressed() );

        version ( False )
        {
            import ui.magnet : Magnet;
            auto m1 = new Magnet();
            m1.otd = event.to.d;
            m1.oth = event.to.h;
            m1.cd = 100.px;
            m1.gh = 100.px;
            ( cast( MyRoot ) root ).om( m1 );
            root.set();

            m1.mg.dar = 1;
        }

        //vos.process( event );
    }


    /** */
    override
    void process( ref KeyboardKeyEvent event )
    {
        //writeln( __FUNCTION__, ": ", event );

        if ( event.code == VK_ESCAPE )
        {
            exit();
        }
    }
}


/** */
void exit()
{
    doLoop = false;
}

