module ui.vo;

import ui;


// Ot
/** */
interface IVo
{
    ref IO o();
    void uno();
}


/** */
mixin template Vo()
{
    IO _o;


    /** */
    ref IO o()
    {
        return _o;
    }


    /** */
    void uno()
    {
        _o.un( this );
    }
}


