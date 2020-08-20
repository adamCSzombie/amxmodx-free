#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

#define ENG_NULLENT			-1
#define EV_INT_WEAPONKEY	EV_INT_impulse
#define dmp7a1_WEAPONKEY 	501
#define MAX_PLAYERS  		32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define WEAP_LINUX_XTRA_OFF		4
#define m_fKnown					44
#define m_flNextPrimaryAttack 		46
#define m_flTimeWeaponIdle			48
#define m_iClip					51
#define m_fInReload				54
#define PLAYER_LINUX_XTRA_OFF	5
#define m_flNextAttack				83

#define dmp7a1_RELOAD_TIME 			3.5
#define dmp7a1_SHOOT_LEFT1			1
#define dmp7a1_SHOOT_LEFT2			2
#define dmp7a1_SHOOT_LEFTLAST		3
#define dmp7a1_SHOOT_RIGHT1			4
#define dmp7a1_SHOOT_RIGHT2			5
#define dmp7a1_SHOOT_RIGHTLAST		6
#define dmp7a1_RELOAD				7
#define dmp7a1_DRAW					8

#define UP_SCALE			-6.0    //ббепу
#define FORWARD_SCALE	8.5     //боепед
#define RIGHT_SCALE		5.0     //бопюбн
#define LEFT_SCALE		-5.0    //бкебн
#define TE_BOUNCE_SHELL		1

#define write_coord_f(%1)	engfunc(EngFunc_WriteCoord,%1)

new const Fire_Sounds[][] = { "weapons/dmp7-1.wav" }

new dmp7a1_V_MODEL[64] = "models/bluezone/zombie/v_dmp7a1.mdl"
new dmp7a1_P_MODEL[64] = "models/bluezone/zombie/p_dmp7a1.mdl"
new dmp7a1_W_MODEL[64] = "models/bluezone/zombie/w_all_cso_wpn.mdl"

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new const dmp7a1_name[] = "weapon_dmp7a1"

new const dmp7a1_spr[][] = 
{ 
	"sprites/cso_china/640hud21.spr", 
	"sprites/cso_china/640hud7.spr"
}

new cvar_dmg_dmp7a1, cvar_recoil_dmp7a1, g_itemid_dmp7a1, cvar_clip_dmp7a1, cvar_spd_dmp7a1, cvar_dmp7a1_ammo
new g_MaxPlayers, g_orig_event_dmp7a1, g_IsInPrimaryAttack
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_has_dmp7a1[33], g_clip_ammo[33], g_dmp7a1_TmpClip[33], oldweap[33]
new gmsgWeaponList
new g_iShellModel

const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
	register_plugin("[ZP] Extra: Dual MP7A1", "1.0", "LARS-DAY[BR]EAKER")
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_event("CurWeapon","CurrentWeapon","be","1=1")
	RegisterHam(Ham_Item_AddToPlayer, "weapon_mac10", "fw_dmp7a1_AddToPlayer")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
	if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_dmp7a1_PrimaryAttack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_mac10", "fw_dmp7a1_PrimaryAttack_Post", 1)
	RegisterHam(Ham_Item_PostFrame, "weapon_mac10", "dmp7a1_ItemPostFrame")
	RegisterHam(Ham_Weapon_Reload, "weapon_mac10", "dmp7a1_Reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_mac10", "dmp7a1_Reload_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	register_forward(FM_AddToFullPack, "PlayerAddToFullPack", 1)
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

	cvar_dmg_dmp7a1 = register_cvar("zp_dmp7a1_dmgxx", "1.2")
	cvar_recoil_dmp7a1 = register_cvar("zp_dmp7a1_recoil", "1.0")
	cvar_clip_dmp7a1 = register_cvar("zp_dmp7a1_clip", "80")
	cvar_spd_dmp7a1 = register_cvar("zp_dmp7a1_spd", "0.98")
	cvar_dmp7a1_ammo = register_cvar("zp_dmp7a1_ammo", "100")
	
	g_MaxPlayers = get_maxplayers()
	gmsgWeaponList = get_user_msgid("WeaponList")
	register_clcmd(dmp7a1_name, "command_dmp7a1")
}

