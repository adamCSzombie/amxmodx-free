#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < zombieplague >
#include < fakemeta >
#include < fakemeta_util >

#define PLUGIN			"[Avatar] Force G3SG1"
#define VERSION			"0.3"
#define AUTHOR			"adamCSzombie"
#define EVIP 			ADMIN_LEVEL_G
#define EXTRA_ITEM 		"Force G3SG1"
#define BODY			20

new g_item;

new g_knife[ 33 ];

new bool:reload[ 33 ] = false;

public plugin_init( ) 
{
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	g_item = zp_register_extra_item( EXTRA_ITEM, BODY, ZP_TEAM_HUMAN );
}

public stopreload( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	new plrClip, plrAmmo;
	get_user_weapon( id, plrClip , plrAmmo );
				
	if(reload[ id ] == true )
	{
		if( g_knife[ id ] )
		{
			if( get_user_weapon( id ) == CSW_DEAGLE )
			{	
				set_task( 0.1,"daj_naboje",id );
			}
		}
	}
	return PLUGIN_CONTINUE;	
}
 
public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_item ) 
	{
		if( g_knife[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 20 );
			return;
		}
		client_print( player, print_chat, "%L", LANG_PLAYER, "FORCE_BUY" );
			
		g_knife[ player ] = true;
			
		give_item( player, "weapon_g3sg1" );
		cs_set_user_bpammo( player, CSW_G3SG1, 350 );	
	}
}

public zp_user_infected_post( infected, infector )
{
	if( g_knife[ infected ] )
	{
		g_knife[ infected ] = false;
	}
}

public client_putinserver( id )
{
	g_knife[ id ] = false;
}

public client_disconnect( id )
{
	g_knife[ id ] = false;
}
