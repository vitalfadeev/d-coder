module ui.box;

import ui;
import ui.magnet : IMagnet;


/** */
class Box : Vid
{
    //mixin Members!();

    MagnetBar cMagnet;
    MagnetBar dMagnet;


    /** */
    this()
    {
        with ( cMagnet = om( new MagnetBar() ) )
        {
            //
        }

        with ( dMagnet = om( new MagnetBar() ) )
        {
            //
        }
    }


    /** */
    override
    void set_vos()
    {
        cMagnet.compute_c_d_cd();
        dMagnet.compute_c_d_cd();
        cMagnet.otd = -computed_cd / 2 + cMagnet.computed_cd / 2;
        dMagnet.otd =  computed_cd / 2 - cMagnet.computed_cd / 2;
        cMagnet.gh =  computed_gh;
        dMagnet.gh =  computed_gh;
        super.set_vos();

        setMagnets( vos );
    }


    /** */
    override
    void vid( IRas ras )
    {
        vid_border( ras );
        super.vid( ras );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 7 );
        pen.to( 0, 0 );  // center
        pen.rectangle( _computed_cd, _computed_gh );
    }
}


/** */
class MagnetBar : Vid, IMagnet
{
    int dar = 100;


    /** */
    this()
    {
        cd = 30.px;
        gh = 100.px;
    }


    /** */
    bool stable()
    {
        return true;
    }


    int cPower()
    {
        return dar;
    }


    int dPower()
    {
        return dar;
    }


    /** */
    override
    void vid( IRas ras )
    {
        vid_border( ras );
        vid_bar( ras );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        
        if ( dar == 0 )
            pen.ra( 0xCCCCCC.rgb, 1 );
        else
        if ( dar > 0 )
            pen.ra( 0xCC0000.rgb, 1 );
        else
            pen.ra( 0x0000CC.rgb, 1 );

        pen.to( 0, 0 );  // center
        pen.rectangle( _computed_cd, _computed_gh );
    }


    void vid_bar( IRas ras )
    {
        auto pen = ras.pen;
        
        if ( dar == 0 )
            pen.ra( 0xCCCCCC.rgb, 1 );
        else
        if ( dar > 0 )
            pen.ra( 0xCC0000.rgb, 1 );
        else
            pen.ra( 0x0000CC.rgb, 1 );

        pen.to( 0, 0 );  // center

        if ( dar == 0 )
            {}
        else
        if ( dar > 0 )
            pen.rectangleFilled( computed_c, dar, computed_d, 0, 0xCC0000.rgb );
        else // dar < 0
            pen.rectangleFilled( computed_c, 0, computed_d, dar, 0x0000CC.rgb );
    }


    /** */
    Box box()
    {
        return cast( Box ) o;
    }


    /** */
    override
    void process( ref MouseKeyEvent event )
    {
        dar = event.to.h;
    }    


    /** */
    override
    void process( ref MouseMoveEvent event )
    {
        if ( event.leftKeyPressed() )
        {
            dar = event.to.h;
        }
    }    
}


//Point pointOf( ref MouseKeyEvent event, MasgnetBar mbar )
//{
//    mbar.sd;
//    mbar.sh;
//}

enum uint MAX_POWER = 100;


/** */
void setMagnets( Object[] magnets )
{
    float[] powers;
    powers.length = magnets.length;

    float power;

    float maxPower = MAX_POWER;
    //foreach ( mag; magnets )
    //    maxPower = max( maxPower, ( cast( IMagnet ) mag ).cPower, ( cast( IMagnet ) mag ).dPower );

    // calc powers
    foreach ( i, mag; magnets )
    {
        // skip stable
        if ( ( cast( IMagnet ) mag ).stable )
        {
            // skip
        }
        else // dynamic
        {
            power = 0;

            foreach ( _mag; magnets )
            {
                // skip self
                if ( mag is _mag )
                {
                    // skip
                }
                else
                {
                    auto distance = 
                        ( cast( ISet ) mag ).computed_otd - ( cast( ISet ) _mag ).computed_otd;

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
                            * ( cast( float ) ( cast( IMagnet ) _mag ).dPower ) 
                            / ( distance * distance );
                    }
                    else // mag <- _mag
                    {
                        power -= 
                            ( maxPower * maxPower ) 
                            * ( cast( float ) ( cast( IMagnet ) _mag ).dPower ) 
                            / ( distance * distance );
                    }
                }
            }

            powers[ i ] = power;
        }
    }

    // do power
    writeln( "powers: ", powers );
    foreach ( i, mag; magnets )
    {
        // skip stable
        if ( ( cast( IMagnet ) mag ).stable )
        {
            // skip
        }
        else
        {
            ( cast( ISet ) mag ).otd = 
                ( ( cast( ISet ) mag ).computed_otd + powers[ i ] ).to!int;
        }
    }
}