public plugin_precache()
{
	precache_model(dmp7a1_V_MODEL)
	precache_model(dmp7a1_P_MODEL)
	precache_model(dmp7a1_W_MODEL)
	for(new i = 0; i < sizeof Fire_Sounds; i++)
	precache_sound(Fire_Sounds[i])	
	precache_sound("weapons/dmp7_drop.wav")
	precache_sound("weapons/dmp7_draw.wav")
	precache_sound("weapons/mp7_foley2.wav")
	precache_sound("weapons/mp7_foley4.wav")
	g_iShellModel = precache_model("models/pshell.mdl")
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")

	register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)

	new sFile[64]
	formatex(sFile, charsmax(sFile), "sprites/%s.txt", dmp7a1_name)
	precache_generic(sFile)

	for(new i = 0; i < sizeof(dmp7a1_spr); i++)
	{
		precache_generic(dmp7a1_spr[i])
	}	
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	if(!is_user_alive(iAttacker))
		return

	new g_currentweapon = get_user_weapon(iAttacker)

	if(g_currentweapon != CSW_MAC10) return
	
	if(!g_has_dmp7a1[iAttacker]) return

	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	if(iEnt)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_DECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		write_short(iEnt)
		message_end()
	}
	else
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		write_coord_f(flEnd[0])
		write_coord_f(flEnd[1])
		write_coord_f(flEnd[2])
		write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
		message_end()
	}
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GUNSHOTDECAL)
	write_coord_f(flEnd[0])
	write_coord_f(flEnd[1])
	write_coord_f(flEnd[2])
	write_short(iAttacker)
	write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
	message_end()
}

public command_dmp7a1(Player)
{
	engclient_cmd(Player, "weapon_mac10")
	return PLUGIN_HANDLED
}

public zp_user_humanized_post(id)
{
	g_has_dmp7a1[id] = false
}

public plugin_natives ()
{
	register_native("get_dmp7a1", "native_give_dmp7a1", 1)
}
public native_give_weapon_add(id)
{
	give_dmp7a1(id)
}

public fwPrecacheEvent_Post(type, const name[])
{
	if (equal("events/mac10.sc", name))
	{
		g_orig_event_dmp7a1 = get_orig_retval()
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

public client_connect(id)
{
	g_has_dmp7a1[id] = false
}

public client_disconnect(id)
{
	g_has_dmp7a1[id] = false
}

public zp_user_infected_post(id)
{
	if (zp_get_user_zombie(id))
	{
		g_has_dmp7a1[id] = false
	}
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED
	
	static szClassName[33]
	entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
		
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED
	
	static iOwner
	
	iOwner = entity_get_edict(entity, EV_ENT_owner)
	
	if(equal(model, "models/w_mac10.mdl"))
	{
		static iStoredAugID
		
		iStoredAugID = find_ent_by_owner(ENG_NULLENT, "weapon_mac10", entity)
	
		if(!is_valid_ent(iStoredAugID))
			return FMRES_IGNORED
	
		if(g_has_dmp7a1[iOwner])
		{
			entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, dmp7a1_WEAPONKEY)
			
			g_has_dmp7a1[iOwner] = false
			
			entity_set_model(entity, dmp7a1_W_MODEL)
			set_pev(entity, pev_body, 8)
			
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}
public native_give_dmp7a1(id)
{
	give_dmp7a1(id)
}

public give_dmp7a1(id)
{
	drop_weapons(id, 1)
	new iWep2 = give_item(id,"weapon_mac10")
	if( iWep2 > 0 )
	{
		cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_dmp7a1))
		cs_set_user_bpammo (id, CSW_MAC10, get_pcvar_num(cvar_dmp7a1_ammo))	
		UTIL_PlayWeaponAnimation(id, dmp7a1_DRAW)
		set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)

		message_begin(MSG_ONE, gmsgWeaponList, _, id)
		write_string(dmp7a1_name)
		write_byte(6)
		write_byte(100)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(13)
		write_byte(CSW_MAC10)
		message_end()
	}
	g_has_dmp7a1[id] = true
}

