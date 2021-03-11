module ui.meta;




/** */
bool _instanceof( T )( ref TypeInfo_Class info )
  if ( is( T == class ) )
{
    if ( info.name == T.classinfo.name )
    {
        return true;
    }
    else
    {
        if ( info.base !is null )
        {
            // recursive out
            return _instanceof!T( info.base );
        }
    }

    return false;
}


/** */
bool _instanceof( T )( ref TypeInfo_Class info )
  if ( is( T == interface ) )
{
    import std.stdio : writeln;

    // scan in width
    // 1. same level
    foreach( iface; info.interfaces )
    {
        if ( iface.classinfo.name == T.classinfo.name )
            return true;
    }

    // 2. step in deep
    foreach( iface; info.interfaces )
    {
        if ( _instanceof!T( iface.classinfo ) )
            return true;
    }

    return false;
}


/** */
bool instanceof( T )( Object o )
  if ( is( T == interface ) || is( T == class ) )
{
    import std.stdio : writeln;

    if ( o.classinfo.name == T.classinfo.name )
        return true;
    else
        return _instanceof!T( o.classinfo );
}


///
unittest
{
    class A
    {
        int x;
    }

    class B : A
    {
        int bx;
    }

    interface IC
    {
        int x();
    }

    class C : IC
    {
        int x() { return 0; };
    }


    interface ID : IC
    {
        int x();
    }

    class D : ID
    {
        int x() { return 0; };
    }


    //
    auto a = new A();
    assert( a.instanceof!A );

    auto b = new B();
    assert( !a.instanceof!B );
    assert( b.instanceof!A );
    assert( b.instanceof!B );

    auto c = new C();
    assert( !a.instanceof!C );
    assert( !b.instanceof!C );
    assert( c.instanceof!C );
    assert( c.instanceof!IC );

    auto d = new D();
    assert( !a.instanceof!D );
    assert( !b.instanceof!D );
    assert( !c.instanceof!D );
    assert( d.instanceof!D );
    assert( d.instanceof!ID );
    assert( d.instanceof!IC );
}
