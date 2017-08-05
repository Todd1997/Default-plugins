#include <amxx>

new const PluginName[]	= "Admin System";
new bool:IsAdmin[MAX_PLAYERS_NUM+1];

new gAdminPassword;
new gAdminPw;

public plugin_init( )
{
	register_plugin( PluginName, AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	gAdminPassword = register_cvar( "amx_admin_setinfo", "_pw" );
	gAdminPw 			= register_cvar( "amx_admin_password", "abcd123")
}

public client_authorized( id )
{
	// Making variables to insert here the informations.
	new Info[128], szCvar[100], szCvar2[100];
	
	// retrieving in szCvar var the amx_admin_setinfo key server use.
	get_pcvar_string(gAdminPassword, szCvar, cm(szCvar));
	
	// retrieving  here the actual password of the server for the admins.
	get_pcvar_string(gAdminPw, szCvar2, cm(szCvar2));
	
	// getting here the setinfo of the _pw value.
	get_user_info( id, szCvar, Info, cm(Info));
	
	// Making a user admin if Info(his password) is equal with amx_admin_password cvar.
	IsAdmin[id] = bool:equali( Info, szCvar2);
}

public plugin_natives( )
{
	register_native( "is_user_admin", "is_admin" );
	register_native ("set_user_admin", "set_admin" );
}

public is_admin( Plugins, Params ) return IsAdmin[get_param(1)];
public set_admin(Plugins, Params) IsAdmin[get_param(1)] = bool:get_param(2);

public client_disconnect( id )
{
	IsAdmin[id] = false;
}
