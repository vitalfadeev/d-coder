import std.stdio;

import ui;
import ui.oswindow : OSWindow;


void main()
{
	auto list = new List();
    writeln( list.o );
    writeln( list.vos );
    list.set();
    
    //
    list.c = 1.px;
    list.compute_cd();
    writeln( list.computed_c );
    writeln( list.computed_d );
    writeln( list.computed_cd );

    import ui.files : Files;
    auto files = new Files();
    //files.read( "." );

    // Thread locals
    root = new Root();
    root.om( list );

    auto ras  = new MyWindow();
    //root.vid( ras );

    // Event loop
    eventLoop();
}


/** */
void eventLoop()
{
    import core.sys.windows.windows;

    MSG msg;

   while ( GetMessage( &msg, NULL, 0, 0 ) )
   {
       //TranslateMessage( &msg );
       DispatchMessage( &msg );
   }
}


/** */
class MyWindow : OSWindow
{
    List list;


    /** */
    void onOmed()
    {
        // list = om( new List() );
    }
}


