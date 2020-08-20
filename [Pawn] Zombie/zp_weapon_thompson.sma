#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

enum
{
        anim_idle,
        anim_reload,
        anim_draw,
        anim_shoot1,
        anim_shoot2,
        anim_shoot3
}
 
#define ENG_NULLENT             -1
#define EV_INT_WEAPONKEY        EV_INT_impulse
#define tomi_WEAPONKEY     9142
#define MAX_PLAYERS                       32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)
 
const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 5
 
#define WEAP_LINUX_XTRA_OFF                     4
#define m_fKnown                                44
#define m_flNextPrimaryAttack                   46
#define m_flTimeWeaponIdle                      48
#define m_iClip                                 51
#define m_fInReload                             54
#define PLAYER_LINUX_XTRA_OFF                   5
#define m_flNextAttack                          83
 
#define tomi_RELOAD_TIME 4.0
 
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_P90)|(1<<CSW_P90)|(1<<CSW_P90)|(1<<CSW_SG550)|(1<<CSW_P90)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_P90)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_P90)|(1<<CSW_AK47)|(1<<CSW_P90)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_p90",
                        "weapon_p90", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_p90", "weapon_sg550",
                        "weapon_p90", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_p90", "weapon_m249",
                        "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_p90",
                        "weapon_ak47", "weapon_knife", "weapon_p90" }

new const Fire_Sounds[][] = { "weapons/thompson-1.wav" }

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new tomi_V_MODEL[64] = "models/v_thompson.mdl"
new tomi_P_MODEL[64] = "models/p_thompson.mdl"
new tomi_W_MODEL[64] = "models/cso_cz/w_th.mdl"

new cvar_dmg_tomi, cvar_recoil_tomi, cvar_clip_tomi, cvar_tomi_ammo , cvar_dmg_tomi2
new g_has_tomi[33]
new g_MaxPlayers, g_orig_event_tomi, g_clip_ammo[33] , g_reload[33]
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_tomi_TmpClip[33]
new g_mode[33] , g_mode2[33]
new g_itemid
new g_hasZoom[33]
public plugin_init()
{
        register_plugin("Thompson", "1.1", "Gazik")
        register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
        register_event("CurWeapon","CurrentWeapon","be","1=1")
        RegisterHam(Ham_Item_AddToPlayer, "weapon_p90", "fw_tomi_AddToPlayer")
        RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
        RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
        RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
        RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
        for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
                if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
        RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_tomi_PrimaryAttack")
        RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_p90", "fw_tomi_PrimaryAttack_Post", 1)
        RegisterHam(Ham_Item_PostFrame, "weapon_p90", "tomi__ItemPostFrame");
        RegisterHam(Ham_Weapon_Reload, "weapon_p90", "tomi__Reload");
        RegisterHam(Ham_Weapon_Reload, "weapon_p90", "tomi__Reload_Post", 1);
        register_forward(FM_CmdStart, "fw_CmdStart")
        RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
        register_forward(FM_SetModel, "fw_SetModel")
        register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
        register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
 
        cvar_dmg_tomi = register_cvar("tomi_dmgdd", "1.75")
        cvar_dmg_tomi2 = register_cvar("tomi_dmg_sniperd", "1.3")
        cvar_recoil_tomi = register_cvar("tomi_recoil", "0.5")
        cvar_clip_tomi = register_cvar("tomi_clip", "50")
        cvar_tomi_ammo = register_cvar("tomi_ammo", "100")
 
        g_MaxPlayers = get_maxplayers()
}
 
public plugin_precache()
{
        precache_model(tomi_V_MODEL)
        precache_model(tomi_P_MODEL)
        precache_model(tomi_W_MODEL)

        precache_sound(Fire_Sounds[0])
        m_iBlood[0] = precache_model("sprites/blood.spr")
        m_iBlood[1] = precache_model("sprites/bloodspray.spr")
        precache_model("sprites/640hud5.spr")
        register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}

public plugin_natives ()
{
        register_native("get_thompson", "native_give_weapon_add", 1)
}

public native_give_weapon_add(id)
{
	give_tomi(id)
}

public native_give_weapon_add2(id)
{
	return g_has_tomi[id]
}

