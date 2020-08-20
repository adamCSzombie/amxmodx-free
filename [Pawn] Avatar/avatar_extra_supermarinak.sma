#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >
#include < fakemeta >
#include < hamsandwich >
#include < xs >
#include < zombieplague >
#include < cstrike >
#include < weapons >

#define ITEM_NAME 	"[\yExtraVIP\w] Super vojak"
#define ITEM_COST 	160

#define PLUGIN 		"[Avatar] Super Vojak"
#define VERSION 	"0.3"
#define AUTHOR 		"adamCSzombie"

#define CVAR_JUMPS	"av_supervojak_skokydadaad"
#define MAX_JUMPS	"1"

#define IsUserValidConnected(%1)	(FIRST_PLAYER <= %1 <= maxplayers && g_bIsConnected[%1])

#define EVIP 		ADMIN_LEVEL_F
#define FIRST_PLAYER		1

#define fm_cs_set_weapon_ammo(%1,%2)	set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)
#define OFFSET_CLIPAMMO		51
#define OFFSET_LINUX_WEAPONS 	4
#define g_uqz_weapon 		373

#define is_user_valid(%1) (1 <= %1 <= maxplayers)

new g_iCurrentWeapon[ 33 ];

new g_msgSync, limit_term, maxplayers, g_hudmsg1, g_limit_super[ 33 ];

new const actived_soilder[ ] = 		"gamesites/avatar/starter.wav";
new const deactivated_soilder[ ] = 	"gamesites/avatar/ender.wav";

new Jumpnum[ 33 ] = false;
new bool:canJump[ 33 ] = false, g_super_jumper_maxjumps, bool:g_norecoil[ 33 ], g_uqz, spustac[ 33 ], g_iMaxPlayers;	

const WPN_BS = ( (1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4) )
new const g_MaxClips[] = { 0, 13, 0, 10, 0, 7, 0, 30, 30, 0, 15, 20, 25, 30, 35,
25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 0, 7, 30, 30, 0, 50 };

public plugin_natives( )
{
	register_native( "is_user_supermarinak","native_is_user_supermarinak",1 )
}

public plugin_init( )
{
	new text[ 555 char ];
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_dictionary( "zombie_plague.txt" );
	g_super_jumper_maxjumps = 	register_cvar( CVAR_JUMPS, MAX_JUMPS );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "SUPER_MARINAK" );
	g_uqz = 			zp_register_extra_item( text, ITEM_COST, ZP_TEAM_HUMAN );
	g_iMaxPlayers = 		get_maxplayers( );
	g_msgSync = 			CreateHudSyncObj( );

	register_forward( FM_PlayerPreThink, "fm_PlayerPreThink" );
	register_forward( FM_PlayerPostThink, "fm_PlayerPostThink" );
	
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" );
	register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
	
	RegisterHam( Ham_Spawn, "player", "Fwd_PlayerSpawn_Post",1 );
	RegisterHam( Ham_TraceAttack, "player", "player_attack" );
	
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	
	maxplayers = get_maxplayers( );
	g_hudmsg1 = CreateHudSyncObj( );
	
}  

public event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	g_iCurrentWeapon[ id ] = read_data( 2 );
	
	return PLUGIN_CONTINUE;
}

public native_is_user_supermarinak( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id );
		return -1;
	}
	
	return spustac[ id ];
} 
 
 public plugin_precache( )
{	
	precache_sound( actived_soilder );
	precache_sound( deactivated_soilder );
}

public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_uqz )
	{
		if( limit_term != 50 )
		{	
			if( !zp_has_round_started( ) )
			{
				client_cmd( player, "spk valve/sound/buttons/button11" );
				client_print( player, print_chat, "%L", LANG_PLAYER, "WAIT_NEW_ROUND" );
				zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
				return;
			}
				
			if( is_user_supervojak( player ) )
			{
				client_cmd( player, "spk valve/sound/buttons/button11" );
				client_print( player, print_chat, "%L", LANG_PLAYER, "SUPER_MARINE_HAVE" );
				zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
				return;
			}
				
			if( spustac[ player ] == 1 )
			{
				if( g_limit_super[ player ] == 2 )
				{	
					g_limit_super[ player ] = 2;
					ChatColor( player, "%L", LANG_PLAYER, "SUPER_MARINE_BUY" );
					set_user_health( player, get_user_health( player ) + 100 ); 
					set_user_armor( player, get_user_armor( player ) + 100 ); 
					return;
				}
				else
				{
					client_cmd( player, "spk valve/sound/buttons/button11" );
					client_print( player, print_chat, "%L", LANG_PLAYER, "SUPER_MARINE_LIMIT" ); 
					zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
					return;
				}
			}
				
			g_limit_super[ player ] = 1;
			limit_term += 1;
										
			set_user_health( player, get_user_health( player ) + 100 );
			set_user_armor( player, get_user_armor( player ) + 100 ); 
					
			spustac[ player ] = 1;
			g_norecoil[ player ] = true;
						
			ChatColor( player, "%L", LANG_PLAYER, "SUPER_MARINE_BUY" );
				
			client_cmd( player, "spk valve/sound/fvox/communications_on" );
					
			ScreenFade( player, 1.5, 8, 89, 5, 100 );
					
			set_user_rendering( player, kRenderFxGlowShell, 8, 89, 5, kRenderNormal, 10 );					
						
			emit_sound( player, CHAN_WEAPON, actived_soilder, 1.0, ATTN_NORM, 0, PITCH_NORM );
					
			new name[ 32 ];
			get_user_name( player, name, 31 );
			set_hudmessage( 0, 255, 0, -1.0, 0.13, 1, 0.0, 5.0, 1.0, 1.0, -1 );
			ShowSyncHudMsg( 0, g_msgSync,"%L", LANG_PLAYER, "SUPER_MARINE_IS", name );
		}	
		else
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			ChatColor( player,"!g[Limit]!y Prepac ale na servery mozu byt naraz len 8 super vojakov!" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
		}
	}		
}  

