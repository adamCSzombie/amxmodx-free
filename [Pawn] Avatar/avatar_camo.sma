#include < amxmodx > 
#include < fakemeta > 
#include < zombieplague > 
#include < hamsandwich >
#include < fun >

new const zclass_name[ ] = 	"Avatar Camo [ExtraVIP]"
new const zclass_info[ ] = 	"[schopnost neviditelnosti]"	
new const zclass_model[ ] = 	"avatar"
new const zclass_clawmodel[ ] = 	"v_knife_avatar.mdl"

const zclass_health = 1300;	
const zclass_speed = 220;	

new const prefix[ ] = "[Avatar Camo]";

const Float:zclass_gravity = 1.0;		
const Float:zclass_knockback = 0.5;

new const SOUND_INVIS[ ] = "bluezone/zombie/invisup.wav";	
new const SOUND_INVIS_END[ ] = "bluezone/zombie/invisdown.wav";

const TIME_INVIS = 10;
const TIME_COOLD = 30;

new g_iGhostClass;
new g_iCooldownSkill[ 33 ];
new g_iCooldownTimer[ 33 ];

public plugin_init ( ) {
	
	register_plugin ( "[ZP Class] Class Ghost" , "1.0", "Shurik07" );	// EDIT By Amik
	register_clcmd( "drop", "Schopnost");	// Schopnosù sa sp˙öùa pÌsmenom G - drop.
	
	RegisterHam( Ham_Spawn,"player","Spawn",1 );
	register_event( "CurWeapon" , "fw_EvRCurWeapon" , "be" , "1=1" );
}

public Spawn( id ) 
{
	remove_task( id );
	g_iCooldownTimer[ id ] = 0;
	g_iCooldownSkill[ id ] = 0;
}
public plugin_precache ( ) 
{
	
	g_iGhostClass = zp_register_zombie_class( zclass_name, zclass_info, zclass_model,
		zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback );
	
	engfunc( EngFunc_PrecacheSound , SOUND_INVIS );
	engfunc( EngFunc_PrecacheSound , SOUND_INVIS_END );
}

public zp_round_ended ( ) 
{
	
	static iPlayer ; 
	for ( iPlayer = 1; iPlayer <= get_maxplayers( ); iPlayer++ ) 
	{
		
		g_iCooldownSkill[ iPlayer ] = 0 ;
		g_iCooldownTimer[ iPlayer ] = 0 ;
		
		remove_task( iPlayer );
	}
}	

public zp_user_humanized_post ( iPlayer ) 
{
	
	UTIL_set_rendering( iPlayer );
	
	g_iCooldownSkill[ iPlayer ] = 0 ;
	g_iCooldownTimer[ iPlayer ] = 0 ;
	
	remove_task( iPlayer );
}

public zp_user_infected_post ( iPlayer , iInfector , iNemesis ) 
{
	
	if ( zp_get_user_zombie( iPlayer ) && zp_get_user_zombie_class( iPlayer ) == g_iGhostClass &&
	!zp_get_user_nemesis( iPlayer ) ) 
	{
		
		g_iCooldownSkill[ iPlayer ] = 0 ;
		g_iCooldownTimer[ iPlayer ] = 0 ;
		ChatColor( iPlayer,"!t[GHOST ZOMBIE]!y Svoju schopnost aktivujes stlacenim pismena !gG!y!" );
		remove_task( iPlayer ) ;
	}
}

public Schopnost ( iPlayer ) 
{
		
	if ( get_user_team( iPlayer ) == 1 && zp_get_user_zombie( iPlayer ) && !zp_get_user_first_zombie( iPlayer ) && zp_get_user_zombie_class( iPlayer ) == g_iGhostClass &&
	!zp_get_user_nemesis( iPlayer ) && g_iCooldownSkill[ iPlayer ] <= 0 && g_iCooldownTimer[ iPlayer ] <= 0) 
	{
		
		UTIL_set_rendering( iPlayer, kRenderFxGlowShell, 255, 255, 255, kRenderTransAlpha, 0 );
		
		set_task( 1.0 , "Neviditelnost" , iPlayer , _, _, "b" );
		emit_sound( iPlayer , CHAN_WEAPON , SOUND_INVIS , 1.0 , ATTN_NORM , 0 , PITCH_NORM ) ;
		ChatColor( iPlayer,"!t[GHOST ZOMBIE]!y Momentalne si neviditelny!" );
		
		g_iCooldownSkill[ iPlayer ] = TIME_INVIS;
	}
	else if ( get_user_team( iPlayer ) == 1 && zp_get_user_zombie( iPlayer ) && !zp_get_user_first_zombie( iPlayer ) && zp_get_user_zombie_class( iPlayer ) == g_iGhostClass &&
	!zp_get_user_nemesis( iPlayer ) && g_iCooldownSkill[ iPlayer ] <= 1 && g_iCooldownTimer[ iPlayer ] <= 1) 
	{
		ChatColor( iPlayer, "!t[GHOST ZOMBIE]!y Nemozes teraz pouzit tuto funkciu!" );
	}
}

public Neviditelnost ( iPlayer ) 
{
	
	if ( !is_user_alive ( iPlayer ) ) return ;
	if ( g_iCooldownSkill[ iPlayer ] <= 0 ) 
	{
		
		remove_task( iPlayer );
		UTIL_set_rendering( iPlayer );
		emit_sound( iPlayer , CHAN_WEAPON , SOUND_INVIS_END , 1.0 , ATTN_NORM , 0 , PITCH_NORM ) ;
		ChatColor( iPlayer,"!t[GHOST ZOMBIE]!y Tvoja Schopnost skoncila!" );
		
		g_iCooldownTimer[ iPlayer ] = TIME_COOLD
		
		set_task( 1.0 , "Nacitavanie" , iPlayer , _, _, "b" );
		return;
	}
		
	g_iCooldownSkill[ iPlayer ]--	
	set_hudmessage( 85, 127, 255, -1.0, 0.15, 0, 1.0, 1.1, 0.0, 0.0, -1 );
	show_hudmessage( iPlayer , "Neviditelnost: %d sec", g_iCooldownSkill[ iPlayer ] );
}

public Nacitavanie ( iPlayer ) {
	
	if ( !is_user_alive ( iPlayer ) ) return ;
	if ( g_iCooldownTimer[ iPlayer ] <= 0 ) 
	{
		
		remove_task( iPlayer );
		ChatColor( iPlayer,"!t[GHOST ZOMBIE]!y Schopnost bola znova obnovena!" );
		return;
	}
	
	g_iCooldownTimer[ iPlayer ]--	
	set_hudmessage( 255, 127, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1 );
	show_hudmessage( iPlayer , "Nacitanie Schopnosti: %d sec", g_iCooldownTimer[ iPlayer ] );
}
stock ChatColor(const id, const input[], any:...)
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

stock UTIL_set_rendering ( entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16 ) 
{
	
	static Float:color [ 3 ];
	color[ 0 ] = float( r );
	color[ 1 ] = float( g );
	color[ 2 ] = float( b );
	
	set_pev( entity, pev_renderfx, fx );
	set_pev( entity, pev_rendercolor, color );
	set_pev( entity, pev_rendermode, render );
	set_pev( entity, pev_renderamt, float( amount ) );
}

public fw_EvRCurWeapon( id )
{
	if( zp_get_user_first_zombie( id ) )
	{
		if( zp_get_user_zombie_class( id ) ==  g_iGhostClass )
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
