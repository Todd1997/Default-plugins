/*
	Copyleft 2016 @ HamletEagle
	Plugin Thread: https://forums.alliedmods.net/showthread.php?t=259471
	
	Auto Plugins Adder to file is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Auto Plugins Adder; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/
#include <amxx>

#define Plugin  "Auto Plugins Adder"
#define Version "0.0.4"
#define Author  "HamletEagle"

new Trie:TriePluginsFromFile
new Array:ArrayPlugins

new HandleDir
new CurrentDir[128]
new CurrentFileName[256]

new CvarLoadFromCustomDir
new CvarLoadOnlyWithPrefix
new CvarRequieredPrefix

public plugin_init()
{
	register_plugin
	(
		.plugin_name = Plugin, 
		.version     = Version, 
		.author      = Author
	)
	
	CvarLoadFromCustomDir  = register_cvar("load_from_custom_dir"    , "0"      )
	CvarLoadOnlyWithPrefix = register_cvar("load_plugins_with_prefix", "0"      )
	CvarRequieredPrefix    = register_cvar("requiered_prefix"        , "_prefix")
	
	TriePluginsFromFile = TrieCreate()
	ArrayPlugins        = ArrayCreate(120)
	
	ReadPluginsFolder()
}

ReadPluginsFolder()
{
	get_localinfo("amxx_pluginsdir", CurrentDir, charsmax(CurrentDir))
	
	if(get_pcvar_num(CvarLoadFromCustomDir))
	{
		new const CustomFolder[] = "autoloader"
		format(CurrentDir, charsmax(CurrentDir), "%s/%s", CurrentDir, CustomFolder)
		
		if(!dir_exists(CurrentDir))
		{
			mkdir(CurrentDir)
		}
	}
	
	HandleDir = open_dir(CurrentDir, CurrentFileName, charsmax(CurrentFileName))
	if(HandleDir)
	{
		new const Extension[] = ".amxx"
		new CheckForPrefix = get_pcvar_num(CvarLoadOnlyWithPrefix)
		new NeededPrefix[10], PosToCheck, bool:Replace
		
		if(CheckForPrefix)
		{
			get_pcvar_string(CvarRequieredPrefix, NeededPrefix, charsmax(NeededPrefix))
			PosToCheck = strlen(NeededPrefix)
		}
		
		//Get all plugins from plugins dir
		while(next_file(HandleDir, CurrentFileName, charsmax(CurrentFileName)))
		{
			if(contain(CurrentFileName, Extension) != -1)
			{
				Replace = true
				if(CheckForPrefix)
				{
					Replace = !!equal(CurrentFileName, NeededPrefix, PosToCheck)
				}
				
				if(Replace)
				{
					ArrayPushString(ArrayPlugins, CurrentFileName)
				}
			}
		}
		
		close_dir(HandleDir)
		ParsePluginsFiles()
	}
	else
	{
		log_amx("Plugins folder could not be found")
		pause("a")
	}
}

ParsePluginsFiles()
{    
	new const OpenFlags[] = "rt"
	
	//Step 1: parse plugins.ini file
	get_localinfo("amxx_plugins", CurrentDir, charsmax(CurrentDir))
	ReadFile(fopen(CurrentDir, OpenFlags))
	
	//Step 2: parse plugins-.ini files
	get_localinfo("amxx_configsdir", CurrentDir, charsmax(CurrentDir))
	
	HandleDir = open_dir(CurrentDir, CurrentFileName, charsmax(CurrentFileName))
	if(HandleDir)
	{
		while(next_file(HandleDir, CurrentFileName, charsmax(CurrentFileName)))
		{
			if(equal(CurrentFileName, "plugins-", 8))
			{
				format(CurrentFileName, charsmax(CurrentFileName), "%s/%s", CurrentDir, CurrentFileName)
				ReadFile(fopen(CurrentFileName, OpenFlags))
			}
		}
		
		close_dir(HandleDir)
	}
	
	//Step 3: parse custom configuration per map name
	new const MapFile[] = "maps"
	format(CurrentDir, charsmax(CurrentDir), "%s/%s", CurrentDir, MapFile)

	HandleDir = open_dir(CurrentDir, CurrentFileName, charsmax(CurrentFileName))
	if(HandleDir)
	{
		while(next_file(HandleDir, CurrentFileName, charsmax(CurrentFileName)))
		{
			if(equal(CurrentFileName, "plugins_", 8))
			{
				format(CurrentFileName, charsmax(CurrentFileName), "%s/%s", CurrentDir, CurrentFileName)
				ReadFile(fopen(CurrentFileName, OpenFlags))
			}
		}
		
		close_dir(HandleDir)
	}
	
	AddPlugins()
}

ReadFile(FilePointer)
{
	if(FilePointer)
	{
		new FileData[128], Needed[128], UnNeeded[128]
		
		while(!feof(FilePointer))
		{
			fgets(FilePointer, FileData, charsmax(FileData))
			trim(FileData)
			
			if(FileData[0] != EOS)
			{
				parse(FileData, Needed, charsmax(Needed), UnNeeded, charsmax(UnNeeded))
				
				if(Needed[0] == ';' && Needed[1] != EOS)
				{
					copy(Needed, charsmax(Needed), Needed[1])
				}
				
				TrieSetCell(TriePluginsFromFile, Needed, 0)
			}
		}
		
		fclose(FilePointer)
	}
}

AddPlugins()
{    
	new i, PluginName[120]
	for(i = 0; i < ArraySize(ArrayPlugins); i++)
	{
		ArrayGetString(ArrayPlugins, i, PluginName, charsmax(PluginName))
		if(TrieKeyExists(TriePluginsFromFile, PluginName))
		{    
			ArrayDeleteItem(ArrayPlugins, i)
			i = i - 1
		}
	}
	
	TrieDestroy(TriePluginsFromFile)
	
	new bool:FileEdited, Size = ArraySize(ArrayPlugins)
	if(Size)
	{
		get_localinfo("amxx_plugins", CurrentDir, charsmax(CurrentDir))
		
		new FilePointer = fopen(CurrentDir, "a")
		if(FilePointer)
		{
			for(i = 0; i < Size; i++)
			{
				ArrayGetString(ArrayPlugins, i, PluginName, charsmax(PluginName))
				fprintf(FilePointer, "%s^n", PluginName)
			}
			
			fclose(FilePointer)
			FileEdited = true
		}
	}
	
	ArrayDestroy(ArrayPlugins)
	
	if(FileEdited)
	{
		//Restart so all new added plugins are loaded
		server_cmd("restart")
	}
}  