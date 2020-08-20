#include < amxmodx >
#include < engine >
#include < fakemeta >
#include < fakemeta_util >
#include < fun >
#include < hamsandwich >
#include < xs >
#include < cstrike >
#include < zombieplague >
#include < dhudmessage >
#include < weapons >

#define AUTHOR 			"adamCSzombie"
#define PLUGIN 			"[Avatar] Granatomet"
#define VERSION			"0.4"
 
#define ENG_NULLENT             -1
#define EV_INT_WEAPONKEY        EV_INT_impulse
#define m32_WEAPONKEY     	91421
#define TASK_ROUND_SCORE	1234554321

new const GRENADE_MODEL[ ] = 		{ "models/grenade.mdl" };
new const GRENADE_TRAIL[ ] = 		{ "sprites/laserbeam.spr" };
new const GRENADE_EXPLOSION[ ] = 	{ "sprites/zerogxplode.spr" };
new const Fire_Sounds[ ][ ] = 		{ "weapons/m32-1.wav" };
new m32_V_MODEL[ 64 ] = 			"models/gamesites/avatar/v_rocket_launcher.mdl";
new m32_P_MODEL[ 64 ] = 			"models/gamesites/avatar/p_rocket_launcher.mdl";
new m32_W_MODEL[ 64 ] = 			"models/gamesites/avatar/w_rocket_launcher.mdl";

new in_zoom[ 33 ], g_reload[ 33 ], sTrail, sExplo;
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_P90)|(1<<CSW_P90)|(1<<CSW_P90)|(1<<CSW_SG550)|(1<<CSW_P90)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_P90)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_M3)|(1<<CSW_P90)|(1<<CSW_AK47)|(1<<CSW_P90)

new gmsgWeaponList;

new cvar_clip_m32, cvar_m32_ammo, cvar_dmg;
new g_kolo_m32[ 33 ];
new g_has_m32[ 33 ];
new g_MaxPlayers, g_orig_event_m32;
new g_itemid, g_iHudSync;

new g_cooldown[ 33 ], i_cooldown_time[ 33 ], g_shoot[ 33 ], g_overenie[ 33 ];
new Float:nabijanie = 50.0;

#define is_user_valid(%1) (1 <= %1 <= g_MaxPlayers)

public plugin_init( )
{
	new text[ 555 char ];
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_message( get_user_msgid( "DeathMsg" ), "message_DeathMsg" );
	
	register_event( "CurWeapon","CurrentWeapon","be","1=1" );
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m3", "m32AddToPlayer")
	register_forward(FM_CmdStart, "fw_CmdStart")
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_attack" )
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_m3", "fw_attackp", 1 )
	RegisterHam(Ham_Item_Deploy,"weapon_m3", "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_m3", "fw_r")
	RegisterHam(Ham_Weapon_Reload, "weapon_m3", "fw_reload" )
	RegisterHam( Ham_Killed,"player","Hrac_Zomrel",1 );
	register_forward(FM_SetModel, "modelka")
	register_forward(FM_UpdateClientData, "client_data_post", 1)
	register_forward(FM_PlaybackEvent, "PlaybackEvent")
	
	register_logevent( "round_end", 2, "1=Round_End" );
	
	cvar_clip_m32 = 	register_cvar( "av_n_m32_clip", "7" );
	cvar_m32_ammo = 	register_cvar( "av_m32_ammo", "32" );
	cvar_dmg = 		register_cvar( "av_nnn_m32_dmgg","490" );
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "GRANATOMET_NAZOV" );
	g_itemid =  		zp_register_extra_item(text, 200, ZP_TEAM_HUMAN );
	gmsgWeaponList = 	get_user_msgid( "WeaponList" );
	g_MaxPlayers = 		get_maxplayers( );
	g_iHudSync = 		CreateHudSyncObj( );
}

public round_end( )
{
	if( !is_user_alive( read_data( 2 ) ) )
		return PLUGIN_CONTINUE;
		
	if( !is_user_connected( read_data( 2 ) ) )
		return PLUGIN_CONTINUE;
	
	g_kolo_m32[ read_data( 2 ) ] = false;
	
	return PLUGIN_CONTINUE;
}

public plugin_natives( )
{
	register_native( "is_user_granatomet", "native_is_user_granatomet", 1 );
}

