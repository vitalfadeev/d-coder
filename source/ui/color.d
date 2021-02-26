module ui.color;

import core.sys.windows.windows : COLORREF;
import core.sys.windows.windows : RGB;
import std.format               : format;
import std.stdio                : writefln;


/** */
struct Color
{
    union
    {
         COLORREF native;
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
        native = _rgb( a );
    }


    COLORREF opCast( T : COLORREF )()
    {
        return native;
    }    


    string toString()
    {
        return format!"Color( 0x%x )"( native );
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
Color rgb( uint color )
{
    return Color( _rgb( color ) );
}


/** */
Color argb( uint color )
{
    Color c;

    c.native = _rgb( color );
    c.a      = ( color & 0xFF000000 ) >> 24;

    return c;
}


///
unittest
{
    auto color = 0xAABBCC.rgb;

    assert( color.native == RGB( 0xAA, 0xBB, 0xCC ) );

    assert( color.b == 0xCC );
    assert( color.g == 0xBB );
    assert( color.r == 0xAA );
    assert( color.a == 0xFF );
}

///
unittest
{
    auto color = 0xAABBCC.rgb;
    assert( !color.isTransparent );
}

//
unittest
{
    auto color = ( 0x00AABBCC ).argb;
    assert( color.native == RGB( 0xAA, 0xBB, 0xCC ) );
    assert( color.isTransparent );
}

//
unittest
{
    auto color = ( 0xFFAABBCC ).argb;
    assert( color.native == RGB( 0xAA, 0xBB, 0xCC ) );
    assert( !color.isTransparent );
}

