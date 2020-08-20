/* adamCSzombie */
#include < amxmodx >
#include < fakemeta >
#include < fun >
#include < hamsandwich >
#include < cstrike >
#include < zombieplague >

#define is_valid_player(%1) (1 <= %1 <= 32)

new AK_V_MODEL[ 64 ] = "models/playaspro/v_sg.mdl";
new AK_P_MODEL[ 64 ] = "models/playaspro/p_sg_new.mdl";

new special_v_2[ 64 ] = "models/bluezone/zombie/v_sg.mdl";
new special_w_2[ 64 ] = "models/bluezone/zombie/p_sg.mdl";
new const special_sound_2[ ] = "weapons/ump45-1.wav";

new m_SOUND[ ] = "playaspro/sg.wav";


const m_flTimeWeaponIdle = 	48;
const m_flNextPrimaryAttack = 	46;
const m_flNextSecondaryAttack =	47;

new cvar_dmgmultiplier, cvar_uclip;

new g_itemid, g_itemidnew;

new bool:g_HasAk[ 33 ], bool:g_has_special2[ 33 ];
const m_pPlayer = 		41;

new g_hasZoom[ 33 ];
new bullets[ 33 ];

new m_spriteTexture, cvar_pattack_rate

const Wep_ak47 = ((1<<CSW_UMP45))

public plugin_init( )
{
	
	cvar_dmgmultiplier = register_cvar( "zp_goldenak_dmg_multipliernx", "4" );
	cvar_uclip = register_cvar( "zp_goldenak_unlimited_clip", "0" );
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_ump45", "fw_Knife_PrimaryAttack_Post", 1 );
	
	register_plugin( "[ZP-Extra] Special Gun", "1.3", "adamCSzombie" );

	g_itemid = zp_register_extra_item( "Special Gun \d(Blue)\y", 200, ZP_TEAM_HUMAN );
	g_itemidnew = zp_register_extra_item( "Special Gun \d(Red)\y", 200, ZP_TEAM_HUMAN );

	register_event( "DeathMsg", "Death", "a" );

	register_event( "WeapPickup","checkModel","b","1=19" );

	register_event( "CurWeapon","checkWeapon","be","1=1" );
	register_event( "CurWeapon", "make_tracer", "be", "1=1", "3>0" );

	RegisterHam( Ham_TakeDamage, "player", "fw_TakeDamage" );
	register_forward( FM_CmdStart, "fw_CmdStart" );
	//RegisterHam( Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1 );
	
	cvar_pattack_rate = 		register_cvar( "av_destroyer_attack1_ratxexx", "0.4" );
}

public fw_Knife_PrimaryAttack_Post( knife )
{	
	static id;
	id = get_pdata_cbase( knife, m_pPlayer, 4 )
	
	if( is_user_connected( id ) && g_HasAk[ id ] )
	{
		static Float:flRate;
		flRate = get_pcvar_float( cvar_pattack_rate );
			
		set_pdata_float( knife, m_flNextPrimaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flNextSecondaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flTimeWeaponIdle, flRate, 4 );
	}
	return HAM_IGNORED;
}

public client_connect( id )
{
	g_has_special2[ id ] = false;
	g_HasAk[ id ] = false;
}

public client_disconnect( id )
{
	g_HasAk[ id ] = false;
	g_has_special2[ id ] = false;
}

public Death( )
{
	g_HasAk[ read_data(2) ] = false;
	g_has_special2[ read_data( 2 ) ] = false;
}

public fwHamPlayerSpawnPost( id )
{
	g_HasAk[ id ] = true;
}

public plugin_precache( )
{
	precache_model( special_v_2 );
	precache_model( special_w_2 );
	precache_sound( special_sound_2 );
	precache_model( AK_V_MODEL );
	precache_model( AK_P_MODEL );
	precache_sound( m_SOUND );
	m_spriteTexture = precache_model( "sprites/dot.spr" );
	precache_sound( "weapons/zoom.wav" );
}

public zp_user_infected_post( id ) {
	if( zp_get_user_zombie( id ) ) {
		g_HasAk[ id ] = false;
		g_has_special2[ id ] = false;
	}
}

public checkModel( id )
{
	if( zp_get_user_zombie( id ) )
		return PLUGIN_HANDLED;
	
	new szWeapID = read_data( 2 );
	
	if( g_HasAk[ id ] )
	{
		set_pev( id, pev_viewmodel2, AK_V_MODEL );
		set_pev( id, pev_weaponmodel2, AK_P_MODEL );
	}
	
	if( g_has_special2[ id ] ) {
		set_pev( id, pev_viewmodel2, special_v_2 );
		set_pev( id, pev_weaponmodel2, special_w_2 );
	}
	return PLUGIN_HANDLED;
}

public checkWeapon( id )
{
	new plrClip, plrAmmo, plrWeap[ 32 ];
	new plrWeapId;
	
	plrWeapId = get_user_weapon( id, plrClip , plrAmmo );
	
	if( plrWeapId == CSW_UMP45 && g_HasAk[ id ] )
	{
		checkModel( id );
	}
	else 
	{
		return PLUGIN_CONTINUE;
	}
	
	if( plrClip == 0 && get_pcvar_num( cvar_uclip ) )
	{
		get_weaponname( plrWeapId, plrWeap, 31 );

		give_item( id, plrWeap );
		engclient_cmd( id, plrWeap );
		engclient_cmd( id, plrWeap );
		engclient_cmd( id, plrWeap );
	}
	return PLUGIN_HANDLED;
}



