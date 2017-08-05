#include <amxx>
#include <amxx_stocks>
#include <nvault>

new const gVaultName[] = "BanList";
new const PluginName[] = "Admin Commands";
new const NoAccesMessage[] = "You're not an admin!";

new bool:gMute[MAX_PLAYERS_NUM+1];
new g_VaultId;

new const Commands[] [] =
{
	"+ AMXX List of Admin Commands +",
	"amx_kick 'Name'",
	"amx_kill 'Name'",
	"amx_map 'Map Name'",
	"amx_mute 'Name'",
	"amx_unmute 'Name'",
	"amx_admins",
	"amx_restrict_ip 'Name'",
	"amx_restrict_name 'Name'",
	"amx_restrict_steam 'Name'",
	"amx_remove_restriction 'Name/Ip/Steam'",
	"amx_server_console 'The Variable to be sended to server'"
};

public plugin_init( )
{
	g_VaultId = nvault_open(gVaultName);

	if( g_VaultId == INVALID_HANDLE )
	{
		set_fail_state("Problems openning BanList.vault");
	}

	register_plugin( PluginName, AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	/* The supreme command ! 
		Please do not use Quotes " " when you use a command or will be readed only the first argument!
	*/

	register_clcmd( "amx_server_console", "cmdSconsole" );

	RegisterCmd( "amx_kick",		"ClcmdKick",			"SrvcmdKick" );
	RegisterCmd( "amx_kill",		"ClcmdKill", 			"SrvcmdKill" );
	RegisterCmd( "amx_map",			"ClcmdMap",   			"SrvcmdMap" );
	RegisterCmd( "amx_mute",		"ClcmdMute", 			"SrvcmdMute" );
	RegisterCmd( "amx_unmute",		"ClcmdUnmute",			"SrvcmdUnmute" );
	RegisterCmd( "amx_admins",		"ClcmdAdmins",			"SrvcmdAdmins" );
	RegisterCmd( "amx_help",		"ClcmdHelp",			"SrvcmdHelp");
	RegisterCmd( "amx_restrict_ip", 	"ClcmdRestrictIp",		"SrvcmdRestrictIp");
	RegisterCmd( "amx_restrict_name", 	"ClcmdRestrictName",		"SrvcmdRestrictName");
	RegisterCmd( "amx_restrict_steam", 	"ClcmdRestrictSteam",		"SrvcmdRestrictSteam");
	RegisterCmd( "amx_remove_restriction",  "ClcmdRemoveRestriction",	"SrvcmdRemoveRestriction");
	

	/* Specify to mute/unmute cmd: */

	register_clcmd( "say", "check_say" );
	register_clcmd( "say_team", "check_say" );
}

public plugin_end() nvault_close(g_VaultId);

public ClcmdHelp( id )
{
	for( new i=0; i < sizeof(Commands); i++ )
	{
		client_print( id, print_console, Commands[i] );
	}

	return PLUGIN_HANDLED;
}

public SrvcmdHelp( )
{
	for( new i=0; i < sizeof(Commands); i++ )
	{
		server_print( Commands[i] );
	}

	return PLUGIN_HANDLED;
}
public client_authorized( id )
{
	gMute[id] = false;

	new szName[32], szIp[32], szAuthId[34];
	
	get_user_name( id, szName, cm(szName) );
	get_user_ip( id, szIp, cm(szIp) );
	get_user_authid( id, szAuthId, cm(szAuthId) );

	if( nvault_get( g_VaultId, szName ) >= 1 )
	{
		server_cmd( "kick %s Your NAME is restricted!", szName );
	} 

	if( nvault_get( g_VaultId, szIp ) >= 1 )
	{
		server_cmd( "kick %s Your IP is restricted!", szName );
	} 

	if( nvault_get( g_VaultId, szAuthId ) >= 1 )
	{
		server_cmd( "kick %s Your STEAM is restricted!", szName );
	} 
}


public ClcmdRemoveRestriction( id )
{
	new Arg1[64], szData[2], iTs;
	read_argv( 1, Arg1, cm(Arg1) );


	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] amx_remove_restriction 'Name/Ip/Steam'" );
		return PLUGIN_HANDLED;
	}

	if( !nvault_lookup( g_VaultId, Arg1, szData, cm(szData), iTs ) )
	{
		client_print( id, print_console, "[AMXX-BLUE] This steam/ip/name is not correct or is not on the BanList: %s", Arg1 );
		return PLUGIN_HANDLED;
	}

	client_print( id, print_console, "[AMXX-BLUE] Restriction has been removed for this name/ip/steam: %s", Arg1 );

	nvault_remove( g_VaultId, Arg1);

	return PLUGIN_HANDLED;
}

