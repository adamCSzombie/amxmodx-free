
new g_nVault;

new g_killed_zombies[ 33 ];
public plugin_cfg( )
{
	g_nVault = nvault_open( "stats_points" );

	if ( g_nVault == INVALID_HANDLE )
		set_fail_state( "Error pri otvarani Stats nVault, zlozka vobec neexistuje!" );
}

public plugin_end( )
{
	nvault_close( g_nVault );
	
	return PLUGIN_CONTINUE;
}

public plugin_init( )
{
	RegisterHam( Ham_Killed,"player","Hrac_Zomrel",1 );
	
	register_logevent( "zaciatok_kola", 2, "1=Round_Start" );
}
public turnaj_menu( id ) {
	new szText1[ 555 char ];
	formatex( szText1, charsmax( szText1 ), "Pocet zabitych zombie \y->\w[ \r%i \w]", g_killed_zombies[ id ] );
	new hm = menu_create( "Event Statistiky \w( \r/event \w)^n\d- jednoducha statistika tvojich uspechov pocas eventu.","turnaj_menu_handle" );
	menu_additem( hm, szText1 );
	menu_additem( hm, "\yMileStone Odmeny" );
	menu_additem( hm, "\rOdmeny za pocet killov" );
	menu_display( id,hm );
	return PLUGIN_HANDLED;
}

public turnaj_menu_handle( id,menu,item ) {
	if( item == MENU_EXIT ) {
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	switch( item ) {
		case 0: {
			turnaj_menu( id );
		}
		case 1: {
			milestone_menu( id );
		}
		case 2: {
			turnaj_menu( id );
			ChatColor( id, "!gODMENY SU ZVEREJNENE NA NASOM WEBE! ZAREGISTRUJ SA NA !tWWW.PLAYASPRO.NET" );
		}
	}
	return PLUGIN_HANDLED;
}

public milestone_menu( id  ) {
	new hm = menu_create( "\yMileStone Odmeny:^n- Vyhry su podla pocet zabitych zombie!", "milestone_menu_handle" );
	if( g_killed_zombies[ id ] < 50 )
		menu_additem( hm, "50 \r=>\y 3500 EXP \d[nedosiahnute]" );
	else 
		menu_additem( hm, "\d50 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 100 ) 
		menu_additem( hm, "100 \r=>\y 3500 EXP + EXP Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d100 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 500 )
		menu_additem( hm, "500 \r=>\y 6000 EXP + EXP Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d500 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 1000 )
		menu_additem( hm, "1000 \r=>\y 10000 EXP + 2x EXP Case \d[nedosiahnute]" );
	else
		menu_additem( hm, "\d1000 => \y[dosiahnute]" );
	if( g_killed_zombies[ id ] < 2000 )
		menu_additem( hm, "2000 \r=>\y 10000 EXP + 3x EXP Case \d[nedosiahnute]" );
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

public ano_nie( id )
{
	new hm = menu_create( "Chces si nastavit Server Config?^n\d- Pozor! Tato operacia sa neda vratit spat!","ano_menu_handle" );
	menu_additem( hm, "Ano" );
	menu_additem( hm, "Nie");
	menu_display( id,hm );
}	

public ano_menu_handle( id,menu,item )
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
			client_cmd( id, "MP3Volume 0.8" );
			client_cmd( id, "volume 0.3" );
			client_cmd( id, "cl_dynamiccrosshair 0" );
			client_cmd( id, "cl_bob 0" );
		}
		case 1:
		{
			herne_menu( id );
		}
	}
	return PLUGIN_HANDLED;
}

public zaciatok_kola( )    
{
		
	for( new id=0;id<=32;id++ )
	{
		if( !is_user_alive( id ) )
			continue;
	
		g_rounds_played[ id ] += 1;
	}
}

public Hrac_Zomrel( victim,attacker,shouldgibc )
{
	if( is_user_alive( attacker ) )
	{
		if( get_user_team( victim ) == 1 )
		{
			g_killed_zombies[ attacker ] += 1;
		}
	}
}
				
public client_disconnect( id ) { SaveData( id ); }
public client_putinserver( id ) { LoadData( id ); }
public client_connect( id ) { g_connected_times[ id ] += 1; }

SaveData( id ) 
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "stats-%s-points", szAuthid )
	formatex( szVaultData, 511, "%i %i %i %i %i", g_killed_players[ id ], g_killed_avatars[ id ], g_killed_humans[ id ], g_rounds_played[ id ], g_connected_times[ id ] );
	nvault_set( g_nVault, szVaultKey, szVaultData );
}

LoadData( id ) 
{
	new szAuthid[ 32 ];
	get_user_authid( id, szAuthid, charsmax(szAuthid) );
	
	new szVaultKey[ 128 ], szVaultData[ 512 ];
	
	formatex( szVaultKey, 127, "stats-%s-points", szAuthid );
	formatex( szVaultData, 511, "%i %i %i %i %i", g_killed_players[ id ], g_killed_avatars[ id ], g_killed_humans[ id ], g_rounds_played[ id ], g_connected_times[ id ] );
	
	nvault_get( g_nVault, szVaultKey, szVaultData, 511 );
	
	new money[ 32 ], nd[ 32 ], co[ 32 ], rg[ 32 ], mj[ 32 ];
	
	parse( szVaultData, money, 31, nd, 31, co, 31, rg, 31, mj, 31 );
	
	g_killed_players[ id ] = str_to_num( money );
	g_killed_avatars[ id ] = str_to_num( nd );
	g_killed_humans[ id ] = str_to_num( co );
	g_rounds_played[ id ] = str_to_num( rg );
	g_connected_times[ id ] = str_to_num( mj );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
