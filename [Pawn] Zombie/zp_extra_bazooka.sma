#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < engine >
#include < hamsandwich >
#include < zombieplague >
#include < dhudmessage >
#include < xs >
#include < weapons >

#define PLUGIN 		"[ZP-Extra] Bazooka s Nabijanim"
#define VERSION 	"0.5"
#define AUTHOR 		"adamCSzombie"
#define EXTRA_ITEM	"Bazooka \w[\rVIP\w]"

#define 		CUSTOM_MODEL

#if defined ADMIN_BAZOOKA
#define BAZOOKA_ACCESS ADMIN_LEVEL_IMMUNITY
#endif

#define TASK_SEEK_CATCH 	9000
#define fm_is_valid_ent(%1) 	pev_valid(%1)

const Float:HUD_EVENT_X = -1.0;
const Float:HUD_EVENT_Y = 0.05;

new g_iHudSync;

#if defined CUSTOM_MODEL
static const mrocket[ ] = "models/rpgrocket.mdl";
static const mrpg_w[ ] = "models/w_rpg.mdl";
static const mrpg_v[ ] = "models/v_rpg.mdl";
static const mrpg_p[ ] = "models/p_rpg.mdl";
#else
static const mrocket[] = "models/rpgrocket.mdl";
static const mrpg_w[] = "models/w_rpg.mdl";
static const mrpg_v[] = "models/v_rpg.mdl";
static const mrpg_p[] = "models/p_rpg.mdl";
#endif
static const sfire[ ] 	= "weapons/rocketfire1.wav";
static const sfly[ ] 	= "weapons/nuke_fly.wav";
static const shit[ ] 	= "weapons/mortarhit.wav";
static const spickup[ ] 	= "items/gunpickup2.wav";
static const reload[ ] 	= "items/9mmclip2.wav";

#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

new g_itemid;


new pcvar_delay, pcvar_maxdmg, pcvar_radius, pcvar_map, pcvar_speed,
	pcvar_dmgforpacks, pcvar_award, pcvar_count, pcvar_speed_homing,
	pcvar_speed_camera;

new rocketsmoke, white, dmgcount[ 33 ], user_controll[ 33 ], mode[ 33 ], bool:g_hasbazooka[ 33 ], bool:CanShoot[ 33 ];

new Float:lastSwitchTime[ 33 ];

new gmsg_screenshake, gmsg_death, gmsg_damage, Saytxt

new g_cooldown[ 33 ], i_cooldown_time[ 33 ], g_maxplayers, g_bazooka_kolo[ 33 ], g_pocet_killov[ 33 ];

new Float:nabijanie = 50.0; // Nabijanie Bazooky

#define BAZOOKA_DELAY		"50"
#define BAZOOKA_DAMAGE		"2500"
#define BAZOOKA_RADIUS		"450"
#define BAZOOKA_MAP		"1"
#define BAZOOKA_REWARD		"1"
#define BAZOOKA_SPEED		"1000"
#define BAZOOKA_HOMING		"1000"
#define BAZOOKA_CAMERA		"1000"
#define BAZOOKA_COUNT		"4"
#define SWITCH_TIME		 0.5

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
        
	RegisterHam( Ham_Spawn, "player", "Spawn", 1 );
	
	g_iHudSync = CreateHudSyncObj( );
	
	pcvar_delay 		= register_cvar( "av_bazooka_delay", BAZOOKA_DELAY );
	pcvar_maxdmg 		= register_cvar( "av_bazooka_damage_nn", BAZOOKA_DAMAGE );
	pcvar_radius 		= register_cvar( "av_bazooka_radius", BAZOOKA_RADIUS );
	pcvar_map 		= register_cvar( "av_bazooka_map", BAZOOKA_MAP );
	pcvar_award 		= register_cvar( "av_bazooka_awardpacks", BAZOOKA_REWARD );
	pcvar_speed 		= register_cvar( "av_bazooka_speed", BAZOOKA_SPEED );
	pcvar_speed_homing 	= register_cvar( "av_bazooka_homing_speed", BAZOOKA_HOMING );
	pcvar_speed_camera 	= register_cvar( "av_bazooka_camera_speed", BAZOOKA_CAMERA );
	pcvar_count 		= register_cvar( "av_bazooka_count", BAZOOKA_COUNT );
	pcvar_dmgforpacks 	= get_cvar_pointer( "zp_human_damage_reward" );
	
	gmsg_screenshake 	= get_user_msgid( "ScreenShake" );
	gmsg_death 		= get_user_msgid( "DeathMsg" );
	gmsg_damage 		= get_user_msgid( "Damage" );
	Saytxt 			= get_user_msgid( "SayText" );
       
	g_itemid = zp_register_extra_item( EXTRA_ITEM, 160, ZP_TEAM_HUMAN );
	
	register_event( "CurWeapon","switch_to_knife","be","1=1","2=29" );
	register_event( "HLTV", "event_HLTV", "a", "1=0", "2=0" );
	
	register_clcmd( "drop", "drop_call" );
	register_concmd( "av_gamesites_bazooka", "give_bazooka", ADMIN_IMMUNITY, "<name/@all> pridava bazooku hracovi." );
	
	register_forward( FM_PlayerPreThink, "client_PreThink" );
	register_forward( FM_Touch, "fw_touch" );
	register_forward( FM_CmdStart, "fw_CmdStart" );
	
	g_maxplayers = get_maxplayers( );
	
}

