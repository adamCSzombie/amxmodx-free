/* Plugin generated by AMXX-Studio */ 

#include < amxmodx > 
#include < fakemeta > 
#include < xs > 
#include < zombieplague > 
#include < hamsandwich >

#if defined UL_MONEY_SUPPORT 
#include <money_ul> 
#endif 

#if AMXX_VERSION_NUM < 180 
#assert AMX Mod X v1.8.0 or greater library required! 
#endif 

#define PLUGIN 			"[ZP-Extra] Laser/Tripmine Entity" 
#define VERSION 		"2.4" 
#define AUTHOR 			"SandStriker" 

#define RemoveEntity(%1) 	engfunc(EngFunc_RemoveEntity,%1) 
#define TASK_PLANT 		30100 
#define TASK_RESET 		15500 
#define TASK_RELEASE 		15900 

#define LASERMINE_TEAM 		pev_iuser1//EV_INT_iuser1 
#define LASERMINE_OWNER 	pev_iuser2 //EV_INT_iuser3 
#define LASERMINE_STEP 		pev_iuser3 
#define LASERMINE_HITING 	pev_iuser4 
#define LASERMINE_COUNT 	pev_fuser1 

#define LASERMINE_POWERUP 	pev_fuser2 
#define LASERMINE_BEAMTHINK 	pev_fuser3 

#define LASERMINE_BEAMENDPOINT 	pev_vuser1 
#define MAX_MINES 		50 
#define MODE_LASERMINE 		0 
#define OFFSET_TEAM 		114 
#define OFFSET_MONEY 		115 
#define OFFSET_DEATH 		444 

#define cs_get_user_team(%1) 	CsTeams:get_offset_value(%1,OFFSET_TEAM) 
#define cs_get_user_deaths(%1) 	get_offset_value(%1,OFFSET_DEATH) 
#define cs_get_user_money(%1) 	get_offset_value(%1,OFFSET_MONEY) 
#define cs_set_user_money(%1,%2) set_offset_value(%1,OFFSET_MONEY,%2) 
 
const g_item_lmines = 5;
new g_kontrola_chat[ 33 ];
 
enum CsTeams { 
	CS_TEAM_UNASSIGNED = 0, 
	CS_TEAM_T = 1, 
	CS_TEAM_CT = 2, 
	CS_TEAM_SPECTATOR = 3 
}; 

enum tripmine_e { 
	TRIPMINE_IDLE1 = 0, 
	TRIPMINE_IDLE2, 
	TRIPMINE_ARM1, 
	TRIPMINE_ARM2, 
	TRIPMINE_FIDGET, 
	TRIPMINE_HOLSTER, 
	TRIPMINE_DRAW, 
	TRIPMINE_WORLD, 
	TRIPMINE_GROUND, 
}; 

enum 
{ 
	POWERUP_THINK, 
	BEAMBREAK_THINK, 
	EXPLOSE_THINK 
}; 

enum 
{ 
	POWERUP_SOUND, 
	ACTIVATE_SOUND, 
	STOP_SOUND 
}; 

new const ENT_MODELS[ ] = 	{ "models/zombie_plague/LaserMines/v_laser_mine.mdl" };
new const ENT_SOUND1[ ] = 	{ "weapons/mine_deploy.wav" }; 
new const ENT_SOUND2[ ] = 	{  "weapons/mine_charge.wav" }; 
new const ENT_SOUND3[ ] = 	{ "weapons/mine_activate.wav" }; 
new const ENT_SOUND4[ ] = 	{ "debris/beamstart9.wav" };
new const ENT_SOUND5[ ] = 	{ "items/gunpickup2.wav" }; 
new const ENT_SOUND6[ ] = 	{ "debris/bustglass1.wav" };
new const ENT_SOUND7[ ] = 	{ "debris/bustglass2.wav" }; 
new const ENT_SPRITE1[ ] = 	{ "sprites/laserbeam.spr" };
new const ENT_SPRITE2[ ] = 	{ "sprites/zerogxplode.spr" };
new const ENT_CLASS_NAME[ ] = 	{ "lasermine" };
new const ENT_CLASS_NAME3[ ] = 	{ "func_breakable" };
new const CHATTAG[ ] = 		{ "!g[Avatar]!y" };
new const STR_NOTACTIVE[ ] = 	{ "LaserMina nieje aktivna" };
new const STR_CANTBUY[ ] = 	{ "Nemozete si kupit LaserMinu na tomto serveru." };
new const STR_NEEDED[ ] = 	{ "" };
new const STR_NOACCESS[ ] = 	{ "Nemate pristup k tomuto prikazu" }; 

new g_EntMine, beam, boom; 
new g_LENABLE,g_LFMONEY,g_LAMMO,g_LDMG, g_LTMAX,g_LCOST,g_LHEALTH,g_LMODE,g_LRADIUS,g_LRDMG,g_LFF,g_LCBT,g_BINDMODE; 
new g_LVISIBLE,g_LACCESS,g_LGLOW,g_LDMGMODE,g_LCLMODE,g_LCBRIGHT,g_LDSEC,g_LCMDMODE,g_LBUYMODE; 

new g_dcount[ 33 ], g_MaxPL, bool:g_settinglaser[ 33 ], g_msgDeathMsg, g_msgScoreInfo, g_msgDamage, g_msgMoney,
Float:plspeed[ 33 ], g_havemine[ 33 ], g_deployed[ 33 ]; 

