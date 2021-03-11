module ui.mag;

import ui;


interface IMag
{
    ref ubyte mc();
    ref ubyte md();
    //ubyte mg();
    //ubyte mh();
    bool stable();
}


class Mag : IMag
{
    ubyte _mc;
    ubyte _md;

    ref ubyte mc()
    {
        return _mc;
    }


    ref ubyte md()
    {
        return _md;
    }


    bool stable()
    {
        return false;
    }
}


void setMags( Object[] mags )
{
    //
}


alias ubyte POWER;
alias int   POS;


struct TMag
{
    POWER mc;    // power
    POWER md;
    bool  stable;

    POS cd;      // px, width,  center at otd
    POS gh;      // px, height, center at oth

    POS otd;     // px, center: relative from the parent center
    POS oth;     // px, center: relative from the parent center

    TMag* o;     // Mag, parent. container. controller. boss

    TMag*[] vos; // Mag[], inner. content, controlled mags, slaves

    void* dar;

    bool live;

    void delegate( IRas ras ) _vid;
    bool delegate( Point p )  _hitTest;
    void delegate( ref MouseKeyEvent event )  _processMouseKey;
    void delegate( ref MouseMoveEvent event ) _processMouseMove;


    void setvos()
    {
        // set Mags
        // each
        //   center = current + m1.power + m2.power + m3.power
        .set();
    }


    void vid( IRas ras )
    {
        // pen
        // pen.lineTo()
        // pen.rect()
        // pen.text()
        vid_border( ras );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 3 );
        pen.to( 0, 0 );  // center
        pen.rectangle( cd, gh );
    }


    /** */
    bool hitTest( Point p )
    {
        return 
            p.d >= -cd/2 && p.d <= cd/2 &&
            p.h >= -gh/2 && p.h <= gh/2;
    }


    void processMouseKey( ref MouseKeyEvent event )
    {
        //
    }


    void processMouseMove( ref MouseMoveEvent event )
    {
        //
    }
}


enum MAXMAGS = 1024;

struct TMagsRegistry
{
    TMag[ MAXMAGS ] mags;
    //TMag*[] freeed; // freeed = mags.each!( a => &a )().array;

    TMag*[] freeed()
    {
        TMag*[] arr;

        foreach ( ref mag; mags )
        {
            if ( !mag.live )
            {
                arr ~= &mag;
            }
        }

        return arr;
    }


    TMag*[] used()
    {
        TMag*[] arr;

        foreach ( ref mag; mags )
        {
            if ( mag.live )
            {
                arr ~= &mag;
            }
        }

        return arr;
    }
}


TMag* CR( T = TMag )()
{
    // using TMagsRegistry
    //   get free slot
    //   o = create new T( args )
    //     return o
    import std.range : front;

    //
    assert( magsRegistry.freeed.length > 0, "Mags limit reached: " ~ MAXMAGS.stringof );

    //
    auto oPtr = magsRegistry.freeed.front;

    with ( oPtr )
    {
        live     = true;
        _vid     = &( cast( T* ) oPtr ).vid;
        _hitTest = &( cast( T* ) oPtr ).hitTest;
        _processMouseKey  = &( cast( T* ) oPtr ).processMouseKey;
        _processMouseMove = &( cast( T* ) oPtr ).processMouseMove;
    }

    return oPtr;
}


TMagsRegistry magsRegistry;


