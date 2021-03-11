module ui.vo;

import ui;


// Ot
/** */
interface IVo
{
    ref Object o();
    void uno();
}


/** */
class Vo : O, IVo
{
    Object _o; // IO


    /** */
    ref Object o()
    {
        return _o;
    }


    /** */
    void uno()
    {
        ( cast( IO ) _o ).un( this );
    }
}

