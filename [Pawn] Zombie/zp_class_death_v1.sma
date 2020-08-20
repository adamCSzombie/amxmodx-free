#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fun >
#include < zombieplague >
#include < hamsandwich >
#include < fakemeta >
#include < engine >
#include < xs >

#define ID_AURA (taskid - TASK_AURA)

#define TASK_GODMODE 25042014

#define PLUGIN "[ZP-Class] Deathless Zombie"
#define VERSION "1.4"
#define AUTHOR "adamCSzombie"

new const zclass_name[ ] = { "Deathless Zombie" };
new const zclass_info[ ] = { "[neposobi nanho adrenalin]" };
new const zclass_model[ ] = { "profun_deathless" };
new const zclass_clawmodel[ ] = { "v_knife_deathless.mdl" };
const zclass_health = 1900; // 1900
const zclass_speed = 250;
const Float:zclass_gravity = 0.8; // 1.0
const Float:zclass_knockback = 1.0;

new g_death;

public plugin_natives()
{
	register_native( "deathlesszombie", "native_deathless", 1 );
}
public native_deathless( id )
{
	if ( !is_user_connected( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id );
		return -1;
	}
	
	return g_death;
}
public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_event("CurWeapon" , "fw_EvFRCurWeapon" , "be" , "1=1")
}
public plugin_precache( )
{
	g_death = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback )
}

public zp_user_infected_post( player, infector )
{
	if( is_user_alive( player ) )
	{
		if( zp_get_user_zombie_class( player ) == g_death )
		{
			ChatColor( player ,"!t[DEATHLESS ZOMBIE]!y Schopnost mas uz automaticky stale!" );
		}
	}
}

public fw_EvFRCurWeapon( id )
{
	if( is_user_alive( id ) )
	{
		if( zp_get_user_first_zombie( id ) )
		{
			if( zp_get_user_zombie_class( id ) ==  g_death )
			{
				new g_iPrevCurWeapon[ 33 ];
				new iCurWeapon = read_data( 3 )
				if( iCurWeapon != g_iPrevCurWeapon[ id ] )
				{
					set_user_maxspeed( id , 380.0 );
					g_iPrevCurWeapon[ id ] = iCurWeapon;
				}
			}
		}
	}
}


stock ChatColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	
	if(id) players[0] = id; else get_players(players, count, "ch")
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