public fw_dmp7a1_AddToPlayer(dmp7a1, id)
{
	if(!is_valid_ent(dmp7a1) || !is_user_connected(id))
		return HAM_IGNORED
	
	if(entity_get_int(dmp7a1, EV_INT_WEAPONKEY) == dmp7a1_WEAPONKEY)
	{
		g_has_dmp7a1[id] = true
		
		entity_set_int(dmp7a1, EV_INT_WEAPONKEY, 0)

		message_begin(MSG_ONE, gmsgWeaponList, _, id)
		write_string(dmp7a1_name)
		write_byte(6)
		write_byte(100)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(13)
		write_byte(CSW_MAC10)
		message_end()
		
		return HAM_HANDLED
	}
	else
	{
		message_begin(MSG_ONE, gmsgWeaponList, _, id)
		write_string("weapon_mac10")
		write_byte(6)
		write_byte(100)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(13)
		write_byte(CSW_MAC10)
		message_end()
	}
	return HAM_IGNORED
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	if (use_type == USE_STOPPED && is_user_connected(caller))
		replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	replace_weapon_models(owner, weaponid)
}

public CurrentWeapon(id)
{
     replace_weapon_models(id, read_data(2))

     if(read_data(2) != CSW_MAC10 || !g_has_dmp7a1[id])
          return
     
     static Float:iSpeed
     if(g_has_dmp7a1[id])
          iSpeed = get_pcvar_float(cvar_spd_dmp7a1)
     
     static weapon[32],Ent
     get_weaponname(read_data(2),weapon,31)
     Ent = find_ent_by_owner(-1,weapon,id)
     if(Ent)
     {
          static Float:Delay
          Delay = get_pdata_float( Ent, 46, 4) * iSpeed
          if (Delay > 0.0)
          {
               set_pdata_float(Ent, 46, Delay, 4)
          }
     }
}

replace_weapon_models(id, weaponid)
{
	switch (weaponid)
	{
		case CSW_MAC10:
		{
			if (zp_get_user_zombie(id) || zp_get_user_survivor(id))
				return
			
			if(g_has_dmp7a1[id])
			{
				set_pev(id, pev_viewmodel2, dmp7a1_V_MODEL)
				set_pev(id, pev_weaponmodel2, dmp7a1_P_MODEL)
				if(oldweap[id] != CSW_MAC10) 
				{
					UTIL_PlayWeaponAnimation(id, dmp7a1_DRAW)
					set_pdata_float(id, m_flNextAttack, 1.0, PLAYER_LINUX_XTRA_OFF)

					message_begin(MSG_ONE, gmsgWeaponList, _, id)
					write_string(dmp7a1_name)
					write_byte(6)
					write_byte(100)
					write_byte(-1)
					write_byte(-1)
					write_byte(0)
					write_byte(13)
					write_byte(CSW_MAC10)
					message_end()
				}
			}
		}
	}
	oldweap[id] = weaponid
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_MAC10 || !g_has_dmp7a1[Player]))
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
	return FMRES_HANDLED
}

public fw_dmp7a1_PrimaryAttack(Weapon)
{
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	if (!g_has_dmp7a1[Player])
		return
	
	g_IsInPrimaryAttack = 1
	pev(Player,pev_punchangle,cl_pushangle[Player])
	
	g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if ((eventid != g_orig_event_dmp7a1) || !g_IsInPrimaryAttack)
		return FMRES_IGNORED
	if (!(1 <= invoker <= g_MaxPlayers))
    return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE
}