public fwPrecacheEvent_Post(type, const name[])
{
        if (equal("events/p90.sc", name))
        {
                g_orig_event_tomi = get_orig_retval()
                return FMRES_HANDLED
        }
        
        return FMRES_IGNORED
}
 
public client_connect(id)
{
        g_has_tomi[id] = false
}
 
public client_disconnect(id)
{
        g_has_tomi[id] = false
}
 
public fw_SetModel(entity, model[])
{
        if(!is_valid_ent(entity))
                return FMRES_IGNORED;
        
        static szClassName[33]
        entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
                
        if(!equal(szClassName, "weaponbox"))
                return FMRES_IGNORED;
        
        static iOwner
        
        iOwner = entity_get_edict(entity, EV_ENT_owner)
        
        if(equal(model, "models/w_p90.mdl"))
        {
                static iStoredSVDID
                
                iStoredSVDID = find_ent_by_owner(ENG_NULLENT, "weapon_p90", entity)
        
                if(!is_valid_ent(iStoredSVDID))
                        return FMRES_IGNORED;
        
                if(g_has_tomi[iOwner])
                {
                        entity_set_int(iStoredSVDID, EV_INT_WEAPONKEY, tomi_WEAPONKEY)
                        g_has_tomi[iOwner] = false
                        
                        entity_set_model(entity, tomi_W_MODEL)
                        
                        return FMRES_SUPERCEDE;
                }
        }
        
        
        return FMRES_IGNORED;
}

public give_tomi(id)
{
        drop_weapons(id, 1);
        new iWep2 = give_item(id,"weapon_p90")
        if( iWep2 > 0 )
        {
        	cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_tomi))
        	cs_set_user_bpammo (id, CSW_P90, get_pcvar_num(cvar_tomi_ammo))
        }
        g_has_tomi[id] = true;
}
 
public fw_tomi_AddToPlayer(tomi, id)
{
        if(!is_valid_ent(tomi) || !is_user_connected(id))
                return HAM_IGNORED;
        
        if(entity_get_int(tomi, EV_INT_WEAPONKEY) == tomi_WEAPONKEY)
        {
                g_has_tomi[id] = true
                
                entity_set_int(tomi, EV_INT_WEAPONKEY, 0)
                
                return HAM_HANDLED;
        }
        
        return HAM_IGNORED;
}
 
public fw_CmdStart(id, uc_handle, seed)
{
        if(id > 0 && id < 33)
        {
        if(!is_user_alive(id)) 
        return PLUGIN_HANDLED
        if(get_user_weapon(id) == CSW_P90 && g_has_tomi[id])
        {
        if((get_uc(uc_handle, UC_Buttons) & IN_USE) && !(pev(id, pev_oldbuttons) & IN_USE) && g_reload[id] == 0 && g_mode2[id] == 0)
        {
                if(!g_hasZoom[id])
                {
                        g_hasZoom[id] = true
                        cs_set_user_zoom(id, CS_SET_AUGSG552_ZOOM, 1)
                }else{
                        g_hasZoom[ id ] = false
                        cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
                }
                if (!g_mode[id])
                {
                        g_hasZoom[id] = false
                        cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
                }
        }
 
        if (g_hasZoom[ id ] && (pev(id, pev_button) & IN_RELOAD))
        {
                g_hasZoom[ id ] = false
                cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
        }
 
	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2) && !g_mode2[id] && !g_reload[id])
                {
              		g_hasZoom[ id ] = false
                	cs_set_user_zoom( id, CS_RESET_ZOOM, 0 )
                	if(g_mode[id] == 0) make_mode2(id)
                	if(g_mode[id] == 2) make_mode1(id)
                }
        }
        return HAM_SUPERCEDE;
        }
        return PLUGIN_HANDLED
}

public make_mode2(id)
{
	set_task(0.000001,"mode_new2",id)
	g_mode2[id] = 1
	UTIL_PlayWeaponAnimation(id, 6)
	set_pdata_float(id, m_flNextAttack, 0.000001, PLAYER_LINUX_XTRA_OFF)
}

public make_mode1(id)
{
	set_task(0.000001,"mode_new1",id)
	g_mode2[id] = 1
	UTIL_PlayWeaponAnimation(id, 6)
	set_pdata_float(id, m_flNextAttack, 0.000001, PLAYER_LINUX_XTRA_OFF)
}

