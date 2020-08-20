#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < cstrike >
#include < fakemeta >
#include < fun >
#include < engine >
#include < zombieplague >
#include < fakemeta_util >
#include < weapons >

#define FFADE_IN 	0x0000
#define FIRERATE 	1.0

#define CHAT_MISS    	"Tesne vedle!"
#define CHAT_HIT    	"Trefil jsi!"

#define	VIP		ADMIN_LEVEL_F

#define is_user_valid(%1) (1 <= %1 <= g_iMaxPlayers)

enum 
{
	anim_idle,
	anim_idle2,
	anim_gentleidle,
	anim_stillidle,
	anim_draw,
	anim_holster,
	anim_spinup,
	anim_spindown,
	anim_spinidle,
	anim_spinfire,
	anim_spinidledown,
	
};

enum
{
	x,
	y,
	z
};

new max_pouzitia_infect, max_pouzitia_infect_hrac[ 33 ];
new Jumpnum[ 33 ] = false;
new bool:canJump[ 33 ] = false;
new g_msgScreenFade;

new skok[ 33 ];

new g_hudmsg1;

new cvar_pattack_rate, cvar_sattack_rate;

new raz_za_kolo[ 33 ];

new const Si[ ] 	= 			{ "playaspro_avatar/zrozeni4.wav" };
new const Si2[ ] = 			{ "playaspro_avatar/zrozeni5.wav" };
new const Si3[ ] = 			{ "playaspro_avatar/zrozeni6.wav" };

new const tlkot[ ] = 			{ "playaspro_avatar/effect_shock.wav" };
new bool:has_jp[ 33 ];

const m_pActiveItem = 		373
new const zclass1_name[ ] = 		{ "Avatar Warrior" };
new const zclass1_model[ ] = 		{ "playaspro_avatar" };
new const zclass1_clawmodel[ ] = 	{ "av_weapon.mdl" };
const zclass1_health = 			2000;
const zclass1_speed = 			270;
const Float:zclass1_gravity = 		0.30;
const Float:zclass1_knockback = 		0.69;

new const zclass2_name[ ] = 		{ "Heitero Bull" };
new const zclass2_model[ ] = 		{ "av_bull" };
new const zclass2_clawmodel[ ] = 	{ "cerbeus_zomb2.mdl" };
const zclass2_health = 			1750;
const zclass2_speed = 			320;
const Float:zclass2_gravity = 		1.00;
const Float:zclass2_knockback = 		1.00;

new const zclass3_name[ ] = 		{ "Blood Dragon" };
new const zclass3_model[ ] = 		{ "av_dragon" };
new const zclass3_clawmodel[ ] = 	{ "v_new_dragon_hands.mdl" };
const zclass3_health = 			1200;
const zclass3_speed = 			240;
const Float:zclass3_gravity = 		0.60;
const Float:zclass3_knockback = 		2.00;

new const zclass4_name[ ] = 		{ "Avatar Nature" };
new const zclass4_model[ ] = 		{ "playaspro_avatar" };
new const zclass4_clawmodel[ ] = 	{ "av_weapon.mdl" };
const zclass4_health = 			1000;
const zclass4_speed = 			410;
const Float:zclass4_gravity = 		0.69;
const Float:zclass4_knockback = 		2.00;

new const zclass5_name[ ] = 		{ "Avatar Life" };
new const zclass5_model[ ] = 		{ "playaspro_avatar" };
new const zclass5_clawmodel[ ] = 	{ "av_weapon.mdl" };
const zclass5_health = 			2800;
const zclass5_speed = 			230;
const Float:zclass5_gravity = 		1.0;
const Float:zclass5_knockback = 		2.00;

new const zclass6_name[ ] = 		{ "Avatar Life Stealer" }
new const zclass6_model[ ] = 		{ "playaspro_avatar" }
new const zclass6_clawmodel[ ] = 	{ "av_weapon.mdl" }
const zclass6_health = 			1200;
const zclass6_speed = 			270;
const Float:zclass6_gravity = 		0.65;
const Float:zclass6_knockback = 		0.80;


new const zclass7_name[ ] = 		{ "Avatar Jumper" };
new const zclass7_model[ ] = 		{ "playaspro_avatar" };
new const zclass7_clawmodel[ ] = 	{ "av_weapon.mdl" }
const zclass7_health = 			1350;
const zclass7_speed = 			260;
const Float:zclass7_gravity = 		0.7;
const Float:zclass7_knockback = 		1.50;

new const zclass8_name[ ] = 		{ "Avatar Magic" }
new const zclass8_model[ ] = 		{ "playaspro_avatar" }
new const zclass8_clawmodel[ ] = 	{ "av_weapon.mdl" }
const zclass8_health = 			1400;
const zclass8_speed = 			270;
const Float:zclass8_gravity = 		1.0;
const Float:zclass8_knockback = 		0.9;


new avatar_warrior, avatar_bull, avatar_dragon, avatar_nature, avatar_life, avatar_destroyer, avatar_jumper, avatar_magic
const m_pPlayer = 		41;
const m_flTimeWeaponIdle = 	48;
const m_flNextPrimaryAttack = 	46;
const m_flNextSecondaryAttack =	47;

new g_hasBhop[ 33 ];

new g_item_luk, gSpr_regeneration;
new luk[ 33 ] = false;
new schopnost[ 33 ];

new g_msgShake;
new prodleva_speed[ 33 ];

new g_msgFade;
new ratanie[ 33 ];

new VIEW_av[ ]    	= "models/zombie_plague/av_weapon.mdl";

new VIEW_kusa[ ]    	= "models/gs_zbrane/v_luk.mdl";
new PLAYER_kusa[ ]    	= "models/gs_zbrane/p_luk.mdl";


new blok_strelby[ 33 ];
new PLAYER_clasic[ ]    	= "models/p_knife.mdl";

new kontrola_klasu[ 33 ] = 0;

new g_knife[ 33 ];

new g_iMaxPlayers;