public native_is_user_granatomet( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id )
		return -1;
	}
	
	return g_has_m32[ id ];
}
 
public plugin_precache()
{
	precache_model( m32_V_MODEL );
	precache_model( m32_P_MODEL );
	precache_model( m32_W_MODEL );
	precache_model( GRENADE_MODEL );
	
	sTrail = 	precache_model( GRENADE_TRAIL );
	sExplo = 	precache_model( GRENADE_EXPLOSION );
	
	precache_sound( "weapons/m32_after_reload.wav" );
	precache_sound( "weapons/m32_insert.wav" );
	precache_sound( "weapons/m32_start_reload.wav" );
	
	precache_sound( Fire_Sounds[ 0 ] );	
	
	precache_generic( "sprites/weapon_m32.txt" );
	precache_generic( "sprites/zp_cso/640hud75.spr" );
	precache_generic( "sprites/zp_cso/640hud7x.spr" );
	precache_generic( "sprites/zp_cso/scope_grenade.spr" );

	register_clcmd( "weapon_m32", "Hook_Select" );
	register_forward( FM_PrecacheEvent, "fwPrecacheEvent_Post", 1 );
}

public zp_extra_item_selected( id, itemid ) 
{
	if( itemid == g_itemid ) 
	{
		if( get_user_flags( id ) & ADMIN_LEVEL_F )
		{
			if( !zp_has_round_started( ) )
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				client_print( id, print_chat, "%L", LANG_PLAYER, "WAIT_NEW_ROUND" );
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
				return;
			}
			
			if( g_has_m32[ id ] )
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				client_print( id, print_chat, "%L", LANG_PLAYER, "GRANATOMET_HAVE" );
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
				return;
			}
			
			if( is_user_bazooka( id ) )
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				client_print( id, print_center,"%L", LANG_PLAYER, "GRANATOMET_REASON_1" );
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
				return;
			}
			if( g_kolo_m32[ id ] )
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				client_print( id, print_chat,"%L", LANG_PLAYER, "GRANATOMET_ONCE" );
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
				return;
			}
			client_cmd( id, "spk valve/sound/fvox/get_satchel" );
			g_kolo_m32[ id ] = true;
			give_m32( id );
			ChatColor( id, "%L", LANG_PLAYER, "GRANATOMET_BUY" );
		}
		else
		{
			client_cmd( id, "spk valve/sound/buttons/button11" );
			client_print( id, print_chat, "%L", LANG_PLAYER, "ITEM_FOR_PREMIUM" );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
			return;
		}
	}	
}

public Hook_Select( id )
{
	engclient_cmd( id, "weapon_m3" );
	return PLUGIN_HANDLED;
}

public fwPrecacheEvent_Post( type, const name[ ] )
{
	if( equal( "events/m3.sc", name ) )
	{
		g_orig_event_m32 = get_orig_retval( );
		return FMRES_HANDLED;
	}
	
	return FMRES_IGNORED;
}
public client_disconnect( id )
{
	g_has_m32[ id ] = false;
	g_shoot[ id ] = 0;
	g_cooldown[ id ] = false;
	g_overenie[ id ] = false;
	g_kolo_m32[ id ] = false;
	if ( task_exists( id+TASK_ROUND_SCORE ) )
		remove_task( id+TASK_ROUND_SCORE )
	remove_task( id );
}
public client_connect( id )
{
	set_task( 1.0, "score_ammo", id+TASK_ROUND_SCORE, _, _, "b" );
	g_has_m32[ id ] = false;
	g_shoot[ id ] = 0;
	g_cooldown[ id ] = false;
	g_overenie[ id ] = false;
	g_kolo_m32[ id ] = false;
	remove_task( id );
}
 
