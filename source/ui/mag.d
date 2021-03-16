module ui.mag;

import ui;


alias byte POWER;
alias int  POS;


struct TMag
{
    bool  stan;
    POWER c;    // m-power: -127..+127
    POWER d;

    POS gh;      // px, height, center at oth

    POS otd;     // px, center: relative from the parent center
    POS oth;     // px, center: relative from the parent center

    TMag* o;     // Mag, parent. container. controller. boss

    TMag*[] vos; // Mag[], inner. content, controlled mags, slaves

    void* dar;

    bool live;

    void delegate( IRas ras ) _vid;
    bool delegate( Point p )  _hitTest;
    void delegate( ref MouseKeyEvent    event ) _processMouseKey;
    void delegate( ref MouseMoveEvent   event ) _processMouseMove;
    void delegate( ref KeyboardKeyEvent event ) _processKeyboardKey;


    // px, width,  center at otd
    POS cd()
    {
        return abs( d ) + abs( c );
    }

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
        vid_center( ras );
        vid_border( ras );
        //vid_symbol( ras );
    }


    /** */
    void vid_center( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 3 );
        pen.to( 0, 0 );  // center
        pen.rectangle( 1, 1 );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        
        pen.to( 0, 0 );  // center

        // c
        if ( c == 0 )
            pen.ra( 0xCCCCCC.rgb, 3 );
        else
        if ( c < 0 )
            pen.ra( 0x0000CC.rgb, 3 );
        else // c > 0
            pen.ra( 0xCC0000.rgb, 3 );

        pen.rectangle( -abs( cast( int ) c ), -gh/2, 0,  gh/2 );

        // d
        if ( d == 0 )
            pen.ra( 0xCCCCCC.rgb, 3 );
        else
        if ( d < 0 )
            pen.ra( 0x0000CC.rgb, 3 );
        else // d > 0
            pen.ra( 0xCC0000.rgb, 3 );

        pen.rectangle( 0, -gh/2, abs( d ),  gh/2 );
    }


    /** */
    void vid_symbol( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 3 );
        pen.to( 0, 0 );  // center
        pen.symbol( 'A', c, -gh/2, d, gh/2 );
    }


    /** */
    bool hitTest( Point p )
    {
        return 
            p.d >= -cd/2 && p.d <= cd/2 &&
            p.h >= -gh/2 && p.h <= gh/2;
    }


    void process( ref MouseKeyEvent event )
    {
        //
    }


    void process( ref MouseMoveEvent event )
    {
        //
    }


    void process( ref KeyboardKeyEvent event )
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
        _processMouseKey    = &( cast( T* ) oPtr ).process;
        _processMouseMove   = &( cast( T* ) oPtr ).process;
        _processKeyboardKey = &( cast( T* ) oPtr ).process;
    }

    return oPtr;
}


TMagsRegistry magsRegistry;


