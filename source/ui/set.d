module ui.set;

import ui;


// Set
/** */
interface ISet
{
//         H          
//         |          
//     C - . - D      
//         |          
//         G          
//
//
//       +100       
//         |       
//  -100 - 0 - +100
//         |       
//       -100
//

    void set();

    // In - message
    //ref Value a();
    //ref Value b();
    ref Value c();
    ref Value d();
    //ref Value e();
    //ref Value f();
    //ref Value g();
    //ref Value h();
    // Computers - transform - process
    void compute_c();
    void compute_d();
    void compute_cd();
    //void compute_g();
    //void compute_h();
    //void compute_gh();
    // Computed state - Current state
    //int computed_a();
    //int computed_b();
    int computed_c();
    int computed_d();
    int computed_cd();
    //int computed_e();
    //int computed_f();
    //int computed_g();
    //int computed_h();
    //int computed_gh();
}


mixin template Set()
{
    // In - message
    //Value _a;
    //Value _b;
    Value _c;
    Value _d;
    Value _cd;
    //Value _e;
    //Value _f;
    //Value _g;
    //Value _h;

    //ref Value a() { return _a; }
    //ref Value b() { return _b; }
    ref Value c()  { return _c; }
    ref Value d()  { return _d; }
    ref Value cd() { return _cd; }
    //ref Value e() { return _e; }
    //ref Value f() { return _f; }
    //ref Value g() { return _g; }
    //ref Value h() { return _h; }

    // Computers - transform - process
    /** */
    void compute_c()
    {
        // px | percent | initial | inherit

        //
        switch ( c.type )
        {
            case ValueType.Px: {
                _computed_c = c.pxValue;
                return;
            }

            case ValueType.Int: {
                _computed_c  = c.intValue;
                return;
            }

            case ValueType.Percent: {
                assert( this.instanceof!IVo );

                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).compute_cd();

                    int ocd = ( cast( ISet ) o ).computed_cd;
                    _computed_c = ocd * c.percentValue / 100;
                    return;
                }                
                else
                {
                    writeln( "Ot is null ( when compute \"c\" ): ", this );
                }
                break;
            }

            default:
                _computed_c = _computed_c.init;
        }
    }

    /** */
    void compute_d()
    {
        // px | percent | initial | inherit

        //
        switch ( d.type )
        {
            case ValueType.Px: {
                _computed_d = d.pxValue;
                return;
            }

            case ValueType.Int: {
                _computed_d  = d.intValue;
                return;
            }

            case ValueType.Percent: {
                assert( this.instanceof!IVo );

                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).compute_cd();

                    int ocd = ( cast( ISet ) o ).computed_cd;
                    _computed_d = ocd * d.percentValue / 100;
                    return;
                }                
                else
                {
                    writeln( "Ot is null ( when compute \"d\" ): ", this );
                }
                break;
            }

            default:
                _computed_d = _computed_d.init;
        }
    }


    /** */
    void compute_cd()
    {
        // c - d

        compute_c();
        compute_d();

        if ( _computed_c > _computed_d )
            _computed_cd = _computed_c - _computed_d;
        else
            _computed_cd = _computed_d - _computed_c;
    }


    // Computed state - Current state
    //int _computed_a;
    //int _computed_b;
    int _computed_c;
    int _computed_d;
    int _computed_cd;
    //int _computed_e;
    //int _computed_f;
    //int _computed_g;
    //int _computed_h;
    //int _computed_gh;

    /** */
    //int computed_a()  { return _computed_a; }
    //int computed_b()  { return _computed_b; }
    int computed_c()  { return _computed_c; }
    int computed_d()  { return _computed_d; }
    int computed_cd() { return _computed_cd; }
    //int computed_e()  { return _computed_e; }
    //int computed_f()  { return _computed_f; }
    //int computed_g()  { return _computed_g; }
    //int computed_h()  { return _computed_h; }
    //int computed_gh() { return _computed_gh; }
}


/** */
void set( IVo[] vos )
{
    foreach( i, vo; vos )
    {
        assert( vo.instanceof!ISet );

        ( cast( ISet ) vo ).c = i.to!int;
    }
}
