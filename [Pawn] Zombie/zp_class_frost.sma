#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < hamsandwich >
#include < engine >
#include < fun >
#include < fakemeta >
#include < zombieplague >

new const upozornenie[ ][ ] = {
	"Spoluhraca nemozes zmrazit!",				// 0
	"Schopnost aktivujes stlacenim !gE !yna klavesnici!",	// 1
	"Tento hrac uz je zmrazeny!",				// 2	
	"Bol si odmrazeny!",					// 3
	"Posledneho cloveka sa neda zmrazit!",			// 4
	"Zmrazil si !gTerminatora!y!",				// 5	
	"Zmrazil si !gHannibala!y!",				// 6
	"Musis este chvilku pockat!",				// 7
	"Schopnost bola obnovena!",				// 8
	"Nacitanie schopnosti: %d",				// 9
	"Si este zmrazeny na: %d sec"				// 10
}
new const prefix[ ][ ] = 	{ "!t[FROST ZOMBIE]!y" };
new const zclass_name[ ] = 	{ "\d(new)\w Frost Zombie\y" };
new const zclass_info[ ] = 	{ "[schopnost zamrazit]" };
new const zclass_model[ ] = 	{ "profun_frost" };
new const zclass_clawmodel[ ] = 	{ "v_profun_frost.mdl" };
new const zclass_sound[ ] = 	{ "bluezone/zombie/frost.wav" };
new const zclass_glass[ ] =	{ "models/glassgibs.mdl" };
//new const zclass_explo[ ] =	{ "models/glassbroken.mdl" };
new const zclass_break[ ] =	{ "bluezone/zombie/unfreezed.wav" };
const zclass_health =		1650;
const zclass_speed =		240;
const Float:zclass_gravity = 	0.9;
const Float:zclass_knockback =	0.8;
const BREAK_GLASS = 		0x01;
new Float:g_freeze_cooldown_standart = 15.0;
new Float:g_freeze_player_cooldown = 7.0;

new g_have_freeze[ 33 ], g_cooldown_time[ 33 ], g_zclass_frost, frostsprite,
pcvar_distance, pcvar_cooldown, pcvar_freeze, g_last_use[ 33 ], g_glassSpr, Float:g_frozen_gravity[ 33 ],
Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame, Float:gLastUseCmd[ 33 ], pcvar_human_speed, g_used_freeze[ 33 ],
g_player_cooldown[ 33 ];
/*new g_exploSpr;*/

public plugin_init( ) {
	register_plugin( "[ZP-Class] Frost Zombie", "1.6", "adamCSzombie" ); 
	
	pcvar_distance = 	register_cvar( "zp_frost_distance_new", "700" );
	pcvar_cooldown = 	register_cvar( "zp_frost_cooldown_new", "15.0" );
	pcvar_freeze = 		register_cvar( "zp_frost_freeze_time_newx", "6.9" );
	pcvar_human_speed = 	register_cvar( "zp_frost_set_human_speed", "240" );
	
	register_forward( FM_CmdStart, "fw_Start" );
	register_event( "CurWeapon" , "fw_EvCurWeapon" , "be" , "1=1" );
	RegisterHam( Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1 );
}

public plugin_precache( ) {
	g_zclass_frost = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback )
	frostsprite = precache_model( "sprites/nhth1.spr" );
	precache_sound( zclass_sound );
	precache_sound( zclass_break );
	g_glassSpr = engfunc( EngFunc_PrecacheModel, zclass_glass );
	//g_exploSpr = engfunc( EngFunc_PrecacheModel, zclass_explo );
}

