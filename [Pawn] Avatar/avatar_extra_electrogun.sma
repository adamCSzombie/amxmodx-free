/* Electro Weapon by Zapdos1
*/
#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < zombieplague >

#define PLUGIN 		"[ZP-Extra] Electro Gun"
#define VERSION		"0.4"
#define AUTHOR		"adamCSzombie"

#define NAME		"Electro Gun"

new g_item, ElectroSpr, g_electro[ 33 ], g_Weapon[ 33 ];
new bool:g_electroweapon[ 33 ];
new g_iMaxPlayers;

new const v_model[ ] = 	{ "models/playaspro_avatar/v_elect.mdl" };
new const sound[ ] = 	{ "zombie_plague/spark6.wav" };

public plugin_init( ) 
{
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" ); 
	
	register_forward( FM_PlayerPreThink, "fw_PlayerPreThink" );
	
	RegisterHam( Ham_TakeDamage, "player", "fw_TakeDamage" );
	
	g_item = 		zp_register_extra_item( NAME, 100, ZP_TEAM_HUMAN );
	g_iMaxPlayers = 	get_maxplayers( );
}

public plugin_precache( ) 
{
	precache_model( v_model ); 
	precache_sound( sound );
	
	ElectroSpr = precache_model( "sprites/spark1.spr" );
}

public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_item ) 
	{	
		if( g_electroweapon[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "%L", LANG_PLAYER, "ELECTRO_HAVE" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 100 );
			return;
		}
			
		client_print( player, print_chat, "%L", LANG_PLAYER, "ELECTRO_BUY" );
				
		g_electroweapon[ player ] = true
		client_cmd( player, "spk valve/sound/fvox/get_egon" );
				
		give_item( player, "weapon_mp5navy" );
		give_item( player, "weapon_knife" );
				
		cs_set_user_bpammo( player, CSW_MP5NAVY, 120 );  
	}		
}

public zp_user_infected_post( infected, infector )
{
	if( g_electroweapon[ infected ] )
	{
		g_electroweapon[ infected ] = false;
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
	
	if(g_electroweapon[ attacker ] && get_user_weapon( attacker ) == CSW_MP5NAVY )
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
	
	g_Weapon[ id ] = read_data( 2 )
	
	if( zp_get_user_zombie( id ) || zp_get_user_survivor( id ) )
		return PLUGIN_CONTINUE;
	
	if( !g_electroweapon[ id ] || g_Weapon[ id ] != CSW_MP5NAVY ) 
		return PLUGIN_CONTINUE;
	
	entity_set_string( id, EV_SZ_viewmodel, "models/playaspro_avatar/v_elect.mdl" ); 
	
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
	write_short( ElectroSpr ); 
	write_byte( 0 );
	write_byte( 0 );
	write_byte( 4 ); 
	write_byte( 60 );
	write_byte( 0 ); 
	write_byte( 41 ); 
	write_byte( 138 ); 
	write_byte( 255 ); 
	write_byte( 200 );
	write_byte( 0 ); 
	message_end( );
}

public client_putinserver( id )
{
	g_electroweapon[ id ] = false;
	g_electro[ id ] = false;
}

public client_disconnect( id )
{
	g_electroweapon[ id ] = false;
	g_electro[ id ] = false;
}
