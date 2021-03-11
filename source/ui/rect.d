module ui.rect;

import core.sys.windows.windows;


struct Rect
{
    union
    {
        RECT windowsRECT;
        struct
        {
            int c;
            int h;
            int d;
            int g;
        }
    }


    int cd()
    {
        import std.math : abs;
        return abs( d - c );
    }


    int hg()
    {
        import std.math : abs;
        return abs( h - g );
    }
}