public zp_user_infected_post( id, infector ) {
	if( is_user_alive( id ) ) {
		if( zp_has_round_started( ) ) {
			if( zp_get_user_zombie_class( id ) == g_zclass_frost ) {
				g_used_freeze[ id ] = false;
				ChatColor( id, "%s %s", prefix, upozornenie[ 1 ] );
			}
		}
	}
}
/*
create_blast( const Float:originF[ 3 ] ) {
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0 );
	write_byte( TE_BEAMCYLINDER ); 
	engfunc( EngFunc_WriteCoord, originF[ 0 ] );
	engfunc( EngFunc_WriteCoord, originF[ 1 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 2 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 0 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 1 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 2 ] + 385.0 ); 
	write_short( g_exploSpr ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 ); 
	write_byte( 60 );
	write_byte( 0 ); 
	write_byte( 0 );
	write_byte( 100 ); 
	write_byte( 200 ); 
	write_byte( 200 ); 
	write_byte( 0 ); 
	message_end( );
	
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0 );
	write_byte( TE_BEAMCYLINDER ); 
	engfunc( EngFunc_WriteCoord, originF[ 0 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 1 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 2 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 0 ] ); 
	engfunc( EngFunc_WriteCoord, originF[ 1 ] );
	engfunc( EngFunc_WriteCoord, originF[ 2 ] + 470.0 ); 
	write_short( g_exploSpr ); 
	write_byte( 0 ); 
	write_byte( 0 );
	write_byte( 4 ); 
	write_byte( 60 ); 
	write_byte( 0 );
	write_byte( 0 ); 
	write_byte( 100 ); 
	write_byte( 200 ); 
	write_byte( 200 ); 
	write_byte( 0 ); 
	message_end( );
	
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0 );
	write_byte( TE_BEAMCYLINDER );
	engfunc( EngFunc_WriteCoord, originF[ 0 ] );
	engfunc( EngFunc_WriteCoord, originF[ 1 ] );
	engfunc( EngFunc_WriteCoord, originF[ 2 ] );
	engfunc( EngFunc_WriteCoord, originF[ 0 ] );
	engfunc( EngFunc_WriteCoord, originF[ 1 ] );
	engfunc( EngFunc_WriteCoord, originF[ 2 ] + 555.0 );
	write_short( g_exploSpr );
	write_byte( 0 );
	write_byte(0 );
	write_byte( 4 );
	write_byte( 60 );
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 100 );
	write_byte( 200 );
	write_byte( 200 );
	write_byte( 0 );
	message_end( );
}*/

public freeze_target( id ) {
	if( !is_user_terminator( id ) && !is_user_hannibal( id ) ) {
		fm_set_rendering( id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
	}
	static Float:originF[ 3 ];
	pev( id, pev_origin, originF );
	//create_blast( originF );
	static origin2[ 3 ];
	get_user_origin( id, origin2 );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, origin2 );
	write_byte( TE_BREAKMODEL );
	write_coord( origin2[ 0 ] );
	write_coord( origin2[ 1 ] );
	write_coord( origin2[ 2 ] + 24 );
	write_coord( 16 );
	write_coord( 16 ); 
	write_coord( 16 ); 
	write_coord( random_num( -50, 50 ) ); 
	write_coord( random_num( -50, 50 ) );
	write_coord( 25 );
	write_byte( 10 );
	write_short( g_glassSpr ); 
	write_byte( 10 ); 
	write_byte( 25 );
	write_byte( BREAK_GLASS ); 
	message_end( ); 
	
	pev( id, pev_gravity, g_frozen_gravity[ id ] );
	
	if( pev( id, pev_flags ) & FL_ONGROUND ) {
		set_pev( id, pev_gravity, 999999.9 );
	} else {
		set_pev( id, pev_gravity, 0.000001 );
	}
	ExecuteHamB( Ham_Player_ResetMaxSpeed, id );
	ScreenFade( id, 6.9, 0, 100, 200, 100 );
	set_task( get_pcvar_float( pcvar_freeze ), "unfreeze_target", id );
}

public unfreeze_target( id ) {
	if( g_have_freeze[ id ] ) {
		g_have_freeze[ id ] = false;
		set_pev( id, pev_gravity, g_frozen_gravity[ id ] );
		ExecuteHamB( Ham_Player_ResetMaxSpeed, id );
		
		if( !is_user_terminator( id ) && !is_user_hannibal( id ) ) {
			fm_set_rendering( id );
		}
		ChatColor( id, "!g[ZP]!y Bol si odmrazeny!" );
		ScreenFade( id, 0.2, 255, 50, 50, 100 );
		
		static origin2[ 3 ];
		get_user_origin( id, origin2 );
		message_begin( MSG_PVS, SVC_TEMPENTITY, origin2 );
		write_byte( TE_BREAKMODEL );
		write_coord( origin2[ 0 ] );
		write_coord( origin2[ 1 ] );
		write_coord( origin2[ 2 ] + 24 );
		write_coord( 16 );
		write_coord( 16 );
		write_coord( 16 );
		write_coord( random_num( -50, 50 ) );
		write_coord( random_num( -50, 50 ) );
		write_coord( 25 );
		write_byte( 10 );
		write_short( g_glassSpr );
		write_byte( 10 );
		write_byte( 25 );
		write_byte( BREAK_GLASS );
		message_end( );
		//ExecuteForward( g_fwUserUnFrozen, g_fwDummyResult, id );
	}
}