new g_iCurrentWeapon[ 33 ];

public plugin_natives( )
{
	register_native( "have_user_infect","native_have_user_infect", 1 );
}

public native_have_user_infect( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[Avatar] Invalid Player (%d)", id );
		return -1;
	}
	
	return max_pouzitia_infect_hrac[ id ];
} 
 
public plugin_precache( ) {
	new text[ 555 char ];
	register_dictionary( "zombie_plague.txt" );
	g_iMaxPlayers = 		get_maxplayers( );
	g_hudmsg1 =			CreateHudSyncObj( );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_WARRIOR" );
	avatar_warrior = 		zp_register_zombie_class( zclass1_name, text, zclass1_model, zclass1_clawmodel, zclass1_health, zclass1_speed, zclass1_gravity, zclass1_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_BULL" );
	avatar_bull = 			zp_register_zombie_class( zclass2_name, text, zclass2_model, zclass2_clawmodel, zclass2_health, zclass2_speed, zclass2_gravity, zclass2_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_DRAGON" );
	avatar_dragon = 		zp_register_zombie_class( zclass3_name, text, zclass3_model, zclass3_clawmodel, zclass3_health, zclass3_speed, zclass3_gravity, zclass3_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_NATURE" );
	avatar_nature = 		zp_register_zombie_class( zclass4_name, text, zclass4_model, zclass4_clawmodel, zclass4_health, zclass4_speed, zclass4_gravity, zclass4_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_LIFE" );
	avatar_life = 			zp_register_zombie_class( zclass5_name, text, zclass5_model, zclass5_clawmodel, zclass5_health, zclass5_speed, zclass5_gravity, zclass5_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_LIFE_STEALER" );
	avatar_destroyer = 		zp_register_zombie_class( zclass6_name, text, zclass6_model, zclass6_clawmodel, zclass6_health, zclass6_speed, zclass6_gravity, zclass6_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_JUMPER" );
	avatar_jumper  = 		zp_register_zombie_class( zclass7_name, text, zclass7_model, zclass7_clawmodel, zclass7_health, zclass7_speed, zclass7_gravity, zclass7_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_MAGIC" );
	avatar_magic = 			zp_register_zombie_class( zclass8_name, text, zclass8_model, zclass8_clawmodel, zclass8_health, zclass8_speed, zclass8_gravity, zclass8_knockback );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW" );
	g_item_luk = 			zp_register_extra_item( text, 40, ZP_TEAM_ZOMBIE );
	g_msgShake = 			get_user_msgid( "ScreenShake" );
	g_msgFade = 			get_user_msgid( "ScreenFade" );
	cvar_pattack_rate = 		register_cvar( "av_destroyer_attack1_rate", "0.6" );
	cvar_sattack_rate = 		register_cvar( "av_destroyer_attack2_rate", "1.2" );
	
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_Knife_PrimaryAttack_Post", 1 );
	RegisterHam( Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1 );
	
	register_forward( FM_PlayerPreThink, "fw_PlayerPreThink" );
	register_forward( FM_PlayerPostThink, "fm_PlayerPostThink" );
	register_forward( FM_CmdStart, "fwdCmdStart", 0 );
	
	RegisterHam( Ham_TraceAttack, "player", "player_attack" );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled" );
	RegisterHam( Ham_Spawn, "player", "player_spawn", 1 ); 
	RegisterHam( Ham_TakeDamage, "player", "fw_TakeDamage" );
	
	g_msgScreenFade = get_user_msgid( "ScreenFade" );
	register_logevent( "round_end", 2, "1=Round_End" );
	
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" );
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	
	precache_sound( Si );
	precache_sound( Si2 );
	precache_sound( Si3 );
	
	precache_sound( tlkot );
	
	register_event( "CurWeapon", 	"Event_Change_Weapon", "be", "1=1" );
	
	precache_model( VIEW_av );
	
	precache_model( VIEW_kusa );
	precache_model( PLAYER_kusa );
	precache_sound( "gs_kusa/gs_kusa.wav" );
	precache_model( PLAYER_clasic );
	
	gSpr_regeneration = precache_model( "sprites/th_jctf_heal.spr" );
	
}	

public player_spawn( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
	g_hasBhop[ id ] = false;
	has_jp[ id ] = false;
	
	schopnost[ id ] = 0;
	canJump[ id ] = false;
	
	set_user_rendering( id , kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
	
	blok_strelby[ id ] = 0;
	kontrola_klasu[ id ] = 0;
	
	if( luk[ id ] )
	{
		ham_strip_weapon( id, "weapon_sg550" );
		luk[ id ]  = false;
	}
	
	return HAM_IGNORED;
}
public round_end( )
{
	if( !is_user_alive( read_data( 2 ) ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( read_data( 2 ) ) )
		return PLUGIN_CONTINUE;
	
	g_hasBhop[ read_data( 2 ) ] = false;
	
	has_jp[ read_data( 2 ) ] = false;
	
	luk[ read_data( 2 ) ]  = false;
	
	schopnost[ read_data( 2 ) ] = 0;
	
	canJump[ read_data( 2 ) ] = false;
	
	set_user_rendering( read_data( 2 ) , kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
	
	blok_strelby[ read_data( 2 ) ] = 0;
	kontrola_klasu[ read_data( 2 ) ] = 0;
	
	return PLUGIN_CONTINUE;
}
	
public zp_extra_item_selected( player, itemid )
{
	new text[ 555 char ];
	if( itemid == g_item_luk ) 
	{
		if( get_user_flags( player ) & VIP )
		{
			if( ( kontrola_klasu[ player ] != 2 ) && ( kontrola_klasu[ player ] != 3 ) )
			{
				client_cmd( player, "spk valve/sound/items/suitchargeok1" );
				formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_BUY" );
				ChatColor( player, text );
				luk[ player ] = true;
				ratanie[ player ] = 0;
				
				cmd_luk( player );
				if( !user_has_weapon( player, CSW_SG550 ) )
					cs_set_weapon_ammo( give_item( player, "weapon_sg550" ), 0 );
				
				engclient_cmd( player, "weapon_sg550" )
				schopnost[ player ] = 1;
				
				if( kontrola_klasu[ player ] == 7 )
				{
					if( schopnost[ player ] == 5 )
					{
						skok[ player ] = 49 - Jumpnum[ player ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_JUMPER_WITH_CROSSBOW_INFECT" );
						show_hudmessage( player, text, skok[ player ] );
					}
					else
					{
						skok[ player ] = 49 - Jumpnum[ player ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						formatex( text, charsmax( text ), "%L", LANG_PLAYER, "AVATAR_JUMPER_JUMPS" );
						show_hudmessage( player, text, skok[ player ] );
					}	
				}
				else
				{	
					if( schopnost[ player ] == 5 )
					{
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_INFECT" );
						show_hudmessage( player, text );
					}
					else
					{
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_AMMO" );
						show_hudmessage( player, text );
					}
				}
				formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_INFO" );
				client_print( player, print_chat, text );
			}
			else
			{
				client_cmd( player, "spk valve/sound/buttons/button11" );
				zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 40 )
				formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_NO_GOOD_AVATAR" );
				client_print( player, print_center, text );
				return PLUGIN_HANDLED;
			}	
		}
		else
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			formatex( text, charsmax( text ), "%L", LANG_PLAYER, "WEAPON_CROSSBOW_PREMIUM" );
			client_print( player, print_chat, text );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + 40 );
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}

public cmd_luk( id )
{
	new text[ 555 char ], text1[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "MENU_LUK" );
	static menu
	{
		menu = menu_create( text, "menu_luk" );
		formatex( text, charsmax( text ), "%L", id, "SLOW_LUK" );
		menu_additem( menu, text, "1", 0 );
		formatex( text, charsmax( text ), "%L", id, "BLIND_LUK" );
		menu_additem( menu, text, "2", 0 );
		formatex( text, charsmax( text ), "%L", id, "SHOOT_LUK" );
		menu_additem( menu, text, "3", 0 );
		formatex( text, charsmax( text ), "%L", id, "KEVLAR_LUK" );
		menu_additem( menu, text, "4", 0 );
		formatex( text, charsmax( text ), "%L", id, "INFECT_LUK" );
		formatex( text1, charsmax( text1 ), "%L", id, "INFECT_LUK1" );
		menu_additem( menu, ( max_pouzitia_infect_hrac[ id ] == 0 ) ? text : text1, "5", 0 );            
		menu_display( id, menu );
	}
	return PLUGIN_HANDLED;
}

public menu_luk( id, menu, item )
{
	if( luk[ id ] && ( kontrola_klasu[ id ] != 2 ) && ( kontrola_klasu[ id ] != 3 ) )
	{
		if( item == MENU_EXIT )
		{
			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}

		static dst[ 32 ], data[ 5 ], access, callback
		
		menu_item_getinfo( menu, item, access, data, charsmax( data ), dst, charsmax( dst ), callback );
		get_user_name( id, dst, charsmax( dst ) );
		menu_destroy( menu );
		
		switch( data[ 0 ] )
		{
			
			case( '1' ):
			{
				schopnost[ id ] = 1;
				native_playanim( id, anim_idle );
				for( new i = 0; i < 5; i++ ) {
					ChatColor( id, "%L", LANG_PLAYER, "SLOW_CHOOSE" );
				}
        
			}
			case( '2' ):
			{
				schopnost[ id ] = 2;
				native_playanim( id, anim_idle )
				for( new i = 0; i < 5; i++ ) {
					ChatColor( id, "%L", LANG_PLAYER, "BLIND_CHOOSE" );
				}
			}
			case( '3' ):
			{
				schopnost[ id ] = 3;
				native_playanim( id, anim_idle );
				for( new i = 0; i < 5; i++ ) {
					ChatColor( id, "%L", LANG_PLAYER, "SHOOT_CHOOSE" );
				}
		
			}
			case( '4' ):
			{
				schopnost[ id ] = 4;
				native_playanim( id, anim_idle )
				for( new i = 0; i < 5; i++ ) {
					ChatColor( id, "%L", LANG_PLAYER, "KEVLAR_CHOOSE" );
				}
			
			}
			case( '5' ):
			{
				if( max_pouzitia_infect != 2 )
				{
					if( max_pouzitia_infect_hrac[ id ] == 0 )
					{
						max_pouzitia_infect_hrac[ id ] += 1;
						max_pouzitia_infect += 1;
						
						schopnost[ id ] = 5;
						native_playanim( id, anim_idle )
						for( new i = 0; i < 5; i++ ) {
							ChatColor( id, "%L", LANG_PLAYER, "INFECT_CHOOSE" );
						}
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						client_print( id, print_chat, "%L", LANG_PLAYER, "INFECT_ONCE" );
						cmd_luk( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					client_print( id, print_chat, "%L", LANG_PLAYER, "INFECT_MORE" );
					cmd_luk( id );
				}
			
			}
		}
	}
	return PLUGIN_HANDLED;
}

public shake2 ( id )
{
	client_cmd( id, "spk silent/vip/items/give_item" );
	
	message_begin( MSG_ONE_UNRELIABLE, g_msgShake, .player=id );
	{
		write_short( 255<<15 );
		write_short( 50<<8 );
		write_short( 255<<15 );
	}
	message_end( );
}

public prodleva( id )
{
	prodleva_speed[ id ] = false;
}
	
public Event_Change_Weapon( id )
{	
	if( get_user_weapon( id ) == CSW_SG550 )
	{
		set_pev( id, pev_viewmodel2, VIEW_kusa );
		set_pev( id, pev_weaponmodel2, PLAYER_kusa );
	}
}

stock ham_strip_weapon( id,weapon[ ] )
{
	    if( !equal( weapon,"weapon_",7 ) ) return 0;
	
	    new wId = get_weaponid( weapon );
	    if( !wId ) return 0;
	
	    new wEnt;
	    while( ( wEnt = engfunc( EngFunc_FindEntityByString,wEnt,"classname",weapon ) ) && pev( wEnt,pev_owner ) != id ) {}
	    if( !wEnt ) return 0;
	
	    if( get_user_weapon( id ) == wId ) ExecuteHamB( Ham_Weapon_RetireWeapon,wEnt );
	
	    if( !ExecuteHamB( Ham_RemovePlayerItem,id,wEnt ) ) return 0;
	    ExecuteHamB( Ham_Item_Kill,wEnt );
	
	    set_pev( id,pev_weapons,pev( id,pev_weapons ) & ~( 1 << wId ) );
	
	    return 1;
}
public fw_ClientKill( )
{
	return FMRES_SUPERCEDE;
}
public native_playanim( player, anim )
{
	set_pev( player, pev_weaponanim, anim); 
	message_begin( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, { 0, 0, 0 }, player );
	write_byte( anim );
	write_byte( pev( player, pev_body ) );
	message_end( );
}

public zvuk( id )
{
		
	client_cmd( id, "spk gs_kusa/gs_kusa.wav" );
}
	
public extra_power( id )
{	
	new ent,boris;
	
	new szPlayerName[ 32 ];
	get_user_name( id, szPlayerName, 32 );
	
	set_task( 0.1,"zvuk",id )
	
	if( schopnost[ id ] == 1 )
	{			
		get_user_aiming( id,ent,boris )
		new szPlayerName2[ 32 ];
		get_user_name( ent, szPlayerName2, 32 );
		
		if( is_user_alive( ent ) )
		{
			if ( !zp_get_user_zombie( ent ) )
			{
				client_cmd( ent,"cl_forwardspeed 100" );
				client_cmd( ent,"cl_backspeed 100" );
				client_cmd( ent,"cl_sidespeed 100" );
				set_task( 5.0,"hahaha",ent );
				ChatColor( 0, "%L", LANG_PLAYER , "SLOW_SHOOTED", szPlayerName, szPlayerName2 );
			
			}
			else
			{
				client_print(id, print_center, CHAT_MISS );
			}
			
		}
		else
		{
			client_print(id, print_center, CHAT_MISS );
		}
	}
	if( schopnost[ id ] == 2 )	
	{	
		get_user_aiming( id,ent,boris )
		new szPlayerName3[ 32 ];
		get_user_name( ent, szPlayerName3, 32 )
		
		if( is_user_alive( ent ) )
		{
			if( !zp_get_user_zombie( ent ) )
			{	
				client_cmd( ent, "spk silent/vip/items/dissable" );	
				message_begin( MSG_ONE_UNRELIABLE, g_msgFade, .player = ent );
				write_short( 3<<12 );
				write_short( 3<<12 );
				write_short( FFADE_IN );
				write_byte( 000 );
				write_byte( 000 );
				write_byte( 000 );
				write_byte( 255 );
				message_end( );
				
				message_begin( MSG_ONE_UNRELIABLE, g_msgFade, .player = id );
				write_short( 1<<10 );
				write_short( 1<<10 );
				write_short( 0x0000 );
				write_byte( 255 );
				write_byte( 255 );
				write_byte( 255 );
				write_byte( 75 );
				message_end( );
				
				ChatColor( 0, "%L", LANG_PLAYER , "BLIND_SHOOTED", szPlayerName, szPlayerName3 );
			}
			else
			{
				client_print( id, print_center, CHAT_MISS );	
			}
		}
		else
		{
			client_print(id, print_center, CHAT_MISS );						
		}
	}
	if( schopnost[ id ] == 3 )	
	{	
		get_user_aiming( id,ent,boris );
		new szPlayerName3[ 32 ];
		get_user_name( ent, szPlayerName3, 32 );
		
		if( is_user_alive( ent ) )
		{
			if( !zp_get_user_zombie( ent ) )
			{
				client_cmd( ent, "spk silent/vip/items/dissable" );
				
				ChatColor( 0, "%L", LANG_PLAYER , "SHOOT_SHOOTED", szPlayerName, szPlayerName3 );
				blok_strelby[ ent ] = 1;
				set_task( 5.0,"blok_off",ent );
				
			}
			else
			{
				client_print(id, print_center, CHAT_MISS );						
			}
		}
		else
		{
			client_print(id, print_center, CHAT_MISS );						
		}
		
		set_task( 0.5,"back",id );
	}
	if( schopnost[ id ] == 4 )	
	{	
		get_user_aiming( id,ent,boris );
		new szPlayerName3[ 32 ];
		get_user_name( ent, szPlayerName3, 32 );
		
		if( is_user_alive( ent ) )
		{
			if( !zp_get_user_zombie( ent ) )
			{
				new armor
				armor = get_user_armor( ent )
				
				if(armor < 40)
				{
					set_user_armor( ent, 0 );
				}
				else
				{
					set_user_armor( ent, armor - 40 );
				}
				
				client_cmd( ent, "spk silent/vip/items/dissable" );
				
				ChatColor( 0, "%L", LANG_PLAYER , "KEVLAR_SHOOTED", szPlayerName, szPlayerName3 );
			}
			else
			{
				client_print( id, print_center, CHAT_MISS );	
			}
		}
		else
		{
			client_print( id, print_center, CHAT_MISS );						
		}
		set_task( 0.5,"back",id );
	}
	if( schopnost[ id ] == 5 )	
	{	
		get_user_aiming( id,ent,boris );
		new szPlayerName3[ 32 ];
		get_user_name( ent, szPlayerName3, 32 );
		
		if( is_user_alive( ent ) )
		{
			if ( !zp_get_user_zombie( ent ) )
			{
				client_cmd( ent, "spk silent/vip/items/dissable" );
				
				zp_infect_user( ent );
				ChatColor( 0, "%L", LANG_PLAYER , "INFECT_SHOOTED", szPlayerName, szPlayerName3 );
			}
			else
			{
				client_print( id, print_center, CHAT_MISS );	
			}
		}
		else
		{
			client_print( id, print_center, CHAT_MISS );						
		}
	}
	set_task( 0.5,"back",id );
}

public client_disconnect( id )
{ max_pouzitia_infect_hrac[ id ] = 0; }
			
public blok_off( id )
{ blok_strelby[ id ] = 0; }
	
public hahaha( id )
{ client_cmd( id,"cl_forwardspeed 400" ); client_cmd( id,"cl_backspeed 400" ); client_cmd( id,"cl_sidespeed 400" ); set_task( 3.1,"hahaha2",id ); }

stock get_weapon_ent( id, wpnid = 0, wpnName[ ] = "" )
{
	static newName[ 24 ];

	if( wpnid ) get_weaponname( wpnid, newName, 23 );

	else formatex( newName, 23, "%s", wpnName );

	if( !equal( newName, "weapon_", 7 ) )
		format( newName, 23, "weapon_%s", newName );

	return fm_find_ent_by_owner( get_maxplayers( ), newName, id );
} 

public vybrat_first( id ) {
	new text[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "FIRST_AVATAR_MENU" );
	new hPrim = menu_create( text, "vybrat_first_handle" );
	formatex( text, charsmax( text ), "%L", id, "FIRST_AVATAR_GOD" );
	menu_additem( hPrim, text, "1", 0 );
	formatex( text, charsmax( text ), "%L", id, "FIRST_AVATAR_HALU" );
	menu_additem( hPrim, text, "2", 0 );
	menu_display( id, hPrim, 0 );
}

public vybrat_first_handle( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iKey = str_to_num( szData );

	switch( iKey )
	{
		case 1:
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 40 );
			set_task( 10.0, "nastav_glow",id );
			set_user_godmode( id, 1 );
		}
		case 2:
		{
			give_halu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public zp_user_infected_post( id, infector )
{
	if( !zp_get_user_nemesis( id ) )
	{
		if( !is_user_alive( id ))
			return PLUGIN_CONTINUE;
			
		if( !is_user_connected( id ) )
			return PLUGIN_CONTINUE;
			
		if ( !zp_get_user_zombie( id ) )
			return PLUGIN_HANDLED;
		
		if( zp_get_user_first_zombie( id ) )
		{
			set_task( 0.1, "nastav_glow", id );
			vybrat_first( id );
		}
		else
		{
			set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 40 );
			set_user_godmode( id, 1 );
			set_task( 3.0, "nastav_glow",id );
		}
		
		raz_za_kolo[ id ] = 0
		
		if( g_knife[ id ] )
		{
			g_knife[ id ] = false;
		}
		
		if(zp_get_user_zombie_class( id ) == avatar_warrior)
		{
			ChatColor( id, "%L", id, "CHOOSE_WARRIOR" );
			kontrola_klasu[ id ] = 1;	
		}
		else if(zp_get_user_zombie_class( id ) == avatar_bull)
		{
			ChatColor( id, "%L", id, "CHOOSE_BULL" );
			kontrola_klasu[ id ] = 2;
		}
		else if(zp_get_user_zombie_class( id ) == avatar_dragon)
		{
			ChatColor( id, "%L", id, "CHOOSE_DRAGON" );
			has_jp[ id ] = true;
			kontrola_klasu[ id ] = 3;
			
		}
		else if( zp_get_user_zombie_class( id ) == avatar_nature )
		{
			ChatColor( id, "%L", id, "CHOOSE_NATURE" );
			kontrola_klasu[ id ] = 4;
		}
		else if( zp_get_user_zombie_class( id ) == avatar_life )
		{
			ChatColor( id, "%L", id, "CHOOSE_LIFE" );
			kontrola_klasu[ id ] = 5;
			set_task( 1.0,"doplnanie_hp", id );
		}
		else if( zp_get_user_zombie_class( id ) == avatar_destroyer )
		{
			ChatColor( id, "%L", id, "CHOOSE_LIFEST" );
			g_hasBhop[ id ] = true;
			kontrola_klasu[ id ] = 6;
		}
		else if( zp_get_user_zombie_class( id ) == avatar_jumper )
		{
			ChatColor( id, "%L", id, "CHOOSE_JUMPER" );
			canJump[ id ] = true;
			kontrola_klasu[ id ] = 7;
			Jumpnum[ id ] = 0;
				
		}
		else if( zp_get_user_zombie_class( id ) == avatar_magic )
		{
			ChatColor( id, "%L", id, "CHOOSE_MAGIC" );
			kontrola_klasu[ id ] = 8;
		}
		
		if( zp_get_user_zombie_class( infector ) == avatar_jumper )
		{
			ChatColor( infector, "%L", LANG_PLAYER, "INFECT_JUMPER" );
			Jumpnum[ infector ] -= 5;
			skok[ infector ] -= 5;
		}
		
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;		
}

stock ChatColor( const id, const input[ ], any:...) 
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	
	
	if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
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

public zp_user_infected_pre( id ) 
{ 
	if( !( get_user_flags( id ) & ADMIN_LEVEL_F ) ) 
	{  
		if( zp_get_user_next_class( id ) == avatar_jumper ) 
		{ 
			client_cmd( id, "spk valve/sound/buttons/button11" );
			zp_set_user_zombie_class( id, 0 ); 
			ChatColor( id, "%L", LANG_PLAYER, "AVATAR_NEED_PREMIUM" );
		} 
		if( zp_get_user_next_class( id ) == avatar_magic ) 
		{ 
			client_cmd( id, "spk valve/sound/buttons/button11" );
			zp_set_user_zombie_class( id, 0 ); 
			ChatColor( id, "%L", LANG_PLAYER, "AVATAR_NEED_PREMIUM" );
		} 
	} 	
} 

public nastav_glow( id )
{
	if( !zp_get_user_nemesis( id ) )
	{
		if( !is_user_alive( id ) )
			return PLUGIN_CONTINUE;
		
		if( !is_user_connected( id ) )
			return PLUGIN_CONTINUE;
			
		set_user_godmode( id, 0 );
		
		if ( !zp_get_user_zombie( id ) )
			return PLUGIN_HANDLED;
	
		if (zp_get_user_zombie_class( id ) == avatar_warrior )
		{
			set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );	
		}
		else if(zp_get_user_zombie_class( id ) == avatar_bull )
		{
			set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );	
		}
		else if( zp_get_user_zombie_class( id ) == avatar_dragon )
		{
			set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0 );	
		}
		else if( zp_get_user_zombie_class( id ) == avatar_nature )
		{
			set_user_rendering(id, kRenderFxGlowShell, 215, 31, 212, kRenderNormal, 10 );
		}
		else if( zp_get_user_zombie_class( id ) == avatar_life )
		{
			set_user_rendering( id, kRenderFxGlowShell, 255, 255, 0, kRenderNormal, 10 );
		}
		else if( zp_get_user_zombie_class( id ) == avatar_destroyer )
		{
			set_user_rendering( id, kRenderFxGlowShell, 193, 193, 193, kRenderNormal, 10 );				
		}
		else if( zp_get_user_zombie_class( id ) == avatar_jumper )
		{
			set_user_rendering( id, kRenderFxGlowShell, 255, 100, 0, kRenderNormal, 10 );
		}
		else if( zp_get_user_zombie_class( id ) == avatar_magic )
		{
			set_user_rendering( id, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 10 );	
		}
	}
	return PLUGIN_CONTINUE;
}	
stock randompunch( id ) 
{
	
	new Float:fPAngles[ 3 ];
	pev( id, pev_punchangle, fPAngles );

	fPAngles[ 0 ] += ( random_float( 1.0 , 100.0 ) );
	fPAngles[ 1 ] += ( random_float( 1.0 , 100.0 ) );
	fPAngles[ 2 ] += ( random_float( 1.0 , 100.0 ) );
	
	set_pev( id, pev_punchangle, fPAngles );
}
public vrat_pohlad( id )
{
	message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SetFOV" ), { 0, 0, 0 }, id );
	write_byte( 90 );
	message_end( );
}
public tma( id )
{
	message_begin( MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id );
	write_short( 5 << 5 ); 
	write_short( 10 << 10 ); 
	write_short( 0x0000 );
	write_byte( 000 ); 
	write_byte( 000 );  
	write_byte( 000 ); 
	write_byte( 255 );
	message_end( );
	
	return 1;
}

public fwdCmdStart( plr, handle, seed )
{
	if( !is_user_connected( plr ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( plr ) )
		return PLUGIN_CONTINUE;
	
	if( luk[ plr ] )
	{
		static iButton;
		iButton = get_uc( handle, UC_Buttons );
		
		if( iButton & IN_ATTACK )
		{
			static iWpnID;
			iWpnID = get_pdata_cbase( plr, m_pActiveItem, 5 );
			
			if( get_user_weapon( plr ) == CSW_SG550  )
			{
				set_pdata_float( iWpnID, m_flNextPrimaryAttack, FIRERATE, 4 );
				set_pdata_float( iWpnID, m_flNextSecondaryAttack, FIRERATE, 4 );
				set_pdata_float( iWpnID, m_flTimeWeaponIdle, FIRERATE, 4 );
			}
		}
	}
	
	return FMRES_SUPERCEDE;
}

	
public player_attack( victim, attacker, Float:damage, Float:direction[ 3 ], tracehandle, damagebits )
{
	
	if( !is_user_connected( attacker ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_alive( attacker ) )
		return PLUGIN_CONTINUE;
		
	if(get_user_godmode( attacker ) == 1 )
		set_user_godmode( attacker, 0 );
	
	if( blok_strelby[ attacker ] == 1 )
	{	
		return HAM_SUPERCEDE;
	}
	
	if ( zp_get_user_zombie( attacker ) )
		return PLUGIN_HANDLED;
	
	if( kontrola_klasu[victim] == 8 )
	{
	
		new chance;
		chance = random_num( 1 , 100 );
	
		if( chance >= 50 && chance <= 53 )
		{
			client_cmd( attacker, "stopsound" );
			client_cmd( attacker, "spk valve/sound/player/breathe2" );
			randompunch( attacker );
		}
		else if( chance >= 70 && chance <= 73 )
		{
			client_cmd( attacker, "stopsound" );
			client_cmd( attacker, "spk valve/sound/player/breathe2" );
			tma( attacker ) ;
		}
	}
	return HAM_IGNORED;
}
public client_putinserver( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
		
		
	g_hasBhop[ id ] = false;
	has_jp[ id ] = false;
	
	luk[ id ]  = false;
	
	schopnost[ id ] = 0;
	canJump[ id ] = false;
	
	max_pouzitia_infect_hrac[ id ] = 0;
	
	set_user_rendering( id , kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
	
	blok_strelby[ id ] = 0;
	kontrola_klasu[ id ] = 0;
	return PLUGIN_CONTINUE;
}

public fw_PlayerKilled( victim, attacker, shouldgib )
{	
	if( !is_user_connected( victim ) )
		return PLUGIN_CONTINUE;
		
	g_hasBhop[ victim ] = false;
	has_jp[ victim ] = false;
	
	luk[ victim ]  = false
	schopnost[ victim ] = 0
	canJump[ victim ] = false
	set_user_rendering( victim , kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
	blok_strelby[ victim ] = 0;
	kontrola_klasu[ victim ] = 0;
	
	return PLUGIN_CONTINUE;
}

public zp_user_humanized_post( id, survivor )
{
	cs_set_user_armor( id, 40, CS_ARMOR_VESTHELM );
	
	if( luk[ id ] )
	{
		luk[ id ] = false;
	}
}

public event_round_start( )
{
	for( new i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
		max_pouzitia_infect = 0;
		
		if( max_pouzitia_infect_hrac[ i ] == 1 )
		{
			max_pouzitia_infect_hrac[ i ] = 0;
		}
		
	}
}


public fw_PlayerPreThink( id )
{
	if ( !zp_get_user_zombie( id ) )
		return PLUGIN_HANDLED;
	
	
	new nbut = pev( id, pev_button );
	new obut = pev( id, pev_oldbuttons );
	new text[ 555 char ];
	if( ( nbut & IN_USE ) && !( obut & IN_USE ) )
	{	
		if( raz_za_kolo[ id ] == 0 )
		{
			new ran;
			ran = random_num( 1, 3 )
			
			if( ran == 1 )
			emit_sound( id, CHAN_AUTO, Si, VOL_NORM, ATTN_NORM , 0, PITCH_NORM );
			
			if( ran == 2 )
			emit_sound( id, CHAN_AUTO, Si2, VOL_NORM, ATTN_NORM , 0, PITCH_NORM );
			
			if( ran == 3 )
			emit_sound( id, CHAN_AUTO, Si3, VOL_NORM, ATTN_NORM , 0, PITCH_NORM );
		
			raz_za_kolo[ id ]++;
		}
		else
		{
			new ran;
			ran = random_num( 1, 3 );
			
			if( ran == 1 )
			client_cmd( id,"spk playaspro_avatar/zrozeni4.wav" );
			
			if( ran == 2 )
			client_cmd( id,"spk playaspro_avatar/zrozeni5.wav" );
			
			if( ran == 3 )
			client_cmd( id,"spk playaspro_avatar/zrozeni6.wav" );	
		}
	}
	if( luk[ id ] )
	{
		if( get_user_weapon( id ) == CSW_SG550 )
		{
			if( ( nbut & IN_ATTACK ) && !( obut & IN_ATTACK ) )
			{
				if( schopnost[ id ] == 5 )
				{
					if( ratanie[ id ] <= 0 )
					{
						ratanie[ id ]++;
						new sip;
						sip = 1 - ratanie[ id ];
						skok[ id ] = 49 - Jumpnum[ id ];
						
						if( kontrola_klasu[ id ] == 7 )
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_INFECT", skok[ id ], sip );
						}
						else
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_INFECT", sip );
						}
						native_playanim( id, anim_idle );
						extra_power( id );
					
					}
				}
				else
				{
					if( ratanie[ id ] <= 5 )
					{
						ratanie[ id ]++;
						new sip;
						sip = 6 - ratanie[ id ];
						skok[ id ] = 49 - Jumpnum[ id ];
						
						if( kontrola_klasu[ id ] == 7 )
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], sip );
						}
						else
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_SIPY", sip );
						}
						
						native_playanim( id, anim_idle );
						extra_power( id );
					
					}
				}
				
			}
			if( ( nbut & IN_RELOAD ) && !( obut & IN_RELOAD ) )
			{
				if( schopnost[ id ] == 5 )
				{
					if( ratanie[ id ] <= 0 )
					{
						ratanie[ id ]++;
						new sip;
						sip = 1 - ratanie[ id ];
						skok[ id ] = 49 - Jumpnum[ id ];
						
						if( kontrola_klasu[ id ] == 7 )
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_INFECT", skok[ id ], sip );
						}
						else
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_INFECT", sip );
						}
						native_playanim( id, anim_idle );
						extra_power( id );
					
					}
				}
				else
				{
					if( ratanie[ id ] <= 5 )
					{
						ratanie[ id ]++;
						new sip;
						sip = 6 - ratanie[ id ];
						skok[ id ] = 49 - Jumpnum[ id ];
						
						if( kontrola_klasu[ id ] == 7 )
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], sip );
						}
						else
						{
							set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
							show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_SIPY", sip );
						}
						
						native_playanim( id, anim_idle );
						extra_power( id );
					
					}
				}
				
			}
			
		}
	}
		
	if( kontrola_klasu[ id ] == 7 && !zp_get_user_nemesis( id ) )
	{	
		new nbut = pev( id, pev_button );
		new obut = pev( id, pev_oldbuttons );
		if ( ( nbut & IN_JUMP ) && !( pev( id, pev_flags ) & FL_ONGROUND ) && !( obut & IN_JUMP ) )
		{
			if( Jumpnum[ id ] < 50 )
			{
				skok[ id ] = 49 - Jumpnum[ id ] ;
				
				if( kontrola_klasu[ id ] == 7 )
				{
					if( schopnost[ id ] == 1 )
					{
						new vsip;
						vsip = 6 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], vsip );
					}
					else if( schopnost[ id ] == 2 )
					{
						new rsip;
						rsip = 6 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], rsip );
					}
					else if( schopnost[ id ] == 3 )
					{
						new bsip;
						bsip = 6 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], bsip );
					}
					else if( schopnost[ id ] == 4 )
					{
						new csip;
						csip = 6 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_SIPY", skok[ id ], csip );
					}
					else if( schopnost[ id ] == 5 )
					{
						new asip;
						asip = 1 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "SKOKY_INFECT", skok[ id ], asip );
					}
					else
					{
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_SKOKY", skok[ id ] );
					}
				}
				else
				{
					if( schopnost[ id ] == 5 )
					{
						new esip;
						esip = 1 - ratanie[ id ];
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_INFECT", esip );
					}	
					else
					{
						set_hudmessage( 93, 163, 93, 0.88, 0.86, 0, 6.0, 12.0 );
						show_hudmessage( id, "%L", LANG_PLAYER, "ONLY_SKOKY", skok[ id ] );
					}
				}
				
				canJump[ id ] = true 
				Jumpnum[ id ]++
			}					
				
		}
		else if( ( nbut & IN_JUMP ) && !( pev( id, pev_flags ) & FL_ONGROUND ) && !( obut & IN_JUMP ) )
		{
			if( Jumpnum[ id ] == 50 || ( nbut & IN_JUMP ) )
			{
				canJump[ id ] = false;
				Jumpnum[ id ] = false;
			}
		}
	}
	if( kontrola_klasu[ id ] == 3 && !zp_get_user_nemesis( id ) )
	{
	
		if( has_jp[ id ] )
		{
			new Float:fAim[ 3 ] , Float:fVelocity[ 3 ];
			VelocityByAim( id , 250 , fAim );
		
			if( !( get_user_button( id ) & IN_JUMP ) )
			{
				fVelocity[ 0 ] = fAim[ 0 ];
				fVelocity[ 1 ] = fAim[ 1 ];
				fVelocity[ 2 ] = fAim[ 2 ];
	
				set_user_velocity( id , fVelocity );
			}
		}
	}	
	return PLUGIN_CONTINUE;
}
public fm_PlayerPostThink( id )
{
	if( kontrola_klasu[ id ] == 7 )
	{	
		if( canJump[ id ] == true )
		{
			new Float:velocity[ 3 ];
			pev( id, pev_velocity, velocity );
			velocity[ 2 ] = random_float( 265.0,285.0 );
			set_pev( id, pev_velocity, velocity );
			
			canJump[ id ] = false;
			
			return FMRES_IGNORED;
		}
	}
	return PLUGIN_CONTINUE
}

