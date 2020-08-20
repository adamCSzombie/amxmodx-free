#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < engine >
#include < hamsandwich >
#include < zombieplague >
#include < fun >
#include < cstrike >
#include < xs >
#include < fakemeta_util >
#include < fakemeta >

#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

new g_maxplayers;

const chainsaw_ap_cost = 200;
const g_buy_armor = 999;
const g_max_regen = 999;
//const g_add_regen_armor = 10
const hannibal_ap = 5;

new MaHanibala[ 33 ];

new limit_hann;

new moze_task[ 33 ];

new const chainsaw_viewmodel[ ] = "models/chainsaw/v_chainsaw.mdl";	
new const chainsaw_playermodel[ ] = "models/chainsaw/p_chainsaw.mdl";	
new const chainsaw_worldmodel[ ] = "models/chainsaw/w_chainsaw.mdl";	

new const chainsaw_sounds[ ][ ] =
{
	"chainsaw/chainsaw_deploy.wav",		
	"chainsaw/chainsaw_hit1.wav",		
	"chainsaw/chainsaw_hit2.wav",		
	"chainsaw/chainsaw_hit1.wav",		
	"chainsaw/chainsaw_hit2.wav",		
	"chainsaw/chainsaw_hitwall.wav",	
	"chainsaw/chainsaw_miss.wav",		
	"chainsaw/chainsaw_miss.wav",		
	"chainsaw/chainsaw_stab.wav"		
}

new Float:chainsaw_mins[ 3 ] = { -2.0, -2.0, -2.0 };
new Float:chainsaw_maxs[ 3 ] = { 2.0, 2.0, 2.0 };
//new MaHanibala[ 33 ] = false

new g_iItemID, g_msgCurWeapon, g_Motorovka;

new g_iHasChainsaw[ 33 ], g_iCurrentWeapon[ 33 ]

new g_MsgSync;

new g_pCVAR_HanibalHealth;
new g_pCVAR_HanibalArmor;
new jumpnum[ 33 ] = 0;
new bool:dojump[ 33 ] = false;
new Gravity[ 33 ] = 0;

new cvar_enable, cvar_dmgmult, cvar_oneround, cvar_sounds, cvar_dmggore, cvar_dropflags,
cvar_pattack_rate, cvar_sattack_rate, cvar_pattack_recoil, cvar_sattack_recoil;

const DROPFLAG_NORMAL = 		( 1<<0 );
const DROPFLAG_INDEATH =	( 1<<1 );
const DROPFLAG_INFECTED =	( 1<<2 ); 
const DROPFLAG_SURVHUMAN =	( 1<<3 );

const m_pPlayer = 		41;
const m_flNextPrimaryAttack = 	46;
const m_flNextSecondaryAttack =	47;
const m_flTimeWeaponIdle = 	48;

new const oldknife_sounds[ ][ ] =
{
	"weapons/knife_deploy1.wav",	
	"weapons/knife_hit1.wav",	
	"weapons/knife_hit2.wav",	
	"weapons/knife_hit3.wav",	
	"weapons/knife_hit4.wav",	
	"weapons/knife_hitwall1.wav",	
	"weapons/knife_slash1.wav",	
	"weapons/knife_slash2.wav",	
	"weapons/knife_stab.wav"
}

#define PLUG_VERSION 	"2.3"
#define PLUG_AUTH 	"adamCSzombie"

public plugin_natives()
{
	register_native("is_user_hannibal","native_is_user_hannibal",1)
	register_native( "have_user_hannibal", "native_is_user_hannibal", 1 );
}

