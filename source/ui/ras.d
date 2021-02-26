module ui.ras;

import ui : Color;
import ui : IPen;


/** */
interface IRas
{
    IPen pen();
    void clear();
}


/** */
class Ras : IRas
{
    Color[100][100] map;
    IPen _pen;


    /** */
    IPen pen()
    {
        return _pen;
    }


    /** */
    void clear()
    {
        //
    }
}


// Thread local
IRas ras;
