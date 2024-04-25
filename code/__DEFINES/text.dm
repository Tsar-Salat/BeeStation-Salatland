/// Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Prepares a text to be used for maptext, using a variable size font.
/// Variable size font. More flexible but doesn't scale pixel perfect to BYOND icon resolutions. (May be blurry.) Can use any size in pt or px.
#define MAPTEXT_VCR_OSD_MONO(text) {"<span style='font-family: \"VCR OSD Mono\"'>[##text]</span>"}

/// Prepares a text to be used for maptext using a pixel font. Cleaner but less size choices.
/// Standard size (ie: normal runechat) Use only sizing pt, multiples of 6: 6pt 12pt 18pt 24pt etc. - Not for use with px sizing
#define MAPTEXT_GRAND9K(text) {"<span style='font-family: \"Grand9K Pixel\"'>[##text]</span>"}

/// Prepares a text to be used for maptext using a pixel font. Cleaner but less size choices.
/// Small size. (ie: whisper runechat) Use only size pt, multiples of 12: 12pt 24pt 48pt etc. - Not for use with px sizing
#define MAPTEXT_TINY_UNICODE(text) {"<span style='font-family: \"TinyUnicode\"'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

#define CENTER(text) {"<center>[##text]</center>"}

#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

#define COLOR_TEXT(color, text) "<font color=\"[color]\">[text]</font>"

/// type of a chat to send discord servers
#define CHAT_TYPE_OOC "chat_ooc"
#define CHAT_TYPE_DEADCHAT "chat_dead"

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP

// which strip method 'stripped_input()' proc will use?
#define BYOND_ENCODE "byond_encode"
#define STRIP_HTML "strip_html"
#define STRIP_HTML_SIMPLE "strip_html_simple"
#define SANITIZE "sanitize"
#define SANITIZE_SIMPLE "sanitize_simple"
#define ADMIN_SCRUB "admin_scrub"
