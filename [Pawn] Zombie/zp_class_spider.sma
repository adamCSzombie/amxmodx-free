#include < amxmodx >
#include < fakemeta >
#include < fakemeta_util >
#include < hamsandwich >
#include < zombieplague >
#include < fun >
#include < engine >

new const zclass_name[ ] = 	{ "Spider Zombie" }; 
new const zclass_info[ ] = 	{ "[pritahovanie pavucinou]" }; 
new const zclass_model[ ] = 	{ "bz_spider" }; 
new const zclass_clawmodel[ ] = { "bz_spider_hand.mdl" };
const zclass_health = 		1450;
const zclass_speed = 		245;
const Float:zclass_gravity = 	0.8;
const Float:zclass_knockback = 	1.0;

new g_zclass_spider;

new g_pritiahnutia[ 33 ];
new Float:g_hook_speed[ 33 ];
new Float:gravity;
new g_hook_color[ 33 ], g_kontrola[ 33 ];
new bool:hook[ 33 ];
new hook_to[ 33 ][ 3 ];
new hashook[ 33 ];
new beamsprite;
new g_maxplayers;
new spider_sound[ ] = 		{ "bluezone/zombie/spider_sit.wav" };

public plugin_init( ) {
	register_plugin( "[ZP-Class] Spider", "0.2", "adamCSzombie" ) ;

	g_zclass_spider = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback );
	register_concmd( "+hook","hook_on" );
	register_concmd( "-hook","hook_off" );
	register_event( "CurWeapon" , "fw_EvEECurWeapon" , "be" , "1=1" );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled" );
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" )
	register_forward( FM_CmdStart , "fw_FM_CmdStart" );
	g_maxplayers = get_maxplayers( );
}

public plugin_precache( ) {
	beamsprite = precache_model( "sprites/plasma.spr" );
	precache_sound( spider_sound );
}

public fw_FM_CmdStart( id , Handle ) {
	static iButtons , iOldButtons;
	iButtons = get_uc( Handle , UC_Buttons );
	iOldButtons = pev( id , pev_oldbuttons );
	if( zp_get_user_zombie( id ) ) {
		if( zp_get_user_zombie_class( id ) == g_zclass_spider ) {
			if( ( iButtons & IN_USE ) && !( iOldButtons & IN_USE) ) {
				if( g_pritiahnutia[ id ] != 0 ) {
					if( hook[ id ] ) {
						hook[ id ] = false;
						hashook[ id ] = true;
						g_kontrola[ id ] = false;
						remove_task( id + 10000 );
						g_pritiahnutia[ id ]--;
						remove_task( id );
						ScreenFade( id, 0.1, 255, 25, 25, 100 );
						client_print( id, print_center, "Zrusil si pritiahnutie!" );
						ChatColor( id, "!t[SPIDER ZOMBIE]!y Pritiahnutie ti vyprsalo! Mas este !g%d!y pokusov.", g_pritiahnutia[ id ] );
					} else {
						hook_on( id );
					}
				} else {
					ChatColor( id, "!t[SPIDER ZOMBIE]!y Nemozes uz pritahovat!" );
				}
			}
		}
	}
	
}

public fw_EvEECurWeapon( id ) {
	if( zp_get_user_first_zombie( id ) ) {
		if( zp_get_user_zombie_class( id ) ==  g_zclass_spider ) {
			new g_iPrevCurWeapon[ 33 ];
			new iCurWeapon = read_data( 3 )
			if( iCurWeapon != g_iPrevCurWeapon[ id ] ) {
				set_user_maxspeed( id , 300.0 );
				g_iPrevCurWeapon[ id ] = iCurWeapon;
			}
		}
	}
}

public client_connect( id ) {
	g_hook_speed[ id ] = 320.0;
	g_hook_color[ id ] = 0;
	hashook[ id ] = false;
	hook[ id ] = false;
}

public event_round_start( ) {
	for( new i = 1; i < g_maxplayers; i++ ) {
		hashook[i] = false;
	}
	return PLUGIN_HANDLED;
}

public hook_on( id ) {
	if( !hashook[ id ] || hook[ id ] )
	return PLUGIN_HANDLED;

	emit_sound( id, CHAN_STATIC ,spider_sound, VOL_NORM, ATTN_NORM, 1, PITCH_NORM );
	set_pev( id, pev_gravity, 0.0 );
	set_task( 0.1, "hook_prethink", id + 10000, "", 0, "b" );
	ScreenFade( id, 0.1, 255, 255, 255, 100 );
	client_print( id, print_center, "Pritahujes sa k stene!" );
	hook[ id ] = true;
	hook_to[ id ][ 0 ] = 999999;
	hook_prethink( id + 10000 );
	return PLUGIN_HANDLED;
}

public hook_off( id ) {
	if (zp_get_user_zombie( id ) ) {
		set_pev( id, pev_gravity, gravity );
	} else {
		set_pev( id, pev_gravity, 1.0 );
	}
	hook[ id ] = false;
	hashook[ id ] = false;
	return PLUGIN_HANDLED;
}

