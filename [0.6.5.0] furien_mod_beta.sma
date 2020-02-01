/* FURIEN MOD */
#include < amxmodx >
#include < amxmisc >
#include < hamsandwich >
#include < cstrike >
#include < fun >
#include < fakemeta >
#include < engine >
#include < nvault >
#include < dhudmessage >
#include < fakemeta_util >
#include < furien >
#include < csx >
#include < xs >

#define is_user_valid(%1) (1 <= %1 <= maxplayers)
#define TASK_FUNKOLO		1234554321
#define TASK_REKLAMA		1234554321

new CvarDistance;

#define FADE_IN    (1<<0)
#define FADE_OUT    (1<<1)
#define FADE_HOLD (1<<2)
#define FADE_LENGTH_PERM (1<<0)

const Float:HUD_STATS_X = 0.02;
const Float:HUD_STATS_Y = 0.93;

new g_truhla_percenta[ 33 ], g_truhla_openning[ 33 ];

const g_max_defense = 999;
const g_max_health = 999;
const g_max_player_health = 100;
new g_maxHP[ 33 ] = 0;

new g_limitspeed[ 33 ], g_limitsuperknife[ 33 ];

new players;

enum ( += 1000 ) 
{
	TASK_REGEN = 1000
};

new g_round_aktualne = 0;

new const funkolonew[ ][ ] =
{
	"bz_furien_mod/funkolo/timer001.wav", 	// 1
	"bz_furien_mod/funkolo/timer002.wav", 	// 2
	"bz_furien_mod/funkolo/timer003.wav", 	// 3
	"bz_furien_mod/funkolo/timer004.wav", 	// 4
	"bz_furien_mod/funkolo/timer005.wav", 	// 5
	"bz_furien_mod/bomb_plant.wav", 	// 6
	"bz_furien_mod/truhla_item.wav" 	// 7
};

#define PLUGIN 	"[Furien Mod]"
#define VERSION "b0.6.5"
#define AUTHOR 	"Adam *adamCSzombie* Valiska"

const PEV_SPEC_TARGET = pev_iuser2;

#define TASK_MULTIHUD 		239283
#define TASK_MULTIHUDNEW 	239282
#define TASK_GODMODE 		25042014

#define MAX_KILL 		9
#define RESET_TIME 		6500.0
#define KILL_CHECK_DELAY 	0.2
#define TASK_CHECK_KILL 	1962+1992
#define TASK_RESET_TIME 	1962+1982

enum (+= 100)
{
	TASK_SHOWHUD
}

#define TASK_CANPLANT		10001

new bool: g_bCanPlant;

#define SYNCHUD_NUMBER random_num(100, 1000)

#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])

#define ID_SHOWHUD (taskid - TASK_SHOWHUD)

new g_isalive[ 33 ];

#define IsUserValidConnected(%1)	(FIRST_PLAYER <= %1 <= maxplayers && g_bIsConnected[%1])

#define MAX_PLAYERS    		32 
#define USE_STOPPED		0
#define FIRST_PLAYER		1
#define PDATA_SAFE		2
#define USE_TOGGLE 		3 
#define OFFSET_LINUX_WEAPONS	4
#define XTRA_OFS_PLAYER		5
#define XO_PLAYER		5
#define PLAYER_JUMP		6
#define ACT_HOP 		7
#define m_pPlayer 		41
#define OFFSET_CLIPAMMO		51
#define m_Activity 		73
#define m_IdealActivity		74
#define m_flNextAttack		83
#define m_afButtonPressed	246
#define m_flFallVelocity	251
#define m_pActiveItem		373
#define IsPlayer(%0) 		(1 <= %0 <= 32)

#define set_bit(%1,%2) 		(%1|=(1<<(%2&31)))
#define get_bit(%1,%2) 		(%1&1<<(%2&31))
#define clear_bit(%1,%2) 	(%1&=~(1<<(%2&31)))

#define VIP ADMIN_LEVEL_H // Nastavenie VIP Modelu
#define EVIP ADMIN_LEVEL_G // Nastavenie ExtraVIP Modelu

new g_pocetodohranych[ 33 ], g_pocetfunkol[ 33 ], g_pocetprikladov[ 33 ];

enum
{
	KILL_HEADSHOT = 1,
	KILL_GRENADE,
	KILL_MELEE
};

enum _:g_vsetkynoze
{
	KNIFE_DEFAULT,
	KNIFE_SUPER,
	KNIFE_AXE,
	KNIFE_ASSASIN,
	KNIFE_BLOODY,
	KNIFE_CROW,
	KNIFE_USARMY,
	KNIFE_ICE,
	KNIFE_ULTI,
	KNIFE_DRAGON,
	KNIFE_NEON
};
new g_pHPCost[ 33 ], g_pAPCost[ 33 ], g_pDMCost[ 33 ];
new exp[ 33 ], g_unHPLevel[ 33 ], g_unAPLevel[ 33 ], g_unDMLevel[ 33 ];
new g_pcvar_unhpcost, g_pcvar_unapcost, g_pcvar_undmcost, g_pcvar_unhpmult, g_pcvar_unapmult, g_pcvar_undmmult;

#define NAJVIAC_NOZOV 10

new g_noze[ 33 ][ g_vsetkynoze ];

new g_event_drop = 1, g_msg_event;
#define TASK_EVENT	999999999999999999

#define MAX_WEAPON CSW_P90

new const g_iMaxClipAmmo[ MAX_WEAPON + 1 ] =
{
	0, 13, 0, 10, 0, 7, 0, 30, 30, 0, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 
	100, 8, 30, 30, 20, 0, 7, 30, 30, 0, 50
};

new const DMG_NADE = ( 1<<24 );
new const prefix[ ] = { "!g[Gamesites.cz]" };

#define PISTOL_WEAPONS_BIT	(1<<CSW_GLOCK18|1<<CSW_USP|1<<CSW_DEAGLE|1<<CSW_P228|1<<CSW_FIVESEVEN|1<<CSW_ELITE)
#define SHOTGUN_WEAPONS_BIT	(1<<CSW_M3|1<<CSW_XM1014)
#define SUBMACHINE_WEAPONS_BIT	(1<<CSW_TMP|1<<CSW_MAC10|1<<CSW_MP5NAVY|1<<CSW_UMP45|1<<CSW_P90)
#define RIFLE_WEAPONS_BIT	(1<<CSW_FAMAS|1<<CSW_GALIL|1<<CSW_AK47|1<<CSW_SCOUT|1<<CSW_M4A1|1<<CSW_SG550|1<<CSW_SG552|1<<CSW_AUG|1<<CSW_AWP|1<<CSW_G3SG1)
#define MACHINE_WEAPONS_BIT	(1<<CSW_M249)
#define PRIMARY_WEAPONS_BIT	(SHOTGUN_WEAPONS_BIT|SUBMACHINE_WEAPONS_BIT|RIFLE_WEAPONS_BIT|MACHINE_WEAPONS_BIT)
#define SECONDARY_WEAPONS_BIT	(PISTOL_WEAPONS_BIT)

new const WEAPONENTNAMES[ ][ ] = 
{
	"", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
	"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
	"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
	"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
	"weapon_ak47", "weapon_knife", "weapon_p90"
};

#define IsPrimaryWeapon(%1)	((1<<%1) & PRIMARY_WEAPONS_BIT)
#define IsSecondaryWeapon(%1)	((1<<%1) & PISTOL_WEAPONS_BIT)

new const g_szLaserSprite[ ] = { "sprites/zbeam4.spr" };

new g_iPlayerCamera[ MAX_PLAYERS+1 ];

new g_bInCamera;
//#define MarkUserInCamera(%0)        g_bInCamera |= 1<<(%0&31) 
#define ClearUserInCamera(%0)        g_bInCamera &= ~(1<<(%0&31)) 
#define IsUserInCamera(%0)            ( g_bInCamera & 1<<(%0&31) ) 
#define ToggleUserCameraState(%0)    g_bInCamera ^= 1<<(%0&31) 

new const zvuk_skacko[ ] = 	"bz_furien_mod/skacko.wav";
new const zvuk_speed[ ] = 	"bz_furien_mod/speed.wav";
new const zvuk_radar[ ] = 	"bz_furien_mod/radar_new.wav";
new const zvuk_menu[ ] = 	"bz_furien_mod/menu_item.wav";
new const zvuk_heal[ ] = 	"bz_furien_mod/menu_heal.wav";
new const zvuk_knife[ ] = 	"bz_furien_mod/menu_knife.wav";
new const zvuk_premenu[ ] =	"bz_furien_mod/menu_p.wav";

new const fura_vipTT[ ] = "models/player/bz_fura/bz_fura.mdl";
new const fura_vipCT[ ] = "models/player/gign_fur/gign_fur.mdl";
new const fura_vipCTT[ ] = "models/player/gign_fur/gign_furT.mdl";

new g_reklama[ 33 ], g_priklady[ 33 ]; 

new const Herne_Menu[ ][ ] = 
{
	"Zbrane",//0 
	"Knife",//1
	"Obchod", //2
	"\yItemy",//3
	"\yEpic Menu \d( \rBETA \d)",//4
	"Ostatne",//5
	"\yAktivacia VIP",//6
	"\yAktivacia ExtraVIP",//7
	"\yAdmin Menu"//8
};

new const Zbrane_Menu[ ][ ] = 
{
	"UMP^t^t^t  \r0$",//0 
	"M3^t^t^t    \r0$",//1
	"AWP^t^t^t\r15$", //2
	"MP5^t^t  \r25$",//3
	"AK47^t  \r35$",//4
	"M4A1   \r35$",//5
	"\y[VIP]\w P90   \r35$",//6
	"\y[ExtraVIP]\w XM1014 ^t\r40$"//7
};

new const Itemy[ ][ ] = 
{
	"Ziadny Item",//0 
	"Regeneracia",//1
	"Absolute Defense", //2
	"Multijump",//3
	"Nesmrtelnost",//4
	"Bunny Hop",//5
	"Drtive Strely",//6
	"Epic Money",//7
	"Laser"//8
};

new const Odkazy[ ][ ] = 
{
	"http://www.gamesites.cz",//0
	"http://www.gamesites.cz/furien-1/evip/default/"//1
};

new const Pistole_Menu[ ][ ] = 
{
	"Glock^t^t^t^t^t^t^t \dcena:^t\r0$",//0 
	"USP pistol^t^t^t \dcena:^t\r5$",//1
	"FiveseveN^t^t^t\dcena:^t\r5$", //2
	"Desert Eagle^t\dcena:^t\r15$",//3
	"Elite duals^t^t^t\dcena:^t\r20$"//4
};

new const OtherSounds[ ][ ] = 
{
	"bluezone/furien/funkolo.mp3", // 1
	"bluezone/furien/item_aktivacia.mp3", // 2
	"bluezone/furien/no_act_item.mp3", // 3
	"bluezone/furien/vyber_item.mp3", // 4
	"bluezone/furien/secret_item_get.mp3", // 5
	"bz_furien_mod/join.mp3" // 6
};

new const Knives[ ][ ] = 
{
	"models/bluezone/furien/update/v_furien_new.mdl", //0
	"models/bluezone/furien/update/v_antifurien_new.mdl", //1
	"models/bluezone/furien/update/v_axe_new.mdl", //2
	"models/bluezone/furien/update/v_assasin.mdl", //3
	"models/bluezone/furien/update/v_bloody.mdl", //4
	"models/bluezone/furien/update/v_usarmy.mdl", //5
	"models/bluezone/furien/update/v_ice.mdl", //6
	"models/bluezone/furien/update/v_silver_new.mdl", //7
	"models/bluezone/furien/update/v_sk.mdl", //8
	"models/bluezone/furien/update/v_dragon.mdl", //9
	"models/bluezone/furien/update/v_crow.mdl", //10
	"models/bluezone/furien/p_axe_new.mdl", //11
	"models/bluezone/furien/p_assasin.mdl", //12
	"models/bluezone/furien/p_bloody.mdl", //13
	"models/bluezone/furien/p_sk.mdl",//14
	"models/bluezone/furien/update/p_dragon.mdl", //15
	"models/bluezone/furien/update/p_crow.mdl", //16
	"models/bluezone/furien/v_neon.mdl", //17
	"models/bluezone/furien/p_furien.mdl", // 18
	"models/bluezone/furien/p_antifurien.mdl" // 19
};

new const WepMod[ ][ ] = 
{
	"models/bluezone/furien/v_ump45_bzup.mdl", //0
	"models/bluezone/furien/v_m3_bzup.mdl", //1
	"models/bluezone/furien/v_awp_bzup.mdl", //2
	"models/bluezone/furien/v_mp5_bzup.mdl", //3
	"models/bluezone/furien/v_ak47_bzup.mdl", //4
	"models/bluezone/furien/v_m4a1_bzup.mdl", //5
	"models/bluezone/furien/v_m249_bzup.mdl", //6
	"models/bluezone/furien/v_glock18_bzup.mdl", //7
	"models/bluezone/furien/v_usp_bzup.mdl", //8
	"models/bluezone/furien/v_fiveseven_bzup.mdl", //9
	"models/bluezone/furien/v_deagle_bzup.mdl", //10
	"models/bluezone/furien/v_elite_bzup.mdl", //11
	"models/bluezone/furien/v_famas_bzup.mdl", //12
	"models/bluezone/furien/update/v_c4.mdl", //13
	"models/bluezone/furien/v_he.mdl", //14
	"models/bluezone/furien/w_he.mdl", //15
	"models/bluezone/furien/v_slow.mdl", //16
	"models/bluezone/furien/w_fl.mdl", //17
	"models/bluezone/furien/v_tele.mdl", //18
	"models/bluezone/furien/w_tele.mdl" //19
};

new const g_szroundstartTT[ ][ ] = 
{
	"bz_furien_mod/tt/tt1.wav",
	"bz_furien_mod/tt/tt2.wav",
	"bz_furien_mod/tt/tt3.wav",
	"bz_furien_mod/tt/tt4.wav",
	"bz_furien_mod/tt/tt5.wav",
	"bz_furien_mod/tt/tt6.wav",
	"bz_furien_mod/tt/tt7.wav",
	"bz_furien_mod/tt/tt8.wav",
	"bz_furien_mod/tt/tt9.wav",
	"bz_furien_mod/tt/tt10.wav",
	"bz_furien_mod/tt/tt11.wav",
	"bz_furien_mod/tt/tt12.wav"
};

new const g_szroundstartCT[ ][ ] = 
{
	"bz_furien_mod/ct/ct1.wav",
	"bz_furien_mod/ct/ct2.wav",
	"bz_furien_mod/ct/ct3.wav",
	"bz_furien_mod/ct/ct4.wav",
	"bz_furien_mod/ct/ct5.wav",
	"bz_furien_mod/ct/ct6.wav",
	"bz_furien_mod/ct/ct7.wav",
	"bz_furien_mod/ct/ct8.wav",
	"bz_furien_mod/ct/ct9.wav",
	"bz_furien_mod/ct/ct10.wav",
	"bz_furien_mod/ct/ct11.wav",
	"bz_furien_mod/ct/ct12.wav"
};

new const g_szTer_Sounds[ ][ ] = 
{
	"bz_furien_mod/round_sound1.mp3",
	"bz_furien_mod/round_sound2.mp3",
	"bz_furien_mod/round_sound3.mp3",
	"bz_furien_mod/round_sound4.mp3",
	"bz_furien_mod/round_sound6.mp3",
	"bz_furien_mod/round_sound7.mp3",
	"bz_furien_mod/round_sound8.mp3",
	"bz_furien_mod/round_sound9.mp3",
	"bz_furien_mod/round_sound10.mp3",
	"bz_furien_mod/round_sound11.mp3",
	"bz_furien_mod/round_sound12.mp3",
	"bz_furien_mod/round_sound13.mp3",
	"bz_furien_mod/round_sound14.mp3",
	"bz_furien_mod/round_sound15.mp3",
	"bz_furien_mod/roundsound16.mp3",
	"bz_furien_mod/round_sound16.mp3",
	"bz_furien_mod/round_sound17.mp3",
	"bz_furien_mod/round_sound18.mp3",
	"bz_furien_mod/round_sound19.mp3",
	"bz_furien_mod/round_sound20.mp3",
	"bz_furien_mod/round_sound21.mp3",
	"bz_furien_mod/round_sound22.mp3",
	"bz_furien_mod/round_sound23.mp3",
	"bz_furien_mod/round_sound24.mp3",
	"bz_furien_mod/round_sound25.mp3",
	"bz_furien_mod/round_sound26.mp3",
	"bz_furien_mod/round_sound27.mp3"
};

new const g_szCt_Sounds[ ][ ] = 
{	
	"bz_furien_mod/round_sound1.mp3",
	"bz_furien_mod/round_sound2.mp3",
	"bz_furien_mod/round_sound3.mp3",
	"bz_furien_mod/round_sound4.mp3",
	"bz_furien_mod/round_sound6.mp3",
	"bz_furien_mod/round_sound7.mp3",
	"bz_furien_mod/round_sound8.mp3",
	"bz_furien_mod/round_sound9.mp3",
	"bz_furien_mod/round_sound10.mp3",
	"bz_furien_mod/round_sound11.mp3",
	"bz_furien_mod/round_sound12.mp3",
	"bz_furien_mod/round_sound13.mp3",
	"bz_furien_mod/round_sound14.mp3",
	"bz_furien_mod/round_sound15.mp3",
	"bz_furien_mod/roundsound16.mp3",
	"bz_furien_mod/round_sound16.mp3",
	"bz_furien_mod/round_sound17.mp3",
	"bz_furien_mod/round_sound18.mp3",
	"bz_furien_mod/round_sound19.mp3",
	"bz_furien_mod/round_sound20.mp3",
	"bz_furien_mod/round_sound21.mp3",
	"bz_furien_mod/round_sound22.mp3",
	"bz_furien_mod/round_sound23.mp3",
	"bz_furien_mod/round_sound24.mp3",
	"bz_furien_mod/round_sound25.mp3",
	"bz_furien_mod/round_sound26.mp3",
	"bz_furien_mod/round_sound27.mp3"
};

new const g_szStartSounds[ ][ ] =
{
	
	"bz_furien_mod/start_sound.mp3",
	"bz_furien_mod/start_sound2.mp3"
	
};

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
};

new const Kills_Sounds[ ][ ] = 
{
	"bluezone/furien/kill1.wav",//0 
	"bluezone/furien/doublekill.wav",//1
	"bluezone/furien/triplekill.wav",//2
	"bluezone/furien/multikill.wav",//3
	"bluezone/furien/monsterkill_new.wav",//4
	"bluezone/furien/megakill.wav",//5
	"bluezone/furien/excellent.wav",//6
	"bluezone/furien/gotit.wav",//7
	"bluezone/furien/headshot.wav",//8
	"bluezone/furien/crazy.wav"//9
};

new const SKSounds[ ][ ] = { "bluezone/furien/knife_deploy1_super.wav", "bluezone/furien/knife_hit1_super.wav", "bluezone/furien/knife_hit1_super.wav",
	"bluezone/furien/knife_hit1_super.wav", "bluezone/furien/knife_hit1_super.wav", "bluezone/furien/knife_hitwall1_super.wav",
	"bluezone/furien/knife_slash1_super.wav", "bluezone/furien/knife_slash2_super.wav", "bluezone/furien/knife_stab_super.wav"
};

new const AxeSounds[ ][ ] = { "bluezone/furien/knife_deploy1_axe.wav", "bluezone/furien/knife_hit1_axe.wav", "bluezone/furien/knife_hit2_axe.wav",
	"bluezone/furien/knife_hit1_axe.wav", "bluezone/furien/knife_hit1_axe.wav", "bluezone/furien/knife_hitwall1_axe.wav",
	"bluezone/furien/knife_slash_axe.wav", "bluezone/furien/knife_slash_axe.wav", "bluezone/furien/knife_stab_axe.wav"
};

new const AsaSounds[ ][ ] = { "bluezone/furien/knife_deploy1_combat.wav", "bluezone/furien/knife_hit1_combat.wav", "bluezone/furien/knife_hit2_combat.wav",
	"bluezone/furien/knife_hit3_combat.wav", "bluezone/furien/knife_hit4_combat.wav", "bluezone/furien/knife_hitwall1_combat.wav",
	"bluezone/furien/knife_slash_combat.wav", "bluezone/furien/knife_slash2_combat.wav", "bluezone/furien/knife_stab_combat.wav"
};

new const BloodSounds[ ][ ] = { "bluezone/furien/knife_deploy1_blood.wav", "bluezone/furien/knife_hit1_blood.wav", "bluezone/furien/knife_hit2_blood.wav",
	"bluezone/furien/knife_hit1_blood.wav", "bluezone/furien/knife_hit1_blood.wav", "bluezone/furien/knife_hitwall1_blood.wav",
	"bluezone/furien/knife_slash_blood.wav", "bluezone/furien/knife_slash_blood.wav", "bluezone/furien/knife_stab_blood.wav"
};

new const USSounds[ ][ ] = { "bluezone/furien/knife_deploy1_us.wav", "bluezone/furien/knife_hit1_us.wav", "bluezone/furien/knife_hit2_us.wav",
	"bluezone/furien/knife_hit1_us.wav", "bluezone/furien/knife_hit1_us.wav", "bluezone/furien/knife_hitwall1_us.wav",
	"bluezone/furien/knife_slash_us.wav", "bluezone/furien/knife_slash_us.wav", "bluezone/furien/knife_stab_us.wav"
};

new const IceSounds[ ][ ] = { "bluezone/furien/knife_deploy1_ice.wav", "bluezone/furien/knife_hit1_ice.wav", "bluezone/furien/knife_hit2_ice.wav",
	"bluezone/furien/knife_hit1_ice.wav", "bluezone/furien/knife_hit1_ice.wav", "bluezone/furien/knife_hitwall1_ice.wav",
	"bluezone/furien/knife_slash_ice.wav", "bluezone/furien/knife_slash_ice.wav", "bluezone/furien/knife_stab_ice.wav"
};

new const DraSounds[ ][ ] = { "bluezone/furien/knife_deploy1_dragon.wav", "bluezone/furien/knife_hit1_dragon.wav", "bluezone/furien/knife_hit2_dragon.wav",
	"bluezone/furien/knife_hit1_dragon.wav", "bluezone/furien/knife_hit2_dragon.wav", "bluezone/furien/knife_hitwall1_dragon.wav",
	"bluezone/furien/knife_slash_dragon.wav", "bluezone/furien/knife_slash_dragon.wav", "bluezone/furien/knife_stab_dragon.wav"
};

new const CrowSounds[ ][ ] = { "bluezone/furien/knife_deploy1_axe.wav", "bluezone/furien/knife_hit1_crow.wav", "bluezone/furien/knife_hit2_crow.wav",
	"bluezone/furien/knife_hit1_crow.wav", "bluezone/furien/knife_hit2_crow.wav", "bluezone/furien/knife_hitwall1_axe.wav",
	"bluezone/furien/knife_slash_crow.wav", "bluezone/furien/knife_slash_crow.wav", "bluezone/furien/knife_stab_crow.wav"
};


new userknife[ 33 ];
new g_shopDefault[ 33 ];
new g_shopAxe[ 33 ];
new g_shopAssasin[ 33 ];
new g_shopBloody[ 33 ];
new g_shopCrowBar[ 33 ];
new g_shopArmy[ 33 ];
new g_shopIce[ 33 ];
new g_shopUlti[ 33 ];
new g_shopDragon[ 33 ];
new g_shopNeon[ 33 ];

new peniaze[ 33 ];

new player_model[ 33 ][ 32 ];
new bool:g_model[ 33 ];

new radar[ 33 ];

new g_shopRadar[ 33 ];
new g_shopDefuse[ 33 ];
new g_shopZivoty[ 33 ];
new g_shopRychlost[ 33 ];
new g_shopZasobnik[ 33 ];
new g_shopSlowGrenade[ 33 ];
new g_shopHeGrenade[ 33 ];
new g_shopSuperKnife[ 33 ];
new g_shopWallHang[ 33 ];
new g_shopKnifeMoney[ 33 ];
new g_shopTeleport[ 33 ];
new g_shopxD[ 33 ];
new furien_speed;

new g_iLaserSprite, g_MaxClients;

new funkolo;
new zbrane[ 33 ];
new nesmrt[ 33 ];
new superknife[ 33 ];

new bool:g_nastavenieModely[ 33 ];

new Hud[ 3 ];
new g_iInvisFactor = 1;

new bool:g_bActived_DoubleJump[ 33 ]; 
new bool:g_bActived_NoDamage[ 33 ]; 
new g_bActived_Epicmoney[ 33 ]; 
new g_bActived_Regen[ 33 ];
new bool:g_bActived_Laser[ 33 ]; 
new g_bActived_BunnyHop[ 33 ];
new g_bActived_Immobilize[ 33 ];
new g_bActived_Respawn[ 33 ];
new g_bActived_Nesmrtelnost[ 33 ];

const Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame;

new g_nVault;
new bool:freezetime = true;

new g_iIdPlayer[ 33 ];
new bool:g_bSendPoints;

new g_iPrevCurWeapon[ 33 ];

new SyncHudObj, SyncHudObj1, SyncHudObj2, SyncHudObj3, SyncHudObj4, SyncHudObj5;
new bool:g_showrecieved;
new g_enabled;

new g_Menu[ 33 ];
new g_RoundSounds[ 33 ];
new gSlashing[ 33 ];
new bool:g_bIsConnected[ 33 ];

new jumps[ 33 ];
new bool:BoughtWallHang[ 33 ];
new bool:IsUserHanged[ 33 ];
new Float:g_fVecMins[ 33 ][ 3 ];
new Float:g_fVecMaxs[ 33 ][ 3 ];
new Float:g_fVecOrigin[ 33 ][ 3 ];

new bool:StartSound[ 33 ];
new bool:pohlad[ 33 ];

new g_c4timer, pointnum, g_msgFade;
new bool:b_planted = false;

new vysledok = 0;
new prebieha_otazka = 0;

new g_LastWinner[ 32 ];
new g_startpack[ 33 ];

new g_bMJ[ 33 ], g_bND[ 33 ], g_bCO[ 33 ], g_bBH[ 33 ], g_bDS[ 33 ], g_bRE[ 33 ], g_bREG[ 33 ], g_bLaser[ 33 ], g_MyKillCount[ 33 ], g_MySpecialKill[ 33 ],
maxplayers, g_Killsounds[ 33 ];

#define UPGRADES_KEYS (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)

