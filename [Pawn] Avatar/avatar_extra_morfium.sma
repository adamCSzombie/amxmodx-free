#include < amxmodx >
#include < fun >
#include < hamsandwich >
#include < zombieplague >

#define AUTHOR 				"adamCSzombie"
#define VERSION				"0.3"
#define PLUGIN 				"[Avatar] Morfium"
#define HaveImmunity(%1) 		g_HaveImmunity & (1<<(%1 & 31))
#define SetHaveImmunity(%1) 		g_HaveImmunity |= (1<<(%1 & 31))
#define ClearHaveImmunity(%1) 		g_HaveImmunity &= ~(1<<(%1 & 31))
#define TASK_AURA 			321
#define ITEM_COST 			180
#define EXTRA_ITEM			"\y(Premium)\w Morfium"

new g_itemID, g_HudSync, g_SayText, g_HaveImmunity;
new cvar_duration, cvar_auracolor, cvar_aurasize, g_have[ 33 ], Time[ 33 ];

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	cvar_duration = 		register_cvar( "zp_immunity_duration", "10" );
	cvar_auracolor = 		register_cvar( "zp_immunity_color", "0 0 0" );
	cvar_aurasize = 		register_cvar( "zp_immunity_aura_size", "0" );
	g_itemID = 			zp_register_extra_item( EXTRA_ITEM, ITEM_COST, ZP_TEAM_HUMAN );	
	g_HudSync = 			CreateHudSyncObj( );
	g_SayText = 			get_user_msgid( "SayText" );
	
	RegisterHam( Ham_Spawn, "player", "Spawn", 1 );
	
	register_dictionary( "zombie_plague.txt" );
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
	if( HaveImmunity( id ) )
	{
		Time[ id ] = 0;
		
		client_print( id, print_center, "%L", id, "EXPIRED" );
		
		remove_task( id + TASK_AURA );
		
		set_user_godmode( id, 0 );

		ClearHaveImmunity( id );
	}
	g_have[ id ] = 0;
}

public zp_extra_item_selected( id, itemid )
{
	if( itemid == g_itemID )
	{
		if( !zp_has_round_started( ) )
		{
			new Temp[ 32 ];
			formatex( Temp, 31 , "!g[Avatar] !y%L", id, "WAIT" );
			chat_color( id, Temp )
			client_cmd( id, "spk valve/sound/buttons/button11" );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + ITEM_COST );
			
			return;
		}
		if( g_have[ id ] == 1 )
		{
			new Temp[ 32 ]
			client_cmd( id, "spk valve/sound/buttons/button11" );
			client_print( id, print_center, "%L", LANG_PLAYER, "MORFIUM_ONCE" );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + ITEM_COST );
			
			return;
		}

		if( HaveImmunity( id ) )
		{
			new Temp[ 32 ];
			client_cmd( id, "spk valve/sound/buttons/button11" );
			formatex( Temp, 31, "!g[Avatar] !y%L", id, "ALREADY" );
			chat_color( id, Temp );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + ITEM_COST )
			
			return;
		}
		
		else
		{
			set_user_godmode( id, 1 );
			
			set_task( 0.1, "aura", id + TASK_AURA, _, _, "b" );
			client_cmd( id, "spk valve/sound/fvox/innsuficient_medical" );
			SetHaveImmunity( id );
			g_have[ id ] = 1;
			set_hudmessage( 85, 127, 255, -1.0, 0.15, 1, 0.1, 3.0, 0.05, 0.05, -1 );
			ShowSyncHudMsg( id, g_HudSync, "%L", id, "IMMUME" )
			
			Time[ id ] = get_pcvar_num( cvar_duration );
			CountDown( id );
			
		}
		
	}
}

public CountDown( id )
{
	if( Time[ id ] <= 0 )
	{		
		remove_task( id + TASK_AURA );
		
		client_print( id, print_center, "%L", id, "EXPIRED" );
		
		set_user_godmode( id, 0 );
		
		ClearHaveImmunity( id );
		
		return;
	}
	
	Time[ id ]--;
	
	set_hudmessage( 85, 127, 255, -1.0, 0.15, 0, 1.0, 1.0 ); 
	ShowSyncHudMsg( id, g_HudSync, "%L", id, "REMAINING", Time[ id ] );
	
	set_task( 1.0, "CountDown", id );
}

public zp_user_infected_post( id )
{
	if( HaveImmunity( id ) )
	{
		Time[ id ] = 0;
		
		remove_task( id + TASK_AURA );
		
		ClearHaveImmunity( id );
		
		set_user_godmode( id, 0 );
		
		g_have[ id ] = 0;
	}
}

public aura( id )
{
	id -= TASK_AURA;	
	
	if( !is_user_alive( id ) )
		return;
	
	new szColors[ 16 ];
	get_pcvar_string( cvar_auracolor, szColors, 15 );
	
	new gRed[ 4 ], gGreen[ 4 ], gBlue[ 4 ], iRed, iGreen, iBlue;
	parse( szColors, gRed, 3, gGreen, 3, gBlue, 3 );
	
	iRed = clamp( str_to_num( gRed ), 0, 255 );
	iGreen = clamp( str_to_num( gGreen ), 0, 255 );
	iBlue = clamp( str_to_num( gBlue ), 0, 255 );
	
	new Origin[ 3 ];
	get_user_origin( id, Origin );
	
	message_begin( MSG_ALL, SVC_TEMPENTITY );
	write_byte( TE_DLIGHT );
	write_coord( Origin[ 0 ] );
	write_coord( Origin[ 1 ] );
	write_coord( Origin[ 2 ] );
	write_byte(get_pcvar_num( cvar_aurasize ) );
	write_byte( iRed );
	write_byte( iGreen );
	write_byte( iBlue );
	write_byte( 2 );
	write_byte( 0 );
	message_end( );
}

stock chat_color( const id, const input[ ], any:... )
{
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
	
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );
	
	message_begin( MSG_ONE_UNRELIABLE, g_SayText, _, id );
	write_byte( id );
	write_string( msg );
	message_end( );
}
