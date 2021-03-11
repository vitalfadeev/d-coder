module ui.tools;

import core.sys.windows.windows;
import std.conv  : to;
import std.stdio : writeln;
import std.stdio : writefln;
import std.range.primitives : isRandomAccessRange, isInputRange;


pragma( inline )
void Writeln( A... )( A a ) nothrow
{
    try {
        writeln( a );
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


pragma( inline )
void Writefln( A... )( A a ) nothrow
{
    try {
        writefln( a );
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


pragma( inline )
auto To( TYPE, VAR )( VAR var ) nothrow
{
    try {
        return var.to!TYPE;
    } catch ( Throwable e ) { assert( 0, e.toString() ); }
}


template staticCat(T...)
if (T.length)
{
    import std.array;
    enum staticCat = [T].join();
}


pragma( inline )
bool odd(T)(T n) { return n & 1; }


pragma( inline )
bool even(T)(T n) { return !( n & 1 ); }


pragma( inline )
T max( T )( T a, T b ) nothrow
{
    return ( a > b ) ? a : b;
}

pragma( inline )
T max( T )( T a, T b, T c ) nothrow
{
    if ( a > b ) 
    {
        if ( a > c )
            return a;
        else
            return c;
    }
    else
        return b;
}


pragma( inline )
T min( T )( T a, T b ) nothrow
{
    return ( a < b ) ? a : b;
}


T min( T )( T a, T b , T c ) nothrow
{
    if ( a < b ) 
    {
        if ( a < c )
            return a;
        else
            return c;
    }
    else
        return b;
}


int GET_X_LPARAM( LPARAM lp ) nothrow
{
    return cast( int ) cast( short )LOWORD( lp );
}


int GET_Y_LPARAM( LPARAM lp ) nothrow
{
    return cast( int ) cast( short )HIWORD( lp );
}


/** */
T instanceof( T )( Object o ) 
  //if ( is( T == class ) || is( T == interafce ) ) 
  if ( is( T == class ) ) 
{
    return cast( T ) o;
}

///
unittest
{
    class Base {}
    class A : Base {}
    class B : Base {}
    
    auto obj = new A;
    assert( obj.instanceof!A );
    assert( obj.instanceof!Base );
    assert( !obj.instanceof!B );
}


/**
*/
string baseName( ClassInfo classinfo ) 
{
    import std.array;
    import std.algorithm : countUntil;
    import std.range : retro;

    string qualName = classinfo.name;

    size_t dotIndex = qualName.retro.countUntil('.');

    if ( dotIndex < 0 ) 
    {
        return qualName;
    }

    return qualName[ $ - dotIndex .. $ ];
}


string moduleName( ClassInfo classinfo ) 
{
    import std.array;
    import std.algorithm : countUntil;
    import std.range : retro;

    string qualName = classinfo.name;

    size_t dotIndex = qualName.retro.countUntil('.');

    if ( dotIndex < 0 ) 
    {
        return "";
    }

    return qualName[ 0 .. $ - dotIndex - 1 ];
}


/**
*/
string classBaseName( Object instance ) 
{
    if ( instance is null ) 
    {
        return "null";
    }

    return instance.classinfo.baseName;
}


/**
*/
string classModuleName( Object instance ) 
{
    if ( instance is null ) 
    {
        return "null";
    }

    return instance.classinfo.moduleName;
}


/**
*/
T instance( T )()
{
 static T _instance;

 if ( !_instance )
 {
    _instance = new T();
 }

 return _instance;
}


/** 
*/
auto frontOrNull( R )( R range )
  if ( isInputRange!R )
{
    import std.range : empty, front;

    return range.empty ? null : range.front;
}

///
unittest
{
    import std.algorithm.searching : find;

    string[] strings;
    strings ~= "one";
    strings ~= "two";
    strings ~= "three";

    string name = "one";
    assert( strings.find!( ( string c ) => ( c == name ) ).frontOrNull == "one" );

    string name2 = "two";
    assert( strings.find!( ( string c ) => ( c == name2 ) ).frontOrNull == "two" );

    string nameOurside = "zero";
    assert( strings.find!( ( string c ) => ( c == nameOurside ) ).frontOrNull is null );
}


/**
*/
auto backOrNull( R )( R range )
  if ( isInputRange!R )
{
    import std.range : empty, back;

    return range.empty ? null : range.back;
}


///
unittest
{
    import std.algorithm.searching : find;

    string[] strings;
    strings ~= "one";
    strings ~= "two";
    strings ~= "three";

    string name = "one";
    assert( strings.find!( ( string c ) => ( c == name ) ).backOrNull == "three" );

    string name2 = "three";
    assert( strings.find!( ( string c ) => ( c == name2 ) ).backOrNull == "three" );

    string nameOurside = "zero";
    assert( strings.find!( ( string c ) => ( c == nameOurside ) ).backOrNull is null );
}


/** */
pragma( inline )
bool between( T, TA, TB )( T x, TA a, TB b )
{
    return ( x >= a ) && ( x < b ); // exclude b
}


/** */
pragma( inline )
bool betweenInclude( T, TA, TB )( T x, TA a, TB b )
{
    return ( x >= a ) && ( x <= b );
}


/** */
string getStackTrace() 
{
    import core.runtime;

    version(Posix) {
        // druntime cuts out the first few functions on the trace as they are internal
        // so we'll make some dummy functions here so our actual info doesn't get cut
        Throwable.TraceInfo f5() { return defaultTraceHandler(); }
        Throwable.TraceInfo f4() { return f5(); }
        Throwable.TraceInfo f3() { return f4(); }
        Throwable.TraceInfo f2() { return f3(); }
        auto stuff = f2();
    } else {
        auto stuff = defaultTraceHandler();
    }

    return stuff.toString();
}


/** Prev char position in UTF8 string */
size_t prevCodepoint( string s, size_t pos )
{
    import std.encoding : lastSequence;

    // Get Prev UTF8 Symbol length
    size_t l = s[ 0 .. pos ].lastSequence;

    return pos - l;
}


/** Next char position in UTF8 string */
size_t nextCodepoint( string s, size_t pos )
{
    import std.encoding : index;

    // Get Next UTF8 Symbol length
    size_t l = s[ pos .. $ ].index( 1 );

    return pos + l;
}


/** */
string[] systemDrives()
{
    import core.sys.windows.windows;
    import core.stdc.wchar_ : wcslen;
    import std.string       : stripRight;
    import ui.utf           : fromWStringz;
    
    DWORD dwSize = MAX_PATH;

    string[] drives;

    wchar[ MAX_PATH ] szLogicalDrives;
    DWORD dwResult = GetLogicalDriveStrings( dwSize, cast( LPWSTR ) szLogicalDrives.ptr );

    if ( dwResult > 0 && dwResult <= MAX_PATH )
    {
        wchar* szSingleDrive = szLogicalDrives.ptr;
        string drive;
        
        while ( *szSingleDrive )
        {
            drive = fromWStringz( szSingleDrive ).to!string;
            drives ~= drive.stripRight( r"\" );  // without trailing '\'

            // get the next drive
            szSingleDrive += drive.length + 1;
        }
    }

    return drives;
}


/** */
//string[] systemVolumes()
//{
//    import core.sys.windows.windows;
//    import ui.utf : wcharBufToString;

//    string[] volumes;

//    enum DWORD BuffSize = MAX_PATH;
//    wchar[ BuffSize ] buf;

//    HANDLE hdl = FindFirstVolumeW( cast( LPWSTR ) buf.ptr, BuffSize );

//    if ( hdl != INVALID_HANDLE_VALUE  )
//    {
//        do
//        {
//            volumes ~= buf.wcharBufToString;
//        } while ( FindNextVolumeW( hdl, cast( LPWSTR ) buf.ptr, BuffSize ) );

//        FindVolumeClose( hdl );

//        return volumes; // OK
//    }
//    else
//    {
//        return volumes; // FAIL
//    }
//}
