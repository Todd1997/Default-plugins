#include <amxx>
#include <nvault>
#include <amxx_stocks>

new NvaultHandle;

enum _:PlayerData
{
	PD_AdminLevel,
	PD_AdminPassword
}

new PD[MAX_PLAYERS_NUM+1][PlayerData];

new CvarPw;

new giAdminLevel[33];

public plugin_init()
{
	register_plugin( "Admin System", AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	/* This command is for making a new admin, this can be used only in SERVER-CONSOLE! */
	/* Note: To remove an admin just set his admin level to '0' */
	/* Example making an user admin: amx_set_admin MyName 5 123 ( 5=adminlevel, 123=password)*/
	register_srvcmd( "amx_set_admin", "_make" );

	NvaultHandle = nvault_open("AdminSystems");

	if( NvaultHandle == INVALID_HANDLE )
	{
		set_fail_state( "Debugging: NvaultHandle var is -1, probably already openned." );
	}

	CvarPw = register_cvar( "amx_admin_password_key", "_pw" );
}

public plugin_end()
{
	nvault_close( NvaultHandle )
}

public _make( )
{
	new AdminName[32];
	read_argv( 1, AdminName, cm(AdminName) );
	new PlayerId = find_player("al", AdminName );

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "User '%s' not finded, please try again.", AdminName );
		return PLUGIN_HANDLED;
	}	

	new AdminLevel = read_arg_int(2);

	if( !AdminLevel )
	{
		server_print( "The admin level your specified ( '%i' ) is not avaible!", AdminLevel );
	}

	PD[PlayerId][PD_AdminLevel] = AdminLevel;
	giAdminLevel[PlayerId] = AdminLevel;

	new AdminPw = read_arg_int(3);

	if( !AdminPw )
	{
		server_print( "The admin password you specified is invalid, please specy only numerical password, example: 1412052223" );
		return PLUGIN_HANDLED;
	}

	PD[PlayerId][PD_AdminPassword] = AdminPw;

	// NvaultHandle is the vault 'index', AdminName is the key name, PD is the array!

	nvault_set_array( NvaultHandle, AdminName, PD[PlayerId], sizeof( PD[] ) );
	
	server_print( "You succesfully make admin the user, please copy the next information:^nAdmin Nick-Name: %s^nAdmin Password: %i^nAdmin Level:%i", AdminName, AdminPw, AdminLevel);
	return PLUGIN_HANDLED;
}

AdminCheck( id )
{
	new szName[32];
	get_user_info( id,"name", szName, cm(szName) )
	
	nvault_get_array( NvaultHandle, szName, PD[id], sizeof(PD[]) );
	
	new szInfo[100], szCvarInfo[100];
	get_pcvar_string( CvarPw, szCvarInfo, cm(szCvarInfo) );
		
	get_user_info( id, szCvarInfo, szInfo, cm(szInfo) );
	
	if( PD[id][PD_AdminLevel] >= 1 )
	{
		if( PD[id][PD_AdminPassword] == str_to_num(szInfo) )
			giAdminLevel[id] = PD[id][PD_AdminLevel];
		else
		{
			server_cmd( "kick %s # This name[%s] is reserved! #", szName,szName );
			PD[id][PD_AdminLevel] = 0;
		}
			
	}
	else
		giAdminLevel[id] = 0;
}

public client_connect( id )
{
	AdminCheck(id);
}

public client_infochanged(id)
{
	AdminCheck(id);
}
public client_disconnect(id)
{
	giAdminLevel[id] = 0;
}

public plugin_natives( )
{
	register_native( "get_user_adminlevel", "_get_admin_level" );
	register_native( "is_user_admin", "_is_admin" );
}

public _get_admin_level(Pl,Pr)
{
	return giAdminLevel[get_param(1)];
}

public _is_admin(Pl,Pr)
{
	return bool:( giAdminLevel[get_param(1)] > 0 );
}
