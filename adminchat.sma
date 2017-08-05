#include <amxx>
#include <amxx_stocks>

public plugin_init( )
{
	register_plugin( "Admin Chat", AMXX_BLUE_VERS, AMXX_BLUE_TEAM );

	register_clcmd( "say_team", "say_check" );
}

public say_check(id)
{
	new Args[64];
	read_args(Args,cm(Args));
	remove_quotes(Args);

	new Name[32];
	get_user_name(id,Name,cm(Name));

	if( is_user_admin(id) )
	{
		print_colored_message( 0, GREY, "^1(ADMIN)^4%s^1: ^3%s", Name, Args );
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
	
}