public plugin_init( ) { 
	register_plugin( PLUGIN, VERSION, AUTHOR ); 
	RegisterHam( Ham_Spawn, "player", "spawn_hraca", 1 );
	register_dictionary( "zombie_plague.txt" );
	
	g_LENABLE = 	register_cvar( "zp_ltm","1" ); 
	g_BINDMODE = 	register_cvar( "zp_ltm_bind","0" );		//Auto bind P Key! 
	g_LACCESS = 	register_cvar( "zp_ltm_acs","0" ); 		//0 all, 1 admin 
	g_LMODE = 	register_cvar( "zp_ltm_mode","1" ); 		//0 lasermine, 1 tripmine 
	g_LAMMO = 	register_cvar( "zp_ltm_ammo","1" ); 
	g_LDMG = 	register_cvar( "zp_ltm_dmg","888" ); 		//laser hit dmg 
	g_LCOST = 	register_cvar( "zp_ltm_cost","0" ); 
	g_LFMONEY = 	register_cvar( "zp_ltm_fragmoney","0" ); 
	g_LHEALTH = 	register_cvar( "zp_ltm_health","5" ); 
	g_LTMAX = 	register_cvar( "zp_ltm_teammax","150" ); 
	g_LRADIUS = 	register_cvar( "zp_ltm_radius","800" ); 
	g_LRDMG = 	register_cvar( "zp_ltm_rdmg","888" ); 		//radius damage 
	g_LFF = 	register_cvar( "zp_ltm_ff","0" ); 
	g_LCBT = 	register_cvar( "zp_ltm_team","CT" ); 		//NO MODIFY!! 
	g_LBUYMODE = 	register_cvar( "zp_ltm_buymode","1" ); 
	g_LVISIBLE = 	register_cvar( "zp_ltm_line","1" ); 
	g_LGLOW = 	register_cvar( "zp_ltm_glow","0" ); 
	g_LCBRIGHT = 	register_cvar( "zp_ltm_bright","100" ); 		//laser line brightness. 
	g_LCLMODE = 	register_cvar( "zp_ltm_color","1" ); 		//0 is team color,1 is green 
	g_LDMGMODE = 	register_cvar( "zp_ltm_ldmgmode","1" ); 		//0 - frame dmg, 1 - once dmg, 2 - 1 second dmg 
	g_LDSEC = 	register_cvar( "zp_ltm_ldmgseconds","1" ); 	//mode 2 only, damage / seconds. default 1 (sec) 
	g_LCMDMODE = 	register_cvar( "zp_ltm_cmdmode","0" ); 		//0 is +USE key, 1 is bind, 2 is each. 
	
	register_event( "DeathMsg", "DeathEvent", "a" ); 
	//register_event( "CurWeapon", "standing", "be", "1=1" ); 
	register_event( "ResetHUD", "delaycount", "a" ); 
	register_event( "ResetHUD", "newround", "b" ); 
	register_event( "Damage","CutDeploy_onDamage","b" ); 
	
	g_msgDeathMsg = 	get_user_msgid( "DeathMsg" ); 
	g_msgScoreInfo = 	get_user_msgid( "ScoreInfo" ); 
	g_msgDamage = 		get_user_msgid( "Damage" ); 
	g_msgMoney = 		get_user_msgid( "Money" ); 

	register_forward( FM_Think, "ltm_Think" ); 
	//register_forward( FM_PlayerPostThink, "ltm_PostThink" ); 
	register_forward( FM_PlayerPreThink, "ltm_PreThink" );  
} 

public plugin_precache( ) { 
	precache_sound( ENT_SOUND1 ); 
	precache_sound( ENT_SOUND2 ); 
	precache_sound( ENT_SOUND3 ); 
	precache_sound( ENT_SOUND4 ); 
	precache_sound( ENT_SOUND5 ); 
	precache_sound( ENT_SOUND6 ); 
	precache_sound( ENT_SOUND7 ); 
	precache_model( ENT_MODELS ); 
	
	beam = precache_model( ENT_SPRITE1 ); 
	boom = precache_model( ENT_SPRITE2 ); 
	return PLUGIN_CONTINUE; 
} 

public plugin_modules( ) { 
	require_module( "fakemeta" ); 
	require_module( "cstrike" ); 
} 

public plugin_cfg( ) { 
	g_EntMine = 	engfunc( EngFunc_AllocString,ENT_CLASS_NAME3 ); 
	g_MaxPL = 	get_maxplayers( ); 
	
	arrayset( g_havemine,0,sizeof( g_havemine ) ); 
	arrayset( g_deployed,0,sizeof( g_deployed ) ); 
	
	new file[ 64 ]; get_localinfo( "amxx_configsdir",file,63 ); 
	
	format( file, 63, "%s/ltm_cvars.cfg", file ); 
	
	if( file_exists( file ) ) server_cmd( "exec %s", file ), server_exec( ); 
} 

public delaycount( id ) { 
	g_dcount[ id ] = floatround( get_gametime( ) ); 
} 

public CreateLaserMine_Progress_b( id ) { 
	if( !zp_get_user_zombie( id ) ) { 
		if( get_pcvar_num( g_LCMDMODE ) != 0 ) 
			CreateLaserMine_Progress( id ); 
		return PLUGIN_HANDLED; 
	} 
	return false; 
} 

public CreateLaserMine_Progress( id ) { 
	if( !CreateCheck( id ) ) 
		return PLUGIN_HANDLED; 
	g_settinglaser[ id ] = true; 
	client_cmd( id, "spk valve/sound/buttons/blip2" );
	message_begin( MSG_ONE, 108, { 0,0,0 }, id ); 
	write_byte( 1 ); 
	write_byte( 0 ); 
	message_end( ); 
	
	set_task( 1.2, "Spawn", ( TASK_PLANT + id ) ); 
	return PLUGIN_HANDLED; 
} 

public ReturnLaserMine_Progress( id ) { 
	if( !ReturnCheck( id ) ) 
		return PLUGIN_HANDLED; 
	g_settinglaser[ id ] = true; 
	
	message_begin( MSG_ONE, 108, { 0,0,0 }, id ); 
	write_byte( 1 ); 
	write_byte( 0 ); 
	message_end( ); 
	
	set_task( 1.2, "ReturnMine", ( TASK_RELEASE + id ) ); 
	return PLUGIN_HANDLED; 
} 

public StopCreateLaserMine( id ) { 
	DeleteTask( id ); 
	message_begin( MSG_ONE, 108, { 0,0,0 }, id ); 
	write_byte( 0 ); 
	write_byte( 0 ); 
	message_end( ); 
	
	return PLUGIN_HANDLED; 
} 

public StopReturnLaserMine( id ) { 
	DeleteTask( id ); 
	message_begin( MSG_ONE, 108, { 0,0,0 }, id ); 
	write_byte( 0 ); 
	write_byte( 0 ); 
	message_end( ); 
	
	return PLUGIN_HANDLED; 
} 

