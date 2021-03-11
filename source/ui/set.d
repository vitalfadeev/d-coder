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
// ( 0, 0 ) - ( d, h ) - center - ot

    void set();

    // In - message
    //ref Value a();
    //ref Value b();
    ref Value c();
    ref Value d();
    ref Value cd();
    //ref Value e();
    //ref Value f();
    ref Value g();
    ref Value h();
    ref Value gh();
    ref Value otd();
    ref Value oth();
    // Computers - transform - process
    //void compute_c();
    //void compute_d();
    //void compute_cd();
    void compute_c_d_cd();
    //void compute_g();
    //void compute_h();
    //void compute_gh();
    void compute_g_h_gh();
    void compute_otd_oth();
    // Computed state - Current state
    //int computed_a();
    //int computed_b();
    int computed_c();
    int computed_d();
    int computed_cd();
    //int computed_e();
    //int computed_f();
    int computed_g();
    int computed_h();
    int computed_gh();
    int computed_otd();
    int computed_oth();
}


//mixin template Set()
class Set : Vo, ISet
{
    // In - message
    //Value _a;
    //Value _b;
    Value _c;
    Value _d;
    Value _cd;
    //Value _e;
    //Value _f;
    Value _g;
    Value _h;
    Value _gh;
    // Center
    Value _otd;
    Value _oth;

    //ref Value a() { return _a; }
    //ref Value b() { return _b; }
    ref Value c()  { return _c; }
    ref Value d()  { return _d; }
    ref Value cd() { return _cd; }
    //ref Value e() { return _e; }
    //ref Value f() { return _f; }
    ref Value g()  { return _g; }
    ref Value h()  { return _h; }
    ref Value gh() { return _gh; }
    ref Value otd() { return _otd; }
    ref Value oth() { return _oth; }

    void set()
    {
        compute_c_d_cd();
        compute_g_h_gh();
        compute_otd_oth();
        set_vos();
    }


    void set_vos()
    {
        //assert( this.instanceof!IO );

        ( cast( IO ) this ).vos.set();
    }


    // Computers - transform - process
    /** */
    void compute_c_d_cd()
    {
        //
        compute_defined_c();
        compute_defined_d();
        compute_defined_cd();

        //
        compute_undefined_c();
        compute_undefined_d();
        compute_undefined_cd();
    }


    /** */
    void compute_g_h_gh()
    {
        //
        compute_defined_g();
        compute_defined_h();
        compute_defined_gh();

        //
        compute_undefined_g();
        compute_undefined_h();
        compute_undefined_gh();
    }


    /** */
    void compute_otd_oth()
    {
        compute_defined_otd();
        compute_defined_oth();
        
        compute_undefined_otd();
        compute_undefined_oth();
    }


    /** */
    import ui.set : Compute_X;
    mixin Compute_X!( "compute_defined_c", "_c", "_computed_c", "compute_c_d_cd", "computed_c", "computed_cd" );
    mixin Compute_X!( "compute_defined_d", "_d", "_computed_d", "compute_c_d_cd", "computed_d", "computed_cd" );
    mixin Compute_X!( "compute_defined_g", "_g", "_computed_g", "compute_g_h_gh", "computed_g", "computed_gh" );
    mixin Compute_X!( "compute_defined_h", "_h", "_computed_h", "compute_g_h_gh", "computed_h", "computed_gh" );

    import ui.set : Compute_XX;
    mixin Compute_XX!( "compute_defined_cd", "_cd", "_computed_cd", "compute_c_d_cd", "computed_cd" );
    mixin Compute_XX!( "compute_defined_gh", "_gh", "_computed_gh", "compute_g_h_gh", "computed_gh" );

    mixin Compute_X!( "compute_defined_otd", "_otd", "_computed_otd", "compute_c_d_cd", "computed_d", "computed_cd" );
    mixin Compute_X!( "compute_defined_oth", "_oth", "_computed_oth", "compute_g_h_gh", "computed_h", "computed_gh" );


    // Computed state - Current state
    //int _computed_a;
    //int _computed_b;
    int _computed_c;
    int _computed_d;
    int _computed_cd;
    //int _computed_e;
    //int _computed_f;
    int _computed_g;
    int _computed_h;
    int _computed_gh;
    int _computed_otd;
    int _computed_oth;

    /** */
    //int computed_a()  { return _computed_a; }
    //int computed_b()  { return _computed_b; }
    int computed_c()  { return _computed_c; }
    int computed_d()  { return _computed_d; }
    int computed_cd() { return _computed_cd; }
    //int computed_e()  { return _computed_e; }
    //int computed_f()  { return _computed_f; }
    int computed_g()  { return _computed_g; }
    int computed_h()  { return _computed_h; }
    int computed_gh() { return _computed_gh; }
    //
    int computed_otd() { return _computed_otd; }
    int computed_oth() { return _computed_oth; }

private:
    /** */
    void compute_undefined_c()
    {
        // cd defined
        if ( _cd.type != ValueType.Undefined )
        {
            // d defined
            if ( _d.type != ValueType.Undefined )
            {
                _computed_c = _computed_cd - _computed_d;
            }
            else // cd defined
            {
                _computed_c = -_computed_cd / 2;
            }
        }
        else
        {
            _computed_c = _computed_c.init;
        }        
    }


    /** */
    void compute_undefined_d()
    {
        // cd defined
        if ( _cd.type != ValueType.Undefined )
        {
            // c defined
            if ( _c.type != ValueType.Undefined )
            {
                _computed_d = _computed_c + _computed_cd;
            }
            else // cd defined
            {
                _computed_d = _computed_cd - _computed_cd / 2;
            }
        }
        else
        {
            _computed_d = _computed_d.init;
        }        
    }


