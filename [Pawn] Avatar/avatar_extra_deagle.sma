#include < amxmodx >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < hamsandwich >
#include < zombieplague >
#include < fakemeta >
#include < fakemeta_util >

#define PLUGIN			"[Avatar] Army Deagle"
#define VERSION			"0.3"
#define AUTHOR			"adamCSzombie"

#define is_user_valid(%1) 		(1 <= %1 <= g_maxplayers)

new g_item;
new g_knife[ 33 ];

new bool:reload[ 33 ] = false;

new g_maxplayers;

public plugin_natives( )
{
	register_native( "get_deagle", "native_is_user_granatomet", 1 );
}

public native_is_user_granatomet( player )
{
	client_print( player, print_chat, "Ziskal jsi Army Deagle!" );
		
	g_knife[ player ] = true
		
	ham_strip_weapon( player,"weapon_deagle" );
		
	give_item( player, "weapon_deagle" );
		
	cs_set_user_bpammo( player, CSW_DEAGLE, 350 );
	set_task( 0.2,"daj_naboje",player );
}

public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_item = zp_register_extra_item( "Army Deagle", 25, ZP_TEAM_HUMAN );
	
	register_event( "CurWeapon", "Event_Change_Weapon", "be", "1=1" );
	register_event( "CurWeapon", "stopreload", "be"  );
	
	g_maxplayers = get_maxplayers( );
}

public stopreload( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	new plrClip, plrAmmo;
	
	get_user_weapon( id, plrClip , plrAmmo );
				
	
	if( reload[ id ] == true )
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

public client_PreThink( id ) 
{
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	new plrClip, plrAmmo;
	new clip, ammo;
	get_user_weapon( id, clip, ammo );
	
	get_user_weapon( id, plrClip , plrAmmo );
	if( g_knife[ id ] )
	{
		if( get_user_weapon( id ) == CSW_DEAGLE )
		{
			if( get_user_button( id ) & IN_RELOAD && reload[ id ] == false )
			{
				if( ammo < 7 )
				return PLUGIN_CONTINUE;
				
				if( ( plrClip != 7 ) && ( plrClip != 21 ) )
				reload[ id ] = true;
			}
		}
		if( get_user_weapon( id ) == CSW_DEAGLE )
		{
			if( plrClip == 0 )
				reload[ id ] = true;
		}
	}
	
	return PLUGIN_CONTINUE
}
stock get_weapon_ent( id,wpnid=0,wpnName[]="" )
{
	static newName[ 24 ];

	if( wpnid ) get_weaponname( wpnid,newName,23 );

	else formatex( newName,23,"%s",wpnName );

	if( !equal( newName,"weapon_",7 ) )
		format( newName,23,"weapon_%s",newName );

	return fm_find_ent_by_owner( get_maxplayers( ),newName,id );
} 
public daj_naboje( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	new clip, ammo;
	new weapon = get_user_weapon( id, clip, ammo );
	new ent = get_weapon_ent( id,weapon );
	
	if( get_user_weapon( id ) == CSW_DEAGLE )
	{	
		cs_set_weapon_ammo( ent, 21 );
		reload[ id ] = false;
	}
	
	return PLUGIN_CONTINUE;
}		

stock ham_strip_weapon( id,weapon[ ] )
{
	    if( !equal( weapon,"weapon_",7 ) ) return 0;
	
	    new wId = get_weaponid( weapon );
	    if( !wId ) return 0;
	
	    new wEnt;
	    while( ( wEnt = engfunc( EngFunc_FindEntityByString, wEnt, "classname", weapon ) ) && pev( wEnt,pev_owner ) != id ) {}
	    if( !wEnt ) return 0;
	
	    if( get_user_weapon( id ) == wId ) ExecuteHamB( Ham_Weapon_RetireWeapon,wEnt );
	
	    if( !ExecuteHamB( Ham_RemovePlayerItem,id,wEnt ) ) return 0;
	    ExecuteHamB( Ham_Item_Kill,wEnt );
	
	    set_pev( id, pev_weapons,pev( id, pev_weapons ) & ~( 1 << wId ) );
	
	    return 1;
}
public Event_Change_Weapon( id )
{         
	new weapon;
	weapon = get_user_weapon( id )
	
	if( g_knife[ id ] )
	{	
		if( weapon != CSW_DEAGLE )
		{
			reload[ id ] = false;
		}
	}

	return PLUGIN_CONTINUE 
}

public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_item ) 
	{
		if( g_knife[ player ] )
		{
				client_cmd( player, "spk valve/sound/buttons/button11" );
				client_print( player, print_chat, "Tento item uz vlastnis!" );
				zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 25 );
				return;
		}
		
		client_print( player, print_chat, "Koupil jsi Army Deagle!" );
		
		g_knife[ player ] = true
		
		ham_strip_weapon( player,"weapon_deagle" );
		
		give_item( player, "weapon_deagle" );
		
		cs_set_user_bpammo( player, CSW_DEAGLE, 350 );
		set_task( 0.2,"daj_naboje",player );
	}
}

public zp_user_infected_post( infected, infector )
{
	if( g_knife[ infected ] )
	{
		g_knife[ infected ] = false;
	}
}

public FwdTakeDamage( victim,attacker, Float:damage, damage_bits,id )
{
	
	if( !g_knife[ attacker ] )
		return PLUGIN_CONTINUE; 
	
	if( get_user_weapon( attacker ) == CSW_KNIFE )	
	{						
		SetHamParamFloat( 4, random_float( 150.0, 300.0 ) )		
	}
	
	return HAM_HANDLED;
} 
public client_putinserver( id )
{
	g_knife[ id ] = false;
}

public client_disconnect( id )
{
	g_knife[ id ] = false;
}
