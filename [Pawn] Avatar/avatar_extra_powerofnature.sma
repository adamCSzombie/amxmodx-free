#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >
#include < fakemeta >
#include < hamsandwich >
#include < xs >
#include < zombieplague >
#include < cstrike >

#define EXTRA_ITEM		"\y(Premium)\w Power of Nature"
#define ITEM_COST		200
#define PLUGIN 			"[Avatar] Power Of Nature"
#define VERSION 		"0.3"
#define AUTHOR 			"adamCSzombie"

new bool:g_nemesis[ 33 ] ;
new item, count, g_msgSync;
new bool:glow[ 33 ];

new const actived_nemesis[ ] = 		"gamesites/avatar/starter.wav";

public plugin_init()
{
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	item = zp_register_extra_item( EXTRA_ITEM, ITEM_COST, ZP_TEAM_ZOMBIE );
	
	register_forward( FM_PlayerPreThink, "fm_PlayerPreThink" );
	RegisterHam( Ham_Spawn, "player", "spawn_n", 1 ); 
	
	g_msgSync = CreateHudSyncObj( );
}

public zp_extra_item_selected( id, itemid )
{
	if( itemid == item )
	{
		if( zp_has_round_started( ) )
		{
			if( get_user_flags( id ) & ADMIN_LEVEL_F )
			{
				
				ChatColor( id, "%L", LANG_PLAYER, "POWER_BUY" );
				g_nemesis[ id ] = true
				
				make_nemesis( id );
				
				ScreenFade( id, 1.5, 255, 0, 127, 100 );
				
				glow[ id ] = true;
				
				emit_sound( id, CHAN_WEAPON, actived_nemesis, 1.0, ATTN_NORM, 0, PITCH_NORM );
				
				new name[ 32 ];
				get_user_name( id, name, 31 );
				set_hudmessage( 255, 0, 127, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1 );
				ShowSyncHudMsg( 0, g_msgSync,"%L", LANG_PLAYER, "POWER_IS", name );
			}
			else
			{
			
				client_cmd( id, "spk valve/sound/buttons/button11" );
				client_print( id, print_chat, "%L", LANG_PLAYER, "ITEM_FOR_PREMIUM" );
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + ITEM_COST );
				return;
			}
		}
		else
		{
			client_cmd( id, "spk valve/sound/buttons/button11" );
			client_print( id, print_chat, "%L", LANG_PLAYER, "WAIT_NEW_ROUND" );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + ITEM_COST );
			return;
		}
	}
}

public spawn_n( id )
{
	if( glow[ id ] )
	{
		glow[ id ] = false;
	}
}
public client_disconnect( id )
{
	if( glow[ id ] )
	{
		glow[ id ] = false;
	}
}

public client_connect( id )
{
	if( glow[ id ] )
	{
		glow[ id ] = false;
	}
}
public zp_user_humanized_post( id, survivor )
{
	if( glow[ id ] )
	{
		glow[ id ] = false;
	}
}

public fm_PlayerPreThink( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	if( glow[ id ] )
	{	
		set_user_rendering( id, kRenderFxGlowShell, 125, 31, 122, kRenderNormal, 40 );
	}
	return PLUGIN_CONTINUE;
}

public make_nemesis( id )
{
	zp_make_user_nemesis( id );
	
	g_nemesis[ id ] = false;
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
		for( new i = 0; i < count; i++ )
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), { 0, 0,0 }, players[ i ] );
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

