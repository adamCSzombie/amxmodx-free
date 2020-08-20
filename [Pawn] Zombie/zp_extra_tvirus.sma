#include < amxmodx >
#include < zombieplague >

#define PLUGIN 		"[ZP-Extra] T-Virus"
#define VERSION 	"0.8"
#define AUTHOR 		"MrCaMp3R"

new g_virus, name[ 32 ];

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	g_virus = zp_register_extra_item( "T-Virus", 50, ZP_TEAM_HUMAN );
	
}

stock ChatColor( const id, const input[], any:... ) // Stocks ChatColor
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

stock ScreenFade( plr, Float:fDuration, red, green, blue, alpha )
{
	    new i = plr ? plr : get_maxplayers( );
	    if( !i )
	    {
		return 0;
	    }
	    
	    message_begin( plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade" ), { 0, 0, 0 }, plr ); // Zafarbenie Obrazovky
	    write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	    write_short( floatround( 4096.0 * fDuration, floatround_round ) );
	    write_short( 4096 );
	    write_byte( red );
	    write_byte( green );
	    write_byte( blue );
	    write_byte( alpha );
	    message_end( );
	    
	    return 1;
}

public zp_extra_item_selected( id, itemid )
{
	if( itemid == g_virus )
	{
		if( !zp_has_round_started( ) )
		{
			client_cmd( id, "spk valve/sound/buttons/button11" );
			client_print( id, print_chat, "Pockaj, nez zacne kolo!" );
			return ZP_PLUGIN_HANDLED;
		}
		
		get_user_name( id, name, 31 );
		for( new i = 0; i < 5; i++ )
		{
			ChatColor( 0, "!g[POZOR]!y Hrac !t%s!y si dal do krvy T-Virus!", name );
		}
		set_task( 6.0, "set_zombie", id );
		set_task( 1.0, "eff", id );
		set_task( 2.0, "eff", id );
		set_task( 3.0, "eff", id );
		set_task( 4.0, "eff", id );
		set_task( 5.0, "eff", id );
	}
	return PLUGIN_CONTINUE;
}

public eff( id )
{
	client_print( id, print_center, "Infekcia zacala posobit.." );
	ScreenFade( id, 0.5, 65, 165, 65, 150 );
}

public set_zombie( id )
{
	if( !zp_get_user_last_human( id ) ) {
		if( zp_has_round_started( ) )
		{
			get_user_name( id, name, 31 );
			server_cmd( "amx_show_activity 0" );
			server_cmd( "zp_zombie %s", name );
			server_cmd( "amx_show_activity 2" );
		} else {
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 50 );
			ChatColor( id, "!g[T-Virus]!y Bohuzial T-Virus nevie ucinkovat ked kolo este nezacalo!" );
			ChatColor( id, "!gBoli ti navratene body.." );
		}
	} else {
		zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 50 );
		ChatColor( id, "!g[T-Virus]!y Bohuzial T-Virus nevie ucinkovat ked si posledny clovek!" );
		ChatColor( id, "!gBoli ti navratene body.." );
	}
}