/* Cista Reklama */
public Reklama( id )
{
	if( g_reklama[ id ] )
	{
		switch( random( 3 ) )
		{
			case 0:
			{	
				ChatColor( 0, "!gNovinka! Nove Epic Menu s super vyhodami!!t /furien" );
				set_task( 50.0, "Reklama", id + TASK_REKLAMA );
			}
			case 1: 
			{	
				ChatColor( 0, "!gPozor! Zbrane zdarma su !tvelmi slabe!g oproti inym zbraniam!" );
				set_task( 50.0, "Reklama", id + TASK_REKLAMA );
			}
			case 2: 
			{	
				ChatColor( 0, "!gNavstiv nas web !twww.gamesites.cz!g kde najdes mnoho informacii!" );
				set_task( 50.0, "Reklama", id + TASK_REKLAMA );
			}	
			case 3: 
			{	
				ChatColor( 0, "!g[Gamesites.cz]!y Herne menu otvoris stlacenim klavesnice !gM" );
				set_task( 50.0, "Reklama", id + TASK_REKLAMA );
			}
		}
	}
	return PLUGIN_HANDLED;
}
/* Register vsetkych nativov mimo pluginu */
public plugin_natives()
{
	register_native( "is_user_anti", "native_is_user_neon", 1 );
	register_native( "is_fun_round", "native_is_fun_round", 1 );
}

public native_is_user_neon( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error( AMX_ERR_NATIVE, "[ Furien ] Invalidny Neon Knife -> (%d)", id );
		return -1;
	}
	
	return g_shopNeon[ id ];
}
/* Vsetky precachnute servery a potrebne veci */
public plugin_precache( )
{
	new i;
	
	for( i = 0; i < sizeof WepMod ; i++ )
		precache_model( WepMod[ i ] );
	for( i = 0; i < sizeof funkolonew ; i++ )
		precache_sound( funkolonew[ i ] );
	for( i = 0; i < sizeof Knives ; i++ )
		precache_model( Knives[ i ] );
	for( i = 0; i < sizeof OtherSounds ; i++ )
		precache_sound( OtherSounds[ i ] );
	for( i = 0; i < sizeof SKSounds ; i++ )
		precache_sound( SKSounds[ i ] );
	for( i = 0; i < sizeof AxeSounds ; i++ )
		precache_sound( AxeSounds[ i ] );
	for( i = 0; i < sizeof AsaSounds ; i++ )
		precache_sound( AsaSounds[ i ] );
	for( i = 0; i < sizeof BloodSounds ; i++ )
		precache_sound( BloodSounds[ i ] );
	for( i = 0; i < sizeof USSounds ; i++ )
		precache_sound( USSounds[ i ] );
	for( i = 0; i < sizeof IceSounds ; i++ )
		precache_sound( IceSounds[ i ] );
	for( i = 0; i < sizeof DraSounds ; i++ )
		precache_sound( DraSounds[ i ] );
	for( i = 0; i < sizeof CrowSounds ; i++ )
		precache_sound( CrowSounds[ i ] );
	for( i = 0; i < sizeof g_szroundstartCT ; i++ )
		precache_sound( g_szroundstartCT[ i ] );
	for( i = 0; i < sizeof g_szroundstartTT ; i++ )
		precache_sound( g_szroundstartTT[ i ] );
	for( i = 0; i < sizeof g_szTer_Sounds ; i++ )
		precache_sound2( g_szTer_Sounds[ i ] );
	for( i = 0; i < sizeof g_szCt_Sounds ; i++ )
		precache_sound2( g_szCt_Sounds[ i ] );
	for( i = 0; i < sizeof g_szStartSounds ; i++ )
		precache_sound2( g_szStartSounds[ i ] );
	for( i = 0; i < sizeof Kills_Sounds ; i++ )
		precache_sound2( Kills_Sounds[ i ] );
		
	precache_sound( zvuk_skacko );
	precache_sound( zvuk_radar );
	precache_sound( zvuk_speed );
	precache_sound( zvuk_heal );
	precache_sound( zvuk_menu );
	precache_sound( zvuk_knife );
	precache_sound( zvuk_premenu );
	
	precache_model( fura_vipTT );
	precache_model( fura_vipCT );
	precache_model( fura_vipCTT );
		
	g_iLaserSprite = precache_model( g_szLaserSprite );
}

public plugin_init( ) 
{
	new i;
	register_dictionary( "furien_mod.txt" );
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	RegisterHam( Ham_Spawn, "player", "spawn_hraca", 1 );
	RegisterHam( Ham_TakeDamage,"player", "Hrac_Damage",0 );
	RegisterHam( Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post",0 );
	RegisterHam( Ham_Touch, "func_wall", "World_Touch" );
	RegisterHam( Ham_Touch, "func_breakable", "World_Touch" );
	RegisterHam( Ham_Touch, "worldspawn", "World_Touch" );
	RegisterHam( Ham_Touch, "weapon_shield", "OnCShield_Touch" );
	RegisterHam( Ham_Player_Jump, "player", "Player_Jump" );
	RegisterHam( Ham_Killed,"player","Hrac_Zomrel",1 );
	RegisterHam( Ham_Player_PostThink, "player", "ham_Player_PostThink_Post", 1 );
	RegisterHam( Ham_Player_PreThink, "player", "ham_Player_PreThink_Pre", 0 );
	RegisterHam( Ham_Use, "func_tank", "ham_UseStationary_Post", 1 );
	RegisterHam( Ham_Use, "func_tankmortar", "ham_UseStationary_Post", 1 );
	RegisterHam( Ham_Use, "func_tankrocket", "ham_UseStationary_Post", 1 );
	RegisterHam( Ham_Use, "func_tanklaser", "ham_UseStationary_Post", 1 );
	RegisterHam( Ham_Player_ResetMaxSpeed,"player","playerResetMaxSpeed",1 );
	RegisterHam( Ham_Weapon_PrimaryAttack, "weapon_c4", "ham_PrimaryAttack_C4" );
	
	g_pcvar_unhpcost = register_cvar( "fur_unimi_cost_hp", 		"10" );
	g_pcvar_unapcost = register_cvar( "fur_unimimu_cost_dmgred", 	"45" );
	g_pcvar_undmcost = register_cvar( "fur_unimi_cost_posko", 	"50" );
	
	g_pcvar_unhpmult = register_cvar( "fur_unimi_mult_hp", "10" );
	g_pcvar_unapmult = register_cvar( "fur_unimimu_mult_ap", "45" );
	g_pcvar_undmmult = register_cvar( "fur_unimi_mult_dm", "50" );
	
	register_menucmd( register_menuid( "UpgradesMenuMain"), UPGRADES_KEYS, "upgrades_menu_pressed" );
	
	register_clcmd( "say /furien","herne_menu" );
	register_clcmd( "say furien","herne_menu" );
	register_clcmd( "chooseteam" , "herne_menu" );
	register_clcmd( "Ciastka", "command_SendPoints" );
	register_clcmd( "say /rs","reset_score" );
	register_clcmd( "say /starter", "starter_pack" );
	register_clcmd( "say /vip", "vip_vyhody" );
	register_clcmd( "say", "handle_say" );
	register_clcmd( "say_team", "handle_say" );
	
	for( i = 1; i < sizeof WEAPONENTNAMES; i++ )
		if( WEAPONENTNAMES[ i ][ 0 ] ) RegisterHam( Ham_Item_Deploy, WEAPONENTNAMES[ i ], "ham_Item_Deploy_Post", 1 );
	
	new szIP[ 20 ];
	get_user_ip( 0, szIP, charsmax(szIP), false );
	
	if( !equal( szIP, "185.91.116.22:27032" ) )
	{
		set_fail_state( "[Anti-Cheat] Tento Plugin je sukromny!" );
	}
	
	register_touch( "weaponbox", "player", "weaponbox_touch" );
	register_touch( "armoury_entity", "player", "weaponbox_touch" );
	register_touch( "weapon_shield", "player", "weaponbox_touch" );
	
	furien_speed = register_cvar( "amx_furien_speed", "700.0" );
	
	register_event( "Damage", "on_damage", "b", "2!0", "3=0", "4!0" );
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	register_event( "SendAudio", "event_SendAudio_Ter", "a", "2&%!MRAD_terwin" );
	register_event( "SendAudio", "event_SendAudio_Ct", "a", "2&%!MRAD_ctwin" );
	register_event( "CurWeapon" , "fw_EvCurWeapon" , "be" , "1=1" );
	register_event( "Money", "Event_Money", "b" );
	register_event( "HLTV", "on_new_round", "a", "1=0", "2=0" );
	register_event( "HLTV", "ev_RoundStart", "a", "1=0", "2=0" );
	
	register_logevent( "Round_Start", 2, "1=Round_Start" );
	register_logevent( "zaciatok_kola", 2, "1=Round_Start" );
	register_logevent( "Round_End", 2, "1=Round_End" );
	register_logevent( "newRound", 2, "1=Round_Start" );
	register_logevent( "endRound", 2, "1=Round_End" );
	register_logevent( "endRound", 2, "1&Restart_Round_" );
	
	register_forward( FM_CmdStart, "forward_Start" );
	register_forward( FM_PlayerPreThink,"Fwd_PlayerPreThink" );
	register_forward( FM_PlayerPreThink, "FM_PreThink" );
	register_forward( FM_PlayerPreThink, "bomb_drop" );
	register_forward( FM_EmitSound,"EmitSound" );
	register_forward( FM_AddToFullPack, "AddToFullPack", 1 );
	register_forward( FM_GetGameDescription, "ForwardGameDescription" );
	register_forward( FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged" );
	register_forward( FM_SetClientKeyValue, "fw_SetClientKeyValue" );
	register_forward( FM_SetModel,"nastav_glow" );
	
	pointnum = get_cvar_pointer( "mp_c4timer" );
 
	register_think( "check_speed", "Set_Furiens_Visibility" );
	
	new iEnt;
	iEnt = create_entity( "info_target" );
	entity_set_string( iEnt, EV_SZ_classname, "check_speed" );
	entity_set_float( iEnt, EV_FL_nextthink, get_gametime() + 0.1 );
	for ( new i = 1; i<= maxplayers ;i++ ) radar[ i ] = false;
	
	maxplayers = get_maxplayers( );
	g_msgFade = get_user_msgid( "ScreenFade" );
	
	SyncHudObj = CreateHudSyncObj( );
	SyncHudObj1 = CreateHudSyncObj( );
	SyncHudObj2 = CreateHudSyncObj( );
	SyncHudObj3 = CreateHudSyncObj( );
	SyncHudObj4 = CreateHudSyncObj( );
	SyncHudObj5 = CreateHudSyncObj( );
	g_msg_event = CreateHudSyncObj( );
	
	CvarDistance = register_cvar( "fur_anticamp_distance", "250.0" );
	
	for( i = 0; i < 3; i++ )
		Hud[ i ] = CreateHudSyncObj( i+ 1 );
		
	set_task( 150.0, "Priklad", 0, _, _, "b" );
}
public native_is_fun_round( id )
{
	if ( !is_user_valid( id ) )
	{
		log_error(AMX_ERR_NATIVE, "[Furien v0.6] Invalid Fun Round (%d)", id)
		return -1;
	}
	
	return funkolo;
}

public playerResetMaxSpeed( id )
{
	if( get_user_team( id ) == 1 )
	{
		static Float:maxspeed;
		pev( id,pev_maxspeed,maxspeed );
		
		if( maxspeed != 1.0 )
		{
			set_pev( id,pev_maxspeed,maxspeed + get_pcvar_float( furien_speed ) ); 
		}
	}
}

public bomb_planted( id )
{
	b_planted = true;
	g_c4timer = get_pcvar_num( pointnum );
	dispTime( )
	set_task( 1.0, "dispTime", 652450, "", 0, "b" );
	
	if( !is_user_bot( id ) )
	{
		if( players >= 5 )
		{
			peniaze[ id ] += 30;
			cs_set_user_money( id,peniaze[ id ] );
			ChatColor( id,"!gZa aktivovanie bomby si ziskal +30$!" );
			ScreenFade( id, 1.0, 200, 0, 0, 100 );
			set_hudmessage( 255, 127, 0, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1 );
			show_hudmessage( 0, "Bomba bola polozena!" );
		} else {
			ChatColor( id,"!gNa ziskanie bonusu musia byt na servery 5 hraci!" );
		}
	}
}

public bomb_defused( id )
{
	if( b_planted )
	{
		remove_task( 652450 );
		b_planted = false;
	}
	if( !is_user_bot( id ) )
	{
		if( players >= 5 )
		{
			peniaze[ id ] += 30;
			cs_set_user_money( id,peniaze[ id ] );
			
			ScreenFade( id, 1.0, 0, 0, 200, 100 );
			
			ChatColor( id,"!gZa zneskodnenie bomby si ziskal +30$!");
		} else {
			ChatColor( id,"!gNa ziskanie bonusu musia byt na servery 5 hraci!" );
		}
	}
}

public reset_score( id )
{
	set_user_frags( id,0 );
	cs_set_user_deaths( id,0 );
	ChatColor( id,"%L", LANG_PLAYER, "RESET_SCORE" );
}

public Round_Start( )
{
	
	new iPlayers[ 32 ], iPlayer, iNum;
	new iPenize, iBestPlayer, iBestPenez;
	
	get_players( iPlayers, iNum, "ah" );
	iBestPlayer = 0;
	iBestPenez = 0;
	
	for( new i = 0; i < iNum; i++ )
	{
		iPlayer = iPlayers[ i ];
		iPenize = peniaze[ iPlayer ];
		
		if( iPenize > iBestPenez )
		{
			iBestPlayer = iPlayer;
			iBestPenez = iPenize;
		}
		else if( iPenize == iBestPenez )
		{
			iBestPlayer = 0;
		}
	}
	
	if( iBestPlayer )
	{
		new szName[ 32 ];
		get_user_name( iBestPlayer, szName, charsmax( szName ) );
		
		ChatColor( 0, "%s !tNajviac peniazi ma !g%s%s!t - !g%d$.!tChces mat viac, napis !g/vip", prefix, ( get_user_flags( iBestPlayer ) & EVIP ) ? "!g" : "!t", szName, iBestPenez );
	}
}

public Set_Furiens_Visibility( iEnt )
{
	entity_set_float( iEnt, EV_FL_nextthink, get_gametime() + 0.1 );
	
	new iPlayers[ 32 ], iNum, Float:fVecVelocity[ 3 ], iSpeed;
	get_players( iPlayers, iNum, "a" );
	new iPlayer;
	
	for( new i; i < iNum; i++ )
	{
			iPlayer = iPlayers[ i ];
			if( get_user_team( iPlayer ) == 1 )
			{
				if( get_user_weapon( iPlayer ) == CSW_KNIFE || get_user_weapon( iPlayer ) == CSW_C4 || get_user_weapon( iPlayer ) == CSW_HEGRENADE || get_user_weapon( iPlayer ) == CSW_SMOKEGRENADE || get_user_weapon( iPlayer ) == CSW_SCOUT )
				{
					if( g_round_aktualne == 1 )
					{
						entity_get_vector( iPlayer, EV_VEC_velocity, fVecVelocity );
						iSpeed = floatround( vector_length( fVecVelocity ) );
						if( iSpeed < g_iInvisFactor*255 )
						{
								set_user_rendering( iPlayer, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, iSpeed/g_iInvisFactor )
								client_cmd( iPlayer, "cl_forwardspeed 700" );
								client_cmd( iPlayer, "cl_backspeed 700" );
								client_cmd( iPlayer, "cl_sidespeed 700" );
						}
						else
						{
							set_user_rendering( iPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
							client_cmd( iPlayer, "cl_forwardspeed 700" );
							client_cmd( iPlayer, "cl_backspeed 700" );
							client_cmd( iPlayer, "cl_sidespeed 700" );
						}
					}
					else
					{
						set_user_rendering( iPlayer, kRenderFxNone, 0, 0, 0, kRenderNormal, 0 );
						client_cmd( iPlayer, "cl_forwardspeed 700" );
						client_cmd( iPlayer, "cl_backspeed 700" );
						client_cmd( iPlayer, "cl_sidespeed 700" );
					}
				}
			}
	}
	return PLUGIN_CONTINUE;
}
public on_new_round( )
{
	g_enabled = 1;
	g_showrecieved = true;
}

public on_damage( id )
{	
	if( get_user_team( id ) & 2 )
	{
		static attacker; attacker = get_user_attacker( id );
		static damage; damage = read_data( 2 );
		if( g_showrecieved )
		{			
			set_hudmessage( 255, 42, 42, -1.0, 0.55, 0, 1.0, 1.0 ); 
			ShowSyncHudMsg( id, SyncHudObj, "%i^n", damage );	
		}
		if( is_user_connected( attacker ) )
		{
			switch( g_enabled )
			{
				case 1: 
				{
					set_hudmessage( 255, 42, 42, -1.0, 0.55, 0, 1.0, 1.0 ); 
					ShowSyncHudMsg( attacker, SyncHudObj, "%i^n", damage );			
				}
				case 2: 
				{
					if( fm_is_ent_visible( attacker,id ) )
					{
						set_hudmessage( 255, 42, 42, -1.0, 0.55, 0, 1.0, 1.0 ); 
						ShowSyncHudMsg( attacker, SyncHudObj, "%i^n", damage );			
					}
				}
			}
		}
	}
}

public Event_Money( id )
{
	if( is_user_connected( id ) )
		cs_set_user_money( id, peniaze[ id ] );
}

public Round_End( )
{
	freezetime = true;
	g_round_aktualne = 0;
	new Players[ 32 ], playerCount, id;
	get_players( Players, playerCount, "a" );
	
	
	for( new i = 0; i < playerCount; i++ )
	{
		id = Players[ i ];
		superknife[ id ] = false;
	}
}

public ForwardGameDescription( )
{
	forward_return( FMV_STRING, VERSION );
	
	return FMRES_SUPERCEDE;
} 

stock fm_cs_get_weapon_ent_owner( ent )
{
	if(pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase( ent, m_pPlayer, OFFSET_LINUX_WEAPONS );
}

public ham_Item_Deploy_Post( weapon_ent )
{
	static id; id = fm_cs_get_weapon_ent_owner( weapon_ent );
	
	if( !pev_valid( id ) )
		return;
		
	static weaponid; weaponid = cs_get_weapon_id( weapon_ent );
	
	replace_weapon_models( id, weaponid );
}


public newRound( )
{
	freezetime = true;
	
	g_c4timer = -1;
	remove_task( 652450);
	
	b_planted = false;
}

public zaciatok_kola( )    
{
	freezetime = false;
	g_round_aktualne = 1;
	//ChatColor( 0, "%s !yHrac %s%s !yma najviac penazi (!t%d!y), chces mat viac, napis !t/vip", prefix, ( get_user_flags( iBestPlayer ) & EVIP ) ? "!g" : "!t", szName, iBestPenez );
		
	for( new id=0;id<=32;id++ )
	{
		if( !is_user_alive( id ) )
			continue;
		
		g_pocetodohranych[ id ]++;
		
		if( get_user_team( id ) & 1 )
		{
			client_cmd( id, "spk %s", g_szroundstartTT[random_num( 0,charsmax( g_szroundstartTT ) )] );
		}
		if( get_user_team( id ) & 2 )
		{
			client_cmd( id, "spk %s", g_szroundstartCT[random_num( 0,charsmax( g_szroundstartCT ) )] );
		}
		if( StartSound[ id ] )
		{
			StarterSound( id );
			ChatColor( id, "!gPockaj pokial sa ti nacte pesnicka!" );
		}
		else if( !StartSound[ id ] )
		{
			client_cmd( id, "mp3 stop" );
		}
	}
}

public case_open( id )
{
	switch( random( 300 ) )
	{
		case 1: case_someone_get( id );
	}
	return PLUGIN_HANDLED;
}

public ham_UseStationary_Post( entity, caller, activator, use_type )
{
	if( use_type == USE_STOPPED && is_user_connected( caller ) )
		replace_weapon_models( caller, get_user_weapon( caller ) );
}

public weaponbox_touch( touched, toucher )
{
	if( !is_user_alive( toucher ) || get_user_team( toucher ) == 2 )
		return PLUGIN_CONTINUE;
	    
	static model[ 32 ];
	pev( touched, pev_model, model, 31 );
	if( equal( model, "models/w_backpack.mdl" ) )
		return PLUGIN_CONTINUE;
	return PLUGIN_HANDLED;
} 

public get_vip_models( id )
{
	if( cs_get_user_team( id ) & CS_TEAM_T && get_user_flags( id ) & EVIP )
	{
		copy( player_model[ id ], sizeof( player_model ), "bz_fura" );
			
		new currentmodel[ 32 ];
		fm_get_user_model( id, currentmodel, sizeof currentmodel - 1 );
				
		if( !equal( currentmodel, player_model[ id ] ) )
		{
			fm_set_user_model( id, player_model[ id ] )
		}
	}
	else if( cs_get_user_team( id ) & CS_TEAM_CT && get_user_flags( id ) & EVIP )
	{
		copy( player_model[ id ], sizeof( player_model ), "gign_fur" );
			
		new currentmodel[ 32 ];
		fm_get_user_model( id, currentmodel, sizeof currentmodel - 1 );
				
		if( !equal( currentmodel, player_model[ id ] ) )
		{
			fm_set_user_model( id, player_model[ id ] )
			//fm_set_user_model( id, "models/player/bz_antisas/bz_antisasT.mdl" )
		}
	}
}

/* Spawn , Client Addons */
public spawn_hraca( id )
{
	if ( !is_user_alive( id ) ) return;
	
	if( get_user_flags( id ) & EVIP && get_user_team( id ) == 1 )
	{
		BoughtWallHang[ id ] = true;
		} else {
		BoughtWallHang[ id ] = false;
	}
	static weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
	
	if( pev_valid( weapon_ent ) )
		replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
		
	IsUserHanged[ id ] = false;
	new ix;
	if( g_startpack[ id ] == 0 )
		for( ix = 0; ix < 5; ix++ )
			ChatColor( id, "!gNEMAS ODOMKNUTY STARTER PACK! NAPIS DO CHATU !t/starter" );
	
	g_shopDefuse[ id ] = false;
	g_shopRadar[ id ] = false;
	g_shopRychlost[ id ] = false;
	g_shopZasobnik[ id ] = false;
	g_shopZivoty[ id ] = false;
	g_shopSlowGrenade[ id ] = false;
	g_shopHeGrenade[ id ] = false;
	g_shopSuperKnife[ id ] = false;
	g_shopWallHang[ id ] = false;
	g_shopKnifeMoney[ id ] = false;
	g_shopTeleport[ id ] = false;
	g_bActived_Nesmrtelnost[ id ] = false;
	
	g_truhla_openning[ id ] = false;
	g_truhla_percenta[ id ] = 0;
	
	superknife[ id ] = false;
	
	radar[ id ] = false;
	
	g_MyKillCount[ id ] = 0;
	g_MySpecialKill[ id ] = 0;
	
	remove_task( id + TASK_MULTIHUD );
	remove_task( id + TASK_MULTIHUDNEW );
	remove_task( id + TASK_REGEN );
	
	zbrane[ id ] = 0;
	nesmrt[ id ] = 0;
	g_isalive[ id ] = true;
	
	strip_user_weapons( id );
	cs_set_user_money( id,peniaze[ id ] );
	
	ham_strip_weapon( id, "weapon_knife" );
	give_item( id,"weapon_knife" );
	
	herne_menu( id );
	
	if( g_bREG[ id ] == 1 )
	{
		if( g_bActived_Regen[ id ] == 1 )
		{
			set_task( 1.0, "regeneracia", id + TASK_REGEN, _, _, "b" );
		}
	}
	cs_set_user_armor( id, 0, CS_ARMOR_KEVLAR );
	 // Tu sa nam automaticky vzdy nastavi maximalny pocet HP hraca odzaciatku aby to kazde kolo prepocitalo znova a znova.
	g_maxHP[ id ] = 100;
	set_pev( id, pev_health, float( min( pev( id, pev_health ) + g_unHPLevel[ id ] * 1, g_max_health ) ) );
	g_maxHP[ id ] = 100 + g_unHPLevel[ id ] * 1;
	if( get_user_team( id ) == 1 )
	{
		if( is_user_alive( id ) )
		{
			if( get_user_flags( id ) & EVIP )
			{
				g_maxHP[ id ] += 20;
				set_pev( id, pev_health, float( min( pev( id, pev_health ) + 20, g_max_health ) ) );
				give_item( id,"weapon_smokegrenade" );
			}
			if( g_shopAssasin[ id ] )
			{
				g_maxHP[ id ] += 10;
				set_pev( id, pev_health, float( min( pev( id, pev_health ) + 10, g_max_health ) ) );			
			}
			if( g_shopAxe[ id ] )
			{
				g_maxHP[ id ] += 3;
				set_pev( id, pev_health, float( min( pev( id, pev_health ) + 3, g_max_health ) ) );
				set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 3, g_max_defense ) ) );
			}
			if( g_shopCrowBar[ id ] )
			{
				set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 25, g_max_defense ) ) );
			}
			if( g_shopBloody[ id ] )
			{
				set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 10, g_max_defense ) ) );
			}
			if( g_shopArmy[ id ] )
			{
				g_maxHP[ id ] += 20;
				set_pev( id, pev_health, float( min( pev( id, pev_health ) + 20, g_max_health ) ) );
			}
			set_user_gravity( id,0.4 );
			g_bActived_Laser[ id ] = false;
			g_bActived_BunnyHop[ id ] = false;
			g_bActived_Immobilize[ id ]  = false;
			set_user_footsteps( id, 1 );
			give_item( id, "weapon_hegrenade" );
			if( !userknife[ id ] || userknife[ id ] == 10 || userknife[ id ] == 2 )
			{
				userknife[ id ] = 1;
			}
		}
	}
	if( get_user_team( id ) == 2 )
	{		
		if( is_user_alive( id ) )
		{
			give_item( id,"weapon_flashbang" );
			if( is_user_bot( id ) )
			{
				new random = random_num( 1, 3 );
				if( random == 1 )
				{
					give_item( id,"weapon_ump45" );
					cs_set_user_bpammo( id, CSW_UMP45, 250 );
				}
				if( random == 2 )
				{
					give_item( id,"weapon_m3" );
					cs_set_user_bpammo( id, CSW_M3, 250 );
				}
				if( random == 3 )
				{
					give_item( id,"weapon_awp" );
					cs_set_user_bpammo( id, CSW_AWP, 250 );
				}
			}
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + g_unAPLevel[ id ] * 4, g_max_defense ) ) );
			g_bActived_NoDamage[ id ] = false;
			g_bActived_Epicmoney[ id ] = false;
			set_user_footsteps( id, 0 );
			set_user_rendering( id , kRenderFxNone, 0, 0, 0, kRenderNormal, 16 );
				
			if( !userknife[ id ] || userknife[ id ] == 10 || userknife[ id ] == 1 )
			{
				userknife[ id ] = 2
			}
		}
	}
	set_task( 3.5, "get_vip_models", id );
}
public ham_Player_TakeDamage_Post( iVictim, iInfictor, iAttacker, Float:fDamage, iDmgBits )
{	
	if( !IsUserValidConnected( iVictim ) || !IsUserValidConnected( iAttacker ) || iVictim == iAttacker )
		return HAM_IGNORED;
	
	new iWeapon = get_user_weapon( iAttacker );
	switch( cs_get_user_team( iAttacker ) )
	{
		case CS_TEAM_T:
		{
			if( g_shopKnifeMoney[ iAttacker ] == 1 && cs_get_user_team( iVictim ) == CS_TEAM_CT )
			{
				if( get_user_weapon( iAttacker ) == CSW_KNIFE )
				{
					peniaze[ iAttacker ] += 10;
					cs_set_user_money( iAttacker, peniaze[ iAttacker ] );
				}
			}
			if( g_shopUlti[ iAttacker ] && cs_get_user_team( iVictim ) == CS_TEAM_CT )
			{
					peniaze[ iAttacker ] += 3;
					cs_set_user_money( iAttacker, peniaze[ iAttacker ] );
			}
		}
		case CS_TEAM_CT:
		{
			if( g_shopZasobnik[ iAttacker ] && cs_get_user_team( iVictim ) == CS_TEAM_T )
			{
					exp[ iAttacker ] += 5;
			}
			
			if( g_bActived_NoDamage[ iVictim ] )
			{
				if( IsPrimaryWeapon( iWeapon ) || IsSecondaryWeapon( iWeapon ) )
				{
					new random = random_num( 1,3 );
					if( random == 2 )
					{
						client_print( iVictim, print_center, "Absolute Defense ta ochranil!" );
						SetHamParamFloat( 4, fDamage - fDamage );
					}
				}
			}		
			if( g_bActived_Immobilize[ iAttacker ] == 1 )
			{
				if( iDmgBits & DMG_BULLET || iDmgBits & DMG_NADE || iDmgBits & DMG_SLASH )
				{
					new random = random_num( 1,20 );
					if( random == 1 )
					{
						set_pev( iVictim, pev_flags, pev( iVictim, pev_flags ) | FL_FROZEN );
						set_task( 0.5, "remove_frozen", iVictim );
					}
				}
			}
		}
	}
	return HAM_IGNORED;
}

