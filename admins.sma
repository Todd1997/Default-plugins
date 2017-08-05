#include <amxx>

new const PluginName[]	= "Admin System";

new Array:g_Stroke = Invalid_Array;
new bool:IsAdmin[MAX_PLAYERS_NUM+1];

new gAdminPassword;

public plugin_init( )
{
	register_plugin( PluginName, AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	gAdminPassword = register_cvar( "amx_admin_setinfo", "_pw" );
}

public client_authorized( id )
{
	// check if file is not empty
	if( ArraySize( g_Stroke ) )
	{
		static Stroke[64], Info[128], szCvar[100];
		get_pcvar_string(gAdminPassword, szCvar, cm(szCvar));
		
		get_user_info( id, szCvar, Info, cm(Info));
		for( new i=0; i < ArraySize(g_Stroke); i++ )
		{
			ArrayGetString( g_Stroke, i, Stroke, cm(Stroke) );
			IsAdmin[id] = bool:equali( Info, Stroke);
		}
	}
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

public plugin_cfg( )
{
	static File = 0, Buffer[64], Location[256];

	g_Stroke = ArrayCreate(64);
	get_localinfo("amxx_configsdir", Location, charsmax(Location));
	
	add(Location, charsmax(Location), "/admins.ini");
	
	// If file doesn't exist, we create one here
	if (!file_exists(Location))
	{
		File = fopen(Location, "w+");
		
		if (File)
		{
			fclose(File);
		}
	}

	// Here we will open and read the file
	File = fopen(Location, "rt");
	
	if (File)
	{
		while (!feof(File))
		{
			fgets(File, Buffer, charsmax(Buffer));
			
			trim(Buffer);
			
			if (!strlen(Buffer) || Buffer[0] == ';')
			{
				continue;
			}
			
			ArrayPushString(g_Stroke, Buffer);
		}
		fclose(File);
	}
}