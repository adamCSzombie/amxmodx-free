#include < amxmodx >
#include < engine >
#include < zombieplague >
#include < hamsandwich >
#include < fun >
#include < fakemeta_util >

#define PLUGIN 		"[Avatar] Energeticky Stit"
#define VERSION 	"0.3"
#define AUTHOR 		"adamCSzombie"

#define EXTRA_ITEM		"Energeticky Stit"
#define ITEM_COST		200
#define ValidTouch(%1) 		( is_user_alive(%1) && ( zp_get_user_zombie(%1) || zp_get_user_nemesis(%1) ) )

#define CAMPO_TASK

#define ONE_COLOR

new const NADE_TYPE_CAMPO = 6545;

#if defined ONE_COLOR
new Float:CampoColors[ 3 ] = 	{ 50.0 , 150.0 , 250.0 }
#endif

new TrailColor[ 3 ] = 		{ 000, 255, 255 }
new Float:Maxs[ 3 ] = 		{ 100.0 , 100.0 , 100.0 }
new Float:Mins[ 3 ] = 		{ -100.0, -100.0, -100.0 }

new const model_grenade[ ] = 		"models/usp_avatar/v_grenade_shield.mdl";
new const model[ ] = 			"models/usp_avatar/aura8.mdl";
new const w_model[ ] = 			"models/zombie_plague/w_aura.mdl";
new const sprite_grenade_trail[ ] = 	"sprites/laserbeam.spr";
new const entclas[ ] = 			"campo_grenade_forze";

new cvar_flaregrenades, g_trailSpr, g_SayText, g_itemID;

new gBomb;
const Float:Push = 0.50;

public plugin_init( )
{
	new text[ 555 char ];
	register_dictionary( "zombie_plague.txt" );
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam( Ham_Think, "grenade", "fw_ThinkGrenade" );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled" );
	RegisterHam( Ham_Item_Deploy, "weapon_smokegrenade", "shield_deploy", 1 );
	
	cvar_flaregrenades = 		get_cvar_pointer( "zp_flare_grenades" );
	g_SayText = 			get_user_msgid("SayText")
	formatex( text, charsmax( text ), "%L", LANG_PLAYER, "ENER_NAZOV" );
	g_itemID = 			zp_register_extra_item ( text, ITEM_COST , ZP_TEAM_HUMAN )	
	
	register_forward( FM_SetModel, "fw_SetModel" );
	register_forward( FM_Touch, "fw_touch" );
	
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
}

public event_round_start( ) 
{
	#if defined CAMPO_ROUND
	remove_entity_name( entclas );
	#endif
	
	gBomb = 0;
}

public plugin_precache( ) 
{
	
	g_trailSpr = engfunc( EngFunc_PrecacheModel, sprite_grenade_trail );
	engfunc( EngFunc_PrecacheModel, model_grenade );
	engfunc( EngFunc_PrecacheModel, model );
	engfunc( EngFunc_PrecacheModel, w_model );
}

public client_disconnect( id ) 
	gBomb &= ~( 1 << ( id % 32 ) )

public zp_extra_item_selected( player, itemid ) 
{
	if( itemid == g_itemID )
	{
		if( get_user_flags( player ) & ADMIN_LEVEL_F )
		{
			if( gBomb & ( 1 << ( player % 32 ) ) )
				Color( player, "%L", LANG_PLAYER, "ENER_HAVE" )
			else 
			{
				gBomb |= ( 1 << ( player % 32 ) )
				
				if( !user_has_weapon( player, CSW_SMOKEGRENADE ) )
					give_item( player,"weapon_smokegrenade" );
				
				
				Color( player, "%L", LANG_PLAYER, "ENER_BUY" );
			}
		}
		else
		{
			client_cmd( player, "spk valve/sound/buttons/button11" );
			client_print( player, print_chat, "%L", LANG_PLAYER, "ITEM_FOR_PREMIUM" );
			zp_set_user_ammo_packs( player, zp_get_user_ammo_packs( player ) + ITEM_COST );
		}	
	}
}

public fw_PlayerKilled( victim, attacker, shouldgib )
{
	if( ( 1 <= attacker <= 32 ) && ( gBomb & ( 1 << ( victim % 32 ) ) ) ) 
		gBomb &= ~( 1 << ( victim % 32 ) )
}

public fw_ThinkGrenade( entity ) 
{   
	
	if( !pev_valid( entity ) ) return HAM_IGNORED;
	
	static Float:dmgtime;
	pev( entity, pev_dmgtime, dmgtime )
	
	if( dmgtime > get_gametime( ) )
		return HAM_IGNORED;   
	
	if( pev( entity, pev_flTimeStepSound ) == NADE_TYPE_CAMPO )
		crear_ent( entity );
	
	return HAM_SUPERCEDE;
}


