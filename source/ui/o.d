module ui.o;

import ui;


// O
/** */
interface IO
{
    Object[] vos();
    T om( T : Object )( T vo );
    void un( Object vo );
}


/** */
class O : IO
{
    Object[] _vos;


    /** */
    Object[] vos()
    {
        return _vos;
    }


    /** */
    T om( T : Object )( T vo )
    {
        assert( vo !is null );

        // uno
        if ( ( cast( IVo ) vo ).o !is null )
        {
            ( cast( IVo ) vo ).uno();
        }

        // om
        _vos ~= vo;

        // vo
        ( cast( IVo ) vo ).o = this;

        return vo;
    }


    /** */
    void un( Object vo )
    {
        import std.algorithm.searching : countUntil;
        import std.array               : replaceInPlace;


        auto pos = _vos.countUntil( vo );

        if ( pos != -1 )
            _vos.replaceInPlace( pos, pos+1, cast( Object[] ) [] );
    }
}


