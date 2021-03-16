module ui.rect;

import core.sys.windows.windows;


struct Rect
{
    union
    {
        struct
        {
            int c;
            int h;
            int d;
            int g;
        }
        RECT windowsRECT;
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