public fw_dmp7a1_PrimaryAttack_Post(Weapon)
{
	g_IsInPrimaryAttack = 0
	new Player = get_pdata_cbase(Weapon, 41, 4)
	
	new szClip, szAmmo
	get_user_weapon(Player, szClip, szAmmo)
	
	if(!is_user_alive(Player))
		return

	if(g_has_dmp7a1[Player])
	{
		if (!g_clip_ammo[Player])
			return

		new Float:push[3]
		pev(Player,pev_punchangle,push)
		xs_vec_sub(push,cl_pushangle[Player],push)
		
		xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_dmp7a1),push)
		xs_vec_add(push,cl_pushangle[Player],push)
		set_pev(Player,pev_punchangle,push)
		
		emit_sound(Player, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new num
		num = random_num(1,2)
		if(num == 1)
		{
			UTIL_PlayWeaponAnimation(Player, szClip < 1 ? dmp7a1_SHOOT_LEFTLAST : random_num(dmp7a1_SHOOT_LEFT1, dmp7a1_SHOOT_LEFT2))	

			static Float:vVel[3], Float:vAngle[3], Float:vOrigin[3], Float:vViewOfs[3], 
			i, Float:vShellOrigin[3], Float:vShellVelocity[3], Float:vRight[3], 
			Float:vUp[3], Float:vForward[3]
			pev(Player, pev_velocity, vVel)
			pev(Player, pev_view_ofs, vViewOfs)
			pev(Player, pev_angles, vAngle)
			pev(Player, pev_origin, vOrigin)
			global_get(glb_v_right, vRight)
			global_get(glb_v_up, vUp)
			global_get(glb_v_forward, vForward)
			for(i = 0; i<3; i++)
			{
				vShellOrigin[i] = vOrigin[i] + vViewOfs[i] + vUp[i] * UP_SCALE + vForward[i] * FORWARD_SCALE + vRight[i] * RIGHT_SCALE
				vShellVelocity[i] = vVel[i] + vRight[i] * random_float(50.0, 70.0) + vUp[i] * random_float(100.0, 150.0) + vForward[i] * 25.0
			}
			CBaseWeapon__EjectBrass(vShellOrigin, vShellVelocity, -vAngle[1], g_iShellModel, TE_BOUNCE_SHELL)
		}
		if(num == 2)  
		{
			UTIL_PlayWeaponAnimation(Player, szClip < 1 ? dmp7a1_SHOOT_RIGHTLAST : random_num(dmp7a1_SHOOT_RIGHT1, dmp7a1_SHOOT_RIGHT2))

			static Float:vVel[3], Float:vAngle[3], Float:vOrigin[3], Float:vViewOfs[3], 
			i, Float:vShellOrigin[3], Float:vShellVelocity[3], Float:vRight[3], 
			Float:vUp[3], Float:vForward[3]
			pev(Player, pev_velocity, vVel)
			pev(Player, pev_view_ofs, vViewOfs)
			pev(Player, pev_angles, vAngle)
			pev(Player, pev_origin, vOrigin)
			global_get(glb_v_right, vRight)
			global_get(glb_v_up, vUp)
			global_get(glb_v_forward, vForward)
			for(i = 0; i<3; i++)
			{
				vShellOrigin[i] = vOrigin[i] + vViewOfs[i] + vUp[i] * UP_SCALE + vForward[i] * FORWARD_SCALE + vRight[i] * LEFT_SCALE
				vShellVelocity[i] = vVel[i] + vRight[i] * random_float(-50.0, -70.0) + vUp[i] * random_float(100.0, 150.0) + vForward[i] * 25.0
			}
			CBaseWeapon__EjectBrass(vShellOrigin, vShellVelocity, -vAngle[1], g_iShellModel, TE_BOUNCE_SHELL)
		}
	}
}

