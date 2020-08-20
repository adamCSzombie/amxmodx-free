#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >
#include < fakemeta >
#include < hamsandwich >
#include < xs >
#include < zombieplague >
#include < cstrike >

#define ITEM_NAME 	"[\yExtraVIP\w] Super vojak"
#define ITEM_COST 	200

#define PLUGIN 		"[Avatar] Super Vojak"
#define VERSION 	"0.2"
#define AUTHOR 		"adamCSzombie"

#define EVIP 		ADMIN_LEVEL_G

#define fm_cs_set_weapon_ammo(%1,%2)	set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)
#define OFFSET_CLIPAMMO		51
#define OFFSET_LINUX_WEAPONS 	4
#define g_uqz_weapon 		373

new g_msgSync, limit_term;

new Jumpnum[ 33 ] = false;
new bool:canJump[ 33 ] = false, g_super_jumper_maxjumps, bool:g_norecoil[ 33 ], g_uqz, spustac[ 33 ], g_iMaxPlayers;	

const WPN_BS = ( (1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4) )
new const g_MaxClips[] = { 0, 13, 0, 10, 0, 7, 0, 30, 30, 0, 15, 20, 25, 30, 35,
25, 12, 20, 10, 30, 100, 8, 30, 30, 20, 0, 7, 30, 30, 0, 50 };

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_super_jumper_maxjumps = register_cvar( "zp_super_jumper_zombie_maxjumps", "3" );
	
	g_uqz = zp_register_extra_item( ITEM_NAME, ITEM_COST, ZP_TEAM_HUMAN );

	register_forward( FM_PlayerPreThink, "fm_PlayerPreThink" );
	register_forward( FM_PlayerPostThink, "fm_PlayerPostThink" );
	
	register_event( "CurWeapon", "Event_CurWeapon", "be", "1=1" );
	
	RegisterHam( Ham_Spawn, "player", "Fwd_PlayerSpawn_Post",1 );
	RegisterHam( Ham_TraceAttack, "player", "player_attack" );
	
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	
	g_iMaxPlayers = get_maxplayers( );
	g_msgSync = CreateHudSyncObj( );
	
 }   
public zp_extra_item_selected( player, itemid )
 {
	if( get_user_flags( player ) & EVIP )
	{
		if( !zp_has_round_started( ) )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "Pockaj kym zacne kolo!" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
			return;
		}
		if( spustac[ player ] == 1 )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "Uz mas kupeneho Super Vojaka!" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
			return;
		}
		if( itemid == g_uqz )
		{
			if( limit_term != 8 )
			{
				limit_term += 1;
									
				set_user_health( player, 200 ); 
				set_user_armor( player, 200 ); 
					
				client_cmd( player, "spk valve/sound/buttons/communications_on" );
				
				spustac[ player ] = 1;
				g_norecoil[ player ] = true;
					
				ChatColor( 0, "!g[Avatar]!y Aktualny pocet Super Vojakov !t%d!y/!t8", limit_term );
					
				set_user_rendering( player, kRenderFxGlowShell, 50, 150, 250, kRenderNormal, 40 );		
				cmd_luk( player );			
					
				new name[ 32 ];
				get_user_name( player, name, 31 );
				set_hudmessage( 50, 150, 250, -1.0, 0.15, 1, 0.0, 5.0, 1.0, 1.0, -1 );
				ShowSyncHudMsg( 0, g_msgSync,"%s je Super Vojak!",name );
			}	
			else
			{
				ChatColor( player,"!g[Limit]!y Prepac ale na servery mozu byt naraz len 8 super vojakov!" );
				zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
			}
		}
	}
	else
	{
		client_print( player, print_chat, "Tento Item je len pre ExtraVIP hracov", player );
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
			
			client_print( i, print_center, "Super Vojak ti vyprsal na nove kolo!!" );
			spustac[ i ] = 0;
			g_norecoil[ i ] = false;
		}
		
	}
}
public cmd_luk( id )
{
	static menu
	{
		menu = menu_create( "Vyber si zbran za Super Vojaka:", "menu_luk" );

		
		menu_additem( menu, "M4A1 + 5 Armoru", "1", 0 );
		menu_additem( menu, "AK47 + 5 Armoru", "2", 0 );
		menu_additem( menu, "Brokovnica + 10 Armoru", "3", 0 );
		menu_additem( menu, "Famas + 10 Armoru", "4", 0 );
		menu_additem( menu, "MP5navy + 30 Armoru", "5", 0 );
		
					
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
			give_item( id, "weapon_m4a1" );	
			cs_set_user_bpammo( id, CSW_M4A1, 500 );
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 5, 999 ) ) );
		}
		case('2'):
		{
			give_item( id, "weapon_ak47" )	
			cs_set_user_bpammo( id, CSW_AK47, 500 ); 
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 5, 999 ) ) );
		
		}
		case('3'):
		{
			give_item( id, "weapon_xm1014" );	
			cs_set_user_bpammo( id, CSW_XM1014, 500 ); 	
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 10, 999 ) ) );
		}
		case('4'):
		{
			give_item( id, "weapon_famas" );
			cs_set_user_bpammo( id, CSW_FAMAS, 500 );
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 10, 999 ) ) );
		}
		case('5'):
		{
			give_item(id, "weapon_mp5navy")
			cs_set_user_bpammo( id, CSW_MP5NAVY, 500 );
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 30, 999 ) ) );
		}
		
				
		
	}
	return PLUGIN_HANDLED;
}
public client_putinserver( id )
{
	spustac[ id ] = 0;
	Jumpnum[ id ] = 0;
	canJump[ id ] = false;
}

public client_disconnect( id )
{
	if( spustac[ id ] == 1 )
	{
		
		spustac[ id ] = 0;
		Jumpnum[ id ] = 0;
		canJump[ id ] = false;
		ChatColor( 0, "!g[Avatar]!y Aktualny pocet Super Vojakov !t%d!y/!t6", limit_term );
		limit_term -= 1;
	}
}
public Fwd_PlayerSpawn_Post( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
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
	if( !is_user_alive(id) || zp_get_user_zombie( id ) )
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
		limit_term -= 1;
		ChatColor( 0, "!g[Avatar]!y Aktualny pocet Super Vojakov !t%d!y/!t6", limit_term );
	}
	
}

public player_attack( victim, attacker, Float:damage, Float:direction[3], tracehandle, damagebits )
{
	if( spustac[ victim ] == 1 )
	{
		if( zp_get_user_nemesis( attacker ) )
		return HAM_SUPERCEDE;
		
	}	
	return HAM_IGNORED;
		
}	

stock ChatColor( const id, const input[], any:... )
{
	new count = 1, players[ 32 ]
	static msg[ 191 ]
	vformat( msg, 190, input, 3 )
	
	replace_all( msg, 190, "!g", "^4" )
	replace_all( msg, 190, "!y", "^1" )
	replace_all( msg, 190, "!t", "^3" )
	
	
	if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
	{
		for(new i = 0; i < count; i++)
		{
			if( is_user_connected( players[ i ] ) )
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[ i ] )  
				write_byte( players[ i ] )
				write_string( msg )
				message_end( )
			}
		}
	}
}
