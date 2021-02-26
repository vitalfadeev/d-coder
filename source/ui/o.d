module ui.o;

import ui;


// O
/** */
interface IO
{
    IVo[] vos();
    void om( IVo vo );
    void un( IVo vo );
}


/** */
mixin template O()
{
    IVo[] _vos;
    //void*[] _vos;


    /** */
    IVo[] vos()
    {
        return cast( IVo[] ) _vos;
    }


    /** */
    void om( IVo vo )
    {
        _vos ~= vo;

        if ( vo.o !is null )
        {
            vo.uno();
        }

        vo.o = this;
    }


    /** */
    void un( IVo vo )
    {
        import std.algorithm.searching : countUntil;
        import std.array               : replaceInPlace;


        auto pos = _vos.countUntil( vo );

        if ( pos != -1 )
            _vos.replaceInPlace( pos, pos+1, cast( IVo[] ) [] );
    }
}