public SrvcmdRemoveRestriction(  )
{
	new Arg1[64], szData[2], iTs;
	read_argv( 1, Arg1, cm(Arg1) );


	if( Arg1[0] == EOS )
	{
		server_print("[AMXX-BLUE] amx_remove_restriction 'Name/Ip/Steam'" );
		return PLUGIN_HANDLED;
	}

	if( !nvault_lookup( g_VaultId, Arg1, szData, cm(szData), iTs ) )
	{
		server_print("[AMXX-BLUE] This steam/ip/name is not correct or is not on the BanList: %s", Arg1 );
		return PLUGIN_HANDLED;
	}

	server_print("[AMXX-BLUE] Restriction has been removed for this name/ip/steam: %s", Arg1 );

	nvault_remove( g_VaultId, Arg1);

	return PLUGIN_HANDLED;
}




public ClcmdRestrictIp( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );

	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user <amx_restrict_ip 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	new Ip[32];
	get_user_ip( PlayerId, Ip, cm(Ip) );

	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been ^4banned^1 by ^4%s^1.", Arg1, szAdminName );

	nvault_set( g_VaultId, Ip, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}


public SrvcmdRestrictIp( )
{
	/* Example of finding a target */
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );


	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user <amx_restrict_ip 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	new Ip[32];
	get_user_ip( PlayerId, Ip, cm(Ip) );

	nvault_set( g_VaultId, Ip, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}


public ClcmdRestrictSteam( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );

	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user <amx_restrict_steam 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	new szAuthId[34];
	get_user_authid( PlayerId, szAuthId, cm(szAuthId) );

	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been ^4banned^1 by ^4%s^1.", Arg1, szAdminName );

	nvault_set( g_VaultId, szAuthId, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}


public SrvcmdRestrictSteam( )
{
	/* Example of finding a target */
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user <amx_restrict_steam 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	new szAuthId[34];
	get_user_authid( PlayerId, szAuthId, cm(szAuthId) );

	nvault_set( g_VaultId, szAuthId, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}


public ClcmdRestrictName( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );

	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user <amx_restrict_name 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */


	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been ^4banned^1 by ^4%s^1.", Arg1, szAdminName );

	nvault_set( g_VaultId, Arg1, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}

public SrvcmdRestrictName( )
{
	/* Example of finding a target */
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user <amx_restrict_name 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}


	/* Doing the things after we find player */


	nvault_set( g_VaultId, Arg1, "1" );
	server_cmd("kick %s BANNED!", Arg1);

	return PLUGIN_HANDLED;
}


public cmdSconsole( id )
{
	/* Example of reading all arguments */
	new Args[64];

	read_args( Args, cm(Args) );

	if( Args[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify a correct command to be sended on server console." );
		return PLUGIN_HANDLED;
	}


	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}


	server_cmd("%s", Args );
	return PLUGIN_HANDLED;
}



public ClcmdAdmins( id )
{
	new Players[32], Num;
	get_players( Players, Num, "a" );

	client_print( id, print_console, "  +++ [AMXX %s] List of admins online +++ ", AMXX_BLUE_VERS );

	for( new i=0; i<Num; i++ )
	{
		if( is_user_admin( Players[i] ) )
		{
			new szName[32];
			get_user_name( Players[i], szName, cm(szName) );

			client_print( id, print_console, "%s", szName );
		}
	}
	return PLUGIN_HANDLED;
}

public SrvcmdAdmins(  )
{
	new Players[32], Num;
	get_players( Players, Num, "a" );

	server_print( "  +++ [AMXX %s] List of admins online +++ ", AMXX_BLUE_VERS );

	for( new i=0; i<Num; i++ )
	{
		if( is_user_admin( Players[i] ) )
		{
			new szName[32];
			get_user_name( Players[i], szName, cm(szName) );

			server_print( "%s", szName );
		}
	}
	return PLUGIN_HANDLED;
}