public mode_new2(id)
{
	if(g_mode2[id] == 1 && is_user_alive(id))
	{
		g_mode2[id] = 0
		g_mode[id] = 2
		client_print(id,print_center,"[Spomalena strelba]")
	}
}

public mode_new1(id)
{
	if(g_mode2[id] == 1 && is_user_alive(id))
	{
		g_mode2[id] = 0
		g_mode[id] = 0
		client_print(id,print_center,"[Automatika]")
	}
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
        remove_task(id)
        g_reload[id] = 0
        g_mode2[id] = 0
}
 
replace_weapon_models(id, weaponid)
{
        switch (weaponid)
        {
                case CSW_P90:
                {
                        if(g_has_tomi[id])
                        {
                                if(g_mode[id] == 0) set_pev(id, pev_viewmodel2, tomi_V_MODEL)
                                if(g_mode[id] == 2) set_pev(id, pev_viewmodel2, tomi_V_MODEL)
                                set_pev(id, pev_weaponmodel2, tomi_P_MODEL)
                        }
                }
        }
}
 
public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
        if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_P90) || !g_has_tomi[Player])
        return FMRES_IGNORED
        
        set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.00001)
        return FMRES_HANDLED
}
 
public fw_tomi_PrimaryAttack(Weapon)
{
        new Player = get_pdata_cbase(Weapon, 41, 4)
        
        if (!g_has_tomi[Player])
                return;
        
        pev(Player,pev_punchangle,cl_pushangle[Player])
        
        g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
}
 
public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
        if ((eventid != g_orig_event_tomi))
                return FMRES_IGNORED
        if (!(1 <= invoker <= g_MaxPlayers))
                return FMRES_IGNORED
 
        playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
        return FMRES_SUPERCEDE
}
 
public fw_tomi_PrimaryAttack_Post(Weapon)
{
        new Player = get_pdata_cbase(Weapon, 41, 4)
        
        new szClip, szAmmo
        get_user_weapon(Player, szClip, szAmmo)
        if(Player > 0 && Player < 33)
        {
        if(!g_has_tomi[Player])
        {
        if(szClip > 0) emit_sound(Player, CHAN_WEAPON, "weapons/p90-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
        }
        if(g_has_tomi[Player])
        {
                new Float:push[3]
                pev(Player,pev_punchangle,push)
                xs_vec_sub(push,cl_pushangle[Player],push)
                
                xs_vec_mul_scalar(push,get_pcvar_float(cvar_recoil_tomi),push)
                xs_vec_add(push,cl_pushangle[Player],push)
                set_pev(Player,pev_punchangle,push)
                
                if (!g_clip_ammo[Player])
                        return
                
                emit_sound(Player, CHAN_WEAPON, Fire_Sounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                UTIL_PlayWeaponAnimation(Player, 3)
        
                make_blood_and_bulletholes(Player)
                if(g_mode[Player] == 2) set_pdata_float(Player, m_flNextAttack, 0.3, PLAYER_LINUX_XTRA_OFF)
        }
        }
}
 
public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
        if (victim != attacker && is_user_connected(attacker))
        {
                if(get_user_weapon(attacker) == CSW_P90)
                {
                        if(g_has_tomi[attacker])
                        {
                        if(g_mode[attacker] == 2) SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_tomi2))
                        if(g_mode[attacker] == 0) SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_tomi))
                        }
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
        
        if(equal(szTruncatedWeapon, "p90") && get_user_weapon(iAttacker) == CSW_P90)
        {
                if(g_has_tomi[iAttacker])
                        set_msg_arg_string(4, "p90")
        }
                
        return PLUGIN_CONTINUE
}
 
stock fm_cs_get_current_weapon_ent(id)
{
        return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}
 
stock fm_cs_get_weapon_ent_owner(ent)
{
        return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}
 
stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
        set_pev(Player, pev_weaponanim, Sequence)
        
        message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
        write_byte(Sequence)
        write_byte(pev(Player, pev_body))
        message_end()
}
 
