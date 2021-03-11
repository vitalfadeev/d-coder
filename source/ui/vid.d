module ui.vid;

import ui : IVo;
import ui : IRas;
import ui : ISet;
import ui : Set;
import ui : instanceof;
import ui : Point;
import ui : MouseKeyEvent;
import ui : MouseMoveEvent;
import ui : KeyboardKeyEvent;
import std.stdio : writeln;


interface IVid
{
    void vid( IRas ras );
    bool hitTest( Point p );
    void process( ref MouseKeyEvent event );
    void process( ref MouseMoveEvent event );
    void process( ref KeyboardKeyEvent event );
}


/** */
class Vid : Set, IVid
{
    /** */
    void vid( IRas ras )
    {
        vos.vid( ras );
    }


    /** */
    bool hitTest( Point p )
    {
        return 
            p.d >= computed_c && p.d <= computed_d &&
            p.h >= computed_g && p.h <= computed_h;
    }


    /** */
    void touch()
    {
        import ui.vidpipe : touch;
        touch( this );
    }


    /** */
    void process( ref MouseKeyEvent event )
    {
        //writeln( __FUNCTION__, ": ", event, ": ", event.leftKeyPressed() );
        vos.process( event );
    }


    /** */
    void process( ref MouseMoveEvent event )
    {
        //writeln( __FUNCTION__, ": ", event, ": ", event.leftKeyPressed() );
        vos.process( event );
    }


    /** */
    void process( ref KeyboardKeyEvent event )
    {
        //writeln( __FUNCTION__, ": ", event );
    }
}


/** */
void vid( Object[] vos, IRas ras )
{
    if ( vos.length > 0 )
    {
        Point ot = ras.ot();

        version ( HardcodedForeach )
        {
            for ( auto vo = vos.ptr, end = vos.ptr + vos.length; vo != end; vo += 1 )
            {
                //assert( (*vo).instanceof!IVid );
                //assert( (*vo).instanceof!ISet );

                // center
                ras.ot( 
                    ot,
                    ( cast( ISet* ) vo ).computed_otd, 
                    ( cast( ISet* ) vo ).computed_oth
                );

                // vid
                ( cast( IVid* ) vo ).vid( ras );
            }
        }
        else
        {
            foreach ( vo; vos )
            {
                //assert( vo.instanceof!IVid );
                //assert( vo.instanceof!ISet );

                // center
                ras.ot( 
                    ot,
                    ( cast( ISet ) vo ).computed_otd, 
                    ( cast( ISet ) vo ).computed_oth
                );

                // vid
                ( cast( IVid ) vo ).vid( ras );
            }
        }        
    }
}


/** */
void process( Object[] vos, ref MouseKeyEvent event )
{
    auto to = event.to;

    foreach ( vo; vos )
    {
        // relative from the vo center
        event.to.d = to.d - ( cast( ISet ) vo ).computed_otd;
        event.to.h = to.h + ( cast( ISet ) vo ).computed_oth;

        // 
        if ( ( cast( IVid ) vo ).hitTest( event.to ) )
        {
            ( cast( IVid ) vo ).process( event );
        }
    }
}


/** */
void process( Object[] vos, ref MouseMoveEvent event )
{
    Point to = event.to;

    foreach ( vo; vos )
    {
        // relative from the vo center
        event.to.d = to.d - ( cast( ISet ) vo ).computed_otd;
        event.to.h = to.h + ( cast( ISet ) vo ).computed_oth;

        // 
        if ( ( cast( IVid ) vo ).hitTest( event.to ) )
        {
            ( cast( IVid ) vo ).process( event );
        }
    }
}

