#include <amxmodx>
#include <hamsandwich>
#include <zombieplague>
#include <dhudmessage>

#define PLUGIN_NAME "[Avatar] Power of Nature HP"
#define PLUGIN_VERS "1.0"
#define PLUGIN_AUTH "ASSOM"

#define TASK_HEALTHNEM 8746446746467

new g_iHudSync

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERS, PLUGIN_AUTH)
	
	g_iHudSync = CreateHudSyncObj()
	
	// Fwd's
	RegisterHam(Ham_Spawn, "player", "Fwd_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "Fwd_PlayerKilled_Pre", 0)
}

public Fwd_PlayerSpawn_Post(id)
{
	if (task_exists(id+TASK_HEALTHNEM))
		remove_task(id+TASK_HEALTHNEM)
}

public Fwd_PlayerKilled_Pre(victim, attacker, shouldgib)
{
	if (task_exists(victim+TASK_HEALTHNEM))
		remove_task(victim+TASK_HEALTHNEM)
}

public zp_round_started(mode, id)
{
	if (mode != MODE_NEMESIS)
		return
		
	if (!zp_get_user_nemesis(id))
		return
		
	set_task(1.0, "Task_ShowHealth", id+TASK_HEALTHNEM, _, _, "b")
}

public Task_ShowHealth(id)
{
	id -= TASK_HEALTHNEM
	
	if (!zp_get_user_nemesis(id))
		remove_task(id+TASK_HEALTHNEM)
	
	//set_dhudmessage(165, 165, 165, -1.0, 0.10, 1, 0.5, 2.0, 0.08, 2.0, true)
	set_dhudmessage( 165, 65, 65, -1.0, 0.10, 0, 6.0, 1.1, 0.0, 0.0, -1 );
	show_dhudmessage( 0,"Power Of Nature: %d HP", get_user_health( id ) );
}
