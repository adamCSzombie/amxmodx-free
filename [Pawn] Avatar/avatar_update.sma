/* Plugin generated by AMXX-Studio */

#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >

#define PLUGIN "new update"
#define VERSION "0.3"
#define AUTHOR "adamCSzombie"

new have_seen_update[ 33 ];

public plugin_init( ) 
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam( Ham_Spawn, "player", "spawn_hraca", 1 );

}

public client_putinserver( id )
{ have_seen_update[ id ] = 0; }

public client_disconnect( id )
{ have_seen_update[ id ] = 0; }

public spawn_hraca( id ) 
{
	if( have_seen_update[ id ] == 0 )
	{
		have_seen_update[ id ] += 1;
		show_motd( id, "update.txt" );
	}
}