public fw_SetModel( entity, const model[ ] ) 
{	
	
	static Float:dmgtime;
	pev( entity, pev_dmgtime, dmgtime );
	
	if( dmgtime == 0.0 )
		return FMRES_IGNORED;
	
	if( equal( model[ 7 ], "w_sm", 4 ) )
	{		
		new owner = pev( entity, pev_owner )		
		
		if( is_user_alive( owner ) && !zp_get_user_zombie( owner ) && ( gBomb & ( 1 << ( owner % 32 ) ) ) ) 
		{
			set_pcvar_num( cvar_flaregrenades,0 );	
			
			fm_set_rendering( entity, kRenderFxGlowShell, random_num( 0, 255 ) , random_num( 0, 255 ), random_num( 0, 255 ), kRenderNormal, 16 );
			
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
			write_byte( TE_BEAMFOLLOW );
			write_short( entity );
			write_short( g_trailSpr );
			write_byte( 10 );
			write_byte( 10 ); 
			write_byte( TrailColor[ 0 ] ); 
			write_byte( TrailColor[ 1 ] ); 
			write_byte( TrailColor[ 2 ] ); 
			write_byte( 500 ); 
			message_end( );
			
			set_pev( entity, pev_flTimeStepSound, NADE_TYPE_CAMPO );
			
			set_task( 6.0, "DeleteEntityGrenade" ,entity );
			gBomb &= ~( 1 << ( owner % 32 ) )
			entity_set_model( entity, w_model );
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
	
}

public DeleteEntityGrenade( entity ) 
	if( is_valid_ent( entity ) )
		remove_entity( entity );

public crear_ent( id ) 
{
	set_pcvar_num( cvar_flaregrenades, 1 );
	
	new iEntity = create_entity( "info_target" );
	
	if( !is_valid_ent( iEntity ) )
		return PLUGIN_HANDLED;
	
	new Float: Origin[ 3 ]; 
	entity_get_vector( id, EV_VEC_origin, Origin );
	
	entity_set_string( iEntity, EV_SZ_classname, entclas );
	
	entity_set_vector( iEntity,EV_VEC_origin, Origin );
	entity_set_model( iEntity,model );
	entity_set_int( iEntity, EV_INT_solid, SOLID_TRIGGER );
	entity_set_size( iEntity, Mins, Maxs );
	entity_set_int( iEntity, EV_INT_renderfx, kRenderFxGlowShell );
	entity_set_int( iEntity, EV_INT_rendermode, kRenderTransAlpha );
	entity_set_float( iEntity, EV_FL_renderamt, 50.0 );
	
	#if defined RANDOM_COLOR
	if( is_valid_ent( iEntity ) )
	{
		new Float:vColor[ 3 ];
		
		for( new i; i < 3; i++ )
			vColor[ i ] = random_float( 0.0, 255.0 );
		
		entity_set_vector( iEntity, EV_VEC_rendercolor, vColor )
	}
	#endif
	
	#if defined ONE_COLOR
	entity_set_vector( iEntity, EV_VEC_rendercolor, CampoColors );
	#endif
	
	#if defined CAMPO_TASK
	set_task( 100.0, "DeleteEntity", iEntity );
	#endif

	return PLUGIN_CONTINUE;
}

public zp_user_infected_post( infected, infector ) 
	if ( gBomb & ( 1 << ( infected % 32 ) ) ) 
		gBomb &= ~( 1 << ( infected % 32 ) ) 

public fw_touch( ent, touched )
{
	if ( !pev_valid( ent ) ) return FMRES_IGNORED;
	static entclass[ 32 ];
	pev( ent, pev_model, entclass, 31 );
	
	if ( strcmp( entclass, model ) == 0 )
	{	
		if( ValidTouch( touched ) )
		{
			static Float:pos_ptr[ 3 ], Float:pos_ptd[ 3 ];
			
			pev( ent, pev_origin, pos_ptr );
			pev( touched, pev_origin, pos_ptd );
			
			for( new i = 0; i < 3; i++ )
			{
				pos_ptd[ i ] -= pos_ptr[ i ];
				pos_ptd[ i ] *= Push;
			}
			set_pev( touched, pev_velocity, pos_ptd );
			set_pev( touched, pev_impulse, pos_ptd );
		}
	}
	return FMRES_HANDLED
}


public DeleteEntity( entity )
	if( is_valid_ent( entity ) ) 
		remove_entity( entity );

stock Color( const id, const input[ ], any:... )
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

public shield_deploy( shield_ent )
{
	if( pev_valid( shield_ent ) != 2 )
		return HAM_IGNORED;
	
	static const mPlayer = 41
	
	new id = get_pdata_cbase( shield_ent, mPlayer, 4 );
	
	if( ( gBomb & ( 1 << ( id % 32 ) ) ) && !zp_get_user_zombie( id ) )
		set_pev( id, pev_viewmodel2, model_grenade );
	
	return HAM_IGNORED;
}
