#include <amxmodx>
#include <amxmisc>

#define PLUGIN "VIP Chat Colors"
#define VERSION "2.0"
#define AUTHOR "Arion"

#define ACCESS_LEVEL	ADMIN_LEVEL_F
#define ADMIN_SETTING	ADMIN_CFG

new message[192]
new sayText
new teamInfo
new maxPlayers

new g_MessageColor
new g_NameColor
new g_AdminListen

new strName[191]
new strText[191]
new alive[11]

public plugin_init()
{
	register_plugin (PLUGIN, VERSION, AUTHOR)
	
	g_MessageColor = register_cvar ("amx_color", "1") // Farby sprav: [1] zlta, [2] zelena, [3] biela, [4] modra, [5] cervena
	
	g_NameColor = register_cvar ("amx_namecolor", "6") // Farby prezyvky: [1] zlta, [2] zelena, [3] biela, [4] modra, [5] cervena, [6] tim farba
	
	g_AdminListen = register_cvar ("amx_listen", "1") // 1 - VIP vidia vsetky spravy chatu ; 0 - VIP nevidia vsetky spravy chatu (zivych/mrtvych)
	
	
	sayText = get_user_msgid ("SayText")
	teamInfo = get_user_msgid ("TeamInfo")
	maxPlayers = get_maxplayers()
	
	
	register_message (sayText, "avoid_duplicated")
	
	register_clcmd ("amx_vip_color", "set_color", ADMIN_SETTING, "<farba>")
	register_clcmd ("amx_vip_avfnamecolor", "set_name_color", ADMIN_SETTING, "<farba>")
	register_clcmd ("amx_vip_avflisten", "set_listen", ADMIN_SETTING, "<1 | 0>")
	
	register_clcmd ("say", "hook_say")
	register_clcmd ("say_team", "hook_teamsay")
}

public plugin_precache( ) {
	precache_sound( "playaspro/chat.wav" );
}

public avoid_duplicated (msgId, msgDest, receiver)
{
	return PLUGIN_HANDLED
}


public hook_say(id)
{
	read_args (message, 191)
	remove_quotes (message)
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE
	
	
	new name[32]
	get_user_name (id, name, 31)
	
	new bool:admin = false
	
	if (get_user_flags(id) & ACCESS_LEVEL)
		admin = true
	
	
	new isAlive
	
	if (is_user_alive (id))
	{
		isAlive = 1
		alive = "^x01"
	}
	else
	{
		isAlive = 0
		alive = "^x01*MRTVY* "
	}
	
	static color[10]
	
	
	
	if (admin)
	{
		// Name
		switch (get_pcvar_num (g_NameColor))
		{
			case 1:
				format (strName, 191, "^x04(Premium) %s%s", alive, name)
			
			case 2:
				format (strName, 191, "^x04(Premium) %s^x04%s ", alive, name)
			
			case 3:
			{
				color = "SPECTATOR"
				format (strName, 191, "^x04(Premium) %s^x03%s ", alive, name)
			}
			
			case 4:
			{
				color = "CT"
				format (strName, 191, "^x04(Premium) %s^x03%s", alive, name)
			}
			
			case 5:
			{
				color = "TERRORIST"
				format (strName, 191, "^x04(Premium) %s^x03%s", alive, name)
			}
			
			case 6:
			{
				get_user_team (id, color, 9)
				
				format (strName, 191, "^x04(Premium) %s^x03%s", alive, name)
			}
		}
		
		
		// Message
		switch (get_pcvar_num (g_MessageColor))
		{
			case 1:	// Yellow
				format (strText, 191, "%s", message)
			
			case 2:	// Green
				format (strText, 191, "^x04%s", message)
			
			case 3:	// White
			{
				copy (color, 9, "SPECTATOR")
				format (strText, 191, "^x03%s", message)
			}
			
			case 4:	// Blue
			{
				copy (color, 9, "CT")
				format (strText, 191, "^x03%s", message)
			}
			
			case 5:	// Red
			{
				copy (color, 9, "TERRORIST")
				format (strText, 191, "^x03%s", message)
			}
		}
	}
	
	else // Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9)
		
		format (strName, 191, "%s ^x03%s", alive, name)
		
		format (strText, 191, "%s", message)
	}
	
	format (message, 191, "%s ^x04->^x01 %s", strName, strText)
	client_cmd( 0, "spk playaspro/chat.wav" );
	sendMessage (color, isAlive)	// Sends the colored message
	
	return PLUGIN_CONTINUE
}


