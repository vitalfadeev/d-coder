module ui.root;

import ui;


/** */
interface IRoot : IO
{
    void vid( IRas ras );
}


/** */
class Root : IRoot
{
    mixin Members!();


    /** */
    override
    void vid( IRas ras )
    {
        writeln( __FUNCTION__ );

        vos.vid( ras );
    }
}


// Thread locals
IRoot root;

