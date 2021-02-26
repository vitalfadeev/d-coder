module ui.files;

import ui;


/** */
enum : uint
{
    FIND_FIRST_EX_CASE_SENSITIVE = 1,
    FIND_FIRST_EX_LARGE_FETCH = 2,
    FIND_FIRST_EX_ON_DISK_ENTRIES_ONLY = 4
}



/** */
class Files
{
    import core.sys.windows.windows;
    import std.path   : buildPath;
    import std.string : toStringz;
    import std.utf    : toUTF16z;

    string path;
    File[] files;

    void read( string path )
    {
        this.path = path;

        //
        files = new File[]( 1000 );

        auto file = files.ptr;

        writeln( files[0].x );
        //writeln( file.data );

/+
        // System Read FS
        HANDLE _handle =
            FindFirstFileExW( 
                buildPath( path, "*.*" ).toUTF16z(), 
                FINDEX_INFO_LEVELS.FindExInfoStandard,
                &file.data,
                FINDEX_SEARCH_OPS.FindExSearchNameMatch,
                NULL,
                FIND_FIRST_EX_CASE_SENSITIVE | FIND_FIRST_EX_LARGE_FETCH | FIND_FIRST_EX_ON_DISK_ENTRIES_ONLY
             );

        //
        if ( _handle == INVALID_HANDLE_VALUE )
        {
            return;
        }

        // skip '.', '..'
        while ( file.data.cFileName[ 0 .. 2 ] == ".\0"w
             || file.data.cFileName[ 0 .. 3 ] == "..\0"w )
        {
            if ( FindNextFileW( _handle, &file.data ) == FALSE )
            {
                // GetLastError() == ERROR_NO_MORE_FILES
                FindClose( _handle );
                return;
            }
        }

        //
        do 
        {
            file += 1;
        } while ( FindNextFileW( _handle, &file.data ) == TRUE );

        FindClose( _handle );
+/
    }
}

/** */
class File
{
    import core.sys.windows.windows : WIN32_FIND_DATAW;

    WIN32_FIND_DATAW data;
    int x;
}

