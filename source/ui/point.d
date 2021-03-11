module ui.point;

import core.sys.windows.windows;


struct Point
{
    union
    {
        struct
        {
            int d;
            int h;
        }
        POINT windowsPOINT;
    }

    // a + b 
    Point opBinary( string op : "+" )( Point x )
    {
        return Point( this.d + x.d, this.h + x.h );
    }

    // a - b
    Point opBinary( string op : "-" )( Point x )
    {
        return Point( this.d - x.d, this.h - x.h );
    }
}
