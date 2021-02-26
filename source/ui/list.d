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
class List : IO, IVo, ISet, IVid
{
    mixin Members!();


    /** */
    void set()
    {
        c = 0;
        d = 0;

        vos.set();
    }


    /** */
    override
    void vid( IRas ras )
    {
        writeln( __FUNCTION__ );

        auto pen = ras.pen;

        pen.cursTo( 0, 0 );  // center

        // rectangle 100 x 100
        pen.cursTo(   50,   50 );  // to right to bottom
        pen.lineTo( -100,    0 ); 
        pen.lineTo(    0,  100 );
        pen.lineTo(  100,    0 );
        pen.lineTo(    0, -100 );

        // rectangle 100 x 100
        pen.cursTo( 0, 0 );  // center
        pen.rectangle( 100, 100 );

        // pen 3x3
        pen.cd = 3;
        pen.gh = 3;

        // rectangle 105 x 105
        pen.cursTo( 0, 0 );  // center
        pen.rectangle( 105, 105 );

        //
        with ( pen )
        {
            init();
            cursTo( 0, 0 );  // center
            rectangle( 100, 100 );

            cd = 3;
            gh = 3;

            cursTo( 0, 0 );  // center
            rectangle( 105, 105 );
        }
    }
}

