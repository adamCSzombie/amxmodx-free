#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <xs>
#include <zombieplague>

#define PLUGIN "[ZP] Extra Item: Cannon"
#define VERSION "1.0"
#define AUTHOR "Dias"

#define CSW_CANNON CSW_M249
#define CANNONFIRE_CLASSNAME "cannon_fire"

new const v_model[] = "models/bluezone/zombie/v_cannon.mdl"
new const p_model[] = "models/bluezone/zombie/p_cannon.mdl"
new const w_model[] = "models/bluezone/zombie/w_cannon.mdl"
new const cannon_sound[2][] = {
	"weapons/cannon-1.wav", // Fire Sound
	"weapons/cannon_draw.wav" // Draw Sound
}
new const fire_sprite[] = "sprites/playaspro.spr"
new g_had_cannon[33], Float:g_last_fire[33], g_reloading[33], g_fired[500][33]
new g_item_cannon

new cvar_ammo, cvar_firedelay, cvar_dmgrandom_start, cvar_dmgrandom_end

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "event_curweapon", "be", "1=1")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_think(CANNONFIRE_CLASSNAME, "fw_think")
	register_forward(FM_Touch, "fw_touch")
	register_forward(FM_SetModel, "fw_SetModel")
	
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "fw_deploy_post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_m249", "fw_reload")
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "fw_item_addtoplayer", 1)
	
	cvar_ammo = register_cvar("zp_dcannon_ammo", "200")
	cvar_firedelay = register_cvar("zp_firedelayd", "3.8")
	cvar_dmgrandom_start = register_cvar("zp_dmgrandom_startd", "1100.0")
	cvar_dmgrandom_end = register_cvar("zp_dmgrandom_endd", "400.0")
	register_clcmd("lastinv", "lastinv_cannon")
}

public plugin_natives()
{
	register_native("get_dragon", "native_get_dragon", 1)
}

public plugin_precache()
{
	precache_model(v_model)
	precache_model(p_model)
	precache_model(w_model)
	precache_model(fire_sprite)
	
	for(new i = 0; i < sizeof(cannon_sound); i++)
		precache_sound(cannon_sound[i])
}

public native_get_dragon(id)
{
		
	g_had_cannon[id] = 1
	g_reloading[id] = 0
	
	give_item(id, "weapon_m249")
	
	static ent
	ent = find_ent_by_owner(-1, "weapon_m249", id)	
	
	cs_set_weapon_ammo(ent, 0)
	cs_set_user_bpammo(id, CSW_CANNON, get_pcvar_num(cvar_ammo))
	
	play_weapon_anim(id, 3)
	
	return PLUGIN_CONTINUE
}

public lastinv_cannon(id)
{
	set_task(0.01, "check_lastinv", id)
}

public check_lastinv(id)
{
	if(is_user_alive(id) && !zp_get_user_zombie(id) && get_user_weapon(id) == CSW_CANNON && g_had_cannon[id])
	{
		play_weapon_anim(id, 3)
	}	
}

public event_curweapon(id)
{
	if(!is_user_alive(id) || !is_user_connected(id) || zp_get_user_zombie(id))
		return PLUGIN_HANDLED
	if(get_user_weapon(id) != CSW_CANNON || !g_had_cannon[id])
		return PLUGIN_HANDLED
	
	set_pev(id, pev_viewmodel2, v_model)
	set_pev(id, pev_weaponmodel2, p_model)
	
	return PLUGIN_CONTINUE
}

public zp_user_infected_post(id)
{
	g_had_cannon[id] = 0
	g_reloading[id] = 0	
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!is_user_alive(id) || !is_user_connected(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED
	
	if(get_user_weapon(id) != CSW_CANNON || !g_had_cannon[id])
		return FMRES_IGNORED
	
	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001)  
	
	return FMRES_HANDLED
}

