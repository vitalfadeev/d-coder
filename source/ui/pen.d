module ui.pen;

//import ui;


/** */
interface IPen
{
    void init();
    void cursTo( int cd, int gh );
    void lineTo( int cd, int gh );
    void rectangle( int cd, int gh );
    ref int cd();
    ref int gh();
}


/** */
class Pen : IPen
{
    int _cd;
    int _gh;


    void init() 
    {
        //
    }

    
    void cursTo( int cd, int gh ) 
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


    ref int cd() 
    { 
        return _cd; 
    }


    ref int gh() 
    { 
        return _gh; 
    }
}
