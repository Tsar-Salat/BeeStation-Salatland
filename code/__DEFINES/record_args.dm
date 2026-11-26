// List of Record Arguments to make things safer
// I know this looks extremely wonky, but it's better than manual management... Believe me.

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_GENERAL_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_LOCK_STRICT_ARGS(arg01, arg02, arg03)\
arg01, arg02, arg03

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_CREW_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11
