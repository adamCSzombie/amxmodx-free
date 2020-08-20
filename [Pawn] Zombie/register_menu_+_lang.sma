new const lang[ ][ ][ ] = {
	{ "SLOVAK", "CZECH", "ENGLISH" },
	{ "\yPrihlasovacie Menu:\d (www.playaspro.net)^n> BETA TESTING", "\yPrihlasovaci Menu:\d (www.playaspro.net)^n> BETA TESTING", "\yLogin Menu: \d (www.playaspro.net)^n> BETA TESTING" }, // 1
	{ "\yMeno:\d ", "\yMeno:\d ", "\yName:\d " }, // 2
	{ "\yHeslo:\d ", "\yHeslo:\d ", "\yPassword:\d " }, // 3
	{ "\rLanguage: \wSlovak", "\rLanguage: \wCzech", "\rLanguage: \wEnglish" }, // 4
	{ ">> PRIHLASIT SA <<", ">> PRIHLASIT SE <<", ">> LOG IN <<" }, // 5
	{ ">> ZAREGISTROVAT SA <<", ">> ZAREGISTROVAT SE <<", ">> MAKE NEW ACCOUNT <<" }, // 6
	{ "!g[ZP]!y Databaza nebola uspesne pripojena!", "!g[ZP]!y Databaze nebyla uspesne prepojena!", "!g[ZP]!y Database has not been connected!" }, // 7
	{ "!g[ZP]!y Prihlasujem na vas ucet....", "!g[ZP]!y Prihlasuji na tvuj ucet....", "!g[ZP]!y Logining into your account...." }, // 8
	{ "\yMeno:\d %s^n\d2. Heslo:", "\yMeno:\d %s^n\d2. Heslo:", "\yName:\d %s^n\d2. Password:" },// 9
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
	{ "!g[ZP]!y Ked si hannibal nemozes pouzit tuto funckiu!", "!g[ZP]!y Kdyz jsi hanniba nemuzes pouzit tuhle funkci!", "!g[ZP]!y When you are hannibal you can not use this function!" } // 28
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
