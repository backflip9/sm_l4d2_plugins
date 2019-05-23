#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

#define PLUGIN_VERSION "0.0"

public Plugin myinfo =
{
	name = "[L4D2]Witch Adrenaline Boost",
	author = "Backflip9",
	description = "Instakill witch within 10 seconds of using adrenaline",
	version = PLUGIN_VERSION,
	url = "streamercabin.net"
};

static bool hasAdrenaline[MAXPLAYERS+1];

public void OnPluginStart()
{
	//CreateConVar("l4d2_witch_adrenaline_boost_version", PLUGIN_VERSION, "[L4D2]Witch_Adrenaline_Boost", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
  for(int i=0;i<MAXPLAYERS+1;i++)
  {
    hasAdrenaline[i]=false;
  }
  PrintToServer("[l4d2 WAB]STARTING... DONE");
  PrintToConsoleAll("[l4d2 WAB]STARTING... DONE");
  HookEvent("adrenaline_used",Event_Adrenaline_Used2);
  HookEvent("infected_hurt", Event_Infected_Hurt2);
	
	//HookAll();
}


public void Event_Infected_Hurt2(Handle event,const char[] name, bool dontBroadcast)
{
  //get client index
  int attackerInt=GetEventInt(event,"attacker");
  int attacker_client=GetClientOfUserId(attackerInt);
  if(IsFakeClient(attacker_client)){return;}
  int victim=GetEventInt(event,"entityid");
  PrintToServer("Infected Hurt: %d",victim);
  PrintToConsoleAll("Infected Hurt: %d",victim);
  PrintToServer("[l4d2 WAB]attackerInt: %d",attackerInt);
  PrintToServer("[l4d2 WAB]attacker_client: %d",attacker_client);
  char clientName[32];
  if(GetClientName(attacker_client,clientName,sizeof(clientName)))
  {
    PrintToServer("[l4d2 WAB]attacker: %s",clientName);
    PrintToConsoleAll("[l4d2 WAB]attacker: %s",clientName);
  }
  else
  {
    PrintToServer("[l4d2 WAB]failed to retrieve client name of client: %d",attacker_client);
    PrintToConsoleAll("[l4d2 WAB]failed to retrieve client name of client: %d",attacker_client);
  }
  //is adrenaline active?
  //if(!GetEntProp(attacker_client, Prop_Send, "m_bAdrenalineActive", 1))
  //if(hasAdrenaline[attacker_client])
  if(hasAdrenaline[attackerInt])//i dont understand the difference between this and the client id /shrug
  {
    PrintToServer("[l4d2 WAB]adrenaline is active!!!!!!!!!!!!!!!!!!");
    PrintToConsoleAll("[l4d2 WAB]adrenaline is active!");
    //get weapon type
    if( attacker_client && IsClientInGame(attacker_client) && IsPlayerAlive(attacker_client) && GetClientTeam(attacker_client) == 2 )
    {
      int weapon = GetEntPropEnt(attacker_client, Prop_Send, "m_hActiveWeapon");
      if( weapon > 0 && IsValidEntity(weapon) )
      {
        char weaponName[32];
        if(GetEntityClassname(weapon, weaponName, sizeof(weaponName)))
        {
          PrintToServer("[l4d2 WAB]weapon name: %s",weaponName);
          PrintToConsoleAll("[l4d2 WAB]weapon name: %s",weaponName);
          //is this a melee weapon?
          if(strcmp(weaponName,"weapon_melee")==0)
          {
            if(GetEntityClassname(victim,weaponName,sizeof(weaponName)))
            {// is the enemy a witch?
              if(strcmp(weaponName,"witch")==0)
              {
                PrintToServer("[l4d2 WAB]KILLING WITCH: %s",weaponName);
                PrintToConsoleAll("[l4d2 WAB]KILLING WITCH: %s",weaponName);

                AcceptEntityInput(victim,"Kill");
                //SetEntityHealth(victim,0);

              }
            }
            else
            {
              PrintToServer("[l4d2 WAB]failed to retrieve class name of infected: %d",attacker_client);
              PrintToConsoleAll("[l4d2 WAB]failed to retrieve class name of infected: %d",attacker_client);
            }
            
          }
        }
        else
        {
          PrintToServer("[l4d2 WAB]failed to retrieve weapon name of client: %d",attacker_client);
          PrintToConsoleAll("[l4d2 WAB]failed to retrieve weapon name of client: %d",attacker_client);
        }
      }
      else
      {
        PrintToServer("[l4d2 WAB]invalid weapon");
        PrintToConsoleAll("[l4d2 WAB]invalid weapon");
      }
    }
    hasAdrenaline[attacker_client]=false;
    PrintToServer("[l4d2 WAB]DEACTIVATED BOOST");
    PrintToConsoleAll("[l4d2 WAB]DEACTIVATED BOOST");
  }
  else
  {
    PrintToServer("[l4d2 WAB]adrenaline is not present");
    PrintToConsoleAll("[l4d2 WAB]adrenaline is not present");
  }

  //return Plugin_Handled;
}

public void Event_Adrenaline_Used2(Handle event,const char[] name, bool dontBroadcast)
{
  int aIndex=GetEventInt(event,"userid");
  PrintToServer("[l4d2 WAB]client used adrenaline: %d",aIndex);
  hasAdrenaline[aIndex]=true;
  CreateTimer(10.0,disableAdrenalineBoost,GetClientSerial(aIndex));
}

public Action disableAdrenalineBoost(Handle timer,any serial)
{
  int this_client=GetClientFromSerial(serial);
  PrintToServer("[l4d2 WAB]adrenaline timer ran out for client: %d",this_client);
  if(this_client==0)
  {
    return Plugin_Stop;
  }
  hasAdrenaline[this_client]=false;
  return Plugin_Handled;
}
