module ui.vid;

import ui : IVo;
import ui : IRas;
import ui : instanceof;


interface IVid
{
    void vid( IRas ras );
}


/** */
mixin template Vid()
{
    void vid( IRas ras )
    {
        //
    }
}


/** */
void vid( IVo[] vos, IRas ras )
{
    import std.stdio : writeln;

    //foreach ( vo; vos )
    for ( auto vo = vos.ptr, end = vos.ptr + vos.length; vo != end; vo += 1 )
    {
        writeln( ": ", *vo );
        assert( (*vo).instanceof!IVid );
        ( cast( IVid* ) vo ).vid( ras );
    }
}

