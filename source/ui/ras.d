module ui.ras;

import ui : Ra;
import ui : IPen;
import ui : Point;
import ui : Size;


/** */
interface IRas
{
    IPen  pen();
    void  ot( Point praot, int d, int h );                 // Point of view
    Point ot();
    void  clear();
    Size  cdgh();
}


/** */
class Ras : IRas
{
    Ra[100][100] ras;
    IPen _pen;


    /** */
    IPen pen()
    {
        return _pen;
    }


    /** */
    //void sdsh( Point base )
    //{
    //    //
    //}


    /** */
    void ot( Point praot, int sd, int sh )
    {
        //
    }


    /** */
    Point ot()
    {
        return Point();
    }


    /** */
    void clear()
    {
        //
    }


    /** */
    Size cdgh()
    {
        return Size();
    }
}


// Thread local
IRas ras;
