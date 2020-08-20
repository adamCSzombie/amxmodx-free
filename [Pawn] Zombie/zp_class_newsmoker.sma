
#include < amxmodx >
#include < zombieplague >
#include < fakemeta >
#include < hamsandwich >
#include < engine >

#define PLUGIN "[ZP] Class Smoker"
#define VERSION "1.3"
#define AUTHOR "4eRT"

new g_zclass_smoker, g_Line;

new g_sndMiss[ ] = "zombie_plague/Smoker_TongueHit_miss.wav";
new g_sndDrag[ ] = "zombie_plague/Smoker_TongueHit_drag.wav";

new g_hooked[ 33 ], g_hooksLeft[ 33 ], g_unable2move[ 33 ], g_ovr_dmg[ 33 ];
new Float:g_lastHook[ 33 ];
new bool: g_bind_use[ 33 ] = false, bool: g_bind_or_not[ 33 ] = false, bool: g_drag_i[ 33 ] = false

new cvar_maxdrags, cvar_dragspeed, cvar_cooldown, cvar_dmg2stop, cvar_mates, cvar_extrahook, cvar_unb2move, cvar_nemesis, cvar_survivor

new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3

new const zclass_name[ ] = { "Smoker Zombie" }
new const zclass_info[ ] = { "[pritahuje ludi]" }
new const zclass_model[ ] = { "profun_smoker" }
new const zclass_clawmodel[ ] = { "v_profun_smoker.mdl" }
const zclass_health = 1350;
const zclass_speed = 250;
const Float:zclass_gravity = 1.0;
const Float:zclass_knockback = 1.0;

new g_item, g_immunita[ 33 ];

public plugin_init()
{
	cvar_dragspeed = register_cvar("zp_smoker_dragspeed", "160")
	cvar_maxdrags = register_cvar("zp_smoker_maxdrags", "4")
	cvar_cooldown = register_cvar("zp_smoker_cooldown", "5")
	cvar_dmg2stop = register_cvar("zp_smoker_dmg2stop", "300")
	cvar_mates = register_cvar("zp_smoker_mates", "0")
	cvar_extrahook = register_cvar("zp_smoker_extrahook", "2")
	cvar_unb2move = register_cvar("zp_smoker_unable_move", "1")
	cvar_nemesis = register_cvar("zp_smoker_nemesis", "0")
	cvar_survivor = register_cvar("zp_smoker_survivor", "1")
	register_event("ResetHUD", "newSpawn", "b")
	register_event("DeathMsg", "smoker_death", "a")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward( FM_CmdStart , "fw_FM_CmdStart" )
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	register_clcmd("+drag","drag_start", ADMIN_USER, "bind ^"key^" ^"+drag^"")
	register_clcmd("-drag","drag_end")
	g_item = zp_register_extra_item( "Anti-Smoker \d(jedno kolo)\y", 50, ZP_TEAM_HUMAN )
	//register_menucmd(register_menuid(""), keys, "bind_v_key")
}
public plugin_precache()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_zclass_smoker = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
	precache_sound(g_sndDrag)
	precache_sound(g_sndMiss)
	g_Line = precache_model("sprites/zbeam4.spr")
}

public zp_extra_item_selected( id, itemid ) {
	if( itemid == g_item ) {
		ChatColor( id, "!g[ZP]!y Zakupil si si imunitu proti !tSmokerom!y!" );
		g_immunita[ id ] = true;
	}
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == g_zclass_smoker)
	{
		ChatColor(id,"!t[SMOKER ZOMBIE]!y Svoju schopnost aktivuje stlacenim !gE")
		g_hooksLeft[id] = 5;
		
		if (!g_bind_or_not[id])
		{
			new menu[192]
			format(menu, 191, "")
			show_menu(id, keys, menu)
		}
	}
}

public newSpawn(id)
{
	if( g_immunita[ id ] ) {
		g_immunita[ id ] = false;
	}
	
	if( g_hooked[ id ] ) {
		drag_end( id );
	}
}