void set()
{
    float[] powers;
    auto magnets = magsRegistry.used;
    powers.length = magnets.length;

    float power;

    float maxpower = 0;

    // calc powers
    foreach ( i, ref mag; magnets )
    {
        // skip stan
        if ( mag.stan )
        {
            // skip
            powers[ i ] = 0;
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
                    else // _mag -> mag .......
                    if ( distance > 0 )
                    {
                        // +c +d
                        if ( mag.c >= 0 && _mag.d >= 0 )
                            power += cast( float ) ( abs( mag.c + _mag.d ) ) / abs( distance );
                        else // -c -d
                        if ( mag.c < 0  && _mag.d < 0 )
                            power += cast( float ) ( abs( mag.c + _mag.d ) ) / abs( distance );
                        else // -c +d
                        if ( mag.c < 0  && _mag.d >= 0 )
                            power += cast( float ) ( abs( mag.c + _mag.d ) ) - abs( distance );
                        else // +c -d
                        if ( mag.c >= 0 && _mag.d < 0 )
                            power += cast( float ) ( abs( mag.c + _mag.d ) ) - abs( distance );
                    }
                    else // ....... mag <- _mag
                    {
                        // +d +c 
                        if ( mag.d >= 0 && _mag.c >= 0 )
                            power -= cast( float ) ( abs( mag.d + _mag.c ) ) / abs( distance );
                        else // -d -c
                        if ( mag.d < 0  && _mag.c < 0 )
                            power -= cast( float ) ( abs( mag.d + _mag.c ) ) / abs( distance );
                        else // -d +c 
                        if ( mag.d < 0  && _mag.c >= 0 )
                            power -= cast( float ) ( abs( mag.d + _mag.c ) ) - abs( distance );
                        else // +d -c
                        if ( mag.d >= 0 && _mag.c < 0 )
                            power -= cast( float ) ( abs( mag.d + _mag.c ) ) - abs( distance );
                    }
                }
            }

            powers[ i ] = power;
            maxpower = max( maxpower, abs( power ) );
        }
    }

    // min. for prevent 1px tremor
    if ( maxpower > 1 )
    {
        maxpower = 1; // jump
    }
    else
    if ( maxpower < 0.016 )
    {
        maxpower = 0;
    }
    else
    {
        maxpower /= 10;
    }

    //
    if ( maxpower == 0 )
    {
        // balance. skip
    }
    else
    {
        TMag* cmag;
        TMag* dmag;

        // do power
        writeln( "powers: ", powers );
        foreach ( i, ref mag; magnets )
        {
            // skip stan
            if ( mag.stan )
            {
                // skip
            }
            else
            {
                mag.otd += ( powers[ i ] / maxpower ).round().to!POS;


                //// prevent over
                //if ( i > 0 )
                //    cmag = magnets[ i - 1 ];
                //else
                //    cmag = null;
                
                //if ( i < magnets.length - 2 )
                //    dmag = magnets[ i + 1 ];
                //else
                //    dmag = null;


                //POS otd = mag.otd + ( powers[ i ] / maxpower ).round().to!POS;

                //if ( cmag !is null && dmag !is null )
                //{
                //    if ( cmag.otd < otd && otd < dmag.otd )
                //        mag.otd = otd;
                //}
                //else
                //    mag.otd = otd;
            }
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


void process( ref MouseKeyEvent event )
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


void process( ref MouseMoveEvent event )
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


void process( ref KeyboardKeyEvent event )
{
    // Global hotkey
    if ( event.code == VK_ESCAPE )
    {
        import app : exit;
        exit();
    }

    // Mag's hotkey
    foreach ( ref mag; magsRegistry.used )
    {
        mag._processKeyboardKey( event );
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
        vid_center( ras );
    }


    /** */
    void vid_center( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 3 );
        pen.to( 0, 0 );  // center
        pen.rectangle( 1, 1 );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        if ( d == 0 )
            pen.ra( 0xCCCCCC.rgb, 3 );
        else
        if ( d > 0 )
            pen.ra( 0xCC0000.rgb, 3 );
        else
        if ( d < 0 )
            pen.ra( 0x0000CC.rgb, 3 );

        pen.to( 0, 0 );  // center
        pen.rectangle( cd, gh );
    }


    /** */
    void vid_fill( IRas ras )
    {
        auto pen = ras.pen;
        if ( d == 0 )
            pen.rectangleFilled( cd, d*2, 0xCCCCCC.rgb );
        else
        if ( d > 0 )
            pen.rectangleFilled( cd, d*2, 0xCC0000.rgb );
        else
        if ( d < 0 )
            pen.rectangleFilled( cd, d*2, 0x0000CC.rgb );
    }


    void process( ref MouseKeyEvent event )
    {
        this.c = abs( event.to.h ).to!POWER;
        this.d = abs( event.to.h ).to!POWER;
    }


    void process( ref MouseMoveEvent event )
    {
        this.c = abs( event.to.h ).to!POWER;
        this.d = abs( event.to.h ).to!POWER;
    }


    void process( ref KeyboardKeyEvent event )
    {
        //
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

    cBar.otd = -200;
    cBar.c   =  20;
    cBar.d   =  20;
    cBar.gh  = 200;
    cBar.stan = true;

    auto m1 = CR();
    m1.otd = 0;
    m1.c   = -1;
    m1.d   = 10;
    m1.gh  = 100;

    auto m2 = CR();
    m2.otd = 2;
    m2.c   = 10;
    m2.d   = 10;
    m2.gh  = 100;

    auto m3 = CR();
    m3.otd = 40;
    m3.c   = 10;
    m3.d   = 10;
    m3.gh  = 100;

    auto m4 = CR();
    m4.otd = 60;
    m4.c   = 10;
    m4.d   = 10;
    m4.gh  = 100;

    auto dBar = CR!TBox();
    dBar.otd = 200;
    dBar.c   =  10;
    dBar.d   =  10;
    dBar.gh  =  200;
    dBar.stan = true;
}