public ReturnMine( id ) { 
	id -= TASK_RELEASE; 
	new tgt,body,Float:vo[ 3 ],Float:to[ 3 ]; 
	get_user_aiming( id,tgt,body ); 
	
	if( !pev_valid( tgt ) ) 
		return; 
		
	pev( id,pev_origin,vo ); 
	pev( tgt,pev_origin,to ); 
	
	if( get_distance_f( vo,to ) > 70.0 ) 
		return; 
	 
	new EntityName[ 32 ]; 
	pev( tgt, pev_classname, EntityName, 31 ); 
	
	if(!equal( EntityName, ENT_CLASS_NAME ) ) 
			return; 
	if(pev(tgt,LASERMINE_OWNER) != id) 
			return; 
			
	RemoveEntity( tgt ); 
	
	g_havemine[ id ] ++; 
	g_deployed[ id ] --; 
	emit_sound( id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM ); 
	return; 
} 

public Spawn( id ) { 
	id -= TASK_PLANT 
	
	new i_Ent = engfunc( EngFunc_CreateNamedEntity,g_EntMine ); 
	if(!i_Ent) 
	{ 
		client_print( id,print_chat,"[Avatar] Nemozete vytvorit" ); 
		return PLUGIN_HANDLED_MAIN; 
	} 
	set_pev( i_Ent,pev_classname,ENT_CLASS_NAME ); 
	
	engfunc( EngFunc_SetModel,i_Ent,ENT_MODELS ); 
	
	set_pev( i_Ent,pev_solid,SOLID_NOT ); 
	set_pev( i_Ent,pev_movetype,MOVETYPE_FLY ); 
	
	set_pev( i_Ent,pev_frame, 0 ); 
	set_pev( i_Ent,pev_body, 3 ); 
	set_pev( i_Ent,pev_sequence,TRIPMINE_WORLD ); 
	set_pev( i_Ent,pev_framerate, 0 ); 
	
	set_pev( i_Ent,pev_takedamage,DAMAGE_YES ); 
	
	set_pev( i_Ent, pev_dmg, 100.0 ); 
	set_user_health( i_Ent, get_pcvar_num( g_LHEALTH ) ); 
	new Float:vOrigin[ 3 ]; 
	new Float:vNewOrigin[ 3 ],Float:vNormal[ 3 ],Float:vTraceDirection[ 3 ], 
	Float:vTraceEnd[ 3 ],Float:vEntAngles[ 3 ]; 
	pev( id, pev_origin, vOrigin ); 
	velocity_by_aim( id, 128, vTraceDirection ); 
	xs_vec_add( vTraceDirection, vOrigin, vTraceEnd ); 
	
	engfunc( EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0 ); 
	
	new Float:fFraction; 
	get_tr2( 0, TR_flFraction, fFraction ); 

	if ( fFraction < 1.0 ) { 
		get_tr2( 0, TR_vecEndPos, vTraceEnd ); 
		get_tr2( 0, TR_vecPlaneNormal, vNormal ); 
	} 
	
	xs_vec_mul_scalar( vNormal, 8.0, vNormal ); 
	xs_vec_add( vTraceEnd, vNormal, vNewOrigin ); 
	
	engfunc( EngFunc_SetSize, i_Ent, Float:{ -4.0, -4.0, -4.0 }, Float:{ 4.0, 4.0, 4.0 } ); 
	engfunc( EngFunc_SetOrigin, i_Ent, vNewOrigin ); 
	
	vector_to_angle( vNormal,vEntAngles ); 
	set_pev( i_Ent,pev_angles,vEntAngles ); 
	
	new Float:vBeamEnd[ 3 ], Float:vTracedBeamEnd[ 3 ]; 
	
	xs_vec_mul_scalar( vNormal, 8192.0, vNormal ); 
	xs_vec_add( vNewOrigin, vNormal, vBeamEnd ); 
	
	engfunc( EngFunc_TraceLine, vNewOrigin, vBeamEnd, IGNORE_MONSTERS, -1, 0 ); 
	
	get_tr2( 0, TR_vecPlaneNormal, vNormal ); 
	get_tr2( 0, TR_vecEndPos, vTracedBeamEnd ); 
	
	set_pev( i_Ent, LASERMINE_OWNER, id ); 
	set_pev( i_Ent,LASERMINE_BEAMENDPOINT,vTracedBeamEnd ); 
	set_pev( i_Ent,LASERMINE_TEAM,2 ); 
	new Float:fCurrTime = get_gametime( ); 
	
	set_pev( i_Ent,LASERMINE_POWERUP, fCurrTime + 2.5 ); 
	
	set_pev( i_Ent,LASERMINE_STEP,POWERUP_THINK ); 
	set_pev( i_Ent,pev_nextthink, fCurrTime + 0.2 ); 
	
	PlaySound( i_Ent,POWERUP_SOUND ); 
	g_deployed[ id ]++; 
	g_havemine[ id ]--; 
	DeleteTask( id ); 
	
	ChatColor(id,"%L", LANG_PLAYER, "LASERMINE_PLANTED" );
	return 1; 
} 

stock is_entity_moving( entity ) {
	if( !is_valid_ent( entity ) )
		return 0;
	
	new Float:fVelocity[ 3 ];
	entity_get_vector( entity, EV_VEC_velocity, fVelocity )
	if( vector_length( fVelocity ) >= 150.0 )
		return 1;
	
	return 0;
} 

stock TeamDeployedCount( id ) { 
	static i; 
	static CsTeams:t;t = cs_get_user_team( id ); 
	static cnt;cnt = 0; 

	for( i = 1; i <= g_MaxPL; i++ ) { 
		if( is_user_connected( i ) ) 
		if( t == cs_get_user_team( i ) ) 
			cnt += g_deployed[ i ]; 
	} 
	return cnt; 
} 

bool:CheckCanTeam( id ) { 
	new arg[ 5 ], CsTeam:num; 
	get_pcvar_string( g_LCBT,arg,3 ); 
	if( equali( arg,"T" ) ) { 
		num = CsTeam:CS_TEAM_T; 
	} else if( equali( arg,"CT" ) ) { 
		num = CsTeam:CS_TEAM_CT; 
	} else if( equali( arg,"ALL" ) ) { 
		num = CsTeam:CS_TEAM_UNASSIGNED; 
	} else { 
		num = CsTeam:CS_TEAM_UNASSIGNED; 
	} 
	if( num != CsTeam:CS_TEAM_UNASSIGNED && num != CsTeam:cs_get_user_team( id ) ) 
	return false; 
	return true; 
} 