public fwdPrimaryAttackKnifePre( ent )
{
	new id = get_pdata_cbase( ent, 41, 4 );
	
	if( !IsUserValidConnected( id ) )
		return HAM_IGNORED;
	
	if( g_bActived_Epicmoney[ id ] && CsTeams:cs_get_user_team( id ) == CS_TEAM_T )
		gSlashing[ id ] = true;
	
	return HAM_IGNORED;
}

public ham_Player_PreThink_Pre( id )
{
	if( is_user_alive( id ) && g_bActived_Laser[ id ] )
	{
		if( cs_get_user_team( id ) == CS_TEAM_CT )
		{
			static iTarget, iBody, iRed, iGreen, iBlue, iWeapon;
			
			get_user_aiming( id, iTarget, iBody );
			
			iWeapon = get_user_weapon( id );
			
			if( IsPrimaryWeapon( iWeapon ) || IsSecondaryWeapon( iWeapon ) )
			{
				if( is_user_alive( iTarget ) && cs_get_user_team( iTarget ) == CS_TEAM_T )
				{
					iRed = 103;
					iGreen = 3;
					iBlue = 3;
				} else {
					iRed = 170;
					iGreen = 255;
					iBlue = 42;
				}
				
				static iOrigin[ 3 ];
				get_user_origin( id, iOrigin, 3 );
				
				message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
				write_byte( TE_BEAMENTPOINT );
				write_short( id | 0x1000 );
				write_coord( iOrigin[ 0 ] );
				write_coord( iOrigin[ 1 ] );
				write_coord( iOrigin[ 2 ] );
				write_short( g_iLaserSprite );
				write_byte( 1 );
				write_byte( 10 );
				write_byte( 1 );
				write_byte( 5 );
				write_byte( 0 );
				write_byte( iRed );
				write_byte( iGreen );
				write_byte( iBlue );
				write_byte( 150 );
				write_byte( 25 );
				message_end( );
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public ham_Player_PostThink_Post( id )
{
	if( g_bActived_BunnyHop[ id ] && CsTeams:cs_get_user_team( id ) == CS_TEAM_CT )
	{
		if( pev( id, pev_button) & IN_JUMP )
		{
			new flags = pev( id, pev_flags );
			
			if( flags & FL_WATERJUMP )
				return HAM_IGNORED;
			if( pev( id, pev_waterlevel ) >= 2 )
				return HAM_IGNORED;
			if(!(flags & FL_ONGROUND))
				return HAM_IGNORED;
			
			static Float:velocity[ 3 ];
			pev( id, pev_velocity, velocity );
			velocity[ 2 ] += 250.0;
			set_pev( id, pev_velocity, velocity );
			
			set_pev( id, pev_gaitsequence, 6 );
		}
	}
	
	return HAM_IGNORED;
}

public client_connect( id )
{
	players += 1;
	
	remove_task( id+672 );

	set_task( 3.0, "HUD", id+672 );
	set_task( 1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b" );
	//set_task( 30.0, "Reklama", id + TASK_REKLAMA );
	
	client_cmd( id, "cl_forwardspeed 700" );
	client_cmd( id, "cl_backspeed 700" );
	client_cmd( id, "cl_sidespeed 700" );
}

public client_disconnect( id )
{
	players -= 1;
	
	userknife[ id ] = 0;
	
	g_isalive[ id ] = false
	
	radar[ id ] = false;
	
	g_maxHP[ id ] = 0;
	
	g_truhla_openning[ id ] = false;
	g_truhla_percenta[ id ] = 0;
	
	g_bIsConnected[ id ] = false;
	
	SaveData( id );
	
	if( task_exists( TASK_GODMODE + id ) )
		remove_task( TASK_GODMODE + id );
	if( task_exists( id + TASK_REGEN ) )
		remove_task( id + TASK_REGEN );
	if( task_exists( id + TASK_REKLAMA ) )
		remove_task( id + TASK_REKLAMA );
	if( task_exists( id + TASK_EVENT ) )
		remove_task( id + TASK_EVENT );
		
	ClearUserInCamera( id );
	CheckForward( ); 
}

public client_putinserver( id )
{
	ClearUserInCamera( id ); 
	
	LoadData( id );
	
	set_task( 1.0, "Task_Show_Power", id + TASK_EVENT, _, _, "b" );
	
	g_bIsConnected[ id ] = true;
	
	g_shopDefault[ id ] = false;
	g_shopAxe[ id ] = false;
	g_shopAssasin[ id ] = false;
	g_shopBloody[ id ] = false;
	g_shopCrowBar[ id ] = false;
	g_shopArmy[ id ] = false;
	g_shopIce[ id ] = false;
	g_shopUlti[ id ] = false;
	g_shopDragon[ id ] = false;
	g_shopNeon[ id ] = false;
	
	set_lights( "m" );
	
	g_shopDefuse[ id ] = false;
	g_shopRadar[ id ] = false;
	g_shopRychlost[ id ] = false;
	g_shopZasobnik[ id ] = false;
	g_shopZivoty[ id ] = false;
	g_shopSlowGrenade[ id ] = false;
	g_shopHeGrenade[ id ] = false;
	g_shopSuperKnife[ id ] = false;
	g_shopWallHang[ id ] = false;
	g_shopKnifeMoney[ id ] = false;
	g_shopTeleport[ id ] = false;
	
	g_maxHP[ id ] = 0;
	
	g_bActived_DoubleJump[ id ] = false;
	g_bActived_NoDamage[ id ] = false;
	g_bActived_Epicmoney[ id ] = false;
	g_bActived_Regen[ id ] = false;
	g_bActived_Laser[ id ] = false;
	g_bActived_BunnyHop[ id ] = false;
	g_bActived_Immobilize[ id ] = false;
	g_bActived_Respawn[ id ] = false;
	
	superknife[ id ] = false;
	
	g_Menu[ id ] = 1;
	g_nastavenieModely[ id ] = true;
	g_Killsounds[ id ] = true;
	g_RoundSounds[ id ] = true;
	StartSound[ id ] = false;
	g_reklama[ id ] = true;
	g_priklady[ id ] = true;

	gSlashing[ id ] = false;
	
	pohlad[ id ] = false;
	
	radar[ id ] = false;

}

public HUD( id )
{	
	new item[ 64 ];
	id -= 672;
	set_task( 0.5, "HUD", id+672 );	
	{
	if( is_user_connected( id ) && !is_user_alive( id ) )
	{
		new target = entity_get_int( id, EV_INT_iuser2 );
		
		if( target == 0 )
			return PLUGIN_CONTINUE;
			
		if( g_bActived_Regen[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 1 ] );
			}
			else if( g_bActived_NoDamage[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 2 ] );
			}
			else if( g_bActived_DoubleJump[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 3 ] );
			}
			else if( g_bActived_Nesmrtelnost[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 4 ] );
			}
			else if( g_bActived_BunnyHop[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 5 ] );
			}
			else if( g_bActived_Immobilize[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 6 ] );
			}
			else if( g_bActived_Epicmoney[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 7 ] );
			}
			else if( g_bActived_Laser[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 8 ] );
			}
			else if( !g_bActived_Regen[ target ] || !g_bActived_NoDamage[ target ] || !g_bActived_DoubleJump[ target ] || !g_bActived_Nesmrtelnost[ target ] || !g_bActived_BunnyHop[ target ] || !g_bActived_Immobilize[ target ] || !g_bActived_Epicmoney[ target ]  || !g_bActived_Laser[ target ] )
			{
				formatex( item, charsmax( item ), Itemy[ 0 ] );
			}
		
		//set_hudmessage(204, 41, 32, 0.0, 0.0, 0, 6.0, 12.0)
		set_hudmessage( 204, 41, 32, -1.0, 1.0, _, _, 0.1, 0.1, 0.1, -1 ); // set_hudmessage( 185, 61, 51, 0.30, 0.98, 0, 0.0, 0.3, 0.0, 0.0 );
		ShowSyncHudMsg( id, SyncHudObj1, "%d $ | %d EXP | Specialny Item: %s", cs_get_user_money( target ) , exp[ target ], item );
		return PLUGIN_CONTINUE;
		}
	return PLUGIN_CONTINUE;
	}
}

SaveData( id ) 
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "fur-%s-points", szAuthid )
	formatex( szVaultData, 511, "%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i", peniaze[ id ], g_bND[ id ], g_bCO[ id ], g_bREG[ id ], g_bMJ[ id ], g_bLaser[ id ], g_bBH[ id ], g_bDS[ id ], g_bRE[ id ], exp[ id ], g_unHPLevel[ id ], g_unAPLevel[ id ], g_unDMLevel[ id ], g_pocetodohranych[ id ], g_startpack[ id ], g_pocetprikladov[ id ] );
	nvault_set( g_nVault, szVaultKey, szVaultData );
}

LoadData( id ) 
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "fur-%s-points", szAuthid );
	formatex( szVaultData, 511, "%i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i", peniaze[ id ], g_bND[ id ], g_bCO[ id ], g_bREG[ id ], g_bMJ[ id ], g_bLaser[ id ], g_bBH[ id ], g_bDS[ id ], g_bRE[ id ], exp[ id ], g_unHPLevel[ id ], g_unAPLevel[ id ], g_unDMLevel[ id ], g_pocetodohranych[ id ],g_startpack[ id ], g_pocetprikladov[ id ] );
	
	nvault_get( g_nVault, szVaultKey, szVaultData, 511 );
	
	new money[ 32 ], nd[ 32 ], co[ 32 ], rg[ 32 ], mj[ 32 ], laser[ 32 ], bh[ 32 ], ds[ 32 ], re[ 32 ], xp[ 32 ], hp[ 32 ], ap[ 32 ], dmg[ 32 ], od[ 32 ], st[ 32 ], xd[ 32 ]
	
	parse( szVaultData, money, 31, nd, 31, co, 31, rg, 31, mj, 31, laser, 31, bh, 31, ds, 31, re, 31, xp, 31, hp, 31, ap, 31, dmg, 31 , od, 31, st, 31, xd, 31 );
	
	peniaze[ id ] 	= str_to_num( money );
	g_bND[ id ] 	= str_to_num( nd );
	g_bCO[ id ] 	= str_to_num( co );
	g_bREG[ id ] 	= str_to_num( rg );
	g_bMJ[ id ] 	= str_to_num( mj );
	g_bLaser[ id ] 	= str_to_num( laser );
	g_bBH[ id ] 	= str_to_num( bh );
	g_bDS[ id ] 	= str_to_num( ds );
	g_bRE[ id ] 	= str_to_num( re );
	exp[ id ]	= str_to_num( xp );
	g_unHPLevel[ id ] = str_to_num( hp );
	g_unAPLevel[ id ] = str_to_num( ap );
	g_unDMLevel[ id ] = str_to_num( dmg );
	g_pocetodohranych[ id ] = str_to_num( od );
	g_startpack[ id ] = str_to_num( st );
	g_pocetprikladov[ id ] = str_to_num( xd );
}
/* Stocks */

stock precache_sound2( sound[ ] )
{
	static linedata[ 64 ];
	formatex( linedata, charsmax( linedata ), "sound/%s", sound );
	
	if( equal( sound[strlen( sound )-4 ],".mp3" ) )
		precache_generic( linedata )
	else
		precache_sound( sound )
}

stock fm_cs_get_current_weapon_ent( id )
{
	if( pev_valid( id ) != PDATA_SAFE )
		return -1;
	
	return get_pdata_cbase( id, m_pActiveItem, XTRA_OFS_PLAYER );
}


stock ham_strip_weapon( id,weapon[ ] )
{
	if( !equal(weapon,"weapon_",7 ) ) return 0;
	
	new wId = get_weaponid( weapon );
	if( !wId ) return 0;
	
	new wEnt;
	while( ( wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon ) ) && pev( wEnt,pev_owner ) != id ) {}
	if( !wEnt ) return 0;
	
	if( get_user_weapon( id ) == wId ) ExecuteHamB( Ham_Weapon_RetireWeapon,wEnt );
	
	if( !ExecuteHamB( Ham_RemovePlayerItem,id,wEnt ) ) return 0;
	ExecuteHamB( Ham_Item_Kill,wEnt );
	
	set_pev( id,pev_weapons,pev(id,pev_weapons ) & ~( 1<<wId ) );
	
	return 1;
}