public fw_TakeDamage( victim, inflictor, attacker, Float:damage ) {
	if ( is_valid_player( attacker ) && get_user_weapon( attacker ) == CSW_UMP45 && g_HasAk[ attacker ] ) {
		SetHamParamFloat(4, damage * get_pcvar_float( cvar_dmgmultiplier ) );
	}
	if ( is_valid_player( attacker ) && get_user_weapon( attacker ) == CSW_UMP45 && g_has_special2[ attacker ] ) {
		SetHamParamFloat(4, damage * 2 );
	}
}

public fw_CmdStart( id, uc_handle, seed ) {
	if( !is_user_alive( id ) ) 
		return PLUGIN_HANDLED;
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) ) {
		new szClip, szAmmo;
		new szWeapID = get_user_weapon( id, szClip, szAmmo );
		
		if( szWeapID == CSW_UMP45 && g_HasAk[ id ] == true && !g_hasZoom[ id ] == true ) {
			g_hasZoom[ id ] = true;
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 0 );
			emit_sound( id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 );
		} else if ( szWeapID == CSW_UMP45 && g_HasAk[ id ] == true && g_hasZoom[ id ] )
		{
			g_hasZoom[ id ] = false;
			cs_set_user_zoom( id, CS_RESET_ZOOM, 0 );
			
		}
		
	}
	return PLUGIN_HANDLED;
}


public make_tracer( id )
{
	new clip,ammo;
	new wpnid = get_user_weapon( id,clip,ammo );
	new pteam[ 16 ];
		
	get_user_team( id, pteam, 15 );
		
	if( ( bullets[ id ] > clip ) && ( wpnid == CSW_UMP45 ) && g_HasAk[ id ] ) 
	{
		new vec1[ 3 ], vec2[ 3 ];
		get_user_origin( id, vec1, 1 ); // origin; your camera point.
		get_user_origin( id, vec2, 4 ); // termina; where your bullet goes (4 is cs-only)
			
		emit_sound( id, CHAN_WEAPON, m_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM );
		//BEAMENTPOINTS
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY );
		write_byte( 0 );    //TE_BEAMENTPOINTS 0
		write_coord( vec1[ 0 ] );
		write_coord( vec1[ 1 ] );
		write_coord( vec1[ 2 ] );
		write_coord( vec2[ 0 ] );
		write_coord( vec2[ 1 ] );
		write_coord( vec2[ 2 ] );
		write_short( m_spriteTexture )
		write_byte( 1 ); // framestart
		write_byte( 5 ); // framerate
		write_byte( 2 ); // life
		write_byte( 10 ); // width
		write_byte( 0 ); // noise
		write_byte( 65 );     // r, g, b
		write_byte( 65 );       // r, g, b
		write_byte( 165 );       // r, g, b
		write_byte( 100 ); // brightness
		write_byte( 150 ); // speed
		message_end( );	
	
		bullets[ id ] = clip;
	}
	bullets[ id ] = clip;
	
}

public zp_extra_item_selected( player, itemid ) {
	if( itemid == g_itemid ) {
		if( is_user_hannibal( player ) ) {
			client_print( player, print_center,"Ked si Hannibal nemozes kupit Special Gun!" );
			return ZP_PLUGIN_HANDLED;
		}
		if( g_has_special2[ player ] ) {
			client_print( player, print_center, "Nemozes mat tuto special gunu ked mas modru!" );
			return ZP_PLUGIN_HANDLED;
		}
		if( user_has_weapon( player, CSW_UMP45 ) ) {
			drop_prim( player );
		}
		give_item( player, "weapon_ump45" );
		cs_set_user_bpammo( player, CSW_UMP45, 250 );
		g_HasAk[ player ] = true;
	}
	if( itemid == g_itemidnew ) {
		if( is_user_hannibal( player ) ) {
			client_print( player, print_center, "Ked si Hannibal nemozes kupit Special Gun!" );
			return ZP_PLUGIN_HANDLED;
		}
		if( g_HasAk[ player ] ) {
			client_print( player, print_center, "Nemozes mat tuto special gunu ked mas cervenu!" );
			return ZP_PLUGIN_HANDLED;
		}
		if( user_has_weapon( player, CSW_UMP45 ) ) {
			drop_prim( player );
		}
		give_item( player, "weapon_ump45" );
		cs_set_user_bpammo( player, CSW_UMP45, 250 );
		g_has_special2[ player ] = true;
	}
	return PLUGIN_CONTINUE;
}

stock drop_prim( id ) 
{
	new weapons[ 32 ], num;
	get_user_weapons( id, weapons, num );
	for( new i = 0; i < num; i++ ) 
	{
		if( Wep_ak47 & ( 1<<weapons[ i ] ) ) 
		{
			static wname[ 32 ];
			get_weaponname( weapons[ i ], wname, sizeof wname - 1 );
			engclient_cmd( id, "drop", wname );
		}
	}
}

public plugin_natives( ) {
	register_native( "get_specialgun", "give_specialgun", 1 );
}

public give_specialgun( id )
{
	give_item( id, "weapon_ump45" );
	cs_set_user_bpammo( id, CSW_UMP45, 250 );
	g_HasAk[ id ] = true;
}
