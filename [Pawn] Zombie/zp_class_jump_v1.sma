/* Zombie Plague 7.1 Jump Zombie */
#include < amxmodx >
#include < fakemeta >
#include < zombieplague >
#include < fun >
#include < cstrike >

new g_classzjump

new const zclass1_name[ ] = { "Jump Zombie" };
new const zclass1_info[ ] = { "[velmi nizka gravitacia]" };
new const zclass1_model[ ] = { "profun_jump" };
new const zclass1_clawmodel [] = { "v_profun_jumper.mdl" };
const zclass1_health = 2200;
const zclass1_speed = 220;
const Float:zclass1_gravity = 0.3;
const Float:zclass1_knockback = 1.0;

public plugin_precache( )
{
	register_plugin( "[ZP-Class] Jump Zombie", "1.3", "adamCSzombie" );
	register_event("CurWeapon" , "fw_EvECurWeapon" , "be" , "1=1")
	
	g_classzjump = zp_register_zombie_class( zclass1_name, zclass1_info, zclass1_model, zclass1_clawmodel, zclass1_health, zclass1_speed, zclass1_gravity, zclass1_knockback );
}

public fw_EvECurWeapon( id )
{
	if( is_user_alive( id ) )
	{
		if( zp_get_user_first_zombie( id ) )
		{
			if( zp_get_user_zombie_class( id ) ==  g_classzjump )
			{
				new g_iPrevCurWeapon[ 33 ];
				new iCurWeapon = read_data( 3 )
				if( iCurWeapon != g_iPrevCurWeapon[ id ] )
				{
					set_user_maxspeed( id , 300.0 );
					g_iPrevCurWeapon[ id ] = iCurWeapon;
				}
			}
		}
	}
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

public zp_user_infected_post( player, infector )
{
	if( is_user_alive( player ) )
	{
		if( zp_get_user_zombie_class( player ) == g_classzjump )
		{
			ChatColor( player ,"!t[JUMP ZOMBIE]!y Tvoja schopnost je automaticky nastavena!" );
		}
	}
}