public check_say( id )
{
	if( gMute[id] )
	{
		client_print( id, print_center, "You have been 'MUTED' by an admin, this map you cannot use the chat!" )
		return PLUGIN_HANDLED;
	}	
	return PLUGIN_CONTINUE;
}

public ClcmdMute( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );
	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user please <amx_mute 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	gMute[PlayerId] = true;
	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been ^4muted^1 by ^4%s^1.", Arg1, szAdminName );

	return PLUGIN_HANDLED;
}

public ClcmdUnmute( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );
	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user please <amx_unmute 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	gMute[PlayerId] = false;
	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been ^4un-muted^1 by ^4%s^1.", Arg1, szAdminName );

	return PLUGIN_HANDLED;
}

public SrvcmdMute(  )
{
	/* Example of finding a target */
	new Arg1[64];

	read_argv( 1, Arg1, cm(Arg1) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user please <amx_mute 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}


	/* Doing the things after we find player */

	gMute[PlayerId] = true;

	return PLUGIN_HANDLED;
}

public SrvcmdUnmute( )
{
	/* Example of finding a target */
	new Arg1[64];

	read_argv( 1, Arg1, cm(Arg1) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user please <amx_mute 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}


	/* Doing the things after we find player */

	gMute[PlayerId] = false;

	return PLUGIN_HANDLED;
}

public ClcmdMap( id )
{
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify an corect map name!" );
		return PLUGIN_HANDLED;
	}

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	server_cmd( "changelevel %s",Arg1 );
	return PLUGIN_HANDLED;
}


public SrvcmdMap( id )
{
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify an corect map name!" );
		return PLUGIN_HANDLED;
	}

	server_cmd( "changelevel %s",Arg1 );
	return PLUGIN_HANDLED;
}

public ClcmdKick( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );
	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user please <amx_kick 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	server_cmd("kick %s", Arg1 );
	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been kicked by ^4%s^1.", Arg1, szAdminName );

	return PLUGIN_HANDLED;
}

public SrvcmdKick( )
{
	new Arg1[64];
	read_argv( 1, Arg1, cm(Arg1) );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user please <amx_kick 'Name'>" );
		return PLUGIN_HANDLED;
	}

	new PlayerId = find_player("al", Arg1 );

	if( !PlayerId || !is_user_connected(PlayerId) )
	{
		server_print("[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}
	
	server_cmd("kick %s", Arg1 );
	return PLUGIN_HANDLED;
}	


public ClcmdKill( id )
{
	/* Example of finding a target */
	new Arg1[64], szAdminName[32];

	read_argv( 1, Arg1, cm(Arg1) );
	get_user_name( id, szAdminName, cm( szAdminName ) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		client_print( id, print_console, "[AMXX-BLUE] Specify the name of the user please <amx_kill 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	if( !is_user_alive(PlayerId) )
	{
		client_print( id, print_console, "[AMXX-BLUE] '%s' is not alive, you can't execute this command on him.", Arg1 );
		return PLUGIN_HANDLED;		
	}

	/* Example checking if is admin and restrict his power */

	if( !is_user_admin(id) )
	{
		client_print( id, print_console, NoAccesMessage );
		return PLUGIN_HANDLED;
	}

	/* Doing the things after we find player */

	user_silentkill( PlayerId );
	print_colored_message( 0 , 0, "^1[ ^3AMXX-BLUE^1 ]^4%s^1 has been killed by ^4%s^1.", Arg1, szAdminName );

	return PLUGIN_HANDLED;
}


public SrvcmdKill( )
{
	/* Example of finding a target */
	new Arg1[64];

	read_argv( 1, Arg1, cm(Arg1) );

	new PlayerId = find_player("al", Arg1 );

	if( Arg1[0] == EOS )
	{
		server_print( "[AMXX-BLUE] Specify the name of the user please <amx_kill 'Name'>" );
		return PLUGIN_HANDLED;
	}

	if( !PlayerId )
	{
		server_print( "[AMXX-BLUE] '%s' not finded, try again with better description", Arg1 );
		return PLUGIN_HANDLED;
	}

	if( !is_user_alive(PlayerId) )
	{
		server_print( "[AMXX-BLUE] '%s' is not alive, you can't execute this command on him.", Arg1 );
		return PLUGIN_HANDLED;		
	}


	/* Doing the things after we find player */

	user_silentkill( PlayerId );
	return PLUGIN_HANDLED;
}