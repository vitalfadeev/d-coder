module ui.magnet;

import ui;

interface IMagnet
{
    bool stable();
    int  cPower();
    int  dPower();
}


/** */
struct TMagnet
{
    byte c;
    byte d;
    byte g;
    byte h;
}


/** */
class Magnet : Vid, IMagnet
{
    TMagnet magnet;
    int magnet_cd = 10;
    int magnet_gh = 10;

    MagnetControl mc;
    MagnetControl md;
    MagnetControl mg;
    MagnetControl mh;

    bool stable()
    {
        return false;
    }


    this()
    {
        mc = new MagnetControl();
        md = new MagnetControl();
        mg = new MagnetControl();
        mh = new MagnetControl();

        mc.cd = magnet_cd;
        md.cd = magnet_cd;
        mg.cd = magnet_cd;
        mh.cd = magnet_cd;
        mc.gh = magnet_gh;
        md.gh = magnet_gh;
        mg.gh = magnet_gh;
        mh.gh = magnet_gh;

        om( mc );
        om( md );
        om( mg );
        om( mh );
    }


    int cPower()
    {
        return mc.dar;
    }


    int dPower()
    {
        return md.dar;
    }


    /** */
    override
    void set()
    {
        compute_c_d_cd();
        compute_g_h_gh();
        compute_otd_oth();

        // magnet center
        mc.otd = _computed_c;
        md.otd = _computed_d;
        mg.oth = _computed_g;
        mh.oth = _computed_h;

        //
        vos.set();
    }    


    /** */
    override
    void vid( IRas ras )
    {
        vid_border( ras );
        vid_magnets( ras );
    }


    /** */
    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb, 3 );
        pen.to( 0, 0 );  // center
        pen.rectangle( _computed_cd, _computed_gh );
    }


    /** */
    void vid_magnets( IRas ras )
    {
        vos.vid( ras );
    }


    /** */
    static
    int m( int m1, int m2 )
    {
        //m1 = [ 0000   0000   0000   0000 ]
        //m2 = [ 0001   0010   0100   1000 ]
        //v  = [    5      1      7      3 ]
        //
        //m( 0000 0001 ) = 5

        int[ int ] m2s = 
            [ 
                0b0000_0001 : TO.G,
                0b0000_0010 : TO.H,
                0b0000_0100 : TO.C,
                0b0000_1000 : TO.D
            ];

        return m2 in m2s ? m2s[ m2 ] : 0;
    }


    /** */
    int mto()
    {
        if ( mc.dar > 0 ) return TO.C;
        if ( md.dar > 0 ) return TO.D;
        if ( mg.dar > 0 ) return TO.G;
        if ( mh.dar > 0 ) return TO.H;
        return 0;
    }
}


enum TO : int
{
    G = 5,
    H = 1,
    C = 7,
    D = 3,
}


/** */
class MagnetControl : Vid
{
    byte dar = 1;


    /** */
    override
    void vid( IRas ras )
    {
        auto pen = ras.pen;

        // Ra
        Ra ra;

        if ( dar == 0 )
            ra = 0xCCCCCC.rgb;
        else if ( dar > 0 )
            ra = 0xCC0000.rgb;
        else  // c < 0
            ra = 0x0000CC.rgb;

        pen.ra( ra );

        // Rect
        pen.rectangleFilled( _computed_cd, _computed_gh, ra );
    }


    /** */
    void onClick()
    {
        this.dar = cast( byte ) -cast( int ) this.dar;
    }
}


