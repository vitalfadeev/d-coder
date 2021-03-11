module ui.list;

import ui;


// List
interface IList
{
    //
}


//mixin template List()
//{
//    //
//}


/** */
class List : Vid
{
    /** */
    override
    void set()
    {
        c = 0;
        d = 0;

        //vos.set();
        setvos();
    }


    /** */
    void setvos()
    {
        int hvo = _computed_h;

        foreach( i, vo; vos )
        {
            assert( vo.instanceof!ISet );

            // set
            ( cast( ISet ) vo ).c  = _computed_c;
            ( cast( ISet ) vo ).d  = _computed_d;
            ( cast( ISet ) vo ).cd = _computed_cd;

            ( cast( ISet ) vo ).h = hvo;
            ( cast( ISet ) vo ).g = hvo + ( cast( ISet ) vo ).computed_gh;

            // compute
            ( cast( ISet ) vo ).compute_c_d_cd();
            ( cast( ISet ) vo ).compute_g_h_gh();

            //
            hvo += ( cast( ISet ) vo ).computed_gh;
        }
    }


    /** */
    override
    void vid( IRas ras )
    {
        vid_border( ras );
        vos.vid( ras );

/*
        auto pen = ras.pen;

        pen.ra( 0xCCCCCC.rgb );

        //pen.cursTo( 0, 0 );  // center

        //// rectangle 100 x 100
        //pen.cursTo(   50,   50 );  // to right to bottom
        //pen.lineTo( -100,    0 ); 
        //pen.lineTo(    0,  100 );
        //pen.lineTo(  100,    0 );
        //pen.lineTo(    0, -100 );

        // rectangle 100 x 100
        pen.to( 200, 200 );  // center
        pen.rectangle( _computed_cd, 100 );

        //// pen 3x3
        //pen.cd = 3;
        //pen.gh = 3;

        //// rectangle 105 x 105
        //pen.cursTo( 100, 100 );  // center
        //pen.rectangle( 105, 105 );

        ////
        //with ( pen )
        //{
        //    init();
        //    cursTo( 0, 0 );  // center
        //    rectangle( 100, 100 );

        //    cd = 3;
        //    gh = 3;

        //    cursTo( 0, 0 );  // center
        //    rectangle( 105, 105 );
        //}
*/
    }


    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb );
        pen.to( 0, 0 );  // center
        pen.rectangle( _computed_cd, _computed_gh );
    }
}


/** */
interface IListItem : IVo, ISet, IVid
{
    //
}


/** */
class ListItem : Vid, IListItem
{
    string  dar = "1234567890";
    TextSet textSet;

    //
    override
    void set()
    {
        //
    }


    override
    void vid( IRas ras )
    {
        vid_border( ras );
        vid_text( ras );
    }


    void vid_border( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb );
        pen.to( 0, 0 );  // center
        pen.rectangle( _computed_cd, _computed_gh );
    }


    void vid_text( IRas ras )
    {
        auto pen = ras.pen;
        pen.ra( 0xCCCCCC.rgb );
        pen.to( 0, 0 );  // center
        pen.text( dar, _computed_cd, _computed_gh, textSet );

        //writeln( textSet );
    }
}