public plugin_natives( )
{
	register_native( "nacitat_bazooku", "set_hudnacitania", 1 );
	register_native( "is_user_bazooka", "native_is_user_bazooka", 1 );
}

public native_is_user_bazooka( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id )
		return -1;
	}
	
	return g_hasbazooka[ id ];
}

public set_hudnacitania( id )
{
	if( g_hasbazooka[ id ] )
	{
		CanShoot[ id ] = false;
		g_cooldown[ id ] = 1;
		i_cooldown_time[ id ] = floatround( nabijanie );		
		set_task( 1.0, "ShowHUD", id, _, _, "a",i_cooldown_time[ id ] );
		set_task( 0.0 + get_pcvar_num(pcvar_delay), "rpg_reload", id );
	}
}


 
public client_putinserver( id )
{
	g_bazooka_kolo[ id ] = false;
	mode[ id ] = 1;
	g_hasbazooka[ id ] = false;
	CanShoot[ id ] = false;
}

public plugin_cfg( )
{
	new cfgdirecction[ 32 ]
	get_configsdir( cfgdirecction, sizeof cfgdirecction - 1 );

	server_cmd( "exec %s/zp_bazooka_modes.cfg", cfgdirecction );
}

public event_HLTV( )
{
	new rpg_temp = engfunc( EngFunc_FindEntityByString, -1, "classname", "rpg_temp" );
	
	while( rpg_temp > 0) 
	{
		engfunc( EngFunc_RemoveEntity, rpg_temp );
		rpg_temp = engfunc( EngFunc_FindEntityByString, -1, "classname", "rpg_temp" );
	}
        
	if ( get_pcvar_num( pcvar_map ) ) return;
        
	for( new id = 1; id <= 32; id++ )
	{
		g_hasbazooka[ id ] = false;
		
		#if defined ADMIN_BAZOOKA
		set_task( 1.0, "AdminBazooka", id );
		#endif
	}
}
/* Extra Item */
					
