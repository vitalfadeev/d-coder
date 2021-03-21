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
    import std.algorithm : sum;
    import std.algorithm : map;
    import std.array     : array;
    import std.math      : isInfinity;
    import std.math      : isFinite;
    import std.math      : isNaN;
    import std.range     : lockstep;
    import std.range     : zip;


    auto magnets = magsRegistry.used;

    // 3 and more
    if ( magnets.length >= 3 )
    {
        // Phase 1. Calc powers
        int[] powers;
        powers.length = magnets.length;

        POS[] offsets;
        offsets.length = magnets.length;

        auto cmag   = magnets.ptr;
        auto mag    = magnets.ptr + 1;
        auto end    = magnets.ptr + magnets.length;
        auto power  = powers.ptr;
        auto offset = offsets.ptr;

        POS  totalOffsets = 0;
        int  totalPower = 0;

        POS  ofs;
        int  pwr;

        POS  cmag_d, mag_c;

        for ( ; mag != end ; cmag += 1, mag += 1, power += 1, offset += 1 )
        {
            cmag_d = ( *cmag ).d;
            mag_c  = ( *mag ).c;

            // cmag -> mag
            // ++
            if ( cmag_d > 0 && mag_c > 0 )
            {
                pwr = cmag_d + mag_c;
                *power = pwr;
                totalPower += pwr;
            }

            else // --
            if ( cmag_d < 0 && mag_c < 0 )
            {
                pwr = abs( cmag_d + mag_c );
                *power = pwr;
                totalPower += pwr;
            }

            else // +-
            if ( cmag_d >= 0 && mag_c <= 0 )
            {
                ofs = max( cmag_d, abs( mag_c ) );
                *offset = ofs;
                totalOffsets += ofs;
            }

            else // -+
            if ( cmag_d <= 0 && mag_c >= 0 )
            {
                ofs = max( abs( cmag_d ), mag_c );
                *offset = ofs;
                totalOffsets += ofs;
            }
        }


        // Phase 2. Set positions
        POS totalDistance = magnets[ $-1 ].otd - magnets[ 0 ].otd - totalOffsets;        

        if ( totalDistance > 0 )
        {
            POS cmag_otd = magnets[ 0 ].otd;

            foreach ( ref mag, p, o; lockstep( magnets[ 1.. $ ], powers, offsets ) )
            {
                if ( mag.stan )
                {
                    // skip
                    cmag_otd = mag.otd;
                }
                else
                {
                    if ( p != 0 )
                    {
                        cmag_otd += 
                            round( 
                                ( ( cast( float ) p ) / totalPower ) * totalDistance
                            ).to!POS;
                        mag.otd = cmag_otd;
                    }
                    else
                    {
                        cmag_otd += o;
                        mag.otd = cmag_otd;
                    }
                }
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
        this.c = event.to.h.to!POWER;
        this.d = event.to.h.to!POWER;
    }


    void process( ref MouseMoveEvent event )
    {
        this.c = event.to.h.to!POWER;
        this.d = event.to.h.to!POWER;
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
    cBar.c   = 20;
    cBar.d   = 20;
    cBar.gh  = 200;
    cBar.stan = true;

    auto m1 = CR();
    m1.otd = 0;
    m1.c   = 10;
    m1.d   = 10;
    m1.gh  = 100;

    auto m2 = CR();
    m2.otd = 2;
    m2.c   = 10;
    m2.d   = 10;
    m2.gh  = 100;
    //m2.stan = true;

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
    dBar.c   = 20;
    dBar.d   = 20;
    dBar.gh  =  200;
    dBar.stan = true;
}