stock ChatColor(const id, const input[], any:...) 
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
	new i = plr ? plr : get_maxplayers();
	if( !i )
	{
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

public typ_noza( id )
	return g_noze[ id ][ NAJVIAC_NOZOV ];

public daj_noz( id, knife )
{
	g_noze[ id ][ NAJVIAC_NOZOV ] = knife;
	
	new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
	
	if( pev_valid( weapon_ent ) )
		replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
}
		
/* Herne menu , Obchod , Itemy , Knife */

public herne_menu( id )
{
	if( !g_truhla_openning[ id ] )
	{
		if( is_user_alive( id ) )
		{
			if( get_user_team( id ) == 2 )
			{
				new hm = menu_create( "Anti-Furien Menu \w( \r/furien \w)","ct_menu_handle" );
				menu_additem( hm, Herne_Menu[ 0 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 6 ] );
				menu_display( id,hm );
			}
			
			if( get_user_team( id ) == 1 )
			{
				new hm = menu_create( "Furien Menu \w( \r/furien \w)","tt_menu_handle" );
				menu_additem( hm, Herne_Menu[ 1 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 6 ] );
				menu_display( id,hm );
			}
			
			if( get_user_flags( id ) & VIP && get_user_team( id ) == 1 )
			{
				new hm = menu_create( "Furien Menu \w( \r/furien \w)","vip_t_menu_handle" );
				menu_additem( hm, Herne_Menu[ 1 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 7 ] );
				menu_display( id,hm );
			}
			
			if( get_user_flags( id ) & VIP && get_user_team( id ) == 2 )
			{
				new hm = menu_create( "Anti-Furien Menu \w( \r/furien \w)","vip_ct_menu_handle" );
				menu_additem( hm, Herne_Menu[ 0 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 7 ] );
				menu_display( id,hm )
			}
			
			if( get_user_flags( id ) & EVIP && get_user_team( id ) == 1 )
			{
				new hm = menu_create( "Furien Menu \w( \r/furien \w)","evip_t_menu_handle" );
				menu_additem( hm, Herne_Menu[ 1 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_display( id,hm );
			}
			
			if( get_user_flags( id ) & EVIP && get_user_team( id ) == 2 )
			{
				new hm = menu_create( "Furien Menu \w( \r/furien \w)","evip_ct_menu_handle" );
				menu_additem( hm, Herne_Menu[ 0 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_display( id,hm );
			}
			
			if( get_user_flags( id ) & ADMIN_BAN && get_user_team( id ) == 2 )
			{
				new hm = menu_create( "Anti-Furien Menu \w( \r/furien \w)","admin_ct_menu_handle" );
				menu_additem( hm, Herne_Menu[ 0 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 8 ] );
				menu_display( id,hm );
			}
			
			if( get_user_flags( id ) & ADMIN_BAN && get_user_team( id ) == 1 )
			{
				new hm = menu_create( "Furien Menu \w( \r/furien \w)","admin_t_menu_handle" );
				menu_additem( hm, Herne_Menu[ 1 ] );
				menu_additem( hm, Herne_Menu[ 2 ] );
				menu_additem( hm, Herne_Menu[ 3 ] );				
				menu_additem( hm, Herne_Menu[ 4 ] );
				menu_additem( hm, Herne_Menu[ 5 ] );
				menu_additem( hm, Herne_Menu[ 8 ] );
				menu_display( id,hm );
			}
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		else
		{
			ChatColor( id,"%L", LANG_PLAYER, "MENU_CAN_NOT_OPEN" );
		}
	}
	else
	{
		ChatColor( id, "Nemozes aktualne otvorit menu!" );
	}
}

public ct_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			vybrat_zbran( id );
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		case 1:
		{
			obchod_ct( id );
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		case 2:
		{
			itemy_ct( id );
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		case 3:
		{
			epic_menu( id );
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		case 4:
		{
			ostatne_menu( id );
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id, Odkazy[ 1 ] );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public vip_vyhody( id )
{
	show_motd( id, Odkazy[ 1 ] );
}

public tt_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_te( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_te( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id,Odkazy[ 1 ] );
			herne_menu( id )
		}
	}
	return PLUGIN_HANDLED;
}

public vip_t_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_te( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_te( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id,Odkazy[ 1 ] );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public vip_ct_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			vybrat_zbran( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_ct( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_ct( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id,Odkazy[ 1 ] );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public evip_ct_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			vybrat_zbran( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_ct( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_ct( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public evip_t_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_te( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_te( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public admin_ct_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			vybrat_zbran( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_ct( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_ct( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			AdminMenu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public admin_t_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			obchod_te( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			itemy_te( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			epic_menu( id );
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ostatne_menu( id );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			AdminMenu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public obchod_ct( id )
{
	if( funkolo == 0 )
	{
		new szText[ 555 char ], szText1[ 555 char ], szText2[ 555 char ], szText3[ 555 char ];
		formatex( szText, charsmax( szText ), "\y[ExtraVIP]\w Speed^t^t^t^t^t^t^t^t \r90$ \d( \y%i \d/ \r4 \d)^n\dVelmi rychle behanie", g_limitspeed[ id ] );
		formatex( szText2, charsmax( szText2 ), "\y[ExtraVIP]\w Speed^t^t^t^t^t^t^t^t \y[kupene] \d( \y%i \d/ \r4 \d)^n\dVelmi rychle behanie", g_limitspeed[ id ] );
		formatex( szText1, charsmax( szText1 ), "\y[ExtraVIP]\w Speed^t^t^t^t^t^t^t^t \r90$ \d( \r4 \d/ \r4 \d)^n\dVelmi rychle behanie" );
		formatex( szText3, charsmax( szText3 ), "\y[ExtraVIP]\w Speed^t^t^t^t^t^t^t^t \y[kupene] \d( \r4 \d/ \r4 \d)^n\dVelmi rychle behanie" );
		
		new oc = menu_create( "\yObchod \w( \r/furien \w)","obchod_ct_handle" );
		if( !g_shopDefuse[ id ] )
		menu_additem( oc, "Defuse ^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r5$^n\dRychle zneskodnenie bomby", "1", 0 );
		else
		menu_additem( oc, "Defuse ^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\y[kupene]^n\dRychle zneskodnenie bomby", "1", 0 );
		if( !g_shopSlowGrenade[ id ] )
		menu_additem( oc, "Freeze Grenade^t^t^t^t^t^t^t^t^t \r20$^n\dGranat ktory spomaly furiena", "2", 0 );
		else
		menu_additem( oc, "Freeze Grenade^t^t^t^t^t^t^t^t^t \y[kupene]^n\dGranat ktory spomaly furiena", "2", 0 );
		if( !g_shopZivoty[ id ] )
		menu_additem( oc, "+50 % HP^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t \r65$^n\dDoplnenie zivota o 50 %", "3", 0 );
		else
		menu_additem( oc, "+50 % HP^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t \y[kupene]^n\dDoplnenie zivota o 50 %", "3", 0 );
		if( !g_shopZasobnik[ id ] )
		menu_additem( oc, "\y[VIP]\w EXP Skill^t^t^t^t^t^t^t^t^t^t^t \r85$^n\dZa kazdy hit nepriatela ziskas +5 EXP", "4", VIP );
		else
		menu_additem( oc, "\y[VIP]\w EXP Skill^t^t^t^t^t^t^t^t^t^t^t \y[kupene]^n\dZa kazdy hit nepriatela ziskas +5 EXP", "4", VIP );
		if( g_limitspeed[ id ] == 4 )
			if( !g_shopRychlost[ id ] )
				menu_additem( oc, szText1, "5", EVIP );
			else
				menu_additem( oc, szText3, "5", EVIP );
		else
			if( !g_shopRychlost[ id ] )
				menu_additem( oc, szText, "5", EVIP );
			else
				menu_additem( oc, szText2, "5", EVIP );
		if( !g_shopRadar[ id ] )
		menu_additem( oc, "\y[ExtraVIP]\w Kevlar Vest^t^t^t^t\r25$^n\dDoplnenie defensu o  75%", "6", EVIP );
		else
		menu_additem( oc, "\y[ExtraVIP]\w Kevlar Vest^t^t^t^t\y[kupene]^n\dDoplnenie defensu o 75%", "6", EVIP );
		menu_additem( oc, "Zpet", "7" );
		menu_display( id,oc );
	}
	else
	{
		ChatColor( id, "%L", LANG_PLAYER, "FUN_ROUND_ACTIVE" );
	}
}

public obchod_ct_handle( id,menu,item )
{	
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item )
	{
		case 0:
		{
			if( !g_shopDefuse[ id ] )
			{
				if( peniaze[ id ] >= 5 )
				{
					peniaze[ id ] -= 5;
					g_shopDefuse[ id ] = true;
					cs_set_user_money( id,peniaze[ id ] );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					give_item( id,"item_thighpack" );
					obchod_ct( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_ct( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}
		case 1:
		{
			if( !g_shopSlowGrenade[ id ] )
			{
				if( peniaze[ id ] >= 20 )
				{
					peniaze[ id ] -= 20;
					g_shopSlowGrenade[ id ] = true;
					cs_set_user_money( id,peniaze[ id ] );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					give_item( id,"weapon_flashbang" );
					obchod_ct( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_ct( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}
		case 2:
		{
			if( !g_shopZivoty[ id ] )
			{
				if( peniaze[ id ] >= 85 )
				{
					peniaze[ id ] -= 85;
					g_shopZivoty[ id ] = true;
					cs_set_user_money( id,peniaze[ id ] );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					set_pev( id, pev_health, float( min( pev( id, pev_health ) + 50, g_maxHP[ id ] ) ) );
					client_cmd( id, "spk bz_furien_mod/menu_heal.wav" );
					obchod_ct( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_ct( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}	
		case 3:
		{
			if( !g_shopZasobnik[ id ] )
			{
				if( peniaze[ id ] >= 85 )
				{
					peniaze[ id ] -= 85;
					ChatColor( id, "!g[EXP Skill]!y Ak HITnes nepriatela ziskas !t+5 EXP" );
					g_shopZasobnik[ id ] = true;
					cs_set_user_money( id,peniaze[ id ] );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					obchod_ct( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_ct( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}
		case 4:
		{
			if( !g_shopRychlost[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 90 )
					{
						if( g_limitspeed[ id ] == 4 )
						{
							obchod_ct( id );
							client_cmd( id, "spk valve/sound/buttons/button11" );
							ChatColor( id, "!gMozes iba 4 krat zakupit Speed za jednu mapu!" );
						} 
						else 
						{
							set_user_rendering( id, kRenderFxGlowShell, 54, 102, 246, kRenderNormal, 10 );
							g_limitspeed[ id ] += 1;
							g_shopRychlost[ id ] = true;
							new Float:MaxSpeed = 500.0;
							peniaze[ id ] -= 90;
							cs_set_user_money( id,peniaze[ id ] );
							set_user_maxspeed( id,Float:MaxSpeed );
							ScreenFade( id, 0.5, 255, 255, 255, 100 );
							client_cmd( id, "spk bz_furien_mod/speed.wav" );
							ChatColor( id,"!yZiskal si Speed! Si skoro rychly ako furien." );
							obchod_ct( id );
						}
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						obchod_ct( id );
					}
				}
				else
				{
					obchod_ct( id );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
				}
			} else {
					
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}	
		case 5:
		{
			if( !g_shopRadar[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 25 )
					{
						set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 75, g_max_defense ) ) );
						g_shopRadar[ id ] = true;
						peniaze[ id ] -= 25;
						cs_set_user_money( id,peniaze[ id ] );
						ScreenFade( id, 0.5, 255, 255, 255, 100 );
						obchod_ct( id );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						obchod_ct( id );
					}
				}
				else
				{
					obchod_ct( id );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_ct( id );
			}
		}
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
} 

public obchod_te( id )
{
	if( funkolo == 0 )
	{
		new szText[ 555 char ], szText1[ 555 char ], szText2[ 555 char ], szText3[ 555 char ];
		formatex( szText, charsmax( szText ), "Super Knife^t^t^t^t^t^t^t^t^t^t^t  \r90$ \d( \y%i \d/ \r5 \d)^n\dZabijanie na jednu ranu", g_limitsuperknife[ id ] );
		formatex( szText2, charsmax( szText2 ), "Super Knife^t^t^t^t^t^t^t^t^t^t^t  \y[kupene] \d( \y%i \d/ \r5 \d)^n\dZabijanie na jednu ranu", g_limitsuperknife[ id ] );
		formatex( szText1, charsmax( szText1 ), "Super Knife^t^t^t^t^t^t^t^t^t^t^t  \r90$ \d( \r5 \d/ \r5 \d)^n\dZabijanie na jednu ranu" );
		formatex( szText3, charsmax( szText3 ), "Super Knife^t^t^t^t^t^t^t^t^t^t^t  \y[kupene] \d( \r5 \d/ \r5 \d)^n\dZabijanie na jednu ranu" );
		new ot = menu_create( "\yObchod \w( \r/furien \w)","obchod_te_handle" );
		if( !g_shopHeGrenade[ id ] )
			menu_additem( ot, "HE Grenade^t^t^t^t^t^t^t^t^t^t^t^t \r30$^n\dExplodujici granat", "1", 0 );
		else
			menu_additem( ot, "HE Grenade^t^t^t^t^t^t^t^t^t^t^t^t \y[kupene]^n\dExplodujici granat", "1", 0 );
		if( !g_shopZivoty[ id ] )
			menu_additem( ot, "+50 % HP^t^t^t^t^t^t^t^t^t^t^t^t^t^t \r65$^n\dDoplnenie zivota o 50 %", "2", 0 );
		else
			menu_additem( ot, "+50 % HP^t^t^t^t^t^t^t^t^t^t^t^t^t^t \y[kupene]^n\dDoplnenie zivota o 50 %", "2", 0 );
		if( g_limitsuperknife[ id ] == 5 )
			if( !g_shopSuperKnife[ id ] )
				menu_additem( ot, szText1, "3", 0 );
			else
				menu_additem( ot, szText3, "3", 0 );
		else
			if( !g_shopSuperKnife[ id ] )
				menu_additem( ot, szText, "3", 0 );
			else
				menu_additem( ot, szText2, "3", 0 );
		if( !g_shopWallHang[ id ] )
			menu_additem( ot, "\y[VIP] \wTruhla^t^t^t^t^t^t^t^t^t^t^t  \r35$^n\dOtvor a uvidis co v nej je!", "4", VIP );
		else
			menu_additem( ot, "\y[VIP] \wTruhla^t^t^t^t^t^t^t^t^t^t^t  \y[kupene]^n\dOtvor a uvidis co v nej je!", "4", VIP );
		if( !g_shopKnifeMoney[ id ] )
			menu_additem( ot, "\y[ExtraVIP] \wMoney Knife^t  \r80$^n\dZa kazdy zasah do nepriatela dostanes +10$", "5", EVIP );
		else
			menu_additem( ot, "\y[ExtraVIP] \wMoney Knife^t  \y[kupene]^n\dZa kazdy zasah do nepriatela dostanes +10$", "5", EVIP );
		if( !g_shopTeleport[ id ] )
			menu_additem( ot, "\y[ExtraVIP] \wTeleport^t^t^t^t^t   \r5$^n\dTeleportovaci granat", "6", EVIP );
		else
			menu_additem( ot, "\y[ExtraVIP] \wTeleport^t^t^t^t^t   \y[kupene]^n\dTeleportovaci granat", "6", EVIP );
		menu_additem( ot, "Zpet", "7" );
		menu_display( id,ot );
	}	
	else
	{
		ChatColor( id,"Pocas Fun Kola nemozes otvorit herne menu!" );
	}
}

public obchod_te_handle( id,menu,item )
{	
	
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0: // HE Grenade
		{
			if( !g_shopHeGrenade[ id ] )
			{
				if( peniaze[ id ] >= 30 )
				{
					g_shopHeGrenade[ id ] = true;
					peniaze[ id ] -= 30;
					cs_set_user_money( id,peniaze[ id ] );
					give_item( id,"weapon_hegrenade" );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					obchod_te( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_te( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}
		case 1: // +50 HP
		{
			if( !g_shopZivoty[ id ] )
			{
				if( peniaze[ id ] >= 65 )
				{
					g_shopZivoty[ id ] = true;
					peniaze[ id ] -= 65;
					cs_set_user_money( id,peniaze[ id ] );
					set_pev( id, pev_health, float( min( pev( id, pev_health ) + 50, g_maxHP[ id ] ) ) );
					client_cmd( id, "spk bz_furien_mod/menu_heal.wav" );
					ScreenFade( id, 0.5, 255, 255, 255, 100 );
					obchod_te( id );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_te( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}	
		case 2: // Super Knife
		{
			if( !g_shopSuperKnife[ id ] )
			{
				if( peniaze[ id ] >= 90 )
				{
					if( g_limitsuperknife[ id ] == 5 )
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id, "!gMozes iba 5 krat kupit Super Knife za jednu mapu!" );
						obchod_te( id );
					} else {
						g_shopSuperKnife[ id ] = true;
						peniaze[ id ] -= 90;
						superknife[ id ] = true;	
						g_limitsuperknife[ id ] += 1;
						daj_noz( id, KNIFE_SUPER );		
						cs_set_user_money( id,peniaze[ id ] );
						ScreenFade( id, 0.5, 255, 255, 255, 100 );
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						client_cmd( id, "spk bz_furien_mod/skacko.wav" );
						ChatColor( id, "%L", LANG_PLAYER, "SHOP_GET_SUPER_KNIFE" );
						obchod_te( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					obchod_te( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}	
		case 3:
		{
			if( !g_shopWallHang[ id ] )
			{
				if( get_user_flags( id ) & VIP )
				{
					if( peniaze[ id ] >= 35 )
					{
						otvaranie_truhly( id );
						g_shopWallHang[ id ] = true;
						peniaze[ id ] -= 35;
						cs_set_user_money( id,peniaze[ id ] );
						ScreenFade( id, 0.5, 255, 255, 255, 100 );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						obchod_te( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					obchod_te( id );
					ChatColor( id,"%L", LANG_PLAYER, "NO_VIP" );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}
		case 4:
		{
			if( !g_shopKnifeMoney[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 80 )
					{
						g_shopKnifeMoney[ id ] = true;
						peniaze[ id ] -= 80;
						cs_set_user_money( id,peniaze[ id ] );
						ChatColor( id,"%L", LANG_PLAYER, "BUY_SPECIAL_GUN" );
						ScreenFade( id, 0.5, 255, 255, 255, 100 );
						obchod_te( id );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						obchod_te( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
					obchod_te( id );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}
		case 5:
		{
			if( !g_shopTeleport[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 5 )
					{
						g_shopTeleport[ id ] = true;
						peniaze[ id ] -= 5;
						cs_set_user_money( id,peniaze[ id ] );
						ChatColor( id,"%L", LANG_PLAYER, "BUY_TELEPORT" );
						give_item( id, "weapon_smokegrenade" );
						ScreenFade( id, 0.5, 255, 255, 255, 100 );
						obchod_te( id );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						obchod_te( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
				}
			} else {
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_HAVE_ITEM" );
				obchod_te( id );
			}
		}
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}


public forward_Start( id, uc_handle )
{
	if( !is_user_alive( id ) )
		return FMRES_IGNORED;
	
	new flags = pev( id, pev_flags );
	
	if( ( get_uc( uc_handle, UC_Buttons ) & IN_JUMP ) && !( flags & FL_ONGROUND ) && !( pev( id, pev_oldbuttons ) & IN_JUMP ) && jumps[ id ] )
	{
		jumps[ id ]--;
		new Float:velocity[ 3 ];
		pev( id, pev_velocity, velocity );
		velocity[ 2 ] = random_float( 265.0,285.0 );
		set_pev( id, pev_velocity, velocity );
	}
	else if( flags & FL_ONGROUND )
	{
		if( g_bActived_DoubleJump[ id ] )
		{
			jumps[ id ] = 2
			} else {
			jumps[ id ] = 1
		}
	}
	if( g_shopxD[ id ] && CsTeams:cs_get_user_team( id ) == CS_TEAM_CT )
	{
		new buttons = get_uc( uc_handle, UC_Buttons );
		new oldbuttons = pev( id, pev_oldbuttons );
		new clip, ammo, weapon = get_user_weapon( id, clip, ammo );
		
		if( g_iMaxClipAmmo[ weapon ] == -1 || !ammo )
			return FMRES_IGNORED;
			
		if( ( buttons & IN_RELOAD && !( oldbuttons & IN_RELOAD ) && !( buttons & IN_ATTACK ) ) || !clip )
		{
			cs_set_user_bpammo( id, weapon, ammo-( g_iMaxClipAmmo[ weapon ]-clip ) );
			new new_ammo = ( g_iMaxClipAmmo[ weapon ] > ammo ) ? clip+ammo : g_iMaxClipAmmo[ weapon ];
			set_user_clip( id, new_ammo );
		}
	}
	
	return FMRES_IGNORED;
}

stock set_user_clip( id, ammo )
{
	new weaponname[ 32 ], weaponid = -1, weapon = get_user_weapon( id, _, _ );
	get_weaponname( weapon, weaponname, 31 );
	while( ( weaponid = engfunc( EngFunc_FindEntityByString, weaponid, "classname", weaponname ) ) != 0 )
		if( pev( weaponid, pev_owner ) == id ) {
		set_pdata_int( weaponid, 51, ammo, 4 );
		return weaponid;
	}
	return 0;
}

replace_weapon_models( id, weaponid )
{
	if( !is_user_connected( id ) )
	return;
	
	static CsTeams:team; team = cs_get_user_team( id );
	
	if( g_nastavenieModely[ id ] == true )
	{
		switch( weaponid )
		{
			case CSW_KNIFE:
			{
				switch( team )
				{
					case CS_TEAM_T:
					{
						if( userknife[ id ] == 1 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 0 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 18 ] );
						}				
						if( userknife[ id ] == 3 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 2 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 11 ] );
							
						}		
						if( userknife[ id ] == 4 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 3 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 12 ] );
							
						}		
						if( userknife[ id ] == 5 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 4 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 14 ]);
						}		
						if( userknife[ id ] == 6 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 5 ] );
						}		
						if( userknife[ id ] == 7 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 6 ] );
						}		
						if( userknife[ id ] == 8 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 7 ] );
						}		
						if( userknife[ id ] == 11 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 9 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 15 ] );
						}
						if( userknife[ id ] == 12 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 10 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 16 ] );
						}
						if( superknife[ id ] == 1 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 8 ] );
							set_pev( id, pev_weaponmodel2, Knives[ 14 ] );
						}		
						if( userknife[ id ] == 10 ) //ZAKLADNI
						{
							set_pev( id, pev_viewmodel2, "models/v_knife.mdl" );
						}
						if( userknife[ id ] == 13 )
						{
							set_pev( id, pev_viewmodel2, Knives[ 17 ] );	
						}

					}
					case CS_TEAM_CT:
					{
						set_pev( id, pev_viewmodel2, Knives[ 1 ] );
						set_pev( id, pev_weaponmodel2, Knives[ 19 ] );
					}
				}
			}
			case CSW_UMP45:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 0 ] );
			}
			case CSW_M3:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 1 ] );
			}
			case CSW_AWP:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 2 ] );
			}
			case CSW_MP5NAVY:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 3 ] );
			}
			case CSW_AK47:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 4 ] );
			}
			case CSW_M4A1:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 5 ] );
			}
			case CSW_M249:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 6 ] );
			}
			case CSW_FAMAS:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 12 ] );
			}
			case CSW_GLOCK18:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 7 ] );
			}
			case CSW_USP:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 8 ] );
			}
			case CSW_DEAGLE:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 10 ] );
			}
			case CSW_C4:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 13 ] );
			}
			case CSW_HEGRENADE:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 14 ] );
			}
			case CSW_FLASHBANG:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 16 ] );
			}
			case CSW_SMOKEGRENADE:
			{
				switch( team )
				{
					case CS_TEAM_CT:
					{
						set_pev( id, pev_viewmodel2, WepMod[ 18 ] );
					}
					case CS_TEAM_T:
					{
						set_pev( id, pev_viewmodel2, WepMod[ 18 ] );
					}
				}
			}
		}
		} else {
		switch( weaponid )
		{
			case CSW_KNIFE:
			{
				set_pev( id, pev_viewmodel2, "models/v_knife.mdl" );
				set_pev( id, pev_weaponmodel2, "models/p_knife.mdl" );
			}
			case CSW_UMP45:
			{
				set_pev( id, pev_viewmodel2, "models/v_ump45.mdl" );
			}
			case CSW_M3:
			{
				set_pev( id, pev_viewmodel2, "models/v_m3.mdl" );
			}
			case CSW_AWP:
			{
				set_pev( id, pev_viewmodel2, "models/v_awp.mdl" );
			}
			case CSW_MP5NAVY:
			{
				set_pev( id, pev_viewmodel2, "models/v_mp5.mdl" );
			}
			case CSW_AK47:
			{
				set_pev( id, pev_viewmodel2, "models/v_ak47.mdl" );
			}
			case CSW_M4A1:
			{
				set_pev( id, pev_viewmodel2, "models/v_m4a1.mdl" );
			}
			case CSW_M249:
			{
				set_pev( id, pev_viewmodel2, "models/v_m249.mdl" );
			}
			case CSW_FAMAS:
			{
				set_pev( id, pev_viewmodel2, "models/v_famas.mdl" );
			}
			case CSW_GLOCK18:
			{
				set_pev( id, pev_viewmodel2, "models/v_glock18.mdl" );
			}
			case CSW_USP:
			{
				set_pev( id, pev_viewmodel2, "models/v_usp.mdl" );
			}
			case CSW_DEAGLE:
			{
				set_pev( id, pev_viewmodel2, "models/v_deagle.mdl" );
			}
			case CSW_C4:
			{
				set_pev( id, pev_viewmodel2, "models/v_c4.mdl" );
			}
			case CSW_HEGRENADE:
			{
				set_pev( id, pev_viewmodel2, "models/v_hegrenade.mdl" );
				set_pev( id, pev_weaponmodel2, "models/p_hegrenade.mdl" );
			}
			case CSW_FLASHBANG:
			{
				set_pev( id, pev_viewmodel2, "models/v_flashbang.mdl" );
				set_pev( id, pev_weaponmodel2, "models/p_flashbang.mdl" );
			}
			case CSW_SMOKEGRENADE:
			{
				set_pev( id, pev_viewmodel2, WepMod[ 18 ] );
			}
		}
	}
}


public vybrat_zbran( id )
{
	if( funkolo == 0 )
	{
		if( is_user_alive( id ) )
		{
			if( get_user_team( id ) == 2 )
			{
				if( zbrane[ id ] == 0 )
				{
					
					new hPrim = menu_create( "\yVyber Zbrani \w( \r/furien \w)", "vybrat_zbran_handle" );
					menu_additem( hPrim, Zbrane_Menu[ 0 ], "1", 0 );
					menu_additem( hPrim, Zbrane_Menu[ 1 ], "2", 0 );
					if( peniaze[ id ] >= 15 )
						menu_additem( hPrim, Zbrane_Menu[ 2 ], "3", 0 );
					else
						menu_additem( hPrim, "\d????????????", "3", 0 );
					if( peniaze[ id ] >= 25 )
						menu_additem( hPrim, Zbrane_Menu[ 3 ], "4", 0 );
					else
						menu_additem( hPrim, "\d????????????", "4", 0 );
					if( peniaze[ id ] >= 35 )
						menu_additem( hPrim, Zbrane_Menu[ 4 ], "5", 0 );
					else
						menu_additem( hPrim, "\d????????????", "5", 0 );
					if( peniaze[ id ] >= 35 )
						menu_additem( hPrim, Zbrane_Menu[ 5 ], "6", 0 );
					else
						menu_additem( hPrim, "\d????????????", "6", 0 );
					if( peniaze[ id ] >= 35 )
						menu_additem( hPrim, Zbrane_Menu[ 6 ], "7", VIP );
					else
						menu_additem( hPrim, "\d????????????", "7", VIP );
					if( peniaze[ id ] >= 40 )
						menu_additem( hPrim, Zbrane_Menu[ 7 ], "8", EVIP );
					else
						menu_additem( hPrim, "\d????????????", "8", EVIP );
					menu_setprop( hPrim, MPROP_PERPAGE, 0 );
					menu_display( id, hPrim, 0 );
					
				}
				else
				{
					ChatColor( id,"%L", LANG_PLAYER, "CHOOSE_WEAPON_1TIME" );		
				}
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "CHOOSE_WEAPON_CT" );
			}
		}
		else
		{
			ChatColor( id,"%L", LANG_PLAYER, "CHOOSE_WEAPON_ALIVE" );
		}
	}
	else
	{
		ChatColor( id, "%L", LANG_PLAYER, "FUN_ROUND_MENU" );
	}
	return PLUGIN_HANDLED;
}

