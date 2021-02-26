module ui.utf;

import core.sys.windows.winnt   : LPWSTR, LPCWSTR, LPCSTR, LPSTR, LPTSTR, WCHAR;
import core.stdc.wchar_         : wcslen;
import std.conv                 : to;
import std.utf                  : toUTFz, toUTF16z, UTFException;


//
// all Windows applications today Unicode
//


/**
 */
LPWSTR toLPWSTR( string s ) nothrow // wchar_t*
{
    try                        { return toUTFz!( LPWSTR )( s ); }
    catch ( UTFException e )   { return cast( LPWSTR ) "ERR"w.ptr; }
    catch ( Exception e )      { return cast( LPWSTR ) "ERR"w.ptr; }
}
alias toLPWSTR toPWSTR;
alias toLPWSTR toLPOLESTR;
alias toLPWSTR toPOLESTR;

///
unittest
{
    auto a = "string".toLPWSTR();
    assert( is( typeof( a ) == wchar* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPWSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPCWSTR toLPCWSTR( string s ) nothrow // const( wchar )*
{
    try                        { return toUTF16z( s ); }
    catch ( UTFException e )   { return "ERR"w.ptr; }
    catch ( Exception e )      { return "ERR"w.ptr; }
}
alias toLPCWSTR toPCWSTR;


///
unittest
{
    auto a = "string".toPCWSTR();
    assert( is( typeof( a ) == const( wchar )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPWSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPCSTR toLPCSTR( string s ) nothrow // const( char_t )*
{
    try                        { return toUTFz!( LPCSTR )( s ); }
    catch ( UTFException e )   { return "ERR".ptr; }
    catch ( Exception e )      { return "ERR".ptr; }
}
alias toLPCSTR toPCSTR;


///
unittest
{
    auto a = "string".toPCSTR();
    assert( is( typeof( a ) == const( char )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toPCSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPSTR toLPSTR( string s ) nothrow // char_t*
{
    try                        { return toUTFz!( LPSTR )( s ); }
    catch ( UTFException e )   { return cast( LPSTR ) "ERR".ptr; }
    catch ( Exception e )      { return cast( LPSTR ) "ERR".ptr; }
}
alias toLPSTR toPSTR;


///
unittest
{
    auto a = "string".toLPSTR();
    assert( is( typeof( a ) == char* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPSTR();
    assert( ru.to!string == "строка" );
}


/**
 */
LPTSTR toLPTSTR( string s ) nothrow // wchar_t*
{
    try                        { return toUTFz!( LPTSTR )( s ); }
    catch ( UTFException e )   { return cast( LPTSTR ) "ERR"w.ptr; }
    catch ( Exception e )      { return cast( LPTSTR ) "ERR"w.ptr; }
}


///
unittest
{
    auto a = "string".toLPTSTR();
    assert( is( typeof( a ) == wchar* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".toLPTSTR();
    assert( ru.to!string == "строка" );
}


/**
 Implementation C macros: TEXT( "x" ) L"x"
 */
LPCWSTR TEXT( const string s )
{
    return toLPCWSTR( s );
}


///
unittest
{
    auto a = "string".TEXT();
    assert( is( typeof( a ) == const( wchar )* ) );
    assert( a.to!string == "string" );

    auto ru = "строка".TEXT();
    assert( ru.to!string == "строка" );
}


// alias wchar_t TCHAR;


/**
Example:
--------------------
WCHAR[ WLAN_MAX_NAME_LENGTH ] guidString;
string s;
s = _info.strInterfaceDescription[ 0 .. wcslen( _info.strInterfaceDescription.ptr ) ].to!string;
--------------------
*/ 
string wcharBufToString( ref WCHAR[] buf )  // WSTR -> string. WSTRtoString
{
    string s = buf.ptr[ 0 .. wcslen( buf.ptr ) ].to!string;
    
    return s;
}


string wcharBufToString( WCHAR[] buf )  // WSTR -> string. WSTRtoString
{
    string s = buf.ptr[ 0 .. wcslen( buf.ptr ) ].to!string;
    
    return s;
}


/**
Example:
--------------------
FormatMessage( ... lpMsgBuf ... )
fromUTF16z( cast( wchar* )lpMsgBuf )
--------------------
*/
//wstring fromUTF16z( const( wchar )* s )
//{
//    if ( s is null ) return null;

//    const( wchar )* ptr;
//    for ( ptr = s; *ptr; ++ptr ) {}

//    return to!wstring( s[ 0 .. ptr - s ] );
//}


/** */
//wstring fromWStringz( const( wchar )* s )
//{
//    if ( s is null ) return null;

//    const( wchar )* ptr;
//    for ( ptr = s; *ptr; ++ptr ) {}

//    return to!wstring( s[ 0 .. ptr - s ] );
//}


/** */
wstring fromWChar( const( wchar )* s )
{
    /** */
    size_t wcslen( const( wchar )* s  )
    {
        auto ptr = s;
        for ( ; *ptr != 0; ptr += 1 ) {}

        return ptr - s;
    }

    return to!wstring( s[ 0 .. wcslen( s ) ] );
}
alias fromWChar fromUTF16z;
alias fromWChar fromWStringz;


public import std.string : fromStringz;