stock fm_set_rendering( entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16 ) {
	static Float:color[ 3 ];
	color[ 0 ] = float( r );
	color[ 1 ] = float( g );
	color[ 2 ] = float( b );
	
	set_pev( entity, pev_renderfx, fx )
	set_pev( entity, pev_rendercolor, color )
	set_pev( entity, pev_rendermode, render )
	set_pev( entity, pev_renderamt, float( amount ) )
}

public te_spray( args[ ] ) {
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 120 ); 
	write_coord( args[ 0 ] ); 
	write_coord( args[ 1 ] );
	write_coord( args[ 2 ] );
	write_coord( args[ 3 ] ); 
	write_coord( args[ 4 ] );
	write_coord( args[ 5 ] );
	write_short( frostsprite ); 
	write_byte( 8 ); 
	write_byte( 70 ); 
	write_byte( 100 );
	write_byte( 5 );
	message_end( );
}

stock sqrt( num ) {
	new div = num;
	new result = 1;
	while( div > result ) {
		div = ( div + result ) / 2;
		result = num / div;
	}
	return div;
}

public sprite_control( player ) {
	new args[ 8 ], vec[ 3 ], aimvec[ 3 ], velocityvec[ 3 ], length, speed = 10;
	
	get_user_origin( player, vec );
	get_user_origin( player, aimvec, 2 );

	velocityvec[ 0 ] = aimvec[ 0 ] - vec[ 0 ];
	velocityvec[ 1 ] = aimvec[ 1 ] - vec[ 1 ];
	velocityvec[ 2 ] = aimvec[ 2 ] - vec[ 2 ];
	length = sqrt( velocityvec[ 0 ] * velocityvec[ 0 ] + velocityvec[ 1 ] * velocityvec[ 1 ] + velocityvec[ 2 ] * velocityvec[ 2 ] );
	velocityvec[ 0 ] = velocityvec[ 0 ] * speed / length;
	velocityvec[ 1 ] = velocityvec[ 1 ] * speed / length;
	velocityvec[ 2 ] = velocityvec[ 2 ] * speed / length;
	
	args[ 0 ] = vec[ 0 ];
	args[ 1 ] = vec[ 1 ];
	args[ 2 ] = vec[ 2 ];
	args[ 3 ] = velocityvec[ 0 ];
	args[ 4 ] = velocityvec[ 1 ];
	args[ 5 ] = velocityvec[ 2 ];

	set_task( 0.1, "te_spray", 0, args, 8, "a", 2 );
}

public fw_Start( id, uc_handle, seed ) {
	new button = get_uc( uc_handle, UC_Buttons );
	if( zp_get_user_zombie( id ) && ( button & IN_USE ) && zp_get_user_zombie_class( id ) == g_zclass_frost && !zp_get_user_nemesis( id ) ) {
		use_cmd( id );
	}
}