public hook_teamsay(id)
{
	new playerTeam = get_user_team(id)
	new playerTeamName[19]
	
	switch (playerTeam) // Team names which appear on team-only messages
	{
		case 1:
			copy (playerTeamName, 11, "Terrorists")
		
		case 2:
			copy (playerTeamName, 18, "Counter-Terrorists")
		
		default:
		copy (playerTeamName, 9, "Spectator")
	}
	
	read_args (message, 191)
	remove_quotes (message)
	
	if (message[0] == '@' || message[0] == '/' || message[0] == '!' || equal (message, "")) // Ignores Admin Hud Messages, Admin Slash commands, 
		// Gungame commands and empty messages
	return PLUGIN_CONTINUE
	
	
	new name[32]
	get_user_name (id, name, 31)
	
	new bool:admin = false
	
	if (get_user_flags(id) & ACCESS_LEVEL)
		admin = true
	
	
	new isAlive
	
	if (is_user_alive (id))
	{
		isAlive = 1
		alive = "^x01"
	}
	else
	{
		isAlive = 0
		alive = "^x01*MRTVY* "
	}
	
	static color[10]
	
	
	
	if (admin)
	{
		// Name
		switch (get_pcvar_num (g_NameColor))
		{
			case 1:
				format (strName, 191, "%s(%s)^x04(Premium) %s", alive, playerTeamName, name)
			
			case 2:
				format (strName, 191, "%s(%s)^x04(Premium) ^x04%s", alive, playerTeamName, name)
			
			case 3:
			{
				color = "SPECTATOR"
				format (strName, 191, "%s(%s)^x04(Premium) ^x03%s", alive, playerTeamName, name)
			}
			
			case 4:
			{
				color = "CT"
				format (strName, 191, "%s(%s)^x04(Premium) ^x03%s", alive, playerTeamName, name)
			}
			
			case 5:
			{
				color = "TERRORIST"
				format (strName, 191, "%s(%s)^x04(Premium) ^x03%s", alive, playerTeamName, name)
			}
			
			case 6:
			{
				get_user_team (id, color, 9)
				
				format (strName, 191, "%s(%s)^x04(Premium) ^x03%s", alive, playerTeamName, name)
			}
		}
		
		
		// Message
		switch (get_pcvar_num (g_MessageColor))
		{
			case 1:	// Yellow
				format (strText, 191, "%s", message)
			
			case 2:	// Green
				format (strText, 191, "^x04%s", message)
			
			case 3:	// White
			{
				copy (color, 9, "SPECTATOR")
				format (strText, 191, "^x03%s", message)
			}
			
			case 4:	// Blue
			{
				copy (color, 9, "CT")
				format (strText, 191, "^x03%s", message)
			}
			
			case 5:	// Red
			{
				copy (color, 9, "TERRORIST")
				format (strText, 191, "^x03%s", message)
			}
		}
	}
	
	else // Player is not admin. Team-color name : Yellow message
	{
		get_user_team (id, color, 9)
		
		format (strName, 191, "%s(%s) ^x03%s", alive, playerTeamName, name)
		
		format (strText, 191, "%s", message)
	}
	
	format (message, 191, "%s ^x04->^x01 %s", strName, strText)
	client_cmd( 0, "spk playaspro/chat.wav" );
	sendTeamMessage (color, isAlive, playerTeam)	// Sends the colored message
	
	return PLUGIN_CONTINUE	
}


