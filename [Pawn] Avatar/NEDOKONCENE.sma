


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

public ham_UseStationary_Post( entity, caller, activator, use_type )
{
	if( use_type == USE_STOPPED && is_user_connected( caller ) )
		replace_weapon_models( caller, get_user_weapon( caller ) );
}

// Spawn 
if( pev_valid( weapon_ent ) )
	replace_weapon_models( id, cs_get_weapon_id( weapon_ent ) );
	
	
replace_weapon_models( id, weaponid )
{
	if( !is_user_connected( id ) )
	return;
	
	static CsTeams:team; team = cs_get_user_team( id );
	
	if( g_nastavenieModely[ id ] == true )
	{
		switch( weaponid )
		{
			case CSW_UMP45:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/ump/v_ump45.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/p_ump45.mdl" );
			}
			case CSW_M3:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/m3/v_m3.mdl" );
			}
			case CSW_AWP:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani/awp/v_awp.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/awp/p_awp.mdl" );
			}
			case CSW_MP5NAVY:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/mp5/v_mp5.mdl" );
			}
			case CSW_AK47:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/ak/v_ak47.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/ak/p_ak47.mdl" );
			}
			case CSW_M4A1:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani/m4a1/v_m4a1.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani/m4a1/p_m4a1.mdl" );
			}
			case CSW_M249:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/m249/v_m249.mdl" );
			}
			case CSW_FAMAS:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/famas/v_famas.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/famas/p_famas.mdl" );
			}
			case CSW_GLOCK18:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/glock/v_glock18.mdl" );
			}
			case CSW_USP:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/usp/v_usp.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/usp/p_usp.mdl" );
			}
			case CSW_DEAGLE:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/deagles/v_deagle.mdl" );
			}
			case CSW_FIVESEVEN:
			{
				set_pev( id, pev_viewmodel2, "models/AVguns/VyberZbrani2/fiveseven/v_fiveseven.mdl" );
				set_pev( id, pev_weaponmodel2, "models/AVguns/VyberZbrani2/fiveseven/p_fiveseven.mdl" );
			}
			case CSW_AUG:
			{
				set_pev( id, pev_viewmodels2, "models/AVguns/VyberZbrani2/bullup/v_aug2.mdl" );
			}
			case CSW_P228:
			{
				set_pev( id, pev_viewmodels2, "models/AVguns/VyberZbrani2/compact/v_p228.mdl" );
			}
			case CSW_ELITE:
			{
				set_pev( id, pev_viewmodels2, "models/AVguns/VyberZbrani2/dualky/v_elite.mdl" );
				set_pev( id, pev_weaponmodels2, "models/AVguns/VyberZbrani2/dualky/p_elite.mdl" );
			}
			// TU SOM SKONCIL
		}
	} 
	else 
	{
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
				set_pev( id, pev_viewmodel2, "models/v_xm1014.mdl" );
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1051\\ f0\\ fs16 \n\\ par }
*/
