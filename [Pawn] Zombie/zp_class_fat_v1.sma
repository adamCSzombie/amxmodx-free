/* Plugin generated by AMXX-Studio */

#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < zombieplague >
#include < fun >
#include < cstrike >

#define PLUGIN "[ZP-Class] Fat Zombie"
#define VERSION "1.4"
#define AUTHOR "adamCSzombie"

new const sleep_sound[ ] = 	{ "profun/zombie/sleep.wav" };
new const zclass_name[ ] = 	{ "Fat Zombie" };
new const zclass_info[ ] = 	{ "[vela zivota a oslepenie]" };
new const zclass_model[ ] = 	{ "profun_fat" };
new const zclass_clawmodel[ ] = 	{ "v_profun_fat.mdl" };
const zclass_health = 		2700;
const zclass_speed = 		240;
const Float:zclass_gravity = 	1.0;
const Float:zclass_knockback = 	0.50;

new g_classfat;

public plugin_init( ) {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_forward( FM_PlayerPreThink, "Daj_Oslepenie" );
	register_event( "CurWeapon" , "fw_EvCurWeapon" , "be" , "1=1" );
	//register_clcmd( "say /epictestingoslepenia","oslepenie" );
}

public plugin_precache( ) {
	g_classfat = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback );
	precache_sound( sleep_sound );
}

stock ChatColor( const id, const input[ ], any:... ) {
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	   
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );

   
	if( id ) players[ 0 ] = id; else get_players( players, count, "ch" )
	{
		for(new i = 0; i < count; i++)
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[ i ] );
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}


public Daj_Oslepenie( id ) {
	if( is_user_alive( id ) ) {
		new idAiming, iBodyPart;
		get_user_aiming( id, idAiming, iBodyPart );
		if( zp_get_user_zombie_class( idAiming ) ==  g_classfat ) {
			if( is_user_alive( idAiming ) && is_user_alive( id ) && zp_get_user_zombie( idAiming ) ) {
				if( cs_get_user_team( id ) == CS_TEAM_CT && cs_get_user_team( idAiming ) == CS_TEAM_T ) {
					oslepenie_random( id );
				}    
				
			}
		}
	}
	return PLUGIN_HANDLED;
}  

public oslepenie_random( id ) {
	switch( random( 1000 ) ) {
		case 200: oslepenie( id );
		case 400: oslepenie( id );
		case 600: oslepenie( id );
		case 800: oslepenie( id );
	}
	return PLUGIN_HANDLED;
} 

public oslepenie( id ) {
	client_cmd( id, "spk bluezone/zombie/sleep.wav" );
	ScreenFade( id, 3.0, 0, 0, 0, 9999999999999 );
} 

stock ScreenFade( plr, Float:fDuration, red, green, blue, alpha ) {
	new i = plr ? plr : get_maxplayers();
	if( !i )
	{
		return 0;
	}
	
	message_begin( plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade" ), {0, 0, 0}, plr );
	write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	write_short( 4096 );
	write_byte( red );
	write_byte( green );
	write_byte( blue );
	write_byte( alpha );
	message_end();
	
	return 1;
	
}

public fw_EvCurWeapon( id )
{
	if( is_user_alive( id ) )
	{
		if( zp_get_user_first_zombie( id ) )
		{
			if( zp_get_user_zombie_class( id ) ==  g_classfat )
			{
				new g_iPrevCurWeapon[ 33 ];
				new iCurWeapon = read_data( 3 )
				if( iCurWeapon != g_iPrevCurWeapon[ id ] )
				{
					set_user_maxspeed( id , 300.0 );
					g_iPrevCurWeapon[ id ] = iCurWeapon;
				}
			}
		}
	}
}

public zp_user_infected_post( player, infector )
{
	if( is_user_alive( player ) )
	{
		if( zp_get_user_zombie_class( player ) == g_classfat )
		{
			ChatColor( player ,"!t[FAT ZOMBIE]!y Tvoja schopnost je automaticky nastavena!" );
		}
	}
}
