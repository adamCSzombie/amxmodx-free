#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < zombieplague >

#define IsUserValidConnected(%1)	(FIRST_PLAYER <= %1 <= maxplayers && g_bIsConnected[%1])

#define PLUGIN 		"[Avatar] Armor Gun"
#define VERSION		"0.3"
#define AUTHOR		"adamCSzombie"

#define NAME		"[\yExtraVIP\w] Armor Gun"

new armor_gun, armor_spr, armor_weapon[ 33 ];
new bool:armor_gun_new[ 33 ];
new g_iMaxPlayers;

new const model_armor[ ] = { "models/usp_avatar/v_elect.mdl" };

public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" ); 
	
	register_forward( FM_PlayerPreThink, "fw_PlayerPreThink" );
	
	RegisterHam( Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post",0 );
	RegisterHam( Ham_TakeDamage, "player", "fw_TakeDamage" );
	
	armor_gun = 		zp_register_extra_item( NAME, 200, ZP_TEAM_HUMAN );
	g_iMaxPlayers = 	get_maxplayers( );
}

public plugin_precache( ) 
{
	precache_model( model_armor ); 
	precache_sound( "zombie_plague/spark6.wav" );
	
	armor_spr = precache_model( "sprites/spark1.spr" );
}

public zp_extra_item_selected( player, itemid )
{
	if( itemid == armor_gun ) 
	{
		if( armor_gun_new[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "Uz mas kupenu Armor Gun!" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 200 );
			return;
		}
		
		ChatColor( player, "!g[Avatar]!y Mas !t1!y / !t10!y sancu ze za hit dostanes +2 AP!" );
		client_print( player, print_chat, "Kupil si si Armor Gun!" ); 
			
		armor_gun_new[ player ] = true
			
		strip_user_weapons( player );
			
		give_item( player, "weapon_m4a1" );
		give_item( player, "weapon_knife" );
			
		cs_set_user_bpammo( player, CSW_M4A1, 120 );  
	}		
}

public zp_user_infected_post( infected, infector )
{
	if( armor_gun_new[ infected ] )
	{
		armor_gun_new[ infected ] = false;
	}
}

public fw_TakeDamage( victim, inflictor, attacker, Float:damage, damage_type )
{
	if( !is_user_connected( attacker ) || !is_user_connected( victim ) || zp_get_user_nemesis( victim ) || attacker == victim || !attacker )
		return HAM_IGNORED;
	
	static Float:originF[ 3 ];
	pev( victim, pev_origin, originF );
	
	static originF2[ 3 ] 
	get_user_origin( victim, originF2 );
	
	if(armor_gun_new[ attacker ] && get_user_weapon( attacker ) == CSW_M4A1 )
	{	
		ElectroRing( originF );
		
		ElectroSound( originF2 );  
	}
	
	if( zp_get_user_nemesis( victim ) )
	{	
		return HAM_IGNORED;
	}
	return PLUGIN_HANDLED;
}

public event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	armor_weapon[ id ] = read_data( 2 )
	
	if( zp_get_user_zombie( id ) || zp_get_user_survivor( id ) )
		return PLUGIN_CONTINUE;
	
	if( !armor_gun_new[ id ] || armor_weapon[ id ] != CSW_M4A1 ) 
		return PLUGIN_CONTINUE;
	
	entity_set_string( id, EV_SZ_viewmodel, model_armor ); 
	
	return PLUGIN_CONTINUE;
}

public fw_PlayerPreThink( id )
{
	if( !is_user_alive( id ) )
		return;
} 

public ElectroSound( iOrigin[ 3 ] )
{
	new Entity = create_entity( "info_target" );
	
	new Float:flOrigin[ 3 ];
	IVecFVec( iOrigin, flOrigin );
	
	entity_set_origin( Entity, flOrigin );
	
	emit_sound( Entity, CHAN_WEAPON, "zombie_plague/spark6.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	
	remove_entity( Entity );
	}
		ElectroRing( const Float:originF3[ 3 ] )
	{
			
	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF3, 0 );
	write_byte( TE_BEAMCYLINDER ) ;
	engfunc( EngFunc_WriteCoord, originF3[ 0 ] ); 
	engfunc( EngFunc_WriteCoord, originF3[ 1 ] ); 
	engfunc( EngFunc_WriteCoord, originF3[ 2 ] ); 
	engfunc( EngFunc_WriteCoord, originF3[ 0 ] );
	engfunc( EngFunc_WriteCoord, originF3[ 1 ] );
	engfunc( EngFunc_WriteCoord, originF3[ 2 ] + 100.0 ); 
	write_short( armor_spr ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 ); 
	write_byte( 60 );
	write_byte( 0 ); 
	write_byte( 41 ); 
	write_byte( 125 ); 
	write_byte( 31 ); 
	write_byte( 122 );
	write_byte( 0 ); 
	message_end( );
}

public client_putinserver( id )
{
	armor_gun_new[ id ] = false;
}

public client_disconnect( id )
{
	armor_gun_new[ id ] = false;
}

stock ChatColor( const id, const input[], any:... )
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
	message_end( );
	
	return 1;
	
}

public case_open( id )
{
	switch( random( 1,10 ) )
	{
		case 1: set_ap( id );
	}
	return PLUGIN_HANDLED;
}

public set_ap( id )
{
	set_hudmessage( 125, 31, 122, -1.0, -1.0, 0, 6.0, 5.0 );
	show_hudmessage( id, "+2 AP" );
	set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 2, 999 ) ) );
	ScreenFade( id, 1.5, 125, 31, 122, 100 );
}