public modelka( entity, model[ ] )
{
	if( !is_valid_ent( entity ) )
		return FMRES_IGNORED;
	
	static szClassName[ 33 ];
	entity_get_string( entity, EV_SZ_classname, szClassName, charsmax( szClassName ) )
	
	if( !equal( szClassName, "weaponbox" ) )
		return FMRES_IGNORED;
	
	static iOwner;
	iOwner = entity_get_edict( entity, EV_ENT_owner )
	
	if( equal( model, "models/w_m3.mdl" ) )
	{
		static iStoredAugID;
		iStoredAugID = find_ent_by_owner( -1, "weapon_m3", entity )
		
		if( !is_valid_ent( iStoredAugID ) )
			return FMRES_IGNORED;
		
		if( g_has_m32[ iOwner ] )
		{
			
			entity_set_int( iStoredAugID, EV_INT_impulse, 91421 );
			g_has_m32[ iOwner ] = false;
			g_reload[ iOwner ] = 0;
			if( in_zoom[ iOwner ] ){
			set_zoom( iOwner,0 );
			return PLUGIN_CONTINUE;
		}
			entity_set_model( entity, m32_W_MODEL );
			
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public Sprite( id,type )
{
    
	message_begin( MSG_ONE, gmsgWeaponList, { 0,0,0 }, id );
	write_string( type ? "weapon_m32" : "weapon_m3" );
	write_byte( 5 );
	write_byte( 32 );
	write_byte( -1 );
	write_byte( -1 );
	write_byte( 0 );
	write_byte( 5 );
	write_byte( 21 );
	write_byte( 0 );
	message_end( );
}

public give_m32( id )
{
	new iWep2 = give_item( id,"weapon_m3" );
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo( iWep2, get_pcvar_num( cvar_clip_m32 ) );
		cs_set_user_bpammo ( id, CSW_M3, get_pcvar_num( cvar_m32_ammo ) );
	}

	if( in_zoom[ id ] )
	{ 
		cs_set_user_zoom( id, CS_RESET_ZOOM, 1 );
		in_zoom[ id ] = 0;
	}
	Sprite( id,1 );
	set_zoom( id,0 );
	g_reload[ id ] = 0;
	g_shoot[ id ]=  0;
	g_has_m32[ id ] = true;
}
 
public m32AddToPlayer( m32, id )
{
	if( !is_valid_ent( m32 ) || !is_user_connected( id ) ) return HAM_IGNORED;
        
	if( entity_get_int( m32, EV_INT_WEAPONKEY ) == m32_WEAPONKEY )
	{
		g_has_m32[ id ] = true;
		g_reload[ id ] = 0;
		g_shoot[ id ] = 0;
		set_zoom( id, 0 );
		entity_set_int( m32, EV_INT_WEAPONKEY, 0 );
		Sprite( id,1 );
		return HAM_HANDLED;
	}
	if( entity_get_int( m32, EV_INT_WEAPONKEY ) != m32_WEAPONKEY ) Sprite( id,0 );
	
	return HAM_IGNORED;
}
 
public fw_Item_Deploy_Post( weapon_ent )
{
	new owner;
	owner = pev( weapon_ent,pev_owner );
	if( is_user_alive( owner ) && get_user_weapon( owner ) == CSW_M3 )
	{
		set_zoom( owner, 0 );
	}
	static weaponid;
	weaponid = cs_get_weapon_id( weapon_ent )
	if( is_user_alive( owner ) )
	replace_weapon_models( owner, weaponid );
}

public CurrentWeapon( id )
{
	if( read_data( 2 ) != CSW_M3 ) {
		if( g_reload[ id ] ) {
			g_reload[ id ] = false;
			remove_task( id + 1331 );
		}
	}
	replace_weapon_models( id, read_data( 2 ) );
	//remove_task( id );
} 
 
replace_weapon_models( id, weaponid )
{
	switch ( weaponid )
	{
		case CSW_M3:
		{
			if( g_has_m32[ id ] && is_user_alive( id ) )
			{

				set_pev( id, pev_viewmodel2, m32_V_MODEL );
				set_pev( id, pev_weaponmodel2, m32_P_MODEL );
			}
		}
	}
}
 
public client_data_post( Player, SendWeapons, CD_Handle )
{
	if( !is_user_alive( Player ) || ( get_user_weapon( Player ) != CSW_M3 ) || !g_has_m32[ Player ] ) return FMRES_IGNORED;
        
	set_cd( CD_Handle, CD_flNextAttack, halflife_time ( ) + 0.00001 );
	return FMRES_HANDLED;
}

public fw_CmdStart( id, uc_handle, seed ) 
{
	new ammo, clip, weapon = get_user_weapon(id, clip, ammo)
	if( !g_has_m32[ id ] || weapon != CSW_M3 || !is_user_alive( id ) )
		return;

	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) ) {
		if( !in_zoom[ id ] && !g_reload[ id ] ) set_zoom( id,1 );
		else set_zoom( id,0 );
	}
}

