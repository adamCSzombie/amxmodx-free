#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < zombieplague >

#define PLUGIN 		"[Avatar] Heavy Gun"
#define VERSION 	"0.3"
#define AUTHOR 		"adamCSzombie"

#define EXTRA_ITEM		"Heavy Gun"
#define ITEM_COST		30

new g_heavegun, g_have_heavegun[ 33 ], g_Weapon[ 33 ];

new const model_heavegun[ ] = { "models/gs_zbrane/v_test.mdl" };

public plugin_init( ) 
{
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" ); 
	
	g_heavegun = 			zp_register_extra_item ( EXTRA_ITEM , ITEM_COST , ZP_TEAM_HUMAN );
}

public plugin_precache( )
{
	precache_model( model_heavegun );
}

public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_heavegun ) 
	{
		if( g_have_heavegun[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "%L", LANG_PLAYER, "HEAVY_HAVE" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 30 );
			return;
		}
		
		client_cmd( player, "spk valve/sound/buttons/get_pistol" );
		client_print( player, print_chat, "%L", LANG_PLAYER, "HEAVY_BUY" );
				
		g_have_heavegun[ player ] = true
				
		give_item( player, "weapon_m249" );
				
		cs_set_user_bpammo( player, CSW_M249, 200 );  
	}		
}

public zp_user_infected_post( infected, infector )
{
	if( g_have_heavegun[ infected ] )
	{
		g_have_heavegun[ infected ] = false;
	}
}

public event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	g_Weapon[ id ] = read_data( 2 )
	
	if( zp_get_user_zombie( id ) || zp_get_user_survivor( id ) )
		return PLUGIN_CONTINUE;
	
	if( !g_have_heavegun[ id ] || g_Weapon[ id ] != CSW_M249 ) 
		return PLUGIN_CONTINUE;
	
	entity_set_string( id, EV_SZ_viewmodel, model_heavegun ); 
	
	return PLUGIN_CONTINUE;
}

public client_putinserver( id )
{
	g_have_heavegun[ id ] = false;
}

public client_disconnect( id )
{
	g_have_heavegun[ id ] = false;
}