    /** */
    void compute_undefined_cd()
    {
        import std.math : abs;

        if ( _c.type != ValueType.Undefined && _d.type != ValueType.Undefined )
        {
            _computed_cd = abs( _computed_d - _computed_c );
        }
    }


    /** */
    void compute_undefined_g()
    {
        // gh defined
        if ( _gh.type != ValueType.Undefined )
        {
            // h defined
            if ( _h.type != ValueType.Undefined )
            {
                _computed_g = _computed_gh - _computed_h;
            }
            else // gh defined
            {
                _computed_g = -_computed_gh / 2;
            }
        }
        else
        {
            _computed_g = _computed_g.init;
        }        
    }


    /** */
    void compute_undefined_h()
    {
        // gh defined
        if ( _gh.type != ValueType.Undefined )
        {
            // g defined
            if ( _g.type != ValueType.Undefined )
            {
                _computed_h = _computed_g + _computed_gh;
            }
            else // gh defined
            {
                _computed_h = _computed_gh - _computed_gh / 2;
            }
        }
        else
        {
            _computed_h = _computed_h.init;
        }        
    }


    /** */
    void compute_undefined_gh()
    {
        import std.math : abs;

        if ( _g.type != ValueType.Undefined && _h.type != ValueType.Undefined )
        {
            _computed_gh = abs( _computed_h - _computed_g );
        }
    }


    /** */
    void compute_undefined_otd()
    {
        // gh defined
        if ( _otd.type == ValueType.Undefined )
        {
            _computed_otd = _computed_otd.init;
        }        
    }


    /** */
    void compute_undefined_oth()
    {
        // gh defined
        if ( _oth.type == ValueType.Undefined )
        {
            _computed_oth = _computed_oth.init;
        }        
    }
}


/** */
void set( Object[] vos )
{
    foreach ( vo; vos )
    {
        //assert( vo.instanceof!ISet );

        ( cast( ISet ) vo ).set();
    }
}


// Compute_X!( "compute_defined_g", "_g", "_computed_g", "compute_g_h_gh", "computed_g", "compute_gh" )
mixin template Compute_X
( 
    string FUNC_NAME, 
    string NAME, 
    string COMPUTED_NAME, 
    string O_COMPUTE_FUNC,
    string O_COMPUTED_NAME,
    string O_COMPUTED_XX_NAME 
)
{
    import scriptlike;

    mixin( 
    mixin( interp!`
    void ${FUNC_NAME}()
    {
        // px | percent | initial | inherit

        import ui.value : ValueType;

        switch ( ${NAME}.type )
        {
            case ValueType.Px: {
                ${COMPUTED_NAME} = ${NAME}.pxValue;
                break;
            }

            case ValueType.Int: {
                ${COMPUTED_NAME} = ${NAME}.intValue;
                break;
            }

            case ValueType.Percent: {
                assert( this.instanceof!IVo );

                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).${O_COMPUTE_FUNC}();

                    ${COMPUTED_NAME} = 
                        ( cast( ISet ) o ).${O_COMPUTED_XX_NAME} * ${NAME}.percentValue / 100;
                }                
                else
                {
                    writeln( "O is null ( when compute \"${NAME}\" ): ", this );
                }
                break;
            }

            case ValueType.Inherit: {
                assert( this.instanceof!IVo );

                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).${O_COMPUTE_FUNC}();

                    ${COMPUTED_NAME} = ( cast( ISet ) o ).${O_COMPUTED_NAME};
                }                
                else
                {
                    writeln( "O is null ( when compute \"${NAME}\" ): ", this );
                }
                break;
            }

            case ValueType.Initial: {
                ${COMPUTED_NAME} = ${COMPUTED_NAME}.init;
                break;
            }

            default:
                //
        }
    }
    ` ) 
    );
}



// Compute_XX!( "compute_defined_cd", "_cd", "_computed_cd", "compute_c_d_cd", "computed_cd" )
mixin template Compute_XX
( 
    string FUNC_NAME,
    string XX_NAME,
    string COMPUTED_XX_NAME,
    string O_COMPUTE_FUNC,
    string O_COMPUTED_XX_NAME
)
{
    import scriptlike;

    mixin( 
    mixin( interp!`
    void ${FUNC_NAME}()
    {
        import ui.value : ValueType;

        switch ( ${XX_NAME}.type )
        {
            // cd defined
            case ValueType.Int: {
                ${COMPUTED_XX_NAME} = ${XX_NAME}.intValue;
                break;
            }

            case ValueType.Px: {
                ${COMPUTED_XX_NAME} = ${XX_NAME}.pxValue;
                break;
            }

            case ValueType.Percent: {
                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).${O_COMPUTE_FUNC}();

                    ${COMPUTED_XX_NAME} = 
                        ( cast( ISet ) o ).${O_COMPUTED_XX_NAME} * ${XX_NAME}.percentValue / 100;
                    return;
                }                
                else
                {
                    writeln( "O is null ( when compute \"${XX_NAME}\" ): ", this );
                }
                break;
            }

            case ValueType.Inherit: {
                if ( o !is null )
                {
                    assert( o.instanceof!ISet );

                    ( cast( ISet ) o ).${O_COMPUTE_FUNC}();

                    ${COMPUTED_XX_NAME} = ( cast( ISet ) o ).${O_COMPUTED_XX_NAME};
                    return;
                }                
                else
                {
                    writeln( "O is null ( when compute \"${XX_NAME}\" ): ", this );
                }
                break;
            }

            case ValueType.Initial: {
                ${COMPUTED_XX_NAME} = ${COMPUTED_XX_NAME}.init;
                break;
            }

            default:
                //
        }
    }
    ` ) 
    );
}
