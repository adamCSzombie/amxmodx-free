#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include < zombieplague >
#include < fun >
#include < cstrike >

new const zclass_name[ ] =	{ "Crab Zombie" };
new const zclass_info[ ] = 	{ "[sanca na kriticke uhryznutie]" };
new const zclass_model[ ] = 	{ "profun_crab" };
new const zclass_clawmodel[ ] = 	{ "v_profun_crab.mdl" };
const zclass_health = 		950; // 920
const zclass_speed = 		655; // 635
const Float:zclass_gravity = 	0.55; // 0.6
const Float:zclass_knockback = 	1.0; // 1.15

new g_zcrawl, g_ducked[ 33 ], g_maxplayers, g_maxspeed;

public plugin_init( ) {
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	register_logevent( "logevent_round_end", 2, "1=Round_End" );
	
	register_forward( FM_PlayerPreThink, "fw_PlayerPreThink" );
	RegisterHam( Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post", 0 );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled" );
	register_event( "CurWeapon" , "fw_EvCurWeapon" , "be" , "1=1" );
	g_maxplayers = get_maxplayers( );
	g_maxspeed = get_cvar_pointer( "sv_maxspeed" );
	
}

public plugin_precache( ) {
	register_plugin( "[ZP-Class] Crab Zombie", "1.6", "adamCSzombie" );
	g_zcrawl = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback );
}

public ham_Player_TakeDamage_Post( iVictim, iInfictor, iAttacker, Float:fDamage, iDmgBits ) {	
	if( !is_user_connected( iVictim ) || !is_user_connected( iAttacker ) || iVictim == iAttacker )
		return HAM_IGNORED;
		
	new iWeapon = get_user_weapon( iAttacker );
	
	switch( cs_get_user_team( iAttacker ) ) {
		case CS_TEAM_T: {
			if( zp_get_user_zombie_class( iAttacker ) ==  g_zcrawl && cs_get_user_team( iVictim ) == CS_TEAM_CT ) {
				new random_crit_armor = random_num( 10, 250 );
				new random_crit_health = random_num( 100, 250 );
				
				if( iWeapon == CSW_KNIFE ) {
					new random = random_num( 1,5 );
					if( !is_user_resist( iVictim ) ) {	
						if( random == 1 ) {
							client_print( iVictim, print_center, "Kriticke Kusnutie!" );
							client_print( iAttacker, print_center, "Kriticke Kusnutie!" );
							ScreenFade( iVictim, 1.0, 255, 0, 0, 100 );
							ScreenFade( iAttacker, 1.0, 255, 0, 0, 100 );
							if( get_user_armor( iVictim ) < 0 ) {
								cs_set_user_armor( iVictim, 0, CS_ARMOR_NONE );
							} else {
								set_user_armor( iVictim, get_user_armor( iVictim ) - random_crit_armor );
							}
						}
					} else {
						client_print( iAttacker, print_center, "Tento hrac ma Resist Humana!" );
						ScreenFade( iAttacker, 1.0, 165, 65, 65, 100 );
					}
				} else {
					if( zp_get_user_last_human( iVictim ) ) {
						if( get_user_health( iVictim ) >= 251 ) {
							set_user_health( iVictim, get_user_health( iVictim ) - random_crit_health );
						} else {
							set_user_health( iVictim, 1 );
						}
					}
				}
			}
		}
	}
	return HAM_IGNORED;
}

stock fm_set_user_armor( id, armor ) 
{
	set_pev( id, pev_armorvalue, float( armor ) );
	return 1;
}

stock ScreenFade( plr, Float:fDuration, red, green, blue, alpha )
{
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

public zp_user_infected_post( id, infector, nemesis )
{
	if( nemesis )
	{
		unduck_player( id );
		
		g_ducked[ id ] = false;
		
		return;
	}
	
	if( zp_get_user_zombie_class( id ) != g_zcrawl )
	{
		g_ducked[ id ] = false;
		
		return;
	}
		
	client_cmd( id, "cl_forwardspeed %d; cl_backspeed %d; cl_sidespeed %d", Float:zclass_speed, Float:zclass_speed, Float:zclass_speed );
	
	g_ducked[ id ] = true;
}

stock ChatColor( const id, const input[ ], any:... ) 
{
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

public zp_user_humanized_post( id, survivor )
{
	unduck_player( id )
	
	g_ducked[ id ] = false;
}

public client_connect( id ) {
	unduck_player( id );
	g_ducked[ id ] = false
}

public client_disconnect( id ) {
	unduck_player( id );
}

public fw_PlayerPreThink( id )
{
	if( zp_get_user_nemesis( id ) || !zp_get_user_zombie( id ) || is_user_bot( id )
	|| zp_get_user_zombie_class( id ) != g_zcrawl || !is_user_alive( id ) )
		return;
	
	set_pev( id, pev_bInDuck, 1 );
	client_cmd( id, "+duck" );
	
	g_ducked[ id ] = true;
}

public fw_PlayerKilled( id )
{
	unduck_player( id );
	
	g_ducked[ id ] = false;
}

public logevent_round_end( )
{
	static id;
	
	for( id = 1; id <= g_maxplayers; id++ ) {
		if( zp_get_user_nemesis( id ) || !zp_get_user_zombie( id ) || zp_get_user_zombie_class( id ) != g_zcrawl || !is_user_alive( id ) )
			g_ducked[ id ] = false;
		else
			g_ducked[ id ] = true
	}
}

public event_round_start( )
{
	if( get_pcvar_float( g_maxspeed ) < Float:zclass_speed )
		server_cmd( "sv_maxspeed 99999" ); // Better than setting it to the zombie speed value
	
	static id;
	
	for( id = 1; id <= g_maxplayers; id++ )
	{
		// Get the hell up
		unduck_player( id );
		
		g_ducked[ id ] = false;
	}
}

public unduck_player( id )
{
	// Isn't ducked | Is a bot
	if( !g_ducked[ id ] || is_user_bot( id ) )
		return;
	
	set_pev( id, pev_bInDuck, 0 );
	client_cmd( id, "-duck" );
	client_cmd( id, "-duck" ); 
	client_cmd( id, "cl_forwardspeed 700; cl_backspeed 700; cl_sidespeed 700" );
}

public fw_EvCurWeapon( id )
{
	if( is_user_alive( id ) )
	{
		if( zp_get_user_first_zombie( id ) )
		{
			if( zp_get_user_zombie_class( id ) ==  g_zcrawl )
			{
				new g_iPrevCurWeapon[ 33 ];
				new iCurWeapon = read_data( 3 )
				if( iCurWeapon != g_iPrevCurWeapon[ id ] )
				{
					set_user_maxspeed( id , 900.0 );
					g_iPrevCurWeapon[ id ] = iCurWeapon;
				}
			}
		}
	}
}

