module ui.root;

import ui;


/** */
interface IRoot : IVid, ISet, IO, IVo
{
    //void set();
    //void vid( IRas ras );
    //void process( ref MouseKeyEvent event );
    //void process( ref KeyboardKeyEvent event );
}


/** */
class Root : Vid, IRoot
{
    //
}


// Thread locals
IRoot root;