public drag_start(id) // starts drag, checks if player is Smoker, checks cvars
{		
	if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_zclass_smoker)) {
		
		static Float:cdown
		cdown = get_pcvar_float(cvar_cooldown)

		if (!is_user_alive(id)) {
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Nemozes pritahovat ludi pokial si mrtvy!")
			return PLUGIN_HANDLED
		}

		if (g_hooksLeft[id] <= 0) {
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Viac krat uz nemozes pritahovat ludi!")
			return PLUGIN_HANDLED
		}

		if (get_gametime() - g_lastHook[id] < cdown) {
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Pockaj !g5 sekund!y pre pouzitie svojej schopnosti znova!", get_pcvar_float(cvar_cooldown) - (get_gametime() - g_lastHook[id]))
			return PLUGIN_HANDLED
		}
		
		new hooktarget, body
		get_user_aiming(id, hooktarget, body)
		
		if (zp_get_user_nemesis(id) && get_pcvar_num(cvar_nemesis) == 0) {
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Nemozes pritahovat ludi pokial si Nemesis!")
			return PLUGIN_HANDLED
		}
		
		if (is_user_alive(hooktarget)) {
			if (!zp_get_user_zombie(hooktarget))
				{
					if( g_immunita[ hooktarget ] ) {
						ChatColor( id, "!t[SMOKER ZOMBIE]!y Tento hrac ma imunitu pro tebe!" );
						return PLUGIN_HANDLED;
					}
					
					if (zp_get_user_survivor(hooktarget) && get_pcvar_num(cvar_survivor) == 0) {
						ChatColor(id,"!t[SMOKER ZOMBIE]!y Nemozes pritahovat vyvoleneho!")
						return PLUGIN_HANDLED;
					}
					
					g_hooked[id] = hooktarget
					emit_sound(hooktarget, CHAN_BODY, g_sndDrag, 1.0, ATTN_NORM, 0, PITCH_HIGH)
				}
			else
				{
					if (get_pcvar_num(cvar_mates) == 1)
					{
						g_hooked[id] = hooktarget
						emit_sound(hooktarget, CHAN_BODY, g_sndDrag, 1.0, ATTN_NORM, 0, PITCH_HIGH)
					}
					else
					{
						ChatColor(id,"!t[SMOKER ZOMBIE]!y Nemozes pritahovat svoj team!")
						return PLUGIN_HANDLED
					}
				}

			if (get_pcvar_float(cvar_dragspeed) <= 0.0)
				cvar_dragspeed = 1
			
			new parm[2]
			parm[0] = id
			parm[1] = hooktarget
			
			set_task(0.1, "smoker_reelin", id, parm, 2, "b")
			harpoon_target(parm)
			
			g_hooksLeft[id]--
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Mozes este pouzit svoju schopnost!g %d krat!", g_hooksLeft[id], (g_hooksLeft[id] < 2) ? "" : "s")
			g_drag_i[id] = true
			
			if(get_pcvar_num(cvar_unb2move) == 1)
				g_unable2move[hooktarget] = true
				
			if(get_pcvar_num(cvar_unb2move) == 2)
				g_unable2move[id] = true
				
			if(get_pcvar_num(cvar_unb2move) == 3)
			{
				g_unable2move[hooktarget] = true
				g_unable2move[id] = true
			}
		} else {
			g_hooked[id] = 33
			noTarget(id)
			emit_sound(hooktarget, CHAN_BODY, g_sndMiss, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			ChatColor( id, "!gNETRAFIL SI SA!" );
			g_drag_i[id] = true
			g_hooksLeft[id] -= 1;
			drag_end(id);
			ChatColor(id,"!t[SMOKER ZOMBIE]!y Mozes este pouzit svoju schopnost!g %d krat", g_hooksLeft[id], (g_hooksLeft[id] < 2) ? "" : "s")
		}
	}
	else
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
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

public smoker_reelin(parm[]) // dragging player to smoker
{
	new id = parm[0]
	new victim = parm[1]
	
	if (!g_hooked[id] || !is_user_alive(victim))
	{
		drag_end(id)
		return
	}
	if( g_hooked[ victim ] )
	{
		drag_end(id)
		return
	}
	
	if( !zp_get_user_zombie( id ) )
	{
		drag_end(id)
		return
	}
	
	if ( zp_get_user_zombie( victim ) )
	{
		drag_end(id)
		return
	}
	
	new Float:fl_Velocity[3]
	new idOrigin[3], vicOrigin[3]
	
	get_user_origin(victim, vicOrigin)
	get_user_origin(id, idOrigin)
	
	new distance = get_distance(idOrigin, vicOrigin)
	
	if (distance > 1) {
		new Float:fl_Time = distance / get_pcvar_float(cvar_dragspeed)
		
		fl_Velocity[0] = (idOrigin[0] - vicOrigin[0]) / fl_Time
		fl_Velocity[1] = (idOrigin[1] - vicOrigin[1]) / fl_Time
		fl_Velocity[2] = (idOrigin[2] - vicOrigin[2]) / fl_Time
		} else {
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}
	
	entity_set_vector(victim, EV_VEC_velocity, fl_Velocity) //<- rewritten. now uses engine
}

public drag_end(id) // drags end function
{
	g_hooked[id] = 0
	beam_remove(id)
	remove_task(id)
	
	if (g_drag_i[id])
		g_lastHook[id] = get_gametime()
	
	g_drag_i[id] = false
	g_unable2move[id] = false
}

public smoker_death() // if smoker dies drag off
{
	new id = read_data(2)
	
	beam_remove(id)
	
	if (g_hooked[id])
		drag_end(id)
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage) // if take damage drag off
{
	if (is_user_alive(attacker) && (get_pcvar_num(cvar_dmg2stop) > 0))
	{
		g_ovr_dmg[victim] = g_ovr_dmg[victim] + floatround(damage)
		if (g_ovr_dmg[victim] >= get_pcvar_num(cvar_dmg2stop))
		{
			g_ovr_dmg[victim] = 0
			drag_end(victim)
			return HAM_IGNORED;
		}
	}
	
	return HAM_IGNORED;
}

public fw_FM_CmdStart( id , Handle )
{
	static iButtons , iOldButtons;
	
	iButtons = get_uc( Handle , UC_Buttons );
	iOldButtons = pev( id , pev_oldbuttons );
	
	if( ( iButtons & IN_USE ) && !( iOldButtons & IN_USE ) ) 
	{
		drag_start(id)
	}
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	
	new button = get_user_button(id)
	new oldbutton = get_user_oldbutton(id)
	
	if (g_bind_use[id] && zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_zclass_smoker))
	{
		if (!(oldbutton & IN_USE) && (button & IN_USE))
			drag_start(id)
		
		if ((oldbutton & IN_USE) && !(button & IN_USE))
			drag_end(id)
	}
	
	if (!g_drag_i[id]) {
		g_unable2move[id] = false
	}
	
	if (g_unable2move[id] && get_pcvar_num(cvar_unb2move) > 0)
	{
		set_pev(id, pev_maxspeed, 1.0)
	}
	
	return PLUGIN_CONTINUE
}