public zp_extra_item_selected( player, itemid )
{
	if( itemid == g_itemid )
	{
		if( !zp_has_round_started( ) )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "Pockaj, nez zacne kolo!" );
			return ZP_PLUGIN_HANDLED;
		}
			
		if( g_bazooka_kolo[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			ChatColor( player, "!g[ZP]!y Mozes kupit Bazooku iba jeden krat za kolo!" );
			return ZP_PLUGIN_HANDLED;
		}
			
		if ( g_hasbazooka[ player ] )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			ChatColor( player, "!g[ZP]!y Uz mas zakupenu bazooku!" );
			return ZP_PLUGIN_HANDLED;		
		}
		else if( is_user_hannibal( player ) )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print(player, print_center,"Hannibal nemozes si zakupit Bazook!" );
			return PLUGIN_CONTINUE;
		}
		else if ( baz_count( ) > get_pcvar_num( pcvar_count ) )
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			ChatColor( player, "!g[ZP]!y Uz mas zakupenu bazooku!" );
			return ZP_PLUGIN_HANDLED;
		}
		else 
		{
			g_bazooka_kolo[ player ] = true;
			g_hasbazooka[ player ] = true;
			CanShoot[ player ] = true;
			g_cooldown[ player ] = 0;
			ChatColor( player, "!g[ZP]!y Mas pripravenu bazooku!" );
			emit_sound( player, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		}
	}
	return PLUGIN_CONTINUE;
}
public give_bazooka( id, level, cid )
{
	if ( !cmd_access( id,level,cid,1 ) ) 
	{
		console_print( id,"K prikazu nemas pristup" );
		return;
	}
	if ( read_argc() > 2 ) 
	{
		console_print( id,"" );
		return;
	}
	
	new arg1[ 32 ];
	read_argv( 1, arg1, sizeof(arg1) - 1 );
	new player = cmd_target( id, arg1, 10 );
	
	if ( !player ) 
	{
		if ( arg1[0] == '@' ) 
		{
			for ( new i = 1; i <= 32; i++ ) 
			{
				if ( is_user_connected( i ) && !g_hasbazooka[ i ] && !zp_get_user_zombie( i ) ) 
				{
					g_bazooka_kolo[ id ] = true;
					g_hasbazooka[ id ] = true;
					CanShoot[ id ] = true;
					g_cooldown[ id ] = 0;
					emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
				}
			}
		} 
		else 
		{
			client_print( id, print_center, "" );
			return;
		}
	} 
	else if ( !g_hasbazooka[ player ] && !zp_get_user_zombie( player ) ) 
	{
		g_bazooka_kolo[ id ] = true;
		g_hasbazooka[ id ] = true;
		CanShoot[ id ] = true;
		g_cooldown[ id ] = 0;
		emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}
 
public zp_user_infected_post( id, infector )
{
	if ( g_hasbazooka[ id ] )
	{
		g_cooldown[ id ] = 0;
		remove_task( id );
		CanShoot[ id ] = false;
		g_pocet_killov[ id ] = 0;
		g_hasbazooka[ id ] = false;
		i_cooldown_time[ id ] = 0;
		drop_rpg_temp( id );
	}
}
		
public zp_user_humanized_post( id, survivor )
{
	#if defined ADMIN_BAZOOKA
	if ( get_user_flags( id ) & BAZOOKA_ACCESS )
	{
		g_hasbazooka[ id ] = true;
		CanShoot[ id ] = true;
		g_cooldown[ id ] = false;
	}
	#endif
}
 
public plugin_precache()
{
	precache_model( mrocket );        
 
	precache_model( mrpg_w );
	precache_model( mrpg_v );
	precache_model( mrpg_p );
 
	precache_sound( sfire );
	precache_sound( sfly );
	precache_sound( shit );
	precache_sound( spickup );
	precache_sound( reload );
        
	rocketsmoke = precache_model( "sprites/smoke.spr" );
	white = precache_model( "sprites/white.spr" );
}
 
public switch_to_knife( id )
{
	if ( !is_user_alive( id ) ) return;
 
	if ( g_hasbazooka[ id ] )
	{
		set_pev( id, pev_viewmodel2, mrpg_v );
		set_pev( id, pev_weaponmodel2, mrpg_p );
	}
}

fire_rocket( id ) 
{
	if ( get_user_weapon( id ) == CSW_KNIFE ) switch_to_knife( id );
	if (!CanShoot[ id ] ) return;

	new ent = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
	
	if ( !pev_valid( ent ) || !is_user_alive( id ) )
		return;
 
	new data[ 1 ];
	data[ 0 ] = id;
	CanShoot[ id ] = false;
	set_pev( id, pev_viewmodel2, mrpg_v );
	set_pev( id, pev_weaponmodel2, mrpg_p );
	i_cooldown_time[ id ] = floatround( nabijanie );		
	set_task( 1.0, "ShowHUD", id, _, _, "a",i_cooldown_time[ id ] );
	g_cooldown[ id ] = 1;
	set_task( 0.0 + get_pcvar_num(pcvar_delay), "rpg_reload", id );
 
	new Float:StartOrigin[ 3 ], Float:Angle[ 3 ];
	pev( id, pev_origin, StartOrigin );
	pev( id, pev_angles, Angle );
	
	set_pev( ent, pev_classname, "rpgrocket" );
	engfunc( EngFunc_SetModel, ent, mrocket );
	set_pev( ent, pev_mins, { -1.0, -1.0, -1.0 } );
	set_pev( ent, pev_maxs, { 1.0, 1.0, 1.0 } );
	engfunc( EngFunc_SetOrigin, ent, StartOrigin );
	set_pev( ent, pev_angles, Angle );

 
	set_pev( ent, pev_solid, 2 );
	set_pev( ent, pev_movetype, 5 );
	set_pev( ent, pev_owner, id );
 
	new Float:fAim[ 3 ],Float:fAngles[ 3 ],Float:fOrigin[ 3 ];
	velocity_by_aim( id,64,fAim );
	vector_to_angle( fAim,fAngles );
	pev( id,pev_origin,fOrigin );
        
	fOrigin[ 0 ] += fAim[ 0 ]
	fOrigin[ 1 ] += fAim[ 1 ]
	fOrigin[ 2 ] += fAim[ 2 ]
 
	new Float:nVelocity[ 3 ];
	if ( mode[ id ] == 1 )
		velocity_by_aim( id, get_pcvar_num( pcvar_speed ), nVelocity );
	else if ( mode[ id ] == 2 )
		velocity_by_aim( id, get_pcvar_num( pcvar_speed_homing ), nVelocity );
	else if ( mode[ id ] == 3 )
		velocity_by_aim( id, get_pcvar_num( pcvar_speed_camera ), nVelocity );
		
	set_pev( ent, pev_velocity, nVelocity );
	entity_set_int( ent, EV_INT_effects, entity_get_int( ent, EV_INT_effects ) )

 
	emit_sound( ent, CHAN_WEAPON, sfire, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	emit_sound( ent, CHAN_VOICE, sfly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
        
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( 22 );
	write_short( ent );
	write_short( rocketsmoke );
	write_byte( 50 );
	write_byte( 3 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 255 );
	write_byte( 255 );
	message_end();

	if ( mode[ id ] == 2 ) 
	{
		set_task( 0.5, "rpg_seek_follow", ent + TASK_SEEK_CATCH, _, _, "b" );
	}
	else if ( mode[ id ] == 3 ) 
	{
		if ( is_user_alive( id ) )
		{
			entity_set_int( ent, EV_INT_rendermode, 1 )
			attach_view( id, ent )
			user_controll[ id ] = ent
		}
	} 
	
}
/* Nabitie Bazooky */
public rpg_reload( id )
{
	if ( !g_hasbazooka[ id ] ) return;
	
	if ( get_user_weapon( id ) == CSW_KNIFE && !is_user_hannibal( id ) ) switch_to_knife( id );
	{
		CanShoot[ id ] = true;
		g_cooldown[ id ] = 0;
		client_print( id, print_center, "Bazooka je nabita!" );
		emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
	}
}
 
public fw_touch( ent, touched )
{
	if ( !pev_valid( ent ) ) 
		return FMRES_IGNORED;
	
	static entclass[ 32 ];
	pev( ent, pev_classname, entclass, 31 );
	
	if ( equali( entclass, "rpg_temp" ) )
	{
		
		if( is_user_hannibal( touched ) )
		{
			return FMRES_IGNORED;
		}
		
		if( g_hasbazooka[ touched ] )
		{
			//remove_task( touched )
			return FMRES_IGNORED;
		}
		static touchclass[ 32 ];
		pev( touched, pev_classname, touchclass, 31 );
		if ( !equali( touchclass, "player" ) ) return FMRES_IGNORED;
                
		if( !is_user_alive( touched ) || zp_get_user_zombie( touched ) ) 
		{
			return FMRES_IGNORED;
		}
		emit_sound( touched, CHAN_VOICE, spickup, 1.0, ATTN_NORM, 0, PITCH_NORM );
		g_hasbazooka[ touched ] = true;
		g_cooldown[ touched ] = 1;
		i_cooldown_time[ touched ] = floatround( nabijanie );		
		set_task( 1.0, "ShowHUD", touched, _, _, "a",i_cooldown_time[ touched ] );
		set_task( 0.0 + get_pcvar_num( pcvar_delay ), "rpg_reload", touched );
		
		engfunc( EngFunc_RemoveEntity, ent );
        
		return FMRES_HANDLED;
	}
	else if ( equali( entclass, "rpgrocket" ) )
	{
		new Float:EndOrigin[ 3 ];
		pev( ent, pev_origin, EndOrigin );
		new NonFloatEndOrigin[ 3 ];
		NonFloatEndOrigin[ 0 ] = floatround( EndOrigin[ 0 ] );
		NonFloatEndOrigin[ 1 ] = floatround( EndOrigin[ 1 ] );
		NonFloatEndOrigin[ 2 ] = floatround( EndOrigin[ 2 ] );
	
		emit_sound( ent, CHAN_WEAPON, shit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		emit_sound( ent, CHAN_VOICE, shit, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		
		make_explosion_effects( ent, 1, 1, 0, 0, 1 )

		new maxdamage = get_pcvar_num( pcvar_maxdmg );
		new damageradius = get_pcvar_num( pcvar_radius );
        
		new PlayerPos[ 3 ], distance, damage;
		for ( new i = 1; i <= 32; i++ ) 
		{
			if ( is_user_alive( i ) ) 
			{       
				new id = pev( ent, pev_owner )
				
				if  ( ( zp_get_user_zombie( id ) ) || ( ( zp_get_user_nemesis( id ) ) ) )
				if ( ( zp_get_user_zombie( i ) ) || ( zp_get_user_nemesis( i ) ) ) continue;
                                                
				if  ( ( !zp_get_user_zombie( id ) ) && ( !zp_get_user_nemesis( id ) ) ) 
				if ( ( !zp_get_user_zombie( i ) ) && ( !zp_get_user_nemesis( i ) ) ) continue;
                                                
				get_user_origin( i, PlayerPos );
                
				distance = get_distance( PlayerPos, NonFloatEndOrigin );
				
				if ( distance <= damageradius )
				{ 
					make_explosion_effects( i, 0, 0, 0, 1, 0 );
					if( !zp_get_user_zombie( id ) ) { 
						damage = maxdamage - floatround( floatmul( float( maxdamage ), floatdiv( float( distance ), float( damageradius ) ) ) );
						new attacker = pev( ent, pev_owner );
         
						baz_damage( i, attacker, damage, "bazooka" );
					}
				}
			}
		}
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte( 21 );
		write_coord( NonFloatEndOrigin[ 0 ] );
		write_coord( NonFloatEndOrigin[ 1 ] );
		write_coord( NonFloatEndOrigin[ 2 ] );
		write_coord( NonFloatEndOrigin[ 0 ] );
		write_coord( NonFloatEndOrigin[ 1 ] );
		write_coord( NonFloatEndOrigin[ 2 ] + 320 );
		write_short( white );
		write_byte( 0 );
		write_byte( 0 );
		write_byte( 16 );
		write_byte( 128 );
		write_byte( 0 );
		write_byte( 255 );
		write_byte( 255 );
		write_byte( 192 );
		write_byte( 128 );
		write_byte( 0 );
		message_end( );
		
		attach_view( entity_get_edict( ent, EV_ENT_owner ), entity_get_edict( ent, EV_ENT_owner ) );
		user_controll[entity_get_edict( ent, EV_ENT_owner )] = 0;
		remove_entity( ent );
                
		return FMRES_HANDLED;
	}
	return FMRES_IGNORED;
}
 
public drop_call( id )
{
	if ( g_hasbazooka[ id ] && get_user_weapon( id ) == CSW_KNIFE )
	{
		g_cooldown[ id ] = 0;
		remove_task( id );
		CanShoot[ id ] = false;
		g_pocet_killov[ id ] = 0;
		drop_rpg_temp( id );
		g_hasbazooka[ id ] = false;
		i_cooldown_time[ id ] = 0;
		set_pev( id, pev_viewmodel2, "models/v_knife.mdl" );
		set_pev( id, pev_weaponmodel2, "models/p_knife.mdl" );
		return PLUGIN_HANDLED; 
	}
	return PLUGIN_CONTINUE;
}
 
drop_rpg_temp( id ) 
{
	new Float:fAim[ 3 ] , Float:fOrigin[ 3 ];
	velocity_by_aim( id , 64 , fAim );
	pev( id , pev_origin , fOrigin );
 
	fOrigin[ 0 ] += fAim[ 0 ];
	fOrigin[ 1 ] += fAim[ 1 ];
 
	new rpg = engfunc( EngFunc_CreateNamedEntity, engfunc( EngFunc_AllocString, "info_target" ) );
 
	set_pev( rpg, pev_classname, "rpg_temp" );
	engfunc( EngFunc_SetModel, rpg, mrpg_w );
 
	set_pev( rpg, pev_mins, { -16.0, -16.0, -16.0 } );
	set_pev( rpg, pev_maxs, { 16.0, 16.0, 16.0 } );
 
	set_pev( rpg , pev_solid , 1 );
	set_pev( rpg , pev_movetype , 6 );
 
	engfunc( EngFunc_SetOrigin, rpg, fOrigin );
	
	/*g_hasbazooka[ id ] = false;
	g_cooldown[ id ] = 0;
	CanShoot[ id ] = false;
	i_cooldown_time[ id ] = 0;*/
}
 
baz_damage( id, attacker, damage, weaponDescription[ ] )
{
	if ( pev( id, pev_takedamage ) == DAMAGE_NO ) return;
	if ( damage <= 0 ) return;
 
	new userHealth = get_user_health(id);
	
	if ( userHealth - damage <= 0 ) 
	{
		dmgcount[ attacker ] += userHealth - damage;
		set_msg_block( gmsg_death, BLOCK_SET );
		ExecuteHamB( Ham_Killed, id, attacker, 2 );
		set_msg_block( gmsg_death, BLOCK_NOT );
        
                
		message_begin( MSG_BROADCAST, gmsg_death );
		write_byte( attacker );
		write_byte( id );
		write_byte( 0 );
		write_string( weaponDescription );
		message_end( );
		g_pocet_killov[ attacker ] += 1;
		set_pev( attacker, pev_frags, float( get_user_frags( attacker ) + 1 ) );
                        
		new kname[ 32 ], vname[ 32 ], kauthid[ 32 ], vauthid[ 32 ], kteam[ 10 ], vteam[ 10 ];
        
		get_user_name( attacker, kname, 31 );
		get_user_team( attacker, kteam, 9 );
		get_user_authid( attacker, kauthid, 31 );
         
		get_user_name( id, vname, 31 );
		get_user_team( id, vteam, 9 );
		get_user_authid( id, vauthid, 31 );
                        
		log_message( "^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
		kname, get_user_userid( attacker ), kauthid, kteam, 
		vname, get_user_userid( id ), vauthid, vteam, weaponDescription );
	}
	else 
	{
		dmgcount[ attacker ] += damage;
		new origin[ 3 ];
		get_user_origin( id, origin );
                
		message_begin( MSG_ONE,gmsg_damage,{ 0,0,0 },id );
		write_byte( 21 );
		write_byte( 20 );
		write_long( DMG_BLAST );
		write_coord( origin[ 0 ] );
		write_coord( origin[ 1 ] );
		write_coord( origin[ 2 ] );
		message_end( );
                
		set_pev( id, pev_health, pev( id, pev_health ) - float( damage ) );
	}
}

public rpg_seek_follow( ent ) 
{
	ent -= TASK_SEEK_CATCH;
        
	new Float: shortest_distance = 500.0;
	new NearestPlayer = 0;
 
	if ( pev_valid( ent ) ) 
	{
		static entclass[ 32 ];
		pev( ent, pev_classname, entclass, 31 ); 

		if ( equali( entclass, "rpgrocket" ) )
		{
			new id_owner = pev( ent, pev_owner )
			new iClient[ 32 ], livePlayers, iNum;
			get_players( iClient, livePlayers, "a" ); 
	 
			for( iNum = 0; iNum < livePlayers; iNum++ ) 
			{ 
				if ( is_user_alive( iClient[ iNum ] ) && pev_valid( ent ) ) 
				{
					if ( id_owner != iClient[ iNum ] && zp_get_user_zombie( iClient[ iNum ] ) )
					{
						new Float:PlayerOrigin[ 3 ], Float:RocketOrigin[ 3 ];
						pev( ent, pev_origin, RocketOrigin );
						pev( iClient[ iNum ], pev_origin, PlayerOrigin );
					
						new Float: distance = get_distance_f( PlayerOrigin, RocketOrigin );
						
						if ( distance <= shortest_distance )
						{
							shortest_distance = distance;
							NearestPlayer = iClient[ iNum ];
						}
					}
				}
			}
			if ( NearestPlayer > 0 ) 
			{
				entity_set_follow( ent, NearestPlayer, 250.0 );
			}
		}
	}
}
 
stock entity_set_follow( entity, target, Float:speed ) 
{
	if( !fm_is_valid_ent( entity ) || !fm_is_valid_ent( target ) ) 
		return 0

	new Float:entity_origin[ 3 ], Float:target_origin[ 3 ];
	pev( entity, pev_origin, entity_origin );
	pev( target, pev_origin, target_origin );

	new Float:diff[ 3 ];
	diff[ 0 ] = target_origin[ 0 ] - entity_origin[ 0 ];
	diff[ 1 ] = target_origin[ 1 ] - entity_origin[ 1 ];
	diff[ 2 ] = target_origin[ 2 ] - entity_origin[ 2 ];
 
	new Float:length = floatsqroot( floatpower( diff[0], 2.0 ) + floatpower( diff[ 1 ], 2.0 ) + floatpower( diff[ 2 ], 2.0 ) )
 
       	new Float:velocity[ 3 ];
	velocity[ 0 ] = diff[ 0 ] * ( speed / length );
	velocity[ 1 ] = diff[ 1 ] * ( speed / length );
	velocity[ 2 ] = diff[ 2 ] * ( speed / length );
 
	set_pev( entity, pev_velocity, velocity )

	return 1;
}

public fw_CmdStart( id, UC_Handle, Seed )
{
	if( !is_user_alive( id ) || !g_hasbazooka[ id ] ) return;
	
                
	if( is_user_hannibal( id ) )
	{
		g_hasbazooka[ id ] = false;
		g_cooldown[ id ] = 0;
		CanShoot[ id ] = false;
		i_cooldown_time[ id ] = 0;
		drop_rpg_temp( id );
		return;
	}
	
	static Button, OldButton;
	OldButton = get_user_oldbutton( id );
                
	Button = get_uc( UC_Handle, UC_Buttons );
        
	if ( Button & IN_ATTACK )
	{
		if ( !CanShoot[ id ] || ( OldButton & IN_ATTACK2 ) ) return;
        
		if ( get_user_weapon( id ) == CSW_KNIFE ) 
			fire_rocket( id ); 
	}
	else if ( Button & IN_ATTACK2 && get_user_weapon( id ) == CSW_KNIFE ) 
	{
		if ( get_gametime ( ) - lastSwitchTime [ id ] < SWITCH_TIME || ( OldButton & IN_ATTACK2 ) ) return
		
		if ( is_user_alive( id ) )
		{
			switch( mode[ id ] ) 
			{
				case 1:
				{
					mode[ id ] = 2;
					client_cmd( id, "spk valve/sound/fvox/beep" );
					client_print( id, print_center, "[ Automaticka strela ]" );
				}
				case 2:
				{
					mode[ id ] = 3
					client_cmd( id, "spk valve/sound/fvox/beep" );
					client_print( id, print_center, "[ Riadena strela ]" );
				}
				case 3:
				{
					mode[id] = 1
					client_cmd( id, "spk valve/sound/fvox/beep" );
					client_print( id, print_center, "[ Normalna strela ]" );
				}		
			}	
			lastSwitchTime [ id ] = get_gametime ( );
		}
	}
	else if ( user_controll[ id ] ) 
	{
		new RocketEnt = user_controll[ id ]
			
		if ( is_valid_ent( RocketEnt ) ) 
		{
			new Float:Velocity[ 3 ];
			VelocityByAim( id, 500, Velocity );
			entity_set_vector( RocketEnt, EV_VEC_velocity, Velocity );
				
			new Float:NewAngle[ 3 ];
			entity_get_vector( id, EV_VEC_v_angle, NewAngle );
			entity_set_vector( RocketEnt, EV_VEC_angles, NewAngle );
		}
		else 
		{
			attach_view( id, id )
		}
	}
}

public client_connect( id )
{
	g_bazooka_kolo[ id ] = false;
	g_hasbazooka[ id ] = false;
	g_cooldown[ id ] = 0;
	i_cooldown_time[ id ] = 0;
}	

#if defined ADMIN_BAZOOKA
public AdminBazooka( id )
{
	if ( g_hasbazooka[ id ] || zp_get_user_nemesis( id ) || zp_get_user_zombie( id ) || zp_get_user_survivor( id ) )
		return;
	
	if ( is_user_alive( id ) && ( get_user_flags( id ) & BAZOOKA_ACCESS ) )
	{
		g_hasbazooka[ id ] = true;
		CanShoot[ id ] = true
		emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		bazooka_message( id, "", get_pcvar_float( pcvar_delay ) );
	}
}
#endif

stock launch_push( id, velamount )
{
	static Float:flNewVelocity[ 3 ], Float:flCurrentVelocity[ 3 ];
	
	velocity_by_aim( id, -velamount, flNewVelocity );
	
	get_user_velocity( id, flCurrentVelocity );
	xs_vec_add( flNewVelocity, flCurrentVelocity, flNewVelocity );
	
	set_user_velocity( id, flNewVelocity );
}

baz_count( )
{
	new i, count = 0;
	
	for( i = 1; i < 33; i++ )
	{
		if( g_hasbazooka[ i ] )
			count++;
	}
	return count;
}

stock bazooka_message( const id, const input[], any:... )
{
	new count = 1, players[ 32 ];
	
	static msg[ 191 ];
	vformat( msg,190,input,3 );
	
	replace_all( msg,190,"/g","^4" );
	replace_all( msg,190,"/y","^1" );
	replace_all( msg,190,"/ctr","^3" );
	
	if ( id ) players[ 0 ] = id; else get_players( players,count,"ch" )
	
	for ( new i = 0; i < count; i++ )
		if ( is_user_connected( players[ i ] ) )
		{
			message_begin( MSG_ONE_UNRELIABLE, Saytxt, _, players[ i ] );
			write_byte( players[ i ] );
			write_string( msg );
			message_end( );
		}
}

stock make_explosion_effects( index, explosion, decal, smoke, shake, texplo )
{
	new Float:fOrigin[ 3 ];
	new iOrigin[ 3 ]
	pev( index, pev_origin, fOrigin );
	FVecIVec( fOrigin,iOrigin );

	if( explosion )
	{
		message_begin( MSG_ALL ,SVC_TEMPENTITY );
		write_byte( TE_EXPLOSION );
		write_coord( iOrigin[ 0 ] );
		write_coord( iOrigin[ 1 ] );
		write_coord( iOrigin[ 2 ] );
		write_short( explosion );	
		write_byte( 65 );
		write_byte( 10 );	
		write_byte( 0 );	
		message_end( );
	}
	if( decal )
	{
		message_begin( MSG_ALL, SVC_TEMPENTITY );
		write_byte( TE_GUNSHOTDECAL );
		write_coord( iOrigin[ 0 ] );
		write_coord( iOrigin[ 1 ] );
		write_coord( iOrigin[ 2 ] );
		write_short( 0 );		
		write_byte( random_num( 46,48 ) );  
		message_end( );
	}
	if( smoke )
	{
		message_begin( MSG_ALL ,SVC_TEMPENTITY );
		write_byte( TE_SMOKE );
		write_coord( iOrigin[ 0 ] );
		write_coord( iOrigin[ 1 ] );
		write_coord( iOrigin[ 2 ] );
		write_short( rocketsmoke );	
		write_byte( 65 );	
		write_byte( 3 );	
		message_end( );
	}
	if( shake )
	{
		message_begin( MSG_ALL, gmsg_screenshake, { 0,0,0 }, index );
		write_short( 1<<14 ); 
		write_short( 1<<14 ); 
		write_short( 1<<14 );
		message_end( );
	}
	if( texplo )
	{
		message_begin( MSG_ALL ,SVC_TEMPENTITY );
		write_byte( TE_TAREXPLOSION );
		write_coord( iOrigin[ 0 ] );
		write_coord( iOrigin[ 1 ] );
		write_coord( iOrigin[ 2 ] );
		message_end( );
	}
}

public Spawn( id )
{
	if( !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
	
	remove_task( id );
	set_hudnacitania( id );
	g_bazooka_kolo[ id ] = false;
	g_pocet_killov[ id ] = 0;
	
	return PLUGIN_CONTINUE;
}


public ShowHUD( id )
{
	if( !is_user_hannibal( id ) )
	{
		if (!g_hasbazooka[ id ] || CanShoot[ id ] || !is_user_alive( id ))
			return 
		
		if(i_cooldown_time[ id ] >= 0)
		{
			i_cooldown_time[ id ] = i_cooldown_time[ id ] - 1;
			set_hudmessage( 200, 200, 0, 0.75, 0.92, 0, 1.0, 1.1, 0.0, 0.0, -1 );
			ShowSyncHudMsg( id, g_iHudSync, "Bazooka nabijanie: %d sec.",i_cooldown_time[ id ] );
		}
		else
		{
			CanShoot[ id ] = true;
			client_print( id, print_center, "Bazooka je nabita!" );
			emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
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
