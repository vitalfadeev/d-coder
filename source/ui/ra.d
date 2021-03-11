module ui.ra;

import core.sys.windows.windows : COLORREF;
import core.sys.windows.windows : RGB;
import std.format               : format;
import std.stdio                : writefln;


/** */
struct Ra
{
    union
    {
         COLORREF windowsCOLORREF;
         struct
        {
            ubyte r;
            ubyte g;
            ubyte b;
        }
    }
    ubyte a = 0xFF; // 0x00 - transparent, 0xFF - opaque


    /** */
    bool isTransparent()
    {
        return cast( bool ) ( a == 0 );
    }   


    /** */
    bool isOpaque()
    {
        return cast( bool ) ( a != 0 );
    }   


    pragma( inline )
    void opAssign( uint a )
    {
        windowsCOLORREF = _rgb( a );
    }


    COLORREF opCast( T : COLORREF )()
    {
        return windowsCOLORREF;
    }    


    string toString()
    {
        return format!"Ra( 0x%x )"( windowsCOLORREF );
    }
}



uint _rgb( uint a )
{
    return 
        cast( uint ) ( 
            ( ( a & 0x000000FF ) << 16 )  |  
            ( ( a & 0x0000FF00 ) )  |  
            ( ( a & 0x00FF0000 ) >> 16 ) 
        );    
}


/** */
Ra rgb( uint ra )
{
    return Ra( _rgb( ra ) );
}


/** */
Ra argb( uint ra )
{
    Ra c;

    c.windowsCOLORREF = _rgb( ra );
    c.a               = ( ra & 0xFF000000 ) >> 24;

    return c;
}


///
unittest
{
    auto ra = 0xAABBCC.rgb;

    assert( ra.windowsCOLORREF == RGB( 0xAA, 0xBB, 0xCC ) );

    assert( ra.b == 0xCC );
    assert( ra.g == 0xBB );
    assert( ra.r == 0xAA );
    assert( ra.a == 0xFF );
}

///
unittest
{
    auto ra = 0xAABBCC.rgb;
    assert( !ra.isTransparent );
}

//
unittest
{
    auto ra = ( 0x00AABBCC ).argb;
    assert( ra.windowsCOLORREF == RGB( 0xAA, 0xBB, 0xCC ) );
    assert( ra.isTransparent );
}

//
unittest
{
    auto ra = ( 0xFFAABBCC ).argb;
    assert( ra.windowsCOLORREF == RGB( 0xAA, 0xBB, 0xCC ) );
    assert( !ra.isTransparent );
}

