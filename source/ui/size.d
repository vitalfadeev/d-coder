module ui.size;

import core.sys.windows.windows;


struct Size
{
    union 
    {
        struct
        {
            int cd;
            int gh;
        }
        SIZE windowsSIZE;
    }
}