public set_color (id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[1], newColor
	read_argv (1, arg, 1)
	
	newColor = str_to_num (arg)
	
	if (newColor >= 1 && newColor <= 5)
	{
		set_cvar_num ("amx_color", newColor)
		set_pcvar_num (g_MessageColor, newColor)
		
		if (get_pcvar_num (g_NameColor) != 1 &&
		((newColor == 3 && get_pcvar_num (g_NameColor) != 3)
		|| (newColor == 4 && get_pcvar_num (g_NameColor) != 4)
		|| (newColor == 5 && get_pcvar_num (g_NameColor) != 5)))
	{
		set_cvar_num ("amx_namecolor", 2)
		set_pcvar_num (g_NameColor, 2)
	}
}

return PLUGIN_HANDLED
}


public set_name_color (id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
	return PLUGIN_HANDLED
	
	new arg[1], newColor
	read_argv (1, arg, 1)
	
	newColor = str_to_num (arg)
	
	if (newColor >= 1 && newColor <= 6)
	{
		set_cvar_num ("amx_namecolor", newColor)
		set_pcvar_num (g_NameColor, newColor)
		
		if ((get_pcvar_num (g_MessageColor) != 1
		&& ((newColor == 3 && get_pcvar_num (g_MessageColor) != 3)
		|| (newColor == 4 && get_pcvar_num (g_MessageColor) != 4)
		|| (newColor == 5 && get_pcvar_num (g_MessageColor) != 5)))
		|| get_pcvar_num (g_NameColor) == 6)
	{
		set_cvar_num ("amx_color", 2)
		set_pcvar_num (g_MessageColor, 2)
	}
}

return PLUGIN_HANDLED
}


public set_listen (id, level, cid)
{
if (!cmd_access(id, level, cid, 2))
	return PLUGIN_HANDLED
	
	new arg[1], newListen
	read_argv(1, arg, 1)
	
	newListen = str_to_num (arg)
	
	set_cvar_num ("amx_listen", newListen)
	set_pcvar_num (g_AdminListen, newListen)
	
	return PLUGIN_HANDLED
}


public sendMessage (color[], alive)
{
	new teamName[10]
	
	for (new player = 1; player < maxPlayers; player++)
	{
		if (!is_user_connected(player))
			continue
		
		if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ACCESS_LEVEL)
		{
			get_user_team (player, teamName, 9)	// Stores user's team name to change back after sending the message
			
			changeTeamInfo (player, color)	// Changes user's team according to color choosen
			
			writeMessage (player, message)	// Writes the message on player's chat
			
			changeTeamInfo (player, teamName)	// Changes user's team back to original
		}
	}
}


public sendTeamMessage (color[], alive, playerTeam)
{
	new teamName[10]
	
	for (new player = 1; player < maxPlayers; player++)
	{
		if (!is_user_connected(player))
			continue
		
		if (get_user_team(player) == playerTeam || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ACCESS_LEVEL)
		{
			if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ACCESS_LEVEL)
			{
				get_user_team (player, teamName, 9)	// Stores user's team name to change back after sending the message
				
				changeTeamInfo (player, color)	// Changes user's team according to color choosen
				
				writeMessage (player, message)	// Writes the message on player's chat
				
				changeTeamInfo (player, teamName)	// Changes user's team back to original
			}
		}
	}
}


public changeTeamInfo (player, team[])
{
	message_begin (MSG_ONE, teamInfo, _, player)	// Tells to to modify teamInfo (Which is responsable for which time player is)
	write_byte (player)	// Write byte needed
	write_string (team)	// Changes player's team
	message_end()	// Also Needed
}


public writeMessage (player, message[])
{
	message_begin (MSG_ONE, sayText, {0, 0, 0}, player)	// Tells to modify sayText (Which is responsable for writing colored messages)
	write_byte (player)	// Write byte needed
	write_string (message)	// Effectively write the message, finally, afterall
	message_end ()	// Needed as always
}
