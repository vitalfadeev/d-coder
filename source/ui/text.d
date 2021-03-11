module ui.text;

import ui;


struct LineSet
{
    string s;
    int c;
    int d;
    int h;
    int g;
}


struct TextSet
{
    Rect[]    cdghs;  // Char posiztion and size: cd, gh
    LineSet[] lines;  // Lines: Length, Start
    int       c;
    int       d;
    int       cd;
    int       h;
    int       g;
    int       gh;
}