public fw_attack( wpn ) {
	if( g_has_m32[ pev( wpn, pev_owner ) ] ) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public fw_attackp( wpn ) {
	new id = pev( wpn, pev_owner ), clip, bpammo;
	get_user_weapon( id, clip, bpammo );
	if( g_has_m32[ id ] ) {
		if( clip > 0 ) {
			if( g_reload[ id ] ) {
				UTIL_PlayWeaponAnimation( id, 4 );
				set_pdata_float( id, 83, 1.0 );
				remove_task( id + 1331 );
				g_reload[ id ] = false;
				return;
			}

			UTIL_PlayWeaponAnimation( id,random_num( 1,2 ) )
			emit_sound( id, CHAN_WEAPON, Fire_Sounds[ 0 ], 1.0, ATTN_NORM, 0, PITCH_NORM );
			FireGrenade( id );
			MakeRecoil( id );

			set_pdata_float( id, 83, 0.6 );
		}
	}
}

public score_ammo( id )
{
	id -= TASK_ROUND_SCORE;
	
	if( g_has_m32[ id ] )
	{
		if( g_shoot[ id ] == 6 )
		{
			if( !g_overenie[ id ] )
			{
				g_cooldown[ id ] = 1;
				g_overenie[ id ] = true;
				i_cooldown_time[ id ] = floatround( nabijanie );		
				set_task( 1.0, "ShowHUD", id, _, _, "a",i_cooldown_time[ id ] );
			}
		}
		else
		{
			new naboje = 6;
			naboje = naboje - g_shoot[ id ];
			set_dhudmessage( 65, 165, 65, 0.75, 0.92, 0, 6.0, 1.1, 0.0, 0.0, -1 );
			show_dhudmessage( id,"%L", LANG_PLAYER, "GRANATOMET_NUM", naboje )
		}
	}
}

public MakeRecoil( id )
{
	if( !is_user_alive( id ) )
		return;

	if( zp_get_user_zombie( id ) )
		return;

	if( !g_has_m32[ id ] )
		return;

	static Float:punchAngle[ 3 ];
	punchAngle[ 0 ] = float(random_num( -1 * 400, 400 ) ) / 100.0;
	punchAngle[ 1 ] = float(random_num( -1 * 700, 700 ) ) / 100.0;
	punchAngle[ 2 ] = 0.0;
	set_pev( id, pev_punchangle, punchAngle );
}

public FireGrenade( id )
{
	if( g_shoot[ id ] != 6 )
	{
		new ammo, clip;
		get_user_weapon( id, clip, ammo );
		
		g_shoot[ id ] += 1;
		
		static wep;
		wep = find_ent_by_owner( -1, "weapon_m3", id );
		cs_set_weapon_ammo( wep, clip-1 );
		
		new Float:origin[ 3 ],Float:velocity[ 3 ],Float:angles[ 3 ];
		
		engfunc( EngFunc_GetAttachment, id, 0, origin,angles );
		pev( id,pev_angles,angles );
		new ent = create_entity( "info_target" );
		set_pev( ent, pev_classname, "m32_grenade" );
		set_pev( ent, pev_solid, SOLID_BBOX );
		set_pev( ent, pev_movetype, MOVETYPE_TOSS );
		set_pev( ent, pev_mins, { -0.1, -0.1, -0.1 } );
		set_pev( ent, pev_maxs, { 0.1, 0.1, 0.1 } );
		entity_set_model( ent, GRENADE_MODEL );
		set_pev( ent, pev_origin, origin );
		set_pev( ent, pev_angles, angles );
		set_pev( ent, pev_owner, id );
		velocity_by_aim( id, in_zoom[ id ]? 1400 : 1000 , velocity );
		set_pev( ent, pev_velocity, velocity );
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( TE_BEAMFOLLOW ); 
		write_short( ent ); 
		write_short( sTrail );
		write_byte( 20 ); // 10
		write_byte( 3 );
		write_byte( 255 ); 
		write_byte( 255 ); 
		write_byte( 255 ); 
		write_byte( 50 );
		message_end( ); 
	
		return PLUGIN_CONTINUE;
	}
	else
	{
		if( !g_overenie[ id ] )
		{
			ChatColor( id, "%L", LANG_PLAYER, "GRANATOMET_RELOAD" );
			client_cmd( id, "spk valve/sound/buttons/button11" );
		}
	}
	
	return PLUGIN_CONTINUE;
}	

public pfn_touch( ptr, ptd )
{
	if( pev_valid( ptr ) )
	{	
		static classname[ 32 ];
		pev( ptr, pev_classname, classname, 31 );
		
		if( equal( classname, "m32_grenade" ) )
		{
			new Float:originF[ 3 ];
			pev( ptr, pev_origin, originF );
			engfunc( EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0 );
			write_byte( TE_WORLDDECAL );
			engfunc( EngFunc_WriteCoord, originF[ 0 ] );
			engfunc( EngFunc_WriteCoord, originF[ 1 ] );
			engfunc( EngFunc_WriteCoord, originF[ 2 ] );
			write_byte( engfunc( EngFunc_DecalIndex,"{scorch3" ) );
			message_end( );

			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( TE_EXPLOSION );
			engfunc( EngFunc_WriteCoord, originF[ 0 ] );
			engfunc( EngFunc_WriteCoord, originF[ 1 ] );
			engfunc( EngFunc_WriteCoord, originF[ 2 ] + 30.0 );
			write_short( sExplo );  
			write_byte( 25 );
			write_byte( 35 );
			write_byte( 0 );
			message_end( );
			
			new owner = pev( ptr, pev_owner );
			
			new a = FM_NULLENT;
		
			while( ( a = find_ent_in_sphere( a, originF,300.0 ) ) != 0 && !is_user_shielded( a ) ) 
			{
				if( a != owner && a != ptr && pev( a, pev_takedamage ) != DAMAGE_NO ) 
				{				
					ExecuteHamB( Ham_TakeDamage, a ,owner ,owner,  get_pcvar_float( cvar_dmg ), DMG_BULLET );
				}
				
				set_pev( ptr, pev_flags, FL_KILLME );
			}
		}
	}
		
}	

public Hrac_Zomrel( victim,attacker,shouldgibc ) {
	if( g_has_m32[ victim ] ) {
		g_kolo_m32[ victim ] = false;
		g_has_m32[ victim ] = false;
	}
}

public zp_user_humanized_post( id, survivor )
{
	if( zp_get_user_survivor( id ) )
	{
		if( g_has_m32[ id ] )
		{
			g_kolo_m32[ id ] = false;
			g_has_m32[ id ] = false;
		}
	}
}
 
public PlaybackEvent( flags, invoker, eventid, Float:delay, Float:origin[ 3 ], Float:angles[ 3 ], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2 )
{
	if ( ( eventid != g_orig_event_m32 ) ) return FMRES_IGNORED;
	if ( !( 1 <= invoker <= g_MaxPlayers ) ) return FMRES_IGNORED;

	playback_event( flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2 );
	return FMRES_SUPERCEDE;
}


public message_DeathMsg( msg_id, msg_dest, id )
{
	static szTruncatedWeapon[ 33 ], iAttacker, iVictim;
        
	get_msg_arg_string( 4, szTruncatedWeapon, charsmax( szTruncatedWeapon ) )
        
	iAttacker = get_msg_arg_int( 1 );
	iVictim = get_msg_arg_int( 2 );
		
	if( !is_user_connected( iAttacker ) || iAttacker == iVictim ) return PLUGIN_CONTINUE;
        
	if( get_user_weapon( iAttacker ) == CSW_M3 )
	{
		if( g_has_m32[ iAttacker ] )
		{
			set_msg_arg_string( 4, "grenade" );
		}
	}
                
	return PLUGIN_CONTINUE;
}
 
stock UTIL_PlayWeaponAnimation( const Player, const Sequence )
{
	set_pev( Player, pev_weaponanim, Sequence );
        
	message_begin( MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player );
	write_byte( Sequence );
	write_byte( 2 ) ;
	message_end( );
}

public fw_r( wpn ) {
	if( g_has_m32[ pev( wpn, pev_owner ) ] ) {
		fw_reload( wpn );
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public fw_reload( weapon ) 
{
	new id = pev( weapon, pev_owner )
	new clip, bpammo;
	get_user_weapon( id, clip, bpammo )
	if( g_has_m32[ id ] && clip < 7 && bpammo > 0 ) {
		if( !task_exists( id + 1331 ) ) set_task( 0.1, "reload", id + 1331 )
		}
	if( in_zoom[ id ] )
	{
		cs_set_user_zoom( id, CS_RESET_ZOOM, 1 );
		in_zoom[ id ] = 0;
	}
	return HAM_IGNORED;
}

public reload( id ) 
{
	id -= 1331;
	if( !g_overenie[ id ] )
	{
		new clip, bpammo, weapon = find_ent_by_owner( -1, "weapon_m3", id );
		get_user_weapon(id, clip, bpammo );
		if( !g_reload[ id ] ) 
		{
				set_zoom( id,0 );
				UTIL_PlayWeaponAnimation( id, 5 );
				g_reload[ id ] = 1;
				set_pdata_float( id, 83, 1.0, 5 );
				set_task( 1.0, "reload", id+1331 );
				return;
		}
	
		if( in_zoom[ id ] )
		{
			cs_set_user_zoom( id, CS_RESET_ZOOM, 1 );
			in_zoom[ id ] = 0;
		}
		
		if( clip > 6 || bpammo < 1 ) 
		{
			UTIL_PlayWeaponAnimation( id, 4 );
			g_reload[ id ] = 0;
			set_pdata_float( id, 83, 1.5, 5 );
			return;
		}
		cs_set_user_bpammo( id, CSW_M3, bpammo - 1 );
		cs_set_weapon_ammo( weapon, clip = 7 );
		set_pdata_float( id, 83, 1.0, 5 );
		UTIL_PlayWeaponAnimation( id, 3 );
		set_task( 1.0, "reload", id+1331 );
	}
}
 
stock drop_weapons( id, dropwhat )
{
	static weapons[ 32 ], num, i, weaponid;
	num = 0;
	get_user_weapons( id, weapons, num )
	
	for( i = 0; i < num; i++ )
	{
		weaponid = weapons[ i ]; 
		
		if( dropwhat == 1 && ( ( 1<< weaponid ) & PRIMARY_WEAPONS_BIT_SUM ) )
		{
			static wname[ 32 ];
			get_weaponname( weaponid, wname, sizeof wname - 1 );
			engclient_cmd( id, "drop", wname );
		}
	}
}

stock set_zoom( index,type )
{
	if( type == 0 )
	{
		if( in_zoom[ index ] == 1 )
		{
			cs_set_user_zoom( index, CS_SET_AUGSG552_ZOOM, 1 );

			in_zoom[ index ] = 0;
			emit_sound( index, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 );
		}
	}
	if(type==1)
	{
		if( in_zoom[index] == 0 )
		{
			cs_set_user_zoom( index, CS_RESET_ZOOM, 1 );

			in_zoom[ index ] = 1;
			emit_sound( index, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100 );
		}
	}
}

stock ChatColor( const id, const input[], any:... )
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	
	
	if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
	{
		for( new i = 0; i < count; i++ )
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

public ShowHUD( id )
{
	if( zp_get_user_zombie( id ) && !is_user_alive( id ) )
		return;
	new clip, bpammo, weapon = find_ent_by_owner( -1, "weapon_m3", id );
	get_user_weapon(id, clip, bpammo );
	
	if( g_has_m32[ id ] )
	{
		if( i_cooldown_time[ id ] == 1 )
		{
			g_shoot[ id ] = 0;
			g_overenie[ id ] = false;
			set_task( 0.1, "reload" );
			client_cmd( id, "spk valve/sound/buttons/button7" );
			client_print( id, print_center, "%L", LANG_PLAYER, "GRANATOMET_CAN" );
		}
			
		if( i_cooldown_time[ id ] >= 0 )
		{
			
			i_cooldown_time[ id ] = i_cooldown_time[ id ] - 1;
			set_hudmessage( 65, 165, 65, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1 );
			cs_set_weapon_ammo( weapon, clip = 0 );
			ShowSyncHudMsg( id, g_iHudSync, "%L", LANG_PLAYER, "GRANATOMET_RE", i_cooldown_time[ id ] );
			
		}
	}
	else
	{
		g_shoot[ id ] = 0;
		g_cooldown[ id ] = false;
		g_overenie[ id ] = false;
		remove_task( id );
	}
}
