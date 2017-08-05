#include <amxx>
#include <amxx_stocks>

new const PluginName []	=	"Admin Menus";
new const NoAccesMes [] =	"^4[ ^3AMXX BLUE ^4] ^1You have no acces to this command.";

new gMapMenuId;
new gPlayerMenuId;
new gMenuId;

new gMenuOffset[ MAX_PLAYERS_NUM+1 ];

new const gBSP[] = ".bsp"; 

new const szMenuCommands[] [] =
{
	// Menu Names		|	Menu Offsets.

	"kill menu:",			// 0
	"Restrict Ip Menu:",		// 1
	"Restrict Steam Menu:",		// 2
	"Restrict Name Menu:",		// 3
	"Kick Menu:",			// 4
	"Mute Menu:",			// 5
	"Unmute Menu:",			// 6
	"change Map:"			// 7

};


public plugin_init( )
{
	register_plugin( PluginName, AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	Register( "/menu" );
	Register( ".menu" );
	Register(  "menu" );	
}

Register( Cmd[] )
{
	new Buffer[50], Buffer2[50];

	formatex( Buffer, cm(Buffer) , "say %s", Cmd );
	formatex( Buffer2, cm(Buffer2), "say_team %s", Cmd );

	register_clcmd( Buffer, "Show_Menu" );
	register_clcmd( Buffer2, "Show_Menu" );
}

public Show_Menu( id )
{
	if( !is_user_admin( id ) )
	{
		print_colored_message( id, id, NoAccesMes );
		return PLUGIN_HANDLED;
	}

	CreateMenu( id );
	return PLUGIN_HANDLED;
}

public PlayersMenuHandler( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	new szInfo[3], _acc, _callback, ItemName[32];
	menu_item_getinfo( menu, item, _acc, szInfo, cm(szInfo), ItemName, cm(ItemName), _callback );

	switch( gMenuOffset[ id ] )
	{
		case 0: server_cmd( "amx_kill %s", ItemName );
		case 1: server_cmd( "amx_restrict_ip %s", ItemName );
		case 2: server_cmd( "amx_restrict_steam %s", ItemName );
		case 3: server_cmd( "amx_restrict_name %s", ItemName );
		case 4: server_cmd( "amx_kick %s", ItemName );
		case 5: server_cmd( "amx_mute %s", ItemName );
		case 6: server_cmd( "amx_unmute %s", ItemName );
	}
			
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public MenusHandle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
    
	gMenuOffset[ id ] = item;

	if( item != 7 )
		CreatePlayersMenu( id, szMenuCommands[item] );
	else
		CreateMapMenu( id );

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public CreateMenu( id )
{
	gMenuId = menu_create( "Admin Menus", "MenusHandle" );

	for( new i=0; i < sizeof(szMenuCommands); i++ )
	{
		menu_additem( gMenuId, szMenuCommands[i], "", 0 );
	}

	menu_setprop( gMenuId, MPROP_EXIT, MEXIT_ALL );

	menu_display( id, gMenuId, 0 );

	return PLUGIN_HANDLED;
}	

public CreatePlayersMenu( id, szTitle[] )
{
	gPlayerMenuId = menu_create( szTitle, "PlayersMenuHandler" );

	new Players[32], Num;
	get_players( Players, Num );

	for( new i=0, PlayersId; i<Num; i++ )
	{
		PlayersId = Players[i];
	
		new szName[32];
		get_user_name( PlayersId, szName, cm(szName) );

		menu_additem( gPlayerMenuId, szName, "", 0 );
	}

	menu_setprop( gPlayerMenuId, MPROP_EXIT, MEXIT_ALL );

	menu_display( id, gPlayerMenuId, 0 );

}

public CreateMapMenu( id )
{
	gMapMenuId = menu_create( szMenuCommands[7], "MapHandle" );

	new fileName[ 32 ] , len;
	new handleDir = open_dir( "maps/", fileName, charsmax( fileName ) );
    
	if ( !handleDir )
	{
		return;
	}

	do
	{
		len = strlen( fileName );
        
		if ( ( len > 4 ) && ( equali( fileName[ len - 4 ] , gBSP , 4 ) ) )
 		{
			replace_all( fileName, cm(fileName), gBSP, "" );
 			menu_additem( gMapMenuId, fileName, "", 0 );
		}
 	}   
	while ( next_file( handleDir, fileName, charsmax( fileName ) ) );
 	
	close_dir( handleDir );

	menu_setprop( gMapMenuId, MPROP_EXIT, MEXIT_ALL );

	menu_display( id, gMapMenuId, 0 );
	
}

public MapHandle( id, menu, item )
{
	if( item == MENU_EXIT )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}

	new szInfo[3], _acc, _callback, ItemName[32];
	menu_item_getinfo( menu, item, _acc, szInfo, cm(szInfo), ItemName, cm(ItemName), _callback );	

	server_cmd( "amx_map %s", ItemName );

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}