bool:CanCheck( id,mode ) { 
	if( !get_pcvar_num( g_LENABLE ) ) { 
		ChatColor( id, "%s %s", CHATTAG,STR_NOTACTIVE );
		return false; 
	} 
	if( get_pcvar_num( g_LACCESS ) != 0 ) { 
		if( !( get_user_flags( id ) & ADMIN_IMMUNITY ) ) { 
			ChatColor( id, "%s %s", CHATTAG,STR_NOACCESS );
			return false; 
		} 
	} 
	if( !pev_user_alive( id ) ) 
		return false; 
	if( !CheckCanTeam( id ) ) 
		return false; 
	if( mode == 0 ) { 
		if( g_havemine[ id ] <= 0 ) { 
			return false; 
		} 
	} 
	if( mode == 1 ) { 
		if( get_pcvar_num( g_LBUYMODE ) == 0 ) { 
			ChatColor( id, "%s %s", CHATTAG, STR_CANTBUY );
			return false; 
		} 
		if( g_havemine[ id ] >= get_pcvar_num( g_LAMMO ) ) { 
			ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_MAX" );
			return false; 
		} 
		if( cs_get_user_money( id ) < get_pcvar_num( g_LCOST ) ) 
		{ 
			client_print( id, print_chat, "%L", LANG_PLAYER, "LASERMINE_NOT_ENOUGH" ); 
			return false; 
		} 
	} 
	return true; 
} 

bool:ReturnCheck( id ) { 
	if( !CanCheck( id, -1 ) ) 
		return false; 
		
	if( g_havemine[ id ] + 1 > get_pcvar_num( g_LAMMO ) ) 
		return false; 
		
	new tgt, body, Float:vo[ 3 ], Float:to[ 3 ]; 
	get_user_aiming( id, tgt, body ); 
	if( !pev_valid( tgt ) ) 
		return false; 
		
	pev( id, pev_origin, vo ); 
	pev( tgt, pev_origin, to ); 
	if( get_distance_f( vo, to ) > 70.0 ) 
		return false; 
	new EntityName[ 32 ]; 
	pev( tgt, pev_classname, EntityName, 31 ); 
	if( !equal( EntityName, ENT_CLASS_NAME ) ) 
		return false; 
		
	if( pev( tgt,LASERMINE_OWNER ) != id ) 
		return false; 

	return true; 
} 

bool:CreateCheck( id ) { 
	if( !CanCheck( id, 0 ) ) 
		return false; 
	if( g_deployed[ id ] >= get_pcvar_num( g_LAMMO ) ) { 
		ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_MAX" );
		return false; 
	} 

	if( TeamDeployedCount( id ) >= get_pcvar_num( g_LTMAX ) ) { 
		return false; 
	} 

	new Float:vTraceDirection[ 3 ], Float:vTraceEnd[ 3 ],Float:vOrigin[ 3 ]; 

	pev( id, pev_origin, vOrigin ); 
	velocity_by_aim( id, 128, vTraceDirection ); 
	xs_vec_add( vTraceDirection, vOrigin, vTraceEnd ); 

	engfunc( EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0 ); 

	new Float:fFraction,Float:vTraceNormal[3]; 
	get_tr2( 0, TR_flFraction, fFraction ); 

	if( fFraction < 1.0 ) { 
		get_tr2( 0, TR_vecEndPos, vTraceEnd ); 
		get_tr2( 0, TR_vecPlaneNormal, vTraceNormal ); 
		return true; 
	} 
	DeleteTask( id ); 
	return false; 
} 

public ltm_Think( i_Ent ) 
{ 
	if ( !pev_valid( i_Ent ) ) 
		return FMRES_IGNORED; 
	new EntityName[ 32 ]; 
	pev( i_Ent, pev_classname, EntityName, 31 ); 
	if( !get_pcvar_num( g_LENABLE ) ) 
		return FMRES_IGNORED;  
	if ( !equal( EntityName, ENT_CLASS_NAME ) ) 
		return FMRES_IGNORED; 
	static Float:fCurrTime; 
	fCurrTime = get_gametime( ); 


	switch( pev( i_Ent, LASERMINE_STEP ) ) { 
		case POWERUP_THINK : { 
			new Float:fPowerupTime; 
			pev( i_Ent, LASERMINE_POWERUP, fPowerupTime ); 

			if( fCurrTime > fPowerupTime ) { 
				set_pev( i_Ent, pev_solid, SOLID_NOT ); 
				set_pev( i_Ent, LASERMINE_STEP, BEAMBREAK_THINK ); 
				PlaySound( i_Ent, ACTIVATE_SOUND ); 
			} 
			if( get_pcvar_num( g_LGLOW ) != 0 ) { 
				if( get_pcvar_num( g_LCLMODE ) == 0 ) { 
					switch( pev( i_Ent,LASERMINE_TEAM ) ) { 
						case CS_TEAM_T: set_rendering( i_Ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 5 ); 
						case CS_TEAM_CT:set_rendering( i_Ent, kRenderFxGlowShell, 54, 102, 246, kRenderNormal, 5 ); 
					} 
				} else { 
					set_rendering( i_Ent, kRenderFxGlowShell, 54, 102, 246, kRenderNormal, 5 ); 
				} 
			} 
			set_pev( i_Ent, pev_nextthink, fCurrTime + 0.1 ); 
		} 
		case BEAMBREAK_THINK : { 
			static Float:vEnd[ 3 ],Float:vOrigin[ 3 ]; 
			pev( i_Ent, pev_origin, vOrigin ); 
			pev( i_Ent, LASERMINE_BEAMENDPOINT, vEnd ); 
			static iHit, Float:fFraction; 
			engfunc( EngFunc_TraceLine, vOrigin, vEnd, DONT_IGNORE_MONSTERS, i_Ent, 0 ); 
			get_tr2( 0, TR_flFraction, fFraction ); 
			iHit = get_tr2( 0, TR_pHit ); 

			if( fFraction < 1.0 ) { 
				if( pev_valid( iHit ) ) { 
					pev( iHit, pev_classname, EntityName, 31 ); 
					if( !equal( EntityName, ENT_CLASS_NAME ) ) { 
						set_pev( i_Ent, pev_enemy, iHit );
						
						if( get_pcvar_num( g_LMODE ) == MODE_LASERMINE ) {
							CreateLaserDamage( i_Ent,iHit ); 
						} else {
							if(get_pcvar_num(g_LFF) || CsTeams:pev(i_Ent,LASERMINE_TEAM) != cs_get_user_team(iHit)) 
							set_pev( i_Ent, LASERMINE_STEP, EXPLOSE_THINK ); 
							set_pev( i_Ent, pev_nextthink, fCurrTime + random_float( 0.1, 0.3 ) ); 
						} 
					} 
				} 
			}
			
			if( get_pcvar_num( g_LDMGMODE ) != 0 ) {
				if( pev( i_Ent,LASERMINE_HITING ) != iHit ) {
					set_pev( i_Ent,LASERMINE_HITING,iHit ); 
				}
			}
					
			if( pev_valid( i_Ent ) ) { 
				static Float:fHealth; 
				pev( i_Ent, pev_health, fHealth ); 

				if( fHealth <= 0.0 || (pev(i_Ent,pev_flags) & FL_KILLME)) { 
					set_pev( i_Ent, LASERMINE_STEP, EXPLOSE_THINK ); 
					set_pev( i_Ent, pev_nextthink, fCurrTime + random_float( 0.1, 0.3 ) ); 
				} 

				static Float:fBeamthink; 
				pev( i_Ent, LASERMINE_BEAMTHINK, fBeamthink ); 

				if( fBeamthink < fCurrTime && get_pcvar_num( g_LVISIBLE ) ) { 
					DrawLaser( i_Ent, vOrigin, vEnd ); 
					set_pev( i_Ent, LASERMINE_BEAMTHINK, fCurrTime + 0.1 ); 
				} 
				set_pev( i_Ent, pev_nextthink, fCurrTime + 0.01 ); 
			} 
		} 
		case EXPLOSE_THINK : { 
			set_pev( i_Ent, pev_nextthink, 0.0 ); 
			PlaySound( i_Ent, STOP_SOUND ); 
			g_deployed[ pev( i_Ent,LASERMINE_OWNER ) ]--; 
			CreateExplosion( i_Ent ); 
			CreateDamage( i_Ent, get_pcvar_float( g_LRDMG ), get_pcvar_float( g_LRADIUS ) ); 
			RemoveEntity ( i_Ent ); 
		} 
	} 
	return FMRES_IGNORED; 
} 

