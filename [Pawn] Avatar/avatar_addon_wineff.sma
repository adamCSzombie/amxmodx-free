#include < amxmodx >
#include < zombieplague >

#define PLUGIN 		"[Avatar] Round Ended Effect"
#define VERSION 	"0.3"
#define AUTHOR 		"adamCSzombie"

new cvar_winzm_color[ 3 ] , cvar_winhuman_color[ 3 ] , cvar_rounddraw_color[ 3 ];

#define AVATAR_COLORS_RED		"65"
#define AVATAR_COLORS_GREEN		"165"
#define AVATAR_COLORS_BLUE		"65"

#define HUMANS_COLORS_RED		"50"
#define HUMANS_COLORS_GREEN		"150"
#define HUMANS_COLORS_BLUE		"250"

public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );

	// Cvars
	cvar_rounddraw_color[ 0 ] = 	register_cvar( "av_round_draw_color_R1", AVATAR_COLORS_RED );
	cvar_rounddraw_color[ 1 ] = 	register_cvar( "av_round_draw_color_G2", AVATAR_COLORS_GREEN );
	cvar_rounddraw_color[ 2 ] = 	register_cvar( "zp_round_draw_color_B3", AVATAR_COLORS_BLUE );
	
	cvar_winzm_color[ 0 ] = 		register_cvar( "av_win_zm_color_R1", AVATAR_COLORS_RED );
	cvar_winzm_color[ 1 ] = 		register_cvar( "av_win_zm_color_G2", AVATAR_COLORS_GREEN );
	cvar_winzm_color[ 2 ] = 		register_cvar( "av_win_zm_color_B3", AVATAR_COLORS_BLUE );

	cvar_winhuman_color[ 0 ] = 	register_cvar( "av_win_human_color_R1", HUMANS_COLORS_RED );
	cvar_winhuman_color[ 1 ] = 	register_cvar( "av_win_human_color_G2", HUMANS_COLORS_GREEN );
	cvar_winhuman_color[ 2 ] = 	register_cvar( "av_win_human_color_B3", HUMANS_COLORS_BLUE );
}

public zp_round_ended( zp_team ) 
{
	if( zp_team == WIN_NO_ONE )
	{	
		message_begin( MSG_BROADCAST, get_user_msgid( "ScreenFade" ) );
		write_short( ( 1 << 12 )*4 );
		write_short( ( 1 << 12 )*1 );	
		write_short( 0x0001 );	
		write_byte ( get_pcvar_num( cvar_rounddraw_color[ 0 ] ) ); 
		write_byte ( get_pcvar_num( cvar_rounddraw_color[ 1 ] ) );
		write_byte ( get_pcvar_num( cvar_rounddraw_color[ 2 ] ) );
		write_byte ( 255 );
		message_end( );
	}
	else if( zp_team == WIN_ZOMBIES )
	{
		message_begin( MSG_BROADCAST, get_user_msgid( "ScreenFade" ) );
		write_short( ( 1 << 12 )*4 );
		write_short( ( 1 << 12 )*1 );	
		write_short( 0x0001 );	
		write_byte ( get_pcvar_num( cvar_winzm_color[ 0 ] ) );
		write_byte ( get_pcvar_num( cvar_winzm_color[ 1 ] ) ); 
		write_byte ( get_pcvar_num( cvar_winzm_color[ 2 ] ) ); 
		write_byte ( 255 );
		message_end( );
	}
	else if( zp_team == WIN_HUMANS )
	{
		message_begin( MSG_BROADCAST, get_user_msgid( "ScreenFade" ) );
		write_short( ( 1<<12 )*4 );
		write_short( ( 1<<12 )*1 );	
		write_short( 0x0001 );	
		write_byte ( get_pcvar_num( cvar_winhuman_color[ 0 ] ) ); 
		write_byte ( get_pcvar_num( cvar_winhuman_color[ 1 ] ) ); 
		write_byte ( get_pcvar_num( cvar_winhuman_color[ 2 ] ) );
		write_byte ( 255 );
		message_end( );
	}
}