public use_cmd( id ) {
	if( !is_user_alive( id ) || !zp_get_user_zombie( id ) || zp_get_user_zombie_class( id ) != g_zclass_frost || zp_get_user_nemesis( id ) ) {
		return PLUGIN_HANDLED;
	}
	
	if( g_used_freeze[ id ] ) {
		return PLUGIN_HANDLED;
	}
	
	if( !g_last_use[ id ] ) {
		if( get_gametime( ) - gLastUseCmd[ id ] < get_pcvar_float( pcvar_cooldown ) ) {
			ChatColor( id, "%s %s", prefix, upozornenie[ 7 ] );
			g_last_use[ id ] = true;
			return PLUGIN_HANDLED;
		}
	} else g_last_use[ id ] = false;
	
	g_used_freeze[ id ] = true;
	gLastUseCmd[ id ] = get_gametime( );
	new target, body;
	emit_sound( id, CHAN_WEAPON, zclass_sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
	get_user_aiming( id, target, body, get_pcvar_num( pcvar_distance ) );
	g_cooldown_time[ id ] = floatround( g_freeze_cooldown_standart );
	g_player_cooldown[ target ] = floatround( g_freeze_player_cooldown );
	set_task( 1.0, "FreezeHUD", target, _, _, "a", g_player_cooldown[ target ] );
	set_task( 1.0, "ShowHUD", id, _, _, "a", g_cooldown_time[ id ] );
	sprite_control( id );
	
	if( !zp_get_user_last_human( target ) ) {
		if( !zp_get_user_zombie( target ) ) {
			if( !g_have_freeze[ target ] ) {
				g_have_freeze[ target ] = true;
				set_task( 0.1, "freeze_target", target );
				if( is_user_terminator( target ) ) {
					ChatColor( id, "%s %s", prefix, upozornenie[ 5 ] );
				}
				
				if( is_user_hannibal( target ) ) {
					ChatColor( id, "%s %s", prefix, upozornenie[ 6 ] );
				}
			} else {
				ChatColor( id, "%s %s", prefix, upozornenie[ 2 ] );
			}
		} else {
			ChatColor( id, "%s %s", prefix, upozornenie[ 0 ] );
		}
	} else {
		ChatColor( id, "%s %s", prefix, upozornenie[ 4 ] );
	}
	return PLUGIN_HANDLED;
}

public fw_ResetMaxSpeed_Post( id ) {
	if ( !g_have_freeze[ id ] || !is_user_alive( id ) )
		return;
	set_player_maxspeed( id );
}

set_player_maxspeed( id ) {
	if( g_have_freeze[ id ] ) {
		set_pev( id, pev_maxspeed, 1.0 );
	} else {
		set_pev( id, pev_maxspeed, get_pcvar_float( pcvar_human_speed ) );
	}
}

stock ChatColor(const id, const input[], any:...) {
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
   
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );

   
	if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
	{
		for( new i = 0; i < count; i++ )
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _, players[ i ] );
				write_byte( players[ i ] );
				write_string( msg );
				message_end( );
			}
		}
	}
}

stock ScreenFade(plr, Float:fDuration, red, green, blue, alpha) {
	    new i = plr ? plr : get_maxplayers( );
	    if( !i ) {
		return 0;
	    }
	    
	    message_begin( plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade" ), { 0, 0, 0 }, plr );
	    write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	    write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	    write_short( 4096 );
	    write_byte( red );
	    write_byte( green );
	    write_byte( blue );
	    write_byte( alpha );
	    message_end( );
	    return 1;
}

public fw_EvCurWeapon( id ) {
	if( zp_get_user_first_zombie( id ) ) {
		if( zp_get_user_zombie_class( id ) ==  g_zclass_frost ) {
			new g_iPrevCurWeapon[ 33 ];
			new iCurWeapon = read_data( 3 )
			if( iCurWeapon != g_iPrevCurWeapon[ id ] ) {
				set_user_maxspeed( id , 300.0 );
				g_iPrevCurWeapon[ id ] = iCurWeapon;
			}
		}
	}
}

public FreezeHUD( id ) {
	if( g_have_freeze[ id ] ) {
		if( g_player_cooldown[ id ] == 1 ) {
			client_print( id, print_center, "Uz niesi Freeznuty!" );
		}
		g_player_cooldown[ id ] = g_player_cooldown[ id ] - 1;
		set_hudmessage( 0, 100, 200, -1.0, 0.5, 0, 1.0, 1.1, 0.0, 0.0, -1 );
		show_hudmessage( id, upozornenie[ 10 ], g_player_cooldown[ id ] );
	}
}

public ShowHUD( id ) {
	if( is_valid_ent( id ) && is_user_alive( id ) && get_user_team( id ) == 1 && zp_get_user_zombie( id ) ) {
		if( g_cooldown_time[ id ] == 1 ) {
			g_used_freeze[ id ] = false; client_print( id, print_center, upozornenie[ 8 ] );
		}
		g_cooldown_time[ id ] = g_cooldown_time[ id ] - 1;
		set_hudmessage( 255, 127, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1 );
		show_hudmessage( id, upozornenie[ 9 ], g_cooldown_time[ id ] );	
	} else {
		remove_task( id );
	}
}

public Spawn( id ) {
	if( g_have_freeze[ id ] ) {
		unfreeze_target( id );
	}
	remove_task( id );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