stock make_blood_and_bulletholes(id)
{
        new aimOrigin[3], target, body
        get_user_origin(id, aimOrigin, 3)
        get_user_aiming(id, target, body)
        
        if(target > 0 && target <= g_MaxPlayers)
        {
                new Float:fStart[3], Float:fEnd[3], Float:fRes[3], Float:fVel[3]
                pev(id, pev_origin, fStart)
                
                velocity_by_aim(id, 64, fVel)
                
                fStart[0] = float(aimOrigin[0])
                fStart[1] = float(aimOrigin[1])
                fStart[2] = float(aimOrigin[2])
                fEnd[0] = fStart[0]+fVel[0]
                fEnd[1] = fStart[1]+fVel[1]
                fEnd[2] = fStart[2]+fVel[2]
                
                new res
                engfunc(EngFunc_TraceLine, fStart, fEnd, 0, target, res)
                get_tr2(res, TR_vecEndPos, fRes)
                
                message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
                write_byte(TE_BLOODSPRITE)
                write_coord(floatround(fStart[0])) 
                write_coord(floatround(fStart[1])) 
                write_coord(floatround(fStart[2])) 
                write_short( m_iBlood [ 1 ])
                write_short( m_iBlood [ 0 ] )
                write_byte(70)
                write_byte(random_num(1,2))
                message_end()
                
                
        } 
        else if(!is_user_connected(target))
        {
                if(target)
                {
                        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
                        write_byte(TE_DECAL)
                        write_coord(aimOrigin[0])
                        write_coord(aimOrigin[1])
                        write_coord(aimOrigin[2])
                        write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
                        write_short(target)
                        message_end()
                } 
                else 
                {
                        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
                        write_byte(TE_WORLDDECAL)
                        write_coord(aimOrigin[0])
                        write_coord(aimOrigin[1])
                        write_coord(aimOrigin[2])
                        write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
                        message_end()
                }
                
                message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
                write_byte(TE_GUNSHOTDECAL)
                write_coord(aimOrigin[0])
                write_coord(aimOrigin[1])
                write_coord(aimOrigin[2])
                write_short(id)
                write_byte(GUNSHOT_DECALS[random_num ( 0, sizeof GUNSHOT_DECALS -1 ) ] )
                message_end()
        }
}
 
public tomi__ItemPostFrame(weapon_entity) {
        new id = pev(weapon_entity, pev_owner)
        if (!is_user_connected(id))
                return HAM_IGNORED;
 
        if (!g_has_tomi[id])
                return HAM_IGNORED;
 
        new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)
 
        new iBpAmmo = cs_get_user_bpammo(id, CSW_P90);
        new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
 
        new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 
 
        if( fInReload && flNextAttack <= 0.0 )
        {
                new j = min(get_pcvar_num(cvar_clip_tomi) - iClip, iBpAmmo)
        
                set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
                cs_set_user_bpammo(id, CSW_P90, iBpAmmo-j);
                
                set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
                fInReload = 0
                g_reload[id] = 0
        }
 
        return HAM_IGNORED;
}
 
public tomi__Reload(weapon_entity) {
        new id = pev(weapon_entity, pev_owner)
        if (!is_user_connected(id))
                return HAM_IGNORED;
 
        if (!g_has_tomi[id])
                return HAM_IGNORED;
 
        g_tomi_TmpClip[id] = -1;
 
        new iBpAmmo = cs_get_user_bpammo(id, CSW_P90);
        new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)
 
        if (iBpAmmo <= 0)
                return HAM_SUPERCEDE;
 
        if (iClip >= get_pcvar_num(cvar_clip_tomi))
                return HAM_SUPERCEDE;
 
 
        g_tomi_TmpClip[id] = iClip;
 
        g_reload[id] = 1
 
        return HAM_IGNORED;
}
 
public tomi__Reload_Post(weapon_entity) {
        new id = pev(weapon_entity, pev_owner)
        if (!is_user_connected(id))
                return HAM_IGNORED;
 
        if (!g_has_tomi[id])
                return HAM_IGNORED;
 
        if (g_tomi_TmpClip[id] == -1)
                return HAM_IGNORED;
 
        set_pdata_int(weapon_entity, m_iClip, g_tomi_TmpClip[id], WEAP_LINUX_XTRA_OFF)
 
        set_pdata_float(weapon_entity, m_flTimeWeaponIdle, tomi_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)
 
        set_pdata_float(id, m_flNextAttack, tomi_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)
 
        set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)
 
        // relaod animation
        UTIL_PlayWeaponAnimation(id, 1)
 
        return HAM_IGNORED;
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