public Event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( g_norecoil[ id ] )
	{
		new uqzWeapon = read_data( 2 );
		
		if( !( WPN_BS & ( 1<<uqzWeapon ) ) )
			fm_cs_set_weapon_ammo( get_pdata_cbase( id, g_uqz_weapon ), g_MaxClips[ uqzWeapon ] );
	}
	return PLUGIN_CONTINUE;
}
public event_round_start( )
{
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
		
		if( spustac[ i ] )
		{
			limit_term -= 1;
			g_limit_super[ i ] = 0;
			emit_sound( i, CHAN_WEAPON, deactivated_soilder, 2.0, ATTN_NORM, 0, PITCH_NORM );
			client_print( i, print_center, "%L", LANG_PLAYER, "SUPER_MARINE_END" );
			spustac[ i ] = 0;
			g_norecoil[ i ] = false;
		}
		
	}
}
public cmd_luk( id )
{
	static menu
	{
		new text[ 555 char ];
		formatex( text, charsmax( text ), "%L", LANG_PLAYER, "SUPER_MARINE_WEAPON" );
		menu = menu_create( text, "menu_luk" );

		
		menu_additem( menu, "M4A1", "1", 0 );
		menu_additem( menu, "AK47", "2", 0 );
		menu_additem( menu, "XM1014", "3", 0 );
		menu_additem( menu, "Famas", "4", 0 );
		menu_additem( menu, "MP5 Navy", "5", 0 );
		
					
		menu_display( id, menu )
	}
	return PLUGIN_HANDLED;
}
public menu_luk( id, menu, item )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( id ) || zp_get_user_zombie( id ) )
		return PLUGIN_CONTINUE;
		
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}

	static dst[ 32 ], data[ 5 ], access, callback;
	
	menu_item_getinfo( menu, item, access, data, charsmax( data ), dst, charsmax( dst ), callback );
	get_user_name( id, dst, charsmax( dst ) );
	menu_destroy( menu );
	
	switch( data[ 0 ] )
	{
		
		case('1'):
		{
			client_cmd( id, "spk valve/sound/buttons/guncock1" );
			give_item( id, "weapon_m4a1" );	
			cs_set_user_bpammo( id, CSW_M4A1, 90 );
		}
		case('2'):
		{
			client_cmd( id, "spk valve/sound/buttons/guncock1" );
			give_item( id, "weapon_ak47" )	
			cs_set_user_bpammo( id, CSW_AK47, 90 ); 
		
		}
		case('3'):
		{
			client_cmd( id, "spk valve/sound/buttons/guncock1" );
			give_item( id, "weapon_xm1014" );	
			cs_set_user_bpammo( id, CSW_XM1014, 32 ); 	
		}
		case('4'):
		{
			client_cmd( id, "spk valve/sound/buttons/guncock1" );
			give_item( id, "weapon_famas" );
			cs_set_user_bpammo( id, CSW_FAMAS, 90 );
		}
		case('5'):
		{
			client_cmd( id, "spk valve/sound/buttons/guncock1" );
			give_item(id, "weapon_mp5navy")
			cs_set_user_bpammo( id, CSW_MP5NAVY, 120 );
		}
		
				
		
	}
	return PLUGIN_HANDLED;
}
public client_putinserver( id )
{
	spustac[ id ] = 0;
	Jumpnum[ id ] = 0;
	canJump[ id ] = false;
	g_limit_super[ id ] = false;
}