public plugin_init( )
{
	register_plugin( "[ZP-Extra] Hannibal Lector & Chainsaw", PLUG_VERSION, PLUG_AUTH );
	
	RegisterHam( Ham_Killed,"player","Hrac_Zomrel",1 );
	RegisterHam( Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post", 0 );
		
	register_event( "HLTV", "event_RoundStart", "a", "1=0", "2=0" );
	register_event( "CurWeapon", "event_CurWeapon", "b", "1=1" );
	register_event( "HLTV", "event_round_start", "a", "1=0", "2=0" );
	//register_event( "CurWeapon", "event_CurWeaponn", "be", "1=1" );
	
	cvar_enable = 		register_cvar( "zp_chainsaw_enable", 		"1" );// 1 = Zapnute , 0 = Vypnute
	cvar_dmgmult = 		register_cvar( "zp_chainsaw_damage_multixx", 	"888" ); // DMG Motorovky (nemenit)
	cvar_dmggore = 		register_cvar( "zp_chainsaw_gore_in_damage", 	"1" ); // (NEMENIT)
	cvar_oneround = 	register_cvar( "zp_chainsaw_oneround", 		"0" );
	cvar_sounds = 		register_cvar( "zp_chainsaw_custom_sounds", 	"1" );
	cvar_dropflags = 	register_cvar( "zp_chainsaw_drop_flags", 	"" );
	cvar_pattack_rate = 	register_cvar( "zp_chainsaw_attack1_rate", 	"0.6" );
	cvar_sattack_rate = 	register_cvar( "zp_chainsaw_attack2_rate", 	"1.2" );
	cvar_pattack_recoil = 	register_cvar( "zp_chainsaw_attack1_recoil", 	"-5.6" );
	cvar_sattack_recoil = 	register_cvar( "zp_chainsaw_attack2_recoil", 	"-8.0" );
	g_pCVAR_HanibalHealth = register_cvar( "zp_hanibal_health", 		"999" );
	g_pCVAR_HanibalArmor = 	register_cvar( "zp_hanibal_armor", 		"999" );
	
	new szCvar[ 30 ];
	formatex( szCvar, charsmax( szCvar ), "v%s by %s", PLUG_VERSION, PLUG_AUTH );
	register_cvar( "zp_extra_chainsaw", szCvar, FCVAR_SERVER|FCVAR_SPONLY );
	
	register_forward( FM_EmitSound, "fw_EmitSound" );
	
	RegisterHam( Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1 );
	RegisterHam( Ham_Killed, "player", "fw_PlayerKilled" );
	RegisterHam( Ham_TakeDamage, "player", "fw_TakeDamage" );
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_Knife_PrimaryAttack_Post", 1 );
	RegisterHam( Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1 );
	register_forward( FM_PlayerPreThink,"Fwd_PlayerPreThink" );
	
	g_Motorovka = zp_register_extra_item( "Motorova Pila", 10, ZP_TEAM_HUMAN );
	g_iItemID = zp_register_extra_item( "Hannibal [\rExtraVIP\w]", chainsaw_ap_cost, ZP_TEAM_HUMAN );
	
	g_msgCurWeapon = get_user_msgid( "CurWeapon" );
	
	register_clcmd( "drop", "clcmd_drop" );
	register_clcmd( "drop", "clcmd_dropp" );
	
	g_maxplayers = get_maxplayers( );
	g_MsgSync = CreateHudSyncObj( );
}

public plugin_precache( )
{
	precache_model( chainsaw_viewmodel );
	precache_model( chainsaw_playermodel );
	precache_model( chainsaw_worldmodel );
	
	for( new i = 0; i < sizeof chainsaw_sounds; i++ )
		precache_sound( chainsaw_sounds[ i ] );
		
	precache_sound( "bluezone/zombie/starter.wav" );
	precache_sound( "playaspro/still.wav" );
}

public event_RoundStart( )
{
	remove_entity_name( "cs_chainsaw" );
}

public event_CurWeapon( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_CONTINUE;
	
	g_iCurrentWeapon[ id ] = read_data( 2 );
	
	if( zp_get_user_zombie( id ) || zp_get_user_survivor( id ) )
		return PLUGIN_CONTINUE;
		
	if(!g_iHasChainsaw[ id ] || g_iCurrentWeapon[ id ] != CSW_KNIFE ) 
		return PLUGIN_CONTINUE
		
	entity_set_string( id, EV_SZ_viewmodel, chainsaw_viewmodel );
	entity_set_string( id, EV_SZ_weaponmodel, chainsaw_playermodel );
		
	return PLUGIN_CONTINUE;
}

public clcmd_drop( id )
{
	if( g_iHasChainsaw[ id ] && g_iCurrentWeapon[ id ] == CSW_KNIFE )
	{
		if( check_drop_flag( DROPFLAG_NORMAL ) )
		{
			drop_chainsaw( id );
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public clcmd_dropp( id )
{
	if( g_iHasChainsaw[ id ] && g_iCurrentWeapon[ id ] == CSW_MAC10 )
	{
		if( check_drop_flag( DROPFLAG_SURVHUMAN ) )
		{
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}

public drop_chainsaw( id ) 
{
	static Float:flAim[ 3 ], Float:flOrigin[ 3 ]
	VelocityByAim( id, 64, flAim );
	entity_get_vector( id, EV_VEC_origin, flOrigin )
	
	flOrigin[ 0] += flAim[ 0 ];
	flOrigin[ 1] += flAim[ 1 ];
	
	new iEnt = create_entity( "info_target" );
	
	entity_set_string( iEnt, EV_SZ_classname, "cs_chainsaw" );
	entity_set_origin( iEnt, flOrigin );
	entity_set_model( iEnt, chainsaw_worldmodel );
	
	set_size( iEnt, chainsaw_mins, chainsaw_maxs );
	
	entity_set_vector( iEnt, EV_VEC_mins, chainsaw_mins );
	entity_set_vector( iEnt, EV_VEC_maxs, chainsaw_maxs );
	
	entity_set_int( iEnt, EV_INT_solid, SOLID_TRIGGER );
	entity_set_int( iEnt, EV_INT_movetype, MOVETYPE_TOSS );
	
	g_iHasChainsaw[ id ] = false;
	
	reset_user_knife( id );
}

public reset_user_knife( id )
{
	if( user_has_weapon( id, CSW_KNIFE ) )
		ExecuteHamB( Ham_Item_Deploy, find_ent_by_owner( -1, "weapon_knife", id ) );
		
	engclient_cmd( id, "weapon_knife" );
	emessage_begin( MSG_ONE, g_msgCurWeapon, _, id );
	ewrite_byte( 1 );
	ewrite_byte( CSW_KNIFE ); 
	ewrite_byte( -1 );
	emessage_end( );
}

public native_is_user_hannibal( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id )
		return -1;
	}
	
	return MaHanibala[ id ]
}

public zp_extra_item_selected( id, itemid )
{

	if( itemid == g_iItemID )
	{
		hannibal( id );
	}
	if( itemid == g_Motorovka )
		{
		if( get_pcvar_num( cvar_enable ) )
		{
			if( g_iHasChainsaw[ id ] )
			{
				ChatColor( id, "!g[ZP]!y Uz mas zakupenu !gmotorovu pilu!" );
			}
			else 
			{
				g_iHasChainsaw[ id ] = true;
				Gravity[ id ] = 0;
				MaHanibala[ id ] = false;
				ChatColor( id, "!g[ZP]!y Prave si si zakupil !gMotorovu Pilu!" );
				
				emit_sound( id, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
				
				reset_user_knife( id );
			}
		}
		else
		{
			client_print(id, print_center, "")
		}
	}
}
		
public hannibal( id )
{
	if( get_pcvar_num( cvar_enable ) )
	{
		if( limit_hann != 4 )
		{
			if( MaHanibala[ id ])
			{
				client_print(id, print_center,"Uz si hannibal!")
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 200 )
				return;
			}
			if( is_user_terminator( id ) )
			{
				client_print(id, print_center,"Ked si Terminator nemozes kupit Hannibala!")
				zp_set_user_ammo_packs(id, zp_get_user_ammo_packs(id) + 200 )
				return;
			}
			if ( !zp_has_round_started( ) )
			{
				client_print( id, print_chat,"Pockaj kym zacne kolo!" )
				zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 )
				return;
			}
			
			g_iHasChainsaw[ id ] = true;
			
			new sIdName[ 32 ];
			
			limit_hann += 1;
			
			ChatColor( 0, "!g[ZP]!y Aktualny pocet !tHannibalov!y je !g%d!y ze !g4", limit_hann );
			
			fm_strip_user_weapons( id );
			
			fm_give_item( id, "weapon_knife" );
			fm_give_item( id, "weapon_mac10" );
			
			get_user_name( id, sIdName, 31 );
			
			set_hudmessage( 208, 114, 224, -1.0, 0.13, 1, 0.0, 5.0, 1.0, 1.0, -1 );
			ShowSyncHudMsg( 0, g_MsgSync, "%s je Hannibal Lector !", sIdName );
			
			ScreenFade( id, 1.0, 208, 114, 224, 100 );
			
			Gravity[ id ] = 1;
			
			set_user_rendering( id, kRenderFxGlowShell, 208, 114, 224, kRenderNormal, 16 );
			set_user_health( id, get_pcvar_num( g_pCVAR_HanibalHealth ) );
			set_user_armor( id, get_pcvar_num( g_pCVAR_HanibalArmor ) );
			MaHanibala[ id ] = true;
			set_pev( id, pev_armorvalue, float( g_buy_armor ) );
			//set_task(1.0, "regeneration", id, _, _, "b")
			ChatColor( id, "!g[ZP]!y Zakupil si si !gHannibala! !y(+999AP,+999HP,HIT +5AP, +4 Skoky)" );
			
			emit_sound( id, CHAN_WEAPON, "bluezone/zombie/starter.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
			
			reset_user_knife( id );
		}
		else
		{
			ChatColor( id,"!g[HANNIBAL LECTOR]!y Na servery mozu byt iba 4 !gHannibali" );
			zp_set_user_ammo_packs( id, zp_get_user_ammo_packs( id ) + 200 );
		}
	}
}

public Hrac_Zomrel( victim,attacker,shouldgibc )
{
	if( is_user_alive( attacker ) )
	{
		if( !zp_get_user_last_human( attacker ) && MaHanibala[ attacker ] )
		{
			set_pev( attacker, pev_armorvalue, float( min( pev( attacker, pev_armorvalue ) + 5, g_max_regen ) ) );
			client_print( attacker, print_center,"+5 Armoru" );
		}
	}
}

public event_round_start( id )
{
	for ( new player; player <= 32; player++ )
	{
		set_task(5.0, "han_dalsi_kolo",id)
	}
	for( new i = 1; i < 33 ; i++ )
		remove_task( i );
}

public han_dalsi_kolo(id){

	if( MaHanibala[ id ] )
	{
		g_iHasChainsaw[ id ] = true;
		fm_strip_user_weapons( id );
		fm_give_item( id, "weapon_knife" );
		fm_give_item( id, "weapon_mac10" );
		fm_set_user_armor( id, 500 );
		fm_set_user_health( id, 500 );
		/*set_pev( player, pev_armorvalue, float( min( pev( player, pev_armorvalue ) + 500, g_max_regen ) ) );
		set_pev( player, pev_health, float( min( pev( player, pev_health ) + 500, g_max_regen ) ) );*/
		ChatColor( id, "!g[ZP]!y Ziskal si 500 armor a 500 HP pro tvojo !gHannibala" );
		client_print( id, print_center, "Hannibal ti zostava na dalsie kolo" );
		emit_sound( id, CHAN_WEAPON, "playaspro/still.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
	}
}

public client_putinserver( player )
{
	remove_task( player );
	jumpnum[ player ] = 0;
	dojump[ player ] = false;
	Gravity[ player ] = 0;
	g_iHasChainsaw[ player ] = false;
	
	moze_task[ player ] = 0;
}

public client_disconnect( player )
{
	if( MaHanibala[ player ] )
	{
		if( task_exists( player ) )
		remove_task( player );
		jumpnum[ player ] = 0;
		dojump[ player ] = false;
		Gravity[ player ] = 0;
		g_iHasChainsaw[ player ] = false;
		
		moze_task[ player ] = 0;
		
		limit_hann -= 1;
	}
}

public zp_user_infected_post( player )
{
	if( MaHanibala[ player ] )
	{
		MaHanibala[ player ] = false;
		jumpnum[ player ] = 0;
		dojump[ player ] = false;
		Gravity[ player ] = 1;
		g_iHasChainsaw[ player ] = false;
		remove_task( player );
		
		limit_hann -= 1;
		
		moze_task[ player ] = 0;
	}
}

public zp_user_infected_pre( id, infector )
{
	if( g_iHasChainsaw[ id ] )
	{
		if( check_drop_flag( DROPFLAG_INFECTED ) )
			drop_chainsaw( id );
		else
		{
			g_iHasChainsaw[ id ] = false;
			
			reset_user_knife( id );
		}
	}
}

public zp_user_humanized_post( id )
{
	if( zp_get_user_survivor( id ) )
	{
		if( check_drop_flag( DROPFLAG_SURVHUMAN ) )
			drop_chainsaw( id );
		else
		{
			g_iHasChainsaw[ id ] = false;
			
			reset_user_knife( id );
		}
	}
}

public fw_PlayerSpawn_Post( id )
{	
	if( get_pcvar_num( cvar_oneround ) || !get_pcvar_num( cvar_enable ) )
	{
		if( g_iHasChainsaw[ id ] )
		{
			g_iHasChainsaw[ id ] = false;

			reset_user_knife( id );
		}
	}
}

public fw_TakeDamage( victim, inflictor, attacker, Float:damage, damage_bits )
{	
	if( victim == attacker || !attacker )
		return HAM_IGNORED;
		
	if( !is_user_connected( attacker ) )
		return HAM_IGNORED;
		
	if( g_iHasChainsaw[ attacker ] && g_iCurrentWeapon[ attacker ] == CSW_KNIFE )
	{
		if( get_pcvar_num( cvar_dmggore ) )
			a_lot_of_blood( victim );
		
		SetHamParamFloat( 4, get_pcvar_float( cvar_dmgmult ) )	

	}
	else if( get_pdata_int( victim, 75 ) == HIT_HEAD && g_iHasChainsaw[ attacker ] && g_iCurrentWeapon[ attacker ] == CSW_KNIFE )
	{
		SetHamParamFloat( 4, get_pcvar_float( cvar_dmgmult ) );	
	}

	return HAM_IGNORED;
}

public fw_PlayerKilled( victim, attacker, shouldgib )
{
	if( g_iHasChainsaw[ attacker ] && g_iCurrentWeapon[ attacker ] == CSW_KNIFE && !zp_get_user_nemesis( victim ) )
		SetHamParamInteger( 3, 2 );
	
	if( g_iHasChainsaw[ victim ] )
	{
		if( check_drop_flag( DROPFLAG_INDEATH ) )
			drop_chainsaw( victim );
		else
		{
			g_iHasChainsaw[ victim ] = false;
			
			reset_user_knife( victim );
		}
	}
}

public fw_EmitSound( id, channel, const sound[ ] )
{
	if( !is_user_alive( id ) || zp_get_user_zombie( id ) || zp_get_user_survivor( id ) || !g_iHasChainsaw[ id ] || !get_pcvar_num( cvar_sounds ) )
		return FMRES_IGNORED;
		
	for( new i = 0; i < sizeof chainsaw_sounds; i++ )
	{
		if( equal( sound, oldknife_sounds[ i ] ) )
		{
			emit_sound( id, channel, chainsaw_sounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
			return FMRES_SUPERCEDE;
		}
	}
			
	return FMRES_IGNORED;
}

public Fwd_PlayerPreThink( id )
{
	if( !is_user_alive( id ) )
		return PLUGIN_HANDLED;
		
	static temp, weapon;
	weapon = get_user_weapon( id, temp, temp );
	
	if( weapon == CSW_KNIFE && g_iHasChainsaw[ id ] )
	{
		static button;
		button = pev( id, pev_button );
		
		if( button & IN_ATTACK )
		{
			button = ( button & ~IN_ATTACK ) | IN_ATTACK2;
			set_pev( id, pev_button, button );
		}
	}
	return PLUGIN_HANDLED;
}

public fw_Knife_PrimaryAttack_Post( knife )
{	
	static id;
	id = get_pdata_cbase( knife, m_pPlayer, 4 )
	
	if( is_user_connected( id ) && g_iHasChainsaw[ id ] )
	{
		static Float:flRate;
		flRate = get_pcvar_float( cvar_pattack_rate );
		
		set_pdata_float( knife, m_flNextPrimaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flNextSecondaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flTimeWeaponIdle, flRate, 4 );
		
		static Float:flPunchAngle[ 3 ];
		flPunchAngle[ 0 ] = get_pcvar_float( cvar_pattack_recoil );
		
		entity_set_vector( id, EV_VEC_punchangle, flPunchAngle );
		
	}
	
	return HAM_IGNORED;
}

public fw_Knife_SecondaryAttack_Post( knife )
{	
	static id;
	id = get_pdata_cbase( knife, m_pPlayer, 4 )
	
	if( is_user_connected( id ) && g_iHasChainsaw[ id ] )
	{
		static Float:flRate;
		flRate = get_pcvar_float( cvar_sattack_rate );
		
		set_pdata_float( knife, m_flNextPrimaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flNextSecondaryAttack, flRate, 4 );
		set_pdata_float( knife, m_flTimeWeaponIdle, flRate, 4 );
		
		static Float:flPunchAngle[ 3 ];
		flPunchAngle[ 0 ] = get_pcvar_float( cvar_sattack_recoil );
		
		entity_set_vector( id, EV_VEC_punchangle, flPunchAngle );
	}
	
	return HAM_IGNORED;
}

check_drop_flag( flag )
{
	new szFlags[ 10 ];
	get_pcvar_string( cvar_dropflags, szFlags, charsmax( szFlags ) )
	
	if( read_flags( szFlags ) & flag )
		return true;
		
	return false;
}

a_lot_of_blood( id )
{
	static iOrigin[ 3 ];
	get_user_origin( id, iOrigin );
	
	message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BLOODSTREAM );
	write_coord( iOrigin[ 0 ] );
	write_coord( iOrigin[ 1 ] );
	write_coord( iOrigin[ 2 ]+10 );
	write_coord( random_num( -360, 360 ) ); 
	write_coord( random_num( -360, 360 ) ); 
	write_coord( -10 ); 
	write_byte( 70 ); 
	write_byte( random_num( 50, 100 ) ); 
	message_end( );
	
	for (new j = 0; j < 4; j++) 
	{
		message_begin( MSG_PVS, SVC_TEMPENTITY, iOrigin );
		write_byte( TE_WORLDDECAL );
		write_coord( iOrigin[ 0 ]+random_num( -100, 100 ) );
		write_coord( iOrigin[ 1 ]+random_num( -100, 100 ) );
		write_coord( iOrigin[ 2 ]-36 );
		write_byte( random_num( 190, 197 ) );
		message_end( );
	}
}

public client_PreThink( player )
{
	if( !is_user_alive( player ) ) return PLUGIN_CONTINUE;
	
	if( MaHanibala[ player ] )
	{
		set_user_rendering( player, kRenderFxGlowShell, 208, 114, 224, kRenderNormal, 14 );
			
		new nbut = get_user_button( player );
		new obut = get_user_oldbutton( player );
		if( ( nbut & IN_JUMP ) && !( get_entity_flags( player ) & FL_ONGROUND ) && !( obut & IN_JUMP ) )
		{
			if( jumpnum[ player ] < 3 ) // skoky
			{
				dojump[ player ] = true;
				jumpnum[ player ]++;
				ChatColor( player, "!g[ZP]!y Pouzil si !t%d!y / !t3 !yskokov!", jumpnum[ player ] );
				return PLUGIN_CONTINUE;
			}
			else
			{
				ChatColor( player, "!g[ZP]!y Pockaj si par sekund pokial mozes znova pouzit 3 skoky!" );
			}
		}
		if( ( nbut & IN_JUMP ) && ( get_entity_flags( player ) & FL_ONGROUND ) )
		{
			if( jumpnum[ player ] == 3 )
			{
				moze_task[ player ] = 1;
						
				if( moze_task[ player ] == 1 )
				{
					moze_task[ player ] = 2;
					set_task( 6.0, "skoky", player );
				}
			}
			return PLUGIN_CONTINUE;
		}
	}
	return PLUGIN_CONTINUE;
}

public skoky( id )
{
	if( moze_task[ id ] == 2 )
	{
		if( is_user_alive( id ) && MaHanibala[ id ] && !zp_get_user_zombie( id ) )
		{
			ChatColor( id, "!g[ZP]!y Tvoje skoky boli obnovene! Skoky !t4 !y/ !t4!y !" );
			jumpnum[ id ] = 0;
			moze_task[ id ] = 0;
		}
	}
}

public client_PostThink( player )
{
	if( !is_user_alive( player ) ) return PLUGIN_CONTINUE;
	
	if( MaHanibala[ player ] )
	{
		if( dojump[ player ] == true )
		{
			new Float:velocity[ 3 ];
			entity_get_vector( player,EV_VEC_velocity,velocity );
			velocity[ 2 ] = random_float( 265.0,285.0 );
			entity_set_vector( player,EV_VEC_velocity,velocity );
			dojump[ player ] = false;
			return PLUGIN_CONTINUE;
		}
	}
	return PLUGIN_CONTINUE;
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

public ham_Player_TakeDamage_Post( iVictim, iInfictor, iAttacker, Float:fDamage, iDmgBits )
{
	//static CsTeams:vteam; vteam = cs_get_user_team( iVictim );
	//static CsTeams:ateam; ateam = cs_get_user_team( iAttacker );
	
	if( !is_user_connected( iVictim ) || !is_user_connected( iAttacker ) || iVictim == iAttacker )
		return HAM_IGNORED;
		
	new iWeapon = get_user_weapon( iAttacker );
	
	
	switch( cs_get_user_team( iAttacker ) )
	{
		case CS_TEAM_CT:
		{
			if( !zp_get_user_last_human( iAttacker ) && MaHanibala[ iAttacker ] == 1 && cs_get_user_team( iVictim ) == CS_TEAM_T )
			{
				if( iWeapon == CSW_KNIFE )
				{
					client_print( iAttacker, print_center, "+5 Armoru" );
					set_pev( iAttacker, pev_armorvalue, float( min( pev( iAttacker, pev_armorvalue ) + hannibal_ap, g_max_regen ) ) );
				}
			}
		}
		
	}
	
	return HAM_IGNORED;
}

stock fm_set_user_armor_fur( id, armor ) 
{
	set_pev( id, pev_armorvalue, float( armor ) );
	return 1;
}

