#include < amxmodx >
#include < fakemeta >
#include < cstrike >
#include < zombieplague >
#include < fun >
#include < cstrike >

#define STR_T           33

#define fm_get_user_button(%1) pev(%1, pev_button)	

#define fm_get_entity_flags(%1) pev(%1, pev_flags)
stock fm_set_user_velocity( entity, const Float:vector[ 3 ] ) 
{
	set_pev( entity, pev_velocity, vector );

	return 1;
}

new bool:g_WallClimb[ 33 ];
new Float:g_wallorigin[ 32 ][ 3 ];
new cvar_zp_wallclimb, cvar_zp_wallclimb_nemesis, cvar_zp_wallclimb_survivor;
new g_zclass_climb;

new const zclass_name[ ] = { "Climb Zombie" };
new const zclass_info[ ] = { "[schopnost liezt po stenach]" } ;
new const zclass_model[ ] = { "profun_climb" } ;
new const zclass_clawmodel[ ] = { "v_profun_climb.mdl" } ;
const zclass_health = 1450 ; // 1600
const zclass_speed = 240 ;	// 230
const Float:zclass_gravity = 0.9; // 1.0
const Float:zclass_knockback = 1.3; // 1.5

public plugin_init( ) 
{
	register_plugin( "[ZP-Class] Climb Zombie", "1.4", "adamCSzombie" );
	
	register_forward( FM_Touch, 		"fwd_touch")
	register_forward( FM_PlayerPreThink, 	"fwd_playerprethink" );
	
	register_event( "DeathMsg","EventDeathMsg","a" );
	register_event( "CurWeapon" , "fw_EvCCCurWeapon" , "be" , "1=1" );
	cvar_zp_wallclimb = register_cvar( "zp_wallclimb", "1" );
	cvar_zp_wallclimb_survivor = register_cvar( "zp_wallclimb_survivor", "0" );
	cvar_zp_wallclimb_nemesis = register_cvar( "zp_wallclimb_nemesis", "1" );
	
}

public plugin_precache( )
{
	g_zclass_climb = zp_register_zombie_class( zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback );
}

public EventDeathMsg( )	
{
	new id = read_data( 2 );
	
	g_WallClimb[ id ] = true;
	
	return PLUGIN_HANDLED;
}

public client_connect( id ) 
{
	g_WallClimb[ id ] = true	;
}

public fwd_touch( id, world )
{
	if( !is_user_alive( id ) || !g_WallClimb[ id ] || !pev_valid( id ) )
		return FMRES_IGNORED;

	new player = STR_T;
	if( !player )
		return FMRES_IGNORED;
		
	new classname[ STR_T ];
	pev( world, pev_classname, classname, ( STR_T ) );
	
	if( equal( classname, "worldspawn" ) || equal( classname, "func_wall" ) || equal( classname, "func_breakable" ) )
		pev( id, pev_origin, g_wallorigin[ id ] );

	return FMRES_IGNORED;
}

public wallclimb( id, button )
{
	static Float:origin[ 3 ];
	pev( id, pev_origin, origin );

	if( get_distance_f( origin, g_wallorigin[ id ] ) > 25.0 )
		return FMRES_IGNORED;
	
	if( fm_get_entity_flags( id ) & FL_ONGROUND )
		return FMRES_IGNORED;
		
	if( button & IN_FORWARD )
	{
		static Float:velocity[ 3 ];
		velocity_by_aim( id, 120, velocity );
		fm_set_user_velocity( id, velocity );
	}
	else if( button & IN_BACK )
	{
		static Float:velocity[ 3 ];
		velocity_by_aim( id, -120, velocity );
		fm_set_user_velocity( id, velocity );
	}
	return FMRES_IGNORED
}	

public fwd_playerprethink( id ) 
{
	if( !g_WallClimb[ id ] || !zp_get_user_zombie( id ) ) 
		return FMRES_IGNORED;
		
	if( zp_is_survivor_round( ) && get_pcvar_num( cvar_zp_wallclimb_survivor ) == 0 )
		return FMRES_IGNORED;
		
	if( zp_is_nemesis_round( ) && get_pcvar_num( cvar_zp_wallclimb_nemesis ) == 0 )
		return FMRES_IGNORED;
	
	new button = fm_get_user_button( id );
	
	if( ( get_pcvar_num( cvar_zp_wallclimb ) == 1 ) && ( button & IN_USE ) && ( zp_get_user_zombie_class( id ) == g_zclass_climb ) ) //Use button = climb
	wallclimb( id, button );
	else if( ( get_pcvar_num( cvar_zp_wallclimb ) == 2 ) && ( button & IN_JUMP ) && button & IN_DUCK && ( zp_get_user_zombie_class( id ) == g_zclass_climb ) ) //Jump + Duck = climb
	wallclimb( id, button );

	return FMRES_IGNORED;
}

stock ChatColor( const id, const input[ ], any:... ) 
{
	new count = 1, players[ 32 ];
	static msg[ 191 ];
	vformat( msg, 190, input, 3 );
   
	replace_all( msg, 190, "!g", "^4" );
	replace_all( msg, 190, "!y", "^1" );
	replace_all( msg, 190, "!t", "^3" );

   
	if( id ) players[ 0 ] = id; else get_players( players, count, "ch" )
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

public zp_user_infected_post( player, infector )
{
	if( is_user_alive( player ) )
	{
		if( zp_get_user_zombie_class( player ) == g_zclass_climb )
		{
			ChatColor( player ,"!t[CLIMB ZOMBIE]!y Stlac !gE!y pre pouzitie lezenia po stenach!" );
		}
	}
}

public fw_EvCCCurWeapon( id )
{
	if( is_user_alive( id ) )
	{
		if( zp_get_user_first_zombie( id ) )
		{
			if( zp_get_user_zombie_class( id ) ==  g_zclass_climb )
			{
				new g_iPrevCurWeapon[ 33 ];
				new iCurWeapon = read_data( 3 )
				if( iCurWeapon != g_iPrevCurWeapon[ id ] )
				{
					set_user_maxspeed( id , 300.0 );
					g_iPrevCurWeapon[ id ] = iCurWeapon;
				}
			}
		}
	}
}
