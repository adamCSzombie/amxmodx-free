/* Zombie Plague 7.2 */
new const PLUGIN_VERSION[ ] = 		{ "7.4.3" };
new const ZP_CUSTOMIZATION_FILE[ ] = 	{ "zombieplague.ini" };
new const ZP_EXTRAITEMS_FILE[ ] = 	{ "zp_extraitems.ini" };
new const ZP_ZOMBIECLASSES_FILE[ ] = 	{ "zp_zombieclasses.ini" };
new const prefix[ ] = 			{ "!g[PlayAsPro.net]" };
new const Prefix[ ] = 		{ "[PlayAsPro.net]" };

const MAX_CSDM_SPAWNS = 128;
const MAX_STATS_SAVED = 64;

#define MAXP 			32 + 1

new g_event = 1, g_msg_event, g_multiround, g_weekend_event = 0;
new exp_case[ MAXP ], lvl_case[ MAXP ], playaspro_case[ MAXP ], g_killed_zombies[ MAXP ], start_pack_player[ MAXP ], 
zbrane[ 33 ], players, vysledok = 0, prebieha_otazka = 0, g_LastWinner[ 32 ], human_rip[ 33 ];
new g_leg_vyvoleny[ 33 ], g_leg_randomweapon[ 33 ], g_leg_used[ 33 ];

new SQL_Host[ 32 ], SQL_Database[ 32 ], SQL_User[ 32 ], SQL_Password[ 32 ], Name[ MAXP ][ 32 ];
new Handle:SQL_TUPLE, ServerLoaded, User[ MAXP ][ 32 ], Password[ MAXP ][ 32 ], Found[ MAXP ], UserLoad[ MAXP ], RegisterMod[ MAXP ], inProgress[ MAXP ],
UserID[ MAXP ], Activity[ MAXP ], bool:Logined[ MAXP ]

new gSpr_regeneration, g_spr_resist;

#include < amxmodx >
#include < amxmisc >
#include < cstrike >
#include < fakemeta >
#include < hamsandwich >
#include < engine >
#include < xs >
#include < fun >
#include < sqlx >
#include < nvault >
#include < dhudmessage >
#include < weapons >
#include < furien >

#define FIRST_PLAYER_ID		1
#define IsPlayer(%1) 		(FIRST_PLAYER_ID <= %1 <= g_maxplayers)
#define TASK_EVENT1		999999999999999999

new g_player_lang[ 33 ];

new const lang[ ][ ][ ] = {
	{ "SLOVAK", "CZECH", "ENGLISH" },
	{ "\yPrihlasovacie Menu:\d (www.playaspro.net)^n> BETA TESTING", "\yPrihlasovaci Menu:\d (www.playaspro.net)^n> BETA TESTING", "\yLogin Menu: \d (www.playaspro.net)^n> BETA TESTING" }, // 1
	{ "\yMeno:\d ", "\yJmeno:\d ", "\yName:\d " }, // 2
	{ "\yHeslo:\d ", "\yHeslo:\d ", "\yPassword:\d " }, // 3
	{ "\rLanguage: \wSlovak", "\rLanguage: \wCzech", "\rLanguage: \wEnglish" }, // 4
	{ ">> PRIHLASIT SA <<", ">> PRIHLASIT SE <<", ">> LOG IN <<" }, // 5
	{ ">> ZAREGISTROVAT SA <<", ">> ZAREGISTROVAT SE <<", ">> MAKE NEW ACCOUNT <<" }, // 6
	{ "!g[ZP]!y Databaza nebola uspesne pripojena!", "!g[ZP]!y Databaze nebyla uspesne prepojena!", "!g[ZP]!y Database has not been connected!" }, // 7
	{ "!g[ZP]!y Prihlasujem na vas ucet....", "!g[ZP]!y Prihlasuji na tvuj ucet....", "!g[ZP]!y Logining into your account...." }, // 8
	{ "\yMeno:\d %s^n\d2. Heslo:", "\yJmeno:\d %s^n\d2. Heslo:", "\yName:\d %s^n\d2. Password:" },// 9
	{ "!g[ZP]!y Vytvaram novy ucet....", "!g[ZP]!y Vytvarim novej ucet....", "!g[ZP]!y Making new account...." }, // 10
	{ "\wEpic Menu \y[\r 2\w/\r2\y ]^n\d( vyberove menu )", "\wEpic Menu \y[\r 2\w/\r2\y ]^n\d( vyberovi menu )", "\wEpic Menu \y[\r 2\w/\r2\y ]^n\d( choose menu )" }, // 11
	{ "\dEpic Vylepsenia", "\dEpic Vylepseni", "\dEpic Upgrades" }, // 12
	{ "\dObchodovaine s Hracom", "\dObchodovani s Hracem", "\dTrading with Player" }, // 13
	{ "Co su to EXP?", "Co sou to EXP?", "What is EXP?" }, // 14
	{ "Co su to Spirity?", "Co sou to Spirity?", "What is Spirits?" }, // 15
	{ "\dCo su to Vylepsenia?\w^n======================================", "\dCo sou to Vylepseni?\w^n======================================",  "\dWhat is Upgrades?\w^n======================================" }, // 16
	{ "\yNaspat", "\yNaspet", "\yBack" }, // 17
	{ "!g[ZP]!y Coskoro si budes moct vylepsit aj svoje zbrane!", "!g[ZP]!y Nejblizsi dobe si budes moct vylepsit svy zbrane!", "!g[ZP]!y Comming soon u can upgrade your weapons!" }, // 18
	{ "!g[ZP]!y Coskoro si budes moct vymenit s hracom exp za levely!", "!g[ZP]!y Nejblizsi dobe si budes moct vymenit s hrace, exp za levely!", "!g[ZP]!y Comming soon u can trade your exp for levels!" }, // 19
	{ "!g[ZP]!y Tato funkcia je momentalne nedostupna!", "!g[ZP]!y Tahle funkce je momentalne nedostupna!", "!g[ZP]!y This function is now not avaibable!" }, // 20
	{ "\wEpic Menu \y[ \d1\w/\r2\y ]^n\d( vyberove menu )", "\wEpic Menu \y[ \d1\w/\r2\y ]^n\d( vyberovi menu )", "\wEpic Menu \y[ \d1\w/\r2\y ]^n\d( choose menu )" }, // 21
	{ "\rVylepsenia", "\rVylepseni", "\rUpgrades" }, // 22
	{ "\yEpic Predmety", "\yEpic Predmety", "\yEpic Items" }, // 23
	{ "Zmenaren", "Zmenaren", "Exchnage Menu" }, // 24
	{ "\yHerny Inventar", "\yHerni Inventar", "\yGame Inventory" }, // 25
	{ "\rTurnajove Statistiky\w^n======================================", "\rTurnajovi Statistiky\w^n======================================", "\rTournament Stats\w^n======================================" }, // 26
	{ "\yDalej", "\yDal", "\yNext" }, // 27
	{ "!g[ZP]!y Ked si hannibal nemozes pouzit tuto funckiu!", "!g[ZP]!y Kdyz jsi hanniba nemuzes pouzit tuhle funkci!", "!g[ZP]!y When you are hannibal you can not use this function!" }, // 28
	{ "\yNastavenie: \w( \r/zpmenu\w )", "\yNastaveni: \w(\r /zpmenu \w)", "\ySettings: \w(\r /zpmenu\w )" }, // 29
	{ "!g[ZP]!y Musis byt nazive!", "!g[ZP]!y Musis byt zivej!", "!g[ZP]!y You must be alive!" }, // 30
	{ "\w3D pohlad^t^t^t  \y[\rZAPNUTE\y]^n\d- Nastavenie 3D pohladu hraca", "\w3D pohled^t^t^t  \y[\rZAPNUTY\y]^n\d- Nastaveni 3D pohledu hrace", "\w3D View ^t^t^t  \y[\rON\y]^n\d- 3D view of your body" }, // 31
	{ "\w3D pohlad^n\d- Nastavenie 3D pohladu hraca", "\w3D pohled^n\d- Nastaveni 3D pohledu hrace", "\w3D View^n\d- 3D view of your body" }, // 32
	{ "\wOdseknut^n\dPomaha pri zaseknuti sa v texture^n", "\wOdseknout^n\dPomaha pri zaseknuti sa v texture^n", "\wUnstuck^n\dIt is helping while you are stucked^n" }, // 33
	{ "!g[ZP]!y Niesi zaseknuty!", "!g[ZP]!y Nejsi zaseknutej!", "!g[ZP]!y You are not stucked!" }, // 34
	{ "\rEXP Case \w| \yAktualny pocet: \w%i", "\rEXP Case \w| \yAktualni pocet: \w%i", "\rEXP Case \w| \yActual Count: \w%i" }, // 35
	{ "\rLVL UP Case \w| \yAktualny pocet: \w%i", "\rLVL UP Case \w| \yAktualni pocet: \w%i", "\rLVL UP Case \w| \yActual Count: \w%i" }, // 36
	{ "\rEpic Case \w| \yAktualny pocet: \w%i", "\rEpic Case \w| \yAktualni pocet: \w%i", "\rEpic Case \w| \yActual Count: \w%i" }, // 37
	{ "\yHerny Inventar:^n\d-Tu najdes vsetky truhly ktore ziskas pocas turnajov!", "\yHerni Inventar:^n\d-Tu jsi mas vsechni truhly ktery ziskas pocas turnajov!", "\yGame Inventory:^n\d-Here you can find everysingle case that you have found!" }, // 38
	{ "\dVolny Slot", "\dVolnej Slot", "\dFree Slot" }, // 39
	{ "Tento slot nic neobsahuje!", "Tehlen slot nic v sebe nema!", "This slot is empty!" } //40
}

enum {
	SECTION_NONE = 0, SECTION_ACCESS_FLAGS, SECTION_PLAYER_MODELS,
	SECTION_WEAPON_MODELS, SECTION_GRENADE_SPRITES, SECTION_SOUNDS,
	SECTION_AMBIENCE_SOUNDS, SECTION_BUY_MENU_WEAPONS, SECTION_EXTRA_ITEMS_WEAPONS,
	SECTION_HARD_CODED_ITEMS_COSTS, SECTION_WEATHER_EFFECTS, SECTION_SKY, 
	SECTION_LIGHTNING, SECTION_ZOMBIE_DECALS, SECTION_KNOCKBACK,
	SECTION_OBJECTIVE_ENTS, SECTION_SVC_BAD
};

enum {
	ACCESS_ENABLE_MOD = 0, ACCESS_ADMIN_MENU, ACCESS_MODE_INFECTION,
	ACCESS_MODE_NEMESIS, ACCESS_MODE_SURVIVOR, ACCESS_MODE_SWARM,
	ACCESS_MODE_MULTI, ACCESS_MODE_PLAGUE, ACCESS_MAKE_ZOMBIE,
	ACCESS_MAKE_HUMAN, ACCESS_MAKE_NEMESIS, ACCESS_MAKE_SURVIVOR,
	ACCESS_RESPAWN_PLAYERS, ACCESS_ADMIN_MODELS, MAX_ACCESS_FLAGS
};

enum (+= 100)
{
	TASK_MODEL = 2000,
	TASK_TEAM,
	TASK_SPAWN,
	TASK_BLOOD,
	TASK_AURA,
	TASK_BURN,
	TASK_NVISION,
	TASK_FLASH,
	TASK_CHARGE,
	TASK_SHOWHUD,
	TASK_MAKEZOMBIE,
	TASK_WELCOMEMSG,
	TASK_THUNDER_PRE,
	TASK_THUNDER,
	TASK_LASTHUMAN,
	TASK_AMBIENCESOUNDS
};

#define ID_MODEL 		(taskid - TASK_MODEL)
#define ID_TEAM 		(taskid - TASK_TEAM)
#define ID_SPAWN 		(taskid - TASK_SPAWN)
#define ID_BLOOD 		(taskid - TASK_BLOOD)
#define ID_AURA 		(taskid - TASK_AURA)
#define ID_BURN 		(taskid - TASK_BURN)
#define ID_NVISION 		(taskid - TASK_NVISION)
#define ID_FLASH 		(taskid - TASK_FLASH)
#define ID_CHARGE 		(taskid - TASK_CHARGE)
#define ID_SHOWHUD 		(taskid - TASK_SHOWHUD)
#define VIP 			ADMIN_LEVEL_H
#define ACCESS_FLAG 		ADMIN_USER
#define EVIP 			ADMIN_LEVEL_G
#define ACCES 			ADMIN_CVAR
#define REFILL_WEAPONID 	args[ 0 ]
#define WPN_STARTID 		g_menu_data[ id ][ 1 ]
#define WPN_MAXIDS 		ArraySize( g_primary_items )
#define WPN_SELECTION 		( g_menu_data[ id ][ 1 ] + key )
#define WPN_AUTO_ON 		g_menu_data[ id ][ 2 ]
#define WPN_AUTO_PRI 		g_menu_data[ id ][ 3 ]
#define WPN_AUTO_SEC 		g_menu_data[ id ][ 4 ]
#define PL_ACTION 		g_menu_data[ id ][ 0 ]
#define MENU_PAGE_ZCLASS 	g_menu_data[ id ][ 5 ]
#define MENU_PAGE_EXTRAS 	g_menu_data[ id ][ 6 ]
#define MENU_PAGE_PLAYERS 	g_menu_data[ id ][ 7 ]
#define FFADE_IN 		0x0000
#define FFADE_OUT 		0x0001
#define FADE_TYPE 		FFADE_OUT
#define TASK_HEALTH 		1234554321
#define TASK_POWER 		44554451
#define TASK_ADD_ADRENALIN 	46465464687
#define TASK_REMOVE_ADRENALIN 	15465464646
#define EXTRAS_CUSTOM_STARTID 	( EXTRA_WEAPONS_STARTID + ArraySize( g_extraweapon_names ) )
const MENU_KEY_AUTOSELECT = 7;
const MENU_KEY_BACK = 7;
const MENU_KEY_NEXT = 8;
const MENU_KEY_EXIT = 9;

enum {
	EXTRA_NVISION = 0, EXTRA_ANTIDOTE, EXTRA_MADNESS, EXTRA_INFBOMB, EXTRA_WEAPONS_STARTID
}

enum {
	MODE_NONE = 0, MODE_INFECTION, MODE_NEMESIS, MODE_SURVIVOR, MODE_SWARM, MODE_MULTI, MODE_PLAGUE
}

const ZP_TEAM_NO_ONE = 0;
const ZP_TEAM_ANY = 0;
const ZP_TEAM_ZOMBIE = ( 1 << 0 );
const ZP_TEAM_HUMAN = ( 1 << 1 );
const ZP_TEAM_NEMESIS = ( 1 << 2 );
const ZP_TEAM_SURVIVOR = ( 1 << 3 );

new const ZP_TEAM_NAMES[ ][ ] = { 
	"ZOMBIE , HUMAN", "ZOMBIE", "HUMAN", "ZOMBIE , HUMAN", "NEMESIS", "ZOMBIE , NEMESIS", "HUMAN , NEMESIS", "ZOMBIE , HUMAN , NEMESIS",
	"SURVIVOR", "ZOMBIE , SURVIVOR", "HUMAN , SURVIVOR", "ZOMBIE , HUMAN , SURVIVOR", "NEMESIS , SURVIVOR", "ZOMBIE , NEMESIS , SURVIVOR", "HUMAN, NEMESIS, SURVIVOR",
	"ZOMBIE , HUMAN , NEMESIS , SURVIVOR" 
}

new const CS_TEAM_NAMES[ ][ ] = 	{ "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" };
new const lasthuman_zvuk[ ] = 		{ "bluezone/zombie/lasthumaninfo.wav" };
new const sound_flashlight[ ] =		{ "items/flashlight1.wav" };
new const sound_buyammo[ ] = 		{ "items/9mmclip1.wav" };
new const sound_armorhit[ ] = 		{ "player/bhit_helmet-1.wav" };
new const sound_levelup[ ] = 		{ "playaspro/xp_levelup.wav" };
new const sound_buy[ ] = 		{ "playaspro/zakupenie.wav" };
new const sound_upgrade[ ] = 		{ "playaspro/upgraden.wav" };
new const sound_legendary[ ] = 		{ "playaspro/legendarykey.wav" };

static const pet_model[ ] = 	{ "models/stukabat.mdl" };
static const pet_idle = 13;
static const pet_run = 13;
static const pet_die = 5;
static const pet_cost = 5;
static const Float:pet_idle_speed = 0.5;
static const Float:pet_run_speed = 13.0;

const ZCLASS_NONE = 		-1;
new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame
const Float:HUD_EVENT_X = -1.0;
const Float:HUD_EVENT_Y = 0.04;
const Float:HUD_INFECT_X = 0.05;
const Float:HUD_INFECT_Y = 0.45;
const Float:HUD_SPECT_X = 0.6;
const Float:HUD_SPECT_Y = 0.8;
const Float:HUD_STATS_X = -1.0; // 0.02
const Float:HUD_STATS_Y = 0.9; // 0.93
const fPainShock = 108;
const extra_offset_weapon = 4;
const PDATA_SAFE = 2;
const OFFSET_PAINSHOCK = 108; 
const OFFSET_CSTEAMS = 114;
const OFFSET_CSMONEY = 115;
const OFFSET_CSMENUCODE = 205;
const OFFSET_FLASHLIGHT_BATTERY = 244;
const OFFSET_CSDEATHS = 444;
const OFFSET_MODELINDEX = 491;
const OFFSET_ACTIVE_ITEM = 373;
const OFFSET_WEAPONOWNER = 41;
const OFFSET_LINUX = 5;
const OFFSET_LINUX_WEAPONS = 4;
const m_iClip = 51;
new legendary_key[ MAXP ];

enum {
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}

const HIDE_MONEY = ( 1 << 5 );
const UNIT_SECOND = ( 1 << 12 );
const DMG_HEGRENADE = ( 1 << 24 );
const IMPULSE_FLASHLIGHT = 100;
const USE_USING = 2;
const USE_STOPPED = 0;
const STEPTIME_SILENT = 999;
const BREAK_GLASS = 0x01;
const FFADE_STAYOUT = 0x0004;
const PEV_SPEC_TARGET = pev_iuser2;

new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }

new const MAXCLIP[] = { -1, 13, -1, 10, -1, 7, -1, 30, 30, -1, 30, 20, 25, 30, 35, 25, 12, 20,
			10, 30, 100, 8, 30, 30, 20, -1, 7, 30, 30, -1, 50 }

new const BUYAMMO[] = { -1, 13, -1, 30, -1, 8, -1, 12, 30, -1, 30, 50, 12, 30, 30, 30, 12, 30,
			10, 30, 30, 8, 30, 30, 30, -1, 7, 30, 30, -1, 50 }

new const AMMOID[] = { -1, 9, -1, 2, 12, 5, 14, 6, 4, 13, 10, 7, 6, 4, 4, 4, 6, 10,
			1, 10, 3, 5, 4, 10, 2, 11, 8, 4, 2, -1, 7 }

new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp",
			"556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot",
			"556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" }

new const AMMOWEAPON[] = { 0, CSW_AWP, CSW_SCOUT, CSW_M249, CSW_AUG, CSW_XM1014, CSW_MAC10, CSW_FIVESEVEN, CSW_DEAGLE,
			CSW_P228, CSW_ELITE, CSW_FLASHBANG, CSW_HEGRENADE, CSW_SMOKEGRENADE, CSW_C4 }

new const WEAPONNAMES[][] = { "", "Compact", "", "Scout", "", "XM1014 M4", "", "Ingram MAC-10", "\yScope Hell  \r4000 $",
			"", "Elite Duals", "FiveseveN", "UMP 45", "SG-550 Auto-Sniper", "Galil" , "Famas",
			"USP Pistol", "Glock-18", "AWP Magnum Sniper", "\yWater Snake  \r3600 $", "M249 Para Machinegun",
			"\yWinchester  \r4000 $", "M4A1", "Schmidt TMP", "G3SG1 Auto-Sniper", "", "Desert Eagle",
			"SG-552", "AK47", "Knife", "ES P90" }

new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }
			
new const g_provocation[ ][ ] = {
	"playaspro/idle_human1.wav", "playaspro/idle_human2.wav", "playaspro/idle_human3.wav",
	"playaspro/idle_human4.wav", "playaspro/idle_human5.wav", "playaspro/idle_human6.wav"
}

const Float:NADE_EXPLOSION_RADIUS = 240.0

const PEV_ADDITIONAL_AMMO = pev_iuser1

const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_INFECTION = 1111
const NADE_TYPE_NAPALM = 2222
const NADE_TYPE_FROST = 3333
const NADE_TYPE_FLARE = 4444
const PEV_FLARE_COLOR = pev_punchangle
const PEV_FLARE_DURATION = pev_flSwimTime

new g_resFrostCost[ 33 ], g_resBurnCost[ 33 ], g_FrostCost[ 33 ], g_BurnCost[ 33 ];
new g_resFrostLevel[ MAXP ], g_resBurnLevel[ MAXP ], g_BurnLevel[ MAXP ], g_FrostLevel[ MAXP ];
new g_ArmorRegCost[ 33 ], g_CritDamageCost[ 33 ], g_MoneyCost[ 33 ], g_SpyCost[ 33 ];
new g_ArmorRegLevel[ MAXP ], g_CritDamageLevel[ MAXP ], g_MoneyLevel[ MAXP ], g_SpyLevel[ MAXP ];


const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_C4)

new const MODEL_ENT_CLASSNAME[] = "player_model"
new const WEAPON_ENT_CLASSNAME[] = "weapon_model"

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

enum
{
	AMBIENCE_SOUNDS_INFECTION = 0,
	AMBIENCE_SOUNDS_NEMESIS,
	AMBIENCE_SOUNDS_SURVIVOR,
	AMBIENCE_SOUNDS_SWARM,
	AMBIENCE_SOUNDS_PLAGUE,
	MAX_AMBIENCE_SOUNDS
}

enum
{
	ACTION_ZOMBIEFY_HUMANIZE = 0,
	ACTION_MAKE_NEMESIS,
	ACTION_MAKE_SURVIVOR,
	ACTION_RESPAWN_PLAYER,
	ACTION_MODE_SWARM,
	ACTION_MODE_MULTI,
	ACTION_MODE_PLAGUE
}

const ZP_PLUGIN_HANDLED = 97

new g_zombie[ 33 ], g_nemesis[ 33 ], g_survivor[ 33 ], g_firstzombie[ 33 ], g_lastzombie[ 33 ], g_lasthuman[ 33 ],
g_frozen[ 33 ], Float:g_frozen_gravity[ 33 ], g_nodamage[ 33 ], g_respawn_as_zombie[ 33 ], g_nvision[ 33 ],
g_nvisionenabled[ 33 ], g_zombieclass[ 33 ], g_zombieclassnext[ 33 ], g_flashlight[ 33 ], g_flashbattery[ 33 ] = { 100, ... }, 
g_canbuy[ 33 ], g_ammopacks[ 33 ], g_damagedealt_human[ 33 ], g_damagedealt_zombie[ 33 ], Float:g_lastleaptime[ 33 ], 
Float:g_lastflashtime[ 33 ], g_playermodel[ 33 ][ 32 ], g_menu_data[ 33 ][ 8 ], g_ent_playermodel[ 33 ],
g_ent_weaponmodel[ 33 ], g_burning_duration[ 33 ], Float:g_buytime[ 33 ];

new g_pluginenabled, g_newround, g_endround, g_nemround, g_survround, g_swarmround, g_plagueround, g_modestarted, 
g_lastmode, g_scorezombies, g_scorehumans, g_gamecommencing, g_spawnCount, g_spawnCount2, Float:g_spawns[ MAX_CSDM_SPAWNS ][ 3 ], 
Float:g_spawns2[ MAX_CSDM_SPAWNS ][ 3 ], g_lights_i, g_lights_cycle[ 32 ], g_lights_cycle_len, Float:g_models_targettime,
Float:g_teams_targettime, g_MsgSync, g_MsgSync2 ,g_MsgSync3, g_MsgSync4, g_MsgSync5, g_MsgSync6, g_MsgSync7, g_MsgSync8, g_trailSpr, 
g_exploSpr, g_flameSpr, g_smokeSpr, g_glassSpr, g_modname[ 32 ], g_freezetime, g_maxplayers, g_czero, g_hamczbots, g_fwSpawn, 
g_fwPrecacheSound, g_infbombcounter, g_antidotecounter, g_madnesscounter, g_arrays_created, g_lastplayerleaving, g_switchingteam,
g_buyzone_ent, body[ 33 ] = 0, Rychly[ 33 ] = 0, Gravity[ 33 ] = 0, adrenaline[ 33 ] = 0, g_player_class[ 33 ], bool:mazbran[ 33 ],
bool:g_item_dmg[ 33 ], bool:g_item_gdmg[ 33 ], g_damage[ 33 ], cvar_max_lvl, kills[ 33 ],levels[ MAXP ], exp[ MAXP ], g_vault;

new g_msgScoreInfo, g_msgNVGToggle, g_msgScoreAttrib, g_msgAmmoPickup, g_msgScreenFade,
g_msgDeathMsg, g_msgSetFOV, g_msgFlashlight, g_msgFlashBat, g_msgTeamInfo, g_msgDamage,
g_msgHideWeapon, g_msgCrosshair, g_msgSayText, g_msgScreenShake, g_msgCurWeapon

new g_fwRoundStart, g_fwRoundEnd, g_fwUserInfected_pre, g_fwUserInfected_post,
g_fwUserHumanized_pre, g_fwUserHumanized_post, g_fwUserInfect_attempt,
g_fwUserHumanize_attempt, g_fwExtraItemSelected, g_fwUserUnfrozen,
g_fwUserLastZombie, g_fwUserLastHuman, g_fwDummyResult

new db_name[MAX_STATS_SAVED][32]
new db_ammopacks[MAX_STATS_SAVED] 
new db_zombieclass[MAX_STATS_SAVED] 
new db_slot_i

new Array:g_extraitem_name 
new Array:g_extraitem_cost 
new Array:g_extraitem_team 
new g_extraitem_i 

new Array:g_extraitem2_realname, Array:g_extraitem2_name, Array:g_extraitem2_cost,
Array:g_extraitem2_team, Array:g_extraitem_new

new Array:g_zclass_name 
new Array:g_zclass_info 
new Array:g_zclass_modelsstart
new Array:g_zclass_modelsend
new Array:g_zclass_playermodel 
new Array:g_zclass_modelindex 
new Array:g_zclass_clawmodel 
new Array:g_zclass_hp 
new Array:g_zclass_spd 
new Array:g_zclass_grav 
new Array:g_zclass_kb 
new g_zclass_i

new g_pHPCost[ MAXP ], g_pAPCost[ MAXP ], g_pDMCost[ MAXP ], g_pDECost[ MAXP ], g_unHPLevel[ MAXP ], g_unAPLevel[ MAXP ], g_unDMLevel[ MAXP ], g_unDELevel[ MAXP ];
new g_pcvar_unhpcost, g_pcvar_unapcost, g_pcvar_undmcost, g_pcvar_undecost, g_pcvar_unhpmult, g_pcvar_unapmult, g_pcvar_undmmult, g_pcvar_undemult;

new Array:g_zclass2_realname, Array:g_zclass2_name, Array:g_zclass2_info,
Array:g_zclass2_modelsstart, Array:g_zclass2_modelsend, Array:g_zclass2_playermodel,
Array:g_zclass2_modelindex, Array:g_zclass2_clawmodel, Array:g_zclass2_hp,
Array:g_zclass2_spd, Array:g_zclass2_grav, Array:g_zclass2_kb, Array:g_zclass_new

new g_access_flag[MAX_ACCESS_FLAGS], Array:model_nemesis, Array:model_survivor, Array:model_human,
Array:model_admin_zombie, Array:model_admin_human, Array:g_modelindex_human,
Array:g_modelindex_nemesis, Array:g_modelindex_survivor, g_same_models_for_all,
Array:g_modelindex_admin_zombie, Array:g_modelindex_admin_human, model_vknife_human[64],
model_vknife_nemesis[64], model_vweapon_survivor[64], model_grenade_infect[64],
model_grenade_fire[64], model_grenade_frost[64], model_grenade_flare[64],
model_vknife_admin_human[64], model_vknife_admin_zombie[64],
sprite_grenade_trail[64], sprite_grenade_ring[64], sprite_grenade_fire[64],
sprite_grenade_smoke[64], sprite_grenade_glass[64], Array:sound_win_zombies,
Array:sound_win_humans, Array:sound_win_no_one, Array:sound_win_zombies_ismp3,
Array:sound_win_humans_ismp3, Array:sound_win_no_one_ismp3, Array:zombie_infect,
Array:zombie_idle, Array:human_idle , Array:zombie_pain, Array:nemesis_pain, Array:zombie_die, Array:zombie_fall,
Array:zombie_miss_wall, Array:zombie_hit_normal, Array:zombie_hit_stab, g_ambience_rain,
Array:zombie_idle_last, Array:zombie_madness, Array:sound_nemesis, Array:sound_survivor,
Array:sound_swarm, Array:sound_multi, Array:sound_plague, Array:grenade_infect,
Array:grenade_infect_player, Array:grenade_fire, Array:grenade_fire_player,
Array:grenade_frost, Array:grenade_frost_player, Array:grenade_frost_break,
Array:grenade_flare, Array:sound_antidote, Array:sound_thunder, Array:sound_firstzombie , g_ambience_sounds[MAX_AMBIENCE_SOUNDS],
Array:sound_ambience1, Array:sound_ambience2, Array:sound_ambience3, Array:sound_ambience4,
Array:sound_ambience5, Array:sound_ambience1_duration, Array:sound_ambience2_duration,
Array:sound_ambience3_duration, Array:sound_ambience4_duration,
Array:sound_ambience5_duration, Array:sound_ambience1_ismp3, Array:sound_ambience2_ismp3,
Array:sound_ambience3_ismp3, Array:sound_ambience4_ismp3, Array:sound_ambience5_ismp3,
Array:g_primary_items, Array:g_secondary_items, Array:g_additional_items,
Array:g_primary_weaponids, Array:g_secondary_weaponids, Array:g_extraweapon_names,
Array:g_extraweapon_items, Array:g_extraweapon_costs, g_extra_costs2[EXTRA_WEAPONS_STARTID],
g_ambience_snow, g_ambience_fog, g_fog_density[10], g_fog_color[12], g_sky_enable,
Array:g_sky_names, Array:lights_thunder, Array:zombie_decals, Array:g_objective_ents,
Float:g_modelchange_delay, g_set_modelindex_offset, g_handle_models_on_separate_ent,
Float:kb_weapon_power[31] = { -1.0, ... }, Array:zombie_miss_slash, g_force_consistency

new cvar_lighting, cvar_zombiefov, cvar_plague, cvar_plaguechance, cvar_zombiefirsthp,
cvar_removemoney, cvar_thunder, cvar_zombiebonushp, cvar_nemhp, cvar_nem, cvar_surv,
cvar_nemchance, cvar_deathmatch, cvar_nemglow, cvar_customnvg, cvar_hitzones, cvar_humanhp,
cvar_nemgravity, cvar_flashsize, cvar_ammodamage_human, cvar_ammodamage_zombie,
cvar_zombiearmor, cvar_zombiearmor2, cvar_survpainfree, cvar_nempainfree, cvar_nemspd, cvar_survchance,
cvar_survhp, cvar_survspd, cvar_humanspd, cvar_swarmchance, cvar_flashdrain,
cvar_zombiebleeding, cvar_removedoors, cvar_customflash, cvar_randspawn, cvar_multi,
cvar_multichance, cvar_infammo, cvar_swarm, cvar_ammoinfect, cvar_toggle,
cvar_knockbackpower, cvar_freezeduration, cvar_triggered, cvar_flashcharge,
cvar_firegrenades, cvar_frostgrenades, cvar_survgravity, cvar_logcommands, cvar_survglow,
cvar_humangravity, cvar_spawnprotection, cvar_nvgsize, cvar_flareduration, cvar_zclasses,
cvar_extraitems, cvar_showactivity, cvar_humanlasthp, cvar_nemignorefrags, cvar_warmup,
cvar_flashdist, cvar_flarecolor, cvar_survignorefrags, cvar_fireduration, cvar_firedamage,
cvar_flaregrenades, cvar_knockbackducking, cvar_knockbackdamage, cvar_knockbackzvel,
cvar_multiratio, cvar_flaresize, cvar_spawndelay, cvar_extraantidote, cvar_extramadness,
cvar_extraweapons, cvar_extranvision, cvar_nvggive, cvar_preventconsecutive, cvar_botquota,
cvar_buycustom, cvar_zombiepainfree, cvar_fireslowdown, cvar_survbasehp, cvar_survaura,
cvar_nemignoreammo, cvar_survignoreammo, cvar_nemaura, cvar_extrainfbomb, cvar_knockback,
cvar_fragsinfect, cvar_fragskill, cvar_humanarmor, cvar_removedropped,
cvar_plagueratio, cvar_blocksuicide, cvar_knockbackdist, cvar_nemdamage, cvar_leapzombies,
cvar_leapzombiesforce, cvar_leapzombiesheight, cvar_leapzombiescooldown, cvar_leapnemesis,
cvar_leapnemesisforce, cvar_leapnemesisheight, cvar_leapnemesiscooldown, cvar_leapsurvivor,
cvar_leapsurvivorforce, cvar_leapsurvivorheight, cvar_nemminplayers, cvar_survminplayers,
cvar_respawnonsuicide, cvar_respawnafterlast, cvar_leapsurvivorcooldown, cvar_statssave,
cvar_swarmminplayers, cvar_multiminplayers, cvar_plagueminplayers, cvar_adminmodelshuman,
cvar_adminmodelszombie, cvar_nembasehp, cvar_blockpushables,
cvar_madnessduration, cvar_plaguenemnum, cvar_plaguenemhpmulti, cvar_plaguesurvhpmulti,
cvar_survweapon, cvar_plaguesurvnum, cvar_infectionscreenfade, cvar_infectionscreenshake,
cvar_infectionsparkle, cvar_infectiontracers, cvar_infectionparticles, cvar_infbomblimit,
cvar_allowrespawnsurv, cvar_flashshowall, cvar_allowrespawninfection, cvar_allowrespawnnem,
cvar_allowrespawnswarm, cvar_allowrespawnplague, cvar_survinfammo, cvar_nemknockback,
cvar_nvgcolor[3], cvar_nemnvgcolor[3], cvar_humnvgcolor[3], cvar_flashcolor[3],
cvar_hudicons, cvar_respawnzomb, cvar_respawnhum, cvar_respawnnem, cvar_respawnsurv,
cvar_startammopacks, cvar_randweapons, cvar_antidotelimit, cvar_madnesslimit,
cvar_adminknifemodelshuman, cvar_adminknifemodelszombie, cvar_keephealthondisconnect, cvar_huddisplay

new g_isconnected[33]
new g_isalive[33] 
new g_isbot[33] 
new g_currentweapon[33] 
new g_playername[33][32] 
new Float:g_zombie_spd[33]
new Float:g_zombie_knockback[33] 
new g_zombie_classname[33][32] 

new CvarHost, CvarDatabase, CvarUser, CvarPassword

#define is_user_valid_connected(%1) (1 <= %1 <= g_maxplayers && g_isconnected[%1])
#define is_user_valid_alive(%1) (1 <= %1 <= g_maxplayers && g_isalive[%1])
#define is_user_valid(%1) (1 <= %1 <= g_maxplayers)

new g_cached_customflash, g_cached_zombiesilent, g_cached_leapzombies, g_cached_leapnemesis,
g_cached_leapsurvivor, Float:g_cached_leapzombiescooldown, Float:g_cached_leapnemesiscooldown,
Float:g_cached_leapsurvivorcooldown, Float:g_cached_buytime

new g_epicDragon[33]
new g_epicFastBZ[33]
new g_epic20hpmap[33]
new g_epic20dmgmap[33]
new g_epicUltimate[33]

new m4a1[33]
new ak47[33]
new mp5[33]
new p90[33]
new aug[33]
new fam[33]
new m3[33]

new water[33]
new scope[33]
new rockg[33]
new fired[33]
new iceha[33]
new snipe[33]

new start_human[ 33 ], fast_human[ 33 ], gravity_human[ 33 ];
new frost_human[33]
new strong_human[33]
new damage_human[33]
new adrenal_human[33]
new minigun_human[33]
new special_human[33]
new imune_human[33]
new spirit_human[33]
new exp_human[33]
new defense_human[ 33 ], points_human[ 33 ], expcase_human[ 33 ], resist_human[ 33 ];

new g_ASTAR[33]
new g_AFAST[33]
new g_AGRAV[33]
new g_ASTRO[33]
new g_ADAMA[33]

new pohlad[33]

new speeda[33]
new gravita[33]

new adrenalin_pohyb[33]
new last_human

new const vyber_humana[] = { "bluezone/zombie/vyber_humana.wav" }

public plugin_natives() {

	register_native("is_user_resist", "native_get_user_resist", 1)
	register_native("zp_get_user_zombie", "native_get_user_zombie", 1)
	register_native("zp_get_user_nemesis", "native_get_user_nemesis", 1)
	register_native("zp_get_user_survivor", "native_get_user_survivor", 1)
	register_native("zp_get_user_first_zombie", "native_get_user_first_zombie", 1)
	register_native("zp_get_user_last_zombie", "native_get_user_last_zombie", 1)
	register_native("zp_get_user_last_human", "native_get_user_last_human", 1)
	register_native("zp_get_user_zombie_class", "native_get_user_zombie_class", 1)
	register_native("zp_get_user_next_class", "native_get_user_next_class", 1)
	register_native("zp_set_user_zombie_class", "native_set_user_zombie_class", 1)
	register_native("zp_get_user_ammo_packs", "native_get_user_ammo_packs", 1)
	register_native("zp_set_user_ammo_packs", "native_set_user_ammo_packs", 1)
	register_native("zp_get_zombie_maxhealth", "native_get_zombie_maxhealth", 1)
	register_native("zp_get_user_batteries", "native_get_user_batteries", 1)
	register_native("zp_set_user_batteries", "native_set_user_batteries", 1)
	register_native("zp_get_user_nightvision", "native_get_user_nightvision", 1)
	register_native("zp_set_user_nightvision", "native_set_user_nightvision", 1)
	register_native("zp_infect_user", "native_infect_user", 1)
	register_native("zp_disinfect_user", "native_disinfect_user", 1)
	register_native("zp_make_user_nemesis", "native_make_user_nemesis", 1)
	register_native("zp_make_user_survivor", "native_make_user_survivor", 1)
	register_native("zp_respawn_user", "native_respawn_user", 1)
	register_native("zp_force_buy_extra_item", "native_force_buy_extra_item", 1)
	register_native("zp_override_user_model", "native_override_user_model", 1)
	
	register_native("zp_has_round_started", "native_has_round_started", 1)
	register_native("zp_is_nemesis_round", "native_is_nemesis_round", 1)
	register_native("zp_is_survivor_round", "native_is_survivor_round", 1)
	register_native("zp_is_swarm_round", "native_is_swarm_round", 1)
	register_native("zp_is_plague_round", "native_is_plague_round", 1)
	register_native("zp_get_zombie_count", "native_get_zombie_count", 1)
	register_native("zp_get_human_count", "native_get_human_count", 1)
	register_native("zp_get_nemesis_count", "native_get_nemesis_count", 1)
	register_native("zp_get_survivor_count", "native_get_survivor_count", 1)
	
	register_native("zp_register_extra_item", "native_register_extra_item", 1)
	register_native("zp_register_zombie_class", "native_register_zombie_class", 1)
	register_native("zp_get_extra_item_id", "native_get_extra_item_id", 1)
	register_native("zp_get_zombie_class_id", "native_get_zombie_class_id", 1)
	register_native("zp_get_zombie_class_info", "native_get_zombie_class_info", 1)
	
}

public plugin_precache()
{
	register_plugin("Zombie Plague 7.2.6", PLUGIN_VERSION, "MeRcyLeZZ - Edit: adamCSzombie")
	
	register_concmd("zp_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Zombie Plague (will restart the current map)", 0)
	cvar_toggle = register_cvar("zp_on", "1")
	
	if (!get_pcvar_num(cvar_toggle)) return;
	g_pluginenabled = true
	
	model_human = ArrayCreate(32, 1)
	model_nemesis = ArrayCreate(32, 1)
	model_survivor = ArrayCreate(32, 1)
	model_admin_human = ArrayCreate(32, 1)
	model_admin_zombie = ArrayCreate(32, 1)
	g_modelindex_human = ArrayCreate(1, 1)
	g_modelindex_nemesis = ArrayCreate(1, 1)
	g_modelindex_survivor = ArrayCreate(1, 1)
	g_modelindex_admin_human = ArrayCreate(1, 1)
	g_modelindex_admin_zombie = ArrayCreate(1, 1)
	sound_win_zombies = ArrayCreate(64, 1)
	sound_win_zombies_ismp3 = ArrayCreate(1, 1)
	sound_win_humans = ArrayCreate(64, 1)
	sound_win_humans_ismp3 = ArrayCreate(1, 1)
	sound_win_no_one = ArrayCreate(64, 1)
	sound_win_no_one_ismp3 = ArrayCreate(1, 1)
	zombie_infect = ArrayCreate(64, 1)
	zombie_pain = ArrayCreate(64, 1)
	nemesis_pain = ArrayCreate(64, 1)
	zombie_die = ArrayCreate(64, 1)
	zombie_fall = ArrayCreate(64, 1)
	zombie_miss_slash = ArrayCreate(64, 1)
	zombie_miss_wall = ArrayCreate(64, 1)
	zombie_hit_normal = ArrayCreate(64, 1)
	zombie_hit_stab = ArrayCreate(64, 1)
	zombie_idle = ArrayCreate(64, 1)
	human_idle = ArrayCreate(64, 1)
	zombie_idle_last = ArrayCreate(64, 1)
	zombie_madness = ArrayCreate(64, 1)
	sound_nemesis = ArrayCreate(64, 1)
	sound_survivor = ArrayCreate(64, 1)
	sound_swarm = ArrayCreate(64, 1)
	sound_multi = ArrayCreate(64, 1)
	sound_plague = ArrayCreate(64, 1)
	grenade_infect = ArrayCreate(64, 1)
	grenade_infect_player = ArrayCreate(64, 1)
	grenade_fire = ArrayCreate(64, 1)
	grenade_fire_player = ArrayCreate(64, 1)
	grenade_frost = ArrayCreate(64, 1)
	grenade_frost_player = ArrayCreate(64, 1)
	grenade_frost_break = ArrayCreate(64, 1)
	grenade_flare = ArrayCreate(64, 1)
	sound_antidote = ArrayCreate(64, 1)
	sound_thunder = ArrayCreate(64, 1)
	sound_firstzombie = ArrayCreate(64, 1)
	sound_ambience1 = ArrayCreate(64, 1)
	sound_ambience2 = ArrayCreate(64, 1)
	sound_ambience3 = ArrayCreate(64, 1)
	sound_ambience4 = ArrayCreate(64, 1)
	sound_ambience5 = ArrayCreate(64, 1)
	sound_ambience1_duration = ArrayCreate(1, 1)
	sound_ambience2_duration = ArrayCreate(1, 1)
	sound_ambience3_duration = ArrayCreate(1, 1)
	sound_ambience4_duration = ArrayCreate(1, 1)
	sound_ambience5_duration = ArrayCreate(1, 1)
	sound_ambience1_ismp3 = ArrayCreate(1, 1)
	sound_ambience2_ismp3 = ArrayCreate(1, 1)
	sound_ambience3_ismp3 = ArrayCreate(1, 1)
	sound_ambience4_ismp3 = ArrayCreate(1, 1)
	sound_ambience5_ismp3 = ArrayCreate(1, 1)
	g_primary_items = ArrayCreate(32, 1)
	g_secondary_items = ArrayCreate(32, 1)
	g_additional_items = ArrayCreate(32, 1)
	g_primary_weaponids = ArrayCreate(1, 1)
	g_secondary_weaponids = ArrayCreate(1, 1)
	g_extraweapon_names = ArrayCreate(32, 1)
	g_extraweapon_items = ArrayCreate(32, 1)
	g_extraweapon_costs = ArrayCreate(1, 1)
	g_sky_names = ArrayCreate(32, 1)
	lights_thunder = ArrayCreate(32, 1)
	zombie_decals = ArrayCreate(1, 1)
	g_objective_ents = ArrayCreate(32, 1)
	g_extraitem_name = ArrayCreate(32, 1)
	g_extraitem_cost = ArrayCreate(1, 1)
	g_extraitem_team = ArrayCreate(1, 1)
	g_extraitem2_realname = ArrayCreate(32, 1)
	g_extraitem2_name = ArrayCreate(32, 1)
	g_extraitem2_cost = ArrayCreate(1, 1)
	g_extraitem2_team = ArrayCreate(1, 1)
	g_extraitem_new = ArrayCreate(1, 1)
	g_zclass_name = ArrayCreate(32, 1)
	g_zclass_info = ArrayCreate(32, 1)
	g_zclass_modelsstart = ArrayCreate(1, 1)
	g_zclass_modelsend = ArrayCreate(1, 1)
	g_zclass_playermodel = ArrayCreate(32, 1)
	g_zclass_modelindex = ArrayCreate(1, 1)
	g_zclass_clawmodel = ArrayCreate(32, 1)
	g_zclass_hp = ArrayCreate(1, 1)
	g_zclass_spd = ArrayCreate(1, 1)
	g_zclass_grav = ArrayCreate(1, 1)
	g_zclass_kb = ArrayCreate(1, 1)
	g_zclass2_realname = ArrayCreate(32, 1)
	g_zclass2_name = ArrayCreate(32, 1)
	g_zclass2_info = ArrayCreate(32, 1)
	g_zclass2_modelsstart = ArrayCreate(1, 1)
	g_zclass2_modelsend = ArrayCreate(1, 1)
	g_zclass2_playermodel = ArrayCreate(32, 1)
	g_zclass2_modelindex = ArrayCreate(1, 1)
	g_zclass2_clawmodel = ArrayCreate(32, 1)
	g_zclass2_hp = ArrayCreate(1, 1)
	g_zclass2_spd = ArrayCreate(1, 1)
	g_zclass2_grav = ArrayCreate(1, 1)
	g_zclass2_kb = ArrayCreate(1, 1)
	g_zclass_new = ArrayCreate(1, 1)
	
	g_arrays_created = true
	
	load_customization_from_files()
	
	new i, buffer[100]
	
	native_register_extra_item2("NightVision", g_extra_costs2[EXTRA_NVISION], ZP_TEAM_HUMAN)
	native_register_extra_item2("T-Virus Antidote", g_extra_costs2[EXTRA_ANTIDOTE], ZP_TEAM_ZOMBIE)
	native_register_extra_item2("Zombie Madness", g_extra_costs2[EXTRA_MADNESS], ZP_TEAM_ZOMBIE)
	native_register_extra_item2("Infection Bomb", g_extra_costs2[EXTRA_INFBOMB], ZP_TEAM_ZOMBIE)
	
	for (i = 0; i < ArraySize(g_extraweapon_names); i++)
	{
		ArrayGetString(g_extraweapon_names, i, buffer, charsmax(buffer))
		native_register_extra_item2(buffer, ArrayGetCell(g_extraweapon_costs, i), ZP_TEAM_HUMAN)
	}
	
	for (i = 0; i < ArraySize(model_human); i++)
	{
		ArrayGetString(model_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_nemesis); i++)
	{
		ArrayGetString(model_nemesis, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_nemesis, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_survivor); i++)
	{
		ArrayGetString(model_survivor, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_survivor, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_admin_zombie); i++)
	{
		ArrayGetString(model_admin_zombie, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_zombie, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	for (i = 0; i < ArraySize(model_admin_human); i++)
	{
		ArrayGetString(model_admin_human, i, buffer, charsmax(buffer))
		format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", buffer, buffer)
		ArrayPushCell(g_modelindex_admin_human, engfunc(EngFunc_PrecacheModel, buffer))
		if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, buffer)
		if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, buffer)
		copy(buffer[strlen(buffer)-4], charsmax(buffer) - (strlen(buffer)-4), "T.mdl")
		if (file_exists(buffer)) engfunc(EngFunc_PrecacheModel, buffer)
	}
	
	engfunc(EngFunc_PrecacheModel, model_vknife_human)
	engfunc(EngFunc_PrecacheModel, model_vknife_nemesis)
	engfunc(EngFunc_PrecacheModel, model_vweapon_survivor)
	engfunc(EngFunc_PrecacheModel, model_grenade_infect)
	engfunc(EngFunc_PrecacheModel, model_grenade_fire)
	engfunc(EngFunc_PrecacheModel, model_grenade_frost)
	engfunc(EngFunc_PrecacheModel, model_grenade_flare)
	engfunc(EngFunc_PrecacheModel, model_vknife_admin_human)
	engfunc(EngFunc_PrecacheModel, model_vknife_admin_zombie)
	engfunc(EngFunc_PrecacheSound, vyber_humana)
	
	g_trailSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_trail)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_ring)
	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
	g_glassSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_glass)
	
	for (i = 0; i < ArraySize(sound_win_zombies); i++)
	{
		ArrayGetString(sound_win_zombies, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_zombies_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}
	for (i = 0; i < ArraySize(sound_win_humans); i++)
	{
		ArrayGetString(sound_win_humans, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_humans_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}
	for (i = 0; i < ArraySize(sound_win_no_one); i++)
	{
		ArrayGetString(sound_win_no_one, i, buffer, charsmax(buffer))
		if (ArrayGetCell(sound_win_no_one_ismp3, i))
		{
			format(buffer, charsmax(buffer), "sound/%s", buffer)
			engfunc(EngFunc_PrecacheGeneric, buffer)
		}
		else
		{
			engfunc(EngFunc_PrecacheSound, buffer)
		}
	}
	for (i = 0; i < ArraySize(zombie_infect); i++)
	{
		ArrayGetString(zombie_infect, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_pain); i++)
	{
		ArrayGetString(zombie_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(nemesis_pain); i++)
	{
		ArrayGetString(nemesis_pain, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_die); i++)
	{
		ArrayGetString(zombie_die, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_fall); i++)
	{
		ArrayGetString(zombie_fall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_miss_slash); i++)
	{
		ArrayGetString(zombie_miss_slash, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_miss_wall); i++)
	{
		ArrayGetString(zombie_miss_wall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_hit_normal); i++)
	{
		ArrayGetString(zombie_hit_normal, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_hit_stab); i++)
	{
		ArrayGetString(zombie_hit_stab, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_idle); i++)
	{
		ArrayGetString(zombie_idle, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(human_idle); i++)
	{
		ArrayGetString(human_idle, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_idle_last); i++)
	{
		ArrayGetString(zombie_idle_last, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(zombie_madness); i++)
	{
		ArrayGetString(zombie_madness, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_nemesis); i++)
	{
		ArrayGetString(sound_nemesis, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_survivor); i++)
	{
		ArrayGetString(sound_survivor, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_swarm); i++)
	{
		ArrayGetString(sound_swarm, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_multi); i++)
	{
		ArrayGetString(sound_multi, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_plague); i++)
	{
		ArrayGetString(sound_plague, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_infect); i++)
	{
		ArrayGetString(grenade_infect, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_infect_player); i++)
	{
		ArrayGetString(grenade_infect_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire); i++)
	{
		ArrayGetString(grenade_fire, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_fire_player); i++)
	{
		ArrayGetString(grenade_fire_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost); i++)
	{
		ArrayGetString(grenade_frost, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_player); i++)
	{
		ArrayGetString(grenade_frost_player, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_frost_break); i++)
	{
		ArrayGetString(grenade_frost_break, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(grenade_flare); i++)
	{
		ArrayGetString(grenade_flare, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_antidote); i++)
	{
		ArrayGetString(sound_antidote, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_firstzombie); i++)
	{
		ArrayGetString(sound_firstzombie, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_thunder); i++)
	{
		ArrayGetString(sound_thunder, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION])
	{
		for (i = 0; i < ArraySize(sound_ambience1); i++)
		{
			ArrayGetString(sound_ambience1, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience1_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS])
	{
		for (i = 0; i < ArraySize(sound_ambience2); i++)
		{
			ArrayGetString(sound_ambience2, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience2_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR])
	{
		for (i = 0; i < ArraySize(sound_ambience3); i++)
		{
			ArrayGetString(sound_ambience3, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience3_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM])
	{
		for (i = 0; i < ArraySize(sound_ambience4); i++)
		{
			ArrayGetString(sound_ambience4, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience4_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE])
	{
		for (i = 0; i < ArraySize(sound_ambience5); i++)
		{
			ArrayGetString(sound_ambience5, i, buffer, charsmax(buffer))
			
			if (ArrayGetCell(sound_ambience5_ismp3, i))
			{
				format(buffer, charsmax(buffer), "sound/%s", buffer)
				engfunc(EngFunc_PrecacheGeneric, buffer)
			}
			else
			{
				engfunc(EngFunc_PrecacheSound, buffer)
			}
		}
	}
	
	engfunc(EngFunc_PrecacheSound, sound_flashlight)
	engfunc(EngFunc_PrecacheSound, sound_buyammo)
	engfunc(EngFunc_PrecacheSound, sound_armorhit)
	
	new ent
	
	gSpr_regeneration = precache_model( "sprites/sleep.spr" );
	g_spr_resist = precache_model( "sprites/deimosexp.spr" );
	
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	
	if (g_ambience_fog)
	{
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
		if (pev_valid(ent))
		{
			fm_set_kvd(ent, "density", g_fog_density, "env_fog")
			fm_set_kvd(ent, "rendercolor", g_fog_color, "env_fog")
		}
	}
	if (g_ambience_rain) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))
	
	g_buyzone_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if (pev_valid(g_buyzone_ent))
	{
		dllfunc(DLLFunc_Spawn, g_buyzone_ent)
		set_pev(g_buyzone_ent, pev_solid, SOLID_NOT)
	}
	precache_sound( lasthuman_zvuk );
	precache_sound( sound_levelup );
	precache_sound( sound_buy );
	precache_sound( sound_upgrade );
	precache_sound( sound_legendary );
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
}

public plugin_end( ) {
	SQL_FreeHandle( SQL_TUPLE );
}

public plugin_init()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// No zombie classes?
	if (!g_zclass_i) set_fail_state("No zombie classes loaded!")
	
	// Language files
	register_dictionary("zombie_plague.txt")
	register_concmd( "MOJE_MENO", "cmdUser" );
	register_concmd( "MOJE_HESLO", "cmdPassword" );
	
	// Events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_logevent("logevent_round_start",2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_logevent("Round_End", 2, "1=Round_End")
	register_event("AmmoX", "event_ammo_x", "be")
	if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] || g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] || g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] || g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] || g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE])
		register_event("30", "event_intermission", "a")
	
	CvarHost = register_cvar( "csgo_host1", "db.mysql-01.gsp-europe.net" );
	CvarDatabase = register_cvar( "csgo_db1", "sql_5685" );
	CvarUser = register_cvar( "csgo_user1", "sql_5685" );
	CvarPassword = register_cvar( "csgo_pw1", "840Zy5OF1E7SdzXLYviyA48JvbEd6Yz" );
	
	get_pcvar_string( CvarHost, SQL_Host, charsmax( SQL_Host ) );
	get_pcvar_string( CvarDatabase, SQL_Database, charsmax( SQL_Database ) );
	get_pcvar_string( CvarUser, SQL_User, charsmax( SQL_User ) );
	get_pcvar_string( CvarPassword, SQL_Password, charsmax( SQL_Password ) );
	
	register_clcmd( "say /start", "starter_pack" );
	register_clcmd( "say /event", "event_menu" );
	// HAM Forwards
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled_Post", 1)
	RegisterHam(Ham_Killed, "player", "Hrac_Umrel", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_TakeDamage, "player", "takedamage_adrenalin",0)
	RegisterHam(Ham_TakeDamage,"player", "Hrac_Damage",0)
	//RegisterHam(Ham_TakeDamage,"player", "Adrenalin_Damage",0)
	RegisterHam( Ham_TakeDamage, "player", "ham_Player_TakeDamage_Post", 0 );
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_Player_ResetMaxSpeed, "player", "fw_ResetMaxSpeed_Post", 1)
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
	RegisterHam(Ham_Use, "func_pushable", "fw_UsePushable")
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_AddPlayerItem, "player", "fw_AddPlayerItem")
	RegisterHam(Ham_Spawn, "player", "Hrac_Spawn", 1)
	RegisterHam(Ham_Killed,"player","daj_level",1);
	RegisterHam(Ham_Killed, "player", "Fwd_PlayerKilled_Pre", 0)
	RegisterHam(Ham_Spawn, "player", "Fwd_PlayerSpawn_Post", 1)
	
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
	
	// FM Forwards
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect")
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
	register_forward(FM_ClientKill, "fw_ClientKill")
	register_forward(FM_EmitSound, "fw_EmitSound")
	if (!g_handle_models_on_separate_ent) register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPreThink, "FM_PreThink")
	unregister_forward(FM_Spawn, g_fwSpawn)
	unregister_forward(FM_PrecacheSound, g_fwPrecacheSound)
	
	register_logevent( "Round_Start", 2, "1=Round_Start" );
	
	// Client commands
	register_clcmd("say zpmenu", "clcmd_saymenu")
	register_clcmd("say /zpmenu", "clcmd_saymenu")
	register_clcmd("say unstuck", "clcmd_sayunstuck")
	register_clcmd("say /unstuck", "clcmd_sayunstuck")
	register_clcmd("nightvision", "clcmd_nightvision")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd( "say", "handle_say" );
	register_clcmd( "say_team", "handle_say" );
	register_clcmd("buyammo1", "clcmd_buyammo")
	register_clcmd("buyammo2", "clcmd_buyammo")
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	register_clcmd("say /rs", "reset_score")
	register_clcmd( "test", "test" );
	register_clcmd("get_special", "reg_menu")
	register_clcmd("pohodaaokksss","SetLvL", ADMIN_CVAR, "Pridanie lvlov")
	register_clcmd("pohodaaexpsss", "SetExp", ADMIN_CVAR, "Pridanie EXP" );
	register_clcmd( "say /aktivator", "aktivator_money_sk" );
	
	g_vault = nvault_open("xp_mod") // Vytvorime premennu pre otvorenie xp_mod nVault zlozky
	
	cvar_max_lvl = register_cvar("zp_maxlvl","10000")
	
	set_task( 30.0, "Reklama", 0, _, _,"b" )
	set_task( 30.0, "ProvocationSound", 0, _, _, "b" )
	
	register_menucmd(register_menuid("Menu_Lvl"),1023,"postava_items");
	
	// Menus
	register_menu("Game Menu", KEYSMENU, "menu_game")
	register_menu("Buy Menu 1", KEYSMENU, "vybrat_zbran")
	register_menu("Buy Menu 2", KEYSMENU, "vybrat_zbran2")
	register_menu("Mod Info", KEYSMENU, "menu_info")
	register_menu("Admin Menu", KEYSMENU, "menu_admin")
	
	// CS Buy Menus (to prevent zombies/survivor from buying)
	register_menucmd(register_menuid("#Buy", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuySub", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyItem", 1), 511, "menu_cs_buy")
	register_menucmd(-28, 511, "menu_cs_buy")
	register_menucmd(-29, 511, "menu_cs_buy")
	register_menucmd(-30, 511, "menu_cs_buy")
	register_menucmd(-32, 511, "menu_cs_buy")
	register_menucmd(-31, 511, "menu_cs_buy")
	register_menucmd(-33, 511, "menu_cs_buy")
	register_menucmd(-34, 511, "menu_cs_buy")
	register_event("CurWeapon" , "fw_EvCurWeapon" , "be" , "1=1")
	register_menucmd(register_menuid("\yVyber primarni zbrane 1/2:"), 1023, "handle_zbrane") 
	register_menucmd(register_menuid("\yVyber primarni zbrane 2/2:"), 1023, "handle_zbrane2")
	
	// Admin commands
	register_concmd("zp_zombie", "cmd_zombie", _, "<target> - Turn someone into a Zombie", 0)
	register_concmd("zp_human", "cmd_human", _, "<target> - Turn someone back to Human", 0)
	register_concmd("zp_nemesis", "cmd_nemesis", _, "<target> - Turn someone into a Nemesis", 0)
	register_concmd("zp_survivor", "cmd_survivor", _, "<target> - Turn someone into a Survivor", 0)
	register_concmd("zp_respawn", "cmd_respawn", _, "<target> - Respawn someone", 0)
	register_concmd("zp_swarm", "cmd_swarm", _, " - Start Swarm Mode", 0)
	register_concmd("zp_multi", "cmd_multi", _, " - Start Multi Infection", 0)
	register_concmd("zp_plague", "cmd_plague", _, " - Start Plague Mode", 0)
	
	// Message IDs
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgSetFOV = get_user_msgid("SetFOV")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	g_msgNVGToggle = get_user_msgid("NVGToggle")
	g_msgFlashlight = get_user_msgid("Flashlight")
	g_msgFlashBat = get_user_msgid("FlashBat")
	g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgDamage = get_user_msgid("Damage")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgSayText = get_user_msgid("SayText")
	g_msgCurWeapon = get_user_msgid("CurWeapon")
	
	// Message hooks
	register_message(g_msgCurWeapon, "message_cur_weapon")
	//register_message(get_user_msgid("Money"), "message_money")
	register_message(get_user_msgid("Health"), "message_health")
	register_message(g_msgFlashBat, "message_flashbat")
	register_message(g_msgScreenFade, "message_screenfade")
	register_message(g_msgNVGToggle, "message_nvgtoggle")
	if (g_handle_models_on_separate_ent) register_message(get_user_msgid("ClCorpse"), "message_clcorpse")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(get_user_msgid("TeamScore"), "message_teamscore")
	register_message(g_msgTeamInfo, "message_teaminfo")
	register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
	register_event("CurWeapon", "event_CurWeaponn", "be", "1=1")
	RegisterHam(Ham_TakeDamage, "player", "ham_TakeDamage")
	register_logevent( "zaciatok_kola", 2, "1=Round_Start" );
	
	// CVARS - General Purpose
	cvar_warmup = register_cvar("zp_delay", "10")
	cvar_lighting = register_cvar("zp_lighting", "")
	cvar_thunder = register_cvar("zp_thunderclap", "90")
	cvar_triggered = register_cvar("zp_triggered_lights", "1")
	cvar_removedoors = register_cvar("zp_remove_doors", "0")
	cvar_blockpushables = register_cvar("zp_blockuse_pushables", "1")
	cvar_blocksuicide = register_cvar("zp_block_suicide", "1")
	cvar_randspawn = register_cvar("zp_random_spawn", "1")
	cvar_removedropped = register_cvar("zp_remove_dropped", "0")
	cvar_removemoney = register_cvar("zp_remove_money", "1")
	cvar_buycustom = register_cvar("zp_buy_custom", "1")
	cvar_randweapons = register_cvar("zp_random_weapons", "0")
	cvar_adminmodelshuman = register_cvar("zp_admin_models_human", "1")
	cvar_adminknifemodelshuman = register_cvar("zp_admin_knife_models_human", "0")
	cvar_adminmodelszombie = register_cvar("zp_admin_models_zombie", "1")
	cvar_adminknifemodelszombie = register_cvar("zp_admin_knife_models_zombie", "0")
	cvar_zclasses = register_cvar("zp_zombie_classes", "1")
	cvar_statssave = register_cvar("zp_stats_save", "1")
	cvar_startammopacks = register_cvar("zp_starting_ammo_packs", "5")
	cvar_preventconsecutive = register_cvar("zp_prevent_consecutive_modes", "1")
	cvar_keephealthondisconnect = register_cvar("zp_keep_health_on_disconnect", "1")
	cvar_huddisplay = register_cvar("zp_hud_display", "1")
	
	g_pcvar_unhpcost = register_cvar( "zp_cena_hp", 		"500" );
	g_pcvar_unapcost = register_cvar( "zp_cena_armor", 		"750" );
	g_pcvar_undmcost = register_cvar( "zp_cena_damage", 		"500" );
	g_pcvar_undecost = register_cvar( "zp_cena_defense",		"850" );
	
	g_pcvar_unhpmult = register_cvar( "zp_nasobok_hp",		"500" );
	g_pcvar_unapmult = register_cvar( "zp_nasobok_armor",		"750" );
	g_pcvar_undmmult = register_cvar( "zp_nasobok_damage", 		"510" );
	g_pcvar_undemult = register_cvar( "zp_nasobok_defensen", 	"1250" );
	// CVARS - Deathmatch3
	cvar_deathmatch = register_cvar("zp_deathmatch", "0")
	cvar_spawndelay = register_cvar("zp_spawn_delay", "5")
	cvar_spawnprotection = register_cvar("zp_spawn_protection", "5")
	cvar_respawnonsuicide = register_cvar("zp_respawn_on_suicide", "0")
	cvar_respawnafterlast = register_cvar("zp_respawn_after_last_human", "1")
	cvar_allowrespawninfection = register_cvar("zp_infection_allow_respawn", "1")
	cvar_allowrespawnnem = register_cvar("zp_nem_allow_respawn", "0")
	cvar_allowrespawnsurv = register_cvar("zp_surv_allow_respawn", "0")
	cvar_allowrespawnswarm = register_cvar("zp_swarm_allow_respawn", "0")
	cvar_allowrespawnplague = register_cvar("zp_plague_allow_respawn", "0")
	cvar_respawnzomb = register_cvar("zp_respawn_zombies", "1")
	cvar_respawnhum = register_cvar("zp_respawn_humans", "1")
	cvar_respawnnem = register_cvar("zp_respawn_nemesis", "1")
	cvar_respawnsurv = register_cvar("zp_respawn_survivors", "1")
	
	// CVARS - Extra Items
	cvar_extraitems = register_cvar("zp_extra_items", "1")
	cvar_extraweapons = register_cvar("zp_extra_weapons", "1")
	cvar_extranvision = register_cvar("zp_extra_nvision", "1")
	cvar_extraantidote = register_cvar("zp_extra_antidote", "1")
	cvar_antidotelimit = register_cvar("zp_extra_antidote_limit", "999")
	cvar_extramadness = register_cvar("zp_extra_madness", "1")
	cvar_madnesslimit = register_cvar("zp_extra_madness_limit", "999")
	cvar_madnessduration = register_cvar("zp_extra_madness_duration", "5.0")
	cvar_extrainfbomb = register_cvar("zp_extra_infbomb", "1")
	cvar_infbomblimit = register_cvar("zp_extra_infbomb_limit", "999")
	
	// CVARS - Flashlight and Nightvision
	cvar_nvggive = register_cvar("zp_nvg_give", "1")
	cvar_customnvg = register_cvar("zp_nvg_custom", "1")
	cvar_nvgsize = register_cvar("zp_nvg_size", "80")
	cvar_nvgcolor[0] = register_cvar("zp_nvg_color_R", "0")
	cvar_nvgcolor[1] = register_cvar("zp_nvg_color_G", "150")
	cvar_nvgcolor[2] = register_cvar("zp_nvg_color_B", "0")
	cvar_humnvgcolor[0] = register_cvar("zp_nvg_hum_color_R", "0")
	cvar_humnvgcolor[1] = register_cvar("zp_nvg_hum_color_G", "150")
	cvar_humnvgcolor[2] = register_cvar("zp_nvg_hum_color_B", "0")
	cvar_nemnvgcolor[0] = register_cvar("zp_nvg_nem_color_R", "150")
	cvar_nemnvgcolor[1] = register_cvar("zp_nvg_nem_color_G", "0")
	cvar_nemnvgcolor[2] = register_cvar("zp_nvg_nem_color_B", "0")
	cvar_customflash = register_cvar("zp_flash_custom", "0")
	cvar_flashsize = register_cvar("zp_flash_size", "10")
	cvar_flashdrain = register_cvar("zp_flash_drain", "1")
	cvar_flashcharge = register_cvar("zp_flash_charge", "5")
	cvar_flashdist = register_cvar("zp_flash_distance", "1000")
	cvar_flashcolor[0] = register_cvar("zp_flash_color_R", "100")
	cvar_flashcolor[1] = register_cvar("zp_flash_color_G", "100")
	cvar_flashcolor[2] = register_cvar("zp_flash_color_B", "100")
	cvar_flashshowall = register_cvar("zp_flash_show_all", "1")
	
	// CVARS - Knockback
	cvar_knockback = register_cvar("zp_knockback", "0")
	cvar_knockbackdamage = register_cvar("zp_knockback_damage", "1")
	cvar_knockbackpower = register_cvar("zp_knockback_power", "1")
	cvar_knockbackzvel = register_cvar("zp_knockback_zvel", "0")
	cvar_knockbackducking = register_cvar("zp_knockback_ducking", "0.25")
	cvar_knockbackdist = register_cvar("zp_knockback_distance", "500")
	cvar_nemknockback = register_cvar("zp_knockback_nemesis", "0.25")
	
	// CVARS - Leap
	cvar_leapzombies = register_cvar("zp_leap_zombies", "0")
	cvar_leapzombiesforce = register_cvar("zp_leap_zombies_force", "500")
	cvar_leapzombiesheight = register_cvar("zp_leap_zombies_height", "300")
	cvar_leapzombiescooldown = register_cvar("zp_leap_zombies_cooldown", "5.0")
	cvar_leapnemesis = register_cvar("zp_leap_nemesis", "1")
	cvar_leapnemesisforce = register_cvar("zp_leap_nemesis_force", "500")
	cvar_leapnemesisheight = register_cvar("zp_leap_nemesis_height", "300")
	cvar_leapnemesiscooldown = register_cvar("zp_leap_nemesis_cooldown", "5.0")
	cvar_leapsurvivor = register_cvar("zp_leap_survivor", "0")
	cvar_leapsurvivorforce = register_cvar("zp_leap_survivor_force", "500")
	cvar_leapsurvivorheight = register_cvar("zp_leap_survivor_height", "300")
	cvar_leapsurvivorcooldown = register_cvar("zp_leap_survivor_cooldown", "5.0")
	
	// CVARS - Humans
	cvar_humanhp = register_cvar("zp_human_health", "100")
	cvar_humanlasthp = register_cvar("zp_human_last_extrahp", "0")
	cvar_humanspd = register_cvar("zp_human_speed", "240")
	cvar_humangravity = register_cvar("zp_human_gravity", "1.0")
	cvar_humanarmor = register_cvar("zp_human_armor_protect", "1")
	cvar_infammo = register_cvar("zp_human_unlimited_ammo", "0")
	cvar_ammodamage_human = register_cvar("zp_human_damage_reward", "500")
	cvar_fragskill = register_cvar("zp_human_frags_for_kill", "1")
	
	// CVARS - Custom Grenades
	cvar_firegrenades = register_cvar("zp_fire_grenades", "1")
	cvar_fireduration = register_cvar("zp_fire_duration", "10")
	cvar_firedamage = register_cvar("zp_fire_damage", "5")
	cvar_fireslowdown = register_cvar("zp_fire_slowdown", "0.5")
	cvar_frostgrenades = register_cvar("zp_frost_grenades", "1")
	cvar_freezeduration = register_cvar("zp_frost_duration", "3")
	cvar_flaregrenades = register_cvar("zp_flare_grenades","1")
	cvar_flareduration = register_cvar("zp_flare_duration", "60")
	cvar_flaresize = register_cvar("zp_flare_size", "25")
	cvar_flarecolor = register_cvar("zp_flare_color", "0")
	
	// CVARS - Zombies
	cvar_zombiefirsthp = register_cvar("zp_zombie_first_hp", "2.0")
	cvar_zombiearmor = register_cvar("zp_zombie_armor", "0.75")
	cvar_zombiearmor2 = register_cvar("zp_zombie_armor2", "250")
	cvar_hitzones = register_cvar("zp_zombie_hitzones", "0")
	cvar_zombiebonushp = register_cvar("zp_zombie_infect_health", "100")
	cvar_zombiefov = register_cvar("zp_zombie_fov", "110")
	cvar_zombiepainfree = register_cvar("zp_zombie_painfree", "1")
	cvar_zombiebleeding = register_cvar("zp_zombie_bleeding", "1")
	cvar_ammoinfect = register_cvar("zp_zombie_infect_reward", "1")
	cvar_ammodamage_zombie = register_cvar("zp_zombie_damage_reward", "0")
	cvar_fragsinfect = register_cvar("zp_zombie_frags_for_infect", "1")
	
	// CVARS - Special Effects
	cvar_infectionscreenfade = register_cvar("zp_infection_screenfade", "1")
	cvar_infectionscreenshake = register_cvar("zp_infection_screenshake", "1")
	cvar_infectionsparkle = register_cvar("zp_infection_sparkle", "1")
	cvar_infectiontracers = register_cvar("zp_infection_tracers", "1")
	cvar_infectionparticles = register_cvar("zp_infection_particles", "1")
	cvar_hudicons = register_cvar("zp_hud_icons", "1")
	
	// CVARS - Nemesis
	cvar_nem = register_cvar("zp_nem_enabled", "1")
	cvar_nemchance = register_cvar("zp_nem_chance", "20")
	cvar_nemminplayers = register_cvar("zp_nem_min_players", "0")
	cvar_nemhp = register_cvar("zp_nem_health", "0")
	cvar_nembasehp = register_cvar("zp_nem_base_health", "0")
	cvar_nemspd = register_cvar("zp_nem_speed", "250")
	cvar_nemgravity = register_cvar("zp_nem_gravity", "0.5")
	cvar_nemdamage = register_cvar("zp_nem_damage", "250")
	cvar_nemglow = register_cvar("zp_nem_glow", "1")
	cvar_nemaura = register_cvar("zp_nem_aura", "1")	
	cvar_nempainfree = register_cvar("zp_nem_painfree", "0")
	cvar_nemignorefrags = register_cvar("zp_nem_ignore_frags", "1")
	cvar_nemignoreammo = register_cvar("zp_nem_ignore_rewards", "1")
	
	// CVARS - Survivor
	cvar_surv = register_cvar("zp_surv_enabled", "1")
	cvar_survchance = register_cvar("zp_surv_chance", "20")
	cvar_survminplayers = register_cvar("zp_surv_min_players", "0")
	cvar_survhp = register_cvar("zp_surv_health", "0")
	cvar_survbasehp = register_cvar("zp_surv_base_health", "0")
	cvar_survspd = register_cvar("zp_surv_speed", "230")
	cvar_survgravity = register_cvar("zp_surv_gravity", "1.25")
	cvar_survglow = register_cvar("zp_surv_glow", "1")
	cvar_survaura = register_cvar("zp_surv_aura", "1")
	cvar_survpainfree = register_cvar("zp_surv_painfree", "1")
	cvar_survignorefrags = register_cvar("zp_surv_ignore_frags", "1")
	cvar_survignoreammo = register_cvar("zp_surv_ignore_rewards", "1")
	cvar_survweapon = register_cvar("zp_surv_weapon", "weapon_m249")
	cvar_survinfammo = register_cvar("zp_surv_unlimited_ammo", "2")
	
	// CVARS - Swarm Mode
	cvar_swarm = register_cvar("zp_swarm_enabled", "1")
	cvar_swarmchance = register_cvar("zp_swarm_chance", "20")
	cvar_swarmminplayers = register_cvar("zp_swarm_min_players", "0")
	
	// CVARS - Multi Infection
	cvar_multi = register_cvar("zp_multi_enabled", "1")
	cvar_multichance = register_cvar("zp_multi_chance", "20")
	cvar_multiminplayers = register_cvar("zp_multi_min_players", "0")
	cvar_multiratio = register_cvar("zp_multi_ratio", "0.15")
	
	// CVARS - Plague Mode
	cvar_plague = register_cvar("zp_plague_enabled", "1")
	cvar_plaguechance = register_cvar("zp_plague_chance", "30")
	cvar_plagueminplayers = register_cvar("zp_plague_min_players", "0")
	cvar_plagueratio = register_cvar("zp_plague_ratio", "0.5")
	cvar_plaguenemnum = register_cvar("zp_plague_nem_number", "1")
	cvar_plaguenemhpmulti = register_cvar("zp_plague_nem_hp_multi", "0.5")
	cvar_plaguesurvnum = register_cvar("zp_plague_surv_number", "1")
	cvar_plaguesurvhpmulti = register_cvar("zp_plague_surv_hp_multi", "0.5")
	
	// CVARS - Others
	cvar_logcommands = register_cvar("zp_logcommands", "1")
	cvar_showactivity = get_cvar_pointer("amx_show_activity")
	cvar_botquota = get_cvar_pointer("bot_quota")
	register_cvar("zp_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("zp_version", PLUGIN_VERSION)
	
	// Custom Forwards
	g_fwRoundStart = CreateMultiForward("zp_round_started", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwRoundEnd = CreateMultiForward("zp_round_ended", ET_IGNORE, FP_CELL)
	g_fwUserInfected_pre = CreateMultiForward("zp_user_infected_pre", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserInfected_post = CreateMultiForward("zp_user_infected_post", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanized_pre = CreateMultiForward("zp_user_humanized_pre", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserHumanized_post = CreateMultiForward("zp_user_humanized_post", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwUserInfect_attempt = CreateMultiForward("zp_user_infect_attempt", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	g_fwUserHumanize_attempt = CreateMultiForward("zp_user_humanize_attempt", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwExtraItemSelected = CreateMultiForward("zp_extra_item_selected", ET_CONTINUE, FP_CELL, FP_CELL)
	g_fwUserUnfrozen = CreateMultiForward("zp_user_unfrozen", ET_IGNORE, FP_CELL)
	g_fwUserLastZombie = CreateMultiForward("zp_user_last_zombie", ET_IGNORE, FP_CELL)
	g_fwUserLastHuman = CreateMultiForward("zp_user_last_human", ET_IGNORE, FP_CELL)
	
	set_task( 300.0, "Priklad", 0, _, _, "b" );
	// Collect random spawn points
	load_spawns()
	
	// Set a random skybox?
	if (g_sky_enable)
	{
		new sky[32]
		ArrayGetString(g_sky_names, random_num(0, ArraySize(g_sky_names) - 1), sky, charsmax(sky))
		set_cvar_string("sv_skyname", sky)
	}
	
	// Disable sky lighting so it doesn't mess with our custom lighting
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)
	
	register_event( "Money", "Event_Money", "b" );
	
	// Create the HUD Sync Objects
	g_MsgSync = CreateHudSyncObj()
	g_MsgSync2 = CreateHudSyncObj()
	g_MsgSync3 = CreateHudSyncObj()
	g_MsgSync4 = CreateHudSyncObj()
	g_MsgSync5 = CreateHudSyncObj()
	g_MsgSync6 = CreateHudSyncObj()
	g_MsgSync7 = CreateHudSyncObj()
	g_MsgSync8 = CreateHudSyncObj()
	g_msg_event = CreateHudSyncObj( );
	
	// Format mod name
	formatex(g_modname, charsmax(g_modname), "Zombie Mod %s", PLUGIN_VERSION)
	
	// Get Max Players
	g_maxplayers = get_maxplayers()
	
	// Reserved saving slots starts on maxplayers+1
	db_slot_i = g_maxplayers+1
	
	// Check if it's a CZ server
	new mymod[6]
	get_modname(mymod, charsmax(mymod))
	if (equal(mymod, "czero")) g_czero = 1
	//Other
	SQL_FirstLoad( );
}

public vip_vyhody( id )
{
	show_motd( id, "http://valiska.eu/zombie-chronic-1");
}

public plugin_cfg()
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Get configs dir
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	// Execute config file (zombieplague.cfg)
	server_cmd("exec %s/zombieplague.cfg", cfgdir)
	
	// Prevent any more stuff from registering
	g_arrays_created = false
	
	// Save customization data
	save_customization()
	
	// Lighting task
	set_task(5.0, "lighting_effects", _, _, _, "b")
	
	// Cache CVARs after configs are loaded / call roundstart manually
	set_task(0.5, "cache_cvars")
	set_task(0.5, "event_round_start")
	set_task(0.5, "logevent_round_start")
}

public Event_Money( id ) {
	if( is_user_connected( id ) )
	{
		cs_set_user_money( id, cs_get_user_money( id ) );
	}
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Main Events]
=================================================================================*/

// Event Round Start
public event_round_start()
{
	// Remove doors/lights?
	set_task(0.1, "remove_stuff")
	
	// New round starting
	g_newround = true
	g_endround = false
	g_survround = false
	g_nemround = false
	g_swarmround = false
	g_multiround = false
	g_plagueround = false
	g_modestarted = false
	
	// Reset bought infection bombs counter
	g_infbombcounter = 0
	g_antidotecounter = 0
	g_madnesscounter = 0
	
	// Freezetime begins
	g_freezetime = true
	
	// Show welcome message and T-Virus notice
	remove_task(TASK_WELCOMEMSG)
	set_task(2.0, "welcome_msg", TASK_WELCOMEMSG)
	
	// Set a new "Make Zombie Task"
	remove_task(TASK_LASTHUMAN)
	//
	remove_task(TASK_MAKEZOMBIE)
	set_task(2.0 + get_pcvar_float(cvar_warmup), "make_zombie_task", TASK_MAKEZOMBIE)
}

// Log Event Round Start
public logevent_round_start()
{
	// Freezetime ends
	g_freezetime = false
	last_human = 0
}

// Log Event Round End
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5) return;
	lastendtime = current_time
	
	// Temporarily save player stats?
	if (get_pcvar_num(cvar_statssave))
	{
		static id, team
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not connected
			if (!g_isconnected[id])
				continue;
			
			team = fm_cs_get_user_team(id)
			cs_set_user_armor( id, 0, CS_ARMOR_NONE)
			
			// Not playing
			if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
				continue;
			
			save_stats(id)
		}
	}
	
	// Round ended
	g_endround = true
	
	// Stop old tasks (if any)
	remove_task(TASK_WELCOMEMSG)
	remove_task(TASK_MAKEZOMBIE)
	//remove_task(id+672);
	
	// Stop ambience sounds
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround) || (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround) || (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		ambience_sound_stop()
	}
	
	// Show HUD notice, play win sound, update team scores...
	static sound[64]
	if (!fnGetZombies())
	{
		// Human team wins //2.0  = 5.0
		//set_dhudmessage(255, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 9.0, 5.0, 1.0, -1)
		set_dhudmessage( 255, 255, 255, -1.0, 0.10, 0, 8.0, 8.0 );
		show_dhudmessage(0, "%L", LANG_PLAYER, "WIN_HUMAN")
		
		// Play win sound and increase score, unless game commencing
		ArrayGetString(sound_win_humans, random_num(0, ArraySize(sound_win_humans) - 1), sound, charsmax(sound))
		PlaySound(sound)
		if (!g_gamecommencing) g_scorehumans++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_HUMAN);
	}
	else if (!fnGetHumans())
	{
		// Zombie team wins
		//set_dhudmessage(255, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 2.0, 6.0, 2.0)
		//set_dhudmessage(255, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 0, 0.0, 0.3, 0.0, 0.0)
		set_dhudmessage( 255, 255, 255, -1.0, 0.10, 0, 8.0, 8.0 );
		show_dhudmessage(0, "%L", LANG_PLAYER, "WIN_ZOMBIE")
		
		// Play win sound and increase score, unless game commencing
		ArrayGetString(sound_win_zombies, random_num(0, ArraySize(sound_win_zombies) - 1), sound, charsmax(sound))
		PlaySound(sound)
		if (!g_gamecommencing) g_scorezombies++
		
		// Round end forward
		ExecuteForward(g_fwRoundEnd, g_fwDummyResult, ZP_TEAM_ZOMBIE);
	}
	else
	{
		// No one wins
		//set_dhudmessage(255, 255, 255, HUD_EVENT_X, HUD_EVENT_Y, 1, 2.0, 6.0, 2.0)
		set_dhudmessage( 255, 255, 255, -1.0, 0.10, 0, 8.0, 8.0 );
		show_dhudmessage(0, "%L", LANG_PLAYER, "WIN_NO_ONE")
		
		// Play win sound
		ArrayGetString(sound_win_no_one, random_num(0, ArraySize(sound_win_no_one) - 1), sound, charsmax(sound))
		PlaySound(sound)
	}
	
	// Game commencing triggers round end
	g_gamecommencing = false
	
	// Balance the teams
	balance_teams()
}

// Event Map Ended
public event_intermission()
{
	// Remove ambience sounds task
	remove_task(TASK_AMBIENCESOUNDS)
}

// BP Ammo update
public event_ammo_x(id)
{
	// Humans only
	if (g_zombie[id])
		return;
	
	// Get ammo type
	static type
	type = read_data(1)
	
	// Unknown ammo type
	if (type >= sizeof AMMOWEAPON)
		return;
	
	// Get weapon's id
	static weapon
	weapon = AMMOWEAPON[type]
	
	// Primary and secondary only
	if (MAXBPAMMO[weapon] <= 2)
		return;
	
	// Get ammo amount
	static amount
	amount = read_data(2)
	
	// Unlimited BP Ammo?
	if (g_survivor[id] ? get_pcvar_num(cvar_survinfammo) : get_pcvar_num(cvar_infammo))
	{
		if (amount < MAXBPAMMO[weapon])
		{
			// The BP Ammo refill code causes the engine to send a message, but we
			// can't have that in this forward or we risk getting some recursion bugs.
			// For more info see: https://bugs.alliedmods.net/show_bug.cgi?id=3664
			static args[1]
			args[0] = weapon
			set_task(0.1, "refill_bpammo", id, args, sizeof args)
		}
	}
	// Bots automatically buy ammo when needed
	else if (g_isbot[id] && amount <= BUYAMMO[weapon])
	{
		// Task needed for the same reason as above
		set_task(0.1, "clcmd_buyammo", id)
	}
}

/*================================================================================
 [Main Forwards]
=================================================================================*/

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))
		
		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Ham Player Spawn Post Forward
public fw_PlayerSpawn_Post(id)
{
	// Not alive or didn't join a team yet
	if (!is_user_alive(id) || !fm_cs_get_user_team(id))
		return;
	
	// Player spawned
	gravita[id] = false
	speeda[id] = false
	g_isalive[id] = true
	zbrane[id] = 0
	water[id] = true
	scope[id] = true
	fired[id] = true
	iceha[id] = true
	snipe[id] = true
	rockg[id] = true
	m4a1[id] = true
	ak47[id] = true
	mp5[id] = true
	p90[id] = true
	aug[id] = true
	fam[id] = true
	m3[id] = true
	human_rip[id] = 0
	
	if( !g_zombie[ id ] ) {
		if( legendary_key[ id ] == 100 ) {
			get_pet( id );
		}
	}
	
	if( Logined[ id ] ) {
		if( start_pack_player[ id ] == 0 ) {
			for( new i = 0; i < 5; i++ ) {
				ChatColor( id, "%L", LANG_PLAYER, "NO_STARTERPACK" );
			}
		}
	}
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_NVISION)
	if (task_exists(id+TASK_SPAWN))
		remove_task(id+TASK_SPAWN)
	if (task_exists(id+TASK_ADD_ADRENALIN))
		remove_task(id+TASK_ADD_ADRENALIN)
	mazbran[id] = false
	
	adrenaline[id] = 0
	
	set_user_footsteps( id, 0 );
	
	set_task( 2.0, "respawn_player_check_task", id+TASK_SPAWN )
	
	// Spawn at a random location?
	if (get_pcvar_num(cvar_randspawn)) do_random_spawn(id)
	
	// Hide money?
	if (get_pcvar_num(cvar_removemoney))
		set_task(0.4, "task_hide_money", id+TASK_SPAWN)
	
	// Respawn player if he dies because of a worldspawn kill?
	/*if (get_pcvar_num(cvar_respawnworldspawnkill))
	{
		set_task( 2.0, "respawn_player_check_task", id+TASK_SPAWN )
	}*/
	// Spawn as zombie?
	if (g_respawn_as_zombie[id] && !g_newround)
	{
		reset_vars(id, 0) // reset player vars
		zombieme(id, 0, 0, 0, 0) // make him zombie right away
		return;
	}
	
	// Reset player vars
	reset_vars(id, 0)
	g_buytime[id] = get_gametime()
	
	// Show custom buy menu?
	//set_task(0.2, "show_menu_buy1", id+TASK_SPAWN)
	set_task(0.2, "vybrat_zbran", id+TASK_SPAWN)
	
	// Set health and gravity
	fm_set_user_health(id, get_pcvar_num(cvar_humanhp))
	set_pev(id, pev_gravity, get_pcvar_float(cvar_humangravity))
	
	// Set human maxspeed
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	
	// Switch to CT if spawning mid-round
	if (!g_newround && fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (get_pcvar_num(cvar_adminmodelshuman) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
		{
			iRand = random_num(0, ArraySize(model_admin_human) - 1)
			ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
		}
		else
		{
			iRand = random_num(0, ArraySize(model_human) - 1)
			ArrayGetString(model_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_human, iRand))
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Remove glow on player model entity
		fm_set_rendering(g_ent_playermodel[id])
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (get_pcvar_num(cvar_adminmodelshuman) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
		{
			size = ArraySize(model_admin_human)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
			}
		}
		else
		{
			size = ArraySize(model_human)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_human, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_human, iRand))
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Remove glow
		fm_set_rendering(id)
	}
	
	// Bots stuff
	if (g_isbot[id])
	{
		// Turn off NVG for bots
		cs_set_user_nvg(id, 0)
		
		// Automatically buy extra items/weapons after first zombie is chosen
		if (get_pcvar_num(cvar_extraitems))
		{
			if (g_newround) set_task(10.0 + get_pcvar_float(cvar_warmup), "bot_buy_extras", id+TASK_SPAWN)
			else set_task(10.0, "bot_buy_extras", id+TASK_SPAWN)
		}
	}
	
	// Enable spawn protection for humans spawning mid-round
	if (!g_newround && get_pcvar_float(cvar_spawnprotection) > 0.0)
	{
		// Do not take damage
		g_nodamage[id] = true
		
		// Make temporarily invisible
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
		
		// Set task to remove it
		set_task(get_pcvar_float(cvar_spawnprotection), "remove_spawn_protection", id+TASK_SPAWN)
	}
	
	// Turn off his flashlight (prevents double flashlight bug/exploit)
	turn_off_flashlight(id)
	
	// Set the flashlight charge task to update battery status
	if (g_cached_customflash)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	
	// Replace weapon models (bugfix)
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Ham Player Killed Forward
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	// Player killed
	g_isalive[victim] = false
	// Disable nodamage mode after we die to prevent spectator nightvision using zombie madness colors bug
	g_nodamage[victim] = false
	
	// Enable dead players nightvision
	set_task(0.1, "spec_nvision", victim)
	
	// Disable nightvision when killed (bugfix)
	if (get_pcvar_num(cvar_nvggive) == 0 && g_nvision[victim])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(victim+TASK_NVISION)
		else if (g_nvisionenabled[victim]) set_user_gnvision(victim, 0)
		g_nvision[victim] = false
		g_nvisionenabled[victim] = false
	}
	
	// Turn off nightvision when killed (bugfix)
	if (get_pcvar_num(cvar_nvggive) == 2 && g_nvision[victim] && g_nvisionenabled[victim])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(victim+TASK_NVISION)
		else set_user_gnvision(victim, 0)
		g_nvisionenabled[victim] = false
	}
	
	// Turn off custom flashlight when killed
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[victim] = false
		g_flashbattery[victim] = 100
		
		// Remove previous tasks
		remove_task(victim+TASK_CHARGE)
		remove_task(victim+TASK_FLASH)
	}
	
	// Stop bleeding/burning/aura when killed
	if (g_zombie[victim])
	{
		remove_task(victim+TASK_BLOOD)
		remove_task(victim+TASK_AURA)
		remove_task(victim+TASK_BURN)
	}
	
	// Survivor
	if (g_survivor[victim])
		SetHamParamInteger(3, 2)
	if (g_nemesis[victim])
		SetHamParamInteger(3, 2)
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Killed by a non-player entity or self killed
	if (selfkill) return;
	
	// Ignore Nemesis/Survivor Frags?
	if ((g_nemesis[attacker] && get_pcvar_num(cvar_nemignorefrags)) || (g_survivor[attacker] && get_pcvar_num(cvar_survignorefrags)))
		RemoveFrags(attacker, victim)
	
	// Zombie/nemesis killed human, reward ammo packs
	if (g_zombie[attacker] && (!g_nemesis[attacker] || !get_pcvar_num(cvar_nemignoreammo)))
		g_ammopacks[attacker] += get_pcvar_num(cvar_ammoinfect)
	
	// Human killed zombie, add up the extra frags for kill
	if (!g_zombie[attacker] && get_pcvar_num(cvar_fragskill) > 1)
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragskill) - 1, 0, 0)
	
	// Zombie killed human, add up the extra frags for kill
	if (g_zombie[attacker] && get_pcvar_num(cvar_fragsinfect) > 1)
		UpdateFrags(attacker, victim, get_pcvar_num(cvar_fragsinfect) - 1, 0, 0)
}

// Ham Player Killed Post Forward
public fw_PlayerKilled_Post(victim, attacker, shouldgib)
{
	// Last Zombie Check
	fnCheckLastZombie()
	
	// Determine whether the player killed himself
	static selfkill
	selfkill = (victim == attacker || !is_user_valid_connected(attacker)) ? true : false
	
	// Respawn if deathmatch is enabled
	if (get_pcvar_num(cvar_deathmatch))
	{
		// Respawn on suicide?
		if (selfkill && !get_pcvar_num(cvar_respawnonsuicide))
			return;
		
		// Respawn if human/zombie/nemesis/survivor?
		if ((g_zombie[victim] && !g_nemesis[victim] && !get_pcvar_num(cvar_respawnzomb)) || (!g_zombie[victim] && !g_survivor[victim] && !get_pcvar_num(cvar_respawnhum)) || (g_nemesis[victim] && !get_pcvar_num(cvar_respawnnem)) || (g_survivor[victim] && !get_pcvar_num(cvar_respawnsurv)))
			return;
		
		// Set the respawn task
		set_task(get_pcvar_float(cvar_spawndelay), "respawn_player_task", victim+TASK_SPAWN)
	}
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	if (g_nodamage[victim])
		return HAM_SUPERCEDE;
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
	// No slowdown
	if (g_firstzombie[victim])
	{
			set_pdata_float(attacker, fPainShock, 1.0, 5)
	}
	// Attacker is human...
	if (!g_zombie[attacker])
	{
		// Armor multiplier for the final damage on normal zombies
		if (!g_nemesis[victim])
		{
			damage *= get_pcvar_float(cvar_zombiearmor)
			SetHamParamFloat(4, damage)
		}
		
		// Reward ammo packs to humans for damaging zombies?
		if ((get_pcvar_num(cvar_ammodamage_human) > 0) && (!g_survivor[attacker] || !get_pcvar_num(cvar_survignoreammo)))
		{
			// Store damage dealt
			g_damagedealt_human[attacker] += floatround(damage)
			
			// Reward ammo packs for every [ammo damage] dealt
			while (g_damagedealt_human[attacker] > get_pcvar_num(cvar_ammodamage_human))
			{
				g_ammopacks[attacker]++
				g_damagedealt_human[attacker] -= get_pcvar_num(cvar_ammodamage_human)
			}
		}
		
		return HAM_IGNORED;
	}
	
	// Attacker is zombie...
	
	// Prevent infection/damage by HE grenade (bugfix)
	if (damage_type & DMG_HEGRENADE)
		return HAM_SUPERCEDE;
	
	// Nemesis?
	if (g_nemesis[attacker])
	{
		// Ignore nemesis damage override if damage comes from a 3rd party entity
		// (to prevent this from affecting a sub-plugin's rockets e.g.)
		if (inflictor == attacker)
		{
			// Set nemesis damage
			SetHamParamFloat(4, get_pcvar_float(cvar_nemdamage))
		}
		
		return HAM_IGNORED;
	}
	if( g_survivor[ victim ] )
		return HAM_IGNORED;
	// First Zombie Inf. adamCSzombie
	if (get_pcvar_num(cvar_humanarmor) )
	{
		if( !g_firstzombie[attacker] )
		{
			if( !g_lasthuman[victim] )
			{
					// Get victim armor
					static Float:armor
					pev(victim, pev_armorvalue, armor)
					
					// If he has some, block the infection and reduce armor instead
					if (armor > 0.0)
					{
						emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
						if (armor - damage > 0.0)
							set_pev(victim, pev_armorvalue, armor - damage)
						else
							cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
						return HAM_SUPERCEDE;
				}
			}
		} 
		else 
		{
			if( imune_human[victim] )
			{
				// Get victim armor
				static Float:armor
				pev(victim, pev_armorvalue, armor)
				
				// If he has some, block the infection and reduce armor instead
				if (armor > 0.0)
				{
					emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
					if (armor - damage > 0.0)
						set_pev(victim, pev_armorvalue, armor - damage)
					else
						cs_set_user_armor(victim, 0, CS_ARMOR_NONE)
					return HAM_SUPERCEDE;
				}
			}
			
		}
		
	}
	
	// Reward ammo packs to zombies for damaging humans?
	if (get_pcvar_num(cvar_ammodamage_zombie) > 0)
	{
		// Store damage dealt
		g_damagedealt_zombie[attacker] += floatround(damage)
		
		// Reward ammo packs for every [ammo damage] dealt
		while (g_damagedealt_zombie[attacker] > get_pcvar_num(cvar_ammodamage_zombie))
		{
			g_ammopacks[attacker]++
			g_damagedealt_zombie[attacker] -= get_pcvar_num(cvar_ammodamage_zombie)
		}
	}
	
	// Last human or not an infection round
	if (g_survround || g_nemround || g_swarmround || g_plagueround || fnGetHumans() == 1)
		return HAM_IGNORED; // human is killed
	
	// Infection allowed
	zombieme(victim, attacker, 0, 0, 1) // turn into zombie
	return HAM_SUPERCEDE;
}

public fw_TakeDamage_Post( victim ) {
	if( pev_valid( victim ) != PDATA_SAFE )
		return;
	if( g_zombie[ victim ] ) {
		if( g_nemesis[ victim ] ) {
			set_pdata_float( victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX );
		} else if( g_firstzombie[ victim ] ) {
			set_pdata_float( victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX );
		} else if( g_epicUltimate[ victim ] ) {
			set_pdata_float( victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX );
		}
	}
}

// Ham Trace Attack Forward
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type)
{
	// Non-player damage or self damage
	if (victim == attacker || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
	
	// New round starting or round ended
	if (g_newround || g_endround)
		return HAM_SUPERCEDE;
	
	// Victim shouldn't take damage or victim is frozen
	/*if (g_nodamage[victim] || g_frozen[victim])
		return HAM_SUPERCEDE;*/
	
	// Prevent friendly fire
	if (g_zombie[attacker] == g_zombie[victim])
		return HAM_SUPERCEDE;
	
	// Victim isn't a zombie or not bullet damage, nothing else to do here
	if (!g_zombie[victim] || !(damage_type & DMG_BULLET))
		return HAM_IGNORED;
	
	// If zombie hitzones are enabled, check whether we hit an allowed one
	if (get_pcvar_num(cvar_hitzones) && !g_nemesis[victim] && !(get_pcvar_num(cvar_hitzones) & (1<<get_tr2(tracehandle, TR_iHitgroup))))
		return HAM_SUPERCEDE;
	
	// Knockback disabled, nothing else to do here
	if (!get_pcvar_num(cvar_knockback))
		return HAM_IGNORED;
	
	// Nemesis knockback disabled, nothing else to do here
	if (g_nemesis[victim] && get_pcvar_float(cvar_nemknockback) == 0.0)
		return HAM_IGNORED;
	
	// Get whether the victim is in a crouch state
	static ducking
	ducking = pev(victim, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)
	
	// Zombie knockback when ducking disabled
	if (ducking && get_pcvar_float(cvar_knockbackducking) == 0.0)
		return HAM_IGNORED;
	
	// Get distance between players
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > get_pcvar_num(cvar_knockbackdist))
		return HAM_IGNORED;
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Use damage on knockback calculation
	if (get_pcvar_num(cvar_knockbackdamage))
		xs_vec_mul_scalar(direction, damage, direction)
	
	// Use weapon power on knockback calculation
	if (get_pcvar_num(cvar_knockbackpower) && kb_weapon_power[g_currentweapon[attacker]] > 0.0)
		xs_vec_mul_scalar(direction, kb_weapon_power[g_currentweapon[attacker]], direction)
	
	// Apply ducking knockback multiplier
	if (ducking)
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_knockbackducking), direction)
	
	// Apply zombie class/nemesis knockback multiplier
	if (g_nemesis[victim])
		xs_vec_mul_scalar(direction, get_pcvar_float(cvar_nemknockback), direction)
	else
		xs_vec_mul_scalar(direction, g_zombie_knockback[victim], direction)
	
	// Add up the new vector
	xs_vec_add(velocity, direction, direction)
	
	// Should knockback also affect vertical velocity?
	if (!get_pcvar_num(cvar_knockbackzvel))
		direction[2] = velocity[2]
	
	// Set the knockback'd victim's velocity
	set_pev(victim, pev_velocity, direction)
	
	return HAM_IGNORED;
}

// Ham Reset MaxSpeed Post Forward
public fw_ResetMaxSpeed_Post(id)
{
	// Freezetime active or player not alive
	if (g_freezetime || !g_isalive[id])
		return;
	
	set_player_maxspeed(id)
}

// Ham Use Stationary Gun Forward
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Post Forward
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
		replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Use Pushable Forward
public fw_UsePushable()
{
	// Prevent speed bug with pushables?
	if (get_pcvar_num(cvar_blockpushables))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Touch Forward
public fw_TouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id))
		return HAM_IGNORED;
	
	// Dont pickup weapons if zombie or survivor (+PODBot MM fix)
	if (g_zombie[id] || g_survivor[id])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Weapon Pickup Forward
public fw_AddPlayerItem(id, weapon_ent)
{
	// HACK: Retrieve our custom extra ammo from the weapon
	static extra_ammo
	extra_ammo = pev(weapon_ent, PEV_ADDITIONAL_AMMO)
	
	// If present
	if (extra_ammo)
	{
		// Get weapon's id
		static weaponid
		weaponid = cs_get_weapon_id(weapon_ent)
		
		// Add to player's bpammo
		ExecuteHamB(Ham_GiveAmmo, id, extra_ammo, AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, 0)
	}
}

// Ham Weapon Deploy Forward
public fw_Item_Deploy_Post(weapon_ent)
{
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Valid owner?
	if (!pev_valid(owner))
		return;
	
	// Get weapon's id
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)
	
	// Store current weapon's id for reference
	g_currentweapon[owner] = weaponid
	
	// Replace weapon models with custom ones
	replace_weapon_models(owner, weaponid)
	
	// Zombie not holding an allowed weapon for some reason
	if (g_zombie[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		// Switch to knife
		g_currentweapon[owner] = CSW_KNIFE
		engclient_cmd(owner, "weapon_knife")
	}
}

// WeaponMod bugfix
//forward wpn_gi_reset_weapon(id);
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// Client joins the game
public client_putinserver(id)
{
	// Plugin disabled?
	if (!g_pluginenabled) return;
	
	// Player joined
	g_isconnected[id] = true
	g_player_lang[id] = 0;
	get_user_authid(id, Name[id], 31);
	fast_human[id] = false
	exp_human[id] = false
	start_human[id] = true
	gravity_human[id] = false
	strong_human[id] = false
	frost_human[id] = false
	damage_human[id] = false
	adrenal_human[id] = false
	minigun_human[id] = false
	special_human[id] = false
	spirit_human[id] = false
	imune_human[id] = false
	speeda[id] = false
	gravita[id] = false
	pohlad[id] = false
	defense_human[ id ] = false;
	points_human[ id ] = false;
	expcase_human[ id ] = false;	
	UserLoad[id] = 0;
	Nacitat( id );
	inProgress[id] = 0;
	SQL_RegCheck( id );
	Logined[id] = false;
	//copy(Password[id], 31, "");
	//copy(User[id], 31, "");
	Activity[id] = 0;
	set_task(1.0, "task_Main", id, _, _, "b")
	
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	// Initialize player vars
	reset_vars(id, 1)
	
	// Load player stats?
	if (get_pcvar_num(cvar_statssave)) load_stats(id)
	
	// Set some tasks for humans only
	if (!is_user_bot(id))
	{
		// Set the custom HUD display task if enabled
		if (get_pcvar_num(cvar_huddisplay))
			set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
		
		// Disable minmodels for clients to see zombies properly
		set_task(5.0, "disable_minmodels", id)
	}
	else
	{
		// Set bot flag
		g_isbot[id] = true
		
		// CZ bots seem to use a different "classtype" for player entities
		// (or something like that) which needs to be hooked separately
		if (!g_hamczbots && cvar_botquota)
		{
			// Set a task to let the private data initialize
			set_task(0.1, "register_ham_czbots", id)
		}
	}
	if( !is_user_bot( id ) )
		return;
	players++;
}

// Client leaving
public fw_ClientDisconnect(id)
{
	// Check that we still have both humans and zombies to keep the round going
	if (g_isalive[id]) check_round(id)
	
	// Temporarily save player stats?
	if (get_pcvar_num(cvar_statssave)) save_stats(id)
	
	// Remove previous tasks
	remove_task(id+TASK_TEAM)
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_FLASH)
	remove_task(id+TASK_CHARGE)
	remove_task(id+TASK_SPAWN)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	remove_task(id+TASK_SHOWHUD)
	
	if(Logined[id])
	{
		Logined[id] = false;
		Activity[id] = 0;
		SQL_UpdateActivity(id);
		log_amx("asdsdadsadsa");
	}
	
	if (g_handle_models_on_separate_ent)
	{
		// Remove custom model entities
		fm_remove_model_ents(id)
	}
	
	// Player left, clear cached flags
	g_isconnected[id] = false
	g_isbot[id] = false
	g_isalive[id] = false
	if( !is_user_bot( id ) )
		return;
	players--;
}

// Client left
public fw_ClientDisconnect_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Client Kill Forward
public fw_ClientKill()
{
	// Prevent players from killing themselves?
	if (get_pcvar_num(cvar_blocksuicide))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Emit Sound Forward
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	// Replace these next sounds for zombies only
	if (!is_user_valid_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;
	
	static sound[64]
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if (g_nemesis[id])
		{
			ArrayGetString(nemesis_pain, random_num(0, ArraySize(nemesis_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		else
		{
			ArrayGetString(zombie_pain, random_num(0, ArraySize(zombie_pain) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
		}
		return FMRES_SUPERCEDE;
	}
	
	// Zombie attacks with knife
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			ArrayGetString(zombie_miss_slash, random_num(0, ArraySize(zombie_miss_slash) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				ArrayGetString(zombie_miss_wall, random_num(0, ArraySize(zombie_miss_wall) - 1), sound, charsmax(sound))
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
			else
			{
				ArrayGetString(zombie_hit_normal, random_num(0, ArraySize(zombie_hit_normal) - 1), sound, charsmax(sound))
				emit_sound(id, channel, sound, volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			ArrayGetString(zombie_hit_stab, random_num(0, ArraySize(zombie_hit_stab) - 1), sound, charsmax(sound))
			emit_sound(id, channel, sound, volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		ArrayGetString(zombie_die, random_num(0, ArraySize(zombie_die) - 1), sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie falls off
	if (sample[10] == 'f' && sample[11] == 'a' && sample[12] == 'l' && sample[13] == 'l')
	{
		ArrayGetString(zombie_fall, random_num(0, ArraySize(zombie_fall) - 1), sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

// Forward Set ClientKey Value -prevent CS from changing player models-
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	// Block CS model changes
	if (key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Forward Client User Info Changed -prevent players from changing models-
public fw_ClientUserInfoChanged(id)
{
	// Cache player's name
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	if (!g_handle_models_on_separate_ent)
	{
		// Get current model
		static currentmodel[32]
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// If they're different, set model again
		if (!equal(currentmodel, g_playermodel[id]) && !task_exists(id+TASK_MODEL))
			fm_cs_set_user_model(id+TASK_MODEL)
	}
}

public test( id ) {
	for( new i = 0; i < 10; i++ ) {
		client_print( id, print_console, "%s", lang[ 0 ][ i ]  );
	}
	
}

public reg_menu( id ) {
	
	if( ServerLoaded == 0 ) {
		ChatColor( id, "%s", lang[ 6 ][ g_player_lang[ id ] ] );
		return PLUGIN_HANDLED;	
	}
	new Text[ 555 char ];
	new hm = menu_create( lang[ 1 ][ g_player_lang[ id ] ], "register_menu_handle" );
	
	if( strlen( User[ id ] ) > 0 ) {
		formatex( Text, charsmax( Text ), "%s%s", lang[ 2 ][ g_player_lang[ id ] ], User[ id ] );
		menu_additem( hm, Text, "1" );
		formatex( Text, charsmax( Text ), "%s%s^n", lang[ 3 ][ g_player_lang[ id ] ], Password[ id ] );
		menu_additem( hm, Text, "2" );
	} else {
		formatex( Text, charsmax( Text ), "%s%s", lang[ 9 ][ g_player_lang[ id ] ], User[ id ] );
		menu_additem( hm, Text, "1" );
	}
	if( strlen( User[ id ] ) > 0 && strlen( Password[ id ] ) > 0 && UserLoad[ id ] == 0 && inProgress[ id ] == 0 ) {
		if( Found[ id ] == 1 ) {
			formatex( Text, charsmax( Text ), "%s^n", lang[ 5 ][ g_player_lang[ id ] ] );
			menu_additem( hm, Text, "3" );
		} else {
			formatex( Text, charsmax( Text ), "%s^n", lang[ 6 ][ g_player_lang[ id ] ] );
			menu_additem( hm, Text, "4" );
		}
	}
	formatex( Text, charsmax( Text ), "%s", lang[ 4 ][ g_player_lang[ id ] ] );
	menu_additem( hm, Text, "5" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
	
}

public register_menu_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	new data[ 14 ], line[ 32 ], access1, callback;
	menu_item_getinfo( menu, item, access1, data, charsmax( data ), line, charsmax( line ), callback );
	new buttom = str_to_num( data );
	
	switch( buttom ) {
		case 1: {
			client_cmd( id, "messagemode MOJE_MENO" );
			reg_menu( id );
		}
		case 2: {
			client_cmd( id, "messagemode MOJE_HESLO" );
			reg_menu( id );
		}
		case 3: {
			if( inProgress[ id ] == 0 ) {
				inProgress[ id ] = 1;
				ChatColor( id, "%s", lang[ 8 ][ g_player_lang[ id ] ] );
				RegisterMod[ id ] = 1;
				SQL_Check( id );
				reg_menu( id );
			} else {
				reg_menu( id );
			}
		}
		case 4: {
			if( inProgress[ id ] == 0 ) {
				inProgress[ id ] = 1;
				ChatColor( id, "%s", lang[ 10 ][ g_player_lang[ id ] ] );
				RegisterMod[ id ] = 2;
				SQL_Check( id );
				reg_menu( id );
			} else {
				reg_menu( id );
			}
		}
		case 5: {
			if( g_player_lang[ id ] == 0 ) {
				g_player_lang[ id ] = 1;
				reg_menu( id );
			} else if( g_player_lang[ id ] == 1 ) {
				g_player_lang[ id ] = 2;
				reg_menu( id );
			} else {
				g_player_lang[ id ] = 0;
				reg_menu( id );
			}
		}
	}
	return PLUGIN_HANDLED;
}

// Forward Get Game Description
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, g_modname)
	
	return FMRES_SUPERCEDE;
}

// Forward Set Model
public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return;
	
	// Remove weapons?
	if (get_pcvar_float(cvar_removedropped) > 0.0)
	{
		// Get entity's classname
		static classname[10]
		pev(entity, pev_classname, classname, charsmax(classname))
		
		// Check if it's a weapon box
		if (equal(classname, "weaponbox"))
		{
			// They get automatically removed when thinking
			set_pev(entity, pev_nextthink, get_gametime() + get_pcvar_float(cvar_removedropped))
			return;
		}
	}
	
	// Narrow down our matches a bit
	if (model[7] != 'w' || model[8] != '_')
		return;
	
	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return;
	
	// Get whether grenade's owner is a zombie
	if (g_zombie[pev(entity, pev_owner)])
	{
		if (model[9] == 'h' && model[10] == 'e' && get_pcvar_num(cvar_extrainfbomb)) // Infection Bomb
		{
			// Give it a glow
			fm_set_rendering(entity, kRenderFxGlowShell, 0, 200, 0, kRenderNormal, 16);
			
			// And a colored trail
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(0) // r
			write_byte(200) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			// Set grenade type on the thrown grenade entity
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_INFECTION)
		}
	}
	else if (model[9] == 'h' && model[10] == 'e' && get_pcvar_num(cvar_firegrenades)) // Napalm Grenade
	{
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 165, 45, 45, kRenderNormal, 16);
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(165) // r
		write_byte(65) // g
		write_byte(65) // b
		write_byte(200) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_NAPALM)
	}
	else if (model[9] == 'f' && model[10] == 'l' && get_pcvar_num(cvar_frostgrenades)) // Frost Grenade
	{
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, 45, 45, 165, kRenderNormal, 16);
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(0) // r
		write_byte(45) // g
		write_byte(45) // b
		write_byte(165) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FROST)
	}
	else if (model[9] == 's' && model[10] == 'm' && get_pcvar_num(cvar_flaregrenades)) // Flare
	{
		// Build flare's color
		static rgb[3]
		switch (get_pcvar_num(cvar_flarecolor))
		{
			case 0: // white
			{
				rgb[0] = 255 // r
				rgb[1] = 255 // g
				rgb[2] = 255 // b
			}
			case 1: // red
			{
				rgb[0] = random_num(50,255) // r
				rgb[1] = 0 // g
				rgb[2] = 0 // b
			}
			case 2: // green
			{
				rgb[0] = 0 // r
				rgb[1] = random_num(50,255) // g
				rgb[2] = 0 // b
			}
			case 3: // blue
			{
				rgb[0] = 0 // r
				rgb[1] = 0 // g
				rgb[2] = random_num(50,255) // b
			}
			case 4: // random (all colors)
			{
				rgb[0] = random_num(50,200) // r
				rgb[1] = random_num(50,200) // g
				rgb[2] = random_num(50,200) // b
			}
			case 5: // random (r,g,b)
			{
				switch (random_num(1, 3))
				{
					case 1: // red
					{
						rgb[0] = random_num(50,255) // r
						rgb[1] = 0 // g
						rgb[2] = 0 // b
					}
					case 2: // green
					{
						rgb[0] = 0 // r
						rgb[1] = random_num(50,255) // g
						rgb[2] = 0 // b
					}
					case 3: // blue
					{
						rgb[0] = 0 // r
						rgb[1] = 0 // g
						rgb[2] = random_num(50,255) // b
					}
				}
			}
		}
		
		// Give it a glow
		fm_set_rendering(entity, kRenderFxGlowShell, rgb[0], rgb[1], rgb[2], kRenderNormal, 16);
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW) // TE id
		write_short(entity) // entity
		write_short(g_trailSpr) // sprite
		write_byte(10) // life
		write_byte(10) // width
		write_byte(rgb[0]) // r
		write_byte(rgb[1]) // g
		write_byte(rgb[2]) // b
		write_byte(200) // brightness
		message_end()
		
		// Set grenade type on the thrown grenade entity
		set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FLARE)
		
		// Set flare color on the thrown grenade entity
		set_pev(entity, PEV_FLARE_COLOR, rgb)
	}
}

// Ham Grenade Think Forward
public fw_ThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return HAM_IGNORED;
	
	// Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	// Check if it's time to go off
	if (dmgtime > current_time)
		return HAM_IGNORED;
	
	// Check if it's one of our custom nades
	switch (pev(entity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION: // Infection Bomb
		{
			infection_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_NAPALM: // Napalm Grenade
		{
			fire_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FROST: // Frost Grenade
		{
			frost_explode(entity)
			return HAM_SUPERCEDE;
		}
		case NADE_TYPE_FLARE: // Flare
		{
			// Get its duration
			static duration
			duration = pev(entity, PEV_FLARE_DURATION)
			
			// Already went off, do lighting loop for the duration of PEV_FLARE_DURATION
			if (duration > 0)
			{
				// Check whether this is the last loop
				if (duration == 1)
				{
					// Get rid of the flare entity
					engfunc(EngFunc_RemoveEntity, entity)
					return HAM_SUPERCEDE;
				}
				
				// Light it up!
				flare_lighting(entity, duration)
				
				// Set time for next loop
				set_pev(entity, PEV_FLARE_DURATION, --duration)
				set_pev(entity, pev_dmgtime, current_time + 2.0)
			}
			// Light up when it's stopped on ground
			else if ((pev(entity, pev_flags) & FL_ONGROUND) && fm_get_speed(entity) < 10)
			{
				// Flare sound
				static sound[64]
				ArrayGetString(grenade_flare, random_num(0, ArraySize(grenade_flare) - 1), sound, charsmax(sound))
				emit_sound(entity, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				// Set duration and start lightning loop on next think
				set_pev(entity, PEV_FLARE_DURATION, 1 + get_pcvar_num(cvar_flareduration)/2)
				set_pev(entity, pev_dmgtime, current_time + 0.1)
			}
			else
			{
				// Delay explosion until we hit ground
				set_pev(entity, pev_dmgtime, current_time + 0.5)
			}
		}
	}
	
	return HAM_IGNORED;
}

// Forward CmdStart
public fw_CmdStart(id, handle)
{
	// Not alive
	if (!g_isalive[id])
		return;
	
	// This logic looks kinda weird, but it should work in theory...
	// p = g_zombie[id], q = g_survivor[id], r = g_cached_customflash
	// ¬(p v q v (¬p ^ r)) <==> ¬p ^ ¬q ^ (p v ¬r)
	if (!g_zombie[id] && !g_survivor[id] && (g_zombie[id] || !g_cached_customflash))
		return;
	
	// Check if it's a flashlight impulse
	if (get_uc(handle, UC_Impulse) != IMPULSE_FLASHLIGHT)
		return;
	
	// Block it I say!
	set_uc(handle, UC_Impulse, 0)
	
	// Should human's custom flashlight be turned on?
	if (!g_zombie[id] && !g_survivor[id] && g_flashbattery[id] > 2 && get_gametime() - g_lastflashtime[id] > 1.2)
	{
		// Prevent calling flashlight too quickly (bugfix)
		g_lastflashtime[id] = get_gametime()
		
		// Toggle custom flashlight
		g_flashlight[id] = !(g_flashlight[id])
		
		// Play flashlight toggle sound
		emit_sound(id, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on the HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(g_flashlight[id]) // toggle
		write_byte(g_flashbattery[id]) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
		
		// Set the flashlight charge task
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
		
		// Call our custom flashlight task if enabled
		if (g_flashlight[id]) set_task(0.1, "set_user_flashlight", id+TASK_FLASH, _, _, "b")
	}
}

// Forward Player PreThink
public fw_PlayerPreThink(id)
{
	// Not alive
	if (!g_isalive[id])
		return;
	
	// Enable custom buyzone for player during buytime, unless zombie or survivor or time expired
	if (g_cached_buytime > 0.0 && !g_zombie[id] && !g_survivor[id] && (get_gametime() < g_buytime[id] + g_cached_buytime))
	{
		if (pev_valid(g_buyzone_ent))
			dllfunc(DLLFunc_Touch, g_buyzone_ent, id)
	}
	
	// Silent footsteps for zombies?
	if (g_cached_zombiesilent && g_zombie[id] && !g_nemesis[id])
		set_pev(id, pev_flTimeStepSound, STEPTIME_SILENT)
		
	if(g_survivor[id])
	{
		set_user_rendering( id, kRenderFxGlowShell, 0, 0, 200, kRenderNormal, 14 );	
	}
	// Player frozen?
	if (g_frozen[id])
	{
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0}) // stop motion
		return; // shouldn't leap while frozen
	}
	
	// --- Check if player should leap ---
	
	// Don't allow leap during freezetime
	if (g_freezetime)
		return;
	
	// Check if proper CVARs are enabled and retrieve leap settings
	static Float:cooldown, Float:current_time
	if (g_zombie[id])
	{
		if (g_nemesis[id])
		{
			if (!g_cached_leapnemesis) return;
			cooldown = g_cached_leapnemesiscooldown
		}
		else
		{
			switch (g_cached_leapzombies)
			{
				case 0: return;
				case 2: if (!g_firstzombie[id]) return;
				case 3: if (!g_firstzombie[id]) return;
			}
			cooldown = g_cached_leapzombiescooldown
		}
	}
	else
	{
		if (g_survivor[id])
		{
			if (!g_cached_leapsurvivor) return;
			cooldown = g_cached_leapsurvivorcooldown
		}
		else return;
	}
	
	current_time = get_gametime()
	
	// Cooldown not over yet
	if (current_time - g_lastleaptime[id] < cooldown)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!g_isbot[id] && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 80)
		return;
	
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, g_survivor[id] ? get_pcvar_num(cvar_leapsurvivorforce) : g_nemesis[id] ? get_pcvar_num(cvar_leapnemesisforce) : get_pcvar_num(cvar_leapzombiesforce), velocity)
	
	// Set custom height
	velocity[2] = g_survivor[id] ? get_pcvar_float(cvar_leapsurvivorheight) : g_nemesis[id] ? get_pcvar_float(cvar_leapnemesisheight) : get_pcvar_float(cvar_leapzombiesheight)
	
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
	
	// Update last leap time
	g_lastleaptime[id] = current_time
}

/*================================================================================
 [Client Commands]
=================================================================================*/

public clcmd_saymenu( id ) {
	show_menu_game( id );
}

// Say "/unstuck"
public clcmd_sayunstuck(id)
{
	menu_game(id, 3) // try to get unstuck
}

// Nightvision toggle
public clcmd_nightvision(id)
{
	// Nightvision available to player?
	if (g_nvision[id] || (g_isalive[id] && cs_get_user_nvg(id)))
	{
		// Enable-disable
		g_nvisionenabled[id] = !(g_nvisionenabled[id])
		
		// Custom nvg?
		if (get_pcvar_num(cvar_customnvg))
		{
			remove_task(id+TASK_NVISION)
			if (g_nvisionenabled[id]) set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
		}
		else
			set_user_gnvision(id, g_nvisionenabled[id])
	}
	
	return PLUGIN_HANDLED;
}

// Weapon Drop
public clcmd_drop(id)
{
	// Survivor should stick with its weapon
	if (g_survivor[id])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Buy BP Ammo
public clcmd_buyammo(id)
{
	// Not alive or infinite ammo setting enabled
	if (!g_isalive[id] || get_pcvar_num(cvar_infammo))
		return PLUGIN_HANDLED;
	
	// Not human
	if (g_zombie[id])
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_HUMAN_ONLY")
		return PLUGIN_HANDLED;
	}
	
	// Custom buytime enabled and human player standing in buyzone, allow buying weapon's ammo normally instead
	if (g_cached_buytime > 0.0 && !g_survivor[id] && (get_gametime() < g_buytime[id] + g_cached_buytime) && cs_get_user_buyzone(id))
		return PLUGIN_CONTINUE;
	
	// Get user weapons
	static weapons[32], num, i, currentammo, weaponid, refilled
	num = 0 // reset passed weapons count (bugfix)
	refilled = false
	get_user_weapons(id, weapons, num)
	
	// Loop through them and give the right ammo type
	for (i = 0; i < num; i++)
	{
		// Prevents re-indexing the array
		weaponid = weapons[i]
		
		// Primary and secondary only
		if (MAXBPAMMO[weaponid] > 2)
		{
			// Get current ammo of the weapon
			currentammo = cs_get_user_bpammo(id, weaponid)
			
			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, id, BUYAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
			
			// Check whether we actually refilled the weapon's ammo
			if (cs_get_user_bpammo(id, weaponid) - currentammo > 0) refilled = true
		}
	}
	
	// Weapons already have full ammo
	if (!refilled) return PLUGIN_HANDLED;
	
	// Deduce ammo packs, play clip purchase sound, and notify player
	g_ammopacks[id]--
	emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
	zp_colored_print(id, "^x04[ZP]^x01 %L", id, "AMMO_BOUGHT")
	
	return PLUGIN_HANDLED;
}

// Block Team Change
public clcmd_changeteam( id ) {
	static team;
	team = fm_cs_get_user_team( id );
	
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;
	
		show_menu_game( id );
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Menus]
=================================================================================*/

// Game Menu

show_menu_game( id ) {
	if( !g_isconnected[ id ] )
		return;
	
	static menu[ 250 ], len, userflags;
	len = 0;
	userflags = get_user_flags( id );
	new kluce;
	kluce = 100 - legendary_key[ id ];
	
	len += formatex( menu[ len ], charsmax( menu ) - len, "%L", id, "MAIN_MENU" );
	// 1. Buy weapons
	if( is_user_alive( id ) )
		len += formatex( menu[ len ], charsmax( menu ) - len, "\r1.\w %L^n", id, "MENU_BUY" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "\d1. %L^n", id, "MENU_BUY" );
	
	// 2. Extra items
	if( get_pcvar_num( cvar_extraitems ) && g_isalive[ id ] )
		len += formatex( menu[ len ], charsmax( menu ) - len, "\r2.\w %L^n", id, "MENU_EXTRABUY" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "\d2. %L^n", id, "MENU_EXTRABUY" );
	
	// 3. Zombie class
	if( get_pcvar_num( cvar_zclasses ) )
		len += formatex( menu[ len ], charsmax( menu ) - len, "\r3.\w %L^n", id,"MENU_ZCLASS" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "\d3. %L^n", id,"MENU_ZCLASS" );
	
	// 4. Unstuck
	if( is_user_alive( id ) )
		len += formatex( menu[ len ], charsmax( menu ) - len, "\r4.\w %L^n", id, "MENU_UNSTUCK" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "\d4. %L^n", id, "MENU_UNSTUCK" );
	
	// 5. Help
	len += formatex( menu[ len ], charsmax( menu ) - len, "\r5.\w %L^n", id, "MENU_INFO" );
	
	// 7. Join spec
	if ( legendary_key[ id ] == 100 )
		len += formatex( menu[ len ], charsmax( menu ) - len, "\r6. %L^n", id, "LEGENDARY_MENU" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "\d6. %L^n", id, "NO_LEGENDARY_MENU", kluce );
	
	// 6. Human Menu
	len += formatex( menu[ len ], charsmax(menu) - len, "\r7.\w %L^n", id, "MENU_HUMAN" );
	
	// 8. Menu Stats
	len += formatex( menu[ len ], charsmax( menu ) - len, "\r8.\w %L^n", id, "MENU_STATS" );
	
	// 9. Admin menu
	if( userflags & g_access_flag[ ACCESS_ADMIN_MENU ] )
		len += formatex( menu[ len ], charsmax( menu ) - len, "%L", id, "MENU_ADMIN" );
	else
		len += formatex( menu[ len ], charsmax( menu ) - len, "%L", id, "MENU_ADMIN" );
	
	// 0. Exit
	len += formatex( menu[ len ], charsmax( menu ) - len, "^n^n\r0.\w %L", id, "MENU_EXIT" );
	
	// Fix for AMXX custom menus
	if( pev_valid( id ) == PDATA_SAFE )
		set_pdata_int( id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX );
	
	show_menu( id, KEYSMENU, menu, -1, "Game Menu" );
}
// Buy Menu 1
public show_menu_buy1(taskid)
{
	// Get player's id
	static id
	(taskid > g_maxplayers) ? (id = ID_SPAWN) : (id = taskid);
	
	// Player dead?
	if (!g_isalive[id])
		return;
	
	// Zombies or survivors get no guns
	if (g_zombie[id] || g_survivor[id])
		return;
	
	// Bots pick their weapons randomly / Random weapons setting enabled
	if (get_pcvar_num(cvar_randweapons) || g_isbot[id])
	{
		buy_primary_weapon(id, random_num(0, ArraySize(g_primary_items) - 1))
		menu_buy2(id, random_num(0, ArraySize(g_secondary_items) - 1))
		return;
	}
	
	// Automatic selection enabled for player and menu called on spawn event
	if (WPN_AUTO_ON && taskid > g_maxplayers)
	{
		buy_primary_weapon(id, WPN_AUTO_PRI)
		menu_buy2(id, WPN_AUTO_SEC)
		return;
	}
	
	static menu[300], len, weap, maxloops
	len = 0
	maxloops = min(WPN_STARTID+7, WPN_MAXIDS)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n^n", id, "MENU_BUY1_TITLE", WPN_STARTID+1, min(WPN_STARTID+7, WPN_MAXIDS))
	
	// 1-7. Weapon List
	for (weap = WPN_STARTID; weap < maxloops; weap++)
		len += formatex(menu[len], charsmax(menu) - len, "\r%d.\w %s^n", weap-WPN_STARTID+1, WEAPONNAMES[ArrayGetCell(g_primary_weaponids, weap)])
	
	// 9. Next/Back - 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r9.\w %L/%L^n^n\r0.\w %L", id, "MENU_NEXT", id, "MENU_BACK", id, "MENU_EXIT")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 1")
}

// Buy Menu 2
show_menu_buy2(id)
{
	// Player dead?
	if (!g_isalive[id])
		return;
	
	static menu[250], len, weap, maxloops
	len = 0
	maxloops = ArraySize(g_secondary_items)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n", id, "MENU_BUY2_TITLE")
	
	// 1-6. Weapon List
	for (weap = 0; weap < maxloops; weap++)
		len += formatex(menu[len], charsmax(menu) - len, "^n\r%d.\w %s", weap+1, WEAPONNAMES[ArrayGetCell(g_secondary_weaponids, weap)])
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\w %L", id, "MENU_EXIT")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu 2")
}

// Extra Items Menu
show_menu_extras(id)
{
	// Player dead?
	if (!g_isalive[id])
		return;
	
	static menuid, menu[128], item, team, buffer[32]
	
	// Title
	formatex(menu, charsmax(menu), "%L [%L]\r", id, "MENU_EXTRA_TITLE", id, g_zombie[id] ? g_nemesis[id] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE" : g_survivor[id] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
	menuid = menu_create(menu, "menu_extras")
	
	// Item List
	for (item = 0; item < g_extraitem_i; item++)
	{
		// Retrieve item's team
		team = ArrayGetCell(g_extraitem_team, item)
		
		// Item not available to player's team/class
		if ((g_zombie[id] && !g_nemesis[id] && !(team & ZP_TEAM_ZOMBIE)) || (!g_zombie[id] && !g_survivor[id] && !(team & ZP_TEAM_HUMAN)) || (g_nemesis[id] && !(team & ZP_TEAM_NEMESIS)) || (g_survivor[id] && !(team & ZP_TEAM_SURVIVOR)))
			continue;
		
		// Check if it's one of the hardcoded items, check availability, set translated caption
		switch (item)
		{
			case EXTRA_NVISION:
			{
				if (!get_pcvar_num(cvar_extranvision)) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA1")
			}
			case EXTRA_ANTIDOTE:
			{
				if (!get_pcvar_num(cvar_extraantidote) || g_antidotecounter >= get_pcvar_num(cvar_antidotelimit)) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA2")
			}
			case EXTRA_MADNESS:
			{
				if (!get_pcvar_num(cvar_extramadness) || g_madnesscounter >= get_pcvar_num(cvar_madnesslimit)) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA3")
			}
			case EXTRA_INFBOMB:
			{
				if (!get_pcvar_num(cvar_extrainfbomb) || g_infbombcounter >= get_pcvar_num(cvar_infbomblimit)) continue;
				formatex(buffer, charsmax(buffer), "%L", id, "MENU_EXTRA4")
			}
			default:
			{
				if (item >= EXTRA_WEAPONS_STARTID && item <= EXTRAS_CUSTOM_STARTID-1 && !get_pcvar_num(cvar_extraweapons)) continue;
				ArrayGetString(g_extraitem_name, item, buffer, charsmax(buffer))
			}
		}
		
		// Add Item Name and Cost
		formatex(menu, charsmax(menu), "%s \y%d %L", buffer, ArrayGetCell(g_extraitem_cost, item), id, "AMMO_PACKS2")
		buffer[0] = item
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// No items to display?
	if (menu_items(menuid) <= 0)
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id ,"CMD_NOT_EXTRAS")
		menu_destroy(menuid)
		return;
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
		
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_EXTRAS = min(MENU_PAGE_EXTRAS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_EXTRAS)
}

// Zombie Class Menu
public show_menu_zclass(id)
{
	// Player disconnected
	if (!g_isconnected[id])
		return;
	
	// Bots pick their zombie class randomly
	if (g_isbot[id])
	{
		g_zombieclassnext[id] = random_num(0, g_zclass_i - 1)
		return;
	}
	
	static menuid, menu[128], class, buffer[32], buffer2[32]
	
	// Title
	formatex(menu, charsmax(menu), "%L\r", id, "MENU_ZCLASS_TITLE")
	menuid = menu_create(menu, "menu_zclass")
	
	// Class List
	for (class = 0; class < g_zclass_i; class++)
	{
		// Retrieve name and info
		ArrayGetString(g_zclass_name, class, buffer, charsmax(buffer))
		ArrayGetString(g_zclass_info, class, buffer2, charsmax(buffer2))
		
		// Add to menu
		if (class == g_zombieclassnext[id])
			formatex(menu, charsmax(menu), "\d%s %s", buffer, buffer2)
		else
			formatex(menu, charsmax(menu), "%s \y%s", buffer, buffer2)
		
		buffer[0] = class
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_ZCLASS = min(MENU_PAGE_ZCLASS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_ZCLASS)
}

// Help Menu
show_menu_info(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menu[150]
	
	formatex(menu, charsmax(menu), "\y%L^n^n\r1.\w %L^n\r2.\w %L^n\r3.\w %L^n\r4.\w %L^n^n\r0.\w %L", id, "MENU_INFO_TITLE", id, "MENU_INFO1", id,"MENU_INFO2", id,"MENU_INFO3", id,"MENU_INFO4", id, "MENU_EXIT")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Mod Info")
}

// Admin Menu
show_menu_admin(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menu[250], len, userflags
	len = 0
	userflags = get_user_flags(id)
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\y%L^n^n", id, "MENU_ADMIN_TITLE")
	
	// 1. Zombiefy/Humanize command
	if (userflags & (g_access_flag[ACCESS_MODE_INFECTION] | g_access_flag[ACCESS_MAKE_ZOMBIE] | g_access_flag[ACCESS_MAKE_HUMAN]))
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w %L^n", id, "MENU_ADMIN1")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d1. %L^n", id, "MENU_ADMIN1")
	
	// 2. Nemesis command
	if (userflags & (g_access_flag[ACCESS_MODE_NEMESIS] | g_access_flag[ACCESS_MAKE_NEMESIS]))
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w %L^n", id, "MENU_ADMIN2")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d2. %L^n", id, "MENU_ADMIN2")
	
	// 3. Survivor command
	if (userflags & (g_access_flag[ACCESS_MODE_SURVIVOR] | g_access_flag[ACCESS_MAKE_SURVIVOR]))
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\w %L^n", id, "MENU_ADMIN3")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d3. %L^n", id, "MENU_ADMIN3")
	
	// 4. Respawn command
	if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w %L^n", id, "MENU_ADMIN4")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d4. %L^n", id, "MENU_ADMIN4")
	
	// 5. Swarm mode command
	if ((userflags & g_access_flag[ACCESS_MODE_SWARM]) && allowed_swarm())
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w %L^n", id, "MENU_ADMIN5")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d5. %L^n", id, "MENU_ADMIN5")
	
	// 6. Multi infection command
	if ((userflags & g_access_flag[ACCESS_MODE_MULTI]) && allowed_multi())
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\w %L^n", id, "MENU_ADMIN6")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d6. %L^n", id, "MENU_ADMIN6")
	
	// 7. Plague mode command
	if ((userflags & g_access_flag[ACCESS_MODE_PLAGUE]) && allowed_plague())
		len += formatex(menu[len], charsmax(menu) - len, "\r7.\w %L^n", id, "MENU_ADMIN7")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\d7. %L^n", id, "MENU_ADMIN7")
	
	// 0. Exit
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0.\w %L", id, "MENU_EXIT")
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	show_menu(id, KEYSMENU, menu, -1, "Admin Menu")
}

// Player List Menu
show_menu_player_list(id)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return;
	
	static menuid, menu[128], player, userflags, buffer[2]
	userflags = get_user_flags(id)
	
	// Title
	switch (PL_ACTION)
	{
		case ACTION_ZOMBIEFY_HUMANIZE: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN1")
		case ACTION_MAKE_NEMESIS: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN2")
		case ACTION_MAKE_SURVIVOR: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN3")
		case ACTION_RESPAWN_PLAYER: formatex(menu, charsmax(menu), "%L\r", id, "MENU_ADMIN4")
	}
	menuid = menu_create(menu, "menu_player_list")
	
	// Player List
	for (player = 0; player <= g_maxplayers; player++)
	{
		// Skip if not connected
		if (!g_isconnected[player])
			continue;
		
		// Format text depending on the action to take
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[player])
				{
					if (allowed_human(player) && (userflags & g_access_flag[ACCESS_MAKE_HUMAN]))
						formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE")
					else
						formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE")
				}
				else
				{
					if (allowed_zombie(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_INFECTION]) : (userflags & g_access_flag[ACCESS_MAKE_ZOMBIE])))
						formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
					else
						formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (allowed_nemesis(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NEMESIS]) : (userflags & g_access_flag[ACCESS_MAKE_NEMESIS])))
				{
					if (g_zombie[player])
						formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE")
					else
						formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
				}
				else
					formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, g_zombie[player] ? g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE" : g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (allowed_survivor(player) && (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SURVIVOR]) : (userflags & g_access_flag[ACCESS_MAKE_SURVIVOR])))
				{
					if (g_zombie[player])
						formatex(menu, charsmax(menu), "%s \r[%L]", g_playername[player], id, g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE")
					else
						formatex(menu, charsmax(menu), "%s \y[%L]", g_playername[player], id, g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
				}
				else
					formatex(menu, charsmax(menu), "\d%s [%L]", g_playername[player], id, g_zombie[player] ? g_nemesis[player] ? "CLASS_NEMESIS" : "CLASS_ZOMBIE" : g_survivor[player] ? "CLASS_SURVIVOR" : "CLASS_HUMAN")
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (allowed_respawn(player) && (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS]))
					formatex(menu, charsmax(menu), "%s", g_playername[player])
				else
					formatex(menu, charsmax(menu), "\d%s", g_playername[player])
			}
		}
		
		// Add player
		buffer[0] = player
		buffer[1] = 0
		menu_additem(menuid, menu, buffer)
	}
	
	// Back - Next - Exit
	formatex(menu, charsmax(menu), "%L", id, "MENU_BACK")
	menu_setprop(menuid, MPROP_BACKNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_NEXT")
	menu_setprop(menuid, MPROP_NEXTNAME, menu)
	formatex(menu, charsmax(menu), "%L", id, "MENU_EXIT")
	menu_setprop(menuid, MPROP_EXITNAME, menu)
	
	// If remembered page is greater than number of pages, clamp down the value
	MENU_PAGE_PLAYERS = min(MENU_PAGE_PLAYERS, menu_pages(menuid)-1)
	
	// Fix for AMXX custom menus
	if (pev_valid(id) == PDATA_SAFE)
		set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	
	menu_display(id, menuid, MENU_PAGE_PLAYERS)
}

/*================================================================================
 [Menu Handlers]
=================================================================================*/

// Game Menu
public menu_game(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	static motd[1500], len
	len = 0
	switch (key)
	{
		case 0: // Buy Weapons
		{
			// Custom buy menus enabled?
			if (get_pcvar_num(cvar_buycustom))
			{
				if( !g_survivor[id] )
				{
					if (g_canbuy[id]) 
					{
						vybrat_zbran(id)
					}
				} else {
					ChatColor( id, "%L", LANG_PLAYER, "NO_SURVIVOR_BUY" );
				}
			}
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
		}
		case 1: // Extra Items
		{
			// Extra items enabled?
			if (get_pcvar_num(cvar_extraitems))
			{
				// Check whether the player is able to buy anything
				if (g_isalive[id])
					show_menu_extras(id)
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_EXTRAS")
		}
		case 2: // Spirit
		{
			epic_menu1(id)
		}
		case 3: // Zombie Classes
		{
			// Zombie classes enabled?
			if (get_pcvar_num(cvar_zclasses))
				show_menu_zclass(id)
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ZCLASSES")
		}
		case 4: // Levely
		{
			postava(id)
		}
	
		case 5: // Join Spectator
		{
			if( legendary_key[ id ] == 100 ) {
				legendary_menu( id );
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "NO_ENOUGH_KEYS" );
	
			}
		}
		case 6: // Help Menu
		{
			settings_menu(id)
		}
		case 7: 
		{
			new armor = g_unAPLevel[ id ] * 4;
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2" );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_A", g_unHPLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_B", armor );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_C", g_unDMLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_D", g_unDELevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_E", g_resBurnLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_F", g_resFrostLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_G", g_BurnLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_H", g_FrostLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_I", g_MoneyLevel[ id ] );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_J", g_ArmorRegLevel[ id ]  );
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_W", g_CritDamageLevel[ id ]  );
			show_motd( id, motd );
		}
		case 8: // Admin Menu
		{
			// Check if player has the required access
			if (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MENU])
				show_menu_admin(id)
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
		}
	}
	
	return PLUGIN_HANDLED;
}

public Ulozit( id ) {
	new AuthID[ 35 ], a[ 32 ], b[ 32 ];
	formatex( a, 31, "%s", User[ id ] );
	formatex( b, 31, "%s", Password[ id ] );
	replace_all( a, 31, "\", "\\" );
	replace_all( a, 31, "'", "\'" );
	replace_all( b, 31, "\", "\\" );
	replace_all( b, 31, "'", "\'" );
	get_user_authid( id, AuthID, 34 );
	new vaultkey[ 64 ], vaultdata[ 256 ];
	format( vaultkey, 63, "%s-xp_mod", AuthID );
	format( vaultdata, 255, "%s#%s#%i#", a, b, Found[ id ] );
	nvault_set( g_vault, vaultkey, vaultdata );
	return PLUGIN_CONTINUE;
}

public Nacitat( id ) {
	new AuthID[ 35 ], a[ 32 ], b[ 32 ];
	formatex( a, 31, "%s", User[ id ] );
	formatex( b, 31, "%s", Password[ id ] );
	replace_all( a, 31, "\", "\\" );
	replace_all( a, 31, "'", "\'" );
	replace_all( b, 31, "\", "\\" );
	replace_all( b, 31, "'", "\'" );
	get_user_authid( id, AuthID, 34 );
	new vaultkey[ 64 ], vaultdata[ 256 ];
	
	format( vaultkey, 63, "%s-xp_mod", AuthID );
	format( vaultdata, 255, "%s#%s#%i#", a, b, Found[ id ] );
	
	nvault_get( g_vault, vaultkey, vaultdata, 255 );
	replace_all( vaultdata, 255, "#", " " );
	new meno[ 32 ], heslo[ 32 ], found[ 32 ];
	parse( vaultdata, meno, 31, heslo, 31, found, 31 );
	User[ id ] = meno;
	Password[ id ] = heslo;
	Found[ id ] = str_to_num( found );
	return PLUGIN_CONTINUE;
}



public SetLvL(id, level, cid)
{	
	if(!cmd_access(id,level,cid,3))
	{
		client_print(id, print_console,"[ZP] Nemas pristup k tomuto prikazu !")
		return PLUGIN_HANDLED;
	}
	
	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new player = cmd_target(id, arg1, CMDTARGET_NO_BOTS);
	new value = str_to_num(arg2)-1;
	
	if(!is_user_connected(player))
	{
		client_print(id, print_console,"[ZP] Tento hrac nieje pripojeny")
		return PLUGIN_HANDLED;
	}
	
	if(value > get_pcvar_num(cvar_max_lvl))
	{
		client_print(id, print_console,"[ZP] Maximalne mozete dat %d lvl !",get_pcvar_num(cvar_max_lvl)-levels[player])
		return PLUGIN_HANDLED
	}
	
	new name[32]
	get_user_name(player, name, 31) //ime igraca kome dajemo lvl
	
	client_print(id, print_console,"[ZP] Dal si %d lvl hracovi : %s",value,name)
	levels[player]+=value;
	return PLUGIN_HANDLED
}

public SetExp(id, level, cid)
{	
	if(!cmd_access(id,level,cid,3))
	{
		client_print(id, print_console,"[ZP] Nemas pristup k tomuto prikazu !")
		return PLUGIN_HANDLED;
	}
	
	new arg1[33];
	new arg2[6];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	new player = cmd_target(id, arg1, CMDTARGET_NO_BOTS);
	new value = str_to_num(arg2)-1;
	
	if(!is_user_connected(player))
	{
		client_print(id, print_console,"[ZP] Tento hrac nieje pripojeny")
		return PLUGIN_HANDLED;
	}
	
	new name[32]
	get_user_name(player, name, 31) //ime igraca kome dajemo lvl
	
	client_print(id, print_console,"[ZP] Dal si %d exp hracovi : %s",value,name)
	exp[player]+=value;
	return PLUGIN_HANDLED
}

public daj_level( victim, attacker, shouldgib ) {
	new expcka = 0;
	if( Logined[ attacker ] ) {
		if( is_user_alive( attacker ) ) {
			kills[ attacker ]++;
			if( spirit_human[ attacker ] ) {
				if( !g_zombie[ attacker ] ) {
					body[ attacker ]++;
					ChatColor( attacker, "%L", LANG_PLAYER, "SPIRIT_HUMAN" );
				}
			}
			/*
			if( g_weekend_event == 1 ) {
				if( g_nemesis[ victim ] || g_firstzombie[ victim ] || g_survivor[ victim ] ) {
					ChatColor( attacker, "!g[Herny Inventar]!y Musis zabit normalneho hraca aby si ziskal truhlu!" );
				} else {
					ChatColor( attacker, "!g[Herny Inventar]!y Ziskal si !tLVL UP Case!y. Mas ju ulozenu v inventary!" );
					lvl_case[ attacker ]++;
				}
			}*/
			
			if( g_plagueround ) {
				ChatColor( attacker, "%L", LANG_PLAYER, "SURVIVOR_VS_NEMESIS_ON" );
				body[ attacker ] += 5;
			}
			if( g_swarmround ) {
				expcka += 500;
			}
			if( g_multiround ) {
				expcka += 20;
			}
			expcka += 5;
			if( exp_human[ attacker ] ) {
				expcka += 10;
			}
			if( legendary_key[ attacker ] == 100 ) {
				switch( random_num( 1, 20 ) ) {
					case 1: {
						playaspro_case[ attacker ]++; 
						ChatColor( attacker, "%L", LANG_PLAYER, "EPIC_CASE_GET" );
					}
				}
			}
			if( g_event == 1 ) {
				if( get_user_flags( attacker ) & ADMIN_LEVEL_F ) {
					expcka += 30;
				} else {
					expcka += 20;
				}
				/*
				if( !is_user_bot( victim ) ) {
					g_killed_zombies[ attacker ]++;
					if( g_killed_zombies[ attacker ] == 50 ) {
						expcka += 5000;
						client_print( attacker, print_center, "DOSIAHOL SI MILESTONE!" );
						client_cmd( attacker, "spk playaspro/upgraden.wav" );
					}
					if( g_killed_zombies[ attacker ] == 100 ) {
						expcka += 10000;
						exp_case[ attacker ] += 10;
						client_print( attacker, print_center, "DOSIAHOL SI MILESTONE!" );
						client_cmd( attacker, "spk playaspro/upgraden.wav" );
					}
					if( g_killed_zombies[ attacker ] == 500 ) {
						expcka += 10000;
						lvl_case[ attacker ] += 8;
						client_print( attacker, print_center, "DOSIAHOL SI MILESTONE!" );
						client_cmd( attacker, "spk playaspro/upgraden.wav" );
					}
					if( g_killed_zombies[ attacker ] == 1000 ) {
						expcka += 25000;
						exp_case[ attacker ] += 20;
						client_print( attacker, print_center, "DOSIAHOL SI MILESTONE!" );
						client_cmd( attacker, "spk playaspro/upgraden.wav" );
					}
					if( g_killed_zombies[ attacker ] == 2000 ) {
						expcka += 25000;
						exp_case[ attacker ] += 20;
						lvl_case[ attacker ] += 15;
						client_print( attacker, print_center, "DOSIAHOL SI MILESTONE!" );
						client_cmd( attacker, "spk playaspro/upgraden.wav" );
					}
				}*/
			}
			if( get_user_flags( attacker ) & ADMIN_LEVEL_F ) {
				expcka += 5;
			}
			if( expcase_human[ attacker ] ) {
				if( is_user_bot( victim ) ) {
					ChatColor( attacker, "%L", LANG_PLAYER, "EXP_CASE_HUMAN_NO" );
				} else {
					ChatColor( attacker, "%L", LANG_PLAYER, "EXP_CASE_HUMAN" );
					exp_case[ attacker ]++;
				}
			}
			if( kills[ attacker ] == 10 ) {
				ScreenFade( attacker, 0.3, 200, 20, 20, 100 );
				set_dhudmessage( 255, 42, 42, -1.0, 0.45, 0, 1.0, 1.0 ); // 0, 6.0, 1.1, 0.0, 0.0, -1 ShowSyncHudMsg(id, g_SyncHud_Kill, KillText)
				show_dhudmessage( attacker, "LEVEL UP!" );
				client_cmd( attacker, "spk playaspro/xp_levelup.wav" );
				
				kills[ attacker ] = 0; levels[ attacker ]++;
				expcka += 20;
			}
			exp[ attacker ] += expcka;
			ChatColor( attacker, "%L", LANG_PLAYER, "EXP_BONUS", expcka );
			SQL_UpdateUser( attacker );
		}
	}
}


public event_CurWeapon(id) 
{
	if(!g_zombie[id] && !g_nemesis[id] && !g_firstzombie[id] && !g_survivor[id])
	{
		if( fast_human[ id ] )
		{
			set_user_maxspeed(id, 265.0)
		}	
		return 0;
	}
	return 0;
}

public event_CurWeaponn(id)
{
	if(!g_zombie[id] && !g_nemesis[id] && !g_firstzombie[id] && !g_survivor[id])
	{
		if(gravita[id] == 1)
		{
			set_user_gravity(id, 0.75)
		}	
		return 0;
	}
	return 0;
}

public postava( id ) {
	new szText[ 555 char ], szText2[ 555 char ];
	formatex( szText, charsmax( szText ), "%L", id, "HUMAN_MENU_1", levels[ id ] )
	new nast = menu_create( szText, "postava_items" );
	
	formatex( szText, charsmax( szText ), "%L", id, "START_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "START_HUMAN_ON" );
	menu_additem( nast, ( g_player_class[ id ] == 1 ) 	? szText2 : szText, "1", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "STRONG_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "STRONG_HUMAN_ON" );
	menu_additem( nast, ( strong_human[ id ] ) 	? szText2 : szText, "2", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "FROST_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "FROST_HUMAN_ON" );
	menu_additem( nast, ( frost_human[ id ] ) 	? szText2 : szText, "3", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "FAST_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "FAST_HUMAN_ON" );
	menu_additem( nast, ( fast_human[ id ] ) 	? szText2 : szText, "4", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "GRAVITY_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "GRAVITY_HUMAN_ON" );
	menu_additem( nast, ( gravity_human[ id ] ) 	? szText2 : szText, "5", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "ADRENAL_HUMAN_OFF" );
	formatex( szText2, charsmax( szText ), "%L", id, "ADRENAL_HUMAN_ON" );
	menu_additem( nast, ( adrenal_human[ id ] ) 	? szText2 : szText, "6", 0 );
	
	formatex( szText, charsmax( szText ), "%L \y2/3", id, "MENU_NEXT" );
	menu_additem( nast, szText, "7" );
	menu_display( id, nast, 0 );
	return PLUGIN_HANDLED;
}

public postava_items( id, menu, item ) {
	if( item == MENU_EXIT ) {
		return PLUGIN_HANDLED;
	}
	new text[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "HUMAN_ACTIVATE" );
	switch( item ) {
		case 0: { // Start Human = 1
			if( !( start_human[ id ] ) ) {
				if( !( levels[ id ] < 0 ) ) {
					g_player_class[ id ] = 	1;
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					g_ASTAR[ id ] = 		1;
					Gravity[id] = 		0;
					Rychly[id] = 		0;
					resist_human[ id ] = 	false;
					exp_human[ id ] = 	false;
					g_item_dmg[ id ] = 	false;
					g_item_gdmg[ id ] = 	false;
					fast_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					start_human[ id ] = 	true;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
					postava( id );
					ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
					client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 1:	{ // Strong Human = 2
			if( !( strong_human[ id ] ) ) {
				if( !( levels[ id ] < 50 ) ) {
					g_player_class[ id ] = 	2;
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					g_ASTRO[ id ] = 		1;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					resist_human[ id ] = 	false;
					g_item_dmg[ id ] = 	false;
					g_item_gdmg[ id ] = 	false;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					strong_human[ id ] = 	true;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				postava( id );
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 2: { // Frost Human = 3
			if( !( frost_human[ id ] ) ) {
				if( !( levels[ id ] < 50 ) ) {
				g_player_class[ id ] = 	3;
				set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
				ShowSyncHudMsg( id, g_MsgSync8, text );
				client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
				exp_human[ id ] = 	false;			
				Rychly[ id ] = 		0;
				Gravity[ id ] = 		0;
				g_item_dmg[ id ] = 	false;
				g_item_gdmg[ id ] = 	false;
				start_human[ id ] = 	false;
				resist_human[ id ] = 	false;
				fast_human[ id ] = 	false;
				gravity_human[ id ] = 	false;
				strong_human[ id ] = 	false;
				damage_human[ id ] = 	false;
				frost_human[ id ] = 	true;
				adrenal_human[ id ] =	false
				minigun_human[ id ] = 	false
				special_human[ id ] = 	false
				spirit_human[ id ] = 	false
				imune_human[ id ] = 	false
				defense_human[ id ] = 	false;
				points_human[ id ] = 	false;
				expcase_human[ id ] = 	false;
				} else {
				postava( id )
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 3: { // Fast Human = 4
			if( !( fast_human[ id ] ) ) {
				if( !( levels[ id ] < 150 ) ) {
				set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
				ShowSyncHudMsg( id, g_MsgSync8, text );
				client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
				exp_human[ id ] = 	false;
				g_player_class[ id ] = 	4;
				g_item_dmg[ id ] = 	false;
				g_AFAST[ id ] = 		1;
				g_item_gdmg[ id ] = 	false;
				Gravity[ id ] = 		0;
				resist_human[ id ] = 	false;
				start_human[ id ] = 	false;
				gravity_human[ id ] = 	false;
				frost_human[ id ] = 	false;
				strong_human[ id ] = 	false;
				damage_human[ id ] = 	false;
				fast_human[ id ] = 	true;
				adrenal_human[ id ] = 	false;
				minigun_human[ id ] = 	false;
				special_human[ id ] = 	false;
				spirit_human[ id ] = 	false;
				imune_human[ id ] = 	false;
				defense_human[ id ] = 	false;
				points_human[ id ] = 	false;
				expcase_human[ id ] = 	false;
				} else {
				postava( id );
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 4: { // Gravity Human = 5
			if( !( gravity_human[ id ] ) ) {
				if( !( levels[ id ] < 250 ) ) {
				set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
				ShowSyncHudMsg( id, g_MsgSync8, text );
				client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
				exp_human[ id ] = 	false;
				g_AGRAV[ id ] = 		1;
				Rychly[ id ] = 		0;
				g_player_class[ id ] = 	5;
				resist_human[ id ] = 	false;
				g_item_dmg[ id ] = 	false
				g_item_gdmg[ id ] = 	false
				start_human[ id ] = 	false
				fast_human[ id ] = 	false
				frost_human[ id ] = 	false
				strong_human[ id ] = 	false
				damage_human[ id ] = 	false
				gravity_human[ id ] = 	true
				adrenal_human[ id ] = 	false
				minigun_human[ id ] = 	false
				special_human[ id ] = 	false
				spirit_human[ id ] = 	false
				imune_human[ id ] = 	false
				defense_human[ id ] = 	false;
				points_human[ id ] = 	false;
				expcase_human[ id ] = 	false;
				} else {
				postava( id );
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 5: { // Adrenal Human = 6
			if( !( adrenal_human[ id ] ) ) {
				if( !( levels[ id ] < 500 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					g_player_class[ id ] = 	6;
					g_ASTRO[ id ] = 		0;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					adrenal_human[ id ] = 	true;
					resist_human[ id ] = 	false;
					g_item_dmg[ id ] = 	false;
					g_item_gdmg[ id ] = 	false;
					start_human[ id ] =	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
					postava( id );
					ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
					client_cmd( id, "spk valve/sound/buttons/button11" );
				}
			} else {
				postava( id );
			}
		}
		case 6: {
			postava2( id );
		}	
	}
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public postava2( id ) { 
	new szText[ 555 char ], szText2[ 555 char ];
	formatex( szText, charsmax( szText ), "%L", id, "HUMAN_MENU_2", levels[ id ] )
	new nast = menu_create( szText, "postava_items2" );
	
	formatex( szText, charsmax( szText ), "%L", id, "EXP_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "EXP_HUMAN_ON" );
	menu_additem( nast, ( exp_human[ id ] ) ? szText2 : szText, "1", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "SPIRIT_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "SPIRIT_HUMAN_ON" );
	menu_additem( nast, ( spirit_human[ id ] ) ? szText2 : szText, "2", 0 ); 
	
	formatex( szText, charsmax( szText ), "%L", id, "DAMAGE_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "DAMAGE_HUMAN_ON" );
	menu_additem( nast, ( damage_human[ id ] ) ? szText2 : szText, "3", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "MINIGUN_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "MINIGUN_HUMAN_ON" );
	menu_additem( nast, ( minigun_human[ id ] ) ? szText2 : szText, "4", 0 ); 
	
	formatex( szText, charsmax( szText ), "%L", id, "SPECIAL_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "SPECIAL_HUMAN_ON" );
	menu_additem( nast, ( special_human[ id ] ) ? szText2 : szText, "5", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "IMUNE_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "IMUNE_HUMAN_ON" );
	menu_additem( nast, ( imune_human[ id ] ) ? szText2 : szText, "6", 0 );
	
	formatex( szText, charsmax( szText ), "%L \y3/3", id, "MENU_NEXT" );
	menu_additem( nast, szText, "7" );
	menu_display( id, nast, 0 );
}

public postava_items2( id, menu, item ) {
	if( item == MENU_EXIT ) {
		return PLUGIN_HANDLED;
	}
	new text[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "HUMAN_ACTIVATE" );			
	switch( item ) {	
		case 0: {
			if( !( exp_human[ id ] ) ) {
				if( !( levels[ id ] < 1050 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	11;
					start_human[ id ] = 	false;
					fast_human [id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					exp_human[ id ] = 	true;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava2( id );
				}
			} else {
				postava2( id );
			}
		}
		case 1: {
			if( !( spirit_human[ id ] ) ) {
				if( !( levels[ id ] < 1800 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	9;
					resist_human[ id ] = 	false;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	true;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] =	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava2( id );
				}
			} else {
				postava2( id );
			}
		}
		case 2: {
			if( !( damage_human[ id ] ) ) {
				if( !( levels[ id ] < 2000 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		1;
					g_player_class[ id ] = 	6;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	true;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					spirit_human[ id ] = 	false
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
					ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					postava2( id );
				}
			} else {
				postava2( id );
			}
		}
		case 3: {
			if( !( minigun_human[ id ] ) ) {
				if( !( levels[ id ] < 2600 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	7;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	true;
					special_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );  
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava2( id );
				}	
			} else {
				postava2( id );
			}
		}
		case 4: {
			if( !( special_human[ id ] ) ) {
				if( !( levels[ id ] < 3200 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text ); 
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					exp_human[ id ] = 	false;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	8;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	true;
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava2( id );  
				}
			} else {
				postava2( id );
			}
		}
		case 5: {
			if( !( imune_human[ id ] ) ) {
				if( !( levels[ id ] < 4000 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" ); 
					exp_human[ id ] = 	false;
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	10;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					imune_human[ id ] = 	true;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava2( id );
				}
			} else {
				postava2( id );
			}
		}
		case 6: {
			postava3( id );
		}
	}
	menu_destroy( menu );
	return PLUGIN_HANDLED
}

public postava3( id )
{
	new szText[ 555 char ], szText2[ 555 char ];
	formatex( szText, charsmax( szText ), "%L", id, "HUMAN_MENU_3", levels[ id ] );
	new nast = menu_create( szText, "postava_items3" );

	formatex( szText, charsmax( szText ), "%L", id, "RESIST_HUMAN_OFF" );
	formatex( szText, charsmax( szText ), "%L", id, "RESIST_HUMAN_ON" );
	menu_additem( nast, ( resist_human[ id ] ) ? szText2 : szText, "1", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "DEFENSE_HUMAN_OFF" );
	formatex( szText, charsmax( szText ), "%L", id, "DEFENSE_HUMAN_ON" );
	menu_additem( nast, ( defense_human[ id ] ) ? szText2 : szText, "2", 0 );
	
	formatex( szText, charsmax( szText ), "%L", id, "POINTS_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "POINTS_HUMAN_ON" );
	menu_additem( nast, ( points_human[ id ] ) ? szText2 : szText, "3", 0 ); 
	
	formatex( szText, charsmax( szText ), "%L", id, "EXP_CASE_HUMAN_OFF" );
	formatex( szText2, charsmax( szText2 ), "%L", id, "EXP_CASE_HUMAN_ON" );
	menu_additem( nast, ( expcase_human[ id ] ) ? szText2 : szText, "4", 0 );
	
	formatex( szText, charsmax( szText ), "%L \y1/3", id, "MENU_BACK" );
	menu_additem( nast, szText, "5" );
	menu_display( id, nast, 0 );
}

public postava_items3( id, menu, item ) {
	if( item == MENU_EXIT ) {
		return PLUGIN_HANDLED;
	}
	new text[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "HUMAN_ACTIVATE" );				
	switch( item ) {	
		case 0: {
			if( !( resist_human[ id ] ) ) {
				if( !(levels[ id ] < 6000 ) ) {
					set_hudmessage( 255,  255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	16;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					exp_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
					resist_human[ id ] = 	true;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava3( id );
				}
			} else {
				postava3( id );
			}
		}
		case 1: {
			if( !( defense_human[ id ] ) ) {
				if( !( levels[ id ] < 7000 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	12;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					exp_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	true;
					points_human[ id ] = 	false;
					expcase_human[ id ] = 	false;
					resist_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava3( id );
				}
			} else {
				postava3( id );
			}
		}
		case 2: {
			if( !( points_human[ id ] ) ) {
				if( !( levels[ id ] < 8000 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	13;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					exp_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false;
					defense_human[ id ] = 	false;
					points_human[ id ] = 	true;
					expcase_human[ id ] = 	false;
					resist_human[ id ] = 	false;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava3( id );
				}
			} else {
				postava3( id );
			}
		}
		case 3: {
			if( !( expcase_human[ id ] ) ) {
				if( !( levels[ id ] < 9000 ) ) {
					set_hudmessage( 255, 255, 127, -1.0, 0.35, 2, 0.02, 1.0, 0.1, 1.0 );
					ShowSyncHudMsg( id, g_MsgSync8, text );
					client_cmd( id, "spk bluezone/zombie/vyber_humana.wav" );
					Rychly[ id ] = 		0;
					Gravity[ id ] = 		0;
					g_ADAMA[ id ] = 		0;
					g_player_class[ id ] = 	13;
					start_human[ id ] = 	false;
					fast_human[ id ] = 	false;
					frost_human[ id ] = 	false;
					gravity_human[ id ] = 	false;
					strong_human[ id ] = 	false;
					damage_human[ id ] = 	false;
					spirit_human[ id ] = 	false;
					exp_human[ id ] = 	false;
					adrenal_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					minigun_human[ id ] = 	false;
					special_human[ id ] = 	false;
					imune_human[ id ] = 	false
					defense_human[ id ] = 	false;
					points_human[ id ] = 	false;
					resist_human[ id ] = 	false;
					expcase_human[ id ] = 	true;
				} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_ENOUGH_LEVELS" );
				client_cmd( id, "spk valve/sound/buttons/button11" );
				postava3( id );
				}
			} else {
				postava3( id );
			}
		}
		case 4: {
			postava( id );
		}
	}
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public ham_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
	if (g_item_dmg[attacker])
	{
		if (g_item_gdmg[attacker])
			damage*=1.25
	}
	
	else if (g_item_gdmg[attacker])
	{
		if (g_item_gdmg[attacker])
			damage*=1.65
	}
	
	SetHamParamFloat(4, damage + g_item_gdmg[attacker] * 1.05);
}

stock ScreenFade(plr, Float:fDuration, red, green, blue, alpha)
{
	    new i = plr ? plr : get_maxplayers();
	    if( !i )
	    {
		return 0;
	    }
	    
	    message_begin(plr ? MSG_ONE : MSG_ALL, get_user_msgid( "ScreenFade"), {0, 0, 0}, plr);
	    write_short(floatround(4096.0 * fDuration, floatround_round));
	    write_short(floatround(4096.0 * fDuration, floatround_round));
	    write_short(4096);
	    write_byte(red);
	    write_byte(green);
	    write_byte(blue);
	    write_byte(alpha);
	    message_end();
	    
	    return 1;
}

public client_connect(id)
{
	//Nacitat(id) // Nacita Exp a Level
	adrenalin_pohyb[id] = false
	body[id] = 0
	set_task( 1.0, "Task_Show_Power1", id + TASK_EVENT1, _, _, "b" );
}

public client_disconnect(id)
{
	g_item_dmg[id] = false
	g_item_gdmg[id] = false
	//Ulozit(id) // Ulozi Exp a Leve
	adrenalin_pohyb[id] = false
	body[id] = 0
	if( task_exists( id + TASK_EVENT1 ) )
		remove_task( id + TASK_EVENT1 );
}

public Hrac_Spawn(id) 
{
	if(is_user_alive(id))
	{
		//Ulozit(id); // Ulozi Exp a Leve
		//Nacitat(id)
		g_damage[id] = 0
		Rychly[id] = 0
		Gravity[id] = 0
		g_item_dmg[id] = false
		g_item_gdmg[id] = false
		mazbran[id] = false
	}	
}

public inventory( id ) {
	new szText[ 555 char ], szText2[ 555 char ], szText3[ 555 char ];
	formatex( szText, charsmax( szText ), lang[ 35 ][ g_player_lang[ id ] ], exp_case[ id ] );
	formatex( szText2, charsmax( szText2 ), lang[ 36 ][ g_player_lang[ id ] ], lvl_case[ id ] );
	formatex( szText3, charsmax( szText3 ), lang[ 37 ][ g_player_lang[ id ] ], playaspro_case[ id ] );
	new hm = menu_create( lang[ 38 ][ g_player_lang[ id ] ], "inventory_handle" );
	if( exp_case[ id ] >= 1 )
		menu_additem( hm, szText );
	else
		menu_additem( hm, lang[ 39 ][ g_player_lang[ id ] ] );
	if( lvl_case[ id ] >= 1 )
		menu_additem( hm, szText2 );
	else 
		menu_additem( hm, lang[ 39 ][ g_player_lang[ id ] ] );
	if( playaspro_case[ id ] >= 1 )
		menu_additem( hm, szText3 );
	else 
		menu_additem( hm, lang[ 39 ][ g_player_lang[ id ] ] );
	menu_additem( hm, lang[ 39 ][ g_player_lang[ id ] ] );
	menu_additem( hm, lang[ 39 ][ g_player_lang[ id ] ] );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public inventory_handle( id, menu, item ) {	
	
	if( item == MENU_EXIT ) {
		menu_destroy( menu )
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( exp_case[ id ] >= 1 ) {
				open_exp_case( id );
				inventory( id );
			} else {
				client_print( id, print_center, lang[ 40 ][ g_player_lang[ id ] ] );
				inventory( id );
			}
		} 
		case 1: {
			if( lvl_case[ id ] >= 1 ) {
				open_lvl_case( id );
				inventory( id );
			} else {
				client_print( id, print_center, lang[ 40 ][ g_player_lang[ id ] ] );
				inventory( id );
			}
		}
		case 2: {
			if( playaspro_case[ id ] >= 1 ) {
				open_playaspro_case( id );
				inventory( id );
			} else {
				client_print( id, print_center, lang[ 40 ][ g_player_lang[ id ] ] );
				inventory( id );
			}
		}
		case 3: {
			client_print( id, print_center, lang[ 40 ][ g_player_lang[ id ] ] );
			inventory( id );
		}
		case 4: {
			client_print( id, print_center, lang[ 40 ][ g_player_lang[ id ] ] );
			inventory( id );
		}
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public open_playaspro_case( id ) {
	playaspro_case[ id ]--;
	inventory( id );
	ScreenFade( id, 0.3, 255, 155, 43, 100 );
	switch( random( 16 ) ) {
		case 0: {
			g_ammopacks[ id ] += 200;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_200" );
		}
		case 1: {
			g_ammopacks[ id ] += 50;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_50" );
		}
		case 2: {
			body[ id ] += 10;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_10" );
		}
		case 3: {
			body[ id ] += 5;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_5" );
		}
		case 4: {
			exp[ id ] += 2000;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_2000" );
		}
		case 5: {
			exp[ id ] += 1000;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_1000" );
		}
		case 6: {
			levels[ id ] += 25;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_25" );
		}
		case 7: {
			levels[ id ] += 25;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_25" );
		}
		case 8: {
			exp_case[ id ] += 4;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_4" );
		}
		case 9: {
			exp_case[ id ] += 4;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_4" );
		}
		case 10: {
			lvl_case[ id ] += 2;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_2" );
		}
		case 11: {
			lvl_case[ id ] += 2;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_2" );
		}
		case 12: {
			playaspro_case[ id ] += 1;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_1" );
		}
		case 13: {
			playaspro_case[ id ] += 1;
			ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_1" );
		}
		case 14: {
			if( !g_epicUltimate[ id ] ) {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_NOSLOW" );
				g_epicUltimate[ id ] = true;
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_50" );
				g_ammopacks[ id ] += 50;
			}
		}
		case 15: {
			if( !g_epic20hpmap[ id ] ) {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_400" );
				g_epic20hpmap[ id ] = true;
				get_300( id );
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_500" );
				exp[ id ] += 500;
			}
		}
		case 16: {
			if( !g_epic20dmgmap[ id ] ) {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_DMG" );
				g_epic20dmgmap[ id ] = true;
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "YOU_GET_5" );
				body[ id ] += 5;
			}
		}
	}
	client_cmd( id, "spk playaspro/zakupenie.wav" );
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public open_lvl_case( id ) {
	new name[ 32 ];
	new lvly = 0;
	get_user_name( id, name, 31 );
	lvl_case[ id ]--;
	inventory( id );
	ScreenFade( id, 0.3, 255, 155, 43, 100 );
	switch( random( 19 ) ) {
		case 0: {
			lvly += 2;
		}
		case 1: {
			lvly += 2;
		}
		case 2: {
			lvly += 2;
		}
		case 3: {
			lvly += 2;
		}
		case 4: {
			lvly += 2;
		}
		case 5: {
			lvly += 5;
		}
		case 6: {
			lvly += 5;
		}
		case 7: {
			lvly += 15;
		}
		case 8: {
			lvly += 5;
		}
		case 9: {
			lvly += 5;
		}
		case 10: {
			lvly += 15;
		}
		case 11: {
			lvly += 2;
		}
		case 12: {
			lvly += 2;
		}
		case 13: {
			lvly += 5;
		}
		case 14: {
			lvly += 5;
		}
		case 15: {
			lvly += 7;
		}
		case 16: {
			lvly += 9;
		}
		case 17: {
			lvly += 20;
		}
		case 18: {
			lvly += 20;
		}
		case 19: {
			lvly += 100;
		}
	}
	levels[ id ] += lvly;
	ChatColor( id, "%L", LANG_PLAYER, "BONUS_LVL_CASE", lvly );
	client_cmd( id, "spk playaspro/zakupenie.wav" );
	SQL_UpdateUser( id );
}

public open_exp_case( id ) {
	exp_case[ id ]--;
	new name[ 32 ];
	new expcka = 0;
	ScreenFade( id, 0.3, 255, 255, 42, 100 );
	get_user_name( id, name, 31 );
	inventory( id );
	switch( random( 19 ) ) {
		case 0: {
			expcka += 5000;
		}
		case 1: {
			expcka += 1500;
		}
		case 2: {
			expcka += random_num( 250, 500 );
		}
		case 3: {
			expcka += random_num( 250, 500 );
		}
		case 4: {
			expcka += random_num( 250, 500 );
		}
		case 5: {
			expcka += random_num( 250, 500 );
		}
		case 6: {
			expcka += random_num( 250, 500 );
		}
		case 7: {
			expcka += random_num( 250, 500 );
		}
		case 8: {
			expcka += random_num( 250, 1000 );
		}
		case 9: {
			expcka += random_num( 250, 500 );
		}
		case 10: {
			expcka += random_num( 250, 500 );
		}
		case 11: {
			expcka += random_num( 250, 500 );
		}
		case 12: {
			expcka += random_num( 250, 500 );
		}
		case 13: {
			expcka += random_num( 250, 500 );
		}
		case 14: {
			expcka += random_num( 250, 500 );
		}
		case 15: {
			expcka += random_num( 250, 500 );
		}
		case 16: {
			expcka += random_num( 250, 500 );
		}
		case 17: {
			expcka += random_num( 250, 500 );
		}
		case 18: {
			expcka += random_num( 250, 1000 );
		}
		case 19: {
			expcka += random_num( 250, 10000 );
		}
	}
	exp[ id ] += expcka;
	ChatColor( id, "%L", LANG_PLAYER, "BONUS_EXP_CASE", expcka );
	client_cmd( id, "spk playaspro/zakupenie.wav" );
	SQL_UpdateUser( id );
}

public settings_menu( id ) {
	if( !is_user_alive( id ) ) {
		ChatColor( id, "%s", lang[ 30 ][ g_player_lang[ id ] ] );
		return PLUGIN_HANDLED;
	}
	new text[ 555 char ], text2[ 555 char ];
	formatex( text, charsmax( text ), "%L", id, "SETTINGS_MENU" );
	new hm = menu_create( text, "settings_handle" );
	
	formatex( text, charsmax( text ), "%L", id, "3D_VIEW_ON" );
	formatex( text2, charsmax( text2 ), "%L", id, "3D_VIEW_OFF" );
	menu_additem( hm, ( pohlad[ id ] ) ? text : text2 );
	
	formatex( text, charsmax( text ), "%L", id, "UNSTUCK_MENU" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "MENU_BACK" );
	menu_additem( hm, text );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public settings_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( pohlad[ id ] ) {
				pohlad[ id ] = false; get_camera( id ); settings_menu( id );
			} else {
				pohlad[ id ] = true; get_camera( id ); settings_menu( id );
			}
		}
		case 1: {
			if( is_player_stuck( id ) ) {
				if( get_pcvar_num( cvar_randspawn ) ) {
					do_random_spawn( id );
				} else {
					do_random_spawn( id, 1 );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "NOT_STUCKED" );
				settings_menu( id );
			}
		}
		case 2: {
			client_cmd( id, "say /zpmenu" );
		}
	}
	return PLUGIN_HANDLED;
}

// Buy Menu 1
public menu_buy1(id, key)
{
	// Player dead?
	if (!g_isalive[id])
		return PLUGIN_HANDLED;
	
	// Zombies or survivors get no guns
	if (g_zombie[id] || g_survivor[id])
		return PLUGIN_HANDLED;
	
	// Special keys / weapon list exceeded
	if (key >= MENU_KEY_AUTOSELECT || WPN_SELECTION >= WPN_MAXIDS)
	{
		switch (key)
		{
			case MENU_KEY_AUTOSELECT: // toggle auto select
			{
				WPN_AUTO_ON = 1 - WPN_AUTO_ON
			}
			case MENU_KEY_NEXT: // next/back
			{
				if (WPN_STARTID+7 < WPN_MAXIDS)
					WPN_STARTID += 7
				else
					WPN_STARTID = 0
			}
			case MENU_KEY_EXIT: // exit
			{
				return PLUGIN_HANDLED;
			}
		}
		
		// Show buy menu again
		show_menu_buy1(id)
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon id
	WPN_AUTO_PRI = WPN_SELECTION
	
	// Buy primary weapon
	buy_primary_weapon(id, WPN_AUTO_PRI)
	
	// Show pistols menu
	show_menu_buy2(id)
	
	return PLUGIN_HANDLED;
}

// Buy Primary Weapon
buy_primary_weapon(id, selection)
{
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Get weapon's id and name
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_primary_weaponids, selection)
	ArrayGetString(g_primary_items, selection, wname, charsmax(wname))
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	// Weapons bought
	g_canbuy[id] = false
	
	// Give additional items
	static i
	for (i = 0; i < ArraySize(g_additional_items); i++)
	{
		ArrayGetString(g_additional_items, i, wname, charsmax(wname))
		fm_give_item(id, wname)
	}
}

// Buy Menu 2
public menu_buy2(id, key)
{
	// Player dead?
	if (!g_isalive[id])
		return PLUGIN_HANDLED;
	
	// Zombies or survivors get no guns
	if (g_zombie[id] || g_survivor[id])
		return PLUGIN_HANDLED;
	
	// Special keys / weapon list exceeded
	if (key >= ArraySize(g_secondary_items))
	{
		// Toggle autoselect
		if (key == MENU_KEY_AUTOSELECT)
			WPN_AUTO_ON = 1 - WPN_AUTO_ON
		
		// Reshow menu unless user exited
		if (key != MENU_KEY_EXIT)
			show_menu_buy2(id)
		
		return PLUGIN_HANDLED;
	}
	
	// Store selected weapon
	WPN_AUTO_SEC = key
	
	// Drop secondary gun again, in case we picked another (bugfix)
	drop_weapons(id, 2)
	
	// Get weapon's id
	static weaponid, wname[32]
	weaponid = ArrayGetCell(g_secondary_weaponids, key)
	ArrayGetString(g_secondary_items, key, wname, charsmax(wname))
	
	// Give the new weapon and full ammo
	fm_give_item(id, wname)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	
	return PLUGIN_HANDLED;
}

// Extra Items Menu
public menu_extras(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_EXTRAS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Dead players are not allowed to buy items
	if (!g_isalive[id])
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve extra item id
	static buffer[2], dummy, itemid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	itemid = buffer[0]
	
	// Attempt to buy the item
	buy_extra_item(id, itemid)
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Buy Extra Item
buy_extra_item(id, itemid, ignorecost = 0)
{
	// Retrieve item's team
	static team
	team = ArrayGetCell(g_extraitem_team, itemid)
	
	// Check for team/class specific items
	if ((g_zombie[id] && !g_nemesis[id] && !(team & ZP_TEAM_ZOMBIE)) || (!g_zombie[id] && !g_survivor[id] && !(team & ZP_TEAM_HUMAN)) || (g_nemesis[id] && !(team & ZP_TEAM_NEMESIS)) || (g_survivor[id] && !(team & ZP_TEAM_SURVIVOR)))
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
		return;
	}
	
	// Check for unavailable items
	if ((itemid == EXTRA_NVISION && !get_pcvar_num(cvar_extranvision))
	|| (itemid == EXTRA_ANTIDOTE && (!get_pcvar_num(cvar_extraantidote) || g_antidotecounter >= get_pcvar_num(cvar_antidotelimit)))
	|| (itemid == EXTRA_MADNESS && (!get_pcvar_num(cvar_extramadness) || g_madnesscounter >= get_pcvar_num(cvar_madnesslimit)))
	|| (itemid == EXTRA_INFBOMB && (!get_pcvar_num(cvar_extrainfbomb) || g_infbombcounter >= get_pcvar_num(cvar_infbomblimit)))
	|| (itemid >= EXTRA_WEAPONS_STARTID && itemid <= EXTRAS_CUSTOM_STARTID-1 && !get_pcvar_num(cvar_extraweapons)))
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
		return;
	}
	
	// Check for hard coded items with special conditions
	if ((itemid == EXTRA_ANTIDOTE && (g_endround || g_swarmround || g_nemround || g_survround || g_plagueround || fnGetZombies() <= 1 || (get_pcvar_num(cvar_deathmatch) && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() == 1)))
	|| (itemid == EXTRA_MADNESS && g_nodamage[id]) || (itemid == EXTRA_INFBOMB && (g_endround || g_swarmround || g_nemround || g_survround || g_plagueround)))
	{
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_CANTUSE")
		return;
	}
	
	// Ignore item's cost?
	if (!ignorecost)
	{
		// Check that we have enough ammo packs
		if (g_ammopacks[id] < ArrayGetCell(g_extraitem_cost, itemid))
		{
			zp_colored_print(id, "^x04[ZP]^x01 %L", id, "NOT_ENOUGH_AMMO")
			return;
		}
		
		// Deduce item cost
		g_ammopacks[id] -= ArrayGetCell(g_extraitem_cost, itemid)
	}
	
	// Check which kind of item we're buying
	switch (itemid)
	{
		case EXTRA_NVISION: // Night Vision
		{
			g_nvision[id] = true
			
			if (!g_isbot[id])
			{
				g_nvisionenabled[id] = true
				
				// Custom nvg?
				if (get_pcvar_num(cvar_customnvg))
				{
					remove_task(id+TASK_NVISION)
					set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
				}
				else
					set_user_gnvision(id, 1)
			}
			else
				cs_set_user_nvg(id, 1)
		}
		case EXTRA_ANTIDOTE: {
			if (last_human == 1) {
				g_ammopacks[id] += g_extra_costs2[EXTRA_ANTIDOTE]
				ChatColor( id, "%L", LANG_PLAYER, "LAST_HUMAN_ANTIDOTE" );
				return;
			}
			if (g_firstzombie[id]) {
					g_ammopacks[id] += g_extra_costs2[EXTRA_ANTIDOTE]
					ChatColor( id, "%L", LANG_PLAYER, "FIRST_ZOMBIE_ANTIDOTE" );
					return;
			}
			if( fnGetZombies() < 6 ) {
				g_ammopacks[id] += g_extra_costs2[EXTRA_ANTIDOTE]
				ChatColor( id, "%L", LANG_PLAYER, "6_ZOMBIES_ANTIDOTE" );
				return;
			}
			// Increase antidote purchase count for this round
			g_antidotecounter++
			
			humanme(id, 0, 0)
		}
		case EXTRA_MADNESS: // Zombie Madness
		{
			// Increase madness purchase count for this round
			g_madnesscounter++
			
			g_nodamage[id] = true
			set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
			set_task(get_pcvar_float(cvar_madnessduration), "madness_over", id+TASK_BLOOD)
			
			static sound[64]
			ArrayGetString(zombie_madness, random_num(0, ArraySize(zombie_madness) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case EXTRA_INFBOMB: // Infection Bomb
		{
			// Increase infection bomb purchase count for this round
			g_infbombcounter++
			
			// Already own one
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				// Increase BP ammo on it instead
				cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + 1)
				
				// Flash ammo in hud
				message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
				write_byte(AMMOID[CSW_HEGRENADE]) // ammo id
				write_byte(1) // ammo amount
				message_end()
				
				// Play clip purchase sound
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				return; // stop here
			}
			
			// Give weapon to the player
			fm_give_item(id, "weapon_hegrenade")
		}
		default:
		{
			if (itemid >= EXTRA_WEAPONS_STARTID && itemid <= EXTRAS_CUSTOM_STARTID-1) // Weapons
			{
				// Get weapon's id and name
				static weaponid, wname[32]
				ArrayGetString(g_extraweapon_items, itemid - EXTRA_WEAPONS_STARTID, wname, charsmax(wname))
				weaponid = cs_weapon_name_to_id(wname)
				
				// If we are giving a primary/secondary weapon
				if (MAXBPAMMO[weaponid] > 2)
				{
					// Make user drop the previous one
					if ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)
						drop_weapons(id, 1)
					else
						drop_weapons(id, 2)
					
					// Give full BP ammo for the new one
					ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
				}
				// If we are giving a grenade which the user already owns
				else if (user_has_weapon(id, weaponid))
				{
					// Increase BP ammo on it instead
					cs_set_user_bpammo(id, weaponid, cs_get_user_bpammo(id, weaponid) + 1)
					
					// Flash ammo in hud
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(AMMOID[weaponid]) // ammo id
					write_byte(1) // ammo amount
					message_end()
					
					// Play clip purchase sound
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					return; // stop here
				}
				
				// Give weapon to the player
				fm_give_item(id, wname)
			}
			else // Custom additions
			{
				// Item selected forward
				ExecuteForward(g_fwExtraItemSelected, g_fwDummyResult, id, itemid);
				
				// Item purchase blocked, restore buyer's ammo packs
				if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && !ignorecost)
					g_ammopacks[id] += ArrayGetCell(g_extraitem_cost, itemid)
			}
		}
	}
}

// Zombie Class Menu
public menu_zclass(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_ZCLASS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve zombie class id
	static buffer[2], dummy, classid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	classid = buffer[0]
	
	// Store selection for the next infection
	g_zombieclassnext[id] = classid
	
	static name[32]
	ArrayGetString(g_zclass_name, g_zombieclassnext[id], name, charsmax(name))
	
	// Show selected zombie class info and stats
	zp_colored_print(id, "^x04[ZP]^x01 %L: %s", id, "ZOMBIE_SELECT", name)
	zp_colored_print(id, "^x04[ZP]^x01 %L: %d %L: %d %L: %d %L: %d%%", id, "ZOMBIE_ATTRIB1", ArrayGetCell(g_zclass_hp, g_zombieclassnext[id]), id, "ZOMBIE_ATTRIB2", ArrayGetCell(g_zclass_spd, g_zombieclassnext[id]),
	id, "ZOMBIE_ATTRIB3", floatround(Float:ArrayGetCell(g_zclass_grav, g_zombieclassnext[id]) * 800.0), id, "ZOMBIE_ATTRIB4", floatround(Float:ArrayGetCell(g_zclass_kb, g_zombieclassnext[id]) * 100.0))
	
	menu_destroy(menuid)
	return PLUGIN_HANDLED;
}

// Info Menu
public menu_info(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	
	static motd[1500], len
	len = 0
	
	switch (key)
	{
		case 0: // General
		{
			static weather, lighting[2]
			weather = 0
			get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
			strtolower(lighting)
			
			len += formatex(motd[len], charsmax(motd) - len, "%L ", id, "MOTD_INFO11", "Zombie Plague", PLUGIN_VERSION, "MeRcyLeZZ")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO12")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_A")
			
			if (g_ambience_fog)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_FOG")
				weather++
			}
			if (g_ambience_rain)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_RAIN")
				weather++
			}
			if (g_ambience_snow)
			{
				len += formatex(motd[len], charsmax(motd) - len, (weather < 1) ? " %L" : ". %L", id, "MOTD_SNOW")
				weather++
			}
			if (weather < 1) len += formatex(motd[len], charsmax(motd) - len, " %L", id, "MOTD_DISABLED")
			
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_B", lighting)
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_C", id, get_pcvar_num(cvar_triggered) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (lighting[0] >= 'a' && lighting[0] <= 'd' && get_pcvar_float(cvar_thunder) > 0.0) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_D", floatround(get_pcvar_float(cvar_thunder)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_E", id, get_pcvar_num(cvar_removedoors) > 0 ? get_pcvar_num(cvar_removedoors) > 1 ? "MOTD_DOORS" : "MOTD_ROTATING" : "MOTD_ENABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_F", id, get_pcvar_num(cvar_deathmatch) > 0 ? get_pcvar_num(cvar_deathmatch) > 1 ? get_pcvar_num(cvar_deathmatch) > 2 ? "MOTD_ENABLED" : "MOTD_DM_ZOMBIE" : "MOTD_DM_HUMAN" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_deathmatch)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_G", floatround(get_pcvar_float(cvar_spawnprotection)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_H", id, get_pcvar_num(cvar_randspawn) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_I", id, get_pcvar_num(cvar_extraitems) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_J", id, get_pcvar_num(cvar_zclasses) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_K", id, get_pcvar_num(cvar_customnvg) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO1_L", id, g_cached_customflash ? "MOTD_ENABLED" : "MOTD_DISABLED")
			
			show_motd(id, motd)
		}
		case 1: // Humans
		{
			new armor = g_unAPLevel[ id ] * 4;
			len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2" );
			//len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_A", g_unHPLevel[ id ] );
			//len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_B", armor );
			//len += formatex( motd[ len ], charsmax( motd ) - len, "%L", id, "MOTD_INFO2_C", g_unDMLevel[ id ] );
			/*len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_D", floatround(get_pcvar_float(cvar_humangravity) * 800.0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_E", id, get_pcvar_num(cvar_infammo) > 0 ? get_pcvar_num(cvar_infammo) > 1 ? "MOTD_AMMO_CLIP" : "MOTD_AMMO_BP" : "MOTD_LIMITED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_F", get_pcvar_num(cvar_ammodamage_human))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_G", id, get_pcvar_num(cvar_firegrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_H", id, get_pcvar_num(cvar_frostgrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_I", id, get_pcvar_num(cvar_flaregrenades) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO2_J", id, get_pcvar_num(cvar_knockback) ? "MOTD_ENABLED" : "MOTD_DISABLED")*/
			
			show_motd(id, motd)
		}
		case 2: // Zombies
		{
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_A", ArrayGetCell(g_zclass_hp, 0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_B", floatround(float(ArrayGetCell(g_zclass_hp, 0)) * get_pcvar_float(cvar_zombiefirsthp)))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_C", floatround(get_pcvar_float(cvar_zombiearmor) * 100.0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_D", floatround(get_pcvar_float(cvar_zombiearmor2) * 100.0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_E", ArrayGetCell(g_zclass_spd, 0))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_F", floatround(Float:ArrayGetCell(g_zclass_grav, 0) * 800.0))
			if (get_pcvar_num(cvar_zombiebonushp)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_F", get_pcvar_num(cvar_zombiebonushp))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_G", id, get_pcvar_num(cvar_zombiepainfree) > 0 ? get_pcvar_num(cvar_zombiepainfree) > 1 ? "MOTD_LASTZOMBIE" : "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_H", id, get_pcvar_num(cvar_zombiebleeding) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO3_I", get_pcvar_num(cvar_ammoinfect))
			
			show_motd(id, motd)
		}
		case 3: // Gameplay Modes
		{
			static nemhp[5], survhp[5]
			
			// Get nemesis and survivor health
			num_to_str(get_pcvar_num(cvar_nemhp), nemhp, charsmax(nemhp))
			num_to_str(get_pcvar_num(cvar_survhp), survhp, charsmax(survhp))
			
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4")
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_A", id, get_pcvar_num(cvar_nem) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_nem))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_B", get_pcvar_num(cvar_nemchance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_C", get_pcvar_num(cvar_nemhp) > 0 ? nemhp : "[Auto]")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_D", get_pcvar_num(cvar_nemspd))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_E", floatround(get_pcvar_float(cvar_nemgravity) * 800.0))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_F", id, g_cached_leapnemesis ? "MOTD_ENABLED" : "MOTD_DISABLED")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_G", id, get_pcvar_num(cvar_nempainfree) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_H", id, get_pcvar_num(cvar_surv) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_surv))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_I", get_pcvar_num(cvar_survchance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_J", get_pcvar_num(cvar_survhp) > 0 ? survhp : "[Auto]")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_K", get_pcvar_num(cvar_survspd))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_L", floatround(get_pcvar_float(cvar_survgravity) * 800.0))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_M", id, g_cached_leapsurvivor ? "MOTD_ENABLED" : "MOTD_DISABLED")
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_N", id, get_pcvar_num(cvar_survpainfree) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_O", id, get_pcvar_num(cvar_swarm) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_swarm)) len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_P", get_pcvar_num(cvar_swarmchance))
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_Q", id, get_pcvar_num(cvar_multi) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_multi))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_R", get_pcvar_num(cvar_multichance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_S", floatround(get_pcvar_float(cvar_multiratio) * 100.0))
			}
			len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_T", id, get_pcvar_num(cvar_plague) ? "MOTD_ENABLED" : "MOTD_DISABLED")
			if (get_pcvar_num(cvar_plague))
			{
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_U", get_pcvar_num(cvar_plaguechance))
				len += formatex(motd[len], charsmax(motd) - len, "%L", id, "MOTD_INFO4_V", floatround(get_pcvar_float(cvar_plagueratio) * 100.0))
			}
			
			show_motd(id, motd)
		}
		default: return PLUGIN_HANDLED;
	}
	
	// Show help menu again if user wishes to read another topic
	show_menu_info(id)
	
	return PLUGIN_HANDLED;
}

// Admin Menu
public menu_admin(id, key)
{
	// Player disconnected?
	if (!g_isconnected[id])
		return PLUGIN_HANDLED;
	
	static userflags
	userflags = get_user_flags(id)
	
	switch (key)
	{
		case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_INFECTION] | g_access_flag[ACCESS_MAKE_ZOMBIE] | g_access_flag[ACCESS_MAKE_HUMAN]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_ZOMBIEFY_HUMANIZE
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case ACTION_MAKE_NEMESIS: // Nemesis command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_NEMESIS] | g_access_flag[ACCESS_MAKE_NEMESIS]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_NEMESIS
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case ACTION_MAKE_SURVIVOR: // Survivor command
		{
			if (userflags & (g_access_flag[ACCESS_MODE_SURVIVOR] | g_access_flag[ACCESS_MAKE_SURVIVOR]))
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_MAKE_SURVIVOR
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case ACTION_RESPAWN_PLAYER: // Respawn command
		{
			if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
			{
				// Show player list for admin to pick a target
				PL_ACTION = ACTION_RESPAWN_PLAYER
				show_menu_player_list(id)
			}
			else
			{
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				show_menu_admin(id)
			}
		}
		case ACTION_MODE_SWARM: // Swarm Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_SWARM])
			{
				if (allowed_swarm())
					command_swarm(id)
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu_admin(id)
		}
		case ACTION_MODE_MULTI: // Multiple Infection command
		{
			if (userflags & g_access_flag[ACCESS_MODE_MULTI])
			{
				if (allowed_multi())
					command_multi(id)
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu_admin(id)
		}
		case ACTION_MODE_PLAGUE: // Plague Mode command
		{
			if (userflags & g_access_flag[ACCESS_MODE_PLAGUE])
			{
				if (allowed_plague())
					command_plague(id)
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
			}
			else
				zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			
			show_menu_admin(id)
		}
	}
	
	return PLUGIN_HANDLED;
}

// Player List Menu
public menu_player_list(id, menuid, item)
{
	// Player disconnected?
	if (!is_user_connected(id))
	{
		menu_destroy(menuid)
		return PLUGIN_HANDLED;
	}
	
	// Remember player's menu page
	static menudummy
	player_menu_info(id, menudummy, menudummy, MENU_PAGE_PLAYERS)
	
	// Menu was closed
	if (item == MENU_EXIT)
	{
		menu_destroy(menuid)
		show_menu_admin(id)
		return PLUGIN_HANDLED;
	}
	
	// Retrieve player id
	static buffer[2], dummy, playerid
	menu_item_getinfo(menuid, item, dummy, buffer, charsmax(buffer), _, _, dummy)
	playerid = buffer[0]
	
	// Perform action on player
	
	// Get admin flags
	static userflags
	userflags = get_user_flags(id)
	
	// Make sure it's still connected
	if (g_isconnected[playerid])
	{
		// Perform the right action if allowed
		switch (PL_ACTION)
		{
			case ACTION_ZOMBIEFY_HUMANIZE: // Zombiefy/Humanize command
			{
				if (g_zombie[playerid])
				{
					if (userflags & g_access_flag[ACCESS_MAKE_HUMAN])
					{
						if (allowed_human(playerid))
							command_human(id, playerid)
						else
							zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				}
				else
				{
					if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_INFECTION]) : (userflags & g_access_flag[ACCESS_MAKE_ZOMBIE]))
					{
						if (allowed_zombie(playerid))
							command_zombie(id, playerid)
						else
							zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
					}
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
				}
			}
			case ACTION_MAKE_NEMESIS: // Nemesis command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_NEMESIS]) : (userflags & g_access_flag[ACCESS_MAKE_NEMESIS]))
				{
					if (allowed_nemesis(playerid))
						command_nemesis(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case ACTION_MAKE_SURVIVOR: // Survivor command
			{
				if (g_newround ? (userflags & g_access_flag[ACCESS_MODE_SURVIVOR]) : (userflags & g_access_flag[ACCESS_MAKE_SURVIVOR]))
				{
					if (allowed_survivor(playerid))
						command_survivor(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
			case ACTION_RESPAWN_PLAYER: // Respawn command
			{
				if (userflags & g_access_flag[ACCESS_RESPAWN_PLAYERS])
				{
					if (allowed_respawn(playerid))
						command_respawn(id, playerid)
					else
						zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
				}
				else
					zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT_ACCESS")
			}
		}
	}
	else
		zp_colored_print(id, "^x04[ZP]^x01 %L", id, "CMD_NOT")
	
	menu_destroy(menuid)
	show_menu_player_list(id)
	return PLUGIN_HANDLED;
}

// CS Buy Menus
public menu_cs_buy(id, key)
{
	// Prevent buying if zombie/survivor (bugfix)
	if (g_zombie[id] || g_survivor[id])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

/*================================================================================
 [Admin Commands]
=================================================================================*/

// zp_toggle [1/0]
public cmd_toggle(id, level, cid)
{
	// Check for access flag - Enable/Disable Mod
	if (!cmd_access(id, g_access_flag[ACCESS_ENABLE_MOD], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	new arg[2]
	read_argv(1, arg, charsmax(arg))
	
	// Mod already enabled/disabled
	if (str_to_num(arg) == g_pluginenabled)
		return PLUGIN_HANDLED;
	
	// Set toggle cvar
	set_pcvar_num(cvar_toggle, str_to_num(arg))
	client_print(id, print_console, "Zombie Plague %L.", id, str_to_num(arg) ? "MOTD_ENABLED" : "MOTD_DISABLED")
	
	// Retrieve map name
	new mapname[32]
	get_mapname(mapname, charsmax(mapname))
	
	// Restart current map
	server_cmd("changelevel %s", mapname)
	
	return PLUGIN_HANDLED;
}

// zp_zombie [target]
public cmd_zombie(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Infection
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_INFECTION], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Zombie
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_ZOMBIE], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be zombie
	if (!allowed_zombie(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED
	}
	
	command_zombie(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_human [target]
public cmd_human(id, level, cid)
{
	// Check for access flag - Make Human
	if (!cmd_access(id, g_access_flag[ACCESS_MAKE_HUMAN], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be human
	if (!allowed_human(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_human(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_survivor [target]
public cmd_survivor(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Survivor
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_SURVIVOR], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Survivor
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_SURVIVOR], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be survivor
	if (!allowed_survivor(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_survivor(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_nemesis [target]
public cmd_nemesis(id, level, cid)
{
	// Check for access flag depending on the resulting action
	if (g_newround)
	{
		// Start Mode Nemesis
		if (!cmd_access(id, g_access_flag[ACCESS_MODE_NEMESIS], cid, 2))
			return PLUGIN_HANDLED;
	}
	else
	{
		// Make Nemesis
		if (!cmd_access(id, g_access_flag[ACCESS_MAKE_NEMESIS], cid, 2))
			return PLUGIN_HANDLED;
	}
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, (CMDTARGET_ONLY_ALIVE | CMDTARGET_ALLOW_SELF))
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be nemesis
	if (!allowed_nemesis(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_nemesis(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_respawn [target]
public cmd_respawn(id, level, cid)
{
	// Check for access flag - Respawn
	if (!cmd_access(id, g_access_flag[ACCESS_RESPAWN_PLAYERS], cid, 2))
		return PLUGIN_HANDLED;
	
	// Retrieve arguments
	static arg[32], player
	read_argv(1, arg, charsmax(arg))
	player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF)
	
	// Invalid target
	if (!player) return PLUGIN_HANDLED;
	
	// Target not allowed to be respawned
	if (!allowed_respawn(player))
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_respawn(id, player)
	
	return PLUGIN_HANDLED;
}

// zp_swarm
public cmd_swarm(id, level, cid)
{
	// Check for access flag - Mode Swarm
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_SWARM], cid, 1))
		return PLUGIN_HANDLED;
	
	// Swarm mode not allowed
	if (!allowed_swarm())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_swarm(id)
	
	return PLUGIN_HANDLED;
}

// zp_multi
public cmd_multi(id, level, cid)
{
	// Check for access flag - Mode Multi
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_MULTI], cid, 1))
		return PLUGIN_HANDLED;
	
	// Multi infection mode not allowed
	if (!allowed_multi())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_multi(id)
	
	return PLUGIN_HANDLED;
}

// zp_plague
public cmd_plague(id, level, cid)
{
	// Check for access flag - Mode Plague
	if (!cmd_access(id, g_access_flag[ACCESS_MODE_PLAGUE], cid, 1))
		return PLUGIN_HANDLED;
	
	// Plague mode not allowed
	if (!allowed_plague())
	{
		client_print(id, print_console, "[ZP] %L", id, "CMD_NOT")
		return PLUGIN_HANDLED;
	}
	
	command_plague(id)
	
	return PLUGIN_HANDLED;
}

/*================================================================================
 [Message Hooks]
=================================================================================*/

// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!g_isalive[msg_entity] || g_zombie[msg_entity])
		return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
		return;
	
	// Unlimited clip disabled for class
	if (g_survivor[msg_entity] ? get_pcvar_num(cvar_survinfammo) <= 1 : get_pcvar_num(cvar_infammo) <= 1)
		return;
	
	// Get weapon's id
	static weapon
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		static weapon_ent
		weapon_ent = fm_cs_get_current_weapon_ent(msg_entity)
		if (pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Take off player's money
public message_money(msg_id, msg_dest, msg_entity)
{
	// Remove money setting enabled?
	if (!get_pcvar_num(cvar_removemoney))
		return PLUGIN_CONTINUE;
	
	fm_cs_set_user_money(msg_entity, 0)
	return PLUGIN_HANDLED;
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
		return PLUGIN_CONTINUE;
	
	// Nemesis shouldn't be FBed
	if (g_zombie[msg_entity] && !g_nemesis[msg_entity])
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), get_pcvar_num(cvar_nvgcolor[0]))
		set_msg_arg_int(5, get_msg_argtype(5), get_pcvar_num(cvar_nvgcolor[1]))
		set_msg_arg_int(6, get_msg_argtype(6), get_pcvar_num(cvar_nvgcolor[2]))
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_HANDLED;
}

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle()
{
	return PLUGIN_HANDLED;
}

// Set correct model on player corpses
public message_clcorpse()
{
	set_msg_arg_string(1, g_playermodel[get_msg_arg_int(12)])
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end()
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Game commencing, reset scores only (round end is automatically triggered)
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_gamecommencing = true
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Team Switch (or player joining a team for first time)
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return;
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return;
	
	// Get player's id
	static id
	id = get_msg_arg_int(1)
	
	// Invalid player id? (bugfix)
	if (!(1 <= id <= g_maxplayers)) return;
	
	// Enable spectators' nightvision if not spawning right away
	set_task(0.2, "spec_nvision", id)
	
	// Round didn't start yet, nothing to worry about
	if (g_newround) return;
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
		case 'C': // CT
		{
			if (g_survround && fnGetHumans()) // survivor alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
			else if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
		case 'T': // Terrorist
		{
			if ((g_swarmround || g_survround) && fnGetHumans()) // survivor alive or swarm round w/ humans --> spawn as zombie
			{
				g_respawn_as_zombie[id] = true;
			}
			else if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

/*================================================================================
 [Main Functions]
=================================================================================*/

// Make Zombie Task
public make_zombie_task()
{
	// Call make a zombie with no specific mode
	make_a_zombie(MODE_NONE, 0)
}

// Make a Zombie Function
make_a_zombie(mode, id)
{
	// Get alive players count
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	// Not enough players, come back later!
	if (iPlayersnum < 1)
	{
		set_task(2.0, "make_zombie_task", TASK_MAKEZOMBIE)
		return;
	}
	
	// Round started!
	g_newround = false
	
	// Set up some common vars
	static forward_id, sound[64], iZombies, iMaxZombies
	
	if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SURVIVOR) && random_num(1, get_pcvar_num(cvar_survchance)) == get_pcvar_num(cvar_surv) && iPlayersnum >= get_pcvar_num(cvar_survminplayers)) || mode == MODE_SURVIVOR)
	{
		// Survivor Mode
		g_survround = true
		g_lastmode = MODE_SURVIVOR
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		// Turn player into a survivor
		humanme(id, 1, 0)
		
		// Turn the remaining players into zombies
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Survivor or already a zombie
			if (g_survivor[id] || g_zombie[id])
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		// Play survivor sound
		ArrayGetString(sound_survivor, random_num(0, ArraySize(sound_survivor) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Survivor HUD notice
		set_hudmessage(255, 255, 255, -1.0, 0.22, 1, 2.0, 6.0, 2.0)
		show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_SURVIVOR", g_playername[forward_id])
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SURVIVOR, forward_id);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_SWARM) && random_num(1, get_pcvar_num(cvar_swarmchance)) == get_pcvar_num(cvar_swarm) && iPlayersnum >= get_pcvar_num(cvar_swarmminplayers)) || mode == MODE_SWARM)
	{		
		// Swarm Mode
		g_swarmround = true
		g_lastmode = MODE_SWARM
		
		// Make sure there are alive players on both teams (BUGFIX)
		if (!fnGetAliveTs())
		{
			// Move random player to T team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			fm_user_team_update(id)
		}
		else if (!fnGetAliveCTs())
		{
			// Move random player to CT team
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
		
		// Turn every T into a zombie
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// Not a Terrorist
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_T)
				continue;
			
			// Turn into a zombie
			zombieme(id, 0, 0, 1, 0)
		}
		
		// Play swarm sound
		ArrayGetString(sound_swarm, random_num(0, ArraySize(sound_swarm) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Swarm HUD notice
		set_dhudmessage(255, 255, 255, -1.0, 0.22, 1, 2.0, 3.0, 2.0)
		show_dhudmessage(0, "%L", LANG_PLAYER, "NOTICE_SWARM")

		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_SWARM, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_MULTI) && random_num(1, get_pcvar_num(cvar_multichance)) == get_pcvar_num(cvar_multi) && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) >= 2 && floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil) < iPlayersnum && iPlayersnum >= get_pcvar_num(cvar_multiminplayers)) || mode == MODE_MULTI)
	{
		// Multi Infection Mode
		g_lastmode = MODE_MULTI
		g_multiround = true;
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum*get_pcvar_float(cvar_multiratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 0, 1, 0)
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who aren't zombies
			if (!g_isalive[id] || g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		// Play multi infection sound
		ArrayGetString(sound_multi, random_num(0, ArraySize(sound_multi) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Multi Infection HUD notice
		set_hudmessage(255, 127, 0, -1.0, 0.22, 2, 6.0, 1.0 );
		show_hudmessage(0, "%L", LANG_PLAYER, "NOTICE_MULTI")
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_MULTI, 0);
	}
	else if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_PLAGUE) && random_num(1, get_pcvar_num(cvar_plaguechance)) == get_pcvar_num(cvar_plague) && floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) >= 1
	&& iPlayersnum-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) >= 1 && iPlayersnum >= get_pcvar_num(cvar_plagueminplayers)) || mode == MODE_PLAGUE)
	{
		// Plague Mode
		g_plagueround = true
		g_lastmode = MODE_PLAGUE
		
		// Turn specified amount of players into Survivors
		static iSurvivors, iMaxSurvivors
		iMaxSurvivors = get_pcvar_num(cvar_plaguesurvnum)
		iSurvivors = 0
		
		while (iSurvivors < iMaxSurvivors)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor?
			if (g_survivor[id])
				continue;
			
			// If not, turn him into one
			humanme(id, 1, 0)
			iSurvivors++
			
			// Apply survivor health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguesurvhpmulti)))
		}
		
		// Turn specified amount of players into Nemesis
		static iNemesis, iMaxNemesis
		iMaxNemesis = get_pcvar_num(cvar_plaguenemnum)
		iNemesis = 0
		
		while (iNemesis < iMaxNemesis)
		{
			// Choose random guy
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
			
			// Already a survivor or nemesis?
			if (g_survivor[id] || g_nemesis[id])
				continue;
			
			// If not, turn him into one
			zombieme(id, 0, 1, 0, 0)
			iNemesis++
			
			// Apply nemesis health multiplier
			fm_set_user_health(id, floatround(float(pev(id, pev_health)) * get_pcvar_float(cvar_plaguenemhpmulti)))
		}
		
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround((iPlayersnum-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++id > g_maxplayers) id = 1
			
			// Dead or already a zombie or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				zombieme(id, 0, 1, 0, 0) // 0,0,1,0
				iZombies++
			}
		}
		
		// Turn the remaining players into humans
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Only those of them who arent zombies or survivor
			if (!g_isalive[id] || g_zombie[id] || g_survivor[id])
				continue;
				
			humanme(id, 1, 0);
			// Switch to CT
			/*if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				humanme(id, 1, 0)
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}*/
		}
		
		// Play plague sound
		ArrayGetString(sound_plague, random_num(0, ArraySize(sound_plague) - 1), sound, charsmax(sound))
		PlaySound(sound);
		
		// Show Plague HUD notice
		set_hudmessage(125, 31, 122, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_PLAGUE")
		
		// Mode fully started!
		g_modestarted = true
		
		// Round start forward
		ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_PLAGUE, 0);
	}
	else
	{
		// Single Infection Mode or Nemesis Mode
		
		// Choose player randomly?
		if (mode == MODE_NONE)
			id = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		// Remember id for calling our forward later
		forward_id = id
		
		if ((mode == MODE_NONE && (!get_pcvar_num(cvar_preventconsecutive) || g_lastmode != MODE_NEMESIS) && random_num(1, get_pcvar_num(cvar_nemchance)) == get_pcvar_num(cvar_nem) && iPlayersnum >= get_pcvar_num(cvar_nemminplayers)) || mode == MODE_NEMESIS)
		{
			// Nemesis Mode
			g_nemround = true
			g_lastmode = MODE_NEMESIS
			
			// Turn player into nemesis
			zombieme(id, 0, 1, 0, 0)
		}
		else
		{
			// Single Infection Mode
			g_lastmode = MODE_INFECTION
			
			// Turn player into the first zombie
			zombieme(id, 0, 0, 0, 0)
		}
		
		// Remaining players should be humans (CTs)
		for (id = 1; id <= g_maxplayers; id++)
		{
			// Not alive
			if (!g_isalive[id])
				continue;
			
			// First zombie/nemesis
			if (g_zombie[id])
				continue;
			
			// Switch to CT
			if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				fm_user_team_update(id)
			}
		}
		
		if (g_nemround)
		{
			// Play Nemesis sound
			ArrayGetString(sound_nemesis, random_num(0, ArraySize(sound_nemesis) - 1), sound, charsmax(sound))
			PlaySound(sound);
			
			// Show Nemesis HUD notice
			set_hudmessage(255, 20, 20, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_NEMESIS", g_playername[forward_id])
			
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_NEMESIS, forward_id);
		}
		else
		{
			//Play 
			ArrayGetString(sound_firstzombie, random_num(0, ArraySize(sound_firstzombie) - 1), sound, charsmax(sound))
			PlaySound(sound);
			
			// Show First Zombie HUD notice	
			//set_hudmessage(255, 127, 0, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1)
			set_hudmessage(255, 127, 0, -1.0, 0.22, 0, 0.0, 5.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync, "%L",LANG_PLAYER, "NOTICE_FIRST", g_playername[forward_id])
			
			// Mode fully started!
			g_modestarted = true
			
			// Round start forward
			ExecuteForward(g_fwRoundStart, g_fwDummyResult, MODE_INFECTION, forward_id);
		}
	}
	
	// Start ambience sounds after a mode begins
	if ((g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && g_nemround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && g_survround) || (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && g_swarmround) || (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && g_plagueround) || (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && !g_nemround && !g_survround && !g_swarmround && !g_plagueround))
	{
		remove_task(TASK_AMBIENCESOUNDS)
		set_task(2.0, "ambience_sound_effects", TASK_AMBIENCESOUNDS)
	}
}

// Zombie Me Function (player id, infector, turn into a nemesis, silent mode, deathmsg and rewards)
zombieme(id, infector, nemesis, silentmode, rewards)
{
	// User infect attempt forward
	ExecuteForward(g_fwUserInfect_attempt, g_fwDummyResult, id, infector, nemesis)
	
	//.
	zbrane[id] = 1
	
	// One or more plugins blocked the infection. Only allow this after making sure it's
	// not going to leave us with no zombies. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first zombie e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetZombies() > g_lastplayerleaving)
		return;
	
	// Pre user infect forward
	ExecuteForward(g_fwUserInfected_pre, g_fwDummyResult, id, infector, nemesis)
	
	// Show zombie class menu if they haven't chosen any (e.g. just connected)
	if (g_zombieclassnext[id] == ZCLASS_NONE && get_pcvar_num(cvar_zclasses))
		set_task(0.2, "show_menu_zclass", id)
	
	// Set selected zombie class
	g_zombieclass[id] = g_zombieclassnext[id]
	// If no class selected yet, use the first (default) one
	if (g_zombieclass[id] == ZCLASS_NONE) g_zombieclass[id] = 0
	
	// Way to go...
	g_zombie[id] = true
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	
	// Remove survivor's aura (bugfix)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	/*
	// Show deathmsg and reward infector?
	if (rewards && infector)
	{
		if( Logined[ infector ] ) 
		{
			new expcka = 0;
			new text[ 555 char ];
			// Send death notice and fix the "dead" attrib on scoreboard
			SendDeathMsg(infector, id)
			FixDeadAttrib(id)
			
			formatex( text, charsmax( text ), "%L", infector, "INFECT_HUMAN" );
			set_dhudmessage( 255, 42, 42, -1.0, 0.35, 0, 1.0, 1.0 ); // 0, 6.0, 1.1, 0.0, 0.0, -1 ShowSyncHudMsg(id, g_SyncHud_Kill, KillText)
			show_dhudmessage( infector, text );
			// Reward frags, deaths, health, and ammo packs
			UpdateFrags(infector, id, get_pcvar_num(cvar_fragsinfect), 1, 1)
			g_ammopacks[infector] += get_pcvar_num(cvar_ammoinfect)
			body[infector] += 1
			if( g_event == 1 )
			{
				if( get_user_flags( infector ) & ADMIN_LEVEL_F ) {
					expcka += 20;
				} else {
					expcka += 10;
				}
			}
			new hp_bonus = g_unHPLevel[ infector ] * 2;
			new hp_zombie = ArrayGetCell( g_zclass_hp, g_zombieclass[ infector ] )
			new get_bonus = hp_zombie * hp_bonus / 100;
			
			switch( random( 14 ) ) {
				case 1: {
					ChatColor( infector, "%L", LANG_PLAYER, "GET_FULL_HP" );
					fm_set_user_health( infector, ArrayGetCell( g_zclass_hp, g_zombieclass[ infector ] ) + get_bonus );
				}
			}
			if( g_weekend_event == 1 ) {
				if( is_user_bot( id ) ) {
					ChatColor( infector, "%L", LANG_PLAYER, "EXP_CASE_HUMAN_NO" );
				} else {
					ChatColor( infector, "%L", LANG_PLAYER, "EXP_CASE_HUMAN" );
					exp_case[ infector ]++;
				}
			}
			if( g_multiround )
			{
				expcka += 30;
			}
			expcka += 10;
			human_rip[infector] += 1
			speeda[id] = false
			gravita[id] = false
			fm_set_user_health(infector, pev(infector, pev_health) + get_pcvar_num(cvar_zombiebonushp))
			if( human_rip[infector] == 2 && !g_firstzombie[infector] )
			{
				case_of_items( infector )
				human_rip[infector] = 0;
				
				
			}
			exp[ infector ] += expcka;
			ChatColor( infector, "%L", LANG_PLAYER, "EXP_BONUS" );
			SQL_UpdateUser( infector );
		}
	}*/
	// Show deathmsg and reward infector?
	if (rewards && infector)
	{
		if( Logined[ infector ] ) 
		{
			// Send death notice and fix the "dead" attrib on scoreboard
			SendDeathMsg(infector, id)
			FixDeadAttrib(id)
			new text[ 555 char ];
			new expcka = 0;
			formatex( text, charsmax( text ), "%L", infector, "INFECT_HUMAN" );
			set_dhudmessage( 255, 42, 42, -1.0, 0.35, 0, 1.0, 1.0 ); // 0, 6.0, 1.1, 0.0, 0.0, -1 ShowSyncHudMsg(id, g_SyncHud_Kill, KillText)
			show_dhudmessage( infector, text );
			// Reward frags, deaths, health, and ammo packs
			UpdateFrags(infector, id, get_pcvar_num(cvar_fragsinfect), 1, 1)
			g_ammopacks[infector] += get_pcvar_num(cvar_ammoinfect)
			body[infector] += 1
			if( g_event == 1 )
			{
				if( get_user_flags( infector ) & ADMIN_LEVEL_F ) {
					exp[ infector ] += 30; 
					ChatColor( infector, "!g[BONUS]!y Ziskal si !t+30 EXP" );
				} else {
					exp[ infector ] += 20;
					ChatColor( infector, "!g[BONUS]!y Ziskal si !t+20 EXP" );
				}
			}
			new hp_bonus = g_unHPLevel[ infector ] * 2;
			new hp_zombie = ArrayGetCell( g_zclass_hp, g_zombieclass[ infector ] )
			new get_bonus = hp_zombie * hp_bonus / 100;
			
			switch( random( 14 ) ) {
				case 1: {
					fm_set_user_health( infector, ArrayGetCell( g_zclass_hp, g_zombieclass[ infector ] ) + get_bonus );
					ChatColor( infector, "!g[ZP]!y Bol si oziveny o svoje zivoty!" );
				}
			}
			if( g_weekend_event == 1 ) {
				if( is_user_bot( id ) ) {
					ChatColor( infector, "!g[Herny Inventar]!y Musis zabit normalneho hraca aby si ziskal truhlu!" );
				} else {
					ChatColor( infector, "!g[Herny Inventar]!y Ziskal si !tEXP Case!y. Mas ju ulozenu v inventary!" );
					exp_case[ infector ]++;
				}
			}
			if( g_multiround )
			{
				exp[ infector ] += 30;
				ChatColor( infector, "!t[Viacnasobna Infekcia]!g Ziskal si !y30 EXP!g!" );
			}
			exp[ infector] += 10;
			human_rip[infector] += 1
			speeda[id] = false
			gravita[id] = false
			fm_set_user_health(infector, pev(infector, pev_health) + get_pcvar_num(cvar_zombiebonushp))
			if( human_rip[infector] == 2 && !g_firstzombie[infector] )
			{
				case_of_items( infector )
				human_rip[infector] = 0;
				
				
			}
			SQL_UpdateUser( infector );
		}
	}
	
	// Cache speed, knockback, and name for player's class
	g_zombie_spd[id] = float(ArrayGetCell(g_zclass_spd, g_zombieclass[id]))
	g_zombie_knockback[id] = Float:ArrayGetCell(g_zclass_kb, g_zombieclass[id])
	ArrayGetString(g_zclass_name, g_zombieclass[id], g_zombie_classname[id], charsmax(g_zombie_classname[]))
	
	// Set zombie attributes based on the mode
	static sound[64]
	if (!silentmode)
	{
		if (nemesis)
		{
			// Nemesis
			g_nemesis[id] = true
			Rychly[id] = 0
			Gravity[id] = 0
			
			// Set health [0 = auto]
			if (get_pcvar_num(cvar_nemhp) == 0)
			{
				if (get_pcvar_num(cvar_nembasehp) == 0)
					fm_set_user_health(id, ArrayGetCell(g_zclass_hp, 0) * fnGetAlive())
				else
					fm_set_user_health(id, get_pcvar_num(cvar_nembasehp) * fnGetAlive())
			}
			else
				fm_set_user_health(id, get_pcvar_num(cvar_nemhp))
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_nemgravity))
			else g_frozen_gravity[id] = get_pcvar_float(cvar_nemgravity)
			
			// Set nemesis maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		}
		else if (fnGetZombies() == 1)
		{
			// First zombie
			g_firstzombie[id] = true
			Rychly[id] = 0
			Gravity[id] = 0
			fm_set_user_health(id, floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * 2.0 + g_unHPLevel[ id ] * 2))
			// Set health
			//fm_set_user_health(id, floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * get_pcvar_float(cvar_zombiefirsthp) + g_unHPLevel[ id ] * 2))
			set_pdata_float(id, fPainShock, 1.0, 5)
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			// Infection sound
			ArrayGetString(zombie_infect, random_num(0, ArraySize(zombie_infect) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		else
		{
			new hp_bonus = g_unHPLevel[ id ] * 2;
			new hp_zombie = ArrayGetCell(g_zclass_hp, g_zombieclass[id])
			new get_bonus = hp_zombie * hp_bonus / 100;
			// Silent mode, no HUD messages, no infection sounds
			
			// Set health
			fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]) + get_bonus)
			
			// Set gravity, if frozen set the restore gravity value instead
			if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
			else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
			
			// Set zombie maxspeed
			ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
			
			Rychly[id] = 0
			Gravity[id] = 0
			
			// Infection sound
			ArrayGetString(zombie_infect, random_num(0, ArraySize(zombie_infect) - 1), sound, charsmax(sound))
			emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			// Show Infection HUD notice
			//set_hudmessage(255, 0, 0, HUD_INFECT_X, HUD_INFECT_Y, 0, 0.0, 5.0, 1.0, 1.0, -1)
			
			/*if (infector) // infected by someone?
				ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_INFECT2", g_playername[id], g_playername[infector])
			else
				ShowSyncHudMsg(0, g_MsgSync, "%L", LANG_PLAYER, "NOTICE_INFECT", g_playername[id])*/
		}
	}
	else
	{
		new hp_bonus = g_unHPLevel[ id ] * 2;
		new hp_zombie = ArrayGetCell(g_zclass_hp, g_zombieclass[id])
		new get_bonus = hp_zombie * hp_bonus / 100;
		// Silent mode, no HUD messages, no infection sounds
		
		// Set health
		fm_set_user_health(id, ArrayGetCell(g_zclass_hp, g_zombieclass[id]) + get_bonus)
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id]))
		else g_frozen_gravity[id] = Float:ArrayGetCell(g_zclass_grav, g_zombieclass[id])
		
		// Set zombie maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	}
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	
	// Switch to T
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_T) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_nemesis[id])
		{
			iRand = random_num(0, ArraySize(model_nemesis) - 1)
			ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
		}
		else
		{
			if (get_pcvar_num(cvar_adminmodelszombie) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				iRand = random_num(0, ArraySize(model_admin_zombie) - 1)
				ArrayGetString(model_admin_zombie, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_zombie, iRand))
			}
			else
			{
				iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
				ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
			}
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		// Nemesis glow / remove glow on player model entity, unless frozen
		if (!g_frozen[id])
		{
			if (g_nemesis[id] && get_pcvar_num(cvar_nemglow))
				fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 65, 65, 165, kRenderNormal, 10)
			else
				fm_set_rendering(g_ent_playermodel[id])
		}
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_nemesis[id])
		{
			size = ArraySize(model_nemesis)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_nemesis, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_nemesis, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_nemesis, iRand))
			}
		}
		else
		{
			if (get_pcvar_num(cvar_adminmodelszombie) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				size = ArraySize(model_admin_zombie)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_admin_zombie, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_admin_zombie, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_zombie, iRand))
				}
			}
			else
			{
				for (i = ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]); i < ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]); i++)
				{
					ArrayGetString(g_zclass_playermodel, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(ArrayGetCell(g_zclass_modelsstart, g_zombieclass[id]), ArrayGetCell(g_zclass_modelsend, g_zombieclass[id]) - 1)
					ArrayGetString(g_zclass_playermodel, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_zclass_modelindex, iRand))
				}
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Nemesis glow / remove glow, unless frozen
		if (!g_frozen[id])
		{
			if (g_nemesis[id] && get_pcvar_num(cvar_nemglow))
				fm_set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
			else
				fm_set_rendering(id)
		}
	}
	
	// Remove any zoom (bugfix)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
	
	// Remove armor
	cs_set_user_armor(id, 0, CS_ARMOR_NONE)
	
	// Drop weapons when infected
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip zombies from guns and give them a knife
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Fancy effects
	infection_effects(id)
	
	// Nemesis aura task
	if (g_nemesis[id] && get_pcvar_num(cvar_nemaura))
		set_task(0.1, "zombie_aura", id+TASK_AURA, _, _, "b")
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(id))
	{
		cs_set_user_nvg(id, 0)
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
	}
	
	// Give Zombies Night Vision?
	if (get_pcvar_num(cvar_nvggive))
	{
		g_nvision[id] = true
		
		if (!g_isbot[id])
		{
			// Turn on Night Vision automatically?
			if (get_pcvar_num(cvar_nvggive) == 1)
			{
				g_nvisionenabled[id] = true
				
				// Custom nvg?
				if (get_pcvar_num(cvar_customnvg))
				{
					remove_task(id+TASK_NVISION)
					set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
				}
				else
					set_user_gnvision(id, 1)
			}
			// Turn off nightvision when infected (bugfix)
			else if (g_nvisionenabled[id])
			{
				if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
				else set_user_gnvision(id, 0)
				g_nvisionenabled[id] = false
			}
		}
		else
			cs_set_user_nvg(id, 1); // turn on NVG for bots
	}
	// Disable nightvision when infected (bugfix)
	else if (g_nvision[id])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
	
	// Set custom FOV?
	if (get_pcvar_num(cvar_zombiefov) != 90 && get_pcvar_num(cvar_zombiefov) != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(get_pcvar_num(cvar_zombiefov)) // fov angle
		message_end()
	}
	
	// Call the bloody task
	if (!g_nemesis[id] && get_pcvar_num(cvar_zombiebleeding))
		set_task(0.7, "make_blood", id+TASK_BLOOD, _, _, "b")
	
	// Idle sounds task
	if (!g_nemesis[id])
		set_task( 20.0, "zombie_play_idle", id+TASK_BLOOD, _, _, "b")
	
	// Turn off zombie's flashlight
	turn_off_flashlight(id)
	
	// Post user infect forward
	ExecuteForward(g_fwUserInfected_post, g_fwDummyResult, id, infector, nemesis)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

// Function Human Me (player id, turn into a survivor, silent mode)
humanme(id, survivor, silentmode)
{
	// User humanize attempt forward
	ExecuteForward(g_fwUserHumanize_attempt, g_fwDummyResult, id, survivor)
	
	// One or more plugins blocked the "humanization". Only allow this after making sure it's
	// not going to leave us with no humans. Take into account a last player leaving case.
	// BUGFIX: only allow after a mode has started, to prevent blocking first survivor e.g.
	if (g_fwDummyResult >= ZP_PLUGIN_HANDLED && g_modestarted && fnGetHumans() > g_lastplayerleaving)
		return;
	
	// Pre user humanize forward
	ExecuteForward(g_fwUserHumanized_pre, g_fwDummyResult, id, survivor)
	
	//Idle Human
	if (!g_survivor[id])
		set_task( 15.0, "human_play_idle", id+TASK_BLOOD, _, _, "b")
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	remove_task(id+TASK_BLOOD)
	remove_task(id+TASK_AURA)
	remove_task(id+TASK_BURN)
	remove_task(id+TASK_NVISION)
	
	// Reset some vars
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_canbuy[id] = true
	g_buytime[id] = get_gametime()
	
	// Remove survivor's aura (bugfix)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	
	// Remove spawn protection (bugfix)
	g_nodamage[id] = false
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	
	// Reset burning duration counter (bugfix)
	g_burning_duration[id] = 0
	
	// Remove CS nightvision if player owns one (bugfix)
	if (cs_get_user_nvg(id))
	{
		cs_set_user_nvg(id, 0)
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
	}
	
	// Drop previous weapons
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	
	// Strip off from weapons
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	
	// Set human attributes based on the mode
	if (survivor)
	{
		// Survivor
		g_survivor[id] = true
		set_user_rendering( id, kRenderFxGlowShell, 0, 0, 200, kRenderNormal, 15 );
		
		// Set Health [0 = auto]
		if (get_pcvar_num(cvar_survhp) == 0)
		{
			if (get_pcvar_num(cvar_survbasehp) == 0)
				fm_set_user_health(id, get_pcvar_num(cvar_humanhp) * fnGetAlive())
			else
				fm_set_user_health(id, get_pcvar_num(cvar_survbasehp) * fnGetAlive())
		}
		else
			fm_set_user_health(id, get_pcvar_num(cvar_survhp))
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_survgravity))
		else g_frozen_gravity[id] = get_pcvar_float(cvar_survgravity)
		
		// Set survivor maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		
		// Give survivor his own weapon
		static survweapon[32]
		get_pcvar_string(cvar_survweapon, survweapon, charsmax(survweapon))
		fm_give_item(id, survweapon)
		ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[cs_weapon_name_to_id(survweapon)], AMMOTYPE[cs_weapon_name_to_id(survweapon)], MAXBPAMMO[cs_weapon_name_to_id(survweapon)])
		
		// Turn off his flashlight
		turn_off_flashlight(id)
		
		// Give the survivor a bright light
		if (get_pcvar_num(cvar_survaura)) set_pev(id, pev_effects, pev(id, pev_effects) | EF_BRIGHTLIGHT)
		
		// Survivor bots will also need nightvision to see in the dark
		if (g_isbot[id])
		{
			g_nvision[id] = true
			cs_set_user_nvg(id, 1)
		}
	}
	else
	{
		// Human taking an antidote
		zbrane[id] = 0
		// Set health
		fm_set_user_health(id, get_pcvar_num(cvar_humanhp))
		
		// Set gravity, if frozen set the restore gravity value instead
		if (!g_frozen[id]) set_pev(id, pev_gravity, get_pcvar_float(cvar_humangravity))
		else g_frozen_gravity[id] = get_pcvar_float(cvar_humangravity)
		
		// Set human maxspeed
		ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
		

		
		// Silent mode = no HUD messages, no antidote sound
		if (!silentmode)
		{
			// Antidote sound
			client_cmd( id, "stopsound" );
			static sound[64]
			ArrayGetString(sound_antidote, random_num(0, ArraySize(sound_antidote) - 1), sound, charsmax(sound))
			PlaySound(sound);
			
			// Show Antidote HUD notice
			set_hudmessage(42, 42, 225, HUD_INFECT_X, HUD_INFECT_Y, 0, 0.0, 3.0, 1.0, 1.0, -1)
			ShowSyncHudMsg(0, g_MsgSync4, "%L", LANG_PLAYER, "NOTICE_ANTIDOTE", g_playername[id])
		}
	}
	
	// Switch to CT
	if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
	{
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		fm_user_team_update(id)
	}
	
	// Custom models stuff
	static currentmodel[32], tempmodel[32], already_has_model, i, iRand, size
	already_has_model = false
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		if (g_survivor[id])
		{
			iRand = random_num(0, ArraySize(model_survivor) - 1)
			ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
			if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
		}
		else
		{
			if (get_pcvar_num(cvar_adminmodelshuman) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				iRand = random_num(0, ArraySize(model_admin_human) - 1)
				ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
			}
			else
			{
				iRand = random_num(0, ArraySize(model_human) - 1)
				ArrayGetString(model_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_human, iRand))
			}
		}
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
		
		if (g_survivor[id])
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (g_survivor[id])
		{
			size = ArraySize(model_survivor)
			for (i = 0; i < size; i++)
			{
				ArrayGetString(model_survivor, i, tempmodel, charsmax(tempmodel))
				if (equal(currentmodel, tempmodel)) already_has_model = true
			}
			
			if (!already_has_model)
			{
				iRand = random_num(0, size - 1)
				ArrayGetString(model_survivor, iRand, g_playermodel[id], charsmax(g_playermodel[]))
				if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_survivor, iRand))
			}
		}
		else
		{
			if (get_pcvar_num(cvar_adminmodelshuman) && (get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS]))
			{
				size = ArraySize(model_admin_human)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_admin_human, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_admin_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_admin_human, iRand))
				}
			}
			else
			{
				size = ArraySize(model_human)
				for (i = 0; i < size; i++)
				{
					ArrayGetString(model_human, i, tempmodel, charsmax(tempmodel))
					if (equal(currentmodel, tempmodel)) already_has_model = true
				}
				
				if (!already_has_model)
				{
					iRand = random_num(0, size - 1)
					ArrayGetString(model_human, iRand, g_playermodel[id], charsmax(g_playermodel[]))
					if (g_set_modelindex_offset) fm_cs_set_user_model_index(id, ArrayGetCell(g_modelindex_human, iRand))
				}
			}
		}
		
		// Need to change the model?
		if (!already_has_model)
		{
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
		
		// Set survivor glow / remove glow, unless frozen
		if (g_survivor[id])
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)

	}
	
	// Restore FOV?
	if (get_pcvar_num(cvar_zombiefov) != 90 && get_pcvar_num(cvar_zombiefov) != 0)
	{
		message_begin(MSG_ONE, g_msgSetFOV, _, id)
		write_byte(90) // angle
		message_end()
	}
	
	// Disable nightvision when turning into human/survivor (bugfix)
	if (g_nvision[id])
	{
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
	
	// Post user humanize forward
	ExecuteForward(g_fwUserHumanized_post, g_fwDummyResult, id, survivor)
	
	// Last Zombie Check
	fnCheckLastZombie()
}

/*================================================================================
 [Other Functions and Tasks]
=================================================================================*/

public cache_cvars()
{
	g_cached_customflash = get_pcvar_num(cvar_customflash)
	g_cached_leapzombies = get_pcvar_num(cvar_leapzombies)
	g_cached_leapzombiescooldown = get_pcvar_float(cvar_leapzombiescooldown)
	g_cached_leapnemesis = get_pcvar_num(cvar_leapnemesis)
	g_cached_leapnemesiscooldown = get_pcvar_float(cvar_leapnemesiscooldown)
	g_cached_leapsurvivor = get_pcvar_num(cvar_leapsurvivor)
	g_cached_leapsurvivorcooldown = get_pcvar_float(cvar_leapsurvivorcooldown)
}

load_customization_from_files()
{
	// Build customization file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_CUSTOMIZATION_FILE)
	
	// File not present
	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}
	
	// Set up some vars to hold parsing info
	new linedata[1024], key[64], value[960], section, teams
	
	// Open customization file for reading
	new file = fopen(path, "rt")
	
	while (file && !feof(file))
	{
		// Read one line at a time
		fgets(file, linedata, charsmax(linedata))
		
		// Replace newlines with a null character to prevent headaches
		replace(linedata, charsmax(linedata), "^n", "")
		
		// Blank line or comment
		if (!linedata[0] || linedata[0] == ';') continue;
		
		// New section starting
		if (linedata[0] == '[')
		{
			section++
			continue;
		}
		
		// Get key and value(s)
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
		
		// Trim spaces
		trim(key)
		trim(value)
		
		switch (section)
		{
			case SECTION_ACCESS_FLAGS:
			{
				if (equal(key, "ENABLE/DISABLE MOD"))
					g_access_flag[ACCESS_ENABLE_MOD] = read_flags(value)
				else if (equal(key, "ADMIN MENU"))
					g_access_flag[ACCESS_ADMIN_MENU] = read_flags(value)
				else if (equal(key, "START MODE INFECTION"))
					g_access_flag[ACCESS_MODE_INFECTION] = read_flags(value)
				else if (equal(key, "START MODE NEMESIS"))
					g_access_flag[ACCESS_MODE_NEMESIS] = read_flags(value)
				else if (equal(key, "START MODE SURVIVOR"))
					g_access_flag[ACCESS_MODE_SURVIVOR] = read_flags(value)
				else if (equal(key, "START MODE SWARM"))
					g_access_flag[ACCESS_MODE_SWARM] = read_flags(value)
				else if (equal(key, "START MODE MULTI"))
					g_access_flag[ACCESS_MODE_MULTI] = read_flags(value)
				else if (equal(key, "START MODE PLAGUE"))
					g_access_flag[ACCESS_MODE_PLAGUE] = read_flags(value)
				else if (equal(key, "MAKE ZOMBIE"))
					g_access_flag[ACCESS_MAKE_ZOMBIE] = read_flags(value)
				else if (equal(key, "MAKE HUMAN"))
					g_access_flag[ACCESS_MAKE_HUMAN] = read_flags(value)
				else if (equal(key, "MAKE NEMESIS"))
					g_access_flag[ACCESS_MAKE_NEMESIS] = read_flags(value)
				else if (equal(key, "MAKE SURVIVOR"))
					g_access_flag[ACCESS_MAKE_SURVIVOR] = read_flags(value)
				else if (equal(key, "RESPAWN PLAYERS"))
					g_access_flag[ACCESS_RESPAWN_PLAYERS] = read_flags(value)
				else if (equal(key, "ADMIN MODELS"))
					g_access_flag[ACCESS_ADMIN_MODELS] = read_flags(value)
			}
			case SECTION_PLAYER_MODELS:
			{
				if (equal(key, "HUMAN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_human, key)
					}
				}
				else if (equal(key, "NEMESIS"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_nemesis, key)
					}
				}
				else if (equal(key, "SURVIVOR"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_survivor, key)
					}
				}
				else if (equal(key, "ADMIN ZOMBIE"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_admin_zombie, key)
					}
				}
				else if (equal(key, "ADMIN HUMAN"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(model_admin_human, key)
					}
				}
				else if (equal(key, "FORCE CONSISTENCY"))
					g_force_consistency = str_to_num(value)
				else if (equal(key, "SAME MODELS FOR ALL"))
					g_same_models_for_all = str_to_num(value)
				else if (g_same_models_for_all && equal(key, "ZOMBIE"))
				{
					// Parse models
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to models array
						ArrayPushString(g_zclass_playermodel, key)
						
						// Precache model and retrieve its modelindex
						formatex(linedata, charsmax(linedata), "models/player/%s/%s.mdl", key, key)
						ArrayPushCell(g_zclass_modelindex, engfunc(EngFunc_PrecacheModel, linedata))
						if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, linedata)
						if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, linedata)
						// Precache modelT.mdl files too
						copy(linedata[strlen(linedata)-4], charsmax(linedata) - (strlen(linedata)-4), "T.mdl")
						if (file_exists(linedata)) engfunc(EngFunc_PrecacheModel, linedata)
					}
				}
			}
			case SECTION_WEAPON_MODELS:
			{
				if (equal(key, "V_KNIFE HUMAN"))
					copy(model_vknife_human, charsmax(model_vknife_human), value)
				else if (equal(key, "V_KNIFE NEMESIS"))
					copy(model_vknife_nemesis, charsmax(model_vknife_nemesis), value)
				else if (equal(key, "V_M249 SURVIVOR")) // backwards compatibility with old configs
					copy(model_vweapon_survivor, charsmax(model_vweapon_survivor), value)
				else if (equal(key, "V_WEAPON SURVIVOR"))
					copy(model_vweapon_survivor, charsmax(model_vweapon_survivor), value)
				else if (equal(key, "GRENADE INFECT"))
					copy(model_grenade_infect, charsmax(model_grenade_infect), value)
				else if (equal(key, "GRENADE FIRE"))
					copy(model_grenade_fire, charsmax(model_grenade_fire), value)
				else if (equal(key, "GRENADE FROST"))
					copy(model_grenade_frost, charsmax(model_grenade_frost), value)
				else if (equal(key, "GRENADE FLARE"))
					copy(model_grenade_flare, charsmax(model_grenade_flare), value)
				else if (equal(key, "V_KNIFE ADMIN HUMAN"))
					copy(model_vknife_admin_human, charsmax(model_vknife_admin_human), value)
				else if (equal(key, "V_KNIFE ADMIN ZOMBIE"))
					copy(model_vknife_admin_zombie, charsmax(model_vknife_admin_zombie), value)
			}
			case SECTION_GRENADE_SPRITES:
			{
				if (equal(key, "TRAIL"))
					copy(sprite_grenade_trail, charsmax(sprite_grenade_trail), value)
				else if (equal(key, "RING"))
					copy(sprite_grenade_ring, charsmax(sprite_grenade_ring), value)
				else if (equal(key, "FIRE"))
					copy(sprite_grenade_fire, charsmax(sprite_grenade_fire), value)
				else if (equal(key, "SMOKE"))
					copy(sprite_grenade_smoke, charsmax(sprite_grenade_smoke), value)
				else if (equal(key, "GLASS"))
					copy(sprite_grenade_glass, charsmax(sprite_grenade_glass), value)
			}
			case SECTION_SOUNDS:
			{
				if (equal(key, "WIN ZOMBIES"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_zombies, key)
						ArrayPushCell(sound_win_zombies_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "WIN HUMANS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_humans, key)
						ArrayPushCell(sound_win_humans_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "WIN NO ONE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_win_no_one, key)
						ArrayPushCell(sound_win_no_one_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (equal(key, "ZOMBIE INFECT"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_infect, key)
					}
				}
				else if (equal(key, "ZOMBIE PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_pain, key)
					}
				}
				else if (equal(key, "NEMESIS PAIN"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(nemesis_pain, key)
					}
				}
				else if (equal(key, "ZOMBIE DIE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_die, key)
					}
				}
				else if (equal(key, "ZOMBIE FALL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_fall, key)
					}
				}
				else if (equal(key, "ZOMBIE MISS SLASH"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_miss_slash, key)
					}
				}
				else if (equal(key, "ZOMBIE MISS WALL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_miss_wall, key)
					}
				}
				else if (equal(key, "ZOMBIE HIT NORMAL"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_hit_normal, key)
					}
				}
				else if (equal(key, "ZOMBIE HIT STAB"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_hit_stab, key)
					}
				}
				else if (equal(key, "ZOMBIE IDLE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_idle, key)
					}
				}
				else if (equal(key, "ZOMBIE IDLE LAST"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_idle_last, key)
					}
				}
				else if (equal(key, "ZOMBIE MADNESS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(zombie_madness, key)
					}
				}
				else if (equal(key, "ROUND NEMESIS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_nemesis, key)
					}
				}
				else if (equal(key, "ROUND SURVIVOR"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_survivor, key)
					}
				}
				else if (equal(key, "ROUND SWARM"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_swarm, key)
					}
				}
				else if (equal(key, "ROUND MULTI"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_multi, key)
					}
				}
				else if (equal(key, "ROUND PLAGUE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_plague, key)
					}
				}
				else if (equal(key, "GRENADE INFECT EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_infect, key)
					}
				}
				else if (equal(key, "GRENADE INFECT PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_infect_player, key)
					}
				}
				else if (equal(key, "GRENADE FIRE EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire, key)
					}
				}
				else if (equal(key, "GRENADE FIRE PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_fire_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST EXPLODE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost, key)
					}
				}
				else if (equal(key, "GRENADE FROST PLAYER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_player, key)
					}
				}
				else if (equal(key, "GRENADE FROST BREAK"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_frost_break, key)
					}
				}
				else if (equal(key, "GRENADE FLARE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(grenade_flare, key)
					}
				}
				else if (equal(key, "ANTIDOTE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_antidote, key)
					}
				}
				else if (equal(key, "FIRSTZOMBIE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_firstzombie, key)
					}
				}
				else if (equal(key, "HUMAN IDLE"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(human_idle, key)
					}
				}
				else if (equal(key, "THUNDER"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_thunder, key)
					}
				}
			}
			case SECTION_AMBIENCE_SOUNDS:
			{
				if (equal(key, "INFECTION ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience1, key)
						ArrayPushCell(sound_ambience1_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_INFECTION] && equal(key, "INFECTION DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience1_duration, str_to_num(key))
					}
				}
				else if (equal(key, "NEMESIS ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience2, key)
						ArrayPushCell(sound_ambience2_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_NEMESIS] && equal(key, "NEMESIS DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience2_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SURVIVOR ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience3, key)
						ArrayPushCell(sound_ambience3_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SURVIVOR] && equal(key, "SURVIVOR DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience3_duration, str_to_num(key))
					}
				}
				else if (equal(key, "SWARM ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience4, key)
						ArrayPushCell(sound_ambience4_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_SWARM] && equal(key, "SWARM DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience4_duration, str_to_num(key))
					}
				}
				else if (equal(key, "PLAGUE ENABLE"))
					g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] = str_to_num(value)
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE SOUNDS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushString(sound_ambience5, key)
						ArrayPushCell(sound_ambience5_ismp3, equal(key[strlen(key)-4], ".mp3") ? 1 : 0)
					}
				}
				else if (g_ambience_sounds[AMBIENCE_SOUNDS_PLAGUE] && equal(key, "PLAGUE DURATIONS"))
				{
					// Parse sounds
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to sounds array
						ArrayPushCell(sound_ambience5_duration, str_to_num(key))
					}
				}
			}
			case SECTION_BUY_MENU_WEAPONS:
			{
				if (equal(key, "PRIMARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_primary_items, key)
						ArrayPushCell(g_primary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "SECONDARY"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_secondary_items, key)
						ArrayPushCell(g_secondary_weaponids, cs_weapon_name_to_id(key))
					}
				}
				else if (equal(key, "ADDITIONAL ITEMS"))
				{
					// Parse weapons
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_additional_items, key)
					}
				}
			}
			case SECTION_EXTRA_ITEMS_WEAPONS:
			{
				if (equal(key, "NAMES"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_names, key)
					}
				}
				else if (equal(key, "ITEMS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushString(g_extraweapon_items, key)
					}
				}
				else if (equal(key, "COSTS"))
				{
					// Parse weapon items
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to weapons array
						ArrayPushCell(g_extraweapon_costs, str_to_num(key))
					}
				}
			}
			case SECTION_HARD_CODED_ITEMS_COSTS:
			{
				if (equal(key, "NIGHT VISION"))
					g_extra_costs2[EXTRA_NVISION] = str_to_num(value)
				else if (equal(key, "ANTIDOTE"))
					g_extra_costs2[EXTRA_ANTIDOTE] = str_to_num(value)
				else if (equal(key, "ZOMBIE MADNESS"))
					g_extra_costs2[EXTRA_MADNESS] = str_to_num(value)
				else if (equal(key, "INFECTION BOMB"))
					g_extra_costs2[EXTRA_INFBOMB] = str_to_num(value)
			}
			case SECTION_WEATHER_EFFECTS:
			{
				if (equal(key, "RAIN"))
					g_ambience_rain = str_to_num(value)
				else if (equal(key, "SNOW"))
					g_ambience_snow = str_to_num(value)
				else if (equal(key, "FOG"))
					g_ambience_fog = str_to_num(value)
				else if (equal(key, "FOG DENSITY"))
					copy(g_fog_density, charsmax(g_fog_density), value)
				else if (equal(key, "FOG COLOR"))
					copy(g_fog_color, charsmax(g_fog_color), value)
			}
			case SECTION_SKY:
			{
				if (equal(key, "ENABLE"))
					g_sky_enable = str_to_num(value)
				else if (equal(key, "SKY NAMES"))
				{
					// Parse sky names
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to skies array
						ArrayPushString(g_sky_names, key)
						
						// Preache custom sky files
						formatex(linedata, charsmax(linedata), "gfx/env/%sbk.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sdn.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sft.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%slf.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%srt.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
						formatex(linedata, charsmax(linedata), "gfx/env/%sup.tga", key)
						engfunc(EngFunc_PrecacheGeneric, linedata)
					}
				}
			}
			case SECTION_LIGHTNING:
			{
				if (equal(key, "LIGHTS"))
				{
					// Parse lights
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to lightning array
						ArrayPushString(lights_thunder, key)
					}
				}
			}
			case SECTION_ZOMBIE_DECALS:
			{
				if (equal(key, "DECALS"))
				{
					// Parse decals
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to zombie decals array
						ArrayPushCell(zombie_decals, str_to_num(key))
					}
				}
			}
			case SECTION_KNOCKBACK:
			{
				// Format weapon entity name
				strtolower(key)
				format(key, charsmax(key), "weapon_%s", key)
				
				// Add value to knockback power array
				kb_weapon_power[cs_weapon_name_to_id(key)] = str_to_float(value)
			}
			case SECTION_OBJECTIVE_ENTS:
			{
				if (equal(key, "CLASSNAMES"))
				{
					// Parse classnames
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						// Trim spaces
						trim(key)
						trim(value)
						
						// Add to objective ents array
						ArrayPushString(g_objective_ents, key)
					}
				}
			}
			case SECTION_SVC_BAD:
			{
				if (equal(key, "MODELCHANGE DELAY"))
					g_modelchange_delay = str_to_float(value)
				else if (equal(key, "HANDLE MODELS ON SEPARATE ENT"))
					g_handle_models_on_separate_ent = str_to_num(value)
				else if (equal(key, "SET MODELINDEX OFFSET"))
					g_set_modelindex_offset = str_to_num(value)
			}
		}
	}
	if (file) fclose(file)
	
	// Build zombie classes file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_ZOMBIECLASSES_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open zombie classes file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New class starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_zclass2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_zclass2_name, value)
			else if (equal(key, "INFO"))
				ArrayPushString(g_zclass2_info, value)
			else if (equal(key, "MODELS"))
			{
				// Set models start index
				ArrayPushCell(g_zclass2_modelsstart, ArraySize(g_zclass2_playermodel))
				
				// Parse class models
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					// Add to class models array
					ArrayPushString(g_zclass2_playermodel, key)
					ArrayPushCell(g_zclass2_modelindex, -1)
				}
				
				// Set models end index
				ArrayPushCell(g_zclass2_modelsend, ArraySize(g_zclass2_playermodel))
			}
			else if (equal(key, "CLAWMODEL"))
				ArrayPushString(g_zclass2_clawmodel, value)
			else if (equal(key, "HEALTH"))
				ArrayPushCell(g_zclass2_hp, str_to_num(value))
			else if (equal(key, "SPEED"))
				ArrayPushCell(g_zclass2_spd, str_to_num(value))
			else if (equal(key, "GRAVITY"))
				ArrayPushCell(g_zclass2_grav, str_to_float(value))
			else if (equal(key, "KNOCKBACK"))
				ArrayPushCell(g_zclass2_kb, str_to_float(value))
		}
		if (file) fclose(file)
	}
	
	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_EXTRAITEMS_FILE)
	
	// Parse if present
	if (file_exists(path))
	{
		// Open extra items file for reading
		file = fopen(path, "rt")
		
		while (file && !feof(file))
		{
			// Read one line at a time
			fgets(file, linedata, charsmax(linedata))
			
			// Replace newlines with a null character to prevent headaches
			replace(linedata, charsmax(linedata), "^n", "")
			
			// Blank line or comment
			if (!linedata[0] || linedata[0] == ';') continue;
			
			// New item starting
			if (linedata[0] == '[')
			{
				// Remove first and last characters (braces)
				linedata[strlen(linedata) - 1] = 0
				copy(linedata, charsmax(linedata), linedata[1])
				
				// Store its real name for future reference
				ArrayPushString(g_extraitem2_realname, linedata)
				continue;
			}
			
			// Get key and value(s)
			strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
			
			// Trim spaces
			trim(key)
			trim(value)
			
			if (equal(key, "NAME"))
				ArrayPushString(g_extraitem2_name, value)
			else if (equal(key, "COST"))
				ArrayPushCell(g_extraitem2_cost, str_to_num(value))
			else if (equal(key, "TEAMS"))
			{
				// Clear teams bitsum
				teams = 0
				
				// Parse teams
				while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
				{
					// Trim spaces
					trim(key)
					trim(value)
					
					if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_ZOMBIE]))
						teams |= ZP_TEAM_ZOMBIE
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_HUMAN]))
						teams |= ZP_TEAM_HUMAN
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_NEMESIS]))
						teams |= ZP_TEAM_NEMESIS
					else if (equal(key, ZP_TEAM_NAMES[ZP_TEAM_SURVIVOR]))
						teams |= ZP_TEAM_SURVIVOR
				}
				
				// Add to teams array
				ArrayPushCell(g_extraitem2_team, teams)
			}
		}
		if (file) fclose(file)
	}
}

save_customization()
{
	new i, k, buffer[512]
	
	// Build zombie classes file path
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_ZOMBIECLASSES_FILE)
	
	// Open zombie classes file for appending data
	new file = fopen(path, "at"), size = ArraySize(g_zclass_name)
	
	// Add any new zombie classes data at the end if needed
	for (i = 0; i < size; i++)
	{
		if (ArrayGetCell(g_zclass_new, i))
		{
			// Add real name
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_zclass_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add info
			ArrayGetString(g_zclass_info, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nINFO = %s", buffer)
			fputs(file, buffer)
			
			// Add models
			for (k = ArrayGetCell(g_zclass_modelsstart, i); k < ArrayGetCell(g_zclass_modelsend, i); k++)
			{
				if (k == ArrayGetCell(g_zclass_modelsstart, i))
				{
					// First model, overwrite buffer
					ArrayGetString(g_zclass_playermodel, k, buffer, charsmax(buffer))
				}
				else
				{
					// Successive models, append to buffer
					ArrayGetString(g_zclass_playermodel, k, path, charsmax(path))
					format(buffer, charsmax(buffer), "%s , %s", buffer, path)
				}
			}
			format(buffer, charsmax(buffer), "^nMODELS = %s", buffer)
			fputs(file, buffer)
			
			// Add clawmodel
			ArrayGetString(g_zclass_clawmodel, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nCLAWMODEL = %s", buffer)
			fputs(file, buffer)
			
			// Add health
			formatex(buffer, charsmax(buffer), "^nHEALTH = %d", ArrayGetCell(g_zclass_hp, i))
			fputs(file, buffer)
			
			// Add speed
			formatex(buffer, charsmax(buffer), "^nSPEED = %d", ArrayGetCell(g_zclass_spd, i))
			fputs(file, buffer)
			
			// Add gravity
			formatex(buffer, charsmax(buffer), "^nGRAVITY = %.2f", Float:ArrayGetCell(g_zclass_grav, i))
			fputs(file, buffer)
			
			// Add knockback
			formatex(buffer, charsmax(buffer), "^nKNOCKBACK = %.2f^n", Float:ArrayGetCell(g_zclass_kb, i))
			fputs(file, buffer)
		}
	}
	fclose(file)
	
	// Build extra items file path
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/%s", path, ZP_EXTRAITEMS_FILE)
	
	// Open extra items file for appending data
	file = fopen(path, "at")
	size = ArraySize(g_extraitem_name)
	
	// Add any new extra items data at the end if needed
	for (i = EXTRAS_CUSTOM_STARTID; i < size; i++)
	{
		if (ArrayGetCell(g_extraitem_new, i))
		{
			// Add real name
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^n[%s]", buffer)
			fputs(file, buffer)
			
			// Add caption
			ArrayGetString(g_extraitem_name, i, buffer, charsmax(buffer))
			format(buffer, charsmax(buffer), "^nNAME = %s", buffer)
			fputs(file, buffer)
			
			// Add cost
			formatex(buffer, charsmax(buffer), "^nCOST = %d", ArrayGetCell(g_extraitem_cost, i))
			fputs(file, buffer)
			
			// Add team
			formatex(buffer, charsmax(buffer), "^nTEAMS = %s^n", ZP_TEAM_NAMES[ArrayGetCell(g_extraitem_team, i)])
			fputs(file, buffer)
		}
	}
	fclose(file)
	
	// Free arrays containing class/item overrides
	ArrayDestroy(g_zclass2_realname)
	ArrayDestroy(g_zclass2_name)
	ArrayDestroy(g_zclass2_info)
	ArrayDestroy(g_zclass2_modelsstart)
	ArrayDestroy(g_zclass2_modelsend)
	ArrayDestroy(g_zclass2_playermodel)
	ArrayDestroy(g_zclass2_modelindex)
	ArrayDestroy(g_zclass2_clawmodel)
	ArrayDestroy(g_zclass2_hp)
	ArrayDestroy(g_zclass2_spd)
	ArrayDestroy(g_zclass2_grav)
	ArrayDestroy(g_zclass2_kb)
	ArrayDestroy(g_zclass_new)
	ArrayDestroy(g_extraitem2_realname)
	ArrayDestroy(g_extraitem2_name)
	ArrayDestroy(g_extraitem2_cost)
	ArrayDestroy(g_extraitem2_team)
	ArrayDestroy(g_extraitem_new)
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !g_isconnected[id] || !get_pcvar_num(cvar_botquota))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled")
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, id, "fw_ResetMaxSpeed_Post", 1)
	
	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}

// Disable minmodels task
public disable_minmodels(id)
{
	if (!g_isconnected[id]) return;
	client_cmd(id, "cl_minmodels 0")
}

// Bots automatically buy extra items
public bot_buy_extras(taskid)
{
	// Nemesis or Survivor bots have nothing to buy by default
	if (!g_isalive[ID_SPAWN] || g_survivor[ID_SPAWN] || g_nemesis[ID_SPAWN])
		return;
	
	if (!g_zombie[ID_SPAWN]) // human bots
	{
		// Attempt to buy Night Vision
		buy_extra_item(ID_SPAWN, EXTRA_NVISION)
		
		// Attempt to buy a weapon
		buy_extra_item(ID_SPAWN, random_num(EXTRA_WEAPONS_STARTID, EXTRAS_CUSTOM_STARTID-1))
	}
	else // zombie bots
	{
		// Attempt to buy an Antidote
		buy_extra_item(ID_SPAWN, EXTRA_ANTIDOTE)
	}
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
	// Player died or turned into a zombie
	if (!g_isalive[id] || g_zombie[id])
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[REFILL_WEAPONID], AMMOTYPE[REFILL_WEAPONID], MAXBPAMMO[REFILL_WEAPONID])
}

// Balance Teams Task
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return;
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_maxplayers) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
			continue;
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}

// Welcome Message Task
public welcome_msg()
{
	
	// Show mod info
	ChatColor(0,"")
	if (!get_pcvar_num(cvar_infammo)) ChatColor(0,"%L", LANG_PLAYER, "NOTICE_INFO1" );
	
	// Show T-virus HUD notice
	set_hudmessage(0, 125, 200, -1.0, 0.22, 0, 0.0, 3.0, 2.0, 1.0, -1)
	ShowSyncHudMsg(0, g_MsgSync3, "%L", LANG_PLAYER, "NOTICE_VIRUS_FREE")
}

// Respawn Player Task (deathmatch)
public respawn_player_task(taskid)
{
	// Already alive or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// Respawn player automatically if allowed on current round
	if ((!g_survround || get_pcvar_num(cvar_allowrespawnsurv)) && (!g_swarmround || get_pcvar_num(cvar_allowrespawnswarm)) && (!g_nemround || get_pcvar_num(cvar_allowrespawnnem)) && (!g_plagueround || get_pcvar_num(cvar_allowrespawnplague)))
	{
		// Infection rounds = none of the above
		if (!get_pcvar_num(cvar_allowrespawninfection) && !g_survround && !g_nemround && !g_swarmround && !g_plagueround)
			return;
		
		// Respawn if only the last human is left? (ignore this setting on survivor rounds)
		if (!g_survround && !get_pcvar_num(cvar_respawnafterlast) && fnGetHumans() <= 1)
			return;
		
		// Respawn as zombie?
		if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && fnGetZombies() < fnGetAlive()/2))
			g_respawn_as_zombie[ID_SPAWN] = true
		
		// Override respawn as zombie setting on nemesis and survivor rounds
		if (g_survround) g_respawn_as_zombie[ID_SPAWN] = true
		else if (g_nemround) g_respawn_as_zombie[ID_SPAWN] = false
		
		respawn_player_manually(ID_SPAWN)
	}
}

// Respawn Player Check Task (if killed by worldspawn)
public respawn_player_check_task(taskid)
{
	// Successfully spawned or round ended
	if (g_isalive[ID_SPAWN] || g_endround)
		return;
	
	// Get player's team
	static team
	team = fm_cs_get_user_team(ID_SPAWN)
	
	// Player moved to spectators
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return;
	
	// If player was being spawned as a zombie, set the flag again
	if (g_zombie[ID_SPAWN]) g_respawn_as_zombie[ID_SPAWN] = true
	else g_respawn_as_zombie[ID_SPAWN] = false
	
	respawn_player_manually(ID_SPAWN)
}

// Respawn Player Manually (called after respawn checks are done)
respawn_player_manually(id)
{
	// Set proper team before respawning, so that the TeamInfo message that's sent doesn't confuse PODBots
	if (g_respawn_as_zombie[id])
		fm_cs_set_user_team(id, FM_CS_TEAM_T)
	else
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
	
	// Respawning a player has never been so easy
	ExecuteHamB(Ham_CS_RoundRespawn, id)
}

// Check Round Task -check that we still have both zombies and humans on a round-
check_round(leaving_player)
{
	// Round ended or make_a_zombie task still active
	if (g_endround || task_exists(TASK_MAKEZOMBIE))
		return;
	
	// Get alive players count
	static iPlayersnum, id
	iPlayersnum = fnGetAlive()
	
	// Last alive player, don't bother
	if (iPlayersnum < 2)
		return;
	
	// Last zombie disconnecting
	if (g_zombie[leaving_player] && fnGetZombies() == 1)
	{
		// Only one CT left, don't bother
		if (fnGetHumans() == 1 && fnGetCTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last zombie left notice
		zp_colored_print(0, "^x04[ZP]^x01 %L", LANG_PLAYER, "LAST_ZOMBIE_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Nemesis or just a zombie?
		if (g_nemesis[leaving_player])
			zombieme(id, 0, 1, 0, 0)
		else
			zombieme(id, 0, 0, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Nemesis, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) && g_nemesis[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
	
	// Last human disconnecting
	else if (!g_zombie[leaving_player] && fnGetHumans() == 1)
	{
		// Only one T left, don't bother
		if (fnGetZombies() == 1 && fnGetTs() == 1)
			return;
		
		// Pick a random one to take his place
		while ((id = fnGetRandomAlive(random_num(1, iPlayersnum))) == leaving_player ) { /* keep looping */ }
		
		// Show last human left notice
		zp_colored_print(0, "^x04[ZP]^x01 %L", LANG_PLAYER, "LAST_HUMAN_LEFT", g_playername[id])
		
		// Set player leaving flag
		g_lastplayerleaving = true
		
		// Turn into a Survivor or just a human?
		if (g_survivor[leaving_player])
			humanme(id, 1, 0)
		else
			humanme(id, 0, 0)
		
		// Remove player leaving flag
		g_lastplayerleaving = false
		
		// If Survivor, set chosen player's health to that of the one who's leaving
		if (get_pcvar_num(cvar_keephealthondisconnect) && g_survivor[leaving_player])
			fm_set_user_health(id, pev(leaving_player, pev_health))
	}
}

// Lighting Effects Task
public lighting_effects()
{
	// Cache some CVAR values at every 5 secs
	cache_cvars()
	
	// Get lighting style
	static lighting[2]
	get_pcvar_string(cvar_lighting, lighting, charsmax(lighting))
	strtolower(lighting)
	
	// Lighting disabled? ["0"]
	if (lighting[0] == '0')
		return;
	
	// Darkest light settings?
	if (lighting[0] >= 'a' && lighting[0] <= 'd')
	{
		static thunderclap_in_progress, Float:thunder
		thunderclap_in_progress = task_exists(TASK_THUNDER)
		thunder = get_pcvar_float(cvar_thunder)
		
		// Set thunderclap tasks if not existant
		if (thunder > 0.0 && !task_exists(TASK_THUNDER_PRE) && !thunderclap_in_progress)
		{
			g_lights_i = 0
			ArrayGetString(lights_thunder, random_num(0, ArraySize(lights_thunder) - 1), g_lights_cycle, charsmax(g_lights_cycle))
			g_lights_cycle_len = strlen(g_lights_cycle)
			set_task(thunder, "thunderclap", TASK_THUNDER_PRE)
		}
		
		// Set lighting only when no thunderclaps are going on
		if (!thunderclap_in_progress) engfunc(EngFunc_LightStyle, 0, lighting)
	}
	else
	{
		// Remove thunderclap tasks
		remove_task(TASK_THUNDER_PRE)
		remove_task(TASK_THUNDER)
		
		// Set lighting
		engfunc(EngFunc_LightStyle, 0, lighting)
	}
}

// Thunderclap task
public thunderclap()
{
	// Play thunder sound
	if (g_lights_i == 0)
	{
		static sound[64]
		ArrayGetString(sound_thunder, random_num(0, ArraySize(sound_thunder) - 1), sound, charsmax(sound))
		PlaySound(sound)
	}
	
	// Set lighting
	static light[2]
	light[0] = g_lights_cycle[g_lights_i]
	engfunc(EngFunc_LightStyle, 0, light)
	
	g_lights_i++
	
	// Lighting cycle end?
	if (g_lights_i >= g_lights_cycle_len)
	{
		remove_task(TASK_THUNDER)
		lighting_effects()
	}
	// Lighting cycle start?
	else if (!task_exists(TASK_THUNDER))
		set_task(0.1, "thunderclap", TASK_THUNDER, _, _, "b")
}

// Ambience Sound Effects Task
public ambience_sound_effects(taskid)
{
	// Play a random sound depending on the round
	static sound[64], iRand, duration
	
	if (g_nemround) // Nemesis Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience2) - 1)
		ArrayGetString(sound_ambience2, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience2_duration, iRand)
	}
	else if (g_survround) // Survivor Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience3) - 1)
		ArrayGetString(sound_ambience3, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience3_duration, iRand)
	}
	else if (g_swarmround) // Swarm Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience4) - 1)
		ArrayGetString(sound_ambience4, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience4_duration, iRand)
	}
	else if (g_plagueround) // Plague Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience5) - 1)
		ArrayGetString(sound_ambience5, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience5_duration, iRand)
	}
	else // Infection Mode
	{
		iRand = random_num(0, ArraySize(sound_ambience1) - 1)
		ArrayGetString(sound_ambience1, iRand, sound, charsmax(sound))
		duration = ArrayGetCell(sound_ambience1_duration, iRand)
	}
	
	// Play it on clients
	PlaySound(sound)
	
	// Set the task for when the sound is done playing
	set_task(float(duration), "ambience_sound_effects", TASK_AMBIENCESOUNDS)
}

// Ambience Sounds Stop Task
ambience_sound_stop()
{
	client_cmd(0, "mp3 stop; stopsound")
}

// Flashlight Charge Task
public flashlight_charge(taskid)
{
	// Drain or charge?
	if (g_flashlight[ID_CHARGE])
		g_flashbattery[ID_CHARGE] -= get_pcvar_num(cvar_flashdrain)
	else
		g_flashbattery[ID_CHARGE] += get_pcvar_num(cvar_flashcharge)
	
	// Battery fully charged
	if (g_flashbattery[ID_CHARGE] >= 100)
	{
		// Don't exceed 100%
		g_flashbattery[ID_CHARGE] = 100
		
		// Update flashlight battery on HUD
		message_begin(MSG_ONE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(100) // battery
		message_end()
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Battery depleted
	if (g_flashbattery[ID_CHARGE] <= 0)
	{
		// Turn it off
		g_flashlight[ID_CHARGE] = false
		g_flashbattery[ID_CHARGE] = 0
		
		// Play flashlight toggle sound
		emit_sound(ID_CHARGE, CHAN_ITEM, sound_flashlight, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Update flashlight status on HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, ID_CHARGE)
		write_byte(0) // toggle
		write_byte(0) // battery
		message_end()
		
		// Remove flashlight task for this player
		remove_task(ID_CHARGE+TASK_FLASH)
	}
	else
	{
		// Update flashlight battery on HUD
		message_begin(MSG_ONE_UNRELIABLE, g_msgFlashBat, _, ID_CHARGE)
		write_byte(g_flashbattery[ID_CHARGE]) // battery
		message_end()
	}
}

// Remove Spawn Protection Task
public remove_spawn_protection(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Remove spawn protection
	g_nodamage[ID_SPAWN] = false
	set_pev(ID_SPAWN, pev_effects, pev(ID_SPAWN, pev_effects) & ~EF_NODRAW)
}

// Hide Player's Money Task
public task_hide_money(taskid)
{
	// Not alive
	if (!g_isalive[ID_SPAWN])
		return;
	
	// Hide money
	message_begin(MSG_ONE, g_msgHideWeapon, _, ID_SPAWN)
	write_byte(HIDE_MONEY) // what to hide bitsum
	message_end()
	
	// Hide the HL crosshair that's drawn
	message_begin(MSG_ONE, g_msgCrosshair, _, ID_SPAWN)
	write_byte(0) // toggle
	message_end()
}

// Turn Off Flashlight and Restore Batteries
turn_off_flashlight(id)
{
	// Restore batteries for the next use
	fm_cs_set_user_batteries(id, 100)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Turn off custom flashlight
	if (g_cached_customflash)
	{
		// Turn it off
		g_flashlight[id] = false
		g_flashbattery[id] = 100
		
		// Update flashlight HUD
		message_begin(MSG_ONE, g_msgFlashlight, _, id)
		write_byte(0) // toggle
		write_byte(100) // battery
		message_end()
		
		// Remove previous tasks
		remove_task(id+TASK_CHARGE)
		remove_task(id+TASK_FLASH)
	}
}

// Infection Bomb Explosion
infection_explode(ent)
{
	// Round ended (bugfix)
	if (g_endround) return;
	
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	// Make the explosion
	create_blast(originF)
	
	// Infection nade explode sound
	static sound[64]
	ArrayGetString(grenade_infect, random_num(0, ArraySize(grenade_infect) - 1), sound, charsmax(sound))
	emit_sound(ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get attacker
	static attacker
	attacker = pev(ent, pev_owner)
	
	// Infection bomb owner disconnected? (bugfix)
	if (!is_user_valid_connected(attacker))
	{
		// Get rid of the grenade
		engfunc(EngFunc_RemoveEntity, ent)
		return;
	}
	
	// Collisions
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS)) != 0)
	{
		// Only effect alive non-spawnprotected humans
		if (!is_user_valid_alive(victim) || g_zombie[victim] || g_nodamage[victim])
			continue;
		
		// Last human is killed
		if (fnGetHumans() == 1)
		{
			ExecuteHamB(Ham_Killed, victim, attacker, 0)
			continue;
		}
		
		// Infected victim's sound
		ArrayGetString(grenade_infect_player, random_num(0, ArraySize(grenade_infect_player) - 1), sound, charsmax(sound))
		emit_sound(victim, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		// Turn into zombie
		zombieme(victim, attacker, 0, 1, 1)
	}
	
	// Get rid of the grenade
	engfunc(EngFunc_RemoveEntity, ent)
}



// TU SOM SKONCIL







// Fire Grenade Explosion
fire_explode( ent ) {
	static Float:originF[ 3 ];
	pev( ent, pev_origin, originF );
	
	create_blast2( originF );
	
	static sound[ 64 ];
	ArrayGetString( grenade_fire, random_num( 0, ArraySize( grenade_fire ) - 1 ), sound, charsmax( sound ) );
	emit_sound( ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
	
	static victim;
	victim = -1;
	
	while( ( victim = engfunc( EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS ) ) != 0 ) {
		if( !is_user_valid_alive( victim ) || !g_zombie[ victim ] || g_nodamage[ victim ] )
			continue;
		new burn_resist[ 33 ];
		burn_resist[ victim ] = random_num( 1, 100 );
		if( burn_resist[ victim ] < g_resBurnLevel[ victim ] ) {
			player_resisteffect( victim );
			ScreenFade( victim, 0.2, 65, 65, 200, 100 );
			client_print( victim, print_center, "BOL SI OCHRANENY PRED OHNOM!" );
		} else {
			if( get_pcvar_num( cvar_hudicons ) ) {
				message_begin( MSG_ONE_UNRELIABLE, g_msgDamage, _, victim );
				write_byte( 0 );
				write_byte( 0 ); 
				write_long( DMG_BURN );
				write_coord( 0 ); 
				write_coord( 0 ); 
				write_coord( 0 ); 
				message_end( );
			}
			
			if( g_nemesis[ victim ] )
				g_burning_duration[ victim ] += get_pcvar_num( cvar_fireduration );
			else
				g_burning_duration[ victim ] += get_pcvar_num( cvar_fireduration ) * 5;
			
			if( !task_exists( victim + TASK_BURN ) )
				set_task( 0.2, "burning_flame", victim + TASK_BURN, _, _, "b" );
		}
	}
	
	engfunc( EngFunc_RemoveEntity, ent ); 
}

frost_explode( ent )
{
	static Float:originF[ 3 ];
	pev( ent, pev_origin, originF );
	
	create_blast3( originF );
	
	static sound[ 64 ];
	ArrayGetString( grenade_frost, random_num( 0, ArraySize( grenade_frost ) - 1 ), sound, charsmax( sound ) );
	emit_sound( ent, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
	
	static victim;
	victim = -1;
	
	while( ( victim = engfunc( EngFunc_FindEntityInSphere, victim, originF, NADE_EXPLOSION_RADIUS ) ) != 0 ) {
		if( !is_user_valid_alive( victim ) || !g_zombie[ victim ] || g_frozen[ victim ] || g_nodamage[ victim ] )
			continue;
		new frost_resist[ 33 ];
		frost_resist[ victim ] = random_num( 1, 100 );
		
		if( frost_resist[ victim ] < g_resFrostLevel[ victim ] ) {
			ScreenFade( victim, 0.2, 65, 65, 200, 100 );
			client_print( victim, print_center, "BOL SI OCHRANENY PRED ZMRAZENIM!" );
		} else {
			if( g_nemesis[ victim ] ) {
				static origin2[ 3 ];
				get_user_origin( victim, origin2 );
				
				ArrayGetString( grenade_frost_break, random_num( 0, ArraySize( grenade_frost_break ) - 1 ), sound, charsmax( sound ) );
				emit_sound( victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
				
				message_begin( MSG_PVS, SVC_TEMPENTITY, origin2 );
				write_byte( TE_BREAKMODEL );
				write_coord( origin2[ 0 ] ); 
				write_coord( origin2[ 1 ] ); 
				write_coord( origin2[ 2 ] + 24 );
				write_coord( 16 ); 
				write_coord( 16 );
				write_coord( 16 );
				write_coord( random_num( -50, 50 ) ); 
				write_coord( random_num( -50, 50 ) ); 
				write_coord( 25 );
				write_byte( 10 );
				write_short( g_glassSpr );
				write_byte( 10 ); 
				write_byte( 25 );
				write_byte( BREAK_GLASS );
				message_end( );
				continue;
			}
			
			if( get_pcvar_num( cvar_hudicons ) ) {
				message_begin( MSG_ONE_UNRELIABLE, g_msgDamage, _, victim );
				write_byte( 0 ); 
				write_byte( 0 );
				write_long( DMG_DROWN );
				write_coord( 0 ); 
				write_coord( 0 ); 
				write_coord( 0 ); 
				message_end( );
			}
			
			if( g_handle_models_on_separate_ent )
				fm_set_rendering( g_ent_playermodel[ victim ], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
			else
				fm_set_rendering( victim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
			
			ArrayGetString( grenade_frost_player, random_num( 0, ArraySize( grenade_frost_player ) - 1 ), sound, charsmax( sound ) );
			emit_sound( victim, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM );
			
			message_begin( MSG_ONE, g_msgScreenFade, _, victim );
			write_short( 0 ); 
			write_short( 0 ); 
			write_short( FFADE_STAYOUT );
			write_byte( 0 ); 
			write_byte( 50 ); 
			write_byte( 200 ); 
			write_byte( 100 ); 
			message_end( );
			
			g_frozen[ victim ] = true;
			
			pev( victim, pev_gravity, g_frozen_gravity[ victim ] );
			
			if( pev( victim, pev_flags ) & FL_ONGROUND )
				set_pev( victim, pev_gravity, 999999.9 ); 
			else
				set_pev( victim, pev_gravity, 0.000001 ); 
			
			ExecuteHamB( Ham_Player_ResetMaxSpeed, victim );
			
			set_task( get_pcvar_float( cvar_freezeduration ), "remove_freeze", victim );
		}
	}
	
	engfunc( EngFunc_RemoveEntity, ent ); 
}

// Remove freeze task
public remove_freeze(id)
{
	// Not alive or not frozen anymore
	if (!g_isalive[id] || !g_frozen[id])
		return;
	
	// Unfreeze
	g_frozen[id] = false;
	
	// Restore gravity and maxspeed (bugfix)
	set_pev(id, pev_gravity, g_frozen_gravity[id])
	ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
	
	// Restore rendering
	if (g_handle_models_on_separate_ent)
	{
		// Nemesis or Survivor glow / remove glow on player model entity
		if (g_nemesis[id] && get_pcvar_num(cvar_nemglow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
		else if (g_survivor[id] && get_pcvar_num(cvar_survglow))
			fm_set_rendering(g_ent_playermodel[id], kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
		else
			fm_set_rendering(g_ent_playermodel[id])
	}
	else
	{
		// Nemesis or Survivor glow / remove glow
		if (g_nemesis[id] && get_pcvar_num(cvar_nemglow))
			fm_set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
		else if (g_survivor[id] && get_pcvar_num(cvar_survglow))
			fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
		else
			fm_set_rendering(id)
	}
	
	// Gradually remove screen's blue tint
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(0) // red
	write_byte(50) // green
	write_byte(200) // blue
	write_byte(100) // alpha
	message_end()
	
	// Broken glass sound
	static sound[64]
	ArrayGetString(grenade_frost_break, random_num(0, ArraySize(grenade_frost_break) - 1), sound, charsmax(sound))
	emit_sound(id, CHAN_BODY, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	// Get player's origin
	static origin2[3]
	get_user_origin(id, origin2)
	
	// Glass shatter
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin2)
	write_byte(TE_BREAKMODEL) // TE id
	write_coord(origin2[0]) // x
	write_coord(origin2[1]) // y
	write_coord(origin2[2]+24) // z
	write_coord(16) // size x
	write_coord(16) // size y
	write_coord(16) // size z
	write_coord(random_num(-50, 50)) // velocity x
	write_coord(random_num(-50, 50)) // velocity y
	write_coord(25) // velocity z
	write_byte(10) // random velocity
	write_short(g_glassSpr) // model
	write_byte(10) // count
	write_byte(25) // life
	write_byte(BREAK_GLASS) // flags
	message_end()
	
	ExecuteForward(g_fwUserUnfrozen, g_fwDummyResult, id);
}

// Remove Stuff Task
public remove_stuff()
{
	static ent
	
	// Remove rotating doors
	if (get_pcvar_num(cvar_removedoors) > 0)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door_rotating")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Remove all doors
	if (get_pcvar_num(cvar_removedoors) > 1)
	{
		ent = -1;
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "func_door")) != 0)
			engfunc(EngFunc_SetOrigin, ent, Float:{8192.0 ,8192.0 ,8192.0})
	}
	
	// Triggered lights
	if (!get_pcvar_num(cvar_triggered))
	{
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0); // turn off the light
			set_pev(ent, pev_targetname, 0) // prevent it from being triggered
		}
	}
}

// Set Custom Weapon Models
replace_weapon_models(id, weaponid)
{
switch (weaponid)
{
	case CSW_KNIFE: // Custom knife models
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id]) // Nemesis
			{
				set_pev(id, pev_viewmodel2, model_vknife_nemesis)
				set_pev(id, pev_weaponmodel2, "")
			}
			else // Zombies
			{
				// Admin knife models?
				if (get_pcvar_num(cvar_adminknifemodelszombie) && get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS])
				{
					set_pev(id, pev_viewmodel2, model_vknife_admin_zombie)
					set_pev(id, pev_weaponmodel2, "")
				}
				else
				{
					static clawmodel[100]
					ArrayGetString(g_zclass_clawmodel, g_zombieclass[id], clawmodel, charsmax(clawmodel))
					format(clawmodel, charsmax(clawmodel), "models/zombie_plague/%s", clawmodel)
					set_pev(id, pev_viewmodel2, clawmodel)
					set_pev(id, pev_weaponmodel2, "")
				}
			}
		}
		else // Humans
		{
			// Admin knife models?
			if (get_pcvar_num(cvar_adminknifemodelshuman) && get_user_flags(id) & g_access_flag[ACCESS_ADMIN_MODELS])
			{
				set_pev(id, pev_viewmodel2, model_vknife_admin_human)
				set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
			}
			else
			{
				set_pev(id, pev_viewmodel2, model_vknife_human)
				set_pev(id, pev_weaponmodel2, "models/p_knife.mdl")
			}
		}
	}
	case CSW_HEGRENADE: // Infection bomb or fire grenade
	{
		if (g_zombie[id])
			set_pev(id, pev_viewmodel2, model_grenade_infect)
			else
				set_pev(id, pev_viewmodel2, model_grenade_fire)
		}
		case CSW_FLASHBANG: // Frost grenade
		{
			set_pev(id, pev_viewmodel2, model_grenade_frost)
		}
		case CSW_SMOKEGRENADE: // Flare grenade
		{
			set_pev(id, pev_viewmodel2, model_grenade_flare)
		}
	}
	
static survweaponname[32]
get_pcvar_string(cvar_survweapon, survweaponname, charsmax(survweaponname))
if (g_survivor[id] && weaponid == cs_weapon_name_to_id(survweaponname))
		set_pev(id, pev_viewmodel2, model_vweapon_survivor)
	
// Update model on weaponmodel ent
if (g_handle_models_on_separate_ent) fm_set_weaponmodel_ent(id)
}

// Reset Player Vars
reset_vars(id, resetall)
{
	g_zombie[id] = false
	g_nemesis[id] = false
	g_survivor[id] = false
	g_firstzombie[id] = false
	g_lastzombie[id] = false
	g_lasthuman[id] = false
	g_frozen[id] = false
	g_nodamage[id] = false
	g_respawn_as_zombie[id] = false
	g_nvision[id] = false
	g_nvisionenabled[id] = false
	g_flashlight[id] = false
	g_flashbattery[id] = 100
	g_canbuy[id] = true
	g_burning_duration[id] = 0
	
	if (resetall)
	{
		g_ammopacks[id] = get_pcvar_num(cvar_startammopacks)
		g_zombieclass[id] = ZCLASS_NONE
		g_zombieclassnext[id] = ZCLASS_NONE
		g_damagedealt_human[id] = 0
		g_damagedealt_zombie[id] = 0
		WPN_AUTO_ON = 0
		WPN_STARTID = 0
		PL_ACTION = 0
		MENU_PAGE_ZCLASS = 0
		MENU_PAGE_EXTRAS = 0
		MENU_PAGE_PLAYERS = 0
	}
}

// Set spectators nightvision
public spec_nvision(id)
{
	// Not connected, alive, or bot
	if (!g_isconnected[id] || g_isalive[id] || g_isbot[id])
		return;
	
	// Give Night Vision?
	if (get_pcvar_num(cvar_nvggive))
	{
		g_nvision[id] = true
		
		// Turn on Night Vision automatically?
		if (get_pcvar_num(cvar_nvggive) == 1)
		{
			g_nvisionenabled[id] = true
			
			// Custom nvg?
			if (get_pcvar_num(cvar_customnvg))
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else
				set_user_gnvision(id, 1)
		}
	}
}

// Show HUD Task
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD;
	
	// Player died?
	if (!g_isalive[id])
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!g_isalive[id]) return;
	}
	
	// Format classname
	static class[32], red, green, blue
	
	if (g_zombie[id]) // zombies
	{
		red = 207
		green = 104
		blue = 1	
		
		if (g_nemesis[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_NEMESIS")
		else
			copy(class, charsmax(class), g_zombie_classname[id])
	}
	else // humans
	{
		
		red = 5
		green = 116
		blue = 227
		
		if (g_survivor[id])
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_SURVIVOR")
		else
			formatex(class, charsmax(class), "%L", ID_SHOWHUD, "CLASS_HUMAN")
	}
	
	// Spectating someone else?
	if( id != ID_SHOWHUD ) {
		set_hudmessage(255, 255, 255, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "HP: %d | %L %s | %L %d | Spirtiy:%i", pev(id, pev_health), ID_SHOWHUD, "CLASS_CLASS", class, ID_SHOWHUD, "AMMO_PACKS1", g_ammopacks[id] , body[id])
	} else {
		if( Logined[ id ] ) {
			set_hudmessage(red, green, blue, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0, -1)
			ShowSyncHudMsg(ID_SHOWHUD, g_MsgSync2, "%L:%d | EXP:%d | %L%d | LVL:%i | Spirity:%i^nAdrenalin:%i%%", id, "ZOMBIE_ATTRIB1", pev(ID_SHOWHUD, pev_health), exp[id] ,ID_SHOWHUD, "AMMO_PACKS1", g_ammopacks[ID_SHOWHUD], levels[id],body[id],adrenaline[id])
		} else {
			set_hudmessage( 255, 80, 80, HUD_STATS_X, HUD_STATS_Y, 0, 6.0, 1.1, 0.0, 0.0, -1)
			ShowSyncHudMsg( ID_SHOWHUD, g_MsgSync2, "NIESI AKTUALNE PRIHLASENY!^nSTLAC PISMENO M NA ZOBRAZENIE MENU" )
		}
	}
}

// Play idle zombie sounds
public zombie_play_idle(taskid)
{
	// Round ended/new one starting
	if (g_endround || g_newround)
		return;
	
	static sound[64]
	
	// Last zombie?
	if (g_lastzombie[ID_BLOOD])
	{
		ArrayGetString(zombie_idle_last, random_num(0, ArraySize(zombie_idle_last) - 1), sound, charsmax(sound))
		emit_sound(ID_BLOOD, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else
	{
		ArrayGetString(zombie_idle, random_num(0, ArraySize(zombie_idle) - 1), sound, charsmax(sound))
		emit_sound(ID_BLOOD, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

public human_play_idle(taskid)
{
	// Round ended/new one starting
	if (g_endround || g_newround)
		return;
	
	static sound[64]
	
	if( !g_lasthuman[ID_BLOOD] )
	{
		ArrayGetString(human_idle, random_num(0, ArraySize(human_idle) - 1), sound, charsmax(sound))
		emit_sound(ID_BLOOD, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}	
}


// Madness Over Task
public madness_over(taskid)
{
	g_nodamage[ID_BLOOD] = false
}

// Place user at a random spawn
do_random_spawn(id, regularspawns = 0)
{
	static hull, sp_index, i
	
	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	
	// Use regular spawns?
	if (!regularspawns)
	{
		// No spawns?
		if (!g_spawnCount)
			return;
		
		// Choose random spawn to start looping at
		sp_index = random_num(0, g_spawnCount - 1)
		
		// Try to find a clear spawn
		for (i = sp_index + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_index) break;
		}
	}
	else
	{
		// No spawns?
		if (!g_spawnCount2)
			return;
		
		// Choose random spawn to start looping at
		sp_index = random_num(0, g_spawnCount2 - 1)
		
		// Try to find a clear spawn
		for (i = sp_index + 1; /*no condition*/; i++)
		{
			// Start over when we reach the end
			if (i >= g_spawnCount2) i = 0
			
			// Free spawn space?
			if (is_hull_vacant(g_spawns2[i], hull))
			{
				// Engfunc_SetOrigin is used so ent's mins and maxs get updated instantly
				engfunc(EngFunc_SetOrigin, id, g_spawns2[i])
				break;
			}
			
			// Loop completed, no free space found
			if (i == sp_index) break;
		}
	}
}

// Get Zombies -returns alive zombies number-
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_zombie[id])
			iZombies++
	}
	
	return iZombies;
}

// Get Humans -returns alive humans number-
fnGetHumans()
{
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && !g_zombie[id])
			iHumans++
	}
	
	return iHumans;
}

// Get Nemesis -returns alive nemesis number-
fnGetNemesis()
{
	static iNemesis, id
	iNemesis = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_nemesis[id])
			iNemesis++
	}
	
	return iNemesis;
}

// Get Survivors -returns alive survivors number-
fnGetSurvivors()
{
	static iSurvivors, id
	iSurvivors = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id] && g_survivor[id])
			iSurvivors++
	}
	
	return iSurvivors;
}

// Get Alive -returns alive players number-
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
	}
	
	return iAlive;
}

// Get Random Alive -returns index of alive player number n -
fnGetRandomAlive(n)
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
			iAlive++
		
		if (iAlive == n)
			return id;
	}
	
	return -1;
}

// Get Playing -returns number of users playing-
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
				iPlaying++
		}
	}
	
	return iPlaying;
}

// Get CTs -returns number of CTs connected-
fnGetCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Ts -returns number of Ts connected-
fnGetTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isconnected[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Get Alive CTs -returns number of CTs alive-
fnGetAliveCTs()
{
	static iCTs, id
	iCTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_CT)
				iCTs++
		}
	}
	
	return iCTs;
}

// Get Alive Ts -returns number of Ts alive-
fnGetAliveTs()
{
	static iTs, id
	iTs = 0
	
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (g_isalive[id])
		{			
			if (fm_cs_get_user_team(id) == FM_CS_TEAM_T)
				iTs++
		}
	}
	
	return iTs;
}

// Last Zombie Check -check for last zombie and set its flag-
fnCheckLastZombie()
{
	static id
	for (id = 1; id <= g_maxplayers; id++)
	{
		// Last zombie
		if (g_isalive[id] && g_zombie[id] && !g_nemesis[id] && fnGetZombies() == 1)
		{
			if (!g_lastzombie[id])
			{
				// Last zombie forward
				ExecuteForward(g_fwUserLastZombie, g_fwDummyResult, id);
			}
			g_lastzombie[id] = true
		}
		else
			g_lastzombie[id] = false
		
		// Last human
		if (g_isalive[id] && !g_zombie[id] && !g_survivor[id] && fnGetHumans() == 1)
		{
			if (!g_lasthuman[id])
			{
				// Last human forward
				ExecuteForward(g_fwUserLastHuman, g_fwDummyResult, id);
				
				// Reward extra hp
				
				set_task(1.0, "Task_ShowHealth", id+TASK_HEALTH, _, _, "b")
				power_damage(id)
				last_human = 1
			}
			g_lasthuman[id] = true
		}
		else
			g_lasthuman[id] = false
	}
}

// Save player's stats to database
save_stats(id)
{
	// Check whether there is another record already in that slot
	if (db_name[id][0] && !equal(g_playername[id], db_name[id]))
	{
		// If DB size is exceeded, write over old records
		if (db_slot_i >= sizeof db_name)
			db_slot_i = g_maxplayers+1
		
		// Move previous record onto an additional save slot
		copy(db_name[db_slot_i], charsmax(db_name[]), db_name[id])
		db_ammopacks[db_slot_i] = db_ammopacks[id]
		db_zombieclass[db_slot_i] = db_zombieclass[id]
		db_slot_i++
	}
	
	// Now save the current player stats
	copy(db_name[id], charsmax(db_name[]), g_playername[id]) // name
	db_ammopacks[id] = g_ammopacks[id]  // ammo packs
	db_zombieclass[id] = g_zombieclassnext[id] // zombie class
}

// Load player's stats from database (if a record is found)
load_stats(id)
{
	// Look for a matching record
	static i
	for (i = 0; i < sizeof db_name; i++)
	{
		if (equal(g_playername[id], db_name[i]))
		{
			// Bingo!
			g_ammopacks[id] = db_ammopacks[i]
			g_zombieclass[id] = db_zombieclass[i]
			g_zombieclassnext[id] = db_zombieclass[i]
			return;
		}
	}
}

// Checks if a player is allowed to be zombie
allowed_zombie(id)
{
	if ((g_zombie[id] && !g_nemesis[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be human
allowed_human(id)
{
	if ((!g_zombie[id] && !g_survivor[id]) || g_endround || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be survivor
allowed_survivor(id)
{
	if (g_endround || g_survivor[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && g_zombie[id] && fnGetZombies() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to be nemesis
allowed_nemesis(id)
{
	if (g_endround || g_nemesis[id] || !g_isalive[id] || task_exists(TASK_WELCOMEMSG) || (!g_newround && !g_zombie[id] && fnGetHumans() == 1))
		return false;
	
	return true;
}

// Checks if a player is allowed to respawn
allowed_respawn(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	if (g_endround || team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED || g_isalive[id])
		return false;
	
	return true;
}

// Checks if swarm mode is allowed
allowed_swarm()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG))
		return false;
	
	return true;
}

// Checks if multi infection mode is allowed
allowed_multi()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) < 2 || floatround(fnGetAlive()*get_pcvar_float(cvar_multiratio), floatround_ceil) >= fnGetAlive())
		return false;
	
	return true;
}

// Checks if plague mode is allowed
allowed_plague()
{
	if (g_endround || !g_newround || task_exists(TASK_WELCOMEMSG) || floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil) < 1
	|| fnGetAlive()-(get_pcvar_num(cvar_plaguesurvnum)+get_pcvar_num(cvar_plaguenemnum)+floatround((fnGetAlive()-(get_pcvar_num(cvar_plaguenemnum)+get_pcvar_num(cvar_plaguesurvnum)))*get_pcvar_float(cvar_plagueratio), floatround_ceil)) < 1)
		return false;
	
	return true;
}

// Admin Command. zp_zombie
command_zombie(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_INFECT")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_INFECT")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_INFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, player)
	}
	else
	{
		// Just infect
		zombieme(player, 0, 0, 0, 0)
	}
}

// Admin Command. zp_human
command_human(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_DISINFECT")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_DISINFECT", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Turn to human
	humanme(player, 0, 0)
}

// Admin Command. zp_survivor
command_survivor(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_SURVIVAL")
	}
	
	 // Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_SURVIVAL", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, player)
	}
	else
	{
		// Turn player into a Survivor
		humanme(player, 1, 0)
	}
}

// Admin Command. zp_nemesis
command_nemesis(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_NEMESIS")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER,"CMD_NEMESIS", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, player)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(player, 0, 1, 0, 0)
	}
}

// Admin Command. zp_respawn
command_respawn(id, player)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %s %L", g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
		case 2: client_print(0, print_chat, "ADMIN %s - %s %L", g_playername[id], g_playername[player], LANG_PLAYER, "CMD_RESPAWN")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %s %L (Players: %d/%d)", g_playername[id], authid, ip, g_playername[player], LANG_SERVER, "CMD_RESPAWN", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Respawn as zombie?
	if (get_pcvar_num(cvar_deathmatch) == 2 || (get_pcvar_num(cvar_deathmatch) == 3 && random_num(0, 1)) || (get_pcvar_num(cvar_deathmatch) == 4 && fnGetZombies() < fnGetAlive()/2))
		g_respawn_as_zombie[player] = true
	
	// Override respawn as zombie setting on nemesis and survivor rounds
	if (g_survround) g_respawn_as_zombie[player] = true
	else if (g_nemround) g_respawn_as_zombie[player] = false
	
	respawn_player_manually(player);
}

// Admin Command. zp_swarm
command_swarm(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_SWARM")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_SWARM")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "ADMIN %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER, "CMD_SWARM", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Swarm Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_SWARM, 0)
}

// Admin Command. zp_multi
command_multi(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "ADMIN - %L", LANG_PLAYER, "CMD_MULTI")
		case 2: client_print(0, print_chat, "ADMIN %s - %L", g_playername[id], LANG_PLAYER, "CMD_MULTI")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "[Anti-Cheat] %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_MULTI", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Multi Infection
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_MULTI, 0)
}

// Admin Command. zp_plague
command_plague(id)
{
	// Show activity?
	switch (get_pcvar_num(cvar_showactivity))
	{
		case 1: client_print(0, print_chat, "[Anti-Cheat] - %L", LANG_PLAYER, "CMD_PLAGUE")
		case 2: client_print(0, print_chat, "[Anti-Cheat] %s - %L", g_playername[id], LANG_PLAYER, "CMD_PLAGUE")
	}
	
	// Log to Zombie Plague log file?
	if (get_pcvar_num(cvar_logcommands))
	{
		static logdata[100], authid[32], ip[16]
		get_user_authid(id, authid, charsmax(authid))
		get_user_ip(id, ip, charsmax(ip), 1)
		formatex(logdata, charsmax(logdata), "[Anti-Cheat] %s <%s><%s> - %L (Players: %d/%d)", g_playername[id], authid, ip, LANG_SERVER,"CMD_PLAGUE", fnGetPlaying(), g_maxplayers)
		log_to_file("zombieplague.log", logdata)
	}
	
	// Call Plague Mode
	remove_task(TASK_MAKEZOMBIE)
	make_a_zombie(MODE_PLAGUE, 0)
}

// Set proper maxspeed for player
set_player_maxspeed(id)
{
	// If frozen, prevent from moving
	if (g_frozen[id])
	{
		set_pev(id, pev_maxspeed, 1.0)
	}
	// Otherwise, set maxspeed directly
	else
	{
		if (g_zombie[id])
		{
			if (g_nemesis[id])
				set_pev(id, pev_maxspeed, get_pcvar_float(cvar_nemspd))
			else
				set_pev(id, pev_maxspeed, g_zombie_spd[id])
		}
		else
		{
			if (g_survivor[id])
				set_pev(id, pev_maxspeed, get_pcvar_float(cvar_survspd))
			else if (get_pcvar_float(cvar_humanspd) > 0.0)
				set_pev(id, pev_maxspeed, get_pcvar_float(cvar_humanspd))
		}
	}
}

/*================================================================================
 [Custom Natives]
=================================================================================*/

// Native: zp_get_user_zombie
public native_get_user_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombie[id];
}

// Native: zp_get_user_nemesis
public native_get_user_nemesis(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_nemesis[id];
}

// Native: zp_get_user_survivor
public native_get_user_survivor(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_survivor[id];
}

public native_get_user_first_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_firstzombie[id];
}

// Native: zp_get_user_last_zombie
public native_get_user_last_zombie(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_lastzombie[id];
}

// Native: zp_get_user_last_human
public native_get_user_last_human(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_lasthuman[id];
}

// Native: zp_get_user_zombie_class
public native_get_user_zombie_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombieclass[id];
}

// Native: zp_get_user_next_class
public native_get_user_next_class(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_zombieclassnext[id];
}

// Native: zp_set_user_zombie_class
public native_set_user_zombie_class(id, classid)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	if (classid < 0 || classid >= g_zclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
		return false;
	}
	
	g_zombieclassnext[id] = classid
	return true;
}

// Native: zp_get_user_ammo_packs
public native_get_user_ammo_packs(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_ammopacks[id];
}

// Native: zp_set_user_ammo_packs
public native_set_user_ammo_packs(id, amount)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	g_ammopacks[id] = amount;
	return true;
}

// Native: zp_get_zombie_maxhealth
public native_get_zombie_maxhealth(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	if (!g_zombie[id] || g_nemesis[id])
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Player not a normal zombie (%d)", id)
		return -1;
	}
	
	if (g_firstzombie[id])
		return floatround(float(ArrayGetCell(g_zclass_hp, g_zombieclass[id])) * get_pcvar_float(cvar_zombiefirsthp));
	
	return ArrayGetCell(g_zclass_hp, g_zombieclass[id]);
}

// Native: zp_get_user_batteries
public native_get_user_batteries(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_flashbattery[id];
}

public native_get_user_resist( id ) {
	if( !is_user_valid( id ) ) {
		return -1;
	}
	
	return resist_human[ id ];
}

// Native: zp_set_user_batteries
public native_set_user_batteries(id, value)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	g_flashbattery[id] = clamp(value, 0, 100);
	
	if (g_cached_customflash)
	{
		// Set the flashlight charge task to update battery status
		remove_task(id+TASK_CHARGE)
		set_task(1.0, "flashlight_charge", id+TASK_CHARGE, _, _, "b")
	}
	return true;
}

// Native: zp_get_user_nightvision
public native_get_user_nightvision(id)
{
	if (!is_user_valid(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return -1;
	}
	
	return g_nvision[id];
}

// Native: zp_set_user_nightvision
public native_set_user_nightvision(id, set)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	if (set)
	{
		g_nvision[id] = true
		
		if (!g_isbot[id])
		{
			g_nvisionenabled[id] = true
			
			// Custom nvg?
			if (get_pcvar_num(cvar_customnvg))
			{
				remove_task(id+TASK_NVISION)
				set_task(0.1, "set_user_nvision", id+TASK_NVISION, _, _, "b")
			}
			else
				set_user_gnvision(id, 1)
		}
		else
			cs_set_user_nvg(id, 1)
	}
	else
	{
		// Remove CS nightvision if player owns one (bugfix)
		cs_set_user_nvg(id, 0)
		
		if (get_pcvar_num(cvar_customnvg)) remove_task(id+TASK_NVISION)
		else if (g_nvisionenabled[id]) set_user_gnvision(id, 0)
		g_nvision[id] = false
		g_nvisionenabled[id] = false
	}
	return true;
}

// Native: zp_infect_user
public native_infect_user(id, infector, silent, rewards)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be zombie
	if (!allowed_zombie(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first zombie
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_INFECTION, id)
	}
	else
	{
		// Just infect (plus some checks)
		zombieme(id, is_user_valid_alive(infector) ? infector : 0, 0, (silent == 1) ? 1 : 0, (rewards == 1) ? 1 : 0)
	}
	return true;
}

// Native: zp_disinfect_user
public native_disinfect_user(id, silent)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be human
	if (!allowed_human(id))
		return false;
	
	// Turn to human
	humanme(id, 0, (silent == 1) ? 1 : 0)
	return true;
}

// Native: zp_make_user_nemesis
public native_make_user_nemesis(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be nemesis
	if (!allowed_nemesis(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first nemesis
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_NEMESIS, id)
	}
	else
	{
		// Turn player into a Nemesis
		zombieme(id, 0, 1, 0, 0)
	}
	return true;
}

// Native: zp_make_user_survivor
public native_make_user_survivor(id)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Not allowed to be survivor
	if (!allowed_survivor(id))
		return false;
	
	// New round?
	if (g_newround)
	{
		// Set as first survivor
		remove_task(TASK_MAKEZOMBIE)
		make_a_zombie(MODE_SURVIVOR, id)
	}
	else
	{
		// Turn player into a Survivor
		humanme(id, 1, 0)
	}
	
	return true;
}

// Native: zp_respawn_user
public native_respawn_user(id, team)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Respawn not allowed
	if (!allowed_respawn(id))
		return false;
	
	// Respawn as zombie?
	g_respawn_as_zombie[id] = (team == ZP_TEAM_ZOMBIE) ? true : false
	
	// Respawnish!
	respawn_player_manually(id)
	return true;
}

// Native: zp_force_buy_extra_item
public native_force_buy_extra_item(id, itemid, ignorecost)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_alive(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	if (itemid < 0 || itemid >= g_extraitem_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid extra item id (%d)", itemid)
		return false;
	}
	
	buy_extra_item(id, itemid, ignorecost)
	return true;
}

// Native: zp_override_user_model
public native_override_user_model(id, const newmodel[], modelindex)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	if (!is_user_valid_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
		return false;
	}
	
	// Strings passed byref
	param_convert(2)
	
	// Remove previous tasks
	remove_task(id+TASK_MODEL)
	
	// Custom models stuff
	static currentmodel[32]
	
	if (g_handle_models_on_separate_ent)
	{
		// Set the right model
		copy(g_playermodel[id], charsmax(g_playermodel[]), newmodel)
		if (g_set_modelindex_offset && modelindex) fm_cs_set_user_model_index(id, modelindex)
		
		// Set model on player model entity
		fm_set_playermodel_ent(id)
	}
	else
	{
		// Get current model for comparing it with the current one
		fm_cs_get_user_model(id, currentmodel, charsmax(currentmodel))
		
		// Set the right model, after checking that we don't already have it
		if (!equal(currentmodel, newmodel))
		{
			copy(g_playermodel[id], charsmax(g_playermodel[]), newmodel)
			if (g_set_modelindex_offset && modelindex) fm_cs_set_user_model_index(id, modelindex)
			
			// An additional delay is offset at round start
			// since SVC_BAD is more likely to be triggered there
			if (g_newround)
				set_task(5.0 * g_modelchange_delay, "fm_user_model_update", id+TASK_MODEL)
			else
				fm_user_model_update(id+TASK_MODEL)
		}
	}
	return true;
}

// Native: zp_has_round_started
public native_has_round_started()
{
	if (g_newround) return 0; // not started
	if (g_modestarted) return 1; // started
	return 2; // starting
}

// Native: zp_is_nemesis_round
public native_is_nemesis_round()
{
	return g_nemround;
}

// Native: zp_is_survivor_round
public native_is_survivor_round()
{
	return g_survround;
}

// Native: zp_is_swarm_round
public native_is_swarm_round()
{
	return g_swarmround;
}

// Native: zp_is_plague_round
public native_is_plague_round()
{
	return g_plagueround;
}

// Native: zp_get_zombie_count
public native_get_zombie_count()
{
	return fnGetZombies();
}

// Native: zp_get_human_count
public native_get_human_count()
{
	return fnGetHumans();
}

// Native: zp_get_nemesis_count
public native_get_nemesis_count()
{
	return fnGetNemesis();
}

// Native: zp_get_survivor_count
public native_get_survivor_count()
{
	return fnGetSurvivors();
}

// Native: zp_register_extra_item
public native_register_extra_item(const name[], cost, team)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Arrays not yet initialized
	if (!g_arrays_created)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register extra item yet (%s)", name)
		return -1;
	}
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register extra item with an empty name")
		return -1;
	}
	
	new index, extraitem_name[32]
	for (index = 0; index < g_extraitem_i; index++)
	{
		ArrayGetString(g_extraitem_name, index, extraitem_name, charsmax(extraitem_name))
		if (equali(name, extraitem_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Extra item already registered (%s)", name)
			return -1;
		}
	}
	
	// For backwards compatibility
	if (team == ZP_TEAM_ANY)
		team = (ZP_TEAM_ZOMBIE|ZP_TEAM_HUMAN)
	
	// Add the item
	ArrayPushString(g_extraitem_name, name)
	ArrayPushCell(g_extraitem_cost, cost)
	ArrayPushCell(g_extraitem_team, team)
	
	// Set temporary new item flag
	ArrayPushCell(g_extraitem_new, 1)
	
	// Override extra items data with our customizations
	new i, buffer[32], size = ArraySize(g_extraitem2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_extraitem2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended item to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new item flag
		ArraySetCell(g_extraitem_new, g_extraitem_i, 0)
		
		// Replace caption
		ArrayGetString(g_extraitem2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_extraitem_name, g_extraitem_i, buffer)
		
		// Replace cost
		buffer[0] = ArrayGetCell(g_extraitem2_cost, i)
		ArraySetCell(g_extraitem_cost, g_extraitem_i, buffer[0])
		
		// Replace team
		buffer[0] = ArrayGetCell(g_extraitem2_team, i)
		ArraySetCell(g_extraitem_team, g_extraitem_i, buffer[0])
	}
	
	// Increase registered items counter
	g_extraitem_i++
	
	// Return id under which we registered the item
	return g_extraitem_i-1;
}

// Function: zp_register_extra_item (to be used within this plugin only)
native_register_extra_item2(const name[], cost, team)
{
	// Add the item
	ArrayPushString(g_extraitem_name, name)
	ArrayPushCell(g_extraitem_cost, cost)
	ArrayPushCell(g_extraitem_team, team)
	
	// Set temporary new item flag
	ArrayPushCell(g_extraitem_new, 1)
	
	// Increase registered items counter
	g_extraitem_i++
}

// Native: zp_register_zombie_class
public native_register_zombie_class(const name[], const info[], const model[], const clawmodel[], hp, speed, Float:gravity, Float:knockback)
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	param_convert(2)
	param_convert(3)
	param_convert(4)
	
	// Arrays not yet initialized
	if (!g_arrays_created)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register zombie class yet (%s)", name)
		return -1;
	}
	
	if (strlen(name) < 1)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Can't register zombie class with an empty name")
		return -1;
	}
	
	new index, zombieclass_name[32]
	for (index = 0; index < g_zclass_i; index++)
	{
		ArrayGetString(g_zclass_name, index, zombieclass_name, charsmax(zombieclass_name))
		if (equali(name, zombieclass_name))
		{
			log_error(AMX_ERR_NATIVE, "[ZP] Zombie class already registered (%s)", name)
			return -1;
		}
	}
	
	// Add the class
	ArrayPushString(g_zclass_name, name)
	ArrayPushString(g_zclass_info, info)
	
	// Using same zombie models for all classes?
	if (g_same_models_for_all)
	{
		ArrayPushCell(g_zclass_modelsstart, 0)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
	}
	else
	{
		ArrayPushCell(g_zclass_modelsstart, ArraySize(g_zclass_playermodel))
		ArrayPushString(g_zclass_playermodel, model)
		ArrayPushCell(g_zclass_modelsend, ArraySize(g_zclass_playermodel))
		ArrayPushCell(g_zclass_modelindex, -1)
	}
	
	ArrayPushString(g_zclass_clawmodel, clawmodel)
	ArrayPushCell(g_zclass_hp, hp)
	ArrayPushCell(g_zclass_spd, speed)
	ArrayPushCell(g_zclass_grav, gravity)
	ArrayPushCell(g_zclass_kb, knockback)
	
	// Set temporary new class flag
	ArrayPushCell(g_zclass_new, 1)
	
	// Override zombie classes data with our customizations
	new i, k, buffer[32], Float:buffer2, nummodels_custom, nummodels_default, prec_mdl[100], size = ArraySize(g_zclass2_realname)
	for (i = 0; i < size; i++)
	{
		ArrayGetString(g_zclass2_realname, i, buffer, charsmax(buffer))
		
		// Check if this is the intended class to override
		if (!equal(name, buffer))
			continue;
		
		// Remove new class flag
		ArraySetCell(g_zclass_new, g_zclass_i, 0)
		
		// Replace caption
		ArrayGetString(g_zclass2_name, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_name, g_zclass_i, buffer)
		
		// Replace info
		ArrayGetString(g_zclass2_info, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_info, g_zclass_i, buffer)
		
		// Replace models, unless using same models for all classes
		if (!g_same_models_for_all)
		{
			nummodels_custom = ArrayGetCell(g_zclass2_modelsend, i) - ArrayGetCell(g_zclass2_modelsstart, i)
			nummodels_default = ArrayGetCell(g_zclass_modelsend, g_zclass_i) - ArrayGetCell(g_zclass_modelsstart, g_zclass_i)
			
			// Replace each player model and model index
			for (k = 0; k < min(nummodels_custom, nummodels_default); k++)
			{
				ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
				ArraySetString(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, buffer)
				
				// Precache player model and replace its modelindex with the real one
				formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
				ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k, engfunc(EngFunc_PrecacheModel, prec_mdl))
				if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
				if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
				// Precache modelT.mdl files too
				copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
				if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
			}
			
			// We have more custom models than what we can accommodate,
			// Let's make some space...
			if (nummodels_custom > nummodels_default)
			{
				for (k = nummodels_default; k < nummodels_custom; k++)
				{
					ArrayGetString(g_zclass2_playermodel, ArrayGetCell(g_zclass2_modelsstart, i) + k, buffer, charsmax(buffer))
					ArrayInsertStringAfter(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, buffer)
					
					// Precache player model and retrieve its modelindex
					formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", buffer, buffer)
					ArrayInsertCellAfter(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + k - 1, engfunc(EngFunc_PrecacheModel, prec_mdl))
					if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
					if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
					// Precache modelT.mdl files too
					copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
					if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) + (nummodels_custom - nummodels_default))
			}
			
			/* --- Not needed since classes can't have more than 1 default model for now ---
			// We have less custom models than what this class has by default,
			// Get rid of those extra entries...
			if (nummodels_custom < nummodels_default)
			{
				for (k = nummodels_custom; k < nummodels_default; k++)
				{
					ArrayDeleteItem(g_zclass_playermodel, ArrayGetCell(g_zclass_modelsstart, g_zclass_i) + nummodels_custom)
				}
				
				// Fix models end index for this class
				ArraySetCell(g_zclass_modelsend, g_zclass_i, ArrayGetCell(g_zclass_modelsend, g_zclass_i) - (nummodels_default - nummodels_custom))
			}
			*/
		}
		
		// Replace clawmodel
		ArrayGetString(g_zclass2_clawmodel, i, buffer, charsmax(buffer))
		ArraySetString(g_zclass_clawmodel, g_zclass_i, buffer)
		
		// Precache clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/zombie_plague/%s", buffer)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
		
		// Replace health
		buffer[0] = ArrayGetCell(g_zclass2_hp, i)
		ArraySetCell(g_zclass_hp, g_zclass_i, buffer[0])
		
		// Replace speed
		buffer[0] = ArrayGetCell(g_zclass2_spd, i)
		ArraySetCell(g_zclass_spd, g_zclass_i, buffer[0])
		
		// Replace gravity
		buffer2 = Float:ArrayGetCell(g_zclass2_grav, i)
		ArraySetCell(g_zclass_grav, g_zclass_i, buffer2)
		
		// Replace knockback
		buffer2 = Float:ArrayGetCell(g_zclass2_kb, i)
		ArraySetCell(g_zclass_kb, g_zclass_i, buffer2)
	}
	
	// If class was not overriden with customization data
	if (ArrayGetCell(g_zclass_new, g_zclass_i))
	{
		// If not using same models for all classes
		if (!g_same_models_for_all)
		{
			// Precache default class model and replace modelindex with the real one
			formatex(prec_mdl, charsmax(prec_mdl), "models/player/%s/%s.mdl", model, model)
			ArraySetCell(g_zclass_modelindex, ArrayGetCell(g_zclass_modelsstart, g_zclass_i), engfunc(EngFunc_PrecacheModel, prec_mdl))
			if (g_force_consistency == 1) force_unmodified(force_model_samebounds, {0,0,0}, {0,0,0}, prec_mdl)
			if (g_force_consistency == 2) force_unmodified(force_exactfile, {0,0,0}, {0,0,0}, prec_mdl)
			// Precache modelT.mdl files too
			copy(prec_mdl[strlen(prec_mdl)-4], charsmax(prec_mdl) - (strlen(prec_mdl)-4), "T.mdl")
			if (file_exists(prec_mdl)) engfunc(EngFunc_PrecacheModel, prec_mdl)
		}
		
		// Precache default clawmodel
		formatex(prec_mdl, charsmax(prec_mdl), "models/zombie_plague/%s", clawmodel)
		engfunc(EngFunc_PrecacheModel, prec_mdl)
	}
	
	// Increase registered classes counter
	g_zclass_i++
	
	// Return id under which we registered the class
	return g_zclass_i-1;
}

// Native: zp_get_extra_item_id
public native_get_extra_item_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every item (not using Tries since ZP should work on AMXX 1.8.0)
	static i, item_name[32]
	for (i = 0; i < g_extraitem_i; i++)
	{
		ArrayGetString(g_extraitem_name, i, item_name, charsmax(item_name))
		
		// Check if this is the item to retrieve
		if (equali(name, item_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_zombie_class_id
public native_get_zombie_class_id(const name[])
{
	// ZP disabled
	if (!g_pluginenabled)
		return -1;
	
	// Strings passed byref
	param_convert(1)
	
	// Loop through every class (not using Tries since ZP should work on AMXX 1.8.0)
	static i, class_name[32]
	for (i = 0; i < g_zclass_i; i++)
	{
		ArrayGetString(g_zclass_name, i, class_name, charsmax(class_name))
		
		// Check if this is the class to retrieve
		if (equali(name, class_name))
			return i;
	}
	
	return -1;
}

// Native: zp_get_zombie_class_info
public native_get_zombie_class_info(classid, info[], len)
{
	// ZP disabled
	if (!g_pluginenabled)
		return false;
	
	// Invalid class
	if (classid < 0 || classid >= g_zclass_i)
	{
		log_error(AMX_ERR_NATIVE, "[ZP] Invalid zombie class id (%d)", classid)
		return false;
	}
	
	// Strings passed byref
	param_convert(2)
	
	// Fetch zombie class info
	ArrayGetString(g_zclass_info, classid, info, len)
	return true;
}

/*================================================================================
 [Custom Messages]
=================================================================================*/

// Custom Night Vision
public set_user_nvision(taskid)
{
	// Get player's origin
	static origin[3]
	get_user_origin(ID_NVISION, origin)
	
	// Nightvision message
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_NVISION)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(get_pcvar_num(cvar_nvgsize)) // radius
	
	// Nemesis / Madness / Spectator in nemesis round
	if (g_nemesis[ID_NVISION] || (g_zombie[ID_NVISION] && g_nodamage[ID_NVISION]) || (!g_isalive[ID_NVISION] && g_nemround))
	{
		write_byte(get_pcvar_num(cvar_nemnvgcolor[0])) // r
		write_byte(get_pcvar_num(cvar_nemnvgcolor[1])) // g
		write_byte(get_pcvar_num(cvar_nemnvgcolor[2])) // b
	}
	// Human / Spectator in normal round
	else if (!g_zombie[ID_NVISION] || !g_isalive[ID_NVISION])
	{
		write_byte(get_pcvar_num(cvar_humnvgcolor[0])) // r
		write_byte(get_pcvar_num(cvar_humnvgcolor[1])) // g
		write_byte(get_pcvar_num(cvar_humnvgcolor[2])) // b
	}
	// Zombie
	else
	{
		write_byte(get_pcvar_num(cvar_nvgcolor[0])) // r
		write_byte(get_pcvar_num(cvar_nvgcolor[1])) // g
		write_byte(get_pcvar_num(cvar_nvgcolor[2])) // b
	}
	
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

// Game Nightvision
set_user_gnvision(id, toggle)
{
	// Toggle NVG message
	message_begin(MSG_ONE, g_msgNVGToggle, _, id)
	write_byte(toggle) // toggle
	message_end()
}

// Custom Flashlight
public set_user_flashlight(taskid)
{
	// Get player and aiming origins
	static Float:originF[3], Float:destoriginF[3]
	pev(ID_FLASH, pev_origin, originF)
	fm_get_aim_origin(ID_FLASH, destoriginF)
	
	// Max distance check
	if (get_distance_f(originF, destoriginF) > get_pcvar_float(cvar_flashdist))
		return;
	
	// Send to all players?
	if (get_pcvar_num(cvar_flashshowall))
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, destoriginF, 0)
	else
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, ID_FLASH)
	
	// Flashlight
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, destoriginF[0]) // x
	engfunc(EngFunc_WriteCoord, destoriginF[1]) // y
	engfunc(EngFunc_WriteCoord, destoriginF[2]) // z
	write_byte(get_pcvar_num(cvar_flashsize)) // radius
	write_byte(get_pcvar_num(cvar_flashcolor[0])) // r
	write_byte(get_pcvar_num(cvar_flashcolor[1])) // g
	write_byte(get_pcvar_num(cvar_flashcolor[2])) // b
	write_byte(3) // life
	write_byte(0) // decay rate
	message_end()
}

// Infection special effects
infection_effects(id)
{
	// Screen fade? (unless frozen)
	if (!g_frozen[id] && get_pcvar_num(cvar_infectionscreenfade))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		if (g_nemesis[id])
		{
			write_byte(get_pcvar_num(cvar_nemnvgcolor[0])) // r
			write_byte(get_pcvar_num(cvar_nemnvgcolor[1])) // g
			write_byte(get_pcvar_num(cvar_nemnvgcolor[2])) // b
		}
		else
		{
			write_byte(get_pcvar_num(cvar_nvgcolor[0])) // r
			write_byte(get_pcvar_num(cvar_nvgcolor[1])) // g
			write_byte(get_pcvar_num(cvar_nvgcolor[2])) // b
		}
		write_byte (255) // alpha
		message_end()
	}
	
	// Screen shake?
	if (get_pcvar_num(cvar_infectionscreenshake))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
		write_short(UNIT_SECOND*4) // amplitude
		write_short(UNIT_SECOND*2) // duration
		write_short(UNIT_SECOND*10) // frequency
		message_end()
	}
	
	// Infection icon?
	if (get_pcvar_num(cvar_hudicons))
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
		write_byte(0) // damage save
		write_byte(0) // damage take
		write_long(DMG_NERVEGAS) // damage type - DMG_RADIATION
		write_coord(0) // x
		write_coord(0) // y
		write_coord(0) // z
		message_end()
	}
	
	// Get player's origin
	static origin[3]
	get_user_origin(id, origin)
	
	// Tracers?
	if (get_pcvar_num(cvar_infectiontracers))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_IMPLOSION) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(128) // radius
		write_byte(20) // count
		write_byte(3) // duration
		message_end()
	}
	
	// Particle burst?
	if (get_pcvar_num(cvar_infectionparticles))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_PARTICLEBURST) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_short(50) // radius
		write_byte(70) // color
		write_byte(3) // duration (will be randomized a bit)
		message_end()
	}
	
	// Light sparkle?
	if (get_pcvar_num(cvar_infectionsparkle))
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_DLIGHT) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]) // z
		write_byte(20) // radius
		write_byte(get_pcvar_num(cvar_nvgcolor[0])) // r
		write_byte(get_pcvar_num(cvar_nvgcolor[1])) // g
		write_byte(get_pcvar_num(cvar_nvgcolor[2])) // b
		write_byte(2) // life
		write_byte(0) // decay rate
		message_end()
	}
}

// Nemesis/madness aura task
public zombie_aura(taskid)
{
	// Not nemesis, not in zombie madness
	if (!g_nemesis[ID_AURA] && !g_nodamage[ID_AURA])
	{
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	// Get player's origin
	static origin[3]
	get_user_origin(ID_AURA, origin)
	
	if( !g_firstzombie[ ID_AURA ] )
	{
		set_user_rendering( ID_AURA, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 15 );
		set_task( 4.9, "remove_aura", ID_AURA );
	}
	// Colored Aura
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_DLIGHT) // TE id
	write_coord(origin[0]) // x
	write_coord(origin[1]) // y
	write_coord(origin[2]) // z
	write_byte(20) // radius
	write_byte(get_pcvar_num(cvar_nemnvgcolor[0])) // r
	write_byte(get_pcvar_num(cvar_nemnvgcolor[1])) // g
	write_byte(get_pcvar_num(cvar_nemnvgcolor[2])) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
}

public remove_aura( id )
	set_user_rendering( id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 10 );

// Make zombies leave footsteps and bloodstains on the floor
public make_blood(taskid)
{
	// Only bleed when moving on ground
	if (!(pev(ID_BLOOD, pev_flags) & FL_ONGROUND) || fm_get_speed(ID_BLOOD) < 80)
		return;
	
	// Get user origin
	static Float:originF[3]
	pev(ID_BLOOD, pev_origin, originF)
	
	// If ducking set a little lower
	if (pev(ID_BLOOD, pev_bInDuck))
		originF[2] -= 18.0
	else
		originF[2] -= 36.0
	
	// Send the decal message
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_WORLDDECAL) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(ArrayGetCell(zombie_decals, random_num(0, ArraySize(zombie_decals) - 1)) + (g_czero * 12)) // random decal number (offsets +12 for CZ)
	message_end()
}

// Flare Lighting Effects
flare_lighting(entity, duration)
{
	// Get origin and color
	static Float:originF[3], color[3]
	pev(entity, pev_origin, originF)
	pev(entity, PEV_FLARE_COLOR, color)
	
	// Lighting
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(get_pcvar_num(cvar_flaresize)) // radius
	write_byte(color[0]) // r
	write_byte(color[1]) // g
	write_byte(color[2]) // b
	write_byte(21) //life
	write_byte((duration < 2) ? 3 : 0) //decay rate
	message_end()
	
	// Sparks
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPARKS) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	message_end()
}

// Burning Flames
public burning_flame(taskid)
{
	// Get player origin and flags
	static origin[3], flags
	get_user_origin(ID_BURN, origin)
	flags = pev(ID_BURN, pev_flags)
	
	// Madness mode - in water - burning stopped
	if (g_nodamage[ID_BURN] || (flags & FL_INWATER) || g_burning_duration[ID_BURN] < 1)
	{
		// Smoke sprite
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE) // TE id
		write_coord(origin[0]) // x
		write_coord(origin[1]) // y
		write_coord(origin[2]-50) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end();
		
		// Task not needed anymore
		remove_task(taskid);
		return;
	}
	
	// Randomly play burning zombie scream sounds (not for nemesis and first zombie)
	if (!g_firstzombie[ID_BURN] && !g_nemesis[ID_BURN] && !random_num(0, 20))
	{
		static sound[64]
		ArrayGetString(grenade_fire_player, random_num(0, ArraySize(grenade_fire_player) - 1), sound, charsmax(sound))
		emit_sound(ID_BURN, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	// Fire slow down, unless nemesis
	if (!g_firstzombie[ID_BURN] && !g_nemesis[ID_BURN] && (flags & FL_ONGROUND) && get_pcvar_float(cvar_fireslowdown) > 0.0)
	{
		static Float:velocity[3]
		pev(ID_BURN, pev_velocity, velocity)
		xs_vec_mul_scalar(velocity, get_pcvar_float(cvar_fireslowdown), velocity)
		set_pev(ID_BURN, pev_velocity, velocity)
	}
	
	// Get player's health
	static health
	health = pev(ID_BURN, pev_health)
	
	// Take damage from the fire
	if (health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil) > 0)
		fm_set_user_health(ID_BURN, health - floatround(get_pcvar_float(cvar_firedamage), floatround_ceil))
	
	// Flame sprite
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) // TE id
	write_coord(origin[0]+random_num(-5, 5)) // x
	write_coord(origin[1]+random_num(-5, 5)) // y
	write_coord(origin[2]+random_num(-10, 10)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease burning duration counter
	g_burning_duration[ID_BURN]--
}

// Infection Bomb: Green Blast
create_blast(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(200) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Fire Grenade: Fire Blast
create_blast2(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(100) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(50) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(200) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Frost Grenade: Freeze Blast
create_blast3(const Float:originF[3])
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(100) // green
	write_byte(200) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}

// Fix Dead Attrib on scoreboard
FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

// Send Death Message for infections
SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(1) // headshot flag
	write_string("infection") // killer's weapon
	message_end()
}

// Update Player Frags and Deaths
UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(victim)) // team
		message_end()
	}
}

// Remove Player Frags (when Nemesis/Survivor ignore_frags cvar is enabled)
RemoveFrags(attacker, victim)
{
	// Remove attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) - 1))
	
	// Remove victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) - 1)
}

// Plays a sound on clients
PlaySound(const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(0, "spk ^"%s^"", sound)
}

// Prints a colored message to target (use 0 for everyone), supports ML formatting.
// Note: I still need to make something like gungame's LANG_PLAYER_C to avoid unintended
// argument replacement when a function passes -1 (it will be considered a LANG_PLAYER)
zp_colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	// Send to everyone
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			// Not connected
			if (!g_isconnected[player])
				continue;
			
			// Remember changed arguments
			static changed[5], changedcount // [5] = max LANG_PLAYER occurencies
			changedcount = 0
			
			// Replace LANG_PLAYER with player id
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			// Format message for player
			vformat(buffer, charsmax(buffer), message, 3)
			
			// Send it
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			// Replace back player id's with LANG_PLAYER
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	// Send to specific target
	else
	{
		/*
		// Not needed since you should set the ML argument
		// to the player's id for a targeted print message
		
		// Replace LANG_PLAYER with player id
		for (i = 2; i < argscount; i++)
		{
			if (getarg(i) == LANG_PLAYER)
				setarg(i, 0, target)
		}
		*/
		
		// Format message for player
		vformat(buffer, charsmax(buffer), message, 3)
		
		// Send it
		message_begin(MSG_ONE, g_msgSayText, _, target)
		write_byte(target)
		write_string(buffer)
		message_end()
	}
}

/*================================================================================
 [Stocks]
=================================================================================*/

// Set an entity's key value (from fakemeta_util)
stock fm_set_kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

// Set entity's rendering type (from fakemeta_util)
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

// Get entity's speed (from fakemeta_util)
stock fm_get_speed(entity)
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	
	return floatround(vector_length(velocity));
}

// Get entity's aim origins (from fakemeta_util)
stock fm_get_aim_origin(id, Float:origin[3])
{
	static Float:origin1F[3], Float:origin2F[3]
	pev(id, pev_origin, origin1F)
	pev(id, pev_view_ofs, origin2F)
	xs_vec_add(origin1F, origin2F, origin1F)

	pev(id, pev_v_angle, origin2F);
	engfunc(EngFunc_MakeVectors, origin2F)
	global_get(glb_v_forward, origin2F)
	xs_vec_mul_scalar(origin2F, 9999.0, origin2F)
	xs_vec_add(origin1F, origin2F, origin2F)

	engfunc(EngFunc_TraceLine, origin1F, origin2F, 0, id, 0)
	get_tr2(0, TR_vecEndPos, origin)
}

// Find entity by its owner (from fakemeta_util)
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

// Set player's health (from fakemeta_util)
stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

// Give an item to a player (from fakemeta_util)
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
}

// Strip user weapons (from fakemeta_util)
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}

// Collect random spawn points
stock load_spawns()
{
	// Check for CSDM spawns of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "%s/csdm/%s.spawns.cfg", cfgdir, mapname)
	
	// Load CSDM spawns if present
	if (file_exists(filepath))
	{
		new csdmdata[10][6], file = fopen(filepath,"rt")
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			
			// origin
			g_spawns[g_spawnCount][0] = floatstr(csdmdata[0])
			g_spawns[g_spawnCount][1] = floatstr(csdmdata[1])
			g_spawns[g_spawnCount][2] = floatstr(csdmdata[2])
			
			// increase spawn count
			g_spawnCount++
			if (g_spawnCount >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}
	else
	{
		// Collect regular spawns
		collect_spawns_ent("info_player_start")
		collect_spawns_ent("info_player_deathmatch")
	}
	
	// Collect regular spawns for non-random spawning unstuck
	collect_spawns_ent2("info_player_start")
	collect_spawns_ent2("info_player_deathmatch")
}

// Collect spawn points from entity origins
stock collect_spawns_ent(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns[g_spawnCount][0] = originF[0]
		g_spawns[g_spawnCount][1] = originF[1]
		g_spawns[g_spawnCount][2] = originF[2]
		
		// increase spawn count
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}

// Collect spawn points from entity origins
stock collect_spawns_ent2(const classname[])
{
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) != 0)
	{
		// get origin
		new Float:originF[3]
		pev(ent, pev_origin, originF)
		g_spawns2[g_spawnCount2][0] = originF[0]
		g_spawns2[g_spawnCount2][1] = originF[1]
		g_spawns2[g_spawnCount2][2] = originF[2]
		
		// increase spawn count
		g_spawnCount2++
		if (g_spawnCount2 >= sizeof g_spawns2) break;
	}
}

// Drop primary/secondary weapons
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}

stock ColorChat(const id, const input[], any:...) 
{
    new count = 1, players[ 32 ]
    static msg[ 191 ]
    vformat( msg, 190, input, 3 )
    
    replace_all( msg, 190, "!g", "^4" )
    replace_all( msg, 190, "!y", "^1" )
    replace_all( msg, 190, "!t", "^3" )

    if(id) players[ 0 ] = id; else get_players( players, count, "ch" )
    {
        for(new i = 0; i < count; i++)
        {
            if( is_user_connected( players[ i ] ) )
            {
                message_begin( MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[ i ] )  
                write_byte( players[ i ] )
                write_string( msg )
                message_end( )
            }
        }
    }
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

// Checks if a space is vacant (credits to VEN)
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Check if a player is stuck (credits to VEN)
stock is_player_stuck(id)
{
	static Float:originF[3]
	pev(id, pev_origin, originF)
	
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

// Simplified get_weaponid (CS only)
stock cs_weapon_name_to_id(const weapon[])
{
	static i
	for (i = 0; i < sizeof WEAPONENTNAMES; i++)
	{
		if (equal(weapon, WEAPONENTNAMES[i]))
			return i;
	}
	
	return 0;
}

// Get User Current Weapon Entity
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}

// Get Weapon Entity's Owner
stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

// Set User Deaths
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}

// Get User Team
stock fm_cs_get_user_team(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return FM_CS_TEAM_UNASSIGNED;
	
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

// Set a Player's Team
stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}

// Set User Money
stock fm_cs_set_user_money(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSMONEY, value, OFFSET_LINUX)
}

// Set User Flashlight Batteries
stock fm_cs_set_user_batteries(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, value, OFFSET_LINUX)
}

// Update Player's Team on all clients (adding needed delays)
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}

// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	// Note to self: this next message can now be received by other plugins
	
	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_msgTeamInfo)
	ewrite_byte(ID_TEAM) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(ID_TEAM)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}

// Set the precached model index (updates hitboxes server side)
stock fm_cs_set_user_model_index(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
}

// Set Player Model on Entity
stock fm_set_playermodel_ent(id)
{
	// Make original player entity invisible without hiding shadows or firing effects
	fm_set_rendering(id, kRenderFxNone, 255, 255, 255, kRenderTransTexture, 1)
	
	// Format model string
	static model[100]
	formatex(model, charsmax(model), "models/player/%s/%s.mdl", g_playermodel[id], g_playermodel[id])
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_playermodel[id]))
	{
		g_ent_playermodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_playermodel[id])) return;
		
		set_pev(g_ent_playermodel[id], pev_classname, MODEL_ENT_CLASSNAME)
		set_pev(g_ent_playermodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_playermodel[id], pev_aiment, id)
		set_pev(g_ent_playermodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_playermodel[id], model)
}

// Set Weapon Model on Entity
stock fm_set_weaponmodel_ent(id)
{
	// Get player's p_ weapon model
	static model[100]
	pev(id, pev_weaponmodel2, model, charsmax(model))
	
	// Set model on entity or make a new one if unexistant
	if (!pev_valid(g_ent_weaponmodel[id]))
	{
		g_ent_weaponmodel[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if (!pev_valid(g_ent_weaponmodel[id])) return;
		
		set_pev(g_ent_weaponmodel[id], pev_classname, WEAPON_ENT_CLASSNAME)
		set_pev(g_ent_weaponmodel[id], pev_movetype, MOVETYPE_FOLLOW)
		set_pev(g_ent_weaponmodel[id], pev_aiment, id)
		set_pev(g_ent_weaponmodel[id], pev_owner, id)
	}
	
	engfunc(EngFunc_SetModel, g_ent_weaponmodel[id], model)
}

// Remove Custom Model Entities
stock fm_remove_model_ents(id)
{
	// Remove "playermodel" ent if present
	if (pev_valid(g_ent_playermodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_playermodel[id])
		g_ent_playermodel[id] = 0
	}
	// Remove "weaponmodel" ent if present
	if (pev_valid(g_ent_weaponmodel[id]))
	{
		engfunc(EngFunc_RemoveEntity, g_ent_weaponmodel[id])
		g_ent_weaponmodel[id] = 0
	}
}

// Set User Model
public fm_cs_set_user_model(taskid)
{
	set_user_info(ID_MODEL, "model", g_playermodel[ID_MODEL])
}

// Get User Model -model passed byref-
stock fm_cs_get_user_model(player, model[], len)
{
	get_user_info(player, "model", model, len)
}

// Update Player's Model on all clients (adding needed delays)
public fm_user_model_update(taskid)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_models_targettime >= g_modelchange_delay)
	{
		fm_cs_set_user_model(taskid)
		g_models_targettime = current_time
	}
	else
	{
		set_task((g_models_targettime + g_modelchange_delay) - current_time, "fm_cs_set_user_model", taskid)
		g_models_targettime = g_models_targettime + g_modelchange_delay
	}
}

public Task_ShowHealth(id)
{
	id -= TASK_HEALTH
	
	if (!g_lasthuman[id]) {
		last_human = 0;
		remove_task(id+TASK_HEALTH)
	}
	
	if( is_entity_moving(id) )
	{
		set_dhudmessage( 45, 45, 165, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0, -1 );
		show_dhudmessage(0,"Posledny clovek ma zvysene zivoty a power damage")
	} else {
		set_dhudmessage( 45, 45, 165, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0, -1 );
		show_dhudmessage(0,"Posledny clovek ma zvysene zivoty")
	}
}

public vybrat_zbran(taskid)
{
	static id
	(taskid > g_maxplayers) ? (id = ID_SPAWN) : (id = taskid);

	if( !g_zombie[id] )
	{
		if(is_user_alive(id))
		{
			if(zbrane[id] == 0)
			{
				new szMenuBody[1024] 
				new keys 
				
				new nLen = format( szMenuBody, 1023, "\yVyber primarni zbrane 1/2:^n" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r1. \wM4A1^t^t^t^t^t^t^t^t^t^t^t^t^t^t \r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r2. \yCartBlue^t^t^t^t^t^t^t^t \r5700$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r3. \wAK47^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r4. \yAK Long^t^t^t^t^t^t^t^t^t\r5800$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r5. \wXM1014^t^t^t^t^t^t^t^t^t^t^t^t \r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r6. \yDmp 7A1^t^t^t^t^t^t^t^t\r8500$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r7. \wP90^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n^n\d8. Zpet" )
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r9. \wDalsie" )
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r0. \wExit" )
				
				keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
				
				show_menu( id, keys, szMenuBody, -1 ) 
			}
		}
	}
	return PLUGIN_CONTINUE
}

public handle_zbrane(id, key) 
{
	if( g_survivor[id] ) {
		ChatColor( id, "!g[ZP]!y Ked si vyvoleny nemozes si vybrat zbrane!" );
		return PLUGIN_HANDLED;
	}
	if( have_user_hannibal( id ) ) {
		ChatColor( id, "!g[ZP]!y Ked si hannibal nemozes si vybrat zbrane!" );
		return PLUGIN_HANDLED;
	}
	
	if (!g_zombie[id] )
	{
		
		switch( key ) 
		{
			
			case 0:
			{
				new cur_money,cena,new_money;
				cena = 0;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						give_item(id,"weapon_m4a1");
					}
					buyammo(id)
					buyammo(id)
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 1:
			{
				new cur_money,cena,new_money;
				cena = 5700;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						get_cartblue(id)
					}
					buyammo(id)
					buyammo(id)
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 2:
			{
				new cur_money,cena,new_money;
				cena = 0;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else { 
						strip_user_weapons(id)
						give_item(id, "weapon_ak47");
					}
					buyammo(id)
					buyammo(id)
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 3:
			{
				new cur_money,cena,new_money;
				cena = 5800;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						get_ak47long(id)
					}
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 4:
			{
				new cur_money,cena,new_money;
				cena = 0;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						give_item( id, "weapon_xm1014" );
					}
					buyammo(id)
					buyammo(id)
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 5:
			{
				new cur_money,cena,new_money;
				cena = 8500;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						get_dmp7a1(id)
					}
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 6:
			{
				new cur_money,cena,new_money;
				cena = 0;
				cur_money = cs_get_user_money(id);
				
				if(cur_money >= cena)
				{
					strip_user_weapons(id)
					give_item(id,"weapon_p90")
					if(minigun_human[id])
					{
						ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
						get_minigun(id)
					} else {
						strip_user_weapons(id)
						give_item(id,"weapon_p90")
					}
					buyammo(id)
					buyammo(id)
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
					give_item(id,"weapon_hegrenade")
					give_item(id,"weapon_flashbang")
					give_item(id,"weapon_knife")
					new_money = cur_money - cena;
					cs_set_user_money(id,new_money);
					zbrane[id] = 1
					pistole(id)
				}
				else
				{
					vybrat_zbran(id)
					client_print(id, print_center, "Nemas dostatok peniazi!")
				}
			}
			case 7: vybrat_zbran(id)
				case 8: vybrat_zbran2(id)
				case 9: return PLUGIN_HANDLED 
			}
	}
	
	return PLUGIN_HANDLED 
}

public vybrat_zbran2(taskid)
{
	static id
	(taskid > g_maxplayers) ? (id = ID_SPAWN) : (id = taskid)
	if (!g_zombie[id] || g_survivor[id])
	{
		if(is_user_alive(id))
		{
			if(zbrane[id] == 0)
			{
				new szMenuBody[1024] 
				new keys 
				
				new nLen = format( szMenuBody, 1023, "\yVyber primarni zbrane 2/2:^n" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r1. \wAUG^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" )
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r2. \yXM8 Basic^t^t^t^t^t^t^t^t \r6300$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r3. \wFamas^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r4. \yUSAS12 Camo^t^t^t^t^t\r5600$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r5. \wMP5^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r6. \yThompson-50^t^t^t^t^t\r4900$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r7. \wM3^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$" ) 
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n^n\r8. \wZpet" )
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\d9. Dalsie" )
				nLen += format( szMenuBody[nLen], 1023-nLen, "^n\r0. \wExit" )
				
				keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
				
				show_menu( id, keys, szMenuBody, -1 ) 
			}
		}
	}
	return PLUGIN_CONTINUE
}

public handle_zbrane2(id, key) 
{
	if( g_survivor[id] )
		return PLUGIN_HANDLED;
		
	if (!g_zombie[id] || g_survivor[id])
	{
	
	switch( key ) 
	{
		case 0:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);
			
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					give_item(id,"weapon_aug")
				}
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 1:
		{
			new cur_money,cena,new_money;
			cena = 6300;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					get_xm8(id)
				}
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 2:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);
			
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					give_item(id,"weapon_famas")
				}
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				emit_sound(id, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 3:
		{
			new cur_money,cena,new_money;
			cena = 5600;
			cur_money = cs_get_user_money(id);
			
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					get_uscamo(id)
				}
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 4:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);
			
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					give_item(id,"weapon_mp5navy")
				}
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 5:
		{
			new cur_money,cena,new_money;
			cena = 4900;
			cur_money = cs_get_user_money(id);
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					get_thompson(id)
				}
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				emit_sound(id, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 6:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);
			if(cur_money >= cena)
			{
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				} else {
					strip_user_weapons(id)
					give_item(id,"weapon_m3")
				}
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				give_item(id,"weapon_hegrenade")
				give_item(id,"weapon_flashbang")
				give_item(id,"weapon_knife")
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				emit_sound(id, CHAN_WEAPON, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				pistole(id)
			}
			else
			{
				vybrat_zbran2(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		case 7: vybrat_zbran(id);
		case 8: vybrat_zbran2(id)
		case 9: return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_HANDLED 
}

public pistole(id)
{
	new hPrim = menu_create("\yVyber Sekundarnej zbrane:", "pistole_handle")
	menu_additem(hPrim, "\wGlock18^t^t^t^t^t^t^t^t^t^t^t^t^t^t\r0$", "1", 0)
	menu_additem(hPrim, "\wUSP pistol^t^t^t^t^t^t^t^t^t^t^t^t \r0$", "2", 0)
	menu_additem(hPrim, "\wFive-SeveN^t^t^t^t^t^t^t^t^t^t^t\r0$", "3", 0)
	menu_additem(hPrim, "\yDual Infinity^t^t^t^t^t^t^t\r2600$", "4", 0)
	menu_additem(hPrim, "\wDesert Eagle^t^t^t^t^t^t^t^t^t^t\r0$", "5", 0)
	menu_additem(hPrim, "\ySoul Skull1^t^t^t^t^t^t^t^t\r2800$", "6", 0)
	menu_additem(hPrim, "\wDual-Elite^t^t^t^t^t^t^t^t^t^t^t^t \r0$^n\dMenu sa zavrie ak si^nvyberes nejaku pistol!", "7", 0)
	
	menu_setprop(hPrim, MPROP_PERPAGE, 0)
	menu_display(id, hPrim, 0)
	
	return PLUGIN_HANDLED
}

public pistole_handle(id, hMenu, iItem)
{
	if( iItem == MENU_EXIT || !is_user_alive(id) )
	{
		menu_destroy( hMenu );
		return PLUGIN_HANDLED;
	}
	
	new szData[6], iAccess2, hCallback
	menu_item_getinfo(hMenu, iItem, iAccess2, szData, 5, _, _, hCallback)
	new iKey = str_to_num(szData)
	
	switch( iKey )
	{
		case 1:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				cs_set_weapon_ammo( give_item(id,"weapon_glock18") , 30)
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		/*case 2:
		{
			new cur_money,cena,new_money;
			cena = 1500;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				get_anaconda(id)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}*/
		
		case 2:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				cs_set_weapon_ammo( give_item(id,"weapon_usp") , 24)
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		case 3:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				cs_set_weapon_ammo( give_item(id,"weapon_fiveseven") , 20)
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		case 4:
		{
			new cur_money,cena,new_money;
			cena = 2600;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				get_dualinfinity(id)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
				
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		case 5:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				cs_set_weapon_ammo( give_item(id,"weapon_deagle") , 15)
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
				
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		case 6:
		{
			new cur_money,cena,new_money;
			cena = 2800;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				get_skull1(id)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
				zbrane[id] = 1
				
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
		
		case 7:
		{
			new cur_money,cena,new_money;
			cena = 0;
			cur_money = cs_get_user_money(id);

			if(cur_money >= cena)
			{
				cs_set_weapon_ammo( give_item(id,"weapon_elite") , 30)
				buyammo(id)
				buyammo(id)
				emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				new_money = cur_money - cena;
				cs_set_user_money(id,new_money);
				zbrane[id] = 1
				if(frost_human[id] == 1 )
				{
					give_item(id,"weapon_flashbang")
				}
				if(minigun_human[id])
				{
					ChatColor(id,"!g[Humans]!y MiniGun Human bol !taktivovany" )
					get_minigun(id)
				}
				if(special_human[id])
				{
					ChatColor(id,"!g[Humans]!y Special Human bol !taktivovany" )
					get_specialgun(id)
				}
				
			}
			else
			{
				pistole(id)
				client_print(id, print_center, "Nemas dostatok peniazi!")
			}
		}
	}
	
	menu_destroy( hMenu );
	return PLUGIN_HANDLED;
}


stock ChatColor(const id, const input[], any:...)
{
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

public Hrac_Damage(victim, inflictor, attacker, Float:damage, damage_bits, id)
{
	if(is_user_connected(attacker) && is_entity_moving(attacker))
	{    
		new weapon = get_user_weapon(attacker)
		
		if(g_lasthuman[attacker] == 1)
		{
			if(!g_firstzombie[victim] && !(g_zombieclass[victim] == deathlesszombie(victim)) )
			{
				switch(weapon)
				{
					case CSW_MP5NAVY:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_UMP45:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_AK47:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_M4A1:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_FAMAS:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_AWP:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_P90:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_AUG:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_GALIL:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_M249:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_MAC10:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_GLOCK18:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_DEAGLE:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_ELITE:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_FIVESEVEN:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_G3SG1:
					{
						SetHamParamFloat(4,damage * 4)
					}
					case CSW_USP:
					{
						SetHamParamFloat(4,damage * 4)
					}
				}
			}
		}
	}
}

public zp_round_started(id)
{		
	if(!g_lasthuman[id])
		return
		
	set_task(1.0, "Task_ShowHealth", id+TASK_HEALTH, _, _, "b")
	set_task(1.0, "Task_Show_Power", id+TASK_POWER, _, _, "b")
}

public Fwd_PlayerSpawn_Post(id)
{
	if (task_exists(id+TASK_HEALTH))
		remove_task(id+TASK_HEALTH)
	if (task_exists(id+TASK_POWER))
		remove_task(id+TASK_POWER)
}

public Fwd_PlayerKilled_Pre(victim, attacker, shouldgib)
{
	if (task_exists(victim+TASK_HEALTH))
		remove_task(victim+TASK_HEALTH)
	if (task_exists(victim+TASK_POWER))
		remove_task(victim+TASK_POWER)
	if (task_exists(victim+TASK_REMOVE_ADRENALIN))
		remove_task(victim+TASK_REMOVE_ADRENALIN)
	if (task_exists(victim+TASK_ADD_ADRENALIN))
		remove_task(victim+TASK_ADD_ADRENALIN)
	
}

public power_damage( id )
{
	if( g_modestarted )
	{
		client_cmd( 0, "spk bluezone/zombie/lasthumaninfo.wav")
		set_pev( id, pev_health, float( min( pev( id, pev_health ) + get_pcvar_num( cvar_humanlasthp ), 1200 ) ) );
		set_hudmessage( 42, 42, 255, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1 );
		ShowSyncHudMsg( 0, g_MsgSync5, "%L",LANG_PLAYER, "NOTICE_LAST_HUMAN", g_playername[ id ] );
		for( new i = 0; i < 5; i++ )
		{
			ChatColor( id, "%L", LANG_PLAYER, "LAST_HUMAN_INFO" );
		}
		client_cmd( id, "spk items/smallmedkit1.wav" );
		set_task( 1.0, "Task_Show_Power", id + TASK_POWER, _, _, "b" );
	}
}

public Task_Add_Adrenalin(id)
{
	id -= TASK_ADD_ADRENALIN
	if(!g_zombie[id])
	{
		if(adrenal_human[id])
		{
			if(adrenaline[id]< 100)
				adrenaline[id] += 4
			if(adrenaline[id] >= 100 )
				adrenaline[id] = 100
		}
		else
		{
			if(adrenaline[id]< 100)
				adrenaline[id] += 2
			if(adrenaline[id] >= 100 )
				adrenaline[id] = 100
		}
	} else {
		if(!adrenaline[id] < 2)
			adrenaline[id] -= 4
		
		if(adrenaline[id] < 0 )
			adrenaline[id] = 0
	}
	remove_task(id+TASK_ADD_ADRENALIN)
	remove_task(id+TASK_REMOVE_ADRENALIN)
}

public Task_Remove_Adrenalin(id)
{
	id -= TASK_REMOVE_ADRENALIN
	if(!adrenaline[id] < 2)
		adrenaline[id] -= 4
		
	if(adrenaline[id] < 0 )
		adrenaline[id] = 0
	
	remove_task(id+TASK_ADD_ADRENALIN)
	remove_task(id+TASK_REMOVE_ADRENALIN)
}

public task_Main(id)
{
	if(!is_user_alive(id))
		return ;
	
	if(is_entity_moving(id))
	{
		set_task(0.5, "Task_Add_Adrenalin", id+TASK_ADD_ADRENALIN, _, _, "b")
		if (task_exists(id+TASK_REMOVE_ADRENALIN))
		remove_task(id+TASK_REMOVE_ADRENALIN)
	}
	else if(!is_entity_moving(id))
	{
		set_task(0.5, "Task_Remove_Adrenalin", id+TASK_REMOVE_ADRENALIN, _, _, "b")
		if (task_exists(id+TASK_ADD_ADRENALIN))
			remove_task(id+TASK_ADD_ADRENALIN)
	}
}

public Task_Show_Power(id)
{
	id -= TASK_POWER
	
	if (!g_lasthuman[id]) {
		remove_task(id+TASK_POWER)
	}
		
	if ( is_entity_moving(id) )
	{
		
		//set_hudmessage(255, 127, 0, 0.12, 0.31, 1, 1.0, 1.0, 0.1, 0.2, -1)
		set_hudmessage(255, 127, 0, 0.0, 0.21, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(id, g_MsgSync6, "100%% POWER DAMAGE!!^nZiskal si velku silu v zbraniach!")
	}
	else 
	{
		//set_hudmessage(255, 127, 0, 0.12, 0.31, 1, 1.0, 1.0, 0.1, 0.2, -1)
		set_hudmessage(93, 90, 93, 0.0, 0.21, 0, 6.0, 1.1, 0.0, 0.0, -1)
		ShowSyncHudMsg(id, g_MsgSync6, "0%% POWER DAMAGE!!^nPower damage aktivujes pri behu")
	}
}

public FM_PreThink( id )
{
	new idAiming, iBodyPart;
	get_user_aiming( id, idAiming, iBodyPart );
	
	if( is_user_alive( idAiming ) && is_user_alive( id ) )
	{
		if( cs_get_user_team( id ) == CS_TEAM_CT && cs_get_user_team( idAiming ) == CS_TEAM_CT )
		{
			if( is_user_bot( idAiming ) ) {
				new message[ 200 ];
				set_hudmessage( 30, 30, 200, -1.0, 0.60, 0, 0.1, 0.1, 0.1, 0.1 );
				format( message, 199, "Tento hrac je BOT!" );
				ShowSyncHudMsg( id, g_MsgSync7, message );
			} else {
				new message[ 200 ], szTarget[ 33 ], ammo, spirit, level, expi;
				get_user_name( idAiming, szTarget, charsmax( szTarget ) );
				ammo = 		g_ammopacks[ idAiming ];
				spirit =	body[ idAiming ];
				level = 	levels[ idAiming ];
				expi = 		exp[ idAiming ];
				set_hudmessage( 30, 30, 200, -1.0, 0.60, 0, 0.1, 0.1, 0.1, 0.1 );
				format( message, 199, "%s^nBody: %i | EXP: %i^nSpirity: %i | LVL: %i^nHealth: %i/60^nArmor: %i/35^nDamage: %i/35^nDefense: %i/50", szTarget, ammo, expi, spirit, level, g_unHPLevel[ idAiming ], g_unAPLevel[ idAiming ], g_unDMLevel[ idAiming ], g_unDELevel[ idAiming ] );
				ShowSyncHudMsg( id, g_MsgSync7, message );
			}
		}// ZOMBIE SPECT
		else if( cs_get_user_team( id ) == CS_TEAM_T && cs_get_user_team( idAiming ) == CS_TEAM_T )
		{
			if( is_user_bot( idAiming ) ) {
				new message[ 200 ];
				set_hudmessage( 200, 30, 30, -1.0, 0.60, 0, 0.1, 0.1, 0.1, 0.1)
				format( message, 199, "Tento hrac je BOT!" );
				ShowSyncHudMsg( id, g_MsgSync7, message );
			} else {
				new message[ 200 ], szTarget[ 33 ], ammo, spirit, level, expi;
				get_user_name( idAiming, szTarget, charsmax( szTarget ) );
				ammo = 		g_ammopacks[ idAiming ];
				spirit =	body[ idAiming ];
				level = 	levels[ idAiming ];
				expi = 		exp[ idAiming ];
				set_hudmessage( 200, 30, 30, -1.0, 0.60, 0, 0.1, 0.1, 0.1, 0.1)
				format( message, 199, "%s^nBody: %i | EXP: %i^nSpirity: %i | LVL: %i^nHealth: %i/60^nArmor: %i/35^nDamage: %i/35^nDefense: %i/50", szTarget, ammo, expi, spirit, level, g_unHPLevel[ idAiming ], g_unAPLevel[ idAiming ], g_unDMLevel[ idAiming ], g_unDELevel[ idAiming ] );
				ShowSyncHudMsg( id, g_MsgSync7, message );
			}
		}    
	}
	return PLUGIN_HANDLED;
}

stock is_entity_moving(entity)
{
	if(!is_valid_ent(entity))
		return 0
	
	new Float:fVelocity[3]
	entity_get_vector(entity, EV_VEC_velocity, fVelocity)
	if(vector_length(fVelocity) >=150.0)
		return 1
	
	return 0
} 

public ProvocationSound(id)
{
	client_cmd(id, "spk sound/%s", g_provocation[random_num(0,charsmax(g_provocation))])
}

public Reklama()
{
	switch(random(3))
	{
		case 1: ChatColor(0, "!g[ZP]!y Vela!g Adrenalinu!y ti zvetsuje poskodenie a zaroven ta ochranuje")
		case 2: ChatColor(0, "!g[ZP]!y Pokial si!g Posledny Clovek!y ziskas !gobrovsky damage!y!")
		case 3: ChatColor(0, "!g[ZP]!y Herne menu otvoris stlacenim !gM")
	}
	return PLUGIN_HANDLED
}
public daj_protilatku(id)
{
	humanme(id, 0, 0)
}

public fw_EvCurWeapon(id)
{
	if( cs_get_user_team(id) == CS_TEAM_T )
	{
		if(g_firstzombie[id])
		{
			new g_iPrevCurWeapon[33]
			new iCurWeapon = read_data(2)
			if(iCurWeapon != g_iPrevCurWeapon[id])
			{
				g_iPrevCurWeapon[id] = iCurWeapon
				set_user_gravity(id, 0.3)
			}
		}
	}
}

public reset_score( id)
{
	set_user_frags(id,0)
	cs_set_user_deaths(id,0)
	ChatColor( id,"!g[ZP]!y Uspesne si si vynuloval score!" );
}

public Hrac_Umrel( victim, attacker, shouldgibc ) {
	if( is_user_alive( attacker ) ) {
		if( g_zombie[ victim ] ) {
			set_user_health( attacker, get_user_health( attacker ) + 40 );
			set_pev( attacker, pev_armorvalue, float( min( pev( attacker, pev_armorvalue ) + g_ArmorRegLevel[ attacker ], 999 ) ) );
			cs_set_user_deaths( victim, 0 );
			switch( random( 49 ) ) {
				case 1: {
					if( legendary_key[ attacker ] != 100 ) {
						new name[ 32 ];
						get_user_name( attacker, name, 31 );
						for( new i = 0; i < 5; i++ ) {
							ChatColor( 0, "!t%s!y ziskal za zabitie hraca !t1x Legendary Key!y!", name );
						}
						client_cmd( 0, "spk playaspro/legendarykey.wav")
						set_hudmessage( 255, 127, 0, -1.0, 0.22, 1, 0.0, 5.0, 1.0, 1.0, -1 );
						ShowSyncHudMsg( 0, g_MsgSync8, "%s ziskal Legendary Key!", name );
						legendary_key[ attacker ]++;
					}
				}
			}
		} else {
			cs_set_user_deaths( victim, 0 );
		}
	}
}

public zaciatok_kola( ) {	
	for( new id = 0; id <= 32; id++ ) {
		if( !is_user_alive( id ) )
			continue;
		set_user_armor( id,get_user_armor( id )+40 )
		set_pev( id, pev_armorvalue, float( min( pev( id, pev_armorvalue ) + g_unAPLevel[ id ] * 4, 999 ) ) );
		
		if(gravity_human[id])
		{
			ChatColor(id,"!g[Humans]!y Gravity Human bol !taktivovany" )
			gravita[id] = true
		}
		if(fast_human[id])
		{
			ChatColor(id,"!g[Humans]!y Fast Human bol !taktivovany" )
			speeda[id] = true
		}
		if(frost_human[id])
		{
			ChatColor(id,"!g[Humans]!y Frost Human bol !taktivovany" )
		}
		if(strong_human[id])
		{
			set_user_health( id,get_user_health( id )+40 )
			set_user_armor( id,get_user_armor( id )+40 )
			ChatColor(id,"!g[Humans]!y Strong Human bol !taktivovany" )
		}
		if(damage_human[id])
		{
			ChatColor(id,"!g[Humans]!y Damage Human bol !taktivovany" )
			g_item_dmg[id] = true
			g_item_gdmg[id] = true
		}
		if( points_human[ id ] ) {
			ChatColor( id, "!g[Humans]!y Ziskal si !t50 bodov!y a !y2 spirity!y." );
			g_ammopacks[ id ] += 50;
			body[ id ] += 2;
		}
		if( defense_human[ id ] ) {
			ChatColor( id, "!g[Humans]!y Ziskal si !t+250 Armoru!y." );
			set_user_armor( id, get_user_armor( id ) + 250 );
		}
	}
}

public Round_End( )
{
	new Players[32], playerCount, id;
	get_players( Players, playerCount, "a" );
	
	
	for( new i = 0; i < playerCount; i++ )
	{
		id = Players[i];
		speeda[id] = false
		gravita[id] = false
		if (task_exists(id+TASK_HEALTH))
			remove_task(id+TASK_HEALTH)
		if (task_exists(id+TASK_POWER))
			remove_task(id+TASK_POWER)
	}
}

public takedamage_adrenalin(iVictim, iInfictor, iAttacker, Float:fDamage, iDmgBits)
{	
	if(!is_user_valid_connected(iVictim) || !is_user_valid_connected(iAttacker) || iVictim == iAttacker)
		return HAM_IGNORED
	
	switch(cs_get_user_team(iAttacker))
	{
		case CS_TEAM_T:
		{
			if(g_zombie[iAttacker] && cs_get_user_team(iVictim) == CS_TEAM_CT)
			{
				if(get_user_weapon(iAttacker) == CSW_KNIFE)
				{
					if(!(adrenaline[iVictim] < 0))
						adrenaline[iVictim] -= 6
					if(adrenaline[iVictim] >= 0)
						adrenaline[iVictim] -= 0
					
				}
			}
		}
		case CS_TEAM_CT:
		{
			if(cs_get_user_team(iVictim) == CS_TEAM_T)
			{
				if(!(adrenaline[iAttacker] < 0))
					adrenaline[iAttacker] -= 2
				if(adrenaline[iAttacker] >= 0)
					adrenaline[iAttacker] -= 0
			}
		}
	}
	return HAM_IGNORED
}

public ham_Player_TakeDamage_Post( iVictim, iInfictor, iAttacker, Float:damage, iDmgBits ) { 
	if( !is_user_connected( iVictim ) || !is_user_connected( iAttacker ) || iVictim == iAttacker )
		return HAM_IGNORED;
	
	new iWeapon = get_user_weapon( iAttacker );
	new defense_shoot[ 33 ], burn_attack[ 33 ], frost_attack[ 33 ], frost_resist[ 33 ], burn_resist[ 33 ];
	defense_shoot[ iAttacker ] = random_num( 1, 100 );
	burn_attack[ iAttacker ] = random_num( 1, 100 );
	frost_attack[ iAttacker ] = random_num( 1, 100 );
	frost_resist[ iVictim ] = random_num( 1, 100 );
	burn_resist[ iVictim ] = random_num( 1, 100 );
	static Float:originF[ 3 ];
	pev( iVictim, pev_origin, originF );
	switch( cs_get_user_team( iAttacker ) ) {
		case CS_TEAM_CT: {
			cs_set_user_money( iAttacker, cs_get_user_money( iAttacker ) + g_MoneyLevel[ iAttacker ] );
			if( !g_firstzombie[ iVictim ] && cs_get_user_team( iVictim ) == CS_TEAM_T && !( g_zombieclass[ iVictim ] == deathlesszombie( iVictim ) ) ) {
				if( !( iWeapon == CSW_KNIFE ) && !( iWeapon == CSW_M249 ) ) {
					if( burn_attack[ iAttacker ] < g_BurnLevel[ iAttacker ] ) {
						if( burn_resist[ iVictim ] < g_resBurnLevel[ iVictim ] ) {
							player_resisteffect( iVictim );
							ScreenFade( iVictim, 0.2, 65, 65, 200, 100 );
							client_print( iVictim, print_center, "BOL SI OCHRANENY PRED OHNOM!" );
						} else {
							player_attackeffect( iVictim );
							set_task( 0.2, "burning_flame", iVictim + TASK_BURN, _, _, "b" )
							//create_blast2(originF)
							ScreenFade( iAttacker, 0.2, 200, 65, 65, 100 );
							g_burning_duration[ iVictim ] = 5;
						}
					}
					if( frost_attack[ iAttacker ] < g_FrostLevel[ iAttacker ] ) {
						if( frost_resist[ iVictim ] < g_resFrostLevel[ iVictim ] ) {
							player_resisteffect( iVictim );
							ScreenFade( iVictim, 0.2, 65, 65, 200, 100 );
							client_print( iVictim, print_center, "BOL SI OCHRANENY PRED ZMRAZENIM!" );
						} else {
							player_attackeffect( iVictim );
							message_begin( MSG_ONE_UNRELIABLE, g_msgDamage, _, iVictim );
							write_byte( 0 ); // damage save
							write_byte( 0 ) // damage take
							write_long( DMG_DROWN ); // damage type - DMG_FREEZE
							write_coord( 0 ); // x
							write_coord( 0 ); // y
							write_coord( 0 ); // z
							message_end( );
			
							if (g_handle_models_on_separate_ent)
								fm_set_rendering( g_ent_playermodel[ iVictim ], kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
							else
								fm_set_rendering( iVictim, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 25 );
			
							message_begin( MSG_ONE, g_msgScreenFade, _, iVictim );
							write_short( 0 ); // duration
							write_short( 0 ); // hold time
							write_short( FFADE_STAYOUT ); // fade type
							write_byte( 0 ); // red
							write_byte( 50 ); // green
							write_byte( 200 ); // blue
							write_byte( 100 ); // alpha
							message_end( );
			
							g_frozen[ iVictim ] = true;
			
							pev( iVictim, pev_gravity, g_frozen_gravity[ iVictim ] );
			
							if( pev( iVictim, pev_flags ) & FL_ONGROUND )
								set_pev( iVictim, pev_gravity, 999999.9 ); // set really high
							else
								set_pev( iVictim, pev_gravity, 0.000001 ); // no gravity
			
							ExecuteHamB( Ham_Player_ResetMaxSpeed, iVictim );
			
							set_task( 3.0, "remove_freeze", iVictim );
						}
					}
						
					if( defense_shoot[ iAttacker ] < g_unDELevel[ iVictim ] ) {
						SetHamParamFloat( 4, damage - damage );
						client_print( iVictim, print_center, "Defense ta ochranil pred utokom!" );
						emit_sound( iVictim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
						ScreenFade( iVictim, 0.2, 65, 65, 165, 100 );
						ScreenFade( iAttacker, 0.2, 200, 65, 65, 100 );
						client_print( iAttacker, print_center, "Nepriatela ochranil defense!" );
					} else {
						if( adrenaline[ iAttacker ] < 10 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.30 );
						} else if( adrenaline[ iAttacker ] < 15 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.35 );
						} else if( adrenaline[ iAttacker ] < 20 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.38 );
						} else if( adrenaline[ iAttacker ] < 25 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.39 );
						} else if( adrenaline[ iAttacker ] < 30 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.40 );
						} else if( adrenaline[ iAttacker ] < 35 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.45 );
						} else if( adrenaline[ iAttacker ] < 40 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.60 );
						} else if( adrenaline[ iAttacker ] < 45 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.75 );
						} else if( adrenaline[ iAttacker ] < 50 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.85 );
						} else if( adrenaline[ iAttacker ] < 65 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.95 );
						} else if( adrenaline[ iAttacker ] < 75 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 1.95 );
						} else if( adrenaline[ iAttacker ] < 85 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 2.35 );
						} else if( adrenaline[ iAttacker ] < 95 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 2.65 );
						} else if( adrenaline[ iAttacker ] < 100 ) {
							SetHamParamFloat( 4,( damage + g_unDMLevel[ iAttacker ] ) * 2.95 );
						}
					}
				}
			}
		}
		
	}
	return HAM_IGNORED;
}

public buyammo( id )
{
	// Get user weapons
	static weapons[32], num, i, currentammo, weaponid, refilled
	num = 0 // reset passed weapons count (bugfix)
	refilled = false
	get_user_weapons(id, weapons, num)
	
	// Loop through them and give the right ammo type
	for (i = 0; i < num; i++)
	{
		// Prevents re-indexing the array
		weaponid = weapons[i]
		
		// Primary and secondary only
		if (MAXBPAMMO[weaponid] > 2)
		{
			// Get current ammo of the weapon
			currentammo = cs_get_user_bpammo(id, weaponid)
			
			// Give additional ammo
			ExecuteHamB(Ham_GiveAmmo, id, BUYAMMO[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
			
			// Check whether we actually refilled the weapon's ammo
			if (cs_get_user_bpammo(id, weaponid) - currentammo > 0) refilled = true
		}
	}
	
	// Weapons already have full ammo
	if (!refilled) return PLUGIN_HANDLED;
	
	emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_HANDLED;
}

public handle_say( id ) 
{
	new said[ 64 ], vysledokstring[ 64 ];
	read_argv( 1,said,charsmax( said ) )
	num_to_str( vysledok,vysledokstring,63 );
	
	if( !is_str_num( said ) )
		return PLUGIN_CONTINUE;
	
	if( !prebieha_otazka ) 
	{
		ChatColor( id,"!g[PlayAsPro.net] !yVysledok uz uhadol hrac !t%s!y, pockaj si na dalsi priklad!",g_LastWinner );
		return PLUGIN_CONTINUE;
	}
	
	if( equali( said,vysledokstring ) ) 
	{
		get_user_name( id, g_LastWinner, 31 );
		ChatColor( 0, "!g[PlayAsPro.net] !yHrac !t%s !gvyriesil priklad a vyhrava !t55 EXP!y! Vysledok: !t%d", g_LastWinner, vysledok );
		exp[ id ] += 55;
		SQL_UpdateUser( id );
		ScreenFade( id, 0.3, 65, 65, 165, 100 );	
		prebieha_otazka = 0;
	} 
	else 
	{
		ChatColor( id, "!g[PlayAsPro.net] !yZly vysledok!" );
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
			ChatColor( 0, "!g[PlayAsPro.net] !yKolko je !t%i + %i !y? Spravna odpoved ziska !t55 EXP!y.", cislo1, cislo2 );
		}
		case 2: {
			vysledok = cislo1 - cislo2;
			ChatColor( 0, "!t[PlayAsPro.net] !yKolko je !t%i - %i !y? Spravna odpoved ziska !t55 EXP!y.", cislo1, cislo2 );
		}
	}
	return PLUGIN_HANDLED;
}

public case_of_items( id ) {
	if( !is_user_alive( id ) ) {
		ChatColor( id, "!gMusis byt nazive aby si mohol pouzit protilatku!" );
		return PLUGIN_HANDLED;
	}
	new hm = menu_create( "\rNAKAZIL SI 2 LUDI!^n\yVYBER SI SVOJ BONUS ZDARMA", "case_of_items_handle" );
	menu_additem( hm, "T-Virus Protilatka \d(zadarmo)" );
	menu_additem( hm, "+15 Bodov \d(zadarmo)" );
	menu_additem( hm, "+50 EXP \d(zadarmo)" );
	menu_additem( hm, "1x Spirit \d(zadarmo)" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public case_of_items_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( last_human == 0 ) {
				daj_protilatku( id );
				ScreenFade( id, 0.3, 65, 65, 165, 100 );
				client_cmd( id, "spk valve/sound/buttons/blip2" );
			} else {
				ChatColor( id, "!g[ZP]!y Tato funkcia je nedostupna!" );
				case_of_items( id );
			}
		}
		case 1: {
			g_ammopacks[ id ] += 15;
			client_print( id, print_center, "+15 Bodov" );
			ScreenFade( id, 0.3, 165, 65, 65, 100 );
		}
		case 2: {
			exp[ id ] += 50;
			client_print( id, print_center, "+50 EXP" );
			ScreenFade( id, 0.3, 165, 65, 65, 100 );
		}
		case 3: {
			body[ id ]++;
			client_print( id, print_center, "+1x Spirit" );
			ScreenFade( id, 0.3, 165, 65, 65, 100 );
		}
	}
	human_rip[ id ] = 0;
	client_cmd( id, "spk playaspro/legendarykey.wav" );
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public starter_pack( id ) {
	if( start_pack_player[ id ] == 0 ) {
		new hm = menu_create( "\yStarter Pack!^n\dAko novy hrac mas moznost si vybrat^nvynikajuci Starter Pack!", "starter_pack_handle" );
		menu_additem( hm, "\y+50 000 EXP \w(navzdy) \r+\y 35 LVL" );
		menu_additem( hm, "\y+500 LVL \r+\y35x Legendary Key \w(navzdy)" );
		menu_additem( hm, "\y+100 000 EXP \w(navzdy)" );
		menu_additem( hm, "\yDamage Human \w(jedna mapa) \r+\y 250 LVL" );
		menu_display( id, hm );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public starter_pack_handle( id, menu , item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			exp[ id ] += 50000;
			levels[ id ] += 35;
			ChatColor( id, "!gVybral si si 50 000 EXP a 35 LVL!" );
			ScreenFade( id, 1.0, 165, 65, 65, 100 );
			start_pack_player[ id ]++;
			ChatColor( id, "!gDakujeme ze hrajete na portaly PlayAsPro.net" );
		}
		case 1: {
			levels[ id ] += 500;
			legendary_key[ id ] += 35;
			ChatColor( id, "!gVybral si si 500 LVL a 35x Legendary Key!" );
			ScreenFade( id, 1.0, 165, 65, 65, 100 );
			start_pack_player[ id ]++;
			ChatColor( id, "!gDakujeme ze hrajete na portaly PlayAsPro.net" );
		}
		case 2: {
			exp[ id ] += 100000;
			ChatColor( id, "!gVybral si si 100 000 EXP!" );
			ScreenFade( id, 1.0, 165, 65, 65, 100 );
			start_pack_player[ id ]++;
			ChatColor( id, "!gDakujeme ze hrajete na portaly PlayAsPro.net" );
		}
		case 3: {
			damage_human[ id ] = true;
			levels[ id ] += 250;
			ChatColor( id, "!gVybral si si Damage Humana a 250 LVL!" );
			ScreenFade( id, 1.0, 165, 65, 65, 100 );
			start_pack_player[ id ]++;
			ChatColor( id, "!gDakujeme ze hrajete na portaly PlayAsPro.net" );
		}
	}
	client_cmd( id, "spk playaspro/legendarykey.wav" );
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}


public aktivator_money_sk( id )
{
	new hm = menu_create( "\yLEVEL AKTIVATOR \r( \w/aktivator \r)^n\wwww.playaspro.net | Zombie #1","aktivator_sk" );
	menu_additem( hm,"Zakupit Levely^n\d Chybaju ti levely na noveho humana? Zakup si ich hned!" );
	menu_additem( hm,"Problemy s Levelmi^n\d Stratil si levely? Pomozeme ti hned!^n" );
	menu_additem( hm,"Jazyk/Language: \rSlovakia" );
	menu_display( id,hm );
}

public aktivator_sk( id,menu,item )
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
			aktivator_money_sk( id );
			client_cmd( id, "spk valve/sound/buttons/blip2" );
			show_motd( id,"http://playaspro.net/obchod/premium/" );
		}
		case 1:
		{
			aktivator_money_sk( id );
			show_motd( id ,"http://playaspro.net/forum/" );
			client_cmd( id, "spk valve/sound/buttons/button2" );
		}
		case 2:
		{
			aktivator_money_cz( id );
			client_cmd( id, "spk valve/sound/buttons/button8" );
		}
	}
	return PLUGIN_HANDLED;
}

public aktivator_money_cz( id )
{
	new hm = menu_create( "\yLEVEL AKTIVATOR \r( \w/aktivator \r)^n\wwww.playaspro.net | Zombie #1","aktivator_cz" );
	menu_additem( hm,"Zakoupit Levely^n\d Chybeji ti levely na noveho humana? Zakup si je hned!" );
	menu_additem( hm,"Problemy s Levelmi^n\d Ztratil si levely? Pomuzeme ti hned!^n" );
	menu_additem( hm,"Jazyk/Language: \rCzech" );
	menu_display( id,hm );
}

public aktivator_cz( id,menu,item )
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
			aktivator_money_cz( id );
			client_cmd( id, "spk valve/sound/buttons/blip2" );
			show_motd( id,"http://playaspro.net/obchod/premium/" );
		}
		case 1:
		{
			aktivator_money_cz( id );
			show_motd( id ,"http://playaspro.net/forum/" );
			client_cmd( id, "spk valve/sound/buttons/button2" );
		}
		case 2:
		{
			aktivator_money_en( id );
			client_cmd( id, "spk valve/sound/buttons/button8" );
		}
	}
	return PLUGIN_HANDLED;
}

public aktivator_money_en( id )
{
	new hm = menu_create( "\yLEVEL AKTIVATOR \r( \w/aktivator \r)^n\wwww.playaspro.net | Zombie #1","aktivator_en" );
	menu_additem( hm,"Purchase Levels^n\d Are you need levels for new humans? Purchase them now!" );
	menu_additem( hm,"Problems with Levels^n\d Have you lost levels? We will help you now!^n" );
	menu_additem( hm,"Jazyk/Language: \rEnglish" );
	menu_display( id,hm );
}

public aktivator_en( id,menu,item )
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
			aktivator_money_en( id );
			client_cmd( id, "spk valve/sound/buttons/blip2" );
			show_motd( id,"http://playaspro.net/obchod/premium/" );
		}
		case 1:
		{
			aktivator_money_en( id );
			show_motd( id ,"http://playaspro.net/forum/" );
			client_cmd( id, "spk valve/sound/buttons/button2" );
		}
		case 2:
		{
			aktivator_money_sk( id );
			client_cmd( id, "spk valve/sound/buttons/button8" );
		}
	}
	return PLUGIN_HANDLED;
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
		iPenize = levels[ iPlayer ];
		
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
		
		ChatColor( 0, "%s !tNajviac levelov ma !g%s%s!t - !g%d LVL.!tChces mat viac? Napis !g/aktivator", prefix, ( get_user_flags( iBestPlayer ) & EVIP ) ? "!g" : "!t", szName, iBestPenez );
	}
}

public epic_menu1( id ) {
	new text[ 555 char ];
	
	formatex( text, charsmax( text ), "%L", id, "EPIC_MENU" );
	new hm = menu_create( text, "epic_menu1_handle" );
	
	formatex( text, charsmax( text ), "%L", id, "UPGRADES_MENU" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "EPICUPGRADES_MENU" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "EPICITEMS_MENU" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "INVENTORY_MENU" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "TOURNAMENT_STATS" );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "EXCHANGE_MENU" );
	menu_additem( hm, text );
	
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public epic_menu1_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			show_upgrades_menu( id );
		}
		case 1: {
			show_epic_upgrades_menu( id );
		}
		case 2: {
			if( !have_user_hannibal( id ) ) {			
				if( g_zombie[ id ] ) {
					epic_predmety_tt( id );
				} else {
					epic_predmety_ct( id );
				}
			} else {
				ChatColor( id,"%L", LANG_PLAYER, "EPICITEMS_HANNIBAL" );
				epic_menu1( id );
			}
		}
		case 3: {
			inventory( id );
		}
		case 4: {
			event_menu( id );
		}
		case 5: {
			exchange_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public show_epic_upgrades_menu( id ) {
	
	g_resFrostCost[ id ] = 500 + ( 300 * g_resFrostLevel[ id ] );
	g_resBurnCost[ id ] = 500 + ( 300 * g_resBurnLevel[ id ] );
	g_FrostCost[ id ] = 10500 + ( 10000 * g_FrostLevel[ id ] );
	g_BurnCost[ id ] = 1200 + ( 1200 * g_BurnLevel[ id ] );
	
	new text[ 555 char ];
	
	formatex( text, charsmax( text ), "%L^n\d1/2", id, "EPICUPGRADES_NAME_MENU" );
	new hm = menu_create( text, "show_epic_handle" );
	
	formatex( text, charsmax( text ), "%L", id, "FROST_RESIST_UPGRADE", g_resFrostLevel[ id ], g_resFrostCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "BURN_RESIST_UPGRADE", g_resBurnLevel[ id ], g_resBurnCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "FROST_UPGRADE", g_FrostLevel[ id ], g_FrostCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "BURN_UPGRADE", g_BurnLevel[ id ], g_BurnCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "MENU_NEXT" );
	menu_additem( hm, text );
	
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public show_epic_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( g_resFrostLevel[ id ] != 50 ) {
				if( ( exp[ id ] >= g_resFrostCost[ id ] ) && g_resFrostLevel[ id ] < 50 ) {
					g_resFrostLevel[ id ]++;
					exp[ id ] -= g_resFrostCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				g_resFrostLevel[ id ] = 50;
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic_upgrades_menu( id );
		}
		case 1: {
			if( g_resBurnLevel[ id ] != 50 ) {
				if( ( exp[ id ] >= g_resBurnCost[ id ] ) && g_resBurnLevel[ id ] < 50 ) {
					g_resBurnLevel[ id ]++;
					exp[ id ] -= g_resBurnCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
				g_resBurnLevel[ id ] = 50;
			}
			show_epic_upgrades_menu( id );
		}
		case 2: {
			if( g_FrostLevel[ id ] != 10 ) {
				if( ( exp[ id ] >= g_FrostCost[ id ] ) && g_FrostLevel[ id ] < 10 ) {
					g_FrostLevel[ id ]++;
					exp[ id ] -= g_FrostCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
				g_FrostLevel[ id ] = 10;
			}
			show_epic_upgrades_menu( id );
		}
		case 3: {
			if( g_BurnLevel[ id ] != 50 ) {
				if( ( exp[ id ] >= g_BurnCost[ id ] ) && g_BurnLevel[ id ] < 50 ) {
					g_BurnLevel[ id ]++;
					exp[ id ] -= g_BurnCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				g_BurnLevel[ id ] = 50;
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic_upgrades_menu( id );
		}
		case 4: {
			show_epic2_upgrades_menu( id );
		}
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public show_epic2_upgrades_menu( id ) {
	
	g_ArmorRegCost[ id ] = 4000 + ( 4000 * g_ArmorRegLevel[ id ] );
	g_CritDamageCost[ id ] = 1000 + ( 1000 * g_CritDamageLevel[ id ] );
	g_MoneyCost[ id ] = 150 + ( 400 * g_MoneyLevel[ id ] );
	g_SpyCost[ id ] = 150000;
	
	new text[ 555 char ];
	formatex( text, charsmax( text ), "%L^n\d2/2", id, "EPICUPGRADES_NAME_MENU" );
	new hm = menu_create( text, "show_epic2_handle" );
	
	formatex( text, charsmax( text ), "%L", id, "ARMOR_REG_UPGRADE", g_ArmorRegLevel[ id ], g_ArmorRegCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "CRIT_UPGRADE", g_CritDamageLevel[ id ], g_CritDamageCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "MONEY_UPGRADE", g_MoneyLevel[ id ], g_MoneyCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "SPY_UPGRADE", g_SpyLevel[ id ], g_SpyCost[ id ] );
	menu_additem( hm, text );
	
	formatex( text, charsmax( text ), "%L", id, "MENU_BACK" );
	menu_additem( hm, text );
	
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public show_epic2_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( g_ArmorRegLevel[ id ] != 10 ) {
				if( ( exp[ id ] >= g_ArmorRegCost[ id ] ) && g_ArmorRegLevel[ id ] < 10 ) {
					g_ArmorRegLevel[ id ]++;
					exp[ id ] -= g_ArmorRegCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic2_upgrades_menu( id );
		}
		case 1: {
			if( g_CritDamageLevel[ id ] != 35 ) {
				if( ( exp[ id ] >= g_CritDamageCost[ id ] ) && g_CritDamageLevel[ id ] < 35 ) {
					g_CritDamageLevel[ id ]++;
					exp[ id ] -= g_CritDamageCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic2_upgrades_menu( id );
		}
		case 2: {
			if( g_MoneyLevel[ id ] != 100 ) {
				if( ( exp[ id ] >= g_MoneyCost[ id ] ) && g_MoneyLevel[ id ] < 100 ) {
					g_MoneyLevel[ id ]++;
					exp[ id ] -= g_MoneyCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic2_upgrades_menu( id );
		}
		case 3: {
			if( g_SpyLevel[ id ] != 1 ) {
				if( ( exp[ id ] >= g_SpyCost[ id ] ) && g_SpyLevel[ id ] < 1 ) {
					g_SpyLevel[ id ]++;
					exp[ id ] -= g_SpyCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_print( id, print_center, "%L", id, "NOT_ENOUGH_EXP" );
				}
			} else {
				ChatColor( id, "%L", LANG_PLAYER, "FULL_UPGRADE" );
			}
			show_epic2_upgrades_menu( id );
		}
		case 4: {
			show_epic_upgrades_menu( id );
		}
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public legendary_menu( id ) {
	if( legendary_key[ id ] != 100 ) {
		ChatColor( id, "!g[ZP]!y Nemas dostatok klucov!" );
		return PLUGIN_HANDLED;
	}
	if( !is_user_alive( id ) ) {
		ChatColor( id, "!g[ZP]!y Musis byt nazive!" );
		return PLUGIN_HANDLED;
	}
	new szText[ 555 char ], used;
	used = 1 - g_leg_used[ id ];
	formatex( szText, charsmax( szText ), "\rLegendary Menu: \y[1/2]^n\y- Legendary menu mozes pouzit iba \r%i\y krat!", used );
	new hm = menu_create( szText, "legendary_menu_handle" );
	if( !g_leg_vyvoleny[ id ] ) 
		menu_additem( hm, "\yVyvoleny \w=>\r [AKTIVOVAT]" );
	else
		menu_additem( hm, "\yVyvoleny \w=>\d [POUZITE]" );
	if( !g_leg_randomweapon[ id ] )
		menu_additem( hm, "\yRandom Secret Weapon \w=>\r [AKTIVOVAT]" );
	else
		menu_additem( hm, "\yRandom Secret Weapon \w=>\d [POUZITE]" );
	menu_additem( hm, "\d(stlac 3 pre info)\yRegeneration \w=>\d [AKTIVOVANE]" );
	menu_additem( hm, "\d(stlac 4 pre info)\yEpic Drop Case \w=>\d [AKTIVOVANE]^n" )
	menu_additem( hm, "Dalej" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public legendary_menu_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( g_leg_used[ id ] != 1 ) {
				if( !g_zombie[ id ] ) {
					g_leg_vyvoleny[ id ] = true;
					g_leg_used[ id ]++;
					humanme( id, 1, 0 );
					new name[ 32 ];
					get_user_name( id, name, 31 );
					set_hudmessage( 0, 0, 200, -1.0, 0.15, 1, 0.0, 5.0, 1.0, 1.0, -1 );
					ShowSyncHudMsg( 0, g_MsgSync,"%s je Vyvoleny!",name );
					ChatColor( id, "!g[ZP]!y Vybral si si Vyvoleneho!" );
					ScreenFade( id, 1.0, 65, 65, 165, 100 );
					legendary_menu( id );
				} else {
					ChatColor( id, "!g[ZP]!y Musis byt clovek aby si mohol zakupit vyvoleneho!" );
					legendary_menu( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Uz nemozes pouzit tento bonus!" );
				legendary_menu( id );
			}
		}
		case 1: {
			if( g_leg_used[ id ] != 1 ) {
				if( !g_survivor[ id ] || !g_zombie[ id ] ) {
					g_leg_used[ id ]++;
					g_leg_randomweapon[ id ] = true;
					switch( random_num( 1, 4 ) ) {
						case 1: {
							get_minigun( id ); ChatColor( id, "!g[ZP]!y Ziskal si !tMinigun!y!" );
						}
						case 2: {
							get_ak47long( id ); ChatColor( id, "!g[ZP]!y Ziskal si !tAK-47 Long!y!" );
						}
						case 3: {
							get_cartblue( id ); ChatColor( id, "!g[ZP]!y Ziskal si !tCart-Blue!y!" );
						}
						case 4: {
							get_specialgun( id ); ChatColor( id, "!g[ZP]!y Ziskal si !tspecial Gun!y!" );
						}
					}
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					ScreenFade( id, 1.0, 65, 65, 165, 100 );
					legendary_menu( id );
				} else {
					ChatColor( id, "!g[ZP]!y Nemozes ako Vyvoleny ziskat zbran zdarma!" );
					legendary_menu( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Uz nemozes pouzit tento bonus!" );
				legendary_menu( id );
			}
		}
		case 2: {
			for( new i = 0; i < 5; i++ ) {
				ChatColor( id, "!gPokial niekoho nakazis alebo zabijes mas sancu ziskat FULL HP!" );
			}
			legendary_menu( id );
		}
		case 3: {
			for( new i = 0; i < 5; i++ ) {
				ChatColor( id, "!gMas 20% sancu ziskat za kazdy kill/nakazenie Epic Case!" );
			}
			legendary_menu( id );
		}
		case 4: {
			legendary_menu_2( id );
		}
	}
	return PLUGIN_HANDLED;
}

public legendary_menu_2( id ) {
	new szText[ 555 char ], used;
	used = 1 - g_leg_used[ id ];
	formatex( szText, charsmax( szText ), "\rLegendary Menu: \y[2/2]^n\y- Legendary menu mozes pouzit iba \r%i\y krat!", used );
	new hm = menu_create( szText, "legendary_menu2_handle" );
	menu_additem( hm, "Na tejto strane sa zatial nic nenachadza! Sleduj Forum!^n" );
	menu_additem( hm, "Vratit sa" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public legendary_menu2_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			legendary_menu_2( id );
		}
		case 1: {
			legendary_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public exchange_menu( id ) {
	new hm = menu_create( "\wExchange Menu^n\d- Pokial mas nepotrebne body mozes ich vymenit!", "exchange_menu_ex" );
	menu_additem( hm, "[1x Spirit]\r ====> \w[10 EXP]^n" );
	menu_additem( hm, "[5x Spirit]\r ====> \w[35 Bodov]^n" );
	menu_additem( hm, "[10x Spirit]\r ====> \w[1 LVL]^n" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public exchange_menu_ex( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( body[ id ] >= 1 ) {
				body[ id ]--;
				exp[ id ] += 10;
				exchange_menu( id );
				ScreenFade( id, 0.2, 65, 165, 65, 100 );
				client_cmd( id, "spk playaspro/zakupenie.wav" );
				ChatColor( id, "!g[ZP]!y Transakcia prebehla uspesne!" );
			} else {
				ChatColor( id, "!g[ZP]!y Nemas dostatok spiritov!" );
				ScreenFade( id, 0.2, 165, 65, 65, 100 );
				exchange_menu( id );
			}
		}
		case 1: {
			if( body[ id ] >= 5 ) {
				body[ id ] -= 5;
				g_ammopacks[ id ] += 35;
				exchange_menu( id );
				ScreenFade( id, 0.2, 65, 165, 65, 100 );
				client_cmd( id, "spk playaspro/zakupenie.wav" );
				ChatColor( id, "!g[ZP]!y Transakcia prebehla uspesne!" );
			} else {
				ScreenFade( id, 0.2, 165, 65, 65, 100 );
				ChatColor( id, "!g[ZP]!y Nemas dostatok spiritov!" );
				exchange_menu( id );
			}
		}
		case 2: {
			if( body[ id ] >= 10 ) {
				body[ id ] -= 10;
				levels[ id ] += 1;
				exchange_menu( id );
				ScreenFade( id, 0.2, 65, 165, 65, 100 );
				client_cmd( id, "spk playaspro/zakupenie.wav" );
				ChatColor( id, "!g[ZP]!y Transakcia prebehla uspesne!" );
			} else {
				ScreenFade( id, 0.2, 165, 65, 65, 100 );
				ChatColor( id, "!g[ZP]!y Nemas dostatok spiritov!" );
				exchange_menu( id );
			}
		}
		
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}
		
public epic_predmety_tt( id ) {
	new szText1[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\yEpic Zombie Predmety^n\dAktualne mas %i Spiritov", body[ id ] )
	new hm = menu_create( szText1, "epic_predmety_tt_handle" );
	if( !g_epicUltimate[ id ] )
		menu_additem( hm, "\yNo Slow Down \r=>\w 8x Spirit^n\dziadna gulka ta nespomaly (jedna mapa)" );
	else 
		menu_additem( hm, "\yNo Slow Down \r=> [AKTIVOVANY]^n\dziadna gulka ta nespomaly (jedna mapa)" );
	if( !g_epic20hpmap[ id ] ) 
		menu_additem( hm, "\y400 Bodov \r=>\w 8x Spirit^n\dlimit bodov zvyseny na 400 (jedna mapa)" );
	else
		menu_additem( hm, "\y400 Bodov \r=> [AKTIVOVANE]^n\dlimit bodov zvyseny na 400 (jedna mapa)" );
	menu_additem( hm, "\yLVL Case \r=>\w 28x Spirit^n\dziskas lvl case kde mozes ziskat az 500 LVL!" );
	if( !g_epic20dmgmap[ id ] ) 
		menu_additem( hm, "\y+20% Damage \r=>\w 25x Spirit^n\dviac poskodenia za ludi/zombie celu mapu" );
	else 
		menu_additem( hm, "\y+20% Damage \r=> [AKTIVOVANY]^n\dviac poskodenia za ludi/zombie celu mapu" );
	if( legendary_key[ id ] == 100 )
		menu_additem( hm, "\dTento item je pre teba uz nedostupny!^n" );
	else
		menu_additem( hm, "\yLegendary Menu 1x Kluc \r=>\w 25 Levelov^n\dziskas kluc ktorym odomknes legendarne menu!^n" );
	menu_additem( hm, "Spat do menu" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public epic_predmety_tt_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( !g_epicUltimate[ id ] ) {
				if( body[ id ] >= 8 ) {
					g_epicUltimate[ id ] = true;
					body[ id ] -= 8;
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					ChatColor( id, "!g[ZP]!y Zakupil si si !tNo Slow Down!y!" );
					ScreenFade( id, 0.2, 165, 65, 65, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_tt( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas davno aktivovany!" );
				epic_predmety_tt( id );
			}
		}
		case 1: {
			if( !g_epic20hpmap[ id ] ) {
				if( body[ id ] >= 8 ) {
					g_epic20hpmap[ id ] = true;
					get_300( id );
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					body[ id ] -= 8;
					ScreenFade( id, 0.2, 165, 65, 65, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_tt( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas davno aktivovany!" );
				epic_predmety_tt( id );
			}
		}
		case 2: {
			if( body[ id ] >= 28 ) {
				lvl_case[ id ]++
				client_cmd( id, "spk playaspro/zakupenie.wav" );
				body[ id ] -= 28;
				ChatColor( id, "!g[ZP]!y !tLVL Case!y bola ulozena do inventara!" );
				ScreenFade( id, 0.2, 165, 65, 65, 100 );
			} else {
				ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
				epic_predmety_tt( id );
			}
		}
		case 3: {
			if( !g_epic20dmgmap[ id ] ) {
				if( body[ id ] >= 25 ) {
					body[ id ] -= 25;
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					g_epic20dmgmap[ id ] = true;
					ChatColor( id, "!g[ZP]!y Ziskal si !t+20 Damage!y navyse!" );
					ScreenFade( id, 0.2, 165, 65, 65, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_tt( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas aktivovany!" );
				epic_predmety_tt( id );
			}
		} 
		case 4: {
			if( legendary_key[ id ] != 100 ) {
				if( levels[ id ] >= 25 ) {
					legendary_key[ id ]++;
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					levels[ id ] -= 25;
					ChatColor( id, "!g[ZP]!y Ziskal si !t1x Legendary Menu Kluc!y!" );
					ScreenFade( id, 0.2, 165, 65, 65, 100 );
					epic_predmety_tt( id );
					client_cmd( id, "spk playaspro/legendarykey.wav" );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Levelov! " );
					epic_predmety_tt( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item je uz pre teba nedostupny!" );
				epic_predmety_tt( id );
			}
		}
		case 5: {
			epic_menu1( id );
		}
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}
				
		
public epic_predmety_ct( id ) {
	new szText1[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\yEpic Human Predmety^n\dAktualne mas %i Spiritov", body[ id ] );
	new hm = menu_create( szText1, "epic_predmety_ct_handle" );
	if( !g_epic20hpmap[ id ] ) 
		menu_additem( hm, "\y400 Bodov \r=>\w 8x Spirit^n\dlimit bodov zvyseny na 400 (jedna mapa)" );
	else
		menu_additem( hm, "\y400 Bodov \r=> [AKTIVOVANE]^n\dlimit bodov zvyseny na 400 (jedna mapa)" );
	if( !g_epicDragon[ id ] ) 
		menu_additem( hm, "\yDragon Cannon \r=>\w 12x Spirit^n\dzbran ktora striela ohen s vysokym poskodenim" );
	else 
		menu_additem( hm, "\yDragon Cannon \r=> [POUZITY]^n\dzbran ktora striela ohen s vysokym poskodenim" );
	menu_additem( hm, "\yEXP Case \r=>\w 16x Spirit^n\dziskas exp case kde mozes ziskat az 5000 EXP!" );
	if( !g_epic20dmgmap[ id ] ) 
		menu_additem( hm, "\y+20% Damage \r=>\w 25x Spirit^n\dviac poskodenia za ludi/zombie celu mapu" );
	else 
		menu_additem( hm, "\y+20% Damage \r=> [AKTIVOVANY]^n\dviac poskodenia za ludi/zombie celu mapu" );
	if( legendary_key[ id ] == 100 )
		menu_additem( hm, "\dTento item je pre teba uz nedostupny!^n" );
	else
		menu_additem( hm, "\yLegendary Menu 1x Kluc \r=>\w 25 Levelov^n\dziskas kluc ktorym odomknes legendarne menu!^n" );
	menu_additem( hm, "Spat do menu" );
	menu_display( id, hm );
}

public epic_predmety_ct_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( !g_epic20hpmap[ id ] ) {
				if( body[ id ] >= 8 ) {
					g_epic20hpmap[ id ] = true;
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					get_300( id );
					body[ id ] -= 8;
					ScreenFade( id, 0.2, 65, 65, 165, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_ct( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas davno aktivovany!" );
				epic_predmety_ct( id );
			}
		}
		case 1: {
			if( !g_epicDragon[ id ] ) {
				if( body[ id ] >= 12 ) {
					g_epicDragon[ id ] = true;
					get_dragon( id );
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					body[ id ] -= 12;
					ChatColor( id, "!g[ZP]!y Zakupil si si !tEpic Dragon!" );
					ScreenFade( id, 0.2, 65, 65, 165, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_ct( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas davno aktivovany!" );
				epic_predmety_ct( id );
			}
		}
		case 2: {
			if( body[ id ] >= 16 ) {
				exp_case[ id ]++;
				body[ id ] -= 16;
				client_cmd( id, "spk playaspro/zakupenie.wav" );
				ChatColor( id, "!g[ZP]!t EXP Case!y bola ulozena do tvojho inventara!" );
				ScreenFade( id, 0.2, 65, 65, 165, 100 );
			} else {
				ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
				epic_predmety_ct( id );
			}
		}
		case 3: {
			if( !g_epic20dmgmap[ id ] ) {
				if( body[ id ] >= 25 ) {
					g_epic20dmgmap[ id ] = true;
					body[ id ] -= 25;
					client_cmd( id, "spk playaspro/zakupenie.wav" );
					ChatColor( id, "!g[ZP]!y Zakupil si si !t+20 Damage!y navyse!" );
					ScreenFade( id, 0.2, 65, 65, 165, 100 );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Spiritov!" );
					epic_predmety_ct( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item uz mas davno aktivovany!" );
				epic_predmety_ct( id );
			}
		}
		case 4: {
			if( legendary_key[ id ] != 100 ) {
				if( levels[ id ] >= 25 ) {
					legendary_key[ id ]++;
					levels[ id ] -= 25;
					ChatColor( id, "!g[ZP]!y Ziskal si !t1x Legendary Menu Kluc!y!" );
					ScreenFade( id, 0.2, 65, 65, 165, 100 );
					epic_predmety_ct( id );
					client_cmd( id, "spk playaspro/legendarykey.wav" );
				} else {
					ChatColor( id, "!g[ZP]!y Nemas dostatok Levelov! " );
					epic_predmety_ct( id );
				}
			} else {
				ChatColor( id, "!g[ZP]!y Tento item je uz pre teba nedostupny!" );
				epic_predmety_ct( id );
			}
		}
		case 5: {
			epic_menu1( id );
		}
	} 
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}

public show_upgrades_menu( id ) {

	g_pHPCost[ id ] = get_pcvar_num( g_pcvar_unhpcost ) + ( get_pcvar_num( g_pcvar_unhpmult ) * g_unHPLevel[ id ] );
	g_pAPCost[ id ] = get_pcvar_num( g_pcvar_unapcost ) + ( get_pcvar_num( g_pcvar_unapmult ) * g_unAPLevel[ id ] );
	g_pDMCost[ id ] = get_pcvar_num( g_pcvar_undmcost ) + ( get_pcvar_num( g_pcvar_undmmult ) * g_unDMLevel[ id ] );
	g_pDECost[ id ] = get_pcvar_num( g_pcvar_undecost ) + ( get_pcvar_num( g_pcvar_undemult ) * g_unDELevel[ id ] );
	
	new szText1[ 555 char ], szText2[ 555 char ], szText3[ 555 char ], szText4[ 555 char ], szText5[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "\yVylepsenia ktore zostavaju i po odpojeni sa z hry!" );
	formatex( szText2, charsmax( szText2 ), "Health \r[ZM] \d[ \r1 Upgrade \w= \r+2 %% \d]^n\wLevel >> \y %d \w/ \r60\w | Cena >> \d[ \r%d EXP \d]", g_unHPLevel[ id ], g_pHPCost[ id ] );
	formatex( szText3, charsmax( szText3 ), "Armor \y[HUM] \d[ \r1 Upgrade \w= \r+4 %% \d]^n\wLevel >> \y %d \w/ \r35\w | Cena >> \d[ \r%d EXP \d]", g_unAPLevel[ id ], g_pAPCost[ id ] );
	formatex( szText4, charsmax( szText4 ), "Damage \y[HUM] \d[ \r1 Upgrade \w= \r+1 %% \d]^n\wLevel >> \y %d \w/ \r35\w | Cena >> \d[ \r%d EXP \d]", g_unDMLevel[ id ], g_pDMCost[ id ] );
	formatex( szText5, charsmax( szText5 ), "Defense \d[ \r1 Upgrade \w= \r+1 %% \d]^n\wLevel >> \y %d \w/ \r50\w | Cena >> \d[ \r%d EXP \d]", g_unDELevel[ id ], g_pDECost[ id ] );
	new hm = menu_create( szText1, "show_upgrades_handle" );
	menu_additem( hm, szText2 );
	menu_additem( hm, szText3 );
	menu_additem( hm, szText4 );
	menu_additem( hm, szText5 );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public show_upgrades_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			if( g_unHPLevel[ id ] != 60 ) {
				if( ( exp[ id ] >= g_pHPCost[ id ] ) && g_unHPLevel[ id ] < 60 ) {
					g_unHPLevel[ id ]++;
					exp[ id ] -= g_pHPCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					for( new i = 0; i < 5; i++ ) {
						ChatColor( id, "!gAktualny level >> %d", g_unHPLevel[ id ] );
					}
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					client_print( id, print_center, "NEMAS DOSTATOK EXP!" );
				}
			} else {
				client_print( id, print_center, "Toto vylepsenie uz mas naplno!" );
			}
			show_upgrades_menu( id );
		} 
		case 1: {
			if( g_unAPLevel[ id ] != 35 ) {
				if( ( exp[ id ] >= g_pAPCost[ id ] ) && g_unAPLevel[ id ] < 35 ) {
					g_unAPLevel[ id ]++; 
					exp[ id ] -= g_pAPCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					for( new i = 0; i < 5; i++ ) {
						ChatColor( id, "!gAktualny level >> %d", g_unAPLevel[ id ] );
					}
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					client_print( id, print_center, "NEMAS DOSTATOK EXP!" );
				}
			} else {
				client_print( id, print_center, "Toto vylepsenie uz mas naplno!" );
			}
			show_upgrades_menu( id );
		}
		case 2: {
			if( g_unDMLevel[ id ] != 35 ) {
				if( ( exp[ id ] >= g_pDMCost[ id ] ) && g_unDMLevel[ id ] < 35 ) {
					g_unDMLevel[ id ]++;
					exp[ id ] -= g_pDMCost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					for( new i = 0; i < 5; i++ ) {
						ChatColor( id, "!gAktualny Level >> %d", g_unDMLevel[ id ] );
					}
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					client_print( id, print_center, "NEMAS DOSTATOK EXP!" );
				}
			} else {
				client_print( id, print_center, "Toto vylepsenie uz mas naplno!" );
			}
			show_upgrades_menu( id );
		}
		case 3: {
			if( g_unDELevel[ id ] != 50 ) {
				if( ( exp[ id ] >= g_pDECost[ id ] ) && g_unDELevel[ id ] < 50 ) {
					g_unDELevel[ id ]++;
					exp[ id ] -= g_pDECost[ id ];
					client_cmd( id, "spk playaspro/upgraden.wav" );
					for( new i = 0; i < 5; i++ ) {
						ChatColor( id, "!gAktualny Level >> %d", g_unDELevel[ id ] );
					}
					ScreenFade( id, 0.5, 255, 212, 42, 100 );
				} else {
					ScreenFade( id, 1.0, 255, 0, 0, 100 );
					client_cmd( id, "spk valve/sound/buttons/button11" );
					client_print( id, print_center, "NEMAS DOSTATOK EXP!" );
				}
			} else { 
				client_print( id, print_center, "Toto vylepsenie uz mas naplno!" );
			}
			show_upgrades_menu( id );
		}
	}
	SQL_UpdateUser( id );
	return PLUGIN_HANDLED;
}
				
public Task_Show_Power1( id )
{
	id -= TASK_EVENT1;
	if( g_plagueround )
	{
		set_dhudmessage( 125, 31, 122, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0 );
		show_dhudmessage( id,"Mod: Vyvoleny VS Nemesis^nZa kazdy kill ziskas 5 Spiritov" );
	}
	
	if( last_human == 0 )
	{
		if( g_swarmround ) {
			set_dhudmessage( 255, 0, 255, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0 );
			show_dhudmessage( id,"Mod: Epic Round^nza kazdy kill 500 EXP" );
		}
		if( g_multiround )
		{
			set_dhudmessage( 255, 127, 0, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0 );
			show_dhudmessage( id,"Mod: Viacnasobna Infekcia^n+200% viac EXP za kill/nakazenie" );
		}
	} else {
		if( g_multiround )
		{
			set_dhudmessage( 255, 127, 0, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0 );
			show_dhudmessage( id,"^nMod: Viacnasobna Infekcia^n+200% viac EXP za kill/nakazenie" );
		}
		if( g_swarmround ) {
			set_dhudmessage( 255, 0, 255, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0 );
			show_dhudmessage( id,"^nMod: Epic Round^nza kazdy kill 500 EXP" );
		}
	}
	/*if( mode == MODE_MULTI )
	{
		set_dhudmessage( 255, 127, 0, -1.0, 0.04, 0, 6.0, 1.1, 0.0, 0.0, -1 );
		show_dhudmessage( id,"^nMod: Viacnasobna Infekcia" );
	}*/
	
	if( g_event == 1 )
	{
		set_hudmessage( 127, 170, 255, -1.0, 0.8, 0, 6.0, 1.1, 0.0, 0.0, -1 );
		ShowSyncHudMsg( id, g_msg_event, "*** Laser Gun Event ***^nlimitovana zbran -> laser gun^nza kazdy kill/nakazenie ziskas 20 EXP navyse" );
	}
	
}

public event_menu( id ) {
	if( !is_user_alive( id ) ) {
		ChatColor( id, "!g[ZP]!y Musis byt nazive!" );
		return PLUGIN_HANDLED;
	}
	new szText[ 555 char ];
	formatex( szText, charsmax( szText ), "Tvoj pocet zabitych zombie \y-> \w[\r%i\w]", g_killed_zombies[ id ] );
	new hm = menu_create( "Event Statistiky \w( \r/event\w )^n\d- Turnaj trva do \r25.6 2018", "event_menu_handle" );
	menu_additem( hm, szText );
	menu_additem( hm, "Koncove Odmeny" );
	menu_additem( hm, "MileStone Odmeny^n==================" );
	menu_additem( hm, "\yInformacie" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public event_menu_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			event_menu( id );
		}
		case 1: {
			show_motd( id, "info/end_rewards.txt" );
			event_menu( id );
		}
		case 2: {
			milestone_menu( id );
		}
		case 3: {
			show_motd( id, "info/turnaj.txt" );
		}
	}
	return PLUGIN_HANDLED;
}

public milestone_menu( id  ) {
	new hm = menu_create( "\yMileStone Odmeny:^n- Vyhry su podla pocet zabitych zombie!", "milestone_menu_handle" );
	if( g_killed_zombies[ id ] < 50 )
		menu_additem( hm, "50 \r=>\y 5000 EXP \d[nedosiahnute]" );
	else 
		menu_additem( hm, "\d50 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 100 ) 
		menu_additem( hm, "100 \r=>\y 10 000 EXP + 10x EXP Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d100 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 500 )
		menu_additem( hm, "500 \r=>\y 10 000 EXP + 8x LVL Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d500 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 1000 )
		menu_additem( hm, "1000 \r=>\y 25 000 EXP + 20x EXP Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d1000 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 2000 )
		menu_additem( hm, "2000 \r=>\y 25 000 EXP + 20x EXP Case + 15x LVL Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d2000 => \y[dosiahnute]" );
	menu_display( id, hm );
	return PLUGIN_HANDLED;
}

public milestone_menu_handle( id, menu, item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			milestone_menu( id );
		}
		case 1: {
			milestone_menu( id );
		}
		case 2: {
			milestone_menu( id );
		}
		case 3: {
			milestone_menu( id );
		}
		case 4: {
			milestone_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public RegMenu(id)
{
	if(ServerLoaded == 0)
	{
		ChatColor(id, "!g%s!y %L", prefix, id, "SERVERLOADING");
		return;
	}
	
	new String[128];
	formatex(String, charsmax(String), "%L", id, "REGISTERMENU");
	new menu = menu_create(String, "RegMenuh" );
		
	if(strlen(User[id]) > 0)
	{
		formatex(String, charsmax(String), "%L", id, "USERNAME", User[id]);
		menu_additem(menu, String, "1");
		
		formatex(String, charsmax(String), "%L^n", id, "PASSWORD", Password[id]);
		menu_additem(menu, String, "2");
	}
	else
	{
		formatex(String, charsmax(String), "%L", id, "USERNAME2", User[id]);
		menu_additem(menu, String, "1");
	}
	
	if(strlen(User[id]) > 0 && strlen(Password[id]) > 0 && UserLoad[id] == 0 && inProgress[id] == 0)
	{
		if(Found[id] == 1)
		{
			formatex(String, charsmax(String), "%L^n", id, "LOGIN");
			menu_additem(menu, String, "3");
		}
		else
		{
			formatex(String, charsmax(String), "%L^n", id, "REGISTER");
			menu_additem(menu, String, "4");
		}
	}
	menu_additem( menu, "\yLanguage:\w Slovak", "5" );
	
	menu_display(id, menu);
}

public RegMenuh(id, Menu, Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return;
	}
	
	new Data[14], Line[32];
	new Access, Callback;
	menu_item_getinfo(Menu, Item, Access, Data, charsmax(Data), Line, charsmax(Line), Callback);
	
	new x = str_to_num(Data);
	
	switch(x)
	{
		case 1 : {
			client_cmd(id, "messagemode MOJE_MENO");
			RegMenu(id);
		}
		
		case 2 : {
			client_cmd(id, "messagemode MOJE_HESLO");
			RegMenu(id);
		}
		
		case 3 : {
			if(inProgress[id] == 0)
			{
				inProgress[id] = 1;
				ChatColor(id, "!g%s!y %L", prefix, id, "LOGINPENDING");
				RegisterMod[id] = 1;
				SQL_Check(id);
				RegMenu(id);
			}
			else
			{
				RegMenu(id);
			}
		}
		
		case 4 : {
			if(inProgress[id] == 0)
			{
				inProgress[id] = 1;
				ChatColor(id, "!g%s!y %L", prefix, id, "REGISTERPENDING");
				RegisterMod[id] = 2;
				SQL_Check(id);
				RegMenu(id);
			}
			else
			{
				RegMenu(id);
			}
		}
		
		case 5: {
			ChatColor( id, "!g[ZP]!y Other languages comming soon!" );
			RegMenu(id)
		}
	}
}

public SQL_RegCheck(id)
{
	new szQuery[128], Len, a[32], steam[ 33 ];
	
	get_user_authid( id, steam[ id ], 31 );
	
	formatex(a, 31, "%s", steam[id]);

	replace_all(a, 31, "\", "\\");
	replace_all(a, 31, "'", "\'");
	
	Len += formatex(szQuery[Len], 128, "SELECT * FROM csserver_zombieblood ");
	Len += formatex(szQuery[Len], 128-Len,"WHERE STEAM = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(SQL_TUPLE, "SQL_RegCheckResult", szQuery, szData, 2);
	
	UserLoad[id] = 1;
}

public SQL_RegCheckResult(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
	
	new id = szData[0];
	
	if(szData[1] != get_user_userid(id))
		return;
	
	if( is_user_bot( id ) ) 
		return;
		
	if(SQL_NumRows(Query) > 0)
	{
		Found[id] = true;
		inProgress[ id ] = 1;
		ChatColor( id, "!g%s!y %L", Prefix, id, "LOGINPENDING" );
		RegisterMod[ id ] = 1;
		SQL_Check( id );
	} else {
		Found[id] = false;
		inProgress[ id ] = 1;
		ChatColor( id, "!g%s!y %L", Prefix, id, "REGISTERPENDING" );
		RegisterMod[ id ] = 2;
		SQL_Check( id );
	}
	UserLoad[id] = 0;
	//RegMenu(id);
}

public SQL_Check(id)
{
	new szQuery[128], Len, a[32], steam[ 33 ];
	
	get_user_authid( id, steam[ id ], 31 );
	
	formatex(a, 31, "%s", steam[id]);

	replace_all(a, 31, "\", "\\");
	replace_all(a, 31, "'", "\'");
	
	Len += formatex(szQuery[Len], 128, "SELECT * FROM csserver_zombieblood ");
	Len += formatex(szQuery[Len], 128-Len,"WHERE STEAM = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);
	
	SQL_ThreadQuery(SQL_TUPLE, "SQL_CheckResult", szQuery, szData, 2);
}

public SQL_CheckResult(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
	
	new id = szData[0];
	
	if(szData[1] != get_user_userid(id))
		return;
	
	if(RegisterMod[id] == 2)
	{	
		if(SQL_NumRows(Query) > 0)
		{
			ChatColor(id, "!g%s!y %L", Prefix, id, "USERNAMEUSING");
			inProgress[id] = 0;
			RegMenu(id);
		}
		else
		{
			SQL_NewAccount(id);
		}
	}
	else if(RegisterMod[id] == 1)
	{
		/*if(SQL_NumRows(Query) == 0)
		{
			ScreenFade( id, 1.5, 180, 25, 25, 200 );
			ChatColor(id, "!g%s!y %L", Prefix, id, "BADPW");
			inProgress[id] = 0;
			RegMenu(id);
		}
		else
		{*/
			SQL_UserLoad(id);
		//}
	}
}

public SQL_NewAccount(id)
{
	new szQuery[512], Len, a[32], b[32], c[32], steam[ 33 ], name[ 33 ], ip[ 33 ];
	get_user_name( id, name[ id ], 31 );
	get_user_authid( id, steam[ id ], 31 );
	get_user_ip( id, ip[ id ], 31, 1 );
	
	formatex(a, 31, "%s", name[id]);
	formatex(b, 31, "%s", ip[id]);
	formatex(c, 31, "%s", steam[ id ]);

	replace_all(a, 31, "\", "\\");
	replace_all(a, 31, "'", "\'"); 
	replace_all(b, 31, "\", "\\");
	replace_all(b, 31, "'", "\'"); 
	replace_all(c, 31, "\", "\\");
	replace_all(c, 31, "'", "\'");
	 
	Len += formatex(szQuery[Len], 511, "INSERT INTO csserver_zombieblood ");
	Len += formatex(szQuery[Len], 511-Len,"(USER,IP,STEAM) VALUES('%s','%s','%s')", a, b, c);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(SQL_TUPLE,"SQL_NewAccountResult", szQuery, szData, 2);
}

public SQL_NewAccountResult(FailState, Handle:Query, Error[], Errcode, szData[], DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", Error);
		return;
	}
		
	new id = szData[0];
	
	if(szData[1] != get_user_userid(id))
		return;
	
	inProgress[id] = 0;
	RegisterMod[id] = 2;
	ChatColor(id, "!g%s!y %L", Prefix, id, "REGISTERED");
	//ChatColor(id, "!g%s!y %L", Prefix, id, "REGDATAS", User[id], Password[id]);
	SQL_RegCheck(id);
	
	return;
}

public SQL_UserLoad(id)
{
	new szQuery[256], Len, a[32], steam[ 33 ];
	
	get_user_authid( id, steam[ id ], 31 );
	
	formatex(a, 31, "%s", steam[id]);

	replace_all(a, 31, "\", "\\");
	replace_all(a, 31, "'", "\'");
	
	Len += formatex(szQuery[Len], 256, "SELECT * FROM csserver_zombieblood ");
	Len += formatex(szQuery[Len], 256-Len,"WHERE STEAM = '%s'", a);
	
	new szData[2];
	szData[0] = id;
	szData[1] = get_user_userid(id);

	SQL_ThreadQuery(SQL_TUPLE,"SQL_UserLoadResult", szQuery, szData, 2);
}

public SQL_UserLoadResult( FailState, Handle:Query, Error[ ], Errcode, szData[ ], DataSize ) {
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ) {
		log_amx( "%s", Error );
		return;
	} else {
		new id = szData[ 0 ];
		
		if( szData[ 1 ] != get_user_userid( id ) )
			return;
		
		new SqlPassword[ 32 ];
		SQL_ReadResult( Query, 2, SqlPassword, 31 );
		
		new a[ 32 ], b[ 32 ];
		formatex( a, 31, "%s", User[ id ] );
		formatex( b, 31, "%s", Password[ id ] );
		
		replace_all( a, 31, "\", "\\" );
		replace_all( a, 31, "'", "\'" );
		replace_all( b, 31, "\", "\\" );
		replace_all( b, 31, "'", "\'" );
		
		if( equal( Password[ id ], SqlPassword ) ) {	
			SQL_ReadResult( Query, 2, Password[ id ], 31 );
			Activity[ id ] = SQL_ReadResult( Query, 15 );
			if( Activity[ id ] > 0 ) {
				ScreenFade( id, 1.0, 220, 25, 25, 150 );
				ChatColor( id, "!g%s!y %L", prefix, id, "USERUSING" );
				inProgress[ id ] = 0;
				RegMenu( id );
				return;
			}
			UserID[ id ] = SQL_ReadResult( Query, 0 );
			exp[ id ] = SQL_ReadResult( Query, 4 );
			levels[ id ] = SQL_ReadResult( Query, 5 );
			legendary_key[ id ] = SQL_ReadResult( Query, 6 );
			g_unHPLevel[ id ] = SQL_ReadResult( Query, 7 );
			g_unAPLevel[ id ] = SQL_ReadResult( Query, 8 );
			g_unDMLevel[ id ] = SQL_ReadResult( Query, 9 );
			g_unDELevel[ id ] = SQL_ReadResult( Query, 10 );
			g_killed_zombies[ id ] = SQL_ReadResult( Query, 11 );
			exp_case[ id ] = SQL_ReadResult( Query, 12 );
			lvl_case[ id ] = SQL_ReadResult( Query, 13 );
			//playaspro_case[ id ] = SQL_ReadResult( Query, 14 );
			start_pack_player[ id ] = SQL_ReadResult( Query, 14 );
			g_resBurnLevel[ id ] = SQL_ReadResult( Query, 16 );
			g_resFrostLevel[ id ] = SQL_ReadResult( Query, 17 );
			g_BurnLevel[ id ] = SQL_ReadResult( Query, 18 );
			g_FrostLevel[ id ] = SQL_ReadResult( Query, 19 );
			g_ArmorRegLevel[ id ] = SQL_ReadResult( Query, 20 );
			g_CritDamageLevel[ id ] = SQL_ReadResult( Query, 21 );
			g_MoneyLevel[ id ] = SQL_ReadResult( Query, 22 );
			g_SpyLevel[ id ] = SQL_ReadResult( Query, 23 );
			Activity[ id ] = 1;
			SQL_UpdateActivity( id );
			set_dhudmessage( 65, 165, 65, -1.0, 0.10, 0, 8.0, 8.0 );
			show_dhudmessage( id, "%L", LANG_PLAYER, "LOGINED_HUD" );
			ChatColor( id, "!g%s!y %L", prefix, id, "LOGINED" );
			for( new i = 0; i < 3; i++ ) {
				ChatColor( id, "Prosim skontroluj si konzolu pre viac info!" );
			}
			Ulozit( id );
			client_print( id, print_console, "[#] Ked sa znova prihlasis z tohto Pocitaca vsetky tvoje data budu" );
			client_print( id, print_console, "[#] nacitane aby si nemusel znova zadavat meno a heslo." );
			client_print( id, print_console, "[#] Meno: %s", User[ id ] );
			client_print( id, print_console, "[#] Heslo: %s", Password[ id ] );
			client_print( id, print_console, "[#] Steam: %s", Name[ id ] );
			
			ScreenFade( id, 1.5, 25, 180, 25, 150 );
			inProgress[ id ] = 0;
			Logined[ id ] = true;
		} else {
			ScreenFade( id, 1.0, 220, 25, 25, 150 );
			ChatColor( id, "!g%s!y %L", prefix, id, "BADPW" );
			inProgress[ id ] = 0;
			RegMenu( id );
		}
	}
}

public cmdUser( id ) {
	if( Logined[ id ] ) {
		return PLUGIN_HANDLED;
	}
	if( UserLoad[ id ] == 1 ) {
		RegMenu( id );
		return PLUGIN_HANDLED;
	}
	new cmdData[ 32 ], cmdLength;
	cmdData[ 0 ] = EOS;
	read_args( cmdData, 31 );
	remove_quotes( cmdData );
	cmdLength = strlen( cmdData );
	if( cmdLength < 4 ) {
		client_cmd( id, "mp3 play sound/playaspro/badlogin.mp3" );
		ScreenFade( id, 1.0, 220, 25, 25, 150 );
		ChatColor(id, "!g%s!y %L", prefix, id, "SHORT");
		return PLUGIN_HANDLED;
	}
	if( cmdLength > 19 ) {
		client_cmd( id, "mp3 play sound/playaspro/badlogin.mp3" );
		ScreenFade( id, 1.0, 220, 25, 25, 150 );
		ChatColor(id, "!g%s!y %L", prefix, id, "LONG");
		return PLUGIN_HANDLED;
	}
	copy( User[ id ], 31, cmdData );
	SQL_RegCheck( id );
	return PLUGIN_HANDLED;
}

public cmdPassword( id ) {
	if( Logined[ id ] || strlen( User[ id ] ) == 0 ) {
		return PLUGIN_HANDLED;
	}
	new cmdData[ 32 ], cmdLength;
	cmdData[ 0 ] = EOS;
	read_args( cmdData, 31 );
	remove_quotes( cmdData );
	cmdLength = strlen( cmdData );
	if( cmdLength < 4 ) {
		ScreenFade( id, 1.0, 220, 25, 25, 150 );
		ChatColor( id, "!g%s!y %L", prefix, id, "SHORT" );
		return PLUGIN_HANDLED;
	}
	if( cmdLength > 19 ) {
		ScreenFade( id, 1.0, 220, 25, 25, 150 );
		ChatColor( id, "!g%s!y %L", prefix, id, "LONG" );
		return PLUGIN_HANDLED;
	}
	
	copy( Password[ id ], 31, cmdData );
	RegMenu( id );
	return PLUGIN_HANDLED;
}

public SQL_Results( FailState, Handle:Query, Error[ ], Errcode, szData[ ], DataSize ) {
	if( FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED ) {
		log_amx( "%s", Error );
		return;
	}
}

public SQL_FirstLoad( ) {
	SQL_TUPLE = SQL_MakeDbTuple( SQL_Host, SQL_User, SQL_Password, SQL_Database );
	SQL_Reload( );
}

public SQL_Reload( ) {
	new szQuery[ 256 ], Len;
	Len += formatex( szQuery[ Len ], 256, "UPDATE csserver_zombieblood SET " );
	Len += formatex( szQuery[ Len ], 255 - Len, "ACT = '0' " );
	Len += formatex( szQuery[ Len ], 255 - Len, "WHERE ACT = '1'" );
	SQL_ThreadQuery( SQL_TUPLE, "SQL_Results", szQuery );
	ServerLoaded = 1;
}

public SQL_UpdateActivity( id )
{
	new sQuery[512], szQuery[256], a[32], steam[ 33 ];
	
	get_user_authid( id, steam[ id ], 31 );
	
	formatex(a, 31, "%s", steam[id]);
	
	formatex(szQuery, charsmax(szQuery), "UPDATE csserver_zombieblood SET ");
	add(sQuery, charsmax(sQuery), szQuery);
	
	formatex(szQuery, charsmax(szQuery),"ACT = '%d' ", Activity[id]);
	add(sQuery, charsmax(sQuery), szQuery);
	
	formatex(szQuery, charsmax(szQuery),"WHERE STEAM = '%s'", a);
	add(sQuery, charsmax(sQuery), szQuery);
	
	SQL_ThreadQuery(SQL_TUPLE, "SQL_Results", sQuery);
}

public SQL_UpdateUser( id ) {	 
	if(!Logined[id])
		return;
	
	new sQuery[2800], szQuery[256];
	new a[32], i, steam[ 33 ];
	
	get_user_authid( id, steam[ id ], 31 );
	
	formatex(a, 31, "%s", steam[id]);

	replace_all(a, 31, "\", "\\");
	replace_all(a, 31, "'", "\'");
	
	formatex( szQuery, charsmax( szQuery ), "UPDATE csserver_zombieblood SET " );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "STEAM = '%s', ", a );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "EXP = '%d', ", exp[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "LEVELS = '%d', ", levels[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "LEGENDARYKEY = '%d', ", legendary_key[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "HEALTH = '%d', ", g_unHPLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "ARMOR = '%d', ", g_unAPLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "DAMAGE = '%d', ", g_unDMLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "DEFENSE = '%d', ", g_unDELevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "STARTERPACK = '%d', ", start_pack_player[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "ZOMBIEKILLS = '%d', ", g_killed_zombies[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "EXPCASE = '%d', ", exp_case[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );

	formatex( szQuery, charsmax( szQuery ), "LVLCASE = '%d', ", lvl_case[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "BURNRESIST = '%d', ", g_resBurnLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "FROSTRESIST = '%d', ", g_resFrostLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "BURN = '%d', ", g_BurnLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "FROST = '%d', ", g_FrostLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "ARMORREGEN = '%d', ", g_ArmorRegLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "CRITICALDMG = '%d', ", g_CritDamageLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "MONEY = '%d', ", g_MoneyLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "SPY = '%d', ", g_SpyLevel[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex( szQuery, charsmax( szQuery ), "ACT = '%d' ", Activity[ id ] );
	add( sQuery, charsmax( sQuery ), szQuery );
	
	formatex(szQuery, charsmax(szQuery),"WHERE STEAM = '%s';", a);
	add(sQuery, charsmax(sQuery), szQuery);

	SQL_ThreadQuery( SQL_TUPLE, "SQL_Results", sQuery );
}

player_attackeffect( id ) {
	new Float:Origin[ 3 ];
	pev( id, pev_origin, Origin )
	
	Origin[ 2 ] = Origin[ 2 ] + 20.0;
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SPRITE );
	engfunc( EngFunc_WriteCoord, Origin[ 0 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 1 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 2 ] );
	write_short( gSpr_regeneration ); 
	write_byte( 0 );
	write_byte( 200 );
	message_end( );
}

player_resisteffect( id ) {
	new Float:Origin[ 3 ];
	pev( id, pev_origin, Origin )
	
	Origin[ 2 ] = Origin[ 2 ] + 20.0;
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_SPRITE );
	engfunc( EngFunc_WriteCoord, Origin[ 0 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 1 ] );
	engfunc( EngFunc_WriteCoord, Origin[ 2 ] );
	write_short( g_spr_resist ); 
	write_byte( 0 );
	write_byte( 200 );
	message_end( );
}
