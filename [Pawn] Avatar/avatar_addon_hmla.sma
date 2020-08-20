#include < amxmodx >

#define PLUGIN			"[Avatar] Hmla"
#define VERSION			"0.3"
#define	AUTHOR			"adamCSzombie"
#define FOG_DENSITY		"1"
#define FOG_R			"125"
#define FOG_G			"31"
#define FOG_B			"122"

new cvar_fog_density, cvar_fog_color[ 3 ]

new const g_fog_density[ ] = { 0, 0, 0, 0, 111, 18, 3, 58, 111, 18, 125, 58, 66, 96, 27, 59, 90, 101, 60, 59, 90,
			101, 68, 59, 10, 41, 95, 59, 111, 18, 125, 59, 111, 18, 3, 60, 68, 116, 19, 60 }

new const TASK_FOG = 5942;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	cvar_fog_density = 	register_cvar( "av_adv_fog_density", FOG_DENSITY );
	cvar_fog_color[ 0 ] = 	register_cvar( "zpd_adv_fog_color_R", FOG_R  );
	cvar_fog_color[ 1 ] =	register_cvar( "zpd_adv_fog_color_G", FOG_G );
	cvar_fog_color[ 2 ] = 	register_cvar( "zpd_adv_fog_color_B", FOG_B );
	
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
}

public event_round_start( )
{
	remove_task( TASK_FOG );
	set_task( 0.5, "task_update_fog", TASK_FOG, _, _, "b" );
}

public task_update_fog( )
{
	static density;
	density = ( 4 * get_pcvar_num( cvar_fog_density ) );
	
	message_begin( MSG_ALL, get_user_msgid( "Fog" ), { 0,0,0 }, 0 );
	write_byte( get_pcvar_num( cvar_fog_color[ 0 ] ) );
	write_byte( get_pcvar_num( cvar_fog_color[ 1 ] ) );
	write_byte( get_pcvar_num( cvar_fog_color[ 2 ] ) );
	write_byte( g_fog_density[ density ] );
	write_byte( g_fog_density[ density+1 ] ); 
	write_byte( g_fog_density[ density+2 ] );
	write_byte( g_fog_density[ density+3 ] ); 
	message_end( );
}
