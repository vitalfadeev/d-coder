module ui.font;

import core.sys.windows.windows;
import std.utf : toUTF16;


struct Font
{
    string  face        = "Arial";
    uint    height      = 15;
    uint    orientation = 0;
    uint    weight      = 400; // FW_NORMAL
    bool    italic      = false;
    bool    underline   = false;
    bool    strikeout   = false;

    ABC[]   charWidths;


    HFONT toWindowsFont( uint pixels_per_inch = 96 ) 
    {
        LOGFONT lf = {
                        lfEscapement      : 0,
                        lfOrientation     : this.orientation,
                        lfWeight          : this.weight ,
                        lfItalic          : this.italic,
                        lfUnderline       : this.underline,
                        lfStrikeOut       : this.strikeout,
                        lfCharSet         : DEFAULT_CHARSET,
                        lfOutPrecision    : OUT_DEFAULT_PRECIS,
                        lfClipPrecision   : CLIP_DEFAULT_PRECIS,
                        lfQuality         : DEFAULT_QUALITY,
                        lfPitchAndFamily  : FF_DONTCARE
                    };

        lf.lfFaceName[ 0 .. this.face.length ] = this.face.toUTF16;

        static const 
        int points_per_inch = 96; // for Windows

        lf.lfHeight = - ( this.height * pixels_per_inch / points_per_inch );

        return CreateFontIndirect( &lf );
    }


    void getCharWidths( HDC hdc )
    {
        // Char Widths for current Font
        charWidths.reserve( 65536 );
        charWidths.length  = 65536;
        GetCharABCWidths( hdc, 0, 65535, charWidths.ptr );
    }
}