public fw_Knife_PrimaryAttack_Post( knife )
{	
	static id;
	id = get_pdata_cbase( knife, m_pPlayer, 4 )
	
	if( zp_get_user_zombie( id ) && !zp_get_user_nemesis( id ) )
	{
		if( is_user_connected( id ) && zp_get_user_zombie_class( id ) == avatar_destroyer )
		{
			static Float:flRate;
			flRate = get_pcvar_float( cvar_pattack_rate );
			
			set_pdata_float( knife, m_flNextPrimaryAttack, flRate, 4 );
			set_pdata_float( knife, m_flNextSecondaryAttack, flRate, 4 );
			set_pdata_float( knife, m_flTimeWeaponIdle, flRate, 4 );
		}
	}
	return HAM_IGNORED;
}

public fw_Knife_SecondaryAttack_Post( knife )
{	
	static id;
	id = get_pdata_cbase( knife, m_pPlayer, 4 )
	
	if( zp_get_user_zombie( id ) && !zp_get_user_nemesis( id ) )
	{
		if( is_user_connected( id ) && zp_get_user_zombie_class( id ) == avatar_destroyer )
		{
			static Float:flRate;
			flRate = get_pcvar_float( cvar_sattack_rate );
			
			set_pdata_float( knife, m_flNextPrimaryAttack, flRate, 4 );
			set_pdata_float( knife, m_flNextSecondaryAttack, flRate, 4 );
			set_pdata_float( knife, m_flTimeWeaponIdle, flRate, 4 );
		
		}
	}
	return HAM_IGNORED;
}
public event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	g_iCurrentWeapon[ id ] = read_data( 2 );
	
	return PLUGIN_CONTINUE;
}

