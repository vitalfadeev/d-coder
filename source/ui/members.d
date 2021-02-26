module ui.members;

import ui;


// Class members
/** */
mixin template Members()
{
    import std.meta   : AliasSeq;
    import std.meta   : Stride;
    import std.traits : InterfacesTuple;

    //alias templates = 
    //    AliasSeq!( 
    //        // template, interface
    //        Vo,  IVo,  
    //        O,   IO,   
    //        Set, ISet, 
    //        Vid, IVid, 
    //    );

    //static
    //foreach ( i, T; Stride!( 2, templates ) )
    //{
    //    static
    //    if ( is( typeof( this ) : templates[ i * 2 + 1 ] ) )
    //    {
    //        mixin T!();
    //    }
    //}


    pragma( msg, typeof( this ) );

    static
    foreach ( IFACE; InterfacesTuple!( typeof( this ) ) )
    {
        pragma( msg, "  " ~ IFACE.stringof );

        static
        if ( IFACE.stringof.length > 1 && IFACE.stringof[ 1 .. $ ] )
        {
            mixin( 
                format!
                q{
                    static
                    if ( __traits( isTemplate, %s ) )
                    {
                        pragma( msg, "    mixin " ~ IFACE.stringof );
                        mixin %s!();
                    }
                }
                ( 
                    IFACE.stringof[ 1 .. $ ],
                    IFACE.stringof[ 1 .. $ ]
                 )
            );
        }
    }

    
}


// each interface IT[]
//   recursive out
//     find mixin template T
//     mixin template T
