/// Signifies that this proc is used to handle signals.
/// Every proc you pass to RegisterSignal must have this.
#define SIGNAL_HANDLER SHOULD_NOT_SLEEP(TRUE)

///Called when the ticker enters the pre-game phase
#define COMSIG_TICKER_ENTER_PREGAME "comsig_ticker_enter_pregame"

///Called when the ticker sets up the game for start
#define COMSIG_TICKER_ENTER_SETTING_UP "comsig_ticker_enter_setting_up"
