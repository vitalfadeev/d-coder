module ui;

// Standart
public import std.stdio  : writeln;
public import std.conv   : to;
public import std.format : format;

// Helpers
public import ui.utf     : toLPWSTR;
public import ui.meta    : instanceof;
public import ui.tools   : min;
public import ui.tools   : max;
public import ui.tools   : GET_X_LPARAM;
public import ui.tools   : GET_Y_LPARAM;

// Vid
public import ui.vidpipe : touch;

// Structs
public import ui.rect    : Rect;
public import ui.size    : Size;
public import ui.ra      : Ra;
public import ui.text    : TextSet;
public import ui.point   : Point;

// Events
public import ui.event   : MouseKeyEvent;
public import ui.event   : MouseMoveEvent;
public import ui.event   : KeyboardKeyEvent;
//public import ui.vid     : process;
public import ui.mag     : processMouseKey;
public import ui.mag     : processMouseMove;
public import ui.keycodes;

// Base classes
public import ui.members : Members;
public import ui.o       : IO;
public import ui.o       : O;
public import ui.vo      : IVo;
public import ui.vo      : Vo;
public import ui.set     : ISet;
public import ui.set     : Set;
public import ui.set     : set;
public import ui.vid     : IVid;
public import ui.vid     : Vid;
public import ui.vid     : vid;
public import ui.pen     : IPen;
public import ui.pen     : Pen;
public import ui.ras     : IRas;
public import ui.ras     : Ras;
public import ui.vidpipe : VidPipe;
public import ui.root    : IRoot;
public import ui.root    : Root;
public import ui.list    : IList;
public import ui.list    : List;
//public import ui.window  : Window;
public import ui.meta    : instanceof;

// Value
public import ui.value   : Value;
public import ui.value   : ValueType;
public import ui.value   : RaValue;
public import ui.value   : px;
public import ui.ra      : rgb;
public import ui.value   : Auto;
public import ui.value   : percent;
public import ui.value   : inherit;
public import ui.value   : Position;
public import ui.value   : DisplaySelf;
public import ui.value   : DisplayChilds;

// Thread locals
//public import ui.root    : root;
//public import ui.vidpipe : vidPipe;
//public import ui.mag     : magsRegistry;

