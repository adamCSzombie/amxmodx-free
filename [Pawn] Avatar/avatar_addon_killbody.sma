#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >
#include < fakemeta >
#include < hamsandwich >
#include < xs >
#include < zombieplague >
#include < cstrike >
#include < dhudmessage >
#include < weapons >

/* Maximum bodov */

#define MAX_AP_EVIP	200
#define MAX_AP_VIP	160
#define MAX_AP_USER	50

/* Body za kill */

#define KILL_EVIP	50
#define KILL_VIP	40
#define KILL_USER	2

#define IsUserValidConnected(%1)	(FIRST_PLAYER <= %1 <= maxplayers && g_bIsConnected[%1])

#define MAX_PLAYERS    		32 
#define USE_STOPPED		0
#define FIRST_PLAYER		1
#define PDATA_SAFE		2
#define USE_TOGGLE 		3 
#define OFFSET_LINUX_WEAPONS	4
#define XTRA_OFS_PLAYER		5
#define XO_PLAYER		5
#define PLAYER_JUMP		6
#define ACT_HOP 		7
#define m_pPlayer 		41
#define OFFSET_CLIPAMMO		51
#define m_Activity 		73
#define m_IdealActivity		74
#define m_flNextAttack		83
#define m_afButtonPressed	246
#define m_flFallVelocity	251
#define m_pActiveItem		373
#define IsPlayer(%0) (1 <= %0 <= 32)

new bool:g_bIsConnected[ 33 ];
new g_300bodov[ 33 ], max_body[ 33 ], maxplayers, g_hudmsg1;

public plugin_init( )
{
	register_plugin( "1.0", "[Avatar] Kill Ammo Packs", "adamCSzombie" );
	
	RegisterHam( Ham_Killed, "player", "ham_killed", 1 );
	RegisterHam( Ham_Spawn, "player", "Fwd_PlayerSpawn_Post",1 );
	
	maxplayers = get_maxplayers( );
	g_hudmsg1 = CreateHudSyncObj( );
}

public Fwd_PlayerSpawn_Post( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	max_body[ id ] = 0;
	return PLUGIN_CONTINUE;
}

public client_putinserver( id )
{
	g_bIsConnected[ id ] = true;
	
	max_body[ id ] = 0;
	g_300bodov[ id ] = false;
}

public client_disconnect( id )
{
	g_bIsConnected[ id ] = false;
	
	max_body[ id ] = 0;
	g_300bodov[ id ] = false;
}

public native_give_300( id )
{
	get_300xd( id );
}

public plugin_natives()
{
	register_native( "get_300", "native_give_300", 1 );
}

public get_300xd( id )
{
	g_300bodov[ id ] = true;
	ChatColor( id, "!g[300x Bodov]!y Maximalny limit bodov bol zvyseny z !t200!y > !t300!y." );
}

stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[ 32 ];
	static msg[ 191 ]
	vformat( msg, 190, input, 3 )
	
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	
	if( id ) players[ 0 ] = id; else get_players( players, count, "ch" );
	{
		for(new i = 0; i < count; i++)
		{
			if(is_user_connected( players[i]))
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])  
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
}

public ham_killed( victim, attacker, shouldgib )
{
	new ammopacks = zp_get_user_ammo_packs( attacker );
	
	if ( attacker == victim )
		return;
	if ( zp_get_user_nemesis( attacker ) )
	{
		if( max_body[ attacker ] != 25 )
		{
			if( ammopacks + 2 > zp_get_user_limit_ammo_packs( attacker ) )
			{
				ammopacks = zp_get_user_limit_ammo_packs( attacker );
			} else {
				max_body[ attacker ] += 1;
				ammopacks += 2;
			}
		}
		ScreenFade( attacker, 0.5, 65, 165, 65, 100 );
		zp_set_user_ammo_packs( attacker, ammopacks ); 
	}
	if ( !zp_get_user_zombie( attacker ) ) 
	{
		if ( get_user_flags( attacker ) & ADMIN_LEVEL_F ) 
		{
			if ( ammopacks + 50 > zp_get_user_limit_ammo_packs( attacker ) )
			{
				ammopacks = zp_get_user_limit_ammo_packs( attacker );
			}
			else
			{
				ammopacks += 50;
			}
		} else {
			if ( ammopacks + 40 > zp_get_user_limit_ammo_packs( attacker ) )
			{
				ammopacks = zp_get_user_limit_ammo_packs( attacker );
			}
			else
			{
				ammopacks += 40;
			}
		}
		ScreenFade( attacker, 0.5, 65, 165, 65, 100 );
		zp_set_user_ammo_packs( attacker, ammopacks ); 
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