void set()
{
    import std.math : round;

    float[] powers;
    auto magnets = magsRegistry.used;
    powers.length = magnets.length;

    float power;

    float maxPower = 100;
    //foreach ( mag; magnets )
    //    maxPower = max( maxPower, ( cast( IMagnet ) mag ).cPower, ( cast( IMagnet ) mag ).dPower );

    // calc powers
    foreach ( i, ref mag; magnets )
    {
        // skip stable
        if ( mag.stable )
        {
            // skip
        }
        else // dynamic
        {
            power = 0;

            foreach ( ref _mag; magnets )
            {
                // skip self
                if ( mag is _mag )
                {
                    // skip
                }
                else
                {
                    auto distance = mag.otd - _mag.otd;

                    // mag == _mag
                    if ( distance == 0 )
                    {
                        // skip
                    }
                    else // _mag -> mag
                    if ( distance > 0 )
                    {
                        power += 
                            ( maxPower * maxPower ) 
                            * cast( float ) _mag.md 
                            / ( distance * distance );
                    }
                    else // mag <- _mag
                    {
                        power -= 
                            ( maxPower * maxPower ) 
                            * cast( float ) _mag.mc 
                            / ( distance * distance );
                    }
                }
            }

            powers[ i ] = power;
        }
    }

    // do power
    //writeln( "powers: ", powers );
    foreach ( i, ref mag; magnets )
    {
        // skip stable
        if ( mag.stable )
        {
            // skip
        }
        else
        {
            mag.otd = mag.otd + powers[ i ].round().to!int;
        }
    }
}


void vid( IRas ras )
{
    Point praot = ras.ot();

    foreach ( ref mag; magsRegistry.used )
    {
        ras.ot( praot, mag.otd, mag.oth );
        mag._vid( ras );
    }
}


void processMouseKey( ref MouseKeyEvent event )
{
    auto to = event.to;

    foreach ( ref mag; magsRegistry.used )
    {
        event.to.d = to.d - mag.otd;
        event.to.h = to.h + mag.oth;

        //writeln( "event.to: ", event.to );
        //writeln( "mag.cd: ", mag.cd );
        if ( mag._hitTest( event.to ) )
        {
            mag._processMouseKey( event );
        }
    }
}


void processMouseMove( ref MouseMoveEvent event )
{
    auto to = event.to;

    foreach ( ref mag; magsRegistry.used )
    {
        event.to.d = to.d - mag.otd;
        event.to.h = to.h + mag.oth;

        //writeln( "event.to: ", event.to );
        //writeln( "mag.cd: ", mag.cd );
        if ( mag._hitTest( event.to ) )
        {
            mag._processMouseMove( event );
        }
    }
}


struct TBox
{
    TMag _mag;
    alias _mag this;


    void vid( IRas ras )
    {
        vid_border( ras );
        vid_fill( ras );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        if ( md == 0 )
            pen.ra( 0xCCCCCC.rgb, 3 );
        else
        if ( md > 0 )
            pen.ra( 0xCC0000.rgb, 3 );
        else
        if ( md < 0 )
            pen.ra( 0x0000CC.rgb, 3 );

        pen.to( 0, 0 );  // center
        pen.rectangle( cd, gh );
    }


    /** */
    void vid_fill( IRas ras )
    {
        auto pen = ras.pen;
        if ( md == 0 )
            pen.rectangleFilled( cd, md*2, 0xCCCCCC.rgb );
        else
        if ( md > 0 )
            pen.rectangleFilled( cd, md*2, 0xCC0000.rgb );
        else
        if ( md < 0 )
            pen.rectangleFilled( cd, md*2, 0x0000CC.rgb );
    }


    void processMouseKey( ref MouseKeyEvent event )
    {
        this.mc = event.to.h.to!ubyte;
        this.md = event.to.h.to!ubyte;
    }


    void processMouseMove( ref MouseMoveEvent event )
    {
        this.mc = event.to.h.to!ubyte;
        this.md = event.to.h.to!ubyte;
    }
}

// |           |
// |           | 
// |   #   #   |
// |           |
// |           |

void mag_app()
{
    auto cBar = CR!TBox();
    auto dBar = CR!TBox();
    auto m1   = CR();

    cBar.otd = -200;
    cBar.md  =  50;    
    cBar.cd  =  30;
    cBar.gh  =  200;
    cBar.stable = true;

    dBar.otd = 200;
    dBar.mc  =  50;
    dBar.cd  =  30;
    dBar.gh  =  200;
    dBar.stable = true;

    m1.md = 50;
    m1.mc = 50;
    m1.cd = 100;
    m1.gh = 100;

    set();
}

