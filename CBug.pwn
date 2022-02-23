/*

		Filterscript criado por William Borges Padilha

*/


#include <a_samp>
#include <tick-difference> //Essa include � necess�ria para a compila��o, voc� pode obt�-la em: https://github.com/ScavengeSurvive/tick-difference
#include <dof2> //Essa include � necess�ria para a compila��o. Infelizmente n�o h� publica��o original, mas voc� ainda pode obt�-la em sites de terceiros.

#define COLOUR_INFORMACAO 0x00FF00FF
#define COLOUR_ERRO 0xFF0000FF

// Vari�veis individuais
new Contando[MAX_PLAYERS],
TimerCbug[MAX_PLAYERS],
Tiros[MAX_PLAYERS],
Tempo[MAX_PLAYERS];

public OnFilterScriptInit()
{
	print("\n--------------------------------------\n");
	print("Filterscript de C Bug por Will_33 \n");
	print("--------------------------------------\n");
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[128];
    new idx;
    
    cmd = strtok(cmdtext, idx);
    
	if(strcmp(cmd, "/cbug", true) == 0 )
	{
		if(GetPlayerWeapon(playerid) != 24) return SendClientMessage(playerid, COLOUR_ERRO, "{C14124}[CBUG]{FFFFFF} Voc� deve estar com uma desert eagle em m�os!");
		SendClientMessage(playerid, COLOUR_INFORMACAO, "{C14124}[CBUG]{FFFFFF} O contador come�ar� ao dar o primeiro tiro, voc� deve acertar uma superf�cie para o tiro contar");

		Contando[playerid] = 1;
		
		Tempo[playerid] = 0;// Reseta as vari�veis por precau��o
		Tiros[playerid] = 0;
		
		TimerCbug[playerid] = SetTimerEx("ResetContando",30000,false, "i", playerid); //Se em 30 segundos n�o come�ar, desativa a contagem.
		return 1;
	}
	
	if(strcmp(cmd, "/rankingcbug", true) == 0 )
	{
		new file[128];
		format(file,sizeof(file),"RankingCbug.txt");

		if(!DOF2_FileExists(file)) //Caso o ranking ainda n�o tenha sido criado
		{
			return SendClientMessage(playerid, COLOUR_ERRO, "{FF8C00}[ERRO]{FFFFFF} O ranking ainda n�o foi criado, use /cbug!");
		}

		new Ranks[3000];
		for(new i = 1; i<10; i++)
		{
		    new Linha[300];
		    new string[20], NomeC[MAX_PLAYER_NAME], Temp;

		    format(string, sizeof(string), "Pos %d",i);
			Temp = DOF2_GetInt(file, string);

			format(string, sizeof(string), "NPos %d",i);
			format(NomeC, sizeof(NomeC), "%s", DOF2_GetString(file, string));

		    format(Linha, sizeof(Linha), "{FFFFFF}Posi��o %i | Nome: {FF8C00}%s {FFFFFF}| Tempo: {FF8C00}%i ms\n",i,NomeC,Temp);
			strins(Ranks,Linha,strlen(Ranks));
		}
		strins(Ranks,"\n{FFFFFF}Para participar use {00CED1}/cbug",strlen(Ranks));
		ShowPlayerDialog(playerid,3481,DIALOG_STYLE_MSGBOX,"� Ranking C-Bug �",Ranks,"OK","");//Mostra o ranking de 1 a 10 em um di�logo
		return 1;
	}
	return 0;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(weaponid == 24)//Desert Eagle
	{
	    if(Contando[playerid] == 1)
	    {
	    	Tiros[playerid] ++;
	    	if(Tiros[playerid] == 1)
	    	{
				Tempo[playerid] = GetTickCount();//Pega o tempo em ms inicial
				SendClientMessage(playerid, COLOUR_INFORMACAO, "{C14124}[CBUG]{FFFFFF} A contagem come�ou!");
	    	}
	        if(Tiros[playerid] == 7)
	        {
	            new String[128];
	            new DiferencaTempo;
	            DiferencaTempo = GetTickCountDifference(GetTickCount(),Tempo[playerid]);//Faz a diferen�a do tempo inicial com o final
				format(String, sizeof(String), "{C14124}[CBUG]{FFFFFF} O seu tempo foi de %i ms",DiferencaTempo);
	        	SendClientMessage(playerid, COLOUR_INFORMACAO, String);
	        	KillTimer(TimerCbug[playerid]);
	        	AtualizarRankingCbug(playerid,DiferencaTempo);
	        }
	    }
	}
	return 1;
}

forward ResetContando(playerid);
public ResetContando(playerid)
{
	SendClientMessage(playerid, COLOUR_ERRO, "{C14124}[CBUG]{FFFFFF} Voc� demorou demais e o contador foi desfeito");
	Contando[playerid] = 0;
	Tempo[playerid] = 0; //Reseta todas as vari�veis
	Tiros[playerid] = 0;
	return 1;
}

forward AtualizarRankingCbug(playerid,Time);
public AtualizarRankingCbug(playerid,Time)
{
	new Temp;
	new file[300];
	new NomeB[MAX_PLAYER_NAME];

    GetPlayerName(playerid, NomeB, MAX_PLAYER_NAME);
	format(file,sizeof(file),"RankingCbug.txt");

	if(!DOF2_FileExists(file))
	{
		DOF2_CreateFile(file);
		for(new s = 1;s<10;s++)
		{
		    new string[20];
		    format(string, sizeof(string), "Pos %d",s);
			DOF2_SetInt(file, string, 30000);//Cria espa�o para o tempo
			format(string, sizeof(string), "NPos %d",s);
			DOF2_SetString(file, string, "Ninguem");//Cria espa�o para o nome
		}
		DOF2_SaveFile();
	}

	for(new x = 1;x<10;x ++) //Percorre o arquivo de ranking
	{
		new string[20];
  		format(string, sizeof(string), "Pos %d",x);
		Temp = DOF2_GetInt(file, string);

		if(Time < Temp)//Substitui a posi��o mais alta, caso o tempo tenha sido menor
		{
			DOF2_SetInt(file, string, Time);
			format(string, sizeof(string), "NPos %d",x);
            DOF2_SetString(file, string, NomeB);
            DOF2_SaveFile();
            
            new String[128];
            format(String, sizeof(String), "{C14124}[CBUG]{FFFFFF} Parab�ns, voc� ficou em %d� lugar no ranking",x);
            SendClientMessage(playerid, COLOUR_INFORMACAO, String);
			break;
		}
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(Contando[playerid] == 1)
	{
		Contando[playerid] = 0;
		KillTimer(TimerCbug[playerid]);
		Tempo[playerid] = 0; //Reseta todas as vari�ves e acaba com o timer
		Tiros[playerid] = 0;
	}
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(Contando[playerid] == 1)
	{
		Contando[playerid] = 0;
		KillTimer(TimerCbug[playerid]);
		Tempo[playerid] = 0; //Reseta todas as vari�ves e acaba com o timer
		Tiros[playerid] = 0;
	}
}

/*

		FUN��ES FEITAS POR TERCEIROS

*/

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}