PlaySound( i_Ent, i_SoundType ) { 
	switch ( i_SoundType ) { 
		case POWERUP_SOUND: { 
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND1, VOL_NORM, ATTN_NORM, 0, PITCH_NORM ); 
			emit_sound( i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, 0, PITCH_NORM ); 
		} 
		case ACTIVATE_SOUND: { 
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, 1, 75 ); 
		} 
		case STOP_SOUND: { 
			emit_sound( i_Ent, CHAN_BODY , ENT_SOUND2, 0.2, ATTN_NORM, SND_STOP, PITCH_NORM ); 
			emit_sound( i_Ent, CHAN_VOICE, ENT_SOUND3, 0.5, ATTN_NORM, SND_STOP, 75 ); 
		} 
	} 
} 

DrawLaser( i_Ent, const Float:v_Origin[ 3 ], const Float:v_EndOrigin[ 3 ] ) { 
	new tcolor[ 3 ]; 
	new teamid = pev( i_Ent, LASERMINE_TEAM ); 
	if( get_pcvar_num( g_LCLMODE ) == 0 ) { 
		switch( teamid ){ 
			case 1:{ 
				tcolor[ 0 ] = 45; 
				tcolor[ 1 ] = 45; 
				tcolor[ 2 ] = 165; 
			} 
			case 2:{ 
				tcolor[ 0 ] = 45; 
				tcolor[ 1 ] = 45; 
				tcolor[ 2 ] = 165; 
			} 
		} 
	} else { 
		tcolor[ 0 ] = 45; 
		tcolor[ 1 ] = 45; 
		tcolor[ 2 ] = 165; 
	} 
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY ); 
	write_byte( TE_BEAMPOINTS ); 
	engfunc( EngFunc_WriteCoord,v_Origin[ 0 ] ); 
	engfunc( EngFunc_WriteCoord,v_Origin[ 1 ] ); 
	engfunc( EngFunc_WriteCoord,v_Origin[ 2 ] ); 
	engfunc( EngFunc_WriteCoord,v_EndOrigin[ 0 ] ); //Random 
	engfunc( EngFunc_WriteCoord,v_EndOrigin[ 1 ] ); //Random 
	engfunc( EngFunc_WriteCoord,v_EndOrigin[ 2 ] ); //Random 
	write_short( beam ); 
	write_byte( 0 ); 
	write_byte( 0 ); 
	write_byte( 1 ); //Life 
	write_byte( 5 ); //Width 
	write_byte( 0 ); //wave 
	write_byte( tcolor[ 0 ] ); // r 
	write_byte( tcolor[ 1 ] ); // g 
	write_byte( tcolor[ 2 ] ); // b 
	write_byte( get_pcvar_num( g_LCBRIGHT ) ); 
	write_byte( 255 ); 
	message_end( ); 
} 