public picovina( id ) {
	if( zp_get_user_zombie( id ) ) {
		if( ( zp_get_user_zombie_class( id ) == g_zclass_spider ) && !zp_get_user_nemesis( id ) ) {
			hook[ id ] = false;
			hashook[ id ] = true;
			g_kontrola[ id ] = false;
			remove_task( id + 10000 );
			remove_task( id );
			g_pritiahnutia[ id ]--;
			ScreenFade( id, 0.1, 255, 25, 25, 100 );
			ChatColor( id, "!t[SPIDER ZOMBIE]!y Pritiahnutie ti vyprsalo! Mas este !g%d!y pokusov.", g_pritiahnutia[ id ] );
		}
	}
}

public zp_user_infected_post( id, infector ) {
	if( zp_get_user_zombie( id ) ) {
		if( ( zp_get_user_zombie_class( id ) == g_zclass_spider ) && !zp_get_user_nemesis( id ) ) {
			ChatColor( id, "!t[SPIDER ZOMBIE]!y Pre pritiahnutie k stene stlac !gE!y ale aj pre zrusenie." );
			g_pritiahnutia[ id ] = 8;
			g_kontrola[ id ] = false;
			hook[ id ] = false;
			hashook[ id ] = true;
			remove_task( id + 10000 );
		}
	}
}

public fw_PlayerKilled( victim, attacker, shouldgib ) {
	if( ( zp_get_user_zombie_class( victim ) == g_zclass_spider ) && !zp_get_user_nemesis( victim ) ) {
		hashook[ victim ] = true;
		hook[ victim ] = false;
		g_kontrola[ victim ] = false;
	}
}

public hook_prethink( id ) {
	id -= 10000;
	if( !is_user_alive( id ) ) {
		hook[ id ] = false;
		remove_task( id + 10000 );
		remove_task( id );
		return PLUGIN_HANDLED;
	}
	
	if( !zp_get_user_zombie( id ) ) {
		hook[ id ] = false;
		remove_task( id + 10000 );
		remove_task( id );
		return PLUGIN_HANDLED;
	}

	if( !hook[ id ] ) {
		remove_task( id + 10000 );
		return PLUGIN_HANDLED;
	}

	static origin1[ 3 ];
	new Float:origin[ 3 ];
	get_user_origin( id,origin1 );
	pev( id, pev_origin, origin );

	if( hook_to[ id ][ 0 ] == 999999 ) {
		static origin2[	3 ];
		get_user_origin( id, origin2, 3 );
		hook_to[ id ][ 0 ] = origin2[ 0 ];
		hook_to[ id ][ 1 ] = origin2[ 1 ];
		hook_to[ id ][ 2 ] = origin2[ 2 ];
	}
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY );
	write_byte( 1 );
	write_short( id );
	write_coord( hook_to[ id ][ 0 ] );
	write_coord( hook_to[ id ][ 1 ] );
	write_coord( hook_to[ id ][ 2 ] );
	write_short( beamsprite );
	write_byte( 1 ); 		// framestart
	write_byte( 5 );		// framerate
	write_byte( 2 );		// life
	write_byte( 18 );		// width
	write_byte( 0 );		// noise
	if( g_hook_color[ id ] == 0 ) {
		write_byte( 93 );
		write_byte( 93 );
		write_byte( 93 );
	} else if( g_hook_color[ id ] == 1 ) {
		write_byte( 93 );
		write_byte( 93 );
		write_byte( 93 );
	}
	write_byte( 250 );
	write_byte( 0 );
	message_end( );

	static Float:velocity[ 3 ];
	velocity[ 0 ] = ( float( hook_to[ id ][ 0 ] ) - float( origin1[ 0 ] ) ) * 3.0;
	velocity[ 1 ] = ( float( hook_to[ id ][ 1 ] ) - float( origin1[ 1 ] ) ) * 3.0;
	velocity[ 2 ] = ( float( hook_to[ id ][ 2 ] ) - float( origin1[ 2 ] ) ) * 3.0;

	static Float:y;
	y = velocity[ 0 ] * velocity[ 0 ] + velocity[ 1 ] * velocity[ 1 ] + velocity[ 2 ] * velocity[ 2 ];

	static Float:x;
	x = ( g_hook_speed[ id ] ) / floatsqroot( y );

	velocity[ 0 ] *= x;
	velocity[ 1 ] *= x;
	velocity[ 2 ] *= x;

	set_velo( id, velocity );
	if( !g_kontrola[ id ] ) {
		g_kontrola[ id ] = true;
		set_task( 6.0, "picovina", id );
	}
	return PLUGIN_CONTINUE;
}

stock ChatColor(const id, const input[], any:...) 
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	
	
	if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
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

public set_velo( id,Float:velocity[ 3 ] )
return set_pev( id, pev_velocity,velocity );
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
