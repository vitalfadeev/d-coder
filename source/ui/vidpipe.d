module ui.vidpipe;

import ui : IVid;
import ui : IRas;


/** */
class VidPipe
{
    IVid[] pipe;


    /** */
    void opUnary( string op )( IVid o )
      if ( op == "~" )
    {
        pipe ~= o;
    }


    /** */
    void vid( IRas ras )
    {
        import std.algorithm : sort;
        import std.algorithm : uniq;

        // unique
        pipe.sort!( ( a, b ) => ( cast( void* )a > cast( void* ) b ) )();
        auto uniqed = pipe.uniq!( ( a, b ) => ( cast( void* )a > cast( void* ) b ) )();

        // vid
        foreach ( o; uniqed )
        {
            o.vid( ras );
        }

        // clear
        pipe.length = 0;
    }
}


/** */
void touch( IVid o )
{
    //vidPipe ~= o;
    //vidPipe.pipe ~= o;
}


// Threads local
VidPipe vidPipe;