public client_disconnect(id) // if client disconnects drag off
{
	if (id <= 0 || id > 32)
		return
	
	if (g_hooked[id])
		drag_end(id)
	
	if(g_unable2move[id])
		g_unable2move[id] = false
}

public harpoon_target(parm[]) // set beam (ex. tongue:) if target is player
{
	new id = parm[0]
	new hooktarget = parm[1]
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(8)	// TE_BEAMENTS
	write_short(id)
	write_short(hooktarget)
	write_short(g_Line)	// sprite index
	write_byte(0)	// start frame
	write_byte(0)	// framerate
	write_byte(200)	// life
	write_byte(8)	// width
	write_byte(1)	// noise
	write_byte(155)	// r, g, b
	write_byte(155)	// r, g, b
	write_byte(55)	// r, g, b
	write_byte(90)	// brightness
	write_byte(10)	// speed
	message_end()
}

public bind_v_key(id, keys)
{
	g_bind_or_not[id] = true
	switch(keys)
	{
		case 0:
			client_cmd(id, "bind v ^"+drag^"")
		
		case 1:
			client_print(id, print_chat, "[ZP] To drag player to youself (bind ^'^'key^'^' ^'^'+drag^'^') hold binded key")
		
		case 2:
			g_bind_use[id] = true
		
		default:
		g_bind_or_not[id] = false
	}
	
	return PLUGIN_HANDLED
}

public noTarget(id) // set beam if target isn't player
{
	new endorigin[3]
	
	get_user_origin(id, endorigin, 3)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte( TE_BEAMENTPOINT ); // TE_BEAMENTPOINT
	write_short(id)
	write_coord(endorigin[0])
	write_coord(endorigin[1])
	write_coord(endorigin[2])
	write_short(g_Line) // sprite index
	write_byte(0)	// start frame
	write_byte(0)	// framerate
	write_byte(200)	// life
	write_byte(8)	// width
	write_byte(1)	// noise
	write_byte(155)	// r, g, b
	write_byte(155)	// r, g, b
	write_byte(55)	// r, g, b
	write_byte(75)	// brightness
	write_byte(0)	// speed
	message_end()
}

public beam_remove(id) // remove beam
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(99)	//TE_KILLBEAM
	write_short(id)	//entity
	message_end()
}
