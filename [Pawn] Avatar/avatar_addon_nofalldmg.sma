#include < amxmodx >
#include < hlsdk_const >
#include < hamsandwich >

#define PLUGIN 		"No FallDamage"
#define VERSION 	"0.0.1"

public plugin_init( ) {
	register_plugin( PLUGIN, VERSION, "ConnorMcLeod" );
	RegisterHam( Ham_TakeDamage, "player", "OnCBasePlayer_TakeDamage" );
}

public OnCBasePlayer_TakeDamage( id, iInflictor, iAttacker, Float:flDamage, bitsDamageType ) {
	if( bitsDamageType & DMG_FALL ) {
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}  
