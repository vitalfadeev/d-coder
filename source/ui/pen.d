module ui.pen;

import ui;


/** */
interface IPen
{
    void init();
    void ra( Ra ra );
    void ra( Ra ra, int cd );
    void to( int cd, int gh );
    void lineTo( int cd, int gh );
    void rectangle( int cd, int gh );
    void rectangle( int c, int h, int d, int g );
    void rectangleFilled( int cd, int gh, Ra ra );
    void rectangleFilled( int c, int h, int d, int g, Ra ra );
    void symbol( wchar wc, int c, int h, int d, int g );
    void text( string s, int cd, int gh, ref TextSet textSet );
    ref uint cd();
    ref uint gh();
}


/** */
class Pen : IPen
{
    uint _cd;
    uint _gh;


    void init() 
    {
        //
    }


    void ra( Ra ra )
    {
        //
    }

    
    void ra( Ra ra, int cd )
    {
        //
    }

    
    void to( int cd, int gh ) 
    {
        //
    }


    void lineTo( int cd, int gh ) 
    {
        //
    }


    void rectangle( int cd, int gh ) 
    {
        //
    }


    void rectangle( int c, int h, int d, int g )
    {
        //
    }


    void rectangleFilled( int cd, int gh, Ra ra )
    {
        //
    }


    void rectangleFilled( int c, int h, int d, int g, Ra ra )
    {
        //
    }


    void symbol( wchar wc, int c, int h, int d, int g )
    {
        //
    }


    void text( string s, int cd, int gh, ref TextSet textSet )
    {
        //
    }


    ref uint cd() 
    { 
        return _cd; 
    }


    ref uint gh() 
    { 
        return _gh; 
    }
}