public vybrat_zbran_handle( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iKey = str_to_num( szData );

	
	switch( iKey )
	{
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			give_item( id,"weapon_ump45" );
			cs_set_user_bpammo( id, CSW_UMP45, 250 );
			zbrane[ id ] = 1;
			pistole( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			give_item( id,"weapon_m3" );
			cs_set_user_bpammo( id, CSW_M3, 250 );
			zbrane[ id ] = 1;
			pistole( id );
		}
		case 3:
		{
			if( peniaze[ id ] >= 15 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 15;
				give_item( id,"weapon_awp" );
				cs_set_user_bpammo( id, CSW_AWP, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				vybrat_zbran( id );
			}
		}
		case 4:
		{
			if( peniaze[ id ] >= 25 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 25;
				give_item( id,"weapon_mp5navy" );
				cs_set_user_bpammo( id, CSW_MP5NAVY, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				vybrat_zbran( id );
			}
		}
		case 5:
		{
			if( peniaze[ id ] >= 35 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 35;
				give_item( id,"weapon_ak47" );
				cs_set_user_bpammo( id, CSW_AK47, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				vybrat_zbran( id )
			}
		}
		case 6:
		{
			if( peniaze[ id ] >= 35 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 35;
				give_item( id,"weapon_m4a1" );
				cs_set_user_bpammo( id, CSW_M4A1, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				vybrat_zbran( id );
			}
		}
		case 7:
		{
			if( peniaze[ id ] >= 35 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 35;
				give_item( id,"weapon_p90" );
				cs_set_user_bpammo( id, CSW_P90, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				vybrat_zbran( id );
			}
		}
		case 8:
		{
			if( peniaze[ id ] >= 40 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				peniaze[ id ] -= 40;
				give_item( id,"weapon_xm1014" );
				cs_set_user_bpammo( id, CSW_XM1014, 250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				pistole( id );
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				vybrat_zbran( id );
			}
		}
	}
	return PLUGIN_HANDLED;
}
public pistole( id )
{
	if( funkolo == 0 )
	{
		new pis = menu_create( "\yVyber Zbrani \w( \r/furien \w)","pistole_handle" );
		menu_additem( pis, Pistole_Menu[ 0 ] );
		if( peniaze[ id ] >= 5 )
			menu_additem( pis, Pistole_Menu[ 1 ] );
		else
			menu_additem( pis, "\d????????????" );
		if( peniaze[ id ] >= 5 )	
			menu_additem( pis, Pistole_Menu[ 2 ] );
		else
			menu_additem( pis, "\d????????????" );
		if( peniaze[ id ] >= 15 )
			menu_additem( pis, Pistole_Menu[ 3 ] );
		else
			menu_additem( pis, "\d????????????" );
		if( peniaze[ id ] >= 20 )
			menu_additem( pis, Pistole_Menu[ 4 ] );
		else
			menu_additem( pis, "\d????????????" );
		menu_display( id,pis );
	}
	else
	{
		ChatColor( id, "%L", LANG_PLAYER, "FUN_ROUND_MENU" );
	}
}

public pistole_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			give_item( id,"weapon_glock18" );
			cs_set_user_bpammo( id, CSW_GLOCK18,250 );
			zbrane[ id ] = 1;
			if( g_Menu[ id ] )
			{
				show_menu( id, 0, "\n", 1 )
				} else {
				herne_menu( id )
			}
		}
		case 1:
		{
			if( peniaze[ id ] >= 5 )
			{
				peniaze[ id ] -= 5;
				give_item( id,"weapon_usp" );
				cs_set_user_bpammo( id, CSW_USP,250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				if( g_Menu[ id ] )
				{
					show_menu( id, 0, "\n", 1 )
					} else {
					herne_menu( id )
				}
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				pistole( id );
			}
		}
		case 2:
		{
			if( peniaze[ id ] >= 5 )
			{
				peniaze[ id ] -= 5;
				give_item( id,"weapon_fiveseven" );
				cs_set_user_bpammo( id, CSW_FIVESEVEN,250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				if( g_Menu[ id ] )
				{
					show_menu( id, 0, "\n", 1 )
					} else {
					herne_menu( id )
				}
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				pistole( id );
			}
		}
		case 3:
		{
			if( peniaze[ id ] >= 15 )
			{
				peniaze[ id ] -= 15;
				give_item( id,"weapon_deagle" );
				cs_set_user_bpammo( id, CSW_DEAGLE,250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				if( g_Menu[ id ] )
				{
					show_menu( id, 0, "\n", 1 )
					} else {
					herne_menu( id )
				}
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				pistole( id );
			}
		}
		case 4:
		{
			if( peniaze[ id ] >= 20 )
			{
				peniaze[ id ] -= 20;
				give_item( id,"weapon_elite" );
				cs_set_user_bpammo( id, CSW_ELITE,250 );
				cs_set_user_money( id,peniaze[ id ] );
				zbrane[ id ] = 1;
				if( g_Menu[ id ] )
				{
					show_menu( id, 0, "\n", 1 )
					} else {
					herne_menu( id )
				}
			}
			else
			{
				ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );	
				pistole( id );
			}
		}
	}
	return PLUGIN_HANDLED;
}

public itemy_ct( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new hItem = menu_create( "\yItemy \w( \r/furien\w )^nSpecialne itemy zostanu ulozene i^npo odpojeni z hry!", "itemy_ct_handler" );
	if( !( g_bREG[ id ] == 1 ) )
		menu_additem( hItem, "\wRegeneracia^t^t^t^t \r22000\r$^n\d- Doplnuje +2HP kazdou sekundu", "1", 0 );
	else
		menu_additem( hItem, ( g_bActived_Regen[ id ] ) ? "\wRegeneracia^t^t^t^t \y[ON]^n\d- Doplnuje +2HP kazdou sekundu" : "\wRegeneracia^t^t^t^t \r[OFF]^n\d- Doplnuje +2HP kazdou sekundu", "1", 0 );
	if( !( g_bDS[ id ] == 1 ) )
		menu_additem( hItem, "\wDrtive strely^t^t^t^t\r10000\r$^n\d- Sanca na znehybneni Furiena", "2", 0 );
	else
		menu_additem( hItem, ( g_bActived_Immobilize[ id ] ) ? "\wDrtive strely^t^t^t^t\y[ON]^n\d- Sanca na znehybnenie Furiena" : "\wDrtive strely^t^t^t^t\r[OFF]^n\d- Sanca na znehybnenie Furiena", "2", 0 );
	if( !( g_bLaser[ id ] == 1 ) )
		menu_additem( hItem, "\wLaser^t^t^t^t^t^t^t^t^t^t \r20000\r$ \y[VIP] \d( \rBETA \d)^n\d- Rychle odhalenie furiena s laserom", "3", VIP );
	else
		menu_additem( hItem, ( g_bActived_Laser[ id ] ) ? "\wLaser^t^t^t^t^t^t^t^t^t^t \y[ON]^n\d- Rychle odhalenie furiena laserom" : "\wLaser^t^t^t^t^t^t^t^t^t^t \r[OFF]^n\d- Rychle odhalenie furiena laserom", "3", VIP );
	if( !( g_bBH[ id ] == 1 ) )
		menu_additem( hItem, "\wBunnyHop^t^t^t^t^t  \r25000\r$ \y[ExtraVIP]^n\d- Moznost skakat automaticky Bhop", "4", EVIP );
	else
		menu_additem( hItem, ( g_bActived_BunnyHop[ id ] ) ? "\wBunnyHop^t^t^t^t^t  \y[ON]^n\d- Moznost skakat automaticky Bhop" : "\wBunnyHop^t^t^t^t^t  \r[OFF]^n\d- Moznost skakat automaticky Bhop", "4", EVIP );
	if( !( g_bMJ[ id ] == 1 ) )
		menu_additem( hItem, "\wMultijump^t^t^t^t^t^t\r23000\r$ \y[ExtraVIP]^n\d- Pridava dalsi skok vo vzduchu", "5", EVIP );
	else
		menu_additem( hItem, ( g_bActived_DoubleJump[ id ] ) ? "\wMultijump^t^t^t^t^t^t\y[ON]^n\d- Pridava dalsi skok vo vzduchu" : "\wMultijump^t^t^t^t^t^t\r[OFF]^n\d- Pridava dalsi skok vo vzduchu", "5", EVIP );
	menu_additem( hItem, "Zpet", "6" );
	
	menu_display( id, hItem, 0 );
	
	return PLUGIN_HANDLED;
}

public itemy_te( id )
{
	if( !is_user_alive( id ) )
	{
		return PLUGIN_HANDLED;
	}
	
	new hItem = menu_create( "\yItemy \w( \r/furien\w )^nSpecialne itemy zostanu ulozene i^npo odpojeni z hry!", "itemy_te_handler" );
	if( !( g_bREG[ id ] == 1 ) )
		menu_additem( hItem, "\wRegeneracia^t^t^t^t \r22000\r$^n\d- Doplnuje +2HP kazdou sekundu", "1", 0 );
	else
		menu_additem( hItem, ( g_bActived_Regen[ id ] ) ? "\wRegeneracia^t^t^t^t \y[ON]^n\d- Doplnuje +2HP kazdou sekundu" : "\wRegeneracia^t^t^t^t \r[OFF]^n\d- Doplnuje +2HP kazdou sekundu", "1", 0 );
	if( !( g_bND[ id ] == 1 ) )
		menu_additem( hItem, "\wAbsolute Defense \r33000\r$^n\d- Sanca 40% ze gulka neubere HP", "2", 0 );
	else
		menu_additem( hItem, ( g_bActived_NoDamage[ id ] ) ? "\wAbsolute Defense \y[ON]^n\d- Sanca 40% ze gulka neubere HP" : "\wAbsolute Defense \r[OFF]^n\d- Sanca 40% ze gulka neubere HP", "2", 0 );
	if( !( g_bCO[ id ] == 1 ) )
		menu_additem( hItem, "\wEpic Money^t^t^t^t  \r21000\r$^t^t^t\y[VIP]^n\d- 50% viac peniazi a EXP za zabitie", "3", VIP );
	else
		menu_additem( hItem, ( g_bActived_Epicmoney[ id ] ) ? "\wEpic Money^t^t^t^t  \y[ON]^n\d- 50% viac peniazi a EXP za zabitie" : "\wEpic Money^t^t^t^t  \r[OFF]^n\d- 50% viac peniazi a EXP za zabitie", "3", VIP );
	if( !( g_bRE[ id ] == 1 ) )
		menu_additem( hItem, "\wNesmrtelnost^t^t^t^t\r28000\r$^t^t^t\y[ExtraVIP]^n\d- Nesmrtelnost na niekolko sekund", "4", EVIP );
	else
		menu_additem( hItem, ( !g_bActived_Nesmrtelnost[ id ] ) ? "\wNesmrtelnost^t^t^t^t \y[neaktivovane]^n\d- Nesmrtelnost na niekolko sekund" : "\wNesmrtelnost^t^t^t^t \r[aktivovane]^n\d- Nemsrtelnost na niekolko sekund", "4", EVIP );
	if( !( g_bMJ[ id ] == 1 ) )
		menu_additem( hItem, "\wMultijump^t^t^t^t^t  \r23000\r$^t^t^t\y[ExtraVIP]^n\d- Pridava dalsi skok vo vzduchu", "5", EVIP );
	else
		menu_additem( hItem, ( g_bActived_DoubleJump[ id ] ) ? "\wMultijump^t^t^t^t^t  \y[ON]^n\d- Pridava dalsi skok vo vzduchu" : "\wMultijump^t^t^t^t^t  \r[OFF]^n\d- Pridava dalsi skok vo vzduchu", "5", EVIP );
	menu_additem( hItem, "Zpet", "6");
	menu_display( id, hItem, 0 );
	
	return PLUGIN_HANDLED;
}

public itemy_ct_handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT || !is_user_alive( id ) || cs_get_user_team( id ) == CS_TEAM_T )
	{
		return PLUGIN_HANDLED;
	}
	
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iKey = str_to_num( szData );
	
	switch( iKey )
	{
		case 1:
		{
			if( !( g_bREG[ id ] == 1 ) )
			{
				if( peniaze[ id ]>= 22000 )
				{
					otazka_regeneracia( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_Epicmoney[ id ] = false;
				if( g_bActived_Regen[ id ] )
				{
					g_bActived_Regen[ id ] = false;
					remove_task( id + TASK_REGEN );
				} 
				else 
				{
					g_bActived_Regen[ id ] = true;
					set_task( 1.0, "regeneracia", id + TASK_REGEN, _, _, "b" );
					//set_task( 1.0, "Task_HealthRegen", id + TASK_REGEN, _, _, "b" );
				}
				itemy_ct( id );
			}
		}
		
		case 2:
		{
			if( !( g_bDS[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 10000 )
				{
					otazka_drtivestrely( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Laser[ id ] = false;
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_Immobilize[ id ] = ( g_bActived_Immobilize[ id ] ) ? false : true;
				itemy_ct( id );
			}
		}
		
		case 3:
		{
			if( !( g_bLaser[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 20000 )
				{
					otazka_laser( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				g_bActived_BunnyHop[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_Laser[ id ] = ( g_bActived_Laser[ id ] ) ? false : true;
				itemy_ct( id );
			}
		}
		
		case 4:
		{
			if( !( g_bBH[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 25000 )
				{
					otazka_bunnyhop( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_BunnyHop[ id ] = ( g_bActived_BunnyHop[ id ] ) ? false : true;
				itemy_ct( id );
			}
		}
		
		case 5:
		{
			if( !( g_bMJ[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 23000 )
				{
					otazka_multijump( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_DoubleJump[ id ] = ( g_bActived_DoubleJump[ id ] ) ? false : true;
				itemy_ct( id );
			}
		}
		
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}
public regeneracia( id )
{
	if( task_exists( id + TASK_REGEN ) )
		remove_task( id + TASK_REGEN );
		
	id -= TASK_REGEN;
	
	if( !is_user_alive( id ) )
		return PLUGIN_HANDLED;
		
	if( get_user_team( id ) == 1 )
	{
		if( g_bActived_Regen[ id ] == 1 )
			if( get_user_health( id ) < g_maxHP[ id ] )
			set_user_health( id,get_user_health( id )+ 2 );
	
		if( get_user_health( id ) >= g_maxHP[ id ] )
			set_user_health( id, g_maxHP[ id ] );
	}
	else
	{
		if( g_bActived_Regen[ id ] == 1 )
			if( get_user_health( id ) < g_maxHP[ id ] )
			set_user_health( id,get_user_health( id )+ 2 );
	
		if( get_user_health( id ) >= g_maxHP[ id ] )
			set_user_health( id, g_maxHP[ id ] );
	}
	
	return PLUGIN_HANDLED;
}

public itemy_te_handler( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT || !is_user_alive( id ) || cs_get_user_team( id ) == CS_TEAM_CT  )
	{
		return PLUGIN_HANDLED;
	}
	
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iKey = str_to_num( szData );
	
	switch( iKey )
	{
		case 1:
		{
			if( !( g_bREG[ id ] == 1 ) )
			{
				if( peniaze[ id ]>= 22000 )
				{
					otazka_regeneracia( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				if( g_bActived_Regen[ id ] )
				{
					g_bActived_Regen[ id ] = false;
					remove_task( id + TASK_REGEN );
				} 
				else 
				{
					g_bActived_Regen[ id ] = true;
					set_task( 1.0, "regeneracia", id + TASK_REGEN, _, _, "b" );
				}
				itemy_te( id );
			}
		}
		case 2:
		{
			if( !( g_bND[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 33000 )
				{
					otazka_mrstnost( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_Laser[ id ] = false;
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_NoDamage[ id ] = ( g_bActived_NoDamage[ id ] ) ? false : true;
				itemy_te( id );
			}
		}
		case 3:
		{
			if( !( g_bCO[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 21000 )
				{
					otazka_zmatenie( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_Epicmoney[ id ] = ( g_bActived_Epicmoney[ id ] ) ? false : true;
				itemy_te( id );
			}
		}
		case 4:
		{
			if( !( g_bRE[ id ] == 1 ) )
			{
				if( peniaze[ id ]>= 28000 )
				{
					otazka_nesmrtelnost( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				g_bActived_Laser[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_DoubleJump[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				g_bActived_Nesmrtelnost[ id ] = true;
				GodMode_ON( id );
				remove_task( id + TASK_REGEN );
				g_bActived_Respawn[ id ] = false;
				
				if( g_bActived_Nesmrtelnost[ id ] )
				{
					g_bActived_Nesmrtelnost[ id ] = true;
				} 
				else 
				{
					g_bActived_Nesmrtelnost[ id ] = false;
				}
				itemy_te( id );
			}
		}
		case 5:
		{
			if( !( g_bMJ[ id ] == 1 ) )
			{
				if( peniaze[ id ] >= 23000 )
				{
					otazka_multijump( id );
					client_cmd( id, "mp3 play /sound/bluezone/furien/vyber_item.mp3" );
				} else ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
				} else {
				g_bActived_Regen[ id ] = false;
				g_bActived_Immobilize[ id ] = false;
				client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
				g_bActived_Laser[ id ] = false;
				g_bActived_BunnyHop[ id ] = false;
				g_bActived_NoDamage[ id ] = false;
				g_bActived_Epicmoney[ id ] = false;
				remove_task( id + TASK_REGEN );
				g_bActived_DoubleJump[ id ] = ( g_bActived_DoubleJump[ id ] ) ? false : true;
				itemy_te( id );
			}
		}
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}
public GodMode_ON( id )
{
	if( nesmrt[ id ] == 0 )
	{
	if( !id || !is_user_alive( id ) )
		return PLUGIN_CONTINUE;

	set_user_godmode( id, 1 );
	nesmrt[ id ] = 1;
	set_task( 5.0, "GodMode_OFF", TASK_GODMODE + id );
	ScreenFade( id, 5.0, 170, 255, 255, 100 );
	return client_print( id, print_chat, "%L", LANG_PLAYER, "GOD_HAVE" );
	}
	return client_print( id, print_chat, "%L", LANG_PLAYER, "GOD_EXPIRED" );
}
public GodMode_OFF( id )
{
	id -= TASK_GODMODE;
	if( !id || !is_user_alive( id ) )
		return PLUGIN_CONTINUE;

	set_user_godmode( id, 0 );
	ScreenFade( id, 1.0, 255, 0, 0, 100 );
	ChatColor( id, "%L", LANG_PLAYER, "NO_IMMUNITY" );
	return client_print( id, print_chat, "%L", LANG_PLAYER, "GOD_HAVED" );
}
public plugin_cfg( )
{
	g_MaxClients = global_get( glb_maxClients );
	g_nVault = nvault_open( "fur_points" );

	if ( g_nVault == INVALID_HANDLE )
		set_fail_state( "ERROR: Pri otvarani fur_points ulozisku!" );
}
public plugin_end( )
{
	nvault_close( g_nVault );
	
	return PLUGIN_CONTINUE;
}
public Event_DeathMsg( )
{
	new id = read_data( 2 );
	if( is_user_connected( id ) )
	{
		show_menu( id, 0, "\n", 1 );
	}
	static Attacker, Headshot, Weapon[ 32 ];
	
	Attacker = read_data( 1 );
	Headshot = read_data( 3 );
	read_data( 4, Weapon, sizeof( Weapon ) );
	
	if( !is_user_connected ( Attacker ) )
		return
	
	g_MyKillCount[ Attacker ] = min( g_MyKillCount[ Attacker ] + 1, MAX_KILL );
	
	if( g_MyKillCount[ Attacker ] <= 1 )
	{
		g_MySpecialKill[ Attacker ] = 0;
		
		if( Headshot )
		{
			g_MySpecialKill[ Attacker ] = KILL_HEADSHOT;
			} 
			else if( equal( Weapon, "knife" ) ) 
			{
				g_MySpecialKill[ Attacker ] = KILL_MELEE;
			} 
			else if( equal(Weapon, "grenade" ) ) 
			{
				g_MySpecialKill[ Attacker ] = KILL_GRENADE;
		}
	}
	remove_task( Attacker+TASK_CHECK_KILL );
	set_task( KILL_CHECK_DELAY, "Check_Kill", Attacker+TASK_CHECK_KILL );
}
public StarterSound( id )
{
	client_cmd( id, "mp3 stop" );
	client_cmd( id, "mp3 play sound/%s", g_szStartSounds[random_num( 0,charsmax( g_szStartSounds ) )] );
}
public event_SendAudio_Ter( id )
{
	new Players[ 32 ], playerCount, id;
	get_players( Players, playerCount );
	for( new i = 0; i <playerCount; i++ )
	{
		id = Players[ i ];
		
		//client_cmd( id, "mp3 stop" );
		client_cmd( id, "mp3 play sound/%s", g_szTer_Sounds[random_num( 0,charsmax( g_szTer_Sounds ) )] );
	}
}
public event_SendAudio_Ct( id )
{
	new Players[ 32 ], playerCount, id;
	get_players( Players, playerCount );
	for( new i = 0; i < playerCount; i++ )
	{
		id = Players[ i ];
		
		//client_cmd( id, "mp3 stop" );
		client_cmd( id, "mp3 play sound/%s", g_szCt_Sounds[random_num( 0,charsmax( g_szCt_Sounds ) )] );
	}
}
Check_Kill_CT( victim, attacker )
{
	if( g_Killsounds[ attacker ] )
	{
		if( get_pdata_int( victim, 75 ) == HIT_HEAD )
		{
			client_cmd( attacker, "stopsound" );
			client_cmd( attacker, "spk %s", Kills_Sounds[ 8 ] );	
			set_dhudmessage( 0, 127, 255, -1.0, 0.35, 0, 2.0, 2.0 );
			show_dhudmessage( attacker, "%L", LANG_PLAYER, "KILL_STATUS_HEADSHOT"  );
		}
		else
		{
			switch( g_MyKillCount[ attacker ] )
			{
				case 6:
				{
					new sIdName[ 32 ];
					get_user_name( attacker, sIdName, 31 );
					set_dhudmessage( 0, 127, 255, -1.0, 0.04, 1, 2.0, 3.0, 2.0 );
					show_dhudmessage( 0, "%s je SIALENY!", sIdName );
					
					client_cmd( attacker, "stopsound" );
					client_cmd( 0, "spk %s", Kills_Sounds[ 9 ] );	
				}
			}
		}
	}
}
public Check_Kill( id )
{
	id -= TASK_CHECK_KILL;
	if( !is_user_connected( id ) )
		return;
	
	static Color[ 3 ], KillText[ 64 ], MsgText;
	Color[ 0 ] = Color[ 1 ] = Color[ 2 ] = 0;
	MsgText = 0;
	if( g_Killsounds[ id ] )
	{
		if( get_user_team( id ) == 1 )
		{
			switch( g_MyKillCount[ id ] )
			{
				case 0:
				{
					MsgText = 0
					switch( g_MySpecialKill[ id ] )
					{
						case KILL_HEADSHOT: 
						{
							Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
							formatex( KillText, sizeof( KillText ), "HEAD SHOT" );
							client_cmd( id, "stopsound" );
							client_cmd( id, "spk %s", Kills_Sounds[ 0 ] );
						}
						case KILL_MELEE: 
						{
							Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
							formatex( KillText, sizeof( KillText ), "" );
							client_cmd( id, "stopsound" );
							client_cmd( id, "spk %s", Kills_Sounds[ 0 ] );					
						}
						case KILL_GRENADE: 
						{
							Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
							formatex( KillText, sizeof( KillText ), "GRENADE KILL" );
							client_cmd( id, "stopsound" );
							client_cmd( id, "spk %s", Kills_Sounds[ 0 ] );
						}
					}
				}
				case 1:
				{
					MsgText = 1;
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "FIRST KILL^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "FIRST KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 0 ] );
				}
				case 2:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "DOUBLE KILL^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "DOUBLE KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 1 ] );			
				}
				case 3:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "TRIPLE KILL^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "TRIPLE KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 2 ] );
				}
				case 4:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "MULTI KILL^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "MULTI KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 3 ] );			
				}
				case 5:
				{
					new sIdName[ 32 ];
					get_user_name( id, sIdName, 31 );
					set_dhudmessage( 255, 42, 42, -1.0, 0.04, 1, 2.0, 3.0, 2.0 );
					show_dhudmessage( 0, "%s MONSTER KILL!", sIdName );
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "MONSTER KILL^n+4 %% HP")
					else formatex( KillText, sizeof( KillText ), "MONSTER KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( 0, "spk %s", Kills_Sounds[ 4 ] );	
				}
				case 6:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "MEGA KILL^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "MEGA KILL^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 5 ] );	
				}
				case 7:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "EXCELLENT^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "EXCELLENT^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 6 ] );		
				}
				case 8:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 7 ] );	
					
				}
				case 9:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 7 ] );	
					
				}
				case 10:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 7 ] );	
					
				}
				case 11:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 7 ] );	
					
				}
				case 12:
				{
					MsgText = 1
					Color[ 0 ] = 255 ; Color[ 1 ] = 42 ; Color[ 2 ] = 42
					if( g_MySpecialKill[ id ] == KILL_HEADSHOT ) formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					else formatex( KillText, sizeof( KillText ), "GOT IT!^n+4 %% HP" )
					client_cmd( id, "stopsound" );
					client_cmd( id, "spk %s", Kills_Sounds[ 7 ] );	
					
				}
				default:
			{
				return;
			}
		}
			g_MySpecialKill[ id ] = 0
			//set_dhudmessage( Color[ 0 ] ,Color[ 1 ] , Color[ 2 ] , -1.0, 0.35, 0, 6.0, 1.1, 0.0, 0.0, -1 );
			set_dhudmessage( Color[ 0 ], Color[ 1 ], Color[ 2 ], -1.0, 0.35, 0, 1.0, 1.0 ); // 0, 6.0, 1.1, 0.0, 0.0, -1 ShowSyncHudMsg(id, g_SyncHud_Kill, KillText)
			show_dhudmessage( id, "%s" , KillText );
			
			remove_task( id+TASK_RESET_TIME );
			set_task( RESET_TIME, "Do_Reset", id+TASK_RESET_TIME );
			
			if( MsgText && g_MyKillCount[ id ] != 1 )
			{
				static Name[ 64 ];
				get_user_name( id, Name, sizeof( Name ) );
			}
		}
	} 
} 

public Do_Reset( id )
{
	id -= TASK_RESET_TIME;
	if( !is_user_connected( id ) )
		return;
	
	g_MyKillCount[ id ] = 0;
	g_MySpecialKill[ id ] = 0;
}
public OnCArmoury_ArmouryTouch( ) { return HAM_SUPERCEDE; }
public OnCShield_Touch( ) { return HAM_SUPERCEDE; }

public nastavenie( id )
{
	new nast = menu_create( "\yHerne nastavenie \d( \r/furien \d)", "nastavenie_handle" );
	
	menu_additem( nast, ( g_Menu[ id ] ) ? "\wFast Menu^t^t^t  \y[\wzapnute\y]^n\d- Menu sa automaticky zavre po vyberu zbrane" : "\wFast Menu^t^t^t^t\y[\rvypnute\y]^n\d- Menu sa automaticky zavre po vyberu zbrane", "1", 0 );
	menu_additem( nast, ( g_Killsounds[ id ] ) ? "\wKill Sound^t^t^t^t^t\y[\wzapnute\y]^n\d- Zobrazuje spravu pokial niekoho zabijete" : "\wKill Sound^t^t^t^t^t\y[\rvypnute\y]^n\d- Zobrazuje spravu pokial niekoho zabijete", "2", 0 );
	menu_additem( nast, ( g_nastavenieModely[ id ] ) ? "\wOld Weapons^t^t\y[\rvypnute\y]^n\d- Nastavi povodni vzhlad pre vsetky zbrane" : "\wOld Weapons^t^t\y[\wzapnute\y]^n\d- Nastavi povodni vzhlad pre vsetky zbrane", "3", 0 );
	menu_additem( nast, ( StartSound[ id ] ) ? "\wStart Sound^t^t^t \y[\wzapnute\y]^n\d- Na zaciatku kola bude pustat pesnicky" : "\wStart Sound^t^t^t \y[\rvypnute\y]^n\d- Na zaciatku kola bude pustat pesnicky", "4", 0 );
	menu_additem( nast, ( pohlad[ id ] ) ? "\w3D Pohlad^t^t^t^t  \y[\wzapnute\y]^n\d- Nastavenie 3D Pohladu hraca^n" : "3D Pohlad^t^t^t^t  \y[\rvypnute\y]^n\d- Nastavenie 3D Pohladu hraca^n", "5", 0 );
	menu_additem( nast, "Zpet", "6" );
	
	menu_display( id, nast, 0 );
}
public nastavenie_handle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			g_Menu[ id ] = ( g_Menu[ id ] ) ? false : true;	
			nastavenie( id );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			g_Killsounds[ id ] = ( g_Killsounds[ id ] ) ? false : true;
			nastavenie( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			g_nastavenieModely[ id ] = ( g_nastavenieModely[ id ] ) ? false : true;
			new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
			if( pev_valid( weapon_ent ) )
			replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
			nastavenie( id );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			if( StartSound[ id ] == true )
			{
				StartSound[ id ] = false;
				client_cmd( id, "mp3 stop" );
				nastavenie( id );
			}
			else
			{
				StartSound[ id ] = true;
				ChatColor( id, "!gPockaj !t4 sekundy!g, pokial sa ti nacte pesnicka!" );
				StarterSound( id );
				nastavenie( id );
			}
		}
		case 4:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			if( pohlad[ id ] == true )
			{
				pohlad[ id ] = false;
				ClCmd_ToggleCamera( id );				
				nastavenie( id );
			}
			else
			{
				pohlad[ id ] = true;
				ClCmd_ToggleCamera( id );
				nastavenie( id );
			}
		}
		case 5:
		{
			herne_menu( id );
		}
		
	}
	return PLUGIN_HANDLED;
}
public knife_menu( id )
{
	new oc = menu_create( "\yKnife Menu 1/2 \w( \r/furien \w)","knife_menu_handle" );
	if( !g_shopDefault[ id ] )
		menu_additem( oc, "Default Knife^t^t^t^t \r0$^n\d- nema ziadne schopnosti", "1", 0 );
	else
		menu_additem( oc, "Default Knife^t^t^t^t \w[kupene]^n\dnema ziadne schopnosti", "1", 0 );
	if( !g_shopAxe[ id ] )
		menu_additem( oc, "Axe^t^t^t^t^t^t^t^t^t^t     \r3$^n\d+3 % HP a +3 % Defense", "2", 0 );
	else
		menu_additem( oc, "Axe^t^t^t^t^t^t^t^t^t^t     \w[kupene]^n\d+3 % HP a +3 % Defense", "2", 0 );
	if( !g_shopAssasin[ id ] )
		menu_additem( oc, "Assasin Knife^t^t^t^t  \r5$^n\d+10 % HP", "3", 0 );
	else
		menu_additem( oc, "Assasin Knife^t^t^t^t  \w[kupene]^n\d+10 % HP", "3", 0 );
	if( !g_shopBloody[ id ] )
		menu_additem( oc, "Bloody Knife^t^t^t^t  \r10$ ^n\d+10 % Defense", "4", 0 );
	else
		menu_additem( oc, "Bloody Knife^t^t^t^t  \w[kupene]^n\d+10 % Defense", "4", 0 );
	if( !g_shopCrowBar[ id ] )
		menu_additem( oc, "\y[VIP]\w Crowbar^t^t^t  \r15$^n\d+25 % Defense^n", "5", 0 );
	else
		menu_additem( oc, "\y[VIP]\w Crowbar^t^t^t  \w[kupene]^n\d+25 % Defense^n", "5", 0 );
	menu_additem( oc, "\rDalsie", "6" );
	menu_additem( oc, "Zpet", "7" );
	menu_display( id,oc );
}