CreateDamage( iCurrent,Float:DmgMAX, Float:Radius ) { 
	new Float:vecSrc[ 3 ]; 
	pev( iCurrent, pev_origin, vecSrc ); 

	new AtkID = pev( iCurrent,LASERMINE_OWNER ); 
	new TeamID= pev( iCurrent,LASERMINE_TEAM ); 

	new ent = -1; 
	new Float:tmpdmg = DmgMAX; 

	new Float:kickback = 0.0; 

	new Float:Tabsmin[ 3 ], Float:Tabsmax[ 3 ]; 
	new Float:vecSpot[ 3 ]; 
	new Float:Aabsmin[ 3 ], Float:Aabsmax[ 3 ]; 
	new Float:vecSee[ 3 ]; 
	new trRes; 
	new Float:flFraction; 
	new Float:vecEndPos[ 3 ]; 
	new Float:distance; 
	new Float:origin[ 3 ], Float:vecPush[ 3 ]; 
	new Float:invlen; 
	new Float:velocity[ 3 ]; 
	new iHitHP,iHitTeam; 

	new Float:falloff; 
	if( Radius > 0.0 ) { 
		falloff = DmgMAX / Radius; 
	} else { 
		falloff = 1.0; 
	} 

	while( ( ent = engfunc( EngFunc_FindEntityInSphere, ent, vecSrc, Radius ) ) != 0 ) { 
		if( !pev_valid( ent ) ) 
			continue; 
		if(!(pev(ent, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER))) { 
			continue; 
		} 
		if( !pev_user_alive( ent ) ) 
			continue; 
		kickback = 1.0; 
		tmpdmg = DmgMAX; 

		pev( ent, pev_absmin, Tabsmin ); 
		pev( ent, pev_absmax, Tabsmax ); 
		xs_vec_add( Tabsmin,Tabsmax,Tabsmin ); 
		xs_vec_mul_scalar( Tabsmin,0.5,vecSpot ); 
		pev( iCurrent, pev_absmin, Aabsmin ); 
		pev( iCurrent, pev_absmax, Aabsmax) ; 
		xs_vec_add( Aabsmin,Aabsmax,Aabsmin ); 
		xs_vec_mul_scalar( Aabsmin,0.5,vecSee ); 

		engfunc( EngFunc_TraceLine, vecSee, vecSpot, 0, iCurrent, trRes ); 
		get_tr2( trRes, TR_flFraction, flFraction ); 

		if( flFraction >= 0.9 || get_tr2( trRes, TR_pHit ) == ent ) { 
			get_tr2( trRes, TR_vecEndPos, vecEndPos ); 

			distance = get_distance_f( vecSrc, vecEndPos ) * falloff; 
			tmpdmg -= distance; 
			if( tmpdmg < 0.0 ) 
				tmpdmg = 0.0; 

			if( kickback != 0.0 ) { 
				xs_vec_sub( vecSpot,vecSee,origin ); 

				invlen = 1.0 / get_distance_f( vecSpot, vecSee ); 

				xs_vec_mul_scalar( origin,invlen,vecPush ); 
				pev( ent, pev_velocity, velocity );
				xs_vec_mul_scalar( vecPush,tmpdmg,vecPush ); 
				xs_vec_mul_scalar( vecPush,kickback,vecPush ); 
				xs_vec_add( velocity,vecPush,velocity ); 

				if( tmpdmg < 60.0 ) { 
					xs_vec_mul_scalar( velocity, 12.0, velocity ); 
				} else { 
					xs_vec_mul_scalar( velocity, 4.0, velocity ); 
				} 

				if( velocity[ 0 ] != 0.0 || velocity[ 1 ] != 0.0 || velocity[ 2 ] != 0.0 ) { 
					set_pev( ent, pev_velocity, velocity );
				} 
			} 
			new hp65 = pev_user_health( ent ) * 65 / 100;
			iHitHP = pev_user_health( ent ) - hp65;
			iHitTeam = int:cs_get_user_team(ent) 
			if( iHitHP <= 0 ) { 
				if( iHitTeam != TeamID ) { 
					cs_set_user_money( AtkID,cs_get_user_money( AtkID ) + get_pcvar_num( g_LFMONEY ) );
					set_score( AtkID, ent, 1, iHitHP );
				} else { 
					if( get_pcvar_num( g_LFF ) ) { 
						cs_set_user_money( AtkID,cs_get_user_money( AtkID ) - get_pcvar_num( g_LFMONEY ) ); 
						set_score( AtkID, ent, 1, iHitHP ); 
					} 
				} 
			} else { 
				if( iHitTeam != TeamID || get_pcvar_num( g_LFF ) ) { 
					if( zp_get_user_zombie( ent ) ) {
						if( !zp_get_user_nemesis( ent ) ) {	
							set_user_health( ent, iHitHP )
						} else {
							set_user_health( ent, get_user_health( ent ) - 1 );
						}
					}
					
					engfunc( EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, g_msgDamage,{ 0.0, 0.0, 0.0 }, ent ); 
					write_byte( floatround( tmpdmg ) ); 
					write_byte( floatround( tmpdmg ) ); 
					write_long( DMG_BULLET ); 
					engfunc( EngFunc_WriteCoord, vecSrc[ 0 ] ); 
					engfunc( EngFunc_WriteCoord, vecSrc[ 1 ] ); 
					engfunc( EngFunc_WriteCoord, vecSrc[ 2 ] ); 
					message_end( ) 
				} 
			} 
		} 
	} 
	return;
} 

bool:pev_user_alive( ent ) { 
	new deadflag = pev( ent,pev_deadflag ); 
	if( deadflag != DEAD_NO ) 
		return false; 
	return true; 
} 

CreateExplosion( iCurrent ) { 
	new Float:vOrigin[ 3 ]; 
	pev( iCurrent,pev_origin,vOrigin ); 
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY ); 
	write_byte( 99 ); 
	write_short( iCurrent ); 
	message_end( ); 

	engfunc( EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vOrigin, 0 ); 
	write_byte( TE_EXPLOSION ); 
	engfunc( EngFunc_WriteCoord,vOrigin[ 0 ] ); 
	engfunc( EngFunc_WriteCoord,vOrigin[ 1 ] ); 
	engfunc( EngFunc_WriteCoord,vOrigin[ 2 ] ); 
	write_short( boom ); 
	write_byte( 30 ); 
	write_byte( 15 ); 
	write_byte( 0 ); 
	message_end( ); 
} 