public client_disconnect( id )
{
	if( spustac[ id ] == 1 )
	{
		
		spustac[ id ] = 0;
		Jumpnum[ id ] = 0;
		canJump[ id ] = false;
		g_limit_super[ id ] = false;
		limit_term -= 1;
	}
}
public Fwd_PlayerSpawn_Post( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	g_limit_super[ id ] = false;
	spustac[ id ] = 0;
	Jumpnum[ id ] = 0;
	canJump[ id ] = false;
	g_norecoil[ id ] = false;
	set_user_armor( id, 0 );
	return PLUGIN_CONTINUE;
	
}	
public fm_PlayerPreThink( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
			
	new nbut = pev( id, pev_button );
	new obut = pev( id, pev_oldbuttons );
	
	if ( !is_user_alive( id ) || zp_get_user_zombie( id ) )
		return PLUGIN_CONTINUE;
		
	if( spustac[ id ] == 1 )
	{
		if( ( nbut & IN_JUMP ) && !( pev( id, pev_flags ) & FL_ONGROUND ) && !( obut & IN_JUMP ) )
		{
			if( Jumpnum[ id ] < get_pcvar_num( g_super_jumper_maxjumps ) )
			{
				canJump[ id ] = true; 
				Jumpnum[ id ]++;
			}					
		}
			
		else if( ( nbut & IN_JUMP ) && !( pev( id, pev_flags ) & FL_ONGROUND ) && !( obut & IN_JUMP ) )
		{
			if( Jumpnum[ id ] == get_pcvar_num( g_super_jumper_maxjumps ) || ( nbut & IN_JUMP ) )
			{
				canJump[ id ] = false;
				Jumpnum[ id ] = false;
					
			}
		}
	}	
	if( pev( id, pev_flags ) & FL_ONGROUND )
	{
			
		Jumpnum[ id ] = 0;
			
	}
	return FMRES_IGNORED;
}

public fm_PlayerPostThink( id )
{
	if( !is_user_alive( id ) || zp_get_user_zombie( id ) )
			return PLUGIN_CONTINUE;
	if( spustac[ id ] != 1 )
		return PLUGIN_CONTINUE
	
	if( canJump[ id ] == true )
	{
		new Float:velocity[ 3 ];	
		pev( id, pev_velocity, velocity );
		velocity[ 2 ] = random_float( 265.0,285.0 );
		set_pev( id, pev_velocity, velocity );
		
		canJump[ id ] = false;
		
		return FMRES_IGNORED;
	}
	
	return FMRES_IGNORED;
}
public zp_user_infected_post( infected, infector )
{
	if( spustac[ infected ] == 1 )
	{
		spustac[ infected ] = 0;
		g_norecoil[ infected ] = false;
		g_limit_super[ infected ] = false;
		limit_term -= 1;
	}
	
}

public player_attack( victim, attacker, Float:damage, Float:direction[3], tracehandle, damagebits )
{
	static button;
	button = pev( attacker, pev_button );
	
	if( spustac[ victim ] == 1 )
	{
		if( zp_get_user_nemesis( attacker ) )
		{
			if( g_iCurrentWeapon[ attacker ] == CSW_KNIFE && button & IN_ATTACK  )
			{
				a_lot_of_blood( victim );
				set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
				ShowSyncHudMsg( attacker, g_hudmsg1, "^n-3 AP^n" );  
				set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
				ShowSyncHudMsg( victim, g_hudmsg1, "^n-3 AP^n" );  
				set_pev( victim, pev_armorvalue, float( min( pev( victim, pev_armorvalue ) - 3, 999 ) ) );
			}
			else
			{
				a_lot_of_blood( victim );
				set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
				ShowSyncHudMsg( attacker, g_hudmsg1, "^n-6 AP^n" );  
				set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
				ShowSyncHudMsg( victim, g_hudmsg1, "^n-6 AP^n" );  
				set_pev( victim, pev_armorvalue, float( min( pev( victim, pev_armorvalue ) - 6, 999 ) ) );
			}
			return HAM_SUPERCEDE;
		}
		
	}	
	return HAM_IGNORED;
		
}

a_lot_of_blood( id )
{
	static iOrigin[ 3 ];
	get_user_origin( id, iOrigin );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ]+10 );
	write_coord( random_num( -360, 360 ) ); 
	write_coord( random_num( -360, 360 ) ); 
	write_coord( -10 ); 
	write_byte( 70 ); 
	write_byte( random_num( 50, 100 ) ); 
	message_end( );
	
	for (new j = 0; j < 4; j++) 
	{
		message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
		write_byte( TE_WORLDDECAL );
		write_coord( iOrigin[ 0 ]+random_num( -100, 100 ) );
		write_coord( iOrigin[ 1 ]+random_num( -100, 100 ) );
		write_coord( iOrigin[ 2 ]-36 );
		write_byte( random_num( 190, 197 ) );
		message_end( );
	}
}

stock ChatColor( const id, const input[], any:... )
{
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
