#include < amxmodx >
#include < hamsandwich >
#include < zombieplague >

new g_300bodov[ 33 ];

public plugin_init( ) {
	register_plugin( "0.0.1", "[ZP-Addons] Kill Ammo Packs", "adamCSzombie" );
	RegisterHam( Ham_Killed, "player", "ham_killed", 1 );
}

public client_putinserver( id ) {
	g_300bodov[ id ] = false;
}

public client_disconnect( id ) {
	g_300bodov[ id ] = false;
}

public native_give_300( id ) {
	get_300( id );
}

public plugin_natives( ) {
	register_native( "get_300", "native_give_300", 1 );
}

public get_300( id ) {
	g_300bodov[ id ] = true;
	ChatColor( id, "!g[400 Bodov]!y Maximalny limit bodov bol zvyseny z !t200!y > !t400!y." );
}

stock ChatColor(const id, const input[], any:...) {
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	
	if(id) players[0] = id; else get_players(players, count, "ch")
	{
		for(new i = 0; i < count; i++)
		{
			if(is_user_connected( players[i]))
			{
				message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])  
				write_byte(players[i])
				write_string(msg)
				message_end()
			}
		}
	}
}

public ham_killed( victim, attacker, shouldgib ) {
	new ammopacks = zp_get_user_ammo_packs( attacker );
	
	if ( attacker == victim )
		return;
	
	if ( !zp_get_user_zombie( attacker ) ) {
		if ( g_300bodov[ attacker ] ) {
			if ( ammopacks + 50 > 400 ) {
				ammopacks = 400;
			} else {
				ammopacks += 50;
			}
			ScreenFade( attacker, 0.5, 254, 106, 106, 100 );
		} else {
			if ( ammopacks + 50 > 200 ) {
				ammopacks = 200;
			} else {
				ammopacks += 50;
			}
			ScreenFade( attacker, 0.5, 254, 106, 106, 100 );
		}
		zp_set_user_ammo_packs( attacker, ammopacks ); 
	}
}

stock ScreenFade( plr, Float:fDuration, red, green, blue, alpha ) {
	new i = plr ? plr : get_maxplayers();
	if( !i ) {
		return 0;
	}
	
	message_begin( plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade" ), {0, 0, 0}, plr );
	write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	write_short( 4096 );
	write_byte( red );
	write_byte( green );
	write_byte( blue );
	write_byte( alpha );
	message_end();
	
	return 1;
	
}
