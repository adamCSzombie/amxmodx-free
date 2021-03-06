/*
[ZP] Extra Item : Immunity

Plugin Thread :

http://forums.alliedmods.net/showthread.php?t=105537
*/


#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <zombieplague>

#define AUTHOR "xxx"

// Bitsums
#define HaveImmunity(%1) g_HaveImmunity & (1<<(%1 & 31))
#define SetHaveImmunity(%1) g_HaveImmunity |= (1<<(%1 & 31))
#define ClearHaveImmunity(%1) g_HaveImmunity &= ~(1<<(%1 & 31))



// If you want immunity for all round, uncomment this !
//#define ALLROUND

// Task IDs
#define TASK_AURA 321

// Ammo Pack cost 
new const ITEM_COST = 180

// Variables
new g_itemID, g_HudSync, g_SayText, g_HaveImmunity

// Cvars
new cvar_duration

new cvar_auracolor, cvar_aurasize

new g_have[ 33 ];

// Array
new /*g_HaveImmunity[33],*/ Time[33]


public plugin_init()
{
	// Plugin register
	register_plugin("Nesmrtelnost", "4.1", AUTHOR)
	
	cvar_duration = register_cvar("zp_immunity_duration", "25")
	
	RegisterHam( Ham_Spawn, "player", "Spawn", 1 );
	
	cvar_auracolor = register_cvar("zp_immunity_color", "0 0 0")
	cvar_aurasize = register_cvar("zp_immunity_aura_size", "0")
	
	// Variables
	g_itemID = zp_register_extra_item("Nesmrtelnost \d(25 sekund)\w", ITEM_COST , ZP_TEAM_HUMAN)	
	g_HudSync = CreateHudSyncObj()
	g_SayText = get_user_msgid("SayText")
	
	// Language File
	register_dictionary("zp_extra_immunity.txt")
	
	// Hamsandwich forward
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	
	// Gamemonitor info
	static szCvar[30]
	formatex(szCvar, charsmax(szCvar), "4.1")
	register_cvar("zp_immunity", szCvar, FCVAR_SERVER|FCVAR_SPONLY)
}
public client_putinserver( id )
{
	g_have[ id ] = 0;
}
public client_disconnect( id )
{
	g_have[ id ] = 0;
}
public Spawn( id )
{
	g_have[ id ] = 0;
}

// If some one buy the item
public zp_extra_item_selected(id, itemid)
{
	if(itemid == g_itemID)
	{
		if( get_user_flags( id ) & ADMIN_LEVEL_G )
		{
			// Wait until the round start
			if (!zp_has_round_started())
			{
				new Temp[32]
				formatex(Temp, 31 , "!g[+] !y%L", id, "WAIT")
				chat_color(id, Temp)
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ITEM_COST)
				return;
			}
			if( g_have[ id ] == 1 )
			{
				new Temp[32]
				client_print(id, print_center, "Mozes si toto kupit iba raz za kolo!")
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ITEM_COST)
				return;
			}
			if(is_user_hannibal(id))
			{
				new Temp[32]
				client_print(id, print_center, "Nemozes si kupit Nesmrtelnost ked si Hannibal!")
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ITEM_COST)
				return;
			}
			
			// If the player already have immunity
			if(HaveImmunity(id))
			{
				new Temp[32]
				formatex(Temp, 31, "!g[EVIP] !y%L", id, "ALREADY")
				chat_color(id, Temp)	
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ITEM_COST)
				
				return
			}
			
			else
			{
				// Enable Godmode
				set_user_godmode(id, 1)
				
				// Aura task
				set_task(0.1, "aura", id + TASK_AURA, _, _, "b")
				
				SetHaveImmunity(id)
				g_have[ id ] = 1;
				set_hudmessage(85, 127, 255, -1.0, 0.15, 1, 0.1, 3.0, 0.05, 0.05, -1)
				ShowSyncHudMsg(id, g_HudSync, "%L", id, "IMMUME")
				
				Time[id] = get_pcvar_num(cvar_duration)
				CountDown(id)
				
			}
		} 
		else 
		{
			client_print(id, print_center, "Nemozes si kupit Nesmrtelnost ked nemas [+] ucet!")
			zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + ITEM_COST)
			return;
		}
	}
}

// Countdown code
public CountDown(id)
{
	// If time is 0 or -1
	if(Time[id] <= 0)
	{		
		// Remove aura task
		remove_task(id + TASK_AURA)
		
		// Client_Print
		client_print(id, print_center, "%L", id, "EXPIRED")
		
		// Disable godmode
		set_user_godmode(id, 0)
		
		// Remove immunity
		ClearHaveImmunity(id)
		
		// Remove countdown
		return
	}
	
	// Time - 1
	Time[id]--
	
	// Show the immunity seconds
	set_hudmessage( 85, 127, 255, -1.0, 0.15, 0, 1.0, 1.0 ); 
	ShowSyncHudMsg(id, g_HudSync, "%L", id, "REMAINING", Time[id])
	
	// Repeat
	set_task(1.0, "CountDown", id)
}



// If user is infected (Infection nade)
public zp_user_infected_post(id)
{
	if(HaveImmunity(id))
	{
		#if !defined ALLROUND
		// Remove countdown task
		Time[id] = 0
		#endif
		
		// Remove aura task
		remove_task(id + TASK_AURA)
		
		// Remove immunity
		ClearHaveImmunity(id)
		
		// Disable godmode
		set_user_godmode(id, 0)
		
		g_have[ id ] = 0;
	}
}


// At player spawn
public fw_PlayerSpawn_Post(id)
{
	if(HaveImmunity(id))
	{

		Time[id] = 0
		
		client_print(id, print_center, "%L", id, "EXPIRED")
		
		remove_task(id + TASK_AURA)
		
		set_user_godmode(id, 0)

		ClearHaveImmunity(id)
	}
}



/*============
Aura Code
============*/

public aura(id)
{
	id -= TASK_AURA
	
	
	// If user die 
	if (!is_user_alive(id))
		return
	
	// Color cvar ---> RGB!
	new szColors[16]
	get_pcvar_string(cvar_auracolor, szColors, 15)
	
	new gRed[4], gGreen[4], gBlue[4], iRed, iGreen, iBlue
	parse(szColors, gRed, 3, gGreen, 3, gBlue, 3)
	
	iRed = clamp(str_to_num(gRed), 0, 255)
	iGreen = clamp(str_to_num(gGreen), 0, 255)
	iBlue = clamp(str_to_num(gBlue), 0, 255)
	
	new Origin[3]
	get_user_origin(id, Origin)
	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_DLIGHT)
	write_coord(Origin[0])
	write_coord(Origin[1])
	write_coord(Origin[2])
	write_byte(get_pcvar_num(cvar_aurasize))
	write_byte(iRed) //   R
	write_byte(iGreen) // G
	write_byte(iBlue) //  B
	write_byte(2)
	write_byte(0)
	message_end()
}


/*===============
ColorChat Stock
===============*/

stock chat_color(const id, const input[], any:...)
{
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	message_begin(MSG_ONE_UNRELIABLE, g_SayText, _, id)
	write_byte(id)
	write_string(msg)
	message_end()
}