public fw_CmdStart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED
	
	if(get_user_weapon(id) != CSW_CANNON || !g_had_cannon[id])
		return FMRES_IGNORED
	
	static Button
	Button = get_uc(uc_handle, UC_Buttons)
	
	if(Button & IN_ATTACK)
	{
		if(cs_get_user_bpammo(id, CSW_CANNON) <= 0)
		{			
			return FMRES_IGNORED
		}
		
		static Float:CurTime
		CurTime = get_gametime()
		
		if(CurTime - get_pcvar_float(cvar_firedelay) > g_last_fire[id])
		{
			play_weapon_anim(id, random_num(1, 2))
			emit_sound(id, CHAN_WEAPON, cannon_sound[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			cs_set_user_bpammo(id, CSW_CANNON, cs_get_user_bpammo(id, CSW_CANNON) - 1)
			prepare_makefire(id)
			
			g_last_fire[id] = CurTime
		}
	}
	
	// Remove the button
	Button &= ~IN_ATTACK
	set_uc(uc_handle, UC_Buttons, Button)
	
	Button &= ~IN_RELOAD
	set_uc(uc_handle, UC_Buttons, Button)
	
	return FMRES_HANDLED
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
	
	if(equal(model, "models/w_m249.mdl"))
	{
		static ent
		ent = find_ent_by_owner(-1, "weapon_m249", entity)
		
		if(!is_valid_ent(ent))
			return FMRES_IGNORED;
		
		if(g_had_cannon[iOwner])
		{
			entity_set_int(ent, EV_INT_impulse, 1028)
			g_had_cannon[iOwner] = false
			set_pev(ent, pev_iuser3, cs_get_user_bpammo(iOwner, CSW_CANNON))
			entity_set_model(entity, w_model)
			
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public fw_item_addtoplayer(ent, id)
{
	if(!is_valid_ent(ent))
		return HAM_IGNORED
		
	if(zp_get_user_zombie(id))
		return HAM_IGNORED
			
	if(entity_get_int(ent, EV_INT_impulse) == 1028)
	{
		g_had_cannon[id] = true
		cs_set_user_bpammo(id, CSW_CANNON, pev(ent, pev_iuser3))
		cs_set_weapon_ammo(ent, 0)
		
		entity_set_int(id, EV_INT_impulse, 0)
		
		ExecuteHam(Ham_Item_Deploy, ent)

		return HAM_HANDLED
	}		

	return HAM_HANDLED
}

public prepare_makefire(id)
{
	static Float:VicOrigin[10][3], Float:TempOrigin[3], Float:Angles[3]
	
	pev(id, pev_angles, Angles)
	fm_get_aim_origin(id, TempOrigin)
	
	if((Angles[1] < 45.0 && Angles[1] > -45.0) || (Angles[1] < -125.0 && Angles[1] < 0) || (Angles[1] > -179.0 && Angles[1] > 100.0))
	{
		VicOrigin[0][0] = TempOrigin[0]
		VicOrigin[0][1] = TempOrigin[1]
		VicOrigin[0][2] = TempOrigin[2]
	
		VicOrigin[1][0] = TempOrigin[0]
		VicOrigin[1][1] = TempOrigin[1] + 50.0
		VicOrigin[1][2] = TempOrigin[2]
	
		VicOrigin[2][0] = TempOrigin[0]
		VicOrigin[2][1] = TempOrigin[1] - 50.0
		VicOrigin[2][2] = TempOrigin[2]	
		
		VicOrigin[3][0] = TempOrigin[0]
		VicOrigin[3][1] = TempOrigin[1] + 100.0
		VicOrigin[3][2] = TempOrigin[2]
	
		VicOrigin[4][0] = TempOrigin[0]
		VicOrigin[4][1] = TempOrigin[1] - 100.0
		VicOrigin[4][2] = TempOrigin[2]		
	
		VicOrigin[5][0] = TempOrigin[0]
		VicOrigin[5][1] = TempOrigin[1] + 150.0
		VicOrigin[5][2] = TempOrigin[2]
	
		VicOrigin[6][0] = TempOrigin[0]
		VicOrigin[6][1] = TempOrigin[1] - 150.0
		VicOrigin[6][2] = TempOrigin[2]	
		
		VicOrigin[7][0] = TempOrigin[0]
		VicOrigin[7][1] = TempOrigin[1] + 200.0
		VicOrigin[7][2] = TempOrigin[2]
	
		VicOrigin[8][0] = TempOrigin[0]
		VicOrigin[8][1] = TempOrigin[1] - 250.0
		VicOrigin[8][2] = TempOrigin[2]		
		
		VicOrigin[9][0] = TempOrigin[0]
		VicOrigin[9][1] = TempOrigin[1] - 250.0
		VicOrigin[9][2] = TempOrigin[2]			
	} else {
		VicOrigin[0][0] = TempOrigin[0]
		VicOrigin[0][1] = TempOrigin[1]
		VicOrigin[0][2] = TempOrigin[2]
	
		VicOrigin[1][0] = TempOrigin[0] + 50.0
		VicOrigin[1][1] = TempOrigin[1]
		VicOrigin[1][2] = TempOrigin[2]
	
		VicOrigin[2][0] = TempOrigin[0] - 50.0
		VicOrigin[2][1] = TempOrigin[1]
		VicOrigin[2][2] = TempOrigin[2]	
		
		VicOrigin[3][0] = TempOrigin[0] + 100.0
		VicOrigin[3][1] = TempOrigin[1] 
		VicOrigin[3][2] = TempOrigin[2]
	
		VicOrigin[4][0] = TempOrigin[0] - 100.0
		VicOrigin[4][1] = TempOrigin[1]
		VicOrigin[4][2] = TempOrigin[2]		
	
		VicOrigin[5][0] = TempOrigin[0] + 150.0
		VicOrigin[5][1] = TempOrigin[1]
		VicOrigin[5][2] = TempOrigin[2]
	
		VicOrigin[6][0] = TempOrigin[0] - 150.0
		VicOrigin[6][1] = TempOrigin[1]
		VicOrigin[6][2] = TempOrigin[2]	
		
		VicOrigin[7][0] = TempOrigin[0] + 200.0
		VicOrigin[7][1] = TempOrigin[1]
		VicOrigin[7][2] = TempOrigin[2]
	
		VicOrigin[8][0] = TempOrigin[0] - 250.0
		VicOrigin[8][1] = TempOrigin[1] 
		VicOrigin[8][2] = TempOrigin[2]		
		
		VicOrigin[9][0] = TempOrigin[0] - 250.0
		VicOrigin[9][1] = TempOrigin[1]
		VicOrigin[9][2] = TempOrigin[2]				
	}
	
	for(new i = 0; i < sizeof(VicOrigin); i++)
	{
		make_fire(id, VicOrigin[i])
	}
}

public make_fire(id, Float:VicOrigin[3])
{
	new iEnt = create_entity("env_sprite")
	static Float:vfVelocity[3], Float:vfAttack[3], Float:vfAngle[3]
	
	get_weapon_attachment(id, vfAttack, 30.0)
	pev(id, pev_angles, vfAngle)
	
	// random angle
	vfAngle[2] = float(random(18) * 20)

	get_speed_vector(vfAttack, VicOrigin, 1000.0, vfVelocity)
	
	// set info for ent
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	set_pev(iEnt, pev_rendermode, kRenderTransAdd)
	set_pev(iEnt, pev_renderamt, 250.0)
	set_pev(iEnt, pev_fuser1, get_gametime() + 1.0)	// time remove
	set_pev(iEnt, pev_scale, 2.0)
	set_pev(iEnt, pev_nextthink, halflife_time() + 0.05)
	
	entity_set_string(iEnt, EV_SZ_classname, CANNONFIRE_CLASSNAME)
	engfunc(EngFunc_SetModel, iEnt, fire_sprite)
	set_pev(iEnt, pev_mins, Float:{-10.0, -10.0, -5.0})
	set_pev(iEnt, pev_maxs, Float:{10.0, 10.0, 10.0})
	set_pev(iEnt, pev_origin, vfAttack)
	set_pev(iEnt, pev_gravity, 0.01)
	set_pev(iEnt, pev_velocity, vfVelocity)
	set_pev(iEnt, pev_angles, vfAngle)
	set_pev(iEnt, pev_solid, 1)
	set_pev(iEnt, pev_owner, id)
	
	for(new i = 1; i < get_maxplayers(); i++)
	{
		if(is_user_alive(i))
			g_fired[iEnt][i] = 0
	}
}

public fw_think(iEnt)
{
	if(!pev_valid(iEnt)) 
		return
	
	new Float:fFrame, Float:fNextThink
	pev(iEnt, pev_frame, fFrame)
	
	// effect exp
	new iMoveType = pev(iEnt, pev_movetype)
	if (iMoveType == MOVETYPE_NONE)
	{
		fNextThink = 0.0015
		fFrame += 1.0
		
		if (fFrame > 21.0)
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return
		}
	}
	
	// effect normal
	else
	{
		fNextThink = 0.045
		fFrame += 1.0
		fFrame = floatmin(21.0, fFrame)
	}
	
	set_pev(iEnt, pev_frame, fFrame)
	set_pev(iEnt, pev_nextthink, halflife_time() + fNextThink)
	
	// time remove
	new Float:fTimeRemove
	pev(iEnt, pev_fuser1, fTimeRemove)
	if (get_gametime() >= fTimeRemove)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		return;
	}
}

public fw_touch(ent, id)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED
		
	static classname[32], classname2[32]
	
	pev(ent, pev_classname, classname, sizeof(classname))
	pev(id, pev_classname, classname2, sizeof(classname2))
	
	if(!equal(classname, CANNONFIRE_CLASSNAME) || equal(classname2, CANNONFIRE_CLASSNAME) || pev(ent, pev_owner) == id)
		return FMRES_IGNORED
	
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	set_pev(ent, pev_solid, SOLID_NOT)	
	
	if(!is_valid_ent(id))
		return FMRES_IGNORED
	
	if(!is_user_alive(id) || !is_user_connected(id))
		return FMRES_IGNORED
		
	if(!zp_get_user_zombie(id))
		return FMRES_IGNORED
	
	if(g_fired[ent][id] == 0)
	{
		g_fired[ent][id] = 1
		
		static attacker
		attacker = pev(ent, pev_owner)
		
		ExecuteHam(Ham_TakeDamage, id, 0, attacker, random_float(get_pcvar_float(cvar_dmgrandom_start), get_pcvar_float(cvar_dmgrandom_end)), DMG_BULLET)		
	}
	
	return FMRES_HANDLED
}

public fw_reload(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	if(is_user_alive(id) && !zp_get_user_zombie(id) && get_user_weapon(id) == CSW_CANNON && g_had_cannon[id])
		return HAM_SUPERCEDE
	
	return HAM_HANDLED
}

public fw_deploy_post(ent)
{
	static id
	id = pev(ent, pev_owner)
	
	check_lastinv(id)
}

stock play_weapon_anim(player, anim)
{
	set_pev(player, pev_weaponanim, anim)
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	new Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	new Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	new Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	new Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

//from fakemeta_util.inc
stock fm_get_aim_origin(index, Float:origin[3])
{
	static Float:start[3], Float:view_ofs[3]
	pev(index, pev_origin, start)
	pev(index, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)
	
	static Float:dest[3]
	pev(index, pev_v_angle, dest)
	engfunc(EngFunc_MakeVectors, dest)
	global_get(glb_v_forward, dest)
	xs_vec_mul_scalar(dest, 9999.0, dest)
	xs_vec_add(start, dest, dest)
	
	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0)
	get_tr2(0, TR_vecEndPos, origin)
	
	return 1
}