player_healingEffect( id )
{
	new iOrigin[ 3 ];

	get_user_origin( id, iOrigin )

	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_PROJECTILE )
	write_coord( iOrigin[ x ] + random_num( -10, 10 ) );
	write_coord( iOrigin[ y ] + random_num( -10, 10 ) );
	write_coord( iOrigin[ z ] + random_num( 0, 30 ) );
	write_coord( 0 );
	write_coord( 0 );
	write_coord( 15 );
	write_short( gSpr_regeneration );
	write_byte( 1 );
	write_byte( id );
	message_end( );
}

public fw_TakeDamage( victim, inflictor, attacker, Float:damage, damage_bits )
{	
	
	if( victim == attacker || !attacker )
		return HAM_IGNORED;
		
	if( !is_user_connected( attacker ) )
		return HAM_IGNORED;
	
	static button;
	button = pev( attacker, pev_button );
	if( zp_get_user_zombie( attacker ) )
	{
		if( !zp_get_user_nemesis( attacker ) )
		{
			if( g_hasBhop[ attacker ] )
			{
				if( zp_get_user_zombie_class( attacker ) == avatar_destroyer && g_iCurrentWeapon[ attacker ] == CSW_KNIFE && button & IN_ATTACK  )
				{
					a_lot_of_blood( victim );
					player_healingEffect( attacker );
					emit_sound( attacker, CHAN_WEAPON, tlkot, 1.0, ATTN_NORM, 0, PITCH_NORM );
					set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
					ShowSyncHudMsg( attacker, g_hudmsg1, "^n+50 HP^n" ); 
					set_user_health( attacker,get_user_health( attacker )+50 );
				}
				else
				{
					a_lot_of_blood( victim );
					player_healingEffect( attacker );
					emit_sound( attacker, CHAN_WEAPON, tlkot, 1.0, ATTN_NORM, 0, PITCH_NORM );
					set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
					ShowSyncHudMsg( attacker, g_hudmsg1, "^n+100 HP^n" ); 
					set_user_health( attacker,get_user_health( attacker )+100 );
				}
			}
		}
	}
	/*
	else if( get_pdata_int( victim, 75 ) == HIT_HEAD && zp_get_user_zombie_class( attacker ) == avatar_bhop && g_iCurrentWeapon[ attacker ] == CSW_KNIFE )
	{
		set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
		ShowSyncHudMsg( attacker, g_hudmsg1, "^n+100 HP^n" ); 
		set_user_health( attacker,get_user_health( attacker )+100 );
	}*/

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
	
public doplnanie_hp( id, task )
{
		if( kontrola_klasu[ id ] == 5 )
		{
			set_task( 1.0, "doplnanie_hp", id );
			new hp = pev( id, pev_health );
	
			if( hp >= 250 ) return PLUGIN_CONTINUE;
		
			if( is_user_alive( id ) )
			{
				if( hp < 2500 )
				{
					set_pev( id, pev_health, float( hp + 20 ) );
				}
				else
				{
					set_user_health( id, 100 );
				}
			}
		}
		return PLUGIN_CONTINUE;
}