public PlayerAddToFullPack(ES_Handle, E, pEnt, pHost, bsHostFlags, pPlayer, pSet)
{       
        if(pPlayer && get_user_weapon(pEnt) == CSW_MAC10 && g_has_dmp7a1[pEnt])
        {
                static iAnim; iAnim = get_es(ES_Handle, ES_Sequence)

                switch(iAnim)
                {
                        case 16:
                        {
                                set_es(ES_Handle, ES_Sequence, iAnim += 6)
                        }
                      	case 17:
                        {
                                set_es(ES_Handle, ES_Sequence, iAnim += random_num(6, 7))
                        }
                        case 18, 19:
                        {
                                set_es(ES_Handle, ES_Sequence, iAnim += 7)
                        }
                     	case 20:
                        {
                                set_es(ES_Handle, ES_Sequence, iAnim += random_num(7, 8))
                        }
                        case 21:
                        {
                                set_es(ES_Handle, ES_Sequence, iAnim += 8)
                        }
                }
        }
        return FMRES_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if (victim != attacker && is_user_connected(attacker))
	{
		if(get_user_weapon(attacker) == CSW_MAC10)
		{
			if(g_has_dmp7a1[attacker])
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_dmp7a1))
		}
	}
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iAttacker, iVictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker) || iAttacker == iVictim)
		return PLUGIN_CONTINUE
	
	if(equal(szTruncatedWeapon, "mac10") && get_user_weapon(iAttacker) == CSW_MAC10)
	{
		if(g_has_dmp7a1[iAttacker])
			set_msg_arg_string(4, "dmp7a1")
	}
	return PLUGIN_CONTINUE
}

stock fm_cs_get_current_weapon_ent(id)
{
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

public dmp7a1_ItemPostFrame(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_dmp7a1[id])
          return HAM_IGNORED

     static iClipExtra
     
     iClipExtra = get_pcvar_num(cvar_clip_dmp7a1)
     new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

     new iBpAmmo = cs_get_user_bpammo(id, CSW_MAC10)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 

     if( fInReload && flNextAttack <= 0.0 )
     {
	     new j = min(iClipExtra - iClip, iBpAmmo)
	
	     set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
	     cs_set_user_bpammo(id, CSW_MAC10, iBpAmmo-j)
		
	     set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
	     fInReload = 0
     }
     return HAM_IGNORED
}

public dmp7a1_Reload(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_dmp7a1[id])
          return HAM_IGNORED

     static iClipExtra

     if(g_has_dmp7a1[id])
          iClipExtra = get_pcvar_num(cvar_clip_dmp7a1)

     g_dmp7a1_TmpClip[id] = -1

     new iBpAmmo = cs_get_user_bpammo(id, CSW_MAC10)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     if (iBpAmmo <= 0)
          return HAM_SUPERCEDE

     if (iClip >= iClipExtra)
          return HAM_SUPERCEDE

     g_dmp7a1_TmpClip[id] = iClip

     return HAM_IGNORED
}

public dmp7a1_Reload_Post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	if (!is_user_connected(id))
		return HAM_IGNORED

	if (!g_has_dmp7a1[id])
		return HAM_IGNORED

	if (g_dmp7a1_TmpClip[id] == -1)
		return HAM_IGNORED

	set_pdata_int(weapon_entity, m_iClip, g_dmp7a1_TmpClip[id], WEAP_LINUX_XTRA_OFF)

	set_pdata_float(weapon_entity, m_flTimeWeaponIdle, dmp7a1_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)

	set_pdata_float(id, m_flNextAttack, dmp7a1_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)

	set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

	UTIL_PlayWeaponAnimation(id, dmp7a1_RELOAD)

	return HAM_IGNORED
}

CBaseWeapon__EjectBrass(Float:vecOrigin[3], Float:vecVelocity[3], Float:rotation, model, soundtype)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_MODEL)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2])
	engfunc(EngFunc_WriteCoord, vecVelocity[0])
	engfunc(EngFunc_WriteCoord, vecVelocity[1])
	engfunc(EngFunc_WriteCoord, vecVelocity[2])
	engfunc(EngFunc_WriteAngle, rotation)
	write_short(model)
	write_byte(soundtype)
	write_byte(25) // 2.5 seconds
	message_end()
}

stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          
          if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
}