public knife_menu_handle( id,menu,item )
{	
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED
	}
	switch( item )
	{
		case 0:
		{
			if( !g_shopDefault[ id ] )
			{
				client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
				set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
				ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
				userknife[ id ] = 10
				ham_strip_weapon( id, "weapon_knife" );
				give_item( id,"weapon_knife" );
				g_shopDefault[ id ] = true;
				g_shopAxe[ id ] = false;
				g_shopAssasin[ id ] = false;
				g_shopBloody[ id ] = false;
				g_shopCrowBar[ id ] = false;
				g_shopArmy[ id ] = false;
				g_shopIce[ id ] = false;
				g_shopUlti[ id ] = false;
				g_shopDragon[ id ] = false;
				g_shopNeon[ id ] = false;
				new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
				if( pev_valid( weapon_ent ) )
				replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Default Knife]!y Uz mas tento knife aktivovany!" );
				knife_menu( id );
			}
			
		}
		case 1:
		{
			if( !g_shopAxe[ id ] )
			{
				if( peniaze[ id ] >= 3 )
				{
					client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
					ChatColor( id, "!g[Knife Menu]!y Schopnosti !tAxe!y sa aktivuju na nove kolo!" );
					userknife[ id ] = 3;
					ham_strip_weapon( id, "weapon_knife" );
					give_item( id,"weapon_knife" );
					peniaze[ id ] -= 3;
					g_shopDefault[ id ] = false;
					g_shopAxe[ id ] = true;
					g_shopAssasin[ id ] = false;
					g_shopBloody[ id ] = false;
					g_shopCrowBar[ id ] = false;
					g_shopArmy[ id ] = false;
					g_shopIce[ id ] = false;
					g_shopUlti[ id ] = false;
					g_shopDragon[ id ] = false;
					g_shopNeon[ id ] = false;
					cs_set_user_money( id,peniaze[ id ] );
					new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
					if( pev_valid( weapon_ent ) )
					replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					knife_menu( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Axe]!y Uz mas tento knife aktivovany!" );
				knife_menu( id );
			}
		}
		case 2:
		{
			if( !g_shopAssasin[ id ] )
			{
				if( peniaze[ id ] >= 5 )
				{
					client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
					ChatColor( id, "!g[Knife Menu]!y Schopnosti !tAssasin Knife!y sa aktivuju na nove kolo!" );
					userknife[ id ] = 4;
					ham_strip_weapon( id, "weapon_knife" );
					give_item( id,"weapon_knife" );
					peniaze[ id ] -= 5;
					new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
					if( pev_valid( weapon_ent ) )
					replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
					cs_set_user_money( id,peniaze[ id ] );
					g_shopDefault[ id ] = false;
					g_shopAxe[ id ] = false;
					g_shopAssasin[ id ] = true;
					g_shopBloody[ id ] = false;
					g_shopCrowBar[ id ] = false;
					g_shopArmy[ id ] = false;
					g_shopIce[ id ] = false;
					g_shopUlti[ id ] = false;
					g_shopDragon[ id ] = false;
					g_shopNeon[ id ] = false;
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					knife_menu( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Assasin Knife]!y Tento knife uz mas aktivovany! " );
				knife_menu( id );
			}
		}	
		case 3:
		{
			if( !g_shopBloody[ id ] )
			{
				if( peniaze[ id ] >= 10 )
				{
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
					client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
					ChatColor( id, "!g[Knife Menu]!y Schopnosti !tBloody Knife!y sa aktivuju na nove kolo!" );
					userknife[ id ] = 5;
					ham_strip_weapon( id, "weapon_knife" );
					give_item( id,"weapon_knife" );
					peniaze[ id ] -= 10;
					cs_set_user_money( id,peniaze[ id ] )
					new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
					if( pev_valid( weapon_ent ) )
					replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
					g_shopDefault[ id ] = false;
					g_shopAxe[ id ] = false;
					g_shopAssasin[ id ] = false;
					g_shopBloody[ id ] = true;
					g_shopCrowBar[ id ] = false;
					g_shopArmy[ id ] = false;
					g_shopIce[ id ] = false;
					g_shopUlti[ id ] = false;
					g_shopDragon[ id ] = false;
					g_shopNeon[ id ] = false;
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
					knife_menu( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Bloody Knife]!y Tento knife uz mas aktivovany!" );
				knife_menu( id );
			}
		}
		case 4:
		{
			if( !g_shopCrowBar[ id ] )
			{
				if( get_user_flags( id ) & VIP )
				{
					if( peniaze[ id ] >= 15 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tCrowbar!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 12;
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						peniaze[ id ] -= 15;
						cs_set_user_money( id,peniaze[ id ] );						
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = true;
						g_shopArmy[ id ] = false;
						g_shopIce[ id ] = false;
						g_shopUlti[ id ] = false;
						g_shopDragon[ id ] = false;
						g_shopNeon[ id ] = false;
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_VIP" );
					knife_menu( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Crowbar]!y Tento knife uz mas aktivovany!" );
				knife_menu( id );
			}
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu_new( id );
		}	
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public knife_menu_new( id )
{
	new oc = menu_create( "\yKnife Menu 2/2 \w( \r/furien \w)","knife_menu_new_handle" );
	if( !g_shopArmy[ id ] )
		menu_additem( oc, "\y[VIP]\w US Army^t^t^t^t^t^t^t^t \r20$^n\d+20 % HP", "1", 0 );
	else
		menu_additem( oc, "\y[VIP]\w US Army^t^t^t^t^t^t^t^t \w[kupene]^n\d+20 % HP", "1", 0 );
	if( !g_shopIce[ id ] )
		menu_additem( oc, "\y[VIP]\w Ice Knife^t^t^t^t^t^t^t  \r25$^n\d+10 % Damage", "2", 0 );
	else
		menu_additem( oc, "\y[VIP]\w Ice Knife^t^t^t^t^t^t^t  \w[kupene]^n\d+10 % Damage", "2", 0);
	if( !g_shopUlti[ id ] )
		menu_additem( oc, "\y[ExtraVIP]\w Ulti Knife^t    \r30$^n\dza kazdy hit nepriatela ziskas +3$", "3", 0 );
	else
		menu_additem( oc, "\y[ExtraVIP]\w Ulti Knife^t    \w[kupene]^n\dza kazdy hit nepriatela ziskas +3$", "3", 0 );
	if( !g_shopDragon[ id ] )
		menu_additem( oc, "\y[ExtraVIP]\w Dragon Knife \r35$^n\d+60 % viac EXP za kill", "4", 0 );
	else
		menu_additem( oc, "\y[ExtraVIP]\w Dragon Knife \w[kupene]^n\d+60 % viac EXP za kill", "4", 0 );
	if( !g_shopNeon[ id ] )
		menu_additem( oc, "\y[ExtraVIP]\w Neon Knife^t  \r60$^n\dFreeze Granat ta nezmrazi", "5", 0 );
	else
		menu_additem( oc, "\y[ExtraVIP]\w Neon Knife^t  \w[kupene]^n\dFreeze Granat ta nezmrazi", "5", 0 );
	menu_additem( oc, "Zpet", "6" );
	menu_display( id,oc );
}

public knife_menu_new_handle( id,menu,item )
{	
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			if( !g_shopArmy[ id ])
			{
				if( get_user_flags( id ) & VIP )
				{
					if( peniaze[ id ] >= 20 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tUS Army!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 6;
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );				
						peniaze[ id ] -= 20;
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = false;
						g_shopArmy[ id ] = true;
						g_shopIce[ id ] = false;
						g_shopUlti[ id ] = false;
						g_shopDragon[ id ] = false;
						g_shopNeon[ id ] = false;
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						cs_set_user_money( id,peniaze[ id ] );
								
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu_new( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_VIP" );
					knife_menu_new( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[US Army]!y Tento knife uz mas aktivovany!" );
				knife_menu_new( id );
			}
		}	
		case 1:
		{
			if( !g_shopIce[ id ] )
			{
				if( get_user_flags( id ) & VIP )
				{
					if( peniaze[ id ] >= 25 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tIce Knife!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 7;
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						peniaze[ id ] -= 25;
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = false;
						g_shopArmy[ id ] = false;
						g_shopIce[ id ] = true;
						g_shopUlti[ id ] = false;
						g_shopDragon[ id ] = false;
						g_shopNeon[ id ] = false;
						cs_set_user_money( id,peniaze[ id ] );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu_new( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_VIP" );
					knife_menu_new( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Ice Knife]!y Tento knife uz mas aktivovany!" );
			}
		}
		case 2:
		{
			if( !g_shopUlti[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 30 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tUlti Knife!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 8;
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						peniaze[ id ] -= 30;
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = false;
						g_shopArmy[ id ] = false;
						g_shopIce[ id ] = false;
						g_shopUlti[ id ] = true;
						g_shopDragon[ id ] = false;
						g_shopNeon[ id ] = false;
						cs_set_user_money( id,peniaze[ id ] );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu_new( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
					knife_menu_new( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Ulti Knife]!y Tento knife uz mas aktivovany!" );
				knife_menu_new( id );
			}
		}
		case 3:
		{
			if( !g_shopDragon[ id ])
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 35 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tDragon Knife!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 11;
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						peniaze[ id ] -= 35;
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = false;
						g_shopArmy[ id ] = false;
						g_shopIce[ id ] = false;
						g_shopUlti[ id ] = false;
						g_shopDragon[ id ] = true;
						g_shopNeon[ id ] = false;
						cs_set_user_money( id,peniaze[ id ] );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu_new( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
					knife_menu_new( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Dragon Knife]!y Tento item uz mas aktivovany!" );
				knife_menu_new( id );
			}
		}
		case 4:
		{
			if( !g_shopNeon[ id ] )
			{
				if( get_user_flags( id ) & EVIP )
				{
					if( peniaze[ id ] >= 60 )
					{
						set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
						ShowSyncHudMsg( id, SyncHudObj, "%L", LANG_PLAYER, "SHOP_KNIFE_MENU_WAIT" );
						client_cmd( id, "spk bz_furien_mod/menu_knife.wav" );
						ChatColor( id, "!g[Knife Menu]!y Schopnosti !tNeon Knife!y sa aktivuju na nove kolo!" );
						userknife[ id ] = 13;
						ham_strip_weapon( id, "weapon_knife" );
						give_item( id,"weapon_knife" );
						peniaze[ id ] -= 60;
						new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
						if( pev_valid( weapon_ent ) )
						replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
						g_shopDefault[ id ] = false;
						g_shopAxe[ id ] = false;
						g_shopAssasin[ id ] = false;
						g_shopBloody[ id ] = false;
						g_shopCrowBar[ id ] = false;
						g_shopArmy[ id ] = false;
						g_shopIce[ id ] = false;
						g_shopUlti[ id ] = false;
						g_shopDragon[ id ] = false;
						g_shopNeon[ id ] = true;
						cs_set_user_money( id,peniaze[ id ] );
					}
					else
					{
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id,"%L", LANG_PLAYER, "NO_MONEY" );
						knife_menu_new( id );
					}
				}
				else
				{
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id,"%L", LANG_PLAYER, "NO_EVIP" );
					knife_menu_new( id );
				}
			}
			else
			{
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!g[Neon Knife]!y Tento knife uz mas aktivovany!" );
				knife_menu_new( id );
			}
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			knife_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}	
//SetHamParamFloat( 4, damage + ( g_unDMLevel[ attacker ] * 0.01 ) ); 
public Hrac_Damage( victim, inflictor, attacker, Float:damage, damage_bits, id )
{
	if( is_user_connected( attacker ) )
	{    
		if( !superknife[ attacker ] )
		{ 
			SetHamParamFloat( 4, damage + ( g_unDMLevel[ attacker ] * 0.1 ) ); 
		}
		
		new weapon = get_user_weapon( attacker );
		switch( weapon )
		{
			
			case CSW_KNIFE:
			{
				if( superknife[ attacker ] )
				{
					SetHamParamFloat( 4,damage * 4.0 );
					} else {
					SetHamParamFloat( 4, damage );
				}
				if( !superknife[ attacker ] && g_shopIce[ attacker ] && get_user_team( attacker ) == 1 )
				{
					SetHamParamFloat( 4,damage * 1.16 );
				}
			}
			case CSW_M3: SetHamParamFloat( 4,damage * 0.25 );
				case CSW_UMP45: SetHamParamFloat( 4,damage * 0.30 );
				case CSW_GLOCK18: SetHamParamFloat( 4,damage * 0.25 );
				case CSW_HEGRENADE: SetHamParamFloat( 4,damage * 0.30 );
			}
	}
	if( damage_bits & DMG_NADE )
	{
		if( victim == attacker )
			return HAM_SUPERCEDE;
		
		new Float:newdmg = damage * 0.5;
		
		SetHamParamFloat( 4, newdmg );
	}
	return HAM_IGNORED;
}	

public Hrac_Zomrel( victim,attacker,shouldgibc )
{
	if( !is_user_bot( attacker ) )
	{
		if( is_user_alive( attacker ) )
		{
			if( get_user_team( victim ) == 2 )
			{
				if( get_user_flags( attacker ) & EVIP )
				{
					peniaze[ attacker ] += 30;
					exp[ attacker ] += 5;
					case_open( attacker );
					set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
					
					effekt_kill( attacker );
					
					if( g_bActived_Epicmoney[ attacker ] == 1 )
					{
						peniaze[ attacker ] += 15;
						exp[ attacker ] += 2;
						ChatColor( attacker, "!tBonus !y+15$!t a !y+2 EXP!t za pouzivanie itemu Epic Money" );
					}
					
					if( g_event_drop == 1 )
					{
						give_items( attacker );
						peniaze[ attacker ] += 15;
						exp[ attacker ] += 2;
						ChatColor( attacker, "!tBonus !y+15$!t a !y+2 EXP!t za EVENT!" );
					}
					
					if( g_shopDragon[ attacker ] )
					{
						exp[ attacker ] += 3;
						ChatColor( attacker, "!tBonus !y+3 EXP!t za pouzivanie Dragon Knife" );
					}
					cs_set_user_money( attacker,peniaze[ attacker ] );
				}
				else
				{
					if( get_user_flags( attacker ) & VIP )
					{
						peniaze[ attacker ] += 20;
						exp[ attacker ] += 5;
						ScreenFade( attacker, 1.0, 255, 42, 42, 100 );
						set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
						effekt_kill( attacker );
						
						if( g_event_drop == 1 )
						{
							give_items( attacker );
							peniaze[ attacker ] += 10;
							exp[ attacker ] += 2;
							ChatColor( attacker, "!tBonus !y+10$!t a !y+2 EXP!t za EVENT!" );
						}
						cs_set_user_money( attacker,peniaze[ attacker ] );
					}
					else
					{
						if( g_event_drop == 1 )
						{
							give_items( attacker )	
							peniaze[ attacker ] += 7;
							exp[ attacker ] += 2;
							ChatColor( attacker, "!tBonus !y+7$!t a !y+2 EXP!t za EVENT!" );
						}
						set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
						exp[ attacker ] += 5;
						peniaze[ attacker ] += 15;
						cs_set_user_money( attacker,peniaze[ attacker ] );
						effekt_kill( attacker );
					}
				}
			}
			else if( get_user_team( victim ) == 1 )
			{
				if( get_user_flags( attacker ) & EVIP )
				{
					exp[ attacker ] += 5;
					peniaze[ attacker ] += 25;
					case_open( attacker );
					set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
					effekt_kill( attacker );
					if( g_event_drop == 1 )
					{
						give_items( attacker );
						peniaze[ attacker ] += 12;
						exp[ attacker ] += 2;
						ChatColor( attacker, "!tBonus !y+12$!t a !y+2 EXP!t za EVENT!" );
					}
					cs_set_user_money( attacker,peniaze[ attacker ] );
				}
				else
				{
					if( get_user_flags( attacker ) & VIP )
					{
						if( g_event_drop == 1 )
						{
							give_items( attacker );
							peniaze[ attacker ] += 7;
							exp[ attacker ] += 2;
							ChatColor( attacker, "!tBonus !y+7$!t a !y+2 EXP!t za EVENT!" );
						}
						exp[ attacker ] += 5;
						peniaze[ attacker ] += 15;
						cs_set_user_money( attacker,peniaze[ attacker ] );
						set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
						effekt_kill( attacker );
					}
					else
					{
						if( g_event_drop == 1 )
						{
							give_items( attacker );
							peniaze[ attacker ] += 5;
							exp[ attacker ] += 2;
							ChatColor( attacker, "!tBonus !y+5$!t a !y+2 EXP!t za EVENT!" );
						}
						exp[ attacker ] += 5;
						peniaze[ attacker ] += 10;
						cs_set_user_money( attacker,peniaze[ attacker ] );
						set_pev( attacker, pev_health, float( min( pev( attacker, pev_health ) + 4, g_maxHP[ attacker ] ) ) );
						effekt_kill( attacker );
					}
				}
					
			}
			if( get_user_team( attacker ) == 2 )
			{
				if( !is_user_connected( attacker ) )
					return;
		
				if( victim == attacker )
					return;
		
				Check_Kill_CT( victim, attacker );
			}
			
			superknife[ victim ] = false;

		}
	}
}

public client_PostThink( id )
{
	SaveData( id );
	if( BoughtWallHang[ id ] && IsUserHanged[ id ] )
	{
		engfunc( EngFunc_SetSize, id, g_fVecMins[ id ], g_fVecMaxs[ id ] );
		engfunc( EngFunc_SetOrigin, id, g_fVecOrigin[ id ] );
		entity_set_vector( id, EV_VEC_velocity, Float:{0.0, 0.0, 0.0} );
		set_pdata_float( id, m_flNextAttack, 1.0, XO_PLAYER );
	}
}

public World_Touch( iEnt, id )
{
	if(	IsPlayer( id )
	&&	BoughtWallHang[ id ]
	&&	!IsUserHanged[ id ]
	&&	is_user_alive( id )
	&&	pev( id, pev_button ) & IN_USE
	&&	~pev( id, pev_flags ) & FL_ONGROUND	)
{
	IsUserHanged[ id ] = true;
	pev( id, pev_mins, g_fVecMins[ id ] );
	pev( id, pev_maxs, g_fVecMaxs[ id ] );
	pev( id, pev_origin, g_fVecOrigin[ id ] );
	}
}

public Player_Jump( id )
{
	static flags; flags = entity_get_int( id, EV_INT_flags );
	
	if( ( flags & FL_WATERJUMP ) || entity_get_int( id, EV_INT_waterlevel ) >= 2 || !is_user_alive( id ) )
		
	return HAM_IGNORED;
	
	static afButtonPressed ; afButtonPressed = get_pdata_int( id, m_afButtonPressed )
	
	if(!BoughtWallHang[ id ] || !IsUserHanged[ id ] )
	{
		return HAM_IGNORED;
	}
	
	if( ~afButtonPressed & IN_JUMP )
	{
		return HAM_IGNORED;
	}
	
	IsUserHanged[ id ] = false;
	
	new Float:fVecVelocity[ 3 ];
	
	velocity_by_aim( id, 600, fVecVelocity );
	entity_set_vector( id, EV_VEC_velocity, fVecVelocity );
	
	set_pdata_int( id, m_Activity, ACT_HOP );
	set_pdata_int( id, m_IdealActivity, ACT_HOP );
	entity_set_int( id, EV_INT_gaitsequence, PLAYER_JUMP );
	entity_set_float( id, EV_FL_frame, 0.0 );
	set_pdata_int( id, m_afButtonPressed, afButtonPressed & ~IN_JUMP );

	return HAM_SUPERCEDE;
}

public Fwd_PlayerPreThink( id )
{
	static temp, weapon;
	weapon = get_user_weapon( id, temp, temp );
	
	if( weapon == CSW_KNIFE && superknife[ id ] )
	{
		static button;
		button = pev( id, pev_button );
		
		if( button & IN_ATTACK )
		{
			button = ( button & ~IN_ATTACK ) | IN_ATTACK2;
			set_pev( id, pev_button, button );
		}
	}
}

public bomb_drop( id )
{
	if( !is_valid_ent( id ) )
		return;
	
	if( cs_get_user_team( id ) == CS_TEAM_CT )
	{
		new Float: fOrigin[ 3 ], Float: fPlayerOrigin[ 3 ];
		new weapbox, bomb = fm_find_ent_by_class( -1, "weapon_c4" );
		
		if( bomb && ( weapbox = pev( bomb, pev_owner ) ) > get_maxplayers( ) ) 
		{
			entity_get_vector( weapbox, EV_VEC_origin, fOrigin );
			entity_get_vector( id, EV_VEC_origin, fPlayerOrigin );
			
			if( get_distance_f( fOrigin, fPlayerOrigin ) < get_pcvar_float( CvarDistance ) )
			{
				if( is_user_alive( id ) )
				{
					ScreenFade( id, 0.1, 0, 0, 0, 999999999999999999999 );  
					set_hudmessage( 250, 65, 65, -1.0, 0.20, 0, 1.0, 0.03 , 0.01 , 0.03, 3 );
					ShowSyncHudMsg( id, g_msg_event, "Si velmi blizko bomby!" );
				}
			}
		}
	}
}

stock is_entity_moving( entity )
{
	    if( !is_valid_ent( entity ) )
		return 0;
	
	    new Float:fVelocity[ 3 ];
	    entity_get_vector( entity, EV_VEC_velocity, fVelocity );
	    if( vector_length( fVelocity ) >= 30.0 )
		return 1;
	
	    return 0;
} 

public otazka_nesmrtelnost( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Nesmrtelnost?^n\y( kontrolna otazka )","nesmrtelnost_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public nesmrtelnost_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 28000;
			g_bRE[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tNesmrtelnost", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tNesmrtelnost", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_regeneracia( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Regeneracia?^n\y( kontrolna otazka )","regeneracia_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public regeneracia_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 22000;
			g_bREG[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tRegeneracia", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tRegeneracia", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_mrstnost( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Absolute Defense?^n\y( kontrolna otazka )","mrstnost_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public mrstnost_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 33000;
			g_bND[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tAbsolute Defense", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tAbsolute Defense", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_drtivestrely( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Drtive Strely?^n\y( kontrolna otazka )","drtive_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public drtive_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 10000;
			g_bDS[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tDrtive Strely", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tDrtive Strely", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_laser( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Laser?^n\y( kontrolna otazka )","laser_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public laser_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 20000;
			g_bLaser[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tLaser", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tLaser", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_bunnyhop( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: BunnyHop?^n\y( kontrolna otazka )","bunny_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public bunny_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 25000;
			g_bBH[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tBunnyHop", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tBunnyHop", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_multijump( id )
{
	new hm = menu_create( "\wNaozaj chces zakupit item: Multi Jump?^n\y( kontrolna otazka )","multijump_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public multijump_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 23000;
			g_bMJ[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tMulti Jump", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tMulti Jump", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public otazka_zmatenie( id )
{	
	new hm = menu_create( "\wNaozaj chces zakupit item: Epic Money?^n\y( kontrolna otazka )","zmatenie_menu_handle" );
	menu_additem( hm,"\rAno" );
	menu_additem( hm,"\yNie" );
	menu_display( id,hm );
}

public zmatenie_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			peniaze[ id ] -= 21000;
			g_bCO[ id ] = 1;
			cs_set_user_money( id,peniaze[ id ] );
			herne_menu( id );
			ChatColor( id, "%s !yZakupil si si item:!tEpic Money", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );
		}
		case 1:
		{
			herne_menu( id );
			client_cmd( id, "mp3 play /sound/bluezone/furien/no_act_item.mp3" );
			ChatColor( id, "%s !yNekupil si si item:!tEpic Money", prefix );
		}
		
	}
	return PLUGIN_HANDLED;
}

public FM_PreThink( id )
{
	new idAiming, iBodyPart;
	get_user_aiming( id, idAiming, iBodyPart );
	
	if( is_user_alive( idAiming ) && is_user_alive( id ) )
	{
		if( cs_get_user_team( id ) == CS_TEAM_CT && cs_get_user_team( idAiming ) == CS_TEAM_CT )
		{
			new message[ 200 ], szTarget[ 33 ], HP, money;
			get_user_name( idAiming, szTarget, charsmax( szTarget ) );
			HP = get_user_health( idAiming );
			money = cs_get_user_money( idAiming );
			
			//set_hudmessage( 84, 84, 84, -1.0, 0.33, 0, 0.1, 0.1, 0.1, 0.1, 3 );
			set_hudmessage( 84, 84, 84, -1.0, 0.33, 0, 1.0, 0.03 , 0.01 , 0.03, 3 );
			format( message, 199, "^n^n^n^n^n^n^n^n^n%s^nHP: %i / %i%% HP^nPeniaze: %i$^n*******^nHealth: %i / 30^nDefense: %i / 10^nDamage: %i / 20", szTarget, HP, g_maxHP[ idAiming ], money, g_unHPLevel[ idAiming ], g_unAPLevel[ idAiming ], g_unDMLevel[ idAiming ] );
			ShowSyncHudMsg( id, SyncHudObj3, message );
		}
		else if( cs_get_user_team( id ) == CS_TEAM_T && cs_get_user_team( idAiming ) == CS_TEAM_T )
		{
			new message[ 200 ], szTarget[ 33 ], HP, money;
			get_user_name( idAiming, szTarget, charsmax( szTarget ) );
			HP = get_user_health( idAiming );
			money = cs_get_user_money( idAiming );
		
			//set_hudmessage( 84, 84, 84, -1.0, 0.33, 0, 1.0, 0.03 , 0.01 , 0.03, 3 );
			set_hudmessage( 84, 84, 84, -1.0, 0.33, 0, 1.0, 0.03 , 0.01 , 0.03, 3 );
			format( message, 199, "^n^n^n^n^n^n^n^n^n%s^nHP: %i / %i%% HP^nPeniaze: %i$^n*******^nHealth: %i / 30^nDefense: %i / 10^nDamage: %i / 20", szTarget, HP, g_maxHP[ idAiming ], money, g_unHPLevel[ idAiming ], g_unAPLevel[ idAiming ], g_unDMLevel[ idAiming ] );
			ShowSyncHudMsg( id, SyncHudObj3, message );
		}    
	}
	return PLUGIN_HANDLED;
}

public fw_EvCurWeapon( id )
{
	if ( is_user_bot( id ) )
		return;
	
	if( !is_user_connected( id ) )
		return;
		
	if( g_shopRychlost[ id ] )
	{
		new iCurWeapon = read_data( 2 );
		if( iCurWeapon != g_iPrevCurWeapon[ id ] )
		{
			set_user_maxspeed( id , 500.0 );
			g_iPrevCurWeapon[ id ] = iCurWeapon;
		}
	}
}

public command_AdminMenu( id )
{
	if( !( get_user_flags( id ) & ADMIN_IMMUNITY ) )
	{
		ChatColor( id,"%L", LANG_PLAYER, "NO_OPEN" );
		return PLUGIN_HANDLED;
	}
	
	new g_hMenu = menu_create( "\yPridavanie Peniazi \r( \yAdmin Menu\r )^n\dKazde pridavanie peniazi sa zaznamenava do logu", "sub_adminmenu" );
	
	menu_additem( g_hMenu, "Pridat Peniaze^n\dTymto pridavate peniaze", "1", ADMIN_IMMUNITY );
	menu_additem( g_hMenu, "Zobrat Peniaze^n\dTymto odoberete peniaze^n", "2", ADMIN_IMMUNITY );
	menu_additem( g_hMenu, "Znovu nacitat adminov^n\wCode by adamCSzombie^n\dwww.Gamesites.cz", "3", ADMIN_IMMUNITY );
	
	menu_setprop( g_hMenu, MPROP_EXITNAME, "Zavriet" );
	menu_setprop( g_hMenu, MPROP_NUMBER_COLOR, "\r" );
	menu_display( id, g_hMenu, 0 );
	
	return PLUGIN_HANDLED;
}

public command_ListPlayer( id )
{
	g_iIdPlayer[ id ] = 0;
	
	new strMenuText[ 128 ], szNames[ 32 ], szTempid[ 10 ];
	new hChoosePlayer;
	if( g_bSendPoints )
		hChoosePlayer = menu_create( "\yPridat Peniaze:^n\dTymto pridate peniaze", "sub_listplayer" )
	else
		hChoosePlayer = menu_create( "\yZobrat Peniaze:^n\dTymto odoberete peniaze", "sub_listplayer" )
	
	new iPlayers[ 32 ], iNum;
	get_players( iPlayers, iNum );
	
	for( new i; i < iNum; i++ )
	{
		new TempId = iPlayers[ i ];
		
		if( !is_user_connected( TempId ) )
			continue;
		
		get_user_name( TempId, szNames, charsmax(szNames) );
		num_to_str( TempId, szTempid, 9 );
		if( cs_get_user_team( TempId ) == CS_TEAM_T )
		{
			formatex( strMenuText, charsmax( strMenuText ), "\r[Furien]\w %s prave ma \y%d\r$", szNames, peniaze[ TempId ] );
		}
		if( cs_get_user_team( TempId ) == CS_TEAM_CT )
		{
			formatex(strMenuText, charsmax( strMenuText ), "\y[Anti-Furien]\w %s prave ma \y%d\r$", szNames, peniaze[ TempId ] );
		}
		if( cs_get_user_team( TempId ) == CS_TEAM_SPECTATOR || cs_get_user_team( TempId ) == CS_TEAM_UNASSIGNED )
		{
			formatex( strMenuText, charsmax( strMenuText ), "\d[Divak]\w %s prave ma \y%d\r$", szNames, peniaze[ TempId ] );
		}
		menu_additem( hChoosePlayer, strMenuText, szTempid, 0 )
	}
	
	menu_setprop( hChoosePlayer, MPROP_BACKNAME, "Predchadzajuce" );
	menu_setprop( hChoosePlayer, MPROP_NEXTNAME, "Dalsie" );
	menu_setprop( hChoosePlayer, MPROP_EXITNAME, "Zavriet" );
	menu_setprop( hChoosePlayer, MPROP_EXIT, MEXIT_ALL );
	menu_display( id, hChoosePlayer );
	return PLUGIN_HANDLED;
}

public sub_adminmenu( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT || !(get_user_flags( id ) & ADMIN_BAN ) )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iKey = str_to_num( szData );
	
	switch( iKey )
	{
		case 1:
		{
			g_bSendPoints = true;
			command_ListPlayer( id );
		}
		case 2:
		{
			g_bSendPoints = false;
			command_ListPlayer( id );
		}
		case 3:
		{
			server_cmd( "amx_reloadadmins 1" );
			ChatColor( id,"%L", LANG_PLAYER, "RELOAD_ADMINS" );
			command_AdminMenu( id );
		}
	}
	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}

public sub_listplayer( id, hMenu, iItem )
{
	if( iItem == MENU_EXIT || !( get_user_flags(id) & ADMIN_BAN ) )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	
	new szData[ 6 ], iAccess2, hCallback;
	menu_item_getinfo( hMenu, iItem, iAccess2, szData, 5, _, _, hCallback );
	new iTempId = str_to_num( szData );
	
	g_iIdPlayer[ id ] = iTempId;
	client_cmd( id, "messagemode Ciastka" );
	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}

public command_SendPoints( id )
{
	new szSay[ 32 ];
	read_args( szSay, charsmax( szSay ) );
	remove_quotes( szSay );
	
	if( !is_str_num( szSay ) || equal( szSay, "" ) || !g_iIdPlayer[ id ] )
	{
		command_ListPlayer( id );
		return PLUGIN_HANDLED;
	}
	if( g_bSendPoints )
		SendPoints( id, szSay )
	else
		TakePoints( id, szSay )
	
	return PLUGIN_HANDLED;
}

public SendPoints( id, szSay[ ] )
{
	new iAmount = str_to_num( szSay );
	
	new iReciever = g_iIdPlayer[ id ];
	new szSender[ 32 ], szReciever[ 32 ];
	
	get_user_name( id, szSender, charsmax(szSender) );
	get_user_name( iReciever, szReciever, charsmax( szReciever ) );
	
	if( iAmount < 16000 )
		peniaze[ iReciever ] += iAmount
	else
		peniaze[ iReciever ] = 16000
	cs_set_user_money( iReciever, peniaze[ iReciever ] );
	
	switch( get_cvar_num( "amx_show_activity" ) )
	{
		case 1: client_print( 0, print_chat, "[Anti-Cheat]: dal %i $ hracovi %s", iAmount, szReciever );
			case 2: client_print( 0, print_chat, "[Anti-Cheat] Server dal %i $ hracovi %s", iAmount, szReciever );
		}
	
	command_AdminMenu( id );
}

public effekt_kill( id )
{
	if( get_user_team( id ) & 2 )
	{
		ScreenFade( id, 0.8, 24, 100, 112, 112 );
	}
	if( get_user_team( id ) & 1 )
	{
		ScreenFade( id, 1.0, 255, 42, 42, 100 );
	}
}

public TakePoints( id, szSay[ ] )
{
	new iAmount = str_to_num( szSay );
	
	new iReciever = g_iIdPlayer[ id ];
	new szSender[ 32 ], szReciever[ 32 ];
	
	get_user_name( id, szSender, charsmax( szSender ) );
	get_user_name( iReciever, szReciever, charsmax( szReciever ) );
	
	if( peniaze[ iReciever ] < iAmount )
		peniaze[ iReciever ] = 0
	else
		peniaze[ iReciever ] -= iAmount
	cs_set_user_money( iReciever, peniaze[ iReciever ] );
	
	switch( get_cvar_num( "amx_show_activity" ) )
	{
		case 1: client_print( 0, print_chat, "[Anti-Cheat]: zobral %i $ hracovi %s", iAmount, szReciever );
			case 2: client_print( 0, print_chat, "[Anti-Cheat] Server zobral %i $ hracovi %s", iAmount, szReciever );
		}
	
	command_AdminMenu( id );
}

public EmitSound( id, channel, sample[ ] )
{
	if( is_user_alive( id ) )
	{
		static CsTeams:team; team = cs_get_user_team( id );
		
		switch( team )
		{
			case CS_TEAM_T:
			{
				if( superknife[ id ] )
				{
					for( new i = 0; i < sizeof SKSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, SKSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopAxe[ id ] )
				{
					for( new i = 0; i < sizeof AxeSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, AxeSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopBloody[ id ] )
				{
					for( new i = 0; i < sizeof BloodSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, BloodSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopIce[ id ] )
				{
					for( new i = 0; i < sizeof IceSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, IceSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				
				if( g_shopArmy[ id ] )
				{
					for( new i = 0; i < sizeof USSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, USSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopAssasin[ id ] )
				{
					for( new i = 0; i < sizeof AsaSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, AsaSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopDragon[ id ] )
				{
					for( new i = 0; i < sizeof DraSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, DraSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
				if( g_shopCrowBar[ id ] )
				{
					for( new i = 0; i < sizeof CrowSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, CrowSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
			}
			case CS_TEAM_CT:
			{
				if( superknife[ id ] )
				{
					for( new i = 0; i < sizeof SKSounds; i++ )
					{
						if( equal( sample, oldknife_sounds[ i ] ) )
						{
							emit_sound( id, channel, SKSounds[ i ], 1.0, ATTN_NORM, 0, PITCH_NORM );
							return FMRES_SUPERCEDE;
						}
					}
				}
			}
		}
	}
	return FMRES_IGNORED;
}

public AdminMenu( id )
{
	new hm = menu_create( "Admin Menu \d[ \y1 \w/ \r2 \d]","admin_menu_handle" );
	menu_additem( hm,"\y[\rADMIN\y] \wZabanovat hraca" );
	menu_additem( hm,"\y[\rADMIN\y] \wVykopnut hraca" );
	menu_additem( hm,"\y[\rADMIN\y] \wSlap/Slaynut hraca" );
	menu_additem( hm,"\y[\rADMIN\y] \wBAN List" );
	menu_additem( hm,"\y[\rADMIN\y] \wWeb Forum" );
	menu_additem( hm,"Dalsia Strana \d[ \r2 \w/ \r2 \d]^n" );
	menu_additem( hm,"Zpet do herneho menu" );
	menu_display( id,hm );
}

public admin_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			client_cmd( id, "amx_banmenu" );
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			client_cmd( id, "amx_kickmenu" );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			client_cmd( id, "amx_slapmenu" );
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id,"http://amxbans_8195.gsp-europe.net/ban_list.php" );
		}
		case 4:
		{	
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_motd( id,"http://Gamesites.cz/forum.php" );
		}
		case 5:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			AdminMenu2( id );
		}
		case 6:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public AdminMenu2( id )
{
	new hm = menu_create( "Admin Menu \d[ \r2\w/ \r2 \d]","admin_menu_handle2" );
	menu_additem( hm,"\y[\rHLSA\y] \wPridavanie/odoberanie $" );
	menu_additem( hm,"\y[\rVEDENIE\y] \wAnti-Cheat" );
	menu_additem( hm,"\y[\rVEDENIE\y] \wZabavne Kola" );
	menu_additem( hm,"\y[\rVEDENIE\y] \wKonfiguracia serveru^n" );
	menu_additem( hm,"Zpet na stranu \d[ \y1 \w/ \r2 \d]" );
	menu_display( id,hm );
}

public admin_menu_handle2( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			if( get_user_flags( id ) & ADMIN_IMMUNITY )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				command_AdminMenu( id );
			}
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ChatColor( id, "Nemas dostatocne prava!" );
			//client_cmd( id, "say /adminmenu" );
		}
		case 2:
		{
			if( get_user_flags( id ) & ADMIN_IMMUNITY )
			{
				if( g_event_drop != 1 )
				{
					event_start( id );
				} else {
					ChatColor( id, "!gUz je aktivovany event!" );
				}
			} else {
				ChatColor( id, "Nemas dostatocne prava!" );
				AdminMenu2( id );
			}
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ChatColor( id, "Nemas dostatocne prava!" );
			AdminMenu2( id );
		}
		case 4:
		{	
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			ChatColor( id, "Nemas dostatocne prava!" );
			AdminMenu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public AddToFullPack( es_handle, e, ent, host, hostflags, player, pSet )
{
	if( !is_user_connected( host ) || !is_user_connected( ent ) || !is_user_alive( host ) || !is_user_alive( ent ) )
		return FMRES_IGNORED;
		
	if( !is_entity_moving( ent ) )
	{	
		if( player )
		{
			if( g_round_aktualne == 1 )
			{
				static CsTeams:team; team = cs_get_user_team( ent );
				static CsTeams:teamhost; teamhost = cs_get_user_team( host );
					
				if( team == CS_TEAM_T && team == teamhost )
				{
					new Float: punishPercentage = 1.0;
					new duration = ( punishPercentage == 1.0 ) ? FADE_LENGTH_PERM : 1<<12;
					new holdTime = ( punishPercentage == 1.0 ) ? FADE_LENGTH_PERM : 1<<8;
					new fadeType = ( punishPercentage == 1.0 ) ? FADE_HOLD : FADE_IN;
			    
					message_begin( MSG_ONE, g_msgFade, { 0,0,0 }, ent );
					write_short( duration );
					write_short( holdTime );
					write_short( fadeType );
					write_byte( 0 );
					write_byte( 0 );
					write_byte( 0 );
					write_byte( 100 );
					message_end( );
					set_es( es_handle, ES_RenderFx, kRenderFxDistort );
					set_es( es_handle, ES_RenderColor, { 0, 0, 0 } );
					set_es( es_handle, ES_RenderMode, kRenderTransAdd );
					set_es( es_handle, ES_RenderAmt, 127 );
				}
			}
		}
	} else {
		if( cs_get_user_team( ent ) == CS_TEAM_T )
		{
			punish_blind_stop( ent );
		}
	}
	return FMRES_IGNORED;
}
public punish_blind_stop( id )
{
	    message_begin( MSG_ONE, g_msgFade, { 0,0,0 }, id ); 
	    write_short( 0 ); 
	    write_short( 1<<8 ); 
	    write_short( FADE_OUT ); 
	    write_byte( 0 ); 
	    write_byte( 0 );  
	    write_byte( 0 );      
	    write_byte( 255 );     
	    message_end( );    
}  

public ClCmd_ToggleCamera( id ) 
{ 
	if( !is_user_alive( id ) ) 
	{ 
		return;
	} 
	
	new iEnt = g_iPlayerCamera[ id ] 
	if( !pev_valid( iEnt ) ) 
	{ 
		static iszTriggerCamera;
		if( !iszTriggerCamera ) 
		{ 
			iszTriggerCamera = engfunc( EngFunc_AllocString, "trigger_camera" ); 
		} 
		iEnt = engfunc( EngFunc_CreateNamedEntity, iszTriggerCamera );
		set_kvd( 0, KV_ClassName, "trigger_camera" ); 
		set_kvd( 0, KV_fHandled, 0 );
		set_kvd( 0, KV_KeyName, "wait" ); 
		set_kvd( 0, KV_Value, "999999" ); 
		dllfunc( DLLFunc_KeyValue, iEnt, 0 ); 
		
		set_pev( iEnt, pev_spawnflags, SF_CAMERA_PLAYER_TARGET|SF_CAMERA_PLAYER_POSITION ); 
		set_pev( iEnt, pev_flags, pev(iEnt, pev_flags) | FL_ALWAYSTHINK );
		
		dllfunc( DLLFunc_Spawn, iEnt ); 
		
		g_iPlayerCamera[ id ] = iEnt;
	} 
	
	ToggleUserCameraState( id ) 
	CheckForward( );
	
	new Float:flMaxSpeed, iFlags = pev( id, pev_flags );
	pev( id, pev_maxspeed, flMaxSpeed ); 
	
	ExecuteHam( Ham_Use, iEnt, id, id, USE_TOGGLE, 1.0 ); 
	
	set_pev( id, pev_flags, iFlags );
	set_pev( id, pev_maxspeed, flMaxSpeed ); 
} 

public SetView( id, iEnt ) 
{ 
	if( IsUserInCamera( id ) && is_user_alive( id ) ) 
	{ 
		new iCamera = g_iPlayerCamera[ id ] 
		if( iCamera && iEnt != iCamera ) 
		{ 
			new szClassName[ 16 ];
			pev( iEnt, pev_classname, szClassName, charsmax( szClassName ) ) 
			if( !equal( szClassName, "trigger_camera" ) )
			{ 
				engfunc( EngFunc_SetView, id, iCamera );
				return FMRES_SUPERCEDE;
			} 
		} 
	} 
	return FMRES_IGNORED; 
} 

get_cam_owner( iEnt ) 
{ 
	static id; 
	for( id = 1; id<= maxplayers ; id++ ) 
	{ 
		if( g_iPlayerCamera[ id ] == iEnt ) 
		{ 
			return id;
		} 
	} 
	return 0; 
}

public Camera_Think( iEnt ) 
{ 
	static id; 
	if( !(id = get_cam_owner( iEnt )) ) 
	{ 
		return; 
	} 
	
	static Float:fVecPlayerOrigin[ 3 ], Float:fVecCameraOrigin[ 3 ], Float:fVecAngles[ 3 ], Float:fVecBack[ 3 ]; 
	
	pev( id, pev_origin, fVecPlayerOrigin ); 
	pev( id, pev_view_ofs, fVecAngles ); 
	fVecPlayerOrigin[ 2 ] += fVecAngles[ 2 ]; 
	
	pev( id, pev_v_angle, fVecAngles ); 
	
	angle_vector( fVecAngles, ANGLEVECTOR_FORWARD, fVecBack ); 
	
	fVecCameraOrigin[ 0 ] = fVecPlayerOrigin[ 0 ] + ( -fVecBack[ 0 ] * 150.0 ); 
	fVecCameraOrigin[ 1 ] = fVecPlayerOrigin[ 1 ] + ( -fVecBack[ 1 ] * 150.0 ); 
	fVecCameraOrigin[ 2 ] = fVecPlayerOrigin[ 2 ] + ( -fVecBack[ 2 ] * 150.0 ); 
	
	engfunc( EngFunc_TraceLine, fVecPlayerOrigin, fVecCameraOrigin, IGNORE_MONSTERS, id, 0 ); 
	static Float:flFraction; 
	get_tr2( 0, TR_flFraction, flFraction ); 
	if( flFraction != 1.0 ) 
	{ 
		flFraction *= 150.0; 
		fVecCameraOrigin[ 0 ] = fVecPlayerOrigin[ 0 ] + ( -fVecBack[ 0 ] * flFraction ); 
		fVecCameraOrigin[ 1 ] = fVecPlayerOrigin[ 1 ] + ( -fVecBack[ 1 ] * flFraction ); 
		fVecCameraOrigin[ 2 ] = fVecPlayerOrigin[ 2 ] + ( -fVecBack[ 2 ] * flFraction ); 
	} 
	
	set_pev( iEnt, pev_origin, fVecCameraOrigin ); 
	set_pev( iEnt, pev_angles, fVecAngles );
} 

CheckForward( ) 
{
	static HamHook:iHhCameraThink, iFhSetView; 
	if( g_bInCamera ) 
	{ 
		if( !iFhSetView ) 
		{ 
			iFhSetView = register_forward( FM_SetView, "SetView" ); 
		} 
		if( !iHhCameraThink ) 
		{ 
			iHhCameraThink = RegisterHam( Ham_Think, "trigger_camera", "Camera_Think" ); 
		} 
		else 
		{ 
			EnableHamForward( iHhCameraThink ); 
		} 
	} 
	else 
	{ 
		if( iFhSetView ) 
		{ 
			unregister_forward( FM_SetView, iFhSetView ); 
			iFhSetView = 0;
		} 
		if( iHhCameraThink ) 
		{ 
			DisableHamForward( iHhCameraThink ); 
		} 
	} 
}  

public ev_RoundStart( )
{
	g_bCanPlant = false;
	remove_task( TASK_CANPLANT );

	new Float: flTime = get_cvar_num( "mp_freezetime" ) + ( get_cvar_num( "mp_roundtime" )*60 ) - 96.0;
	set_task( flTime, "task_CanPlant", TASK_CANPLANT );  
}

public ham_PrimaryAttack_C4( iEnt )
{
	new id = pev( iEnt, pev_owner );
	
	if( !g_bCanPlant )
	{
		set_hudmessage( 84, 84, 84, -1.0, 0.33, 0, 1.0, 1.0 ); 
		ShowSyncHudMsg( id, SyncHudObj4, "Bombu mozes platnut v 1:40!");  
		return HAM_SUPERCEDE;  
	}
	
	return HAM_IGNORED;  
}

public task_CanPlant( )  
{
	g_bCanPlant = true; 
}

public ShowHUD( taskid )
{
	static id;
	id = ID_SHOWHUD;
	
	// Player died?
	if( !g_isalive[ id ] )
	{
		// Get spectating target
		id = pev( id, PEV_SPEC_TARGET );
		
		// Target not alive
		if( !g_isalive[ id ] ) return;
	}
	
	// Format classname
	static red, green, blue;
	new item[ 64 ];
	
	if( get_user_team( id ) == 1 ) // furieni
	{
		red = 160
		green = 96
		blue = 96
		
	}
	else // Anti-Furieni
	{
		red = 50
		green = 150
		blue = 250
	}
	
	// Spectating someone else?
	if( id != ID_SHOWHUD )
	{
		// Niè
	}
	else
	{
		if( g_bActived_Regen[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 1 ] );
			}
			else if( g_bActived_NoDamage[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 2 ] );
			}
			else if( g_bActived_DoubleJump[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 3 ] );
			}
			else if( g_bActived_Nesmrtelnost[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 4 ] );
			}
			else if( g_bActived_BunnyHop[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 5 ] );
			}
			else if( g_bActived_Immobilize[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 6 ] );
			}
			else if( g_bActived_Epicmoney[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 7 ] );
			}
			else if( g_bActived_Laser[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 8 ] );
			}
			else if( !g_bActived_Regen[ id ] || !g_bActived_NoDamage[ id ] || !g_bActived_DoubleJump[ id ] || !g_bActived_Nesmrtelnost[ id ] || !g_bActived_BunnyHop[ id ] || !g_bActived_Immobilize[ id ] || !g_bActived_Epicmoney[ id ]  || !g_bActived_Laser[ id ] )
			{
				formatex( item, charsmax( item ), Itemy[ 0 ] );
			}
			// Show health, class and ammo packs
		if( is_user_alive( id ) )
		{
			set_hudmessage( red, green, blue, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0, -1 );
			ShowSyncHudMsg( ID_SHOWHUD, SyncHudObj5, "HP %i / %i%% | %i $ | %i EXP | %s ", get_user_health( id ), g_maxHP[ id ], peniaze[ id ], exp[ id ], item )
		}
	}
}

public endRound( )
{
	g_c4timer = -1;
	remove_task( 652450 );
}
 
public bomb_explode( )
{
	if( b_planted )
	{
		remove_task( 652450 );
		b_planted = false;
	}
}
 
public dispTime(  )
{   
	if( !b_planted )
	{
		remove_task( 652450 );
		return;
	}
        
 
	if( g_c4timer >= 0 )
	{
		if( g_c4timer > 13 ) set_dhudmessage( 93, 93, 93, -1.0, 0.80, 0, 0.1, 0.1 ) 
		else if( g_c4timer > 7 ) set_dhudmessage( 93, 93, 93, -1.0, 0.80, 0, 0.1, 0.1 ) 
		else set_dhudmessage( 93, 93, 93, -1.0, 0.80, 0, 0.1, 0.1 );
		
		show_dhudmessage( 0, "Bomba vybuchne za^n %d sekund", g_c4timer );
 
		--g_c4timer;
	}
} 

public fw_ClientUserInfoChanged( id, infobuffer )
{   
	if ( !g_model[ id ] )
		return FMRES_IGNORED;
	
	new currentmodel[ 32 ]; 
	fm_get_user_model( id, currentmodel, sizeof currentmodel - 1 );
	
	if( !equal( currentmodel, player_model[ id ] ) )
		fm_set_user_model( id, player_model[ id ] ) 
	
	return FMRES_IGNORED;
}

stock fm_set_user_model( player, modelname[ ] )
{   
	engfunc( EngFunc_SetClientKeyValue, player, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", modelname )
	
	g_model[ player ] = true;
}

stock fm_get_user_model( player, model[ ], len )
{   
	engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len )
}

stock fm_reset_user_model( player )
{         
	g_model[ player ] = false;
	
	dllfunc( DLLFunc_ClientUserInfoChanged, player, engfunc( EngFunc_GetInfoKeyBuffer, player ) )
}	

public fw_SetClientKeyValue( id, infobuffer, key[ ], value[ ] )
{   
	if ( g_model[ id ] && equal( key, "model" ) )
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

public case_someone_get( id )
{
	set_hudmessage( 255, 127, 0, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1 );
	ShowSyncHudMsg( 0, SyncHudObj2, "Niekto ziskal Truhlu itemov!!" );
	client_cmd( id, "mp3 play /sound/bz_furien_mod/join.mp3" );
	case_of_items( id );
	new i;
	for( i = 0; i < 5; i++ )
	{
		ChatColor( 0, "!g***!tNiekto ziskal Truhlu itemov!!!g***" );
	}
}
public case_of_items( id )
{
	client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
	new hm = menu_create( "\yTruhla Itemov^n\wZISKAL SI TRUHLU ITEMOV!","case_of_items_handle" );
	menu_additem( hm,"Otvorit Truhlu^n\d Po otvoreny ziskate nahodny item!" );
	menu_additem( hm,"Predat Truhlu^n\d Dostanete +10000$^n\wPokial otvoris item ktory vlastnis nic neziskas!" );
	menu_display( id,hm );
}
public case_of_items_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			nahodny_item( id );
			client_cmd( id, "spk valve/sound/buttons/blip2" );
		}
		case 1:
		{
			peniaze[ id ] += 10000;
			cs_set_user_money( id, peniaze[ id ] );
			client_cmd( id, "spk valve/sound/buttons/button2" );
		}
		
	}
	return PLUGIN_HANDLED;
}

public nahodny_item( id )
{
	new random = random_num( 1, 2 );
	if( random == 1 )
	{
		if( !g_bREG[ id ] )
		{
			g_bREG[ id ] = 1;
			ChatColor( id, "%s !yZiskal si item:!tRegeneracia", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );	
		} else {
			ChatColor( id, "!gJe nam to luto.. Ziskal si item:!tRegeneracia!g. Tento item uz vlastnis!" );
		}
	}
	if( random == 2 )
	{
		if( !g_bDS[ id ] )
		{
			g_bDS[ id ] = 1;
			ChatColor( id, "%s !yZiskal si item:!tDrtive Strely", prefix );
			client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" );	
		} else {
			ChatColor( id, "!gJe nam to luto.. Ziskal si item:!tDrtive Strely!g. Tento item uz vlastnis!" );
		}
	}
}

public handle_say( id ) 
{
	new said[ 64 ], vysledokstring[ 64 ];
	read_argv( 1,said,charsmax( said ) )
	num_to_str( vysledok,vysledokstring,63 );
	
	if( !is_str_num( said ) )
		return PLUGIN_CONTINUE;
	if( !g_priklady[ id ] )
		return PLUGIN_CONTINUE;
	
	if( !prebieha_otazka ) 
	{
		ChatColor( id,"!g[Gamesites.cz] !yVysledok uz uhadol hrac !t%s!y, pockaj si na dalsi priklad!",g_LastWinner );
		return PLUGIN_CONTINUE;
	}
	
	if( equali( said,vysledokstring ) ) 
	{
		get_user_name( id, g_LastWinner, 31 );
		ChatColor( 0, "!g[Gamesites.cz] !yHrac !t%s !gvyriesil priklad a vyhrava !t25$!y a !t35 EXP!y! Vysledok: !t%d", g_LastWinner, vysledok );
		peniaze[ id ] += 25;
		exp[ id ] += 35;
		g_pocetprikladov[ id ] += 1;
		cs_set_user_money( id, peniaze[ id ] );
		prebieha_otazka = 0;
	} 
	else 
	{
		ChatColor( id, "!g[Gamesites.cz] !yZly vysledok!" );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE
}

public Priklad( ) 
{
	new cislo1, cislo2, znamienko;
	prebieha_otazka = 1;
	cislo1 = random_num( 20, 32 );
	cislo2 = random_num( 9, 19 );
	znamienko = random_num( 1, 2 );
	
	switch( znamienko ) 
	{
		case 1: 
		{
			vysledok = cislo1 + cislo2;
			ChatColor( 0, "!g[Gamesites.cz] !yKolko je !t%i + %i !y? Spravna odpoved ziska !t25$!y a !t35 EXP !y.", cislo1, cislo2 );
		}
		case 2: {
			vysledok = cislo1 - cislo2;
			ChatColor( 0, "!t[Gamesites.cz] !yKolko je !t%i - %i !y? Spravna odpoved ziska !t25$!y a !t35 EXP !y.", cislo1, cislo2 );
		}
	}
	return PLUGIN_HANDLED;
}

public show_upgrades_menu( id )
{
	new szMenuBody[ 501 ];
	
	g_pHPCost[ id ] = get_pcvar_num( g_pcvar_unhpcost ) + ( get_pcvar_num( g_pcvar_unhpmult ) * g_unHPLevel[ id ] );
	g_pAPCost[ id ] = get_pcvar_num( g_pcvar_unapcost ) + ( get_pcvar_num( g_pcvar_unapmult ) * g_unAPLevel[ id ] );
	g_pDMCost[ id ] = get_pcvar_num( g_pcvar_undmcost ) + ( get_pcvar_num( g_pcvar_undmmult ) * g_unDMLevel[ id ] );
	
	new nLen = format( szMenuBody, 561, "\yVylepsenia ktore zostavaju i po odpojeni sa z hry!^n\dAktualne mas \r%d\d EXP^n", exp[ id ] );
	nLen += format( szMenuBody[ nLen ], 502-nLen, "^n\y1. \wHealth \d[ \r1 Level \w= \r+1 %% \d]");
	if( g_unHPLevel[ id ] != 30 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wAktualny Level >> \y %d \w/ \r30", g_unHPLevel[ id ] );
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wAktualny Level >> \r30 \w/ \r30" );
	if( g_unHPLevel[ id ] != 30 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wCena >> \d[ \r%d EXP \d]^n", g_pHPCost[ id ] );
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wCena >> \d[ \r0 EXP \d]^n" );
	/*-------------------------------------------------------------------------------------------------------------*/
	nLen += format( szMenuBody[ nLen ], 502-nLen, "^n\y2. \y[VIP] \wDefense \d[ \rAnti-Furien \d] \d[ \r1 Level \w= \r+4 %% \d]");
	if( g_unAPLevel[ id ] != 10 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wAktualny Level >> \y %d \w/ \r10", g_unAPLevel[ id ] );
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wAktualny Level >> \r 10 \w/ \r10" );
	if( g_unAPLevel[ id ] != 10 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wCena >> \d[ \r%d EXP \d]^n", g_pAPCost[ id ] ); 
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n    \wCena >> \d[ \r0 EXP \d]^n" ); 
	/*-------------------------------------------------------------------------------------------------------------*/
	nLen += format( szMenuBody[ nLen ], 502-nLen, "^n\y3. \y[ExtraVIP] \wDamage \d[ \r1 Level \w= \r+1 %% \d]");
	if( g_unDMLevel[ id ] != 20 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n     \wAktualny Level >> \y %d \w/ \r20", g_unDMLevel[ id ] );
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n     \wAktualny Level >> \r 20 \w/ \r20" );
	if( g_unDMLevel[ id ] != 20 )
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n     \wCena >> \d[ \r%d EXP \d]^n", g_pDMCost[ id ] );
	else
		nLen += format( szMenuBody[ nLen ], 502-nLen, "^n     \wCena >> \d[ \r0 EXP \d]^n", g_pDMCost[ id ] );
	nLen += format( szMenuBody[ nLen ], 502-nLen, "^n\y0. \wZavriet" );
	
	show_menu( id, UPGRADES_KEYS, szMenuBody, -1, "UpgradesMenuMain" );
}

public upgrades_menu_pressed( id,key )
{
	switch( key )
	{
		case 0:
		{
			if( g_unHPLevel[ id ] != 30 )
			{
				if( ( exp[ id ] >= g_pHPCost[ id ] ) && g_unHPLevel[ id ] < 30 )
				{
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
					client_cmd( id, "spk valve/sound/weapons/gren_cock1" );
					g_unHPLevel[ id ]++;
					exp[ id ] -= g_pHPCost[ id ];
				}
				else
				{
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id, "!gNemas dostatok EXP!" );
				}
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!gNemozes uz viac upgradovat tento slot!" );
			}
			show_upgrades_menu( id );
		}
		case 1:
		{
			if( get_user_flags( id ) & VIP )
			{
				if( g_unAPLevel[ id ] != 10 )
				{
					if( ( exp[ id ] >= g_pAPCost[ id ] ) && g_unAPLevel[ id ] < 10 )
					{
						ScreenFade( id, 0.5, 255, 212, 42, 100 );
						client_cmd( id, "spk valve/sound/weapons/gren_cock1" );
						g_unAPLevel[ id ]++;
						exp[ id ] -= g_pAPCost[ id ];
					}
					else
					{
						ScreenFade( id, 1.0, 255, 0, 0, 100 );
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id, "!gNemas dostatok EXP!" );
					}
				}
				else
				{
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id, "!gNemozes uz viac upgradovat tento slot!" );
				}
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!gAby si si mohol vylepsit Defense potrebujes mat !tVIP!g!" );
			}
			show_upgrades_menu( id );
		}
		case 2:
		{
			if( get_user_flags( id ) & EVIP )
			{
				if( g_unDMLevel[ id ] != 20 )
				{
					if( ( exp[ id ] >= g_pDMCost[ id ] ) && g_unDMLevel[ id ] < 20 )
					{
						ScreenFade( id, 0.5, 255, 212, 42, 100 );
						client_cmd( id, "spk valve/sound/weapons/gren_cock1" );
						g_unDMLevel[ id ]++;
						exp[ id ] -= g_pDMCost[ id ];
					}
					else
					{
						ScreenFade( id, 1.0, 255, 0, 0, 100 );
						client_cmd( id, "spk valve/sound/buttons/button11" );
						ChatColor( id, "!gNemas dostatok EXP!" );
					}
				}
				else
				{
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id, "!gNemozes uz viac upgradovat tento slot!" );
				}
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!gAby si si mohol vylepsit Damage potrebujes mat !tExtraVIP!g!" );
			}
			show_upgrades_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public epic_menu( id )
{
	new stats[ 8 ], body[ 8 ];
	new rank_pos = get_user_stats( id, stats, body );
	
	new hm = menu_create( "Epic Menu \d( \rBETA \d)^n\d- Nove specialne menu!", "epic_menu_handle" );
	if( rank_pos < 500 )
		menu_additem( hm, "Vylepsenia" );
	else
		menu_additem( hm, "\r[ZAMKNUTE]\w Vylepsenia" );
	menu_additem( hm, "\yEpic Vylepsenia" );
	if( rank_pos < 100 )
		menu_additem( hm, "Cierny Trh!" );
	else
		menu_additem( hm, "\r[ZAMKNUTE]\w Cierny Trh" );
	menu_additem( hm, "Odmeny" );
	menu_display( id,hm );
}

public epic_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	new stats[ 8 ], body[ 8 ];
	new rank_pos = get_user_stats( id, stats, body );
	new rank_XD = rank_pos - 100;
	new rank_XDD = rank_pos - 500;
	
	switch( item )
	{
		case 0:
		{	
			if( rank_pos < 500 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				show_upgrades_menu( id );
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/misc/talk" );
				ChatColor( id, "!gAby si mohol vyuzivat vylepsenia musis byt vyssi rank nez 500!" );
				ChatColor( id, "!gEste potrebujes prejst %d rankov hore!", rank_XDD );
				herne_menu( id );
			}
		}
		case 1:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			client_cmd( id, "say /inventar" );	
		}
		case 2:
		{
			if( rank_pos < 100 )
			{
				client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
				cierny_trh( id );
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/misc/talk" );
				ChatColor( id, "!gAby si mohol vyuzivat cierny trh musis byt vyssi rank nez 100!" );
				ChatColor( id, "!gEste potrebujes prejst %d rankov hore!", rank_XD );
				herne_menu( id );
			}
		}
		case 3:
		{
			client_cmd( id, "spk bz_furien_mod/menu_p.wav" );
			show_odmeny_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public cierny_trh( id )
{
	new hm = menu_create( "Cierny Trh^n\d** LIMITOVANE ZLAVY TENTO TYZDEN! **", "cierny_trh_handle" );
	menu_additem( hm, "Item: \yAbsolute Defense \d[ZLAVA 30%] \wCena: \r23100$ " );
	menu_additem( hm, "Item: \yRegeneracia \d[ZLAVA 25%] \wCena: \r16500$" );
	menu_additem( hm, "\dSlot Vypredany - Prid o tyzden znova!" );
	menu_additem( hm, "\dSlot Vypredany - Prid o tyzden znova!" );
	menu_display( id,hm );
}

public cierny_trh_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			if( g_bND[ id ] != 1 )
			{
				if( peniaze[ id ] >= 23100 )
				{
					peniaze[ id ] -= 23100;
					g_bND[ id ] = 1;
					cs_set_user_money( id,peniaze[ id ] );
					cierny_trh( id );
					ChatColor( id, "%s !yZakupil si si item:!tAbsolute Defense", prefix );
					client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" )
				}
				else
				{
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id, "!gNemas dostatok prostriedkov!" );
					cierny_trh( id );
				}
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!gUz mas tento item zakupeny!" );
				cierny_trh( id );
			}
			
		}
		case 1:
		{
			if( g_bREG[ id ] != 1 )
			{
				if( peniaze[ id ] >= 16500 )
				{
					peniaze[ id ] -= 16500;
					g_bREG[ id ] = 1;
					cs_set_user_money( id,peniaze[ id ] );
					cierny_trh( id );
					ChatColor( id, "%s !yZakupil si si item:!tRegeneracia", prefix );
					client_cmd( id, "mp3 play /sound/bluezone/furien/item_aktivacia.mp3" )
				}
				else
				{
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					ChatColor( id, "!gNemas dostatok prostriedkov!" );
					cierny_trh( id );
				}
			}
			else
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				ChatColor( id, "!gUz mas tento item zakupeny!" );
				cierny_trh( id );
			}
				
		}
		case 2:
		{
			ScreenFade( id, 1.0, 255, 0, 0, 100 );
			ChatColor( id, "!gJe nam to luto, ale tento slot je uz vypredany!" );
			client_cmd( id, "spk valve/sound/buttons/button11" );
			cierny_trh( id );
		}
		case 3:
		{
			ScreenFade( id, 1.0, 255, 0, 0, 100 );
			ChatColor( id, "!gJe nam to luto, ale tento slot je uz vypredany!" );
			client_cmd( id, "spk valve/sound/buttons/button11" );
			cierny_trh( id );
		}
	}
	return PLUGIN_HANDLED;
}

public show_odmeny_menu( id )
{
	new szText1[ 555 char ], szText2[ 555 char ], szText3[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\d[ \r%d \w/ \r100 \d] \wPocet odohranych kol^n\yOdmena \w>> \r1000$ \wa \r250 EXP^n", g_pocetodohranych[ id ]  );
	formatex( szText2, charsmax( szText2 ), "\d[ \r%d \w/ \r10 \d] \wPocet odohranych Fun kol^n\yOdmena \w>> \r2000$ \wa \r500 EXP^n", g_pocetfunkol[ id ] );
	formatex( szText3, charsmax( szText3 ), "\d[ \r%d \w/ \r10 \d] \wPocet vypocitanych prikladov^n\yOdmena \w>> \r550$ \wa \r200 EXP^n^n\d- Pripravujeme nove odmeny aj s Steam klucmi!", g_pocetprikladov[ id ] );
	new hm = menu_create( "Odmeny^n\d- Dufame ze si uzivas nas server naplno!", "odmeny_menu_handle" );
	if( g_pocetodohranych[ id ] > 99 )
		menu_additem( hm, "\d[ \r100 \w/ \r100 \d] \wPocet odohranych kol^n\y>> ODOMKNUT ODMENU! <<^n" );
	else
		menu_additem( hm, szText1 );
	if( g_pocetfunkol[ id ] > 9 )
		menu_additem( hm, "\d[ \r10 \w/ \r10 \d] \wPocet odohranych Fun kol^n\y>> ODOMKNUT ODMENU! <<^n" );
	else
		menu_additem( hm, szText2 );
	if( g_pocetprikladov[ id ] > 9 )
		menu_additem( hm, "\d[ \r10 \w/ \r10 \d] \wPocet vypocitanych prikladov^n\y>> ODOMKNUT ODMENU! <<^n" );
	else
		menu_additem( hm, szText3 );
	menu_display( id,hm );
}

public odmeny_menu_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			if( g_pocetodohranych[ id ] > 99 )
			{
				ChatColor( id, "!gDakujeme ze hrajes na nasich serveroch! Odmena bola odomknuta!" );
				g_pocetodohranych[ id ] = 0;
				peniaze[ id ] += 1000;
				cs_set_user_money( id,peniaze[ id ] );
				exp[ id ] += 250;
				show_odmeny_menu( id );
			}
			else 
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				ChatColor( id, "!gNemas dostatok odohranych kol na odomknutie odmeny!" );
				client_cmd( id, "spk valve/sound/weapons/cbar_hit2" );
				show_odmeny_menu( id );
			}
		}
		case 1:
		{
			if( g_pocetfunkol[ id ] > 9 )
			{
				ChatColor( id, "!gDakujeme ze hrajes na nasich serveroch! Odmena bola odomknuta!" );
				g_pocetfunkol[ id ] = 0;
				peniaze[ id ] += 2000;
				cs_set_user_money( id,peniaze[ id ] );
				exp[ id ] += 500;
				show_odmeny_menu( id );
			}
			else 
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				ChatColor( id, "!gNemas dostatok odohranych Fun kol na odomknutie odmeny!" );
				client_cmd( id, "spk valve/sound/weapons/cbar_hit2" );
				show_odmeny_menu( id );
			}
		}
		case 2:
		{
			if( g_pocetprikladov[ id ] > 9 )
			{
				ChatColor( id, "!gDakujeme ze hrajes na nasich serveroch! Odmena bola odomknuta!" );
				g_pocetprikladov[ id ] = 0;
				peniaze[ id ] += 550;
				cs_set_user_money( id,peniaze[ id ] );
				exp[ id ] += 200;
				show_odmeny_menu( id );
			}
			else 
			{
				ScreenFade( id, 1.0, 255, 0, 0, 100 );
				ChatColor( id, "!gNemas dostatok vypocitanych prikladov na odomknutie odmeny!" );
				client_cmd( id, "spk valve/sound/weapons/cbar_hit2" );
				show_odmeny_menu( id );
			}
		}
	}
	return PLUGIN_HANDLED;
}

public starter_pack( id )
{
	if( g_startpack[ id ] == 0 )
	{
		new hm = menu_create( "Ako novy hrac si mozes vybrat zaciatocne odmeny^nktore by ti mali pomoct presadit sa!", "starter_handle" );
		menu_additem( hm, "\r200$ \wa \y[ExtraVIP]\w Ulti Knife \d( jedna mapa )" );
		menu_additem( hm, "\r100 EXP \wa \y[ExtraVIP]\w Dragon Knife \d( jedna mapa )" );
		menu_additem( hm, "\r1 Level vylepsenia na Health \wa \r100$" );
		menu_additem( hm, "\r5 Levely vylepsenia na Health" );
		menu_display( id,hm );
	}
}

public starter_handle( id,menu,item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			g_startpack[ id ]++;
			peniaze[ id ] += 200;
			ChatColor( id, "!gPrajeme prijemnu hru! Gamesites.cz Team" );
			userknife[ id ] = 8;
			new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
			if( pev_valid( weapon_ent ) )
			replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
			ham_strip_weapon( id, "weapon_knife" );
			give_item( id,"weapon_knife" );
			g_shopDefault[ id ] = false;
			g_shopAxe[ id ] = false;
			g_shopAssasin[ id ] = false;
			g_shopBloody[ id ] = false;
			g_shopCrowBar[ id ] = false;
			g_shopArmy[ id ] = false;
			g_shopIce[ id ] = false;
			g_shopUlti[ id ] = true;
			g_shopDragon[ id ] = false;
			g_shopNeon[ id ] = false;
			cs_set_user_money( id,peniaze[ id ] );
		}
		case 1:
		{
			g_startpack[ id ]++;
			exp[ id ] += 100;
			ChatColor( id, "!gPrajeme prijemnu hru! Gamesites.cz Team" );
			userknife[ id ] = 11;
			new weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent( id );
			if( pev_valid( weapon_ent ) )
			replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
			ham_strip_weapon( id, "weapon_knife" );
			give_item( id,"weapon_knife" );
			g_shopDefault[ id ] = false;
			g_shopAxe[ id ] = false;
			g_shopAssasin[ id ] = false;
			g_shopBloody[ id ] = false;
			g_shopCrowBar[ id ] = false;
			g_shopArmy[ id ] = false;
			g_shopIce[ id ] = false;
			g_shopUlti[ id ] = false;
			g_shopDragon[ id ] = true;
			g_shopNeon[ id ] = false;
			cs_set_user_money( id,peniaze[ id ] );
		}
		case 2:
		{
			g_startpack[ id ]++;
			peniaze[ id ] += 100;
			g_unHPLevel[ id ]++;
			ChatColor( id, "!gPrajeme prijemnu hru! Gamesites.cz Team" );
			cs_set_user_money( id,peniaze[ id ] );
		}
		case 3:
		{
			ChatColor( id, "!gPrajeme prijemnu hru! Gamesites.cz Team" );
			g_startpack[ id ]++;
			g_unHPLevel[ id ] += 5;
		}
	}
	return PLUGIN_HANDLED;
}

public aktualne_eventy( id )
{
	new szText1[ 555 char ], szText2[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\wAktualny Event: \rZiadny^n" );
	formatex( szText2, charsmax( szText2 ), "\wAktualny Event: \yRAID EVENT^n\d50 %% viac EXP a peniazi za kill + za kazdy kill Item Drop^n" );
	new hm = menu_create( "\yMenu Eventov:", "events_handle" );
	if( g_event_drop != 1 )
		menu_additem( hm, szText1 );
	else
		menu_additem( hm, szText2 );
	menu_additem( hm, "\yDo kedy je event zapnuty? \w( stlac 2 pre info )" );
	menu_display( id, hm );
}

public events_handle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			aktualne_eventy( id );
		}
		case 1:
		{
			aktualne_eventy( id );
			for( new i = 0; i < 5; i++ )
			{
				ChatColor( id, "!gRAID EVENT je zapnuty do !r15.11 2017!g." );
			}
		}
	}
	return PLUGIN_HANDLED;
}

public ostatne_menu( id )
{
	new szText1[ 555 char ], szText2[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\yEventy^n\w- Aktualny Event: \rZiadny" );
	formatex( szText2, charsmax( szText2 ), "\yEventy^n\w- Aktualny Event: \yRAID EVENT" );
	new hm = menu_create( "Ostatne \d( \r/furien \d)", "ostatne_handle" );
	menu_additem( hm, "Herne nastavenia" ); 
	if( g_event_drop != 1 )
		menu_additem( hm, szText1 );
	else
		menu_additem( hm, szText2 );
	menu_additem( hm, "Novinky \d( \r5 \d)" );
	menu_display( id,hm );
}

public ostatne_handle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			nastavenie( id );
		}
		case 1:
		{
			aktualne_eventy( id );
		}
		case 2:
		{
			novinky( id );
		}
	}
	return PLUGIN_HANDLED;
}

public novinky( id )
{
	new nast = menu_create( "\yNovinky \d( \r/furien \d)", "novinky_handle" );
	menu_additem( nast, "Eventy a Turnajovy System \d( \rNOVINKA \d)" );
	menu_additem( nast, "Epic Vylepsenia" );
	menu_additem( nast, "Epic Menu" );
	menu_additem( nast, "EXP System" );
	menu_additem( nast, "Furien Update #1" );
	menu_display( id, nast, 0 );
}

public novinky_handle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			show_motd( id, "eventy.txt" );
			novinky( id );
		}
		case 1:
		{
			show_motd( id, "epicvylepsenia.txt" );
			novinky( id );
		}
		case 2:
		{
			show_motd( id, "epicmenu.txt" );
			novinky( id );
		}
		case 3:
		{
			show_motd( id, "exp.txt" );
			novinky( id );
		}
		case 4:
		{
			show_motd( id, "update.txt" );
			novinky( id );
		}

	}
	return PLUGIN_HANDLED;
}
public server_nastavenia( id )
{
	new nast = menu_create( "\yServer nastavenie \d( \r/furien \d)", "server_nastavenie_handle" );
	menu_additem( nast, ( g_reklama[ id ] ) ? "\wReklama^t^t^t  \y[\wzapnute\y]^n\d- Zobrazuje vsetky reklamy v chate" : "\wReklama^t^t^t^t \y[\rvypnute\y]^n\d- Zobrazuje vsetky reklamy v chate", "1", 0 );
	menu_additem( nast, ( g_priklady[ id ] ) ? "\wPriklady^t^t     \y[\wzapnute\y]^n\d- Zobrazuje vsetky priklady v chate" : "\wPriklady^t^t    \y[\rvypnute\y]^n\d- Zobrazuje vsetky priklady v chate", "2", 0 );
	menu_additem( nast, "\wInformacie o Mode \y( Stlac 3 )", "3", 0 );
	menu_display( id, nast, 0 );
}

public server_nastavenie_handle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}
	switch( item )
	{
		case 0:
		{
			/*
			if( g_reklama[ id ] )
			{
				remove_task( id + TASK_REKLAMA );
				g_reklama[ id ] = false;
			} else {
				g_reklama[ id ] = true;
				set_task( 50.0, "Reklama", id + TASK_REKLAMA );
			}*/
			ChatColor( id, "!gJe nam to luto, tato funkcia je aktualne nedostupna!" );
			ChatColor( id, "!gProsim kontaktujte Developera modu!" );
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			server_nastavenia( id );
		}
		case 1:
		{
			/*
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			g_priklady[ id ] = ( g_priklady[ id ] ) ? false : true;*/
			ChatColor( id, "!gJe nam to luto, tato funkcia je aktualne nedostupna!" );
			ChatColor( id, "!gProsim kontaktujte Developera modu!" );
			server_nastavenia( id );
		}
		case 2:
		{
			client_cmd( id, "spk bz_furien_mod/menu_item.wav" );
			ChatColor( id, "!g*************************" );
			ChatColor( id, "!yNazov!t:!g %s", PLUGIN );
			ChatColor( id, "!yVerzia!t:!g %s", VERSION );
			ChatColor( id, "!yAuthor!t:!g %s", AUTHOR );
			ChatColor( id, "!yLegenda!t: !gb -> BETA !t|!g v -> Otestovana Verzia" );
			server_nastavenia( id );
		}
	}
	return PLUGIN_HANDLED;
}

public Task_Show_Power( id )
{
	id -= TASK_EVENT
	if( !is_entity_moving( id ) )
	{
		if( g_event_drop == 1 )
		{
			set_hudmessage( 255, 127, 0, -1.0, 0.7, 0, 6.0, 1.1, 0.0, 0.0, -1 );
			ShowSyncHudMsg( id, g_msg_event, "*** RAID EVENT *** ^n( trva do 15.11 2017 )^n50 %% viac EXP a peniazi za kill + za kazdy kill Item Drop" );
		}
	}
}

public event_start( id )
{
	g_event_drop = 1;
	new i;
	for( i = 0; i < 5; i++ )
	{ 
		ChatColor( 0, "!g***!y EVENT BOL SPUSTENY!g ***" ); 
	}
}

public otvaranie_truhly( id )
{
	truhla_openning_idle( id );
}

public truhla_openning_idle( id )
{
	if( g_round_aktualne == 1 )
	{
		if( cs_get_user_team( id ) == CS_TEAM_T )
		{
			if( g_truhla_percenta[ id ] != 100 )
			{
				if( !g_truhla_openning[ id ] )
				{
					new i;
					for( i = 0; i < 3; i++ )
					{
						ChatColor( id, "!gOtvaras aktualne truhlu......" );
					}
					g_truhla_openning[ id ] = true;
				}
				set_task( 0.1, "truhla_openning_idle", id );
				g_truhla_percenta[ id ] += 1;
				client_cmd( id, "spk valve/sound/common/launch_glow1" );
				set_hudmessage( 65, 165, 65, -1.0, 0.55, 2, 0.1, 0.4, 0.02, 0.02, -1 );
				ShowSyncHudMsg( id, g_msg_event, "Otvaranie truhly uspesne na %d%%", g_truhla_percenta[ id ] );
			} else {
				g_truhla_openning[ id ] = false;
				g_truhla_percenta[ id ] = 0;
				choose_item( id );
			}
		} else {
			ChatColor( id, "!gNastala chyba pri otvarani truhly.. Peniaze boli ti vratene!" );
			peniaze[ id ] += 35;
			cs_set_user_money( id, peniaze[ id ] );
		}
	} else {
		ChatColor( id, "!gNastala chyba pri otvarani truhly.. Peniaze boli ti vratene!" );
		peniaze[ id ] += 35;
		cs_set_user_money( id, peniaze[ id ] );
	}
}

public choose_item( id )
{
	switch( random( 10 ) )
	{
		case 0:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ChatColor( id, "!gZiskal si !t35 EXP!g a !t45$" );
			exp[ id ] += 35;
			peniaze[ id ] += 45;
			cs_set_user_money( id, peniaze[ id ] );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
		}
		case 1:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ChatColor( id, "!gZiskal si !t70 EXP" );
			exp[ id ] += 70;
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
		}
		case 2:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ChatColor( id, "!gZiskal si !t55$" );
			peniaze[ id ] += 55;
			cs_set_user_money( id, peniaze[ id ] );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
		}
		case 3:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
			ChatColor( id, "!gZiskal si !t35 EXP" );
			exp[ id ] += 35;
		}
		case 4:
		{
			if( !g_shopSuperKnife[ id ] )
			{
				client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
				ChatColor( id, "!gZiskal si !tSuper Knife!g. (limit sa nepocita)" );
				g_shopSuperKnife[ id ] = true;
				superknife[ id ] = true;	
				daj_noz( id, KNIFE_SUPER );		
				ScreenFade( id, 0.5, 255, 255, 255, 100 );
				ham_strip_weapon( id, "weapon_knife" );
				give_item( id,"weapon_knife" );
				client_cmd( id, "spk bz_furien_mod/skacko.wav" );
				ChatColor( id, "%L", LANG_PLAYER, "SHOP_GET_SUPER_KNIFE" );
			} else {
				ChatColor( id, "!gSkus otvorit truhlu znova!" );
				peniaze[ id ] += 35;
				g_shopWallHang[ id ] = false;
				cs_set_user_money( id, peniaze[ id ] );
				ScreenFade( id, 0.5, 255, 255, 255, 100 );
			}
		}
		case 5:
		{
			if( !g_shopZivoty[ id ] )
			{
				client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
				set_pev( id, pev_health, float( min( pev( id, pev_health ) + 50, g_maxHP[ id ] ) ) );
				client_cmd( id, "spk bz_furien_mod/menu_heal.wav" );
				ScreenFade( id, 0.5, 255, 255, 255, 100 );
				ChatColor( id, "!gZiskal si !t+50 %% HP" );
				g_shopZivoty[ id ] = true;
			} else {
				ScreenFade( id, 0.5, 255, 255, 255, 100 );
				ChatColor( id, "!gSkus otvorit truhlu znova!" );
				peniaze[ id ] += 35;
				g_shopWallHang[ id ] = false;
				cs_set_user_money( id, peniaze[ id ] );
			}
		}
		case 6:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + 300, g_max_defense ) ) );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
			ChatColor( id, "!gZiskal si !t300 %% Defensu" );
		}
		case 7:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
			ChatColor( id, "!gZiskal si !t90$" );
			peniaze[ id ] += 90;
			cs_set_user_money( id, peniaze[ id ] );
		}
		case 8:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
			ChatColor( id, "!gZiskal si !t100 EXP" );
			exp[ id ] += 100;
		}
		case 9:
		{
			client_cmd( id, "spk sound/bz_furien_mod/truhla_item.wav" );
			ScreenFade( id, 0.5, 255, 255, 255, 100 );
			ChatColor( id, "!gMal si velke stastie! Ziskal si !t150 EXP!g a !t150$" );
			peniaze[ id ] += 150;
			exp[ id ] += 150;
			cs_set_user_money( id, peniaze[ id ] );
		}
	}
	return PLUGIN_HANDLED;
}
	
public nastav_glow( ent, model[ ] ) 
{
	if( !pev_valid( ent ) )
		return FMRES_IGNORED;
	
	if( !( equali( model, "models/w_backpack.mdl" ) ) )
		return FMRES_IGNORED;
	
	static id;
	id = pev( ent,pev_owner );
	
	if( !( 1 <= id <= g_MaxClients ) )
		return FMRES_IGNORED;
	
	fm_set_rendering( ent, kRenderFxGlowShell, 165, 65, 65, kRenderNormal, 100 )
	return FMRES_IGNORED
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