CreateLaserDamage( iCurrent,isHit ) { 
	if(isHit < 0 ) 
		return PLUGIN_CONTINUE 
	switch( get_pcvar_num( g_LDMGMODE ) ) { 
		case 1: { 
			if( pev( iCurrent, LASERMINE_HITING ) == isHit ) 
				return PLUGIN_CONTINUE; 
		} 
		case 2: { 
			if( pev( iCurrent, LASERMINE_HITING ) == isHit ) { 
				static Float:cnt; 
				static now, htime;now = floatround( get_gametime( ) );
				pev( iCurrent, LASERMINE_COUNT, cnt ); 
				htime = floatround( cnt ); 
				if( now - htime < get_pcvar_num( g_LDSEC ) ) { 
					return PLUGIN_CONTINUE; 
					} else { 
					set_pev( iCurrent, LASERMINE_COUNT, get_gametime( ) ); 
				}	 
				} else { 
				set_pev( iCurrent, LASERMINE_COUNT, get_gametime( ) ); 
			} 
		} 
	} 
	new Float:vOrigin[ 3 ],Float:vEnd[ 3 ]; 
	pev( iCurrent, pev_origin, vOrigin ); 
	pev( iCurrent, pev_vuser1, vEnd );  
	
	new teamid = pev( iCurrent, LASERMINE_TEAM ); 
	
	new szClassName[ 32 ], Alive, God, iHitTeam, iHitHP, id, hitscore; 
	szClassName[ 0 ] = '^0'; 
	pev( isHit, pev_classname, szClassName, 32 ); 
	
	if( ( pev( isHit, pev_flags ) & ( FL_CLIENT | FL_FAKECLIENT | FL_MONSTER ) ) ) { 
		Alive = pev_user_alive( isHit ); 
		God = get_user_godmode( isHit ); 
		if( !Alive || God ) 
			return PLUGIN_CONTINUE; 
		
		iHitTeam = int:cs_get_user_team( isHit ); 
		iHitHP = pev_user_health( isHit ) - get_pcvar_num( g_LDMG ); 
		id = pev( iCurrent, LASERMINE_OWNER );
		if( iHitHP <= 0 ) { 
			if( iHitTeam != teamid ) { 
				emit_sound( isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM ) 
				hitscore = 1 
				cs_set_user_money( id, cs_get_user_money( id ) + get_pcvar_num( g_LFMONEY ) ) 
				set_score( id, isHit, hitscore, iHitHP ); 
				} else { 
				if( get_pcvar_num( g_LFF ) ) { 
					emit_sound(isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM ) 
					hitscore = -1 
					cs_set_user_money(id,cs_get_user_money(id) - get_pcvar_num(g_LFMONEY)) 
					set_score(id,isHit,hitscore,iHitHP) 
				} 
			} 
		}	
		else if( iHitTeam != teamid || get_pcvar_num( g_LFF ) ) { 
			emit_sound( isHit, CHAN_WEAPON, ENT_SOUND4, 1.0, ATTN_NORM, 0, PITCH_NORM ); 
			set_user_health( isHit, iHitHP ); 
			set_pev( iCurrent, LASERMINE_HITING, isHit ); 
			
			engfunc( EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, g_msgDamage,{ 0.0, 0.0, 0.0 }, isHit ); 
			write_byte( get_pcvar_num( g_LDMG ) ); 
			write_byte( get_pcvar_num( g_LDMG ) ); 
			write_long( DMG_BULLET ); 
			engfunc( EngFunc_WriteCoord,vOrigin[ 0 ] ); 
			engfunc( EngFunc_WriteCoord,vOrigin[ 1 ] ); 
			engfunc( EngFunc_WriteCoord,vOrigin[ 2 ] ); 
			message_end( ) 
		} 

	}
	else if( equal( szClassName, ENT_CLASS_NAME3 ) ) { 
		new hl; 
		hl = pev_user_health( isHit ); 
		set_user_health( isHit, hl - get_pcvar_num( g_LDMG ) ); 
	} 
	return PLUGIN_CONTINUE 
} 

stock pev_user_health( id ) { 
	new Float:health; 
	pev( id,pev_health,health ); 
	return floatround( health ); 
} 

stock set_user_health( id,health ) { 
	health > 0 ? set_pev( id, pev_health, float( health ) ) : dllfunc( DLLFunc_ClientKill, id ); 
} 

stock get_user_godmode( index ) { 
	new Float:val; 
	pev( index, pev_takedamage, val ); 
	return ( val == DAMAGE_NO ); 
} 

stock set_user_frags( index, frags ) { 
	set_pev( index, pev_frags, float( frags ) ); 
	return 1; 
} 

stock pev_user_frags( index ) { 
	new Float:frags; 
	pev( index, pev_frags, frags ); 
	return floatround( frags ); 
} 

set_score( id, target, hitscore, HP ) { 
	new idfrags = pev_user_frags( id ) + hitscore;
	set_user_frags( id, idfrags ); 
	new tarfrags = pev_user_frags( target ) + 1;
	set_user_frags( target, tarfrags ) 
	new idteam = int:cs_get_user_team( id ); 
	new iddeaths = cs_get_user_deaths( id ); 

	message_begin( MSG_ALL, g_msgDeathMsg, { 0, 0, 0 } , 0 ); 
	write_byte( id ); 
	write_byte( target ); 
	write_byte( 0 ); 
	write_string( ENT_CLASS_NAME ); 
	message_end( ); 

	message_begin( MSG_ALL, g_msgScoreInfo ); 
	write_byte( id ); 
	write_short( idfrags ); 
	write_short( iddeaths ); 
	write_short( 0 );
	write_short( idteam ); 
	message_end( ); 

	set_msg_block( g_msgDeathMsg, BLOCK_ONCE ); 
	set_user_health( target, HP ); 

} 

public BuyLasermine( id ) { 
	if( !CanCheck( id, 1 ) ) 
		return PLUGIN_CONTINUE; 
		
	cs_set_user_money( id, cs_get_user_money( id ) - get_pcvar_num( g_LCOST ) ) 
	g_havemine[ id ]++; 
	emit_sound( id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM ); 
	return PLUGIN_HANDLED; 
} 

public ltm_PreThink( id ) { 
	if( !is_user_alive( id ) || is_user_bot( id ) )
		return FMRES_IGNORED
	
	new button = pev( id, pev_button );
	new oldbutton = pev( id, pev_oldbuttons );
	
	if( button & IN_USE ) {
		if( g_havemine[ id ] >= 1 ) {
			if( !g_settinglaser[ id ] ) {
				if( zp_has_round_started( ) ) {
					CreateLaserMine_Progress( id );
				} else {
					if( !g_kontrola_chat[ id ] ) {
						g_kontrola_chat[ id ] = true;
						ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_WAIT" );
					}
				}	
			}
		}
	}
	else if ( ( oldbutton & IN_USE ) ) { 
			if( g_settinglaser[ id ] ) { 
				g_settinglaser[ id ] = false;
				remove_task( TASK_PLANT + id );
				ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_STOPPED" );
				StopCreateLaserMine( id );
			}
			g_kontrola_chat[ id ] = false;
	}
	return FMRES_IGNORED;  
}

public client_putinserver( id ) { 
	g_deployed[ id ] = 0; 
	g_havemine[ id ] = 0; 
	DeleteTask( id ); 
	return PLUGIN_CONTINUE 
} 

public client_disconnect( id ) { 
	if( !get_pcvar_num( g_LENABLE ) ) 
		return PLUGIN_CONTINUE; 
		
	DeleteTask( id ); 
	RemoveAllTripmines( id ); 
	return PLUGIN_CONTINUE; 
} 

public newround( id ) { 
	if( !get_pcvar_num( g_LENABLE ) ) 
		return PLUGIN_CONTINUE; 
	
	pev( id, pev_maxspeed, plspeed[ id ] ) 
	DeleteTask( id ); 
	RemoveAllTripmines( id ); 
	delaycount( id ); 
	return PLUGIN_CONTINUE ;
} 

