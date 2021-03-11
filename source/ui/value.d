module ui.value;

import ui.ra : Ra;
import ui.ra : rgb;


/** */
struct Value
{
    ValueType type = ValueType.Undefined;
    union
    {
        //float        floatValue;
        int           intValue;
        //uint          uintValue;
        bool          boolValue;
        int           pxValue;
        int           percentValue;
        uint          AutoValue;
        string        stringValue;
        DisplaySelf   displaySelfValue;
        DisplayChilds displayChildsValue;
        Position      positionValue;
        Ra            raValue;
    }


    //pragma( inline )
    //void opAssign( uint a )
    //{
    //    type      = ValueType.Uint;
    //    uintValue = a;
    //}


    pragma( inline )
    void opAssign( int a )
    {
        type     = ValueType.Int;
        intValue = a;
    }


    // = 
    pragma( inline )
    void opAssign( Percent a )
    {
        type         = ValueType.Percent;
        percentValue = a;
    }


    pragma( inline )
    void opAssign( Px a )
    {
        type    = ValueType.Px;
        pxValue = a;
    }


    pragma( inline )
    void opAssign( DisplaySelf a )
    {
        type             = ValueType.DisplaySelf;
        displaySelfValue = a;
    }


    pragma( inline )
    void opAssign( DisplayChilds a )
    {
        type               = ValueType.DisplayChilds;
        displayChildsValue = a;
    }


    pragma( inline )
    void opAssign( Position a )
    {
        type          = ValueType.Position;
        positionValue = a;
    }


    pragma( inline )
    void opAssign( bool a )
    {
        type      = ValueType.Bool;
        boolValue = a;
    }


    pragma( inline )
    void opAssign( Inherit a )
    {
        type = ValueType.Inherit;
    }


    pragma( inline )
    void opAssign( Auto_ a )
    {
        type = ValueType.Auto;
    }


    pragma( inline )
    void opAssign( Ra a )
    {
        type    = ValueType.Ra;
        raValue = a;
    }


    pragma( inline )
    void opAssign( string a )
    {
        type        = ValueType.String;
        stringValue = a;
    }


    // + - / * 
    //pragma( inline )
    //Value opOpAssign( string op : "+" )( Value b )
    //{
    //    alias a this;
    //    if ( a.type == ValueType.Px && b.type == ValueType.Px )
    //    {
    //        Value result;

    //        result.type    = ValueType.Px;
    //        result.pxValue = a.pxValue + b.pxValue;

    //        return result;
    //    }
    //}
}


/** */
struct RaValue
{
    Value v = { type: ValueType.Ra, raValue: 0x444444.rgb };
    alias v this;


    pragma( inline )
    void opAssign( Inherit a )
    {
        type = ValueType.Inherit;
    }


    pragma( inline )
    void opAssign( uint a )
    {
        type    = ValueType.Ra;
        raValue = a.rgb;
    }


    pragma( inline )
    void opAssign( Ra a )
    {
        type    = ValueType.Ra;
        raValue = a;
    }
}


/** */
struct Percent
{
    uint a;
    alias a this;
}

/** */
pragma( inline )
Percent percent( uint a )
{
    return cast( Percent ) a ;
}


/** */
struct Inherit
{
    uint a;
    alias a this;
}

/** */
pragma( inline )
Inherit inherit()
{
    return cast( Inherit ) 0;
}



/** */
struct Px
{
    uint a;
    alias a this;


    pragma( inline )
    Px opBinary( string op )( Px b )
    {
        return mixin( "Px( a " ~ op ~ " b )" );
    }
}

/** */
pragma( inline )
Px px( uint a )
{
    return cast( Px ) a ;
}


/** */
struct Auto_
{
    uint a;
    alias a this;
}

/** */
pragma( inline )
Auto_ Auto()
{
    return cast( Auto_ ) 0;
}


/** */
enum DisplaySelf
{
    Inline,
    Block,
    InlineBlock,
}


/** */
enum DisplayChilds
{
    Inline,
    Block,
    InlineBlock,
}


/** */
enum Position
{
    Relative,
    Absolute,
}


/** */
enum ValueType
{
    Undefined,
    Auto,
    Int,
    //Uint,
    Bool,
    //Float,
    String,
    Px,
    Percent,
    Inherit,
    Initial,
    DisplaySelf,
    DisplayChilds,
    Position,
    Ra,
}