public DeathEvent( ) { 
	if( !get_pcvar_num( g_LENABLE ) ) 
		return PLUGIN_CONTINUE; 
	
	new id = read_data( 2 ); 
	if( is_user_connected( id ) ) DeleteTask( id ); 
	return PLUGIN_CONTINUE 
} 

public RemoveAllTripmines( i_Owner ) { 
	new iEnt = g_MaxPL + 1; 
	new clsname[ 32 ]; 
	while( ( iEnt = engfunc( EngFunc_FindEntityByString, iEnt, "classname", ENT_CLASS_NAME ) ) ) { 
		if ( i_Owner ) { 
			if( pev( iEnt, LASERMINE_OWNER ) != i_Owner ) 
				continue; 
			clsname[ 0 ] = '^0' 
			pev( iEnt, pev_classname, clsname, sizeof( clsname ) - 1 ); 

			if ( equali( clsname, ENT_CLASS_NAME ) ) { 
				PlaySound( iEnt, STOP_SOUND ); 
				RemoveEntity( iEnt ); 
			} 
		} else {
			set_pev( iEnt, pev_flags, FL_KILLME ); 
		} 
	}
	g_deployed[i_Owner]=0; 
} 

public CutDeploy_onDamage( id ) { 
	if( get_user_health( id ) < 1 ) 
		DeleteTask( id ); 
} 

DeleteTask( id ) { 
	if( task_exists( ( TASK_PLANT + id ) ) ) { 
		remove_task( ( TASK_PLANT + id ) ); 
	} 
	
	if( task_exists( ( TASK_RELEASE + id ) ) ) { 
		remove_task( ( TASK_RELEASE + id ) ); 
	} 
	g_settinglaser[ id ] = false; 
	return PLUGIN_CONTINUE; 
} 

stock set_rendering( entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16 ) { 
	static Float:RenderColor[ 3 ]; 
	RenderColor[ 0 ] = float( r ); 
	RenderColor[ 1 ] = float( g ); 
	RenderColor[ 2 ] = float( b ); 
	
	set_pev( entity, pev_renderfx, fx ); 
	set_pev( entity, pev_rendercolor, RenderColor ); 
	set_pev( entity, pev_rendermode, render ); 
	set_pev( entity, pev_renderamt, float( amount ) ); 
	return 1; 
} 

get_offset_value( id, type ) { 
	new key = -1; 
	switch( type ) { 
		case OFFSET_TEAM: key = OFFSET_TEAM; 
		case OFFSET_MONEY: { 
			#if defined UL_MONEY_SUPPORT 
			return cs_get_user_money_ul( id ); 
			#else 
			key = OFFSET_MONEY; 
			#endif 
		} 
		case OFFSET_DEATH: key = OFFSET_DEATH; 
	} 

	if( key != -1 ) { 
		if( is_amd64_server( ) ) key += 25; 
		return get_pdata_int( id, key ); 
	} 
	return -1; 
} 

set_offset_value( id, type, value ) { 
	new key = -1; 
	switch( type ) { 
		case OFFSET_TEAM: key = OFFSET_TEAM; 
		case OFFSET_MONEY: { 
			#if defined UL_MONEY_SUPPORT 
			return cs_set_user_money_ul( id, value ); 
			#else 
			key = OFFSET_MONEY; 

			message_begin( MSG_ONE_UNRELIABLE, g_msgMoney, { 0, 0, 0 }, id ); 
			write_long( value ); 
			write_byte( 1 ); 
			message_end( ); 
			#endif 
		} 
		case OFFSET_DEATH: key = OFFSET_DEATH; 
	} 

	if( key != -1 ) { 
		if( is_amd64_server( ) ) key += 25; 
		set_pdata_int( id, key, value ); 
	} 
	return PLUGIN_CONTINUE; 
} 
 
public cmd_bind( id ) { 
	if( get_pcvar_num( g_LCMDMODE ) == 1 ) { 
		if ( get_pcvar_num(g_BINDMODE) == 1 ) { 
			ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_BUY" );
			ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_HAVE", g_havemine[ id ] + 1 );
			client_cmd( id, "spk valve/sound/buttons/button8" );
			client_cmd( id,"bind p +setlaser" ); 
			return PLUGIN_HANDLED; 
		} 
		ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_BUY" );
		ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_HAVE", g_havemine[ id ] + 1 );
		client_cmd( id, "spk valve/sound/buttons/button8" );
		return PLUGIN_HANDLED; 
	} 
	if( get_pcvar_num( g_LCMDMODE ) == 0 ) 
	{ 
		ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_BUY" );
		ChatColor( id, "%L", LANG_PLAYER, "LASERMINE_HAVE", g_havemine[ id ] + 1 );
		client_cmd( id, "spk valve/sound/buttons/button8" );
		return PLUGIN_HANDLED; 
	} 
	return PLUGIN_CONTINUE ;
} 

public native_give_lasermine( id ) {
	buy_lmines( id );
}

public plugin_natives( )
{
	register_native( "get_lasermine", "native_give_lasermine", 1 );
}

public buy_lmines( id ) { 
	if( get_pcvar_num( g_LENABLE ) == 0 ) {
		ChatColor( id,"!g[Avatar]!y LaserMine plugin bol ukonceny" );
		return PLUGIN_HANDLED; 
	} 
	
	if( !zp_get_user_survivor( id ) && !zp_get_user_zombie( id ) ) { 
		cmd_bind( id ); 
		BuyLasermine( id ); 
		return PLUGIN_CONTINUE; 	
	} 
	
	if( !zp_get_user_zombie( id ) ) { 
		client_cmd( id, "spk valve/sound/buttons/button8" );
		return PLUGIN_HANDLED;
	} 
	
	if( !zp_get_user_survivor( id ) ) { 
		client_cmd( id, "spk valve/sound/buttons/button8" );
		return PLUGIN_HANDLED; 
	} 
	return PLUGIN_CONTINUE; 
} 

public spawn_hraca( id ) {
	/*
	if( !zp_has_round_started( ) ) {
		g_havemine[ id ] = 0;
		client_print( id, print_center, "%L", LANG_PLAYER, "LASERMINE_FREE" );
		g_havemine[ id ]++; 
		emit_sound( id, CHAN_ITEM, ENT_SOUND5, VOL_NORM, ATTN_NORM, 0, PITCH_NORM ); 
	}*/
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