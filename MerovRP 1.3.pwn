//Admin Skin - 98
//MerovRP v1.3
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include 			<a_samp>
#include 			<a_mysql>
#include 			<foreach>
#include 			<mxdate>
#include 			<Pawn.CMD>
#include 			<sscanf2>
#include 			<streamer>
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ���� ������ ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define MySQL_HOST 	"127.0.0.1" //�������, ���������, ������� ���������� ������ ���������� � ��������
#define MySQL_USER 	"root"
#define MySQL_DB 	"MerovRP"
#define MySQL_PASS  ""
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ����� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define ColorWhite	0xFFFFFFFF
#define ColorGrey   0xA6A69FFF
#define ColorGrey2 	0xC8C8C8C8
#define ColorGrey3 	0xAAAAAAAA
#define ColorGrey4 	0x8C8C8C8C
#define ColorRed 	0xFF0000FF
#define ColorGreen 	0x008000FF
#define ColorBlue 	0xFF0000FF
#define ColorYellow 0xFFFF00FF
#define ColorBlack 	0x000000FF
#define ColorOrange 0xDF8600FF
//
#define TEAM_GREEN_COLOR 0xFFFFFFAA
#define TEAM_JOB_COLOR 0xFFB6C1AA
#define TEAM_HIT_COLOR 0xFFFFFF00
#define TEAM_BLUE_COLOR 0x8D8DFF00
#define TEAM_GROVE_COLOR 0x00D900C8
#define TEAM_VAGOS_COLOR 0xFFC801C8
#define TEAM_BALLAS_COLOR 0xD900D3C8
#define TEAM_AZTECAS_COLOR 0x01FCFFC8
#define TEAM_CYAN_COLOR 0xFF8282AA
#define TEAM_ORANGE_COLOR 0xFF830000
#define TEAM_COR_COLOR 0x39393900
#define TEAM_BAR_COLOR 0x00D90000
#define TEAM_TAT_COLOR 0xBDCB9200
#define TEAM_CUN_COLOR 0xD900D300
#define TEAM_STR_COLOR 0x01FCFF00
#define TEAM_ADMIN_COLOR 0x00808000
#define OBJECTIVE_COLOR 0x64000064
#define Grov 0x00E500AA
#define TEAM_RM 0x0B110DAA
#define TEAM_RIFA 0x3B8DF6AA
#define TEAM_TRIAD 0xF60000AA
#define TEAM_BAIK 0x93480CAA
#define TEAM_BALLAS 0xDBBEA3AA
#define TEAM_VAGOS 0xE46BF6AA
#define TEAM_CORONOS 0xF6F65AAA
#define TEAM_STREETRACIN 0x4DCDF6AA
#define TEAM_LIC 0xD9F6F6AA
#define TEAM_TAX 0xF6DC00AA
#define TEAM_HITMANS 0x000000AA
#define TEAM_MER 0x961929AA
#define TEAM_YAK 0xF6F6AFAA
#define TEAM_LCN 0x006F70AA
#define TEAM_MEDIK 0xF60000AA
#define TEAM_ARM 0x00671FAA
#define TEAM_FBI 0x0063AFAA
#define TEAM_COP 0x0100F6AA
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define GM_NAME			!"=== [MerovRP v1.3] ==="
#define GN(%0)			player_name[%0]//������ � �����������, %0 - ���������� ����� ��������� �������
#define SCM     		SendClientMessage
#define SPD 			ShowPlayerDialog
#define Tkick(%0)   	SetTimerEx("@_PlayerKick", 100, false, "i",%0)
#define Freeze(%0,%1) 	TogglePlayerControllable(%0, %1)
#define SCMTA    		SendClientMessageToAll

#define MAX_LEADER_NUM 	1

#if !defined isnull//������� (1 - ��� ����������� strlen();)
#define isnull(%0)      ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ���������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
new
	connect_mysql,
	hour_server,
 	minute_server,
  	second_server,
	
	number_skin[MAX_PLAYERS char],//�������� �������
	number_pass[MAX_PLAYERS char],
	update_timer[MAX_PLAYERS],
	login_timer[MAX_PLAYERS],
	player_name[MAX_PLAYERS][MAX_PLAYER_NAME],
	report_timer[MAX_PLAYERS],
 	//MAX_LEADER[7] = "1)]",
	
	Text: td_select_skin[MAX_PLAYERS][3],//���������� ��� �����������
	Text: td_uper_text[MAX_PLAYERS][4],
	
	lspd_pick[7],// ������ ����
	lspd_car[27],// ��������� ����
	
	Float: pos_pick[3][MAX_PLAYERS],//���������� ���� float
	
	bool: login_check[MAX_PLAYERS char],//���������� ��� ����, ��� �������� �����������
	bool: report_check[MAX_PLAYERS char],
	bool: access_check[MAX_PLAYERS char],
	bool: anti_flood_pick[MAX_PLAYERS char],
	
	sex_info[2][7+1] = {"�������", "�������"},//��������� �������
	nations_info[5][10+1] = {"�������", "����������", "������", "������", "���������"},
	leaders_info[1][4+1] = {"LSPD"},// �������
	Iterator: connect_admins<MAX_PLAYERS>;//���������
enum pinfo //�������� ���������
{
	ppass[32+1], pmail[70+1], plevel, pmoney, psex, pskin, page, pnations, pid, preferal_check, preferal[MAX_PLAYER_NAME+1], pdate_reg[11+1], pexp, pmaxexp,
	padmin, pdonate, pakeys, pakey[20+1], pmember, prank, pmodel//��� ���������� �� ��, +1 ��� ����-�����������
}
new player[MAX_PLAYERS][pinfo];//MAX_PLAYERS
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])//������ �������
{
	switch(dialogid)
	{
	    case 1:
	    {
   			if(response)//���� ������ ����� �������
   			{
				new
				    len = strlen(inputtext);
   			    if(!len)
   			    {
					SCM(playerid, ColorGreen, !"�� ������ �� �����");
					DialogRegistration(playerid);
					return true;
			   	}
			   	if(!(6 <= len <= 32))
			   	{
			   	    SCM(playerid, ColorGreen, !"�������� ����� ������");
					DialogRegistration(playerid);
					return true;
		   		}
		   		if(CheckRussianText(inputtext, len+1))// �������� �� ������� �������
		   		{
					SCM(playerid, ColorGreen, !"������� ��������� ����������!");
					DialogRegistration(playerid);
					return true;
				}
				strmid(player[playerid][ppass], inputtext, 0, len, 32+1);//������ ������/�������� � ������ - ���� ����������, ������, � ������ �������, ����� ������, ������������ ����� ������������ ������
				DialogEmail(playerid);
      		}
		   	else //���� ������ ������ �������
		   	{
				SCM(playerid, ColorRed, !"������� (/q)uit ����� �����");
		   	    Tkick(playerid);
		   	}
		}
   	 case 2:
     {
   			if(response)
   			{
          		new
				    len = strlen(inputtext);
   			    if(!len)
   			    {
					SCM(playerid, ColorGreen, !"�� ������ �� �����");
					DialogEmail(playerid);
					return true;
			   	}
			   	if(!(6 <= len <= 70))
			   	{
			   	    SCM(playerid, ColorGreen, !"�������� ����� �����");
					DialogEmail(playerid);
					return true;
		   		}
		   		if(strfind(inputtext, "@", false) == -1 || strfind(inputtext, ".", false) == -1)//���� ������ � ������ - ������, �����, ����������� �� �������
		   		{
		   		    SCM(playerid, ColorGreen, !"�������� ������ �����!");
					DialogEmail(playerid);
					return true;
		   		}
		   		if(CheckRussianText(inputtext, len+1))// �������� �� ������� �������
		   		{
					SCM(playerid, ColorGreen, !"������� ��������� ����������!");
					DialogRegistration(playerid);
					return true;
				}
				strmid(player[playerid][pmail], inputtext, 0, len, 70+1);//������ ������/�������� � ������ - ���� ����������, ������, � ������ �������, ����� ������, ������������ ����� ������������ ������
				DialogNation(playerid);
	 			}
	  	 		else
	  	 		{
	  	 	    	DialogRegistration(playerid);
		   		}
		}
        case 3:
     	{
   			if(response)
   			{
  				player[playerid][pnations] = listitem+1;
  				DialogAge(playerid);
			}
 			else
	 		{
    			DialogEmail(playerid);
	   		}
		}
		case 4:
     	{
   			if(response)
   			{
   			    new
   			        val = strval(inputtext);
  				if(!strlen(inputtext))
   			    {
					SCM(playerid, ColorGreen, !"�� ������ �� �����");
					DialogRegistration(playerid);
					return true;
			   	}
			   	if(!(18 <= val <= 70))
			   	{
			   	    SCM(playerid, ColorGreen, !"������� �� ����� ���� ������ 18-�� ��� ������ 70-�� ���!");
					DialogAge(playerid);
					return true;
		   		}
				player[playerid][page] = val;
				DialogReferal(playerid);
			}
 			else
	 		{
    			DialogNation(playerid);
	   		}
		}
		case 5:
     	{
   			if(response)
   			{
	  			if(isnull(inputtext))
   			    {
					SCM(playerid, ColorGreen, !"�� ������ �� �����");
					DialogReferal(playerid);
					return true;
			   	}
			   	static //������� const, ���� ���������� mysql format
			    fmt_str[] = "SELECT `Level` FROM `accounts` WHERE `Name` = '%e' LIMIT 1";//���-���� �� �� ��������, �� �����
				new
				    string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//�������� 2 ��-�� %s, +1 ��-�� ����-�����������

				mysql_format(connect_mysql, string, sizeof(string), fmt_str, (inputtext));
				mysql_function_query(connect_mysql, string, true, "@_CheckRef", "de", playerid, inputtext);//@_PlayerCheck - ������, d - ���������(id ������)
				//SCM(playerid, ColorWhite, string);//��������� ��������� ������ � ����
			}
 			else
	 		{
	 		    //strmid(player[playerid][preferal], "None", 0, strlen("None"), 4+1);//���� ������ ������ "����������", � �������� ������������ ����� "None"
    			DialogSex(playerid);
	   		}
		}
		case 6:
     	{
     	    SpawnPlayer(playerid);
   			if(response)
   			{
	  			player[playerid][psex] = 1;//�������
	  			SetPlayerSkin(playerid, 78);//��������� ����� ������ (id ������, ����� �����)
				number_skin{playerid} = 1;//{} - �.� ���������� �������� char, �������� char ������ �������������, ���� �������� ���������� ������, ��� 255 � � ��������
		   	}
 			else
	 		{
    			player[playerid][psex] = 2;//�������
    			SetPlayerSkin(playerid, 10);
    			number_skin{playerid} = 11;
	   		}
	   		
	   		for(new i; i!=3; i++)
	   		{
	   		TextDrawShowForPlayer(playerid, td_select_skin[playerid][i]);
	   		}
	   		SelectTextDraw(playerid, 0xFF0000FF);//��� ��������� �� ���������, ��������� ��������������(������ ���� �� �������)
	   		SetPlayerVirtualWorld(playerid, playerid);//������ ��������� ��� ��� ������, ���������� ��� ����, ����� ����� �� ������������ � ������� ��������(id ������, id ������������ ����)
			SetPlayerInterior(playerid, 3);//��������� ������ � ��������(id ������, id ���������)
			SetPlayerPos(playerid, 513.4482,-13.6003,1001.5653);//����������� ������ �� ������� ���������
			SetPlayerFacingAngle(playerid, 343.2249);//������� ������
			SetPlayerCameraPos(playerid, 514.7122, -9.7444, 1001.5653);//��������� ������� ������
			SetPlayerCameraLookAt(playerid, 513.4482,-13.6003,1001.5653);//�� ��� ������� ������
			Freeze(playerid, 0);//��������� ������: 0 - ���������, 1 - ���������� (TogglePlayerControllable(playerid, 0))
		}
		case 7:
     	{
   			if(response)
   			{
   			    if(isnull(inputtext))
   			    {
					SCM(playerid, ColorGreen, !"�� ������ �� �����");
					DialogLogin(playerid);
					return true;
			   	}
			   	static //������� const, ���� ���������� mysql format
    				fmt_str[] = "SELECT * FROM `accounts` WHERE `Name` = '%s' AND `Pass` = '%s' LIMIT 1";//���-���� �� �� ��������, �� �����
				new
	    			string[sizeof(fmt_str)+MAX_PLAYER_NAME+29];

				mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid), inputtext);
				mysql_function_query(connect_mysql, string, true, "@_OnLogin", "d", playerid);
			   	
			}
 			else
	 		{
    			SCM(playerid, ColorRed, !"������� (/q)uit ����� �����");
		   	    Tkick(playerid);
	   		}
		}
		case 8://menu
     	{
   			if(response)
   			{
   			    switch(listitem)
   			    {
   			        case 0: ShowPers(playerid);
   			        case 1: ShowGPS(playerid);
   			        case 2: ShowOnline(playerid);
   			        case 3: ShowComm(playerid);
   			        case 4: ShowSet(playerid);
   			        case 5: ShowMis(playerid);
			   	}

			}
		}
		case 9://ShowPers
     	{
   			if(response)
   			{
   			    switch(listitem)
   			    {
   			        case 0: ShowStat(playerid, playerid);
   			        case 1: ShowSkills(playerid);
   			        case 2: ShowLic(playerid);
			   	}

			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 10://ShowGPS
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 11://ShowOnline
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 12://ShowComm
		{
		    if(response)
   			{
   			    switch(listitem)
   			    {
   			        case 0: ComBase(playerid);// ��������
   			        /*case 1: ComWork(playerid);// ������
   			        case 2: ComChat(playerid);// ���
   			        case 3: ComPhone(playerid);// �������
   			        case 4: ComHome(playerid);// ���/�����
   			        case 5: ComBiz(playerid);// ������
   			        case 6: ComVeh(playerid);// ���������
   			        case 7: ComFood(playerid);// �������/���
   			        case 8: ComWed(playerid);// �������
   			        case 9: ComIRC(playerid);// IRC
   			        case 10: ComLeder(playerid);// ���������
   			        case 11: ComAnim(playerid);// ��������
   			        case 12: ComRull(playerid);// ���������
   			        case 13: ComLoy(playerid);// ��������
   			        case 14: ComMCHS(playerid);// ���
   			        case 15: ComTaxi(playerid);// �����
   			        case 16: ComHitman(playerid);// ������ ������
   			        case 17: ComRep(playerid);// ��������*/
			   	}
			}
 			else
	 		{
	   		}
		}
		case 13://ShowSet
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 14://ShowMis
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 15://ShowStat
     	{
   			if(!response)//!�.� �������� ������ �� ������ �������(������ ������� �������)
   			{
   				ShowPers(playerid);
			}
		}
		case 16://ShowSkills
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 17://ShowLic
		{
		    if(response)
   			{
			}
 			else
	 		{
	 		    callcmd::menu(playerid);
	   		}
		}
		case 18://ComBase
		{
		    if(response)
   			{
   			    ShowComm(playerid);
			}
 			else
	 		{
	   		}
		}
		case 19://DialogReport
		{
		    if(response)
   			{
   			    if(isnull(inputtext))
   			    {
   			        DialogReport(playerid);
   			        SCM(playerid, ColorGreen, !"�� ������ �� �����");
   			        return true;
			   	}
				if(report_check{playerid} == true)
				{

   			        DialogReport(playerid);
   			        SCM(playerid, ColorGreen, !"���������� ��������� ����� ��������� ���������� ��������� �������������!");
   			        return true;
				}

			    static const
				    fmt_str[] = "���� ������: %s",
				    fmt_str_2[] = "%s[%d] �������� ������: %s";
				new
				    string[sizeof(fmt_str) + 86],
				    string_2[sizeof(fmt_str_2) + MAX_PLAYER_NAME + 86];

				format(string, sizeof(string), fmt_str, inputtext);
				format(string_2, sizeof(string), fmt_str_2, GN(playerid), playerid, inputtext);
				SCM(playerid, ColorYellow, string);
				AdmChat(ColorRed, string_2);
				report_check{playerid} = true;
				report_timer[playerid] = SetTimerEx("@_ReportTime", 1_000*180, false, "i", playerid);
			}
 			else
	 		{
	   		}
		}
		case 20://Donate
		{
		    if(response)
   			{
   			    switch(listitem)
   			    {
   			        case 0:
   			        {
   			            DialogDonateConv(playerid);
			   		}
   			    }
			}
 			else
	 		{
	   		}
		}
		case 21://Donate
		{
		    if(response)
   			{
   			    new
   			        val = strval (inputtext);
   			    if(isnull(inputtext))
   			    {
   			        DialogDonateConv(playerid);
   			        SCM(playerid, ColorGreen, !"�� ������ �� �����");
   			        return true;
			   	}
   			    if(player[playerid][pdonate] < val)
   			    {
   			        DialogDonateConv(playerid);
   			        SCM(playerid, ColorGreen, !"� ��� ������������ �����-������!");
   			        return true;
			   	}
			   	if(!(0 < val <= 99999999999))
			   	{
			   	    SCM(playerid, ColorGreen, !"�������� �������� ��������� �����!");
					DialogDonateConv(playerid);
					return true;
		   		}
		   		static const
			    	fmt_str[] = "�� �������� {FFFF00}%d {FFFFFF}�����-������ � {FFFF00}%d{FFFFFF} ������� ��������";
				new
			    	string[sizeof(fmt_str)+18],
			    	money = val*1_000;//����

				format(string, sizeof(string), fmt_str, val, money);
		   		player[playerid][pmoney] += money;
		   		player[playerid][pdonate] -= val;
				SCM(playerid, ColorWhite, string);
				SavePlayer(playerid, "Money", player[playerid][pmoney], "d");
				SavePlayer(playerid, "Donate", player[playerid][pdonate], "d");
			}
 			else
	 		{
	 		    callcmd::donate(playerid);
	   		}
		}
		case 22://DialogAdminRegistration
		{
		    if(response)
   			{
		    if(isnull(inputtext))
		    {
      			DialogDonateConv(playerid);
       			SCM(playerid, ColorGreen, !"�� ������ �� �����");
		        return true;
		   	}
			new
				len = strlen(inputtext);
   			if(!(6 <= len <= 20))
			   	{
			   	    SCM(playerid, ColorGreen, !"�������� ����� ������");
					DialogAdminRegistration(playerid);
					return true;
		   		}
        	if(CheckRussianText(inputtext, len+1))
		   		{
					SCM(playerid, ColorGreen, !"������� ��������� ����������!");
					DialogAdminRegistration(playerid);
					return true;
				}
            static const
	    		fmt_str[] = "��� �����-������:	%s";
			new
	    		string[sizeof(fmt_str)+38];

			format(string, sizeof(string), fmt_str, inputtext);
			SCM(playerid, ColorGreen, string);
			SCM(playerid, ColorGreen, !"����������� ������� �������� (F8), ����� �� ������ �����-������!");
			player[playerid][pakeys] = 1;
			strmid(player[playerid][pakey], inputtext, 0, len, 20+1);
			SavePlayer(playerid, "Akeys", player[playerid][pakeys], "d");
			SavePlayer(playerid, "Akey", player[playerid][pakey], "s");
            }
            else
            {
			}
		}
    	case 23://DialogAdminLogin
		{
      		new
  				len = strlen(inputtext);
		    if(response)
   			{
   			if(isnull(inputtext))
		    {
      			DialogAdminLogin(playerid);
       			SCM(playerid, ColorGreen, !"�� ������ �� �����");
		        return true;
		   	}
			if(strcmp(player[playerid][pakey], inputtext, false) != 0 || len <=0)
			{
			    DialogAdminLogin(playerid);
   			    SCM(playerid, ColorRed, !"�������� �����-������!");
			    return true;
			}
		 	static const
	    		fmt_str[] = "�������������: {FFFFFF}%s[%d], %d ������ {DF8600}�������������!";
		 	new
	    		string[sizeof(fmt_str)+MAX_PLAYER_NAME];

			format(string, sizeof(string), fmt_str, GN(playerid), playerid, player[playerid][padmin]);
			AdmChat(ColorOrange, string);
			access_check{playerid} = true;
			SCM(playerid, ColorGreen, !"�����-����������� ������ �������! ����� ����������!");
			}
			else
  			{
			}
		}
		case 24://ahelp
		{
		    if(response)
   			{
   			    switch(listitem)
   			    {
   			        case 0:
   			        {
   			            SCM(playerid, ColorRed, !"�������� ������� �����������������!");
			   		}
			   		case 1:
   			        {
						SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 1-�� ������", !"\
						\n{00BFFF}/kick {FFFFFF} - ������� ������\
						\n{00BFFF}/spawn {FFFFFF} - �����\
						", !"�������", !"�����");
			   		}
			   		case 2:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 2-�� ������", !"\
						\n{FF0000}� ����������\
						", !"�������", !"�����");
			   		}
			   		case 3:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 3-�� ������", !"\
						\n{00BFFF}/veh {FFFFFF} - ������� ���������\
						", !"�������", !"�����");
			   		}
			   		case 4:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 4-�� ������", !"\
						\n{FF0000}� ����������\
						", !"�������", !"�����");
			   		}
			   		case 5:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 5-�� ������", !"\
						\n{FF0000}� ����������\
						", !"�������", !"�����");
			   		}
			   		case 6:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 6-�� ������", !"\
						\n{FF0000}/makeleader - ���������/������� ������\
						", !"�������", !"�����");
			   		}
			   		case 7:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 7-�� ������", !"\
						\n{FF0000}� ����������\
						", !"�������", !"�����");
			   		}
			   		case 8:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"������� 8-�� ������", !"\
						\n{FF0000}� ����������\
						", !"�������", !"�����");
			   		}
   			    }
			}
		}
		case 25://Ahelp
		{
		    if(!response)
   			{
   			    callcmd::ahelp(playerid);
			}
		}
        case 26://DialogGunLSPD
		{
		    if(response)
   			{
   			    switch(listitem)
				{
				    case 0:
				    {
				        GivePlayerWeapon(playerid, 24, 35);//������ ������ ������
				    }
				    case 1:
				    {
				        GivePlayerWeapon(playerid, 25, 20);
				    }
				    case 2:
				    {
				        GivePlayerWeapon(playerid, 29, 60);
				    }
				    case 3:
				    {
				        SetPlayerHealth(playerid, 100.0);
				    }
				    case 4:
				    {
				        SetPlayerArmour(playerid, 100.0);
				    }
				}
				DialogGunLSPD(playerid);//���������� ������� ����� ������
			}
		}
	}
	return true;
}
public OnGameModeInit()//��� ������� �������
{
	SetGameModeText("MerovRP");
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0); //����� ������ �� ����������: id �����, 3 �����. , ���� ��������, 6 �������� ��������
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);//���������� ������� ������ 0- ���, 1- �� ���� �����, 2 - �����������
    ShowNameTags(true); //���������� ���� � �������
    SetNameTagDrawDistance(20.0); //�� ����� ��������� ����� ����� �������
    DisableInteriorEnterExits();//������� ���� � ����������� ���� �� ������
    EnableStuntBonusForAll(0);//������� ����� �� �����
    connect_mysql = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_DB, MySQL_PASS);//����������� � ��: ����, ��� ������������, ���� ������, ������
    mysql_function_query(connect_mysql, "SET NAMES utf8", false, "", "");//����������� � ����, ��� ���������, �����������, ������, ���-�� ��������� �������
    mysql_function_query(connect_mysql, "SET CHARACTER SET 'cp1251'", false, "", "");/*����������� � ����, ����������� ��������� ��� ����� ������� �������� � ��,
	�����������, ������, ���-�� ��������� �������*/
	gettime(hour_server, minute_server, second_server);
	SetTimer("@_Update_Server", 1_000, false);
	SetWorldTime(hour_server);
	Pickups();
	Cars();
	return true;
}
public OnGameModeExit()
{
	return true;
}
public OnPlayerRequestClass(playerid, classid)
{
	return true;
}
public OnPlayerConnect(playerid)
{

	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);//id ������, ������,���� ����������, ���-��
	static //������� const, ���� ���������� mysql format
	    fmt_str[] = "SELECT * FROM `accounts` WHERE `Name` = '%s' LIMIT 1";//���-���� �� �� ��������, �� �����
	new
	    string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//�������� 2 ��-�� %s, +1 ��-�� ����-�����������
	
	mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid));
	mysql_function_query(connect_mysql, string, true, "@_PlayerCheck", "d", playerid);//@_PlayerCheck - ������, d - ���������(id ������)
	//SCM(playerid, ColorWhite, string);//��������� ��������� ������ � ����
	Clear(playerid);
	PlayerTextDraws(playerid);
	for(new i; i!=4; i++)
	   		{
	   		TextDrawShowForPlayer(playerid, td_uper_text[playerid][i]);
	   		}
	return true;
}
public OnPlayerDisconnect(playerid, reason)
{
    /*SavePlayer(playerid, "Level", player[playerid][plevel], "d");
	SavePlayer(playerid, "Money", player[playerid][pmoney], "d");
	SavePlayer(playerid, "Donate", player[playerid][pdonate], "d");
	SavePlayer(playerid, "Exp", player[playerid][pexp], "d");
	SavePlayer(playerid, "Maxexp", player[playerid][pmaxexp], "d");
	SavePlayer(playerid, "Skin", player[playerid][pskin], "d");
	SavePlayer(playerid, "Admin", player[playerid][padmin], "d");
	SavePlayer(playerid, "Referal", player[playerid][preferal], "s");
	SavePlayer(playerid, "Referal Check", player[playerid][preferal_check], "d");*/
	if(login_check{playerid} == true)
	    SavePlayerExit(playerid);
    if(player[playerid][padmin] > 0)
		    Iter_Remove(connect_admins, playerid);
    KillTimers(playerid);
	return true;
}
public OnPlayerSpawn(playerid)
{
	if(login_check{playerid} == true)
	    SetPlayerSpawn(playerid);
	return true;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	return true;
}
public OnVehicleSpawn(vehicleid)
{
	return true;
}
public OnVehicleDeath(vehicleid, killerid)
{
	return true;
}
public OnPlayerText(playerid, text[])
{
	if(login_check{playerid} == false)
	{
	    SCM(playerid, ColorGreen, "�� �� ������������!");
	    return false;
	}
	
	switch(player[playerid][pmember])//����� � ����, � ����������� �� �������
	{
		case 0:
	    {
		static const
			fmt_str[] = "%s[%d]: %s";
		new
            string[sizeof(fmt_str) + MAX_PLAYER_NAME + 120];
        format(string, sizeof(string), fmt_str, GN(playerid), playerid, text);
        ProxDetector(20.0, playerid, string, ColorWhite, ColorGrey, ColorGrey2, ColorGrey3, ColorGrey4);
		}
		case 1..3:
	    {
		static const
			fmt_str[] = "{0100F6}%s[%d]:{FFFFFF} %s";
		new
			string[sizeof(fmt_str) + MAX_PLAYER_NAME + 120];
		format(string, sizeof(string), fmt_str, GN(playerid), playerid, text);
		ProxDetector(20.0, playerid, string, ColorWhite, ColorGrey, ColorGrey2, ColorGrey3, ColorGrey4);
		}
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    ApplyAnimation(playerid, "PED", "IDLE_chat", 4.1, 0, 1, 1, 1, 1);// ��������� �������� (id ������, ����������, ���������� �������� �� ����������, ����� ���������������, ����������, ������)
	    SetTimerEx("@_ClearAnim", 3_000, false, "i", playerid);//������ ��� ������� ��������
	}
	return false;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	return false;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return true;
}
public OnPlayerExitVehicle(playerid, vehicleid)
{
	return true;
}
public OnPlayerStateChange(playerid, newstate, oldstate)//������ ������������ ������
{
	//������� ������
	new
	    carid = GetPlayerVehicleID(playerid);
	if(newstate == PLAYER_STATE_DRIVER)
	{
	    if(carid >= lspd_car[0] && carid <= lspd_car[26])
	    {
	        if(player[playerid][pmember] == 1)
	        {
			}
			else
			{
			    RemovePlayerFromVehicle(playerid);
			    SCM(playerid, ColorGreen, "�� �� ������ ��������� ����������� ����!");
			}
		}
	}
	return true;
}
public OnPlayerEnterCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveCheckpoint(playerid)
{
	return true;
}
public OnPlayerEnterRaceCheckpoint(playerid)
{
	return true;
}
public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return true;
}
public OnRconCommand(cmd[])
{
	return true;
}
public OnPlayerRequestSpawn(playerid)
{
	return false;
}
public OnObjectMoved(objectid)
{
	return true;
}
public OnPlayerObjectMoved(playerid, objectid)
{
	return true;
}
public OnPlayerPickUpDynamicPickup(playerid, pickupid)//������
{
	if(anti_flood_pick{playerid} == true)
		return true;
	else
	{
        anti_flood_pick{playerid} = true;
		GetPlayerPos(playerid, pos_pick[0][playerid], pos_pick[1][playerid], pos_pick[2][playerid]);
	}
	if(pickupid == lspd_pick[0])
	{
	    SetPlayerPos(playerid, 246.5715, 65.2846, 1003.6406);//����� ������
		SetPlayerFacingAngle(playerid, 2.3383);//���� ��������
		SetPlayerVirtualWorld(playerid, 1);//��������� ������ � ��� � id = 0
		SetPlayerInterior(playerid, 6);//��������� ���������
		SetCameraBehindPlayer(playerid);//��������� ������ ������ ������
	}
	if(pickupid == lspd_pick[1])
	{
	    SetPlayerPos(playerid, 246.7730, 84.8201, 1003.6406);
		SetPlayerFacingAngle(playerid, 179.3500);
		SetPlayerVirtualWorld(playerid, 1);
		SetPlayerInterior(playerid, 6);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspd_pick[2])
	{
	    SetPlayerPos(playerid, 1552.6343, -1675.7346, 16.1953);
		SetPlayerFacingAngle(playerid, 86.4747);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspd_pick[3])
	{
	    SetPlayerPos(playerid, 1568.7280, -1693.8474, 5.8906);
		SetPlayerFacingAngle(playerid, 180.4991);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspd_pick[4])
	{
	    SetPlayerPos(playerid, 316.5714,-167.7457,999.5938);
		SetPlayerFacingAngle(playerid, 359.0539);
		SetPlayerVirtualWorld(playerid, 1);
		SetPlayerInterior(playerid, 6);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspd_pick[5])
	{
	    SetPlayerPos(playerid, 1527.6619,-1677.7692,5.8906);
		SetPlayerFacingAngle(playerid, 269.1499);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == lspd_pick[6])
	{
		if(player[playerid][pmember] != 1)
			return SCM(playerid, ColorGrey, !"� �� �������� � LSPD!");

		DialogGunLSPD(playerid);
	}
	return true;
}
public OnVehicleMod(playerid, vehicleid, componentid)
{
	return true;
}
public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return true;
}
public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return true;
}
public OnPlayerSelectedMenuRow(playerid, row)
{
	return true;
}
public OnPlayerExitedMenu(playerid)
{
	return true;
}
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return true;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return true;
}
public OnRconLoginAttempt(ip[], password[], success)
{
	return true;
}
public OnPlayerUpdate(playerid)
{
	return true;
}
public OnPlayerStreamIn(playerid, forplayerid)
{
	return true;
}
public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}
public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return true;
}
public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return true;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return true;
}
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(login_check{playerid} == false)
	{
	    SCM(playerid, ColorGreen, "�� �� ������������!");
	    return false;
	}
	return true;
}
public OnPlayerClickTextDraw(playerid, Text: clickedid)
{
	if(clickedid == Text:INVALID_TEXT_DRAW && number_skin{playerid} > 0)
	    SelectTextDraw(playerid, 0xFF0000FF);// ��� ����������� �������������� ����� ������� ������ Esc
	if(clickedid == td_select_skin[playerid][0])
	{
	    number_skin{playerid} ++;
	    if(player[playerid][psex] == 1)//�������� ������ �� �����
		{
	        if(number_skin{playerid} == 11)
	            number_skin{playerid} = 1;
		}
	    else
	    {
	        if(number_skin{playerid} == 24)
	            number_skin{playerid} = 11;
		}

	    switch(number_skin{playerid})
	    {
	        // ������� �����
	        case 1: SetPlayerSkin(playerid, 78);
	        case 2: SetPlayerSkin(playerid, 79);
	        case 3: SetPlayerSkin(playerid, 134);
	        case 4: SetPlayerSkin(playerid, 135);
	        case 5: SetPlayerSkin(playerid, 136);
	        case 6: SetPlayerSkin(playerid, 137);
	        case 7: SetPlayerSkin(playerid, 160);
	        case 8: SetPlayerSkin(playerid, 200);
	        case 9: SetPlayerSkin(playerid, 212);
	        case 10: SetPlayerSkin(playerid, 230);
	        // ������� �����
	        case 11: SetPlayerSkin(playerid, 10);
	        case 12: SetPlayerSkin(playerid, 39);
	        case 13: SetPlayerSkin(playerid, 54);
	        case 14: SetPlayerSkin(playerid, 75);
	        case 15: SetPlayerSkin(playerid, 77);
	        case 16: SetPlayerSkin(playerid, 89);
	        case 17: SetPlayerSkin(playerid, 129);
	        case 18: SetPlayerSkin(playerid, 130);
	        case 19: SetPlayerSkin(playerid, 196);
	        case 20: SetPlayerSkin(playerid, 197);
	        case 21: SetPlayerSkin(playerid, 199);
	        case 22: SetPlayerSkin(playerid, 218);
	        case 23: SetPlayerSkin(playerid, 232);
	    }
	}
	if(clickedid == td_select_skin[playerid][1])
	{
	    number_skin{playerid} --;
	    if(player[playerid][psex] == 1)//�������� ������ �� �����
	    {
	        if(number_skin{playerid} == 0)
	            number_skin{playerid} = 10;
		}
	    else
	    {
	        if(number_skin{playerid} == 10)
	            number_skin{playerid} = 23;
		}

	    switch(number_skin{playerid})
	    {
	        // ������� �����
	        case 1: SetPlayerSkin(playerid, 78);
	        case 2: SetPlayerSkin(playerid, 79);
	        case 3: SetPlayerSkin(playerid, 134);
	        case 4: SetPlayerSkin(playerid, 135);
	        case 5: SetPlayerSkin(playerid, 136);
	        case 6: SetPlayerSkin(playerid, 137);
	        case 7: SetPlayerSkin(playerid, 160);
	        case 8: SetPlayerSkin(playerid, 200);
	        case 9: SetPlayerSkin(playerid, 212);
	        case 10: SetPlayerSkin(playerid, 230);
	        // ������� �����
	        case 11: SetPlayerSkin(playerid, 10);
	        case 12: SetPlayerSkin(playerid, 39);
	        case 13: SetPlayerSkin(playerid, 54);
	        case 14: SetPlayerSkin(playerid, 75);
	        case 15: SetPlayerSkin(playerid, 77);
	        case 16: SetPlayerSkin(playerid, 89);
	        case 17: SetPlayerSkin(playerid, 129);
	        case 18: SetPlayerSkin(playerid, 130);
	        case 19: SetPlayerSkin(playerid, 196);
	        case 20: SetPlayerSkin(playerid, 197);
	        case 21: SetPlayerSkin(playerid, 199);
	        case 22: SetPlayerSkin(playerid, 218);
	        case 23: SetPlayerSkin(playerid, 232);
	    }
	}
	if(clickedid == td_select_skin[playerid][2])
	{
		new
		    year_server,
		    mounth_server,
		    day_server;
	    for(new i; i != 3; i++) TextDrawHideForPlayer(playerid, td_select_skin[playerid][i]);//������� �����������
	    SCM(playerid, ColorWhite, !"�������� �������� ������ �������!");
	    login_check{playerid} = true;
	    update_timer[playerid] = SetTimerEx("@_UpdateTime", 1_000, false, "i", playerid);//��� ����������� �������, ����� ����� ������, � ���������� ��� ������
	    Freeze(playerid, 1);
	    number_skin{playerid} = 0;//������� �� ������ ������ �����
	    CancelSelectTextDraw(playerid);//������� �� ������ �������������� �����������
		//�������� ��������
	    player[playerid][plevel] = 0;//��������� �������
	    player[playerid][pmoney] = 300;//��������� ������
	    player[playerid][pmaxexp] = 4;
	    player[playerid][pdonate] = 0;
	    player[playerid][pskin] = GetPlayerSkin(playerid);
		//
		getdate(year_server, mounth_server, day_server);//��������� ���� � ���������� (���, �����, ����)
		format(player[playerid][pdate_reg], 10+1, "%02d/%02d/%02d", day_server, mounth_server, year_server);
		//
		static
		    fmt_str[] =
			"\
				INSERT INTO `accounts` (`Name`, `Pass`, `Mail`, `Sex`, `Skin`, `Age`, `Nations`, `Level`, `Referal`, `Referal Check`, `Money`, `Exp`, `Maxexp`, `Date Reg`) VALUES ('%s', '%s', \
				'%s', '%d', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%s')\
			";// VALUES - ��������� ������ �� ����������
		new
		    string[sizeof(fmt_str)+MAX_PLAYER_NAME*2+94];//����������� ��������

		mysql_format(connect_mysql, string, sizeof(string), fmt_str,
		GN(playerid), player[playerid][ppass], player[playerid][pmail], player[playerid][psex], player[playerid][pskin], player[playerid][page],
		player[playerid][pnations], player[playerid][plevel], player[playerid][preferal], player[playerid][preferal_check], player[playerid][pmoney], player[playerid][pexp],
		player[playerid][pmaxexp], player[playerid][pdate_reg]);
		
		mysql_function_query(connect_mysql, string, true, "@_GetID", "i", playerid);
	    SpawnPlayer(playerid);
	}

 	return true;
}
@_PlayerCheck(playerid);//���������� ������ �������, @_ - ������ forward
@_PlayerCheck(playerid)//����� ����� ������(�����������, �����������)
{
	new
		rows,
		fields;
		
	cache_get_data(rows, fields);
	if(rows) //�����������
	{
	        login_timer[playerid] = SetTimerEx("@_CheckLogin", 1_000 * 60, false, "i",playerid);
			DialogLogin(playerid);
 	}
	else //�����������
	{
			static const
	   			reset_data[pinfo];
	        player[playerid] = reset_data;
			DialogRegistration(playerid);
	}
	SCM(playerid, ColorRed, !"{FF0000}����� ���������� �� ������ {FFFF00}Merov Role Play"); //{��� �����}, !������������ ������(���������� ���-�� ���������� ������)
	return true;
}
@_UpdateTime(playerid);
@_UpdateTime(playerid)
{
	if(player[playerid][pmoney] !=GetPlayerMoney(playerid))
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, player[playerid][pmoney]);
	}
	
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, pos_pick[0][playerid], pos_pick[1][playerid], pos_pick[2][playerid]))
		anti_flood_pick{playerid} = false;

	update_timer[playerid] = SetTimerEx("@_UpdateTime", 1_000, false, "i",playerid);//������, ������� ����� ��������������� ������ � ������������ ������, i - ������������� id, playerid - id ������
	//SetTimer("@_UpdateTime", false, 1_000);//����������� ������ - �����, True/false - ��� ��������� ��� �� ���,���� false - �� ���������� ���� ���, ����� ����� �����
	return true;
}
@_PlayerKick(playerid);
@_PlayerKick(playerid)
{
	Kick(playerid);
	return true;
}
@_CheckRef(playerid, name[]);//���������� ������ �������, @_ - ������ forward
@_CheckRef(playerid, name[])
{
	new
		rows,
		fields;

	cache_get_data(rows, fields);
	if(!rows)//���� ������� �� ��� ������
	{
	    SCM(playerid, ColorGreen, !"������� �� ������");
		DialogReferal(playerid);
		return true;
	}
	player[playerid][preferal_check] = 1;
	strmid(player[playerid][preferal], name, 0, strlen(name), MAX_PLAYER_NAME+1);
    DialogSex(playerid);
	return true;
}
@_GetID(playerid);
@_GetID(playerid)
{

	player[playerid][pid] = cache_insert_id();// �������� �������� id �� ���� ���������
	return true;
}
@_OnLogin(playerid);
@_OnLogin(playerid)
{
	new
		rows,
		fields;

	cache_get_data(rows, fields);
	if(rows)
  	{
  	    //�������� ��������� ������ �� ��
		cache_get_field_content(0, "Pass", player[playerid][ppass], connect_mysql, 32+1);// ��������� ������ �� Pass � ppass
		cache_get_field_content(0, "Mail", player[playerid][pmail], connect_mysql, 60+1);
		cache_get_field_content(0, "Referal", player[playerid][preferal], connect_mysql, MAX_PLAYER_NAME+1);
		cache_get_field_content(0, "Date Reg", player[playerid][pdate_reg], connect_mysql, 11+1);
		cache_get_field_content(0, "Akey", player[playerid][pakey], connect_mysql, 20+1);
		//�������� ������������� ������ �� ��
		player[playerid][pid] = cache_get_field_content_int(0, "ID");//(�������������, ������ ��������)
		player[playerid][plevel] = cache_get_field_content_int(0, "Level");
		player[playerid][pmoney] = cache_get_field_content_int(0, "Money");
		player[playerid][pskin] = cache_get_field_content_int(0, "Skin");
		player[playerid][psex] = cache_get_field_content_int(0, "Sex");
		player[playerid][preferal_check] = cache_get_field_content_int(0, "Referal Check");
		player[playerid][page] = cache_get_field_content_int(0, "Age");
		player[playerid][pnations] = cache_get_field_content_int(0, "Nations");
		player[playerid][pexp] = cache_get_field_content_int(0, "Exp");
		player[playerid][pmaxexp] = cache_get_field_content_int(0, "Maxexp");
		player[playerid][padmin] = cache_get_field_content_int(0, "Admin");
		player[playerid][pakeys] = cache_get_field_content_int(0, "Akeys");
		player[playerid][pdonate] = cache_get_field_content_int(0, "Donate");
		player[playerid][pmember] = cache_get_field_content_int(0, "Member");
		player[playerid][prank] = cache_get_field_content_int(0, "Rank");
		player[playerid][pmodel] = cache_get_field_content_int(0, "Model");
		//
		if(player[playerid][padmin] > 0)
		    Iter_Add(connect_admins, playerid);
 	    login_check{playerid} = true;
 	    SetTimerEx("@_FastSpawn", 100, false, "i", playerid);
 	    update_timer[playerid] = SetTimerEx("@_UpdateTime", 1_000, false, "i", playerid);
 	    KillTimer(login_timer[playerid]);
  		static //������� const, ���� ���������� mysql format
			fmt_str[] = "SELECT * FROM `referal` WHERE `Name` = '%s'";//���-���� �� �� ��������, �� �����
		new
			string[sizeof(fmt_str)+MAX_PLAYER_NAME-1];

		mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid));
		mysql_function_query(connect_mysql, string, true, "@_CheckReferal", "d", playerid);
	}
	else
	{
	 	number_pass{playerid} ++;
	    if(number_pass{playerid} == 3)
	    {
	        SCM(playerid, ColorGreen, !"������� �� ���� �����������. ������� (/q)uit ����� �����");
	        Tkick(playerid);
	        return true;
	    }

	    static const
		    fmt_str[] = "�� ����� �������� ������, �������� �������: %d";
		new
		    string[sizeof(fmt_str)];

		format(string, sizeof(string), fmt_str, 3-number_pass{playerid});
		SCM(playerid, ColorRed, string);
	    DialogLogin(playerid);
	}
	return true;
}
@_FastSpawn(playerid);
@_FastSpawn(playerid)
{
	SpawnPlayer(playerid);
	return true;
}
@_CheckLogin(playerid);
@_CheckLogin(playerid)
{
	SCM(playerid, ColorGreen, !"����� �� ����������� �����. ������� (/q)uit ����� �����");
	Tkick(playerid);
	return true;
}
@_Update_Server(playerid);
@_Update_Server(playerid)
{
	new
	    hour_server_2,
	    minute_server_2,
	    second_server_2;
	gettime(hour_server_2, minute_server_2, second_server_2);
	if(hour_server!= hour_server_2)
	{
	    hour_server = minute_server_2;
	    SetWorldTime(hour_server);
	    PayDay();
	}
	SetTimer("@_Update_Server", 1_000, false);
	return true;
}
@_Check_Referal(playerid);
@_Check_Referal(playerid)
{
	new
		rows,
		fields;

	cache_get_data(rows, fields);
	if(rows)
	{
	    player[playerid][pmoney] += 50_000;
	    SavePlayer(playerid, "Money", player[playerid][pmoney], "d");
	    SCM(playerid, ColorGreen, !"��� ������� ������ 3-�� ������!");
	    static //������� const, ���� ���������� mysql format
			fmt_str[] = "DELETE FROM `referal` WHERE `Name` = '%s' LIMIT 1";//�������� �� ��
		new
			string[sizeof(fmt_str)+MAX_PLAYER_NAME-1];

		mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid));
		mysql_function_query(connect_mysql, string, true, "", "");
	}
	return true;
}
@_ReportTime(playerid);
@_ReportTime(playerid)
{
	report_check{playerid} = false;
	return true;
}
@_ClearAnim(playerid);
@_ClearAnim(playerid)
{
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 2.1, 0, 0, 0, 0, 0);
	return true;
}
@_OnVehicleSpawn(vehicleid);
@_OnVehicleSpawn(vehicleid)
{
	return true;
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ����� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stock DialogRegistration(playerid)
{
		static const//�� ���������� ��������������
	    	fmt_str[] = "{FFFFFF}���������� {008000}%s, {FFFFFF}����������� �� ������� {FFFF00}MerovRP\n\
						\n{FFFFFF}�� ������ �������� ���� ������ �� ��������� {FF0000}www.vk.com\n\
		 				\n{FFFFFF}�������� � ����� ���� ������:";
		new
	    	string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//�������� 2 ��-�� %s, +1 ��-�� ����-�����������

		format(string, sizeof(string), fmt_str, GN(playerid));
		SPD(playerid, 1, DIALOG_STYLE_INPUT, !"�����������",string,!"�����",!"�����");
		// ShowPlayerDialog(id ������,id �������, ��� �������, �������� �������, ��� ����� �������, ����� �������, ������ �������), ���� ������ ���� ������,�� ������ �� ������
		//DIALOG_STYLE_PASSWORD - ������������� ������
		//DIALOG_STYLE_MSGBOX - �������������� ������
		//DIALOG_STYLE_INPUT - ����������� ������
		//DIALOG_STYLE_LIST - ������/�����
		//DIALOG_STYLE_TABLIST_HEADERS - �������� ������
		//\-������� �������
}
stock DialogEmail(playerid)
{
SPD(playerid, 2, DIALOG_STYLE_INPUT,  !"�����", !"{FFFFFF}������� ���� �����: ", !"�����", !"�����");
}
stock DialogNation(playerid)
{
SPD(playerid, 3, DIALOG_STYLE_LIST, !"��������������", !"�������\n����������\n������\n������\n���������", !"�������", !"�����");
}
stock DialogAge(playerid)
{
	SPD(playerid, 4, DIALOG_STYLE_INPUT,  !"�������", !"{FFFFFF}������� ��� ������� (�� 18 �� 70 ���): ", !"�����", !"�����");
}
stock DialogReferal(playerid)
{
    SPD(playerid, 5, DIALOG_STYLE_INPUT,  !"����������� �������", !"{FFFFFF}������� ������� ������, ������������� ���: \n��� ���������� 3-�� ������, �� �������� 50.000$", !"�����", !"����������");
}
stock DialogSex(playerid)
{
    SPD(playerid, 6, DIALOG_STYLE_MSGBOX,  !"�������� ���", !"{FFFFFF}�������� ���: ", !"�������", !"�������");
}
stock Clear(playerid)
{
	number_skin{playerid} = 0;
	number_pass{playerid} = 0;
	
	login_check{playerid} = false;
	report_check{playerid} = false;
	access_check{playerid} = false;
}
stock SetPlayerSpawn(playerid)//������� ������ ������
{
	Clist(playerid);//��������� ����� ������ ��� ������ �� 100% ������������� (00)
	SetPlayerScore(playerid, player[playerid][plevel]);//������� �����(������ ������)
	if(player[playerid][pmember] > 0)//�������� �� ���� �������, ������ ����� � ����������� �� ������� �������
	{
	    SetPlayerSkin(playerid, player[playerid][pmodel]);
		switch(player[playerid][pmember])
		{
		    case 1:
		    {
     			SetPlayerPos(playerid, 254.1158, 77.7199, 1003.6406);//����� ������ LSPD
     			SetPlayerFacingAngle(playerid, 180.0);//���� ��������
				SetPlayerInterior(playerid, 6);//��������� ���������
			}
		}
		SetPlayerVirtualWorld(playerid, player[playerid][pmember]);//��������� ������ � ��� � id = 0
	    SetCameraBehindPlayer(playerid);//��������� ������ ������ ������
	    return true;
	}
	SetPlayerSkin(playerid, player[playerid][pskin]);
	SetPlayerPos(playerid, 2840.1497, 1303.2096, 11.3906);//����� ������
	SetPlayerFacingAngle(playerid, 88.1048);//���� ��������
	SetPlayerVirtualWorld(playerid, 0);//��������� ������ � ��� � id = 0
	SetPlayerInterior(playerid, 0);//��������� ���������
	SetCameraBehindPlayer(playerid);//��������� ������ ������ ������
	return true;
}
stock KillTimers(playerid)
{
    KillTimer(update_timer[playerid]);
    KillTimer(login_timer[playerid]);
    KillTimer(report_timer[playerid]);
}
stock PlayerTextDraws(playerid)//����������
{
//����� �����
td_select_skin[playerid][0] = TextDrawCreate(475.200042, 309.120056, "LD_BEAT:right");
TextDrawLetterSize(td_select_skin[playerid][0], 0.000000, 0.000000);
TextDrawTextSize(td_select_skin[playerid][0], 85.599975, 39.813354);
TextDrawAlignment(td_select_skin[playerid][0], 2);//�������� ������ �������� �� 2, ��� ������������ �� ������
TextDrawColor(td_select_skin[playerid][0], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][0], 0);
TextDrawSetOutline(td_select_skin[playerid][0], 0);
TextDrawFont(td_select_skin[playerid][0], 4);
TextDrawSetSelectable(td_select_skin[playerid][0], true);

td_select_skin[playerid][1] = TextDrawCreate(89.800018, 307.133209, "LD_BEAT:left");
TextDrawLetterSize(td_select_skin[playerid][1], 0.000000, 0.000000);
TextDrawTextSize(td_select_skin[playerid][1], 85.599975, 39.813354);
TextDrawAlignment(td_select_skin[playerid][1], 2);//�������� ������ �������� �� 2, ��� ������������ �� ������
TextDrawColor(td_select_skin[playerid][1], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][1], 0);
TextDrawSetOutline(td_select_skin[playerid][1], 0);
TextDrawFont(td_select_skin[playerid][1], 4);
TextDrawSetSelectable(td_select_skin[playerid][1], true);

td_select_skin[playerid][2] = TextDrawCreate(320.200256, 321.813415, "SELECT");
TextDrawLetterSize(td_select_skin[playerid][2], 0.449999, 1.600000);
TextDrawTextSize(td_select_skin[playerid][2], 20, 70);
TextDrawAlignment(td_select_skin[playerid][2], 2);//�������� ������ �������� �� 2, ��� ������������ �� ������
TextDrawColor(td_select_skin[playerid][2], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][2], 0);
TextDrawSetOutline(td_select_skin[playerid][2], 1);
TextDrawBackgroundColor(td_select_skin[playerid][2], 255);
TextDrawFont(td_select_skin[playerid][2], 2);
TextDrawSetProportional(td_select_skin[playerid][2], 2);//����� �������
TextDrawSetSelectable(td_select_skin[playerid][2], true);

td_uper_text[playerid][0] = TextDrawCreate(639.199951, 288.213348, "New Textdraw");
TextDrawLetterSize(td_uper_text[playerid][0], 0.449999, 1.600000);
TextDrawAlignment(td_uper_text[playerid][0], 1);
TextDrawColor(td_uper_text[playerid][0], -1);
TextDrawSetShadow(td_uper_text[playerid][0], 0);
TextDrawSetOutline(td_uper_text[playerid][0], 1);
TextDrawBackgroundColor(td_uper_text[playerid][0], 51);
TextDrawFont(td_uper_text[playerid][0], 1);
TextDrawSetProportional(td_uper_text[playerid][0], 1);

td_uper_text[playerid][1] = TextDrawCreate(541.599853, 2.240004, "merov");
TextDrawLetterSize(td_uper_text[playerid][1], 0.462000, 2.316800);
TextDrawAlignment(td_uper_text[playerid][1], 1);
TextDrawColor(td_uper_text[playerid][1], -5963521);
TextDrawSetShadow(td_uper_text[playerid][1], 0);
TextDrawSetOutline(td_uper_text[playerid][1], 1);
TextDrawBackgroundColor(td_uper_text[playerid][1], 51);
TextDrawFont(td_uper_text[playerid][1], 2);
TextDrawSetProportional(td_uper_text[playerid][1], 1);

td_uper_text[playerid][2] = TextDrawCreate(541.800109, 16.680006, "ROLEPLAY");
TextDrawLetterSize(td_uper_text[playerid][2], 0.326799, 2.331732);
TextDrawAlignment(td_uper_text[playerid][2], 1);
TextDrawColor(td_uper_text[playerid][2], -1);
TextDrawSetShadow(td_uper_text[playerid][2], 0);
TextDrawSetOutline(td_uper_text[playerid][2], 0);
TextDrawBackgroundColor(td_uper_text[playerid][2], 255);
TextDrawFont(td_uper_text[playerid][2], 2);
TextDrawSetProportional(td_uper_text[playerid][2], 1);

td_uper_text[playerid][3] = TextDrawCreate(573.600036, 35.093341, "vk.com");
TextDrawLetterSize(td_uper_text[playerid][3], 0.248400, 0.935465);
TextDrawAlignment(td_uper_text[playerid][3], 1);
TextDrawColor(td_uper_text[playerid][3], -1);
TextDrawSetShadow(td_uper_text[playerid][3], -1);
TextDrawSetOutline(td_uper_text[playerid][3], 0);
TextDrawBackgroundColor(td_uper_text[playerid][3], 51);
TextDrawFont(td_uper_text[playerid][3], 2);
TextDrawSetProportional(td_uper_text[playerid][3], 1);
}
stock DialogLogin(playerid)
{
		static const//�� ���������� ��������������
	    	fmt_str[] = "{FFFFFF}���������� {008000}%s, {FFFFFF}����������� �� ������� {FFFF00}MerovRP\n\
						\n{FFFFFF}��� ������� ��� ���������������!\n\
		 				\n{FFFFFF}����������, ������� ���� ������:";
		new
	    	string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//�������� 2 ��-�� %s, +1 ��-�� ����-�����������

		format(string, sizeof(string), fmt_str, GN(playerid));
		SPD(playerid, 7, DIALOG_STYLE_PASSWORD, !"�����������",string,!"�����",!"�����");
}
stock CheckRussianText(string[], size = sizeof(string))
{
    for(new i; i < size; i++)
				switch(string[i])
				{
				    case '�'..'�', '�'..'�':
					return true;
				}
	return false;
}
stock ShowPers(playerid)
{
	SPD(playerid, 9, DIALOG_STYLE_LIST, !"��������","\
	{F5DEB3}����������\
	\n{F5DEB3}������\
	\n{F5DEB3}��������",!"�����",!"�����");
	return true;
}
stock ShowGPS(playerid)
{
    SPD(playerid, 10, DIALOG_STYLE_LIST, !"���������",!"\
	{F5DEB3}���������������\
	\n{F5DEB3}���. ���������\
	\n{F5DEB3}�������\
	\n{F5DEB3}�������� ������\
	\n{F5DEB3}������ ����������\
	\n{F5DEB3}������ ������ �����\
	\n{F5DEB3}����� ���� �� 'ID'\
	\n{F5DEB3}��������� ����\
	\n{F5DEB3}������ ����\
	\n{F5DEB3}��������� �����\
	\n{F5DEB3}��������� ���\
	\n{F5DEB3}������ ��������� �����\
	\n{F5DEB3}����\
	\n{FF80AB}������ ������� (/gps off)",!"�����",!"�����");
	return true;
}
stock ShowOnline(playerid)
{
    SPD(playerid, 11, DIALOG_STYLE_LIST, !"������ ������",!"\
	{F5DEB3}������� ������\
	\n{F5DEB3}������ ������\
	\n{F5DEB3}�������� ������\
	\n{F5DEB3}��������� ������\
	\n{F5DEB3}��������� ������\
	\n{F5DEB3}���������� ������\
	\n{F5DEB3}�������� ������",!"�����",!"�����");
	return true;
}
stock ShowComm(playerid)
{
    SPD(playerid, 12, DIALOG_STYLE_LIST, !"������� �������",!"\
	{F5DEB3}��������\
	\n{F5DEB3}������\
	\n{F5DEB3}���\
	\n{F5DEB3}�������\
	\n{F5DEB3}���/�����\
	\n{F5DEB3}������\
	\n{F5DEB3}���������\
	\n{F5DEB3}�������/���\
	\n{F5DEB3}�������\
	\n{F5DEB3}IRC\
	\n{F5DEB3}���������\
	\n{F5DEB3}��������\
	\n{F5DEB3}���������\
	\n{F5DEB3}��������\
	\n{F5DEB3}���\
	\n{F5DEB3}�����\
	\n{F5DEB3}������ ������\
	\n{F5DEB3}��������",!"�����",!"�����");
	return true;
}
stock ShowSet(playerid)
{
    SPD(playerid, 13, DIALOG_STYLE_LIST, !"���������",!"\
	{F5DEB3}���������� �����\
	\n{F5DEB3}����� ������\
	\n{F5DEB3}������ ��������",!"�����",!"�����");
	return true;
}
stock ShowMis(playerid)//���� ������� (����������)
{
 	SPD(playerid, 14, DIALOG_STYLE_LIST, !"���������� �������",!"\
	{F5DEB3}���������\
	\n{F5DEB3}�������� ����������\
	\n{F5DEB3}�����",!"�����",!"�����");
	return true;
}
stock ShowStat(playerid, id)
{
    static const
	    	fmt_str[] = "{FFFFFF}ID ��������:\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}��� ������:\t\t\t{F5DEB3}%s\n\
						\n{FFFFFF}���� �����������:\t\t{F5DEB3}%s\n\
						\n{FFFFFF}�������:\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}EXP:\t\t\t\t{F5DEB3}%d/%d\n\
						\n{FFFFFF}������:\t\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}�������:\t\t\t{F5DEB3}%d ���\n\
						\n{FFFFFF}���:\t\t\t\t{F5DEB3}%s\n\
		 				\n{FFFFFF}��������������:\t\t{F5DEB3}%s";// \t-��������� ������
	new
	    	string[sizeof(fmt_str)+MAX_PLAYER_NAME+35];//�������� 2 ��-�� %s, +1 ��-�� ����-�����������

	format(string, sizeof(string), fmt_str, player[id][pid], GN(id), player[id][pdate_reg], player[id][plevel], player[id][pexp], player[id][pmaxexp],
 	player[id][pmoney], player[id][page], sex_info[player[id][psex] - 1], nations_info[player[id][pnations] - 1]);
	
    SPD(playerid, 15, DIALOG_STYLE_MSGBOX, !"����������",string,!"�����",!"�����");
	return true;
}
stock ShowSkills(playerid)
{
    SPD(playerid, 16, DIALOG_STYLE_LIST, !"������",!"\
	",!"�����",!"�����");
	return true;
}
stock ShowLic(playerid)
{
    SPD(playerid, 17, DIALOG_STYLE_LIST, !"��������",!"\
	",!"�����",!"�����");
	return true;
}
stock PayDay()
{
	gettime(hour_server, minute_server, second_server);
	SetWorldTime(hour_server);
	foreach(new i: Player)//forearch ����� ��� �������� ����� ��� �������
	{
		if(login_check{i} == false)
		    return true;
		    
		SCM(i, ColorOrange, !"========== [PAY DAY] ==========");
		player[i][pexp] ++;
		if(player[i][pexp] == player[i][pmaxexp])
		{
		    player[i][pexp] = 0;
		    player[i][plevel] ++;
		    player[i][pmaxexp] = player[i][pmaxexp]*2;
		    SCM(i, ColorGreen, !"�����������! �� �������� ����� �������!");
		    SetPlayerScore(i, player[i][plevel]);
      		SavePlayer(i, "Level", player[i][plevel], "d");
      		SavePlayer(i, "Money", player[i][pmoney], "d");
		    //SavePlayer(i, "Level", player[i][plevel], "d");
		    if(player[i][plevel] == 3 && player[i][preferal_check] == 1)
		    {
		        static
   					fmt_str[] = "INSERT INTO `referal` (`Name`) VALUES ('%s')";// \t-��������� ������
				new
					string[sizeof(fmt_str)+ MAX_PLAYER_NAME-1];
				mysql_format(connect_mysql, string, sizeof(string), fmt_str, player[i][preferal]);// ��������� ������ � �������
				mysql_function_query(connect_mysql, string, false, "", "");
		        player[i][preferal_check] = 0;
		        SavePlayer(i, "Referal Check", player[i][preferal_check], "d");
			}
		}
		SCM(i, ColorOrange, !"==============================");
  		SavePlayer(i, "Exp", player[i][pexp], "d");
    	SavePlayer(i, "Maxexp", player[i][pmaxexp], "d");
		//SavePlayer(i, "Exp", player[i][pexp], "d");// ��� �������� �� ��������
	}
	return true;
}
stock SavePlayer(playerid, const field_name[], const set[], const type[])
{
	new
	    string[128+1];
	    
	if(!strcmp(type, "d", true))//�������� �� ��������
	    mysql_format(connect_mysql, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%d' WHERE `Name` = '%s' LIMIT 1", field_name, set, GN(playerid));// ��������� ������ � �������
 	else if(!strcmp(type, "s", true))//�������� �� ��������
	    mysql_format(connect_mysql, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%s' WHERE `Name` = '%s' LIMIT 1", field_name, set, GN(playerid));

    mysql_function_query(connect_mysql, string, false, "", "");
	return true;
}
stock SavePlayerExit(playerid)
{
    static
   		fmt_str[] = "UPDATE `accounts` SET `Money` = '%d', `Exp` = '%d', `Level` = '%d', `Maxexp` = '%d' WHERE `Name` = '%s' LIMIT 1";// \t-��������� ������
	new
		string[sizeof(fmt_str)+ MAX_PLAYER_NAME + 13];
	mysql_format(connect_mysql, string, sizeof(string), fmt_str, player[playerid][pmoney], player[playerid][pexp], player[playerid][plevel], player[playerid][pmaxexp], GN(playerid));// ��������� ������ � �������
	mysql_function_query(connect_mysql, string, false, "", "");
}
stock ComBase(playerid)
{
    SPD(playerid, 18, DIALOG_STYLE_MSGBOX, !"�������",!"\
	{F5DEB3}/kpk - ������� ����\
	\n{F5DEB3}/gps - ������� ���������\
	\n{F5DEB3}/report - ��������� ��������� �������\
	\n{F5DEB3}/donate - ������� �� ����� ������\
	\n{F5DEB3}/time - ������ �����",!"�����",!"�����");
	return true;
}
//������ ��� �����
/*stock ���(playerid, �������)
{
	return true;
}*/
stock DialogReport(playerid)
{
	SPD(playerid, 19, DIALOG_STYLE_INPUT, !"������", !"{FFFFFF}�������� ���� ������/������ �������������:", !"�����", !"�����");
	return true;
}
stock AdmChat(color, str[])
{
	foreach(new i: connect_admins) SCM(i, color, str);// ���������� ���� ��� �������, ������� ������ ��� ������ ��������
	return true;
}
stock DialogDonateConv(playerid)
{
    static const
	    	fmt_str[] = "����� ������: {FFFF00}%d";
	new
	    	string[sizeof(fmt_str)+10];

	format(string, sizeof(string), fmt_str, player[playerid][pdonate]);
    SPD(playerid, 21, DIALOG_STYLE_INPUT, string, !"{FFFFFF}����������� �� �����: 1 ��� = 10.000$, ������� �����:", !"�����", !"�����");
	return true;
}
stock DialogAdminRegistration(playerid)
{
    SPD(playerid, 22, DIALOG_STYLE_INPUT, !"�����-�����������", !"\
		{FFFFFF}���������� ��� �����-������:\
		\n{FFFFFF}��� �� ������ ������������ ������ ��� ��� �����-�����������!\
		\n{DF8600}����� ������ �� 6 �� 20 ��������.\
		\n", !"�����", !"�����");
	return true;
}
stock DialogAdminLogin(playerid)
{
    SPD(playerid, 23, DIALOG_STYLE_PASSWORD, !"�����-�����������", !"\
		{FFFFFF}������� ��� �����-������:\
		\n", !"�����", !"�����");
	return true;
}
stock ClearKillFeed(playerid = INVALID_PLAYER_ID)
{
    if((playerid != INVALID_PLAYER_ID) && (0 == IsPlayerConnected(playerid)))
		return false;

    goto L_start;
    {
        new
			dummy[16/(cellbits/charbits)];

        #emit const.pri dummy
    }
	#if __Pawn < 0x030A
    SendDeathMessage(0, 0, 0),
    SendDeathMessageToPlayer(0, 0, 0, 0);
	#endif
	L_start: const CKF_MAGIC_ID = INVALID_PLAYER_ID - 1;
    new
		i = 5;

    #emit    push.c    CKF_MAGIC_ID
    #emit    push.c    CKF_MAGIC_ID
    if(playerid == INVALID_PLAYER_ID)
    {
        #emit    push.c    12
        do
		{
            #emit    sysreq.c    SendDeathMessage
        }
		while(--i != 0);
        #emit    stack    12
    }
    else
    {
        #emit    push.s    playerid
        #emit    push.c    16
        do
		{
            #emit    sysreq.c    SendDeathMessageToPlayer
        }
		while(--i != 0);
        #emit    stack    16
    }
    return true;
}
stock Clist(playerid)
{
	switch(player[playerid][pmember])
	{
	    case 0: SetPlayerColor(playerid, 0xFFFFFF00);//��������� ����� ���� ������
	    case 1..3: SetPlayerColor(playerid, 0x0100F6AA);//��������� ����� ���� ������ (� ���������� ������)
	}
}
stock ProxDetector(Float:radi, playerid, string[], col1, col2, col3, col4, col5)
{
	new
		Float: X,
		Float: Y,
		Float: Z,
		Float: X_2,
		Float: Y_2,
		Float: Z_2,
		Float: X_3,
		Float: Y_3,
		Float: Z_3;

	GetPlayerPos(playerid, X_2, Y_2, Z_2);
	foreach(new i : Player)
	{
		if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
		{
			GetPlayerPos(i, X, Y, Z);
			X_3 = (X_2 - X);
			Y_3 = (Y_2 - Y);
			Z_3 = (Z_2 - Z);
			if(((X_3 < radi/16) && (X_3 > -radi/16)) && ((Y_3 < radi/16) && (Y_3 > -radi/16)) && ((Z_3 < radi/16) && (Z_3 > -radi/16)))
				SCM(i, col1, string);
			else if(((X_3 < radi/8) && (X_3 > -radi/8)) && ((Y_3 < radi/8) && (Y_3 > -radi/8)) && ((Z_3 < radi/8) && (Z_3 > -radi/8)))
				SCM(i, col2, string);
			else if(((X_3 < radi/4) && (X_3 > -radi/4)) && ((Y_3 < radi/4) && (Y_3 > -radi/4)) && ((Z_3 < radi/4) && (Z_3 > -radi/4)))
				SCM(i, col3, string);
			else if(((X_3 < radi/2) && (X_3 > -radi/2)) && ((Y_3 < radi/2) && (Y_3 > -radi/2)) && ((Z_3 < radi/2) && (Z_3 > -radi/2)))
				SCM(i, col4, string);
			else if(((X_3 < radi) && (X_3 > -radi)) && ((Y_3 < radi) && (Y_3 > -radi)) && ((Z_3 < radi) && (Z_3 > -radi)))
				SCM(i, col5, string);
		}
	}
}
stock GetVehicleName(carid)
{
    new car[256];
    switch (carid)
    {
    case 400: car = "LandStalker"; case 401: car = "Bravura"; case 402: car = "Buffalo"; case 403: car = "Linerunner"; case 404: car = "Perenniel"; case 405: car = "Sentinel";
    case 406: car = "Dumper"; case 407: car = "Firetruck"; case 408: car = "Trashmaster"; case 409: car = "Stretch"; case 410: car = "Manana"; case 411: car = "Infernus";
    case 412: car = "Voodoo"; case 413: car = "Pony"; case 414: car = "Mule"; case 415: car = "Cheetah"; case 416: car = "Ambulance"; case 417: car = "Leviathan";
    case 418: car = "Moonbeam"; case 419: car = "Esperanto"; case 420: car = "Taxi"; case 421: car = "Washington"; case 422: car = "Bobcat"; case 423: car = "Mr Whoopee";
    case 424: car = "BF Injection"; case 425: car = "Hunter"; case 426: car = "Premier"; case 427: car = "Enforcer"; case 428: car = "Securicar"; case 429: car = "Banshee";
    case 430: car = "Predator"; case 431: car = "Bus"; case 432: car = "Rhino"; case 433: car = "Barracks"; case 434: car = "Hotknife"; case 435: car = "Article Trailer";
    case 436: car = "Previon"; case 437: car = "Coach"; case 438: car = "Cabbie"; case 439: car = "Stallion"; case 440: car = "Rumpo"; case 441: car = "RC Bandit";
    case 442: car = "Romero"; case 443: car = "Packer"; case 444: car = "Monster"; case 445: car = "Admiral"; case 446: car = "Squallo"; case 447: car = "Seasparrow";
    case 448: car = "Pizzaboy"; case 449: car = "Tram"; case 450: car = "Article Trailer 2"; case 451: car = "Turismo"; case 452: car = "Speeder"; case 453: car = "Reefer";
    case 454: car = "Tropic"; case 455: car = "Flatbed"; case 456: car = "Yankee"; case 457: car = "Caddy"; case 458: car = "Solairr"; case 459: car = "Berkley's RC Van";
    case 460: car = "Skimmer"; case 461: car = "PCJ-600"; case 462: car = "Faggio"; case 463: car = "Freeway"; case 464: car = "RC Baron"; case 465: car = "RC Raider";
    case 466: car = "Glendale"; case 467: car = "Oceanic"; case 468: car = "Sanchez"; case 469: car = "Sparrow"; case 470: car = "Patriot"; case 471: car = "Quad";
    case 472: car = "Coastguard"; case 473: car = "Dinghy"; case 474: car = "Hermes"; case 475: car = "Sabre"; case 476: car = "Rustler"; case 477: car = "ZR-350";
    case 478: car = "Walton"; case 479: car = "Regina"; case 480: car = "Comet"; case 481: car = "BMX"; case 482: car = "Burrito"; case 483: car = "Camper";
    case 484: car = "Marquis"; case 485: car = "Baggage"; case 486: car = "Dozer"; case 487: car = "Maverick"; case 488: car = "SAN News Maverick"; case 489: car = "Rancher";
    case 490: car = "FBI Rancher"; case 491: car = "Virgo"; case 492: car = "Greenwood"; case 493: car = "Jetmax"; case 494: car = "Hotring Racer"; case 495: car = "Sandking";
    case 496: car = "Blista Compact"; case 497: car = "Police Maverick"; case 498: car = "Boxville"; case 499: car = "Benson"; case 500: car = "Mesa"; case 501: car = "RC Goblin";
    case 502: car = "Hotring Racer"; case 503: car = "Hotring Racer"; case 504: car = "Bloodring Banger"; case 505: car = "Rancher"; case 506: car = "Super GT"; case 507: car = "Elegant";
    case 508: car = "Journey"; case 509: car = "Bike"; case 510: car = "Mountain Bike"; case 511: car = "Beagle"; case 512: car = "Cropduster"; case 513: car = "Stuntplane";
    case 514: car = "Tanker"; case 515: car = "Roadtrain"; case 516: car = "Nebula"; case 517: car = "Majestice"; case 518: car = "Buccaneer"; case 519: car = "Shamal";
    case 520: car = "Hydra"; case 521: car = "FCR-900"; case 522: car = "NRG-500"; case 523: car = "HPV1000"; case 524: car = "Cement Truck"; case 525: car = "Towtruck";
    case 526: car = "Fortune"; case 527: car = "Cadrona"; case 528: car = "FBI Truck"; case 529: car = "Willard"; case 530: car = "Forklift"; case 531: car = "Tractor";
    case 532: car = "Combine Harvester"; case 533: car = "Feltzer"; case 534: car = "Remington"; case 535: car = "Slamvan"; case 536: car = "Blade"; case 537: car = "Freight";
    case 538: car = "Brownstreak"; case 539: car = "Vortex"; case 540: car = "Vincent"; case 541: car = "Bullet"; case 542: car = "Clover"; case 543: car = "Sadler";
    case 544: car = "Firetruck LA"; case 545: car = "Hustler"; case 546: car = "Intruder"; case 547: car = "Primo"; case 548: car = "Cargobob"; case 549: car = "Tampa";
    case 550: car = "Sunrise"; case 551: car = "Merit"; case 552: car = "Utility Van"; case 553: car = "Nevada"; case 554: car = "Yosemite"; case 555: car = "Windsor";
    case 556: car = "Monster \"A\""; case 557: car = "Monster \"B\""; case 558: car = "Uranus"; case 559: car = "Jester"; case 560: car = "Sultan"; case 561: car = "Stratum";
    case 562: car = "Elegy"; case 563: car = "Raindance"; case 564: car = "RC Tiger"; case 565: car = "Flash"; case 566: car = "Tahoma"; case 567: car = "Savanna";
    case 568: car = "Bandito"; case 569: car = "Freight Flat Trailer"; case 570: car = "Streak Trailer"; case 571: car = "Kart"; case 572: car = "Mower"; case 573: car = "Dune";
    case 574: car = "Sweeper"; case 575: car = "Broadway"; case 576: car = "Tornado"; case 577: car = "AT400"; case 578: car = "DFT-30";
    case 579: car = "Huntley"; case 580: car = "Stafford"; case 581: car = "BF-400"; case 582: car = "Newsvan"; case 583: car = "Tug"; case 584: car = "Petrol Trailer";
    case 585: car = "Emperor"; case 586: car = "Wayfarer"; case 587: car = "Euros"; case 588: car = "Hotdog"; case 589: car = "Club"; case 590: car = "Freight Box Trailer";
    case 591: car = "Article Trailer 3"; case 592: car = "Andromada"; case 593: car = "Dodo"; case 594: car = "RC Cam"; case 595: car = "Launch"; case 596: car = "Police Car (LSPD)";
    case 597: car = "Police Car (SFPD)"; case 598: car = "Police Car (LVPD)"; case 599: car = "Police Ranger"; case 600: car = "Picador"; case 601: car = "S.W.A.T."; case 602: car = "Alpha";
    case 603: car = "Phoenix"; case 604: car = "Glendale Shit"; case 605: car = "Sadler Shit"; case 606: car = "Baggage Trailer A"; case 607: car = "Baggage Trailer B"; case 608: car = "Tug Stairs Trailer";
    case 609: car = "Boxville"; case 610: car = "Farm Trailer"; case 611: car = "Utility Trailer"; default: car = "Unknown";
    }
    return car;
}
stock Pickups()
{
	lspd_pick[0] = CreateDynamicPickup(1318, 23, 1555.5059, -1675.7415, 16.1953); //(id pickup-�, ��� pickup-�, �����) ����� �� �����
	lspd_pick[1] = CreateDynamicPickup(1318, 23, 1568.6741, -1689.9702, 6.2188);//(id pickup-�, ��� pickup-�, �����) ����� � ������
	lspd_pick[2] = CreateDynamicPickup(1318, 23, 246.8043, 62.3237, 1003.6406, 1, 6);//(id pickup-�, ��� pickup-�, �����) ����� � �������
	lspd_pick[3] = CreateDynamicPickup(1318, 23, 246.4056, 88.0078, 1003.6406, 1, 6);//(id pickup-�, ��� pickup-�, �����) ����� �� ������
	lspd_pick[4] = CreateDynamicPickup(1318, 23, 1524.4835,-1677.8490,6.2188); // ����� � ���������
	lspd_pick[5] = CreateDynamicPickup(1318, 23, 316.3202,-170.2966,999.5938); // ����� �� ���������
	lspd_pick[6] = CreateDynamicPickup(2061, 23, 312.1859,-168.7103,999.5938); // ����������
}
stock Cars()//���� �� ������� ����������
{
    lspd_car[0] = AddStaticVehicleEx(596, 1602.4960, -1683.9705, 5.6106, 89.9966, 0, 1, 600);//����� ���������� (id ����������, �����, ���� ��������, �����, ����� ��������)
	lspd_car[1] = AddStaticVehicleEx(596, 1602.4961, -1688.1863, 5.6106, 89.9944, 0, 1, 600);
	lspd_car[2] = AddStaticVehicleEx(596, 1602.4960, -1692.1858, 5.6106, 89.9963, 0, 1, 600);
	lspd_car[3] = AddStaticVehicleEx(596, 1602.4961, -1696.4399, 5.6106, 89.9965, 0, 1, 600);
	lspd_car[4] = AddStaticVehicleEx(596, 1602.4961, -1700.4475, 5.6105, 89.9928, 0, 1, 600);
	lspd_car[5] = AddStaticVehicleEx(596, 1602.4973, -1704.7720, 5.6111, 89.9599, 0, 1, 600);
	lspd_car[6] = AddStaticVehicleEx(596, 1591.1188, -1710.8458, 5.6106, 359.9953, 0, 1, 600);
	lspd_car[7] = AddStaticVehicleEx(596, 1587.0615, -1710.8457, 5.6106, 359.9914, 0, 1, 600);
	lspd_car[8] = AddStaticVehicleEx(596, 1582.9340, -1710.8418, 5.6106, 359.9973, 0, 1, 600);
	lspd_car[9] = AddStaticVehicleEx(596, 1578.0387, -1710.8459, 5.6106, 359.9960, 0, 1, 600);
	lspd_car[10] = AddStaticVehicleEx(596, 1574.0431, -1710.8464, 5.6115, 359.9565, 0, 1, 600);
	lspd_car[11] = AddStaticVehicleEx(596, 1569.6342, -1710.8481, 5.5788, 359.9579, 0, 1, 600);
	lspd_car[12] = AddStaticVehicleEx(596, 1558.3914, -1710.8352, 5.6231, 359.9962, 0, 1, 600);
	lspd_car[13] = AddStaticVehicleEx(596, 1584.5720, -1672.3798, 5.6135, 269.9952, 0, 1, 600);
	lspd_car[14] = AddStaticVehicleEx(596, 1584.5693, -1668.1559, 5.6123, 269.9404, 0, 1, 600);
	lspd_car[15] = AddStaticVehicleEx(523, 1545.6881, -1684.3760, 5.4628, 89.8548, 0, 1, 600);
	lspd_car[16] = AddStaticVehicleEx(523, 1545.6832, -1680.3370, 5.4628, 90.0000, 0, 1, 600);
	lspd_car[17] = AddStaticVehicleEx(523, 1545.6796, -1676.2489, 5.4715, 90.0000, 0, 1, 600);
	lspd_car[18] = AddStaticVehicleEx(523, 1545.6934, -1672.1342, 5.4719, 90.0000, 0, 1, 600);
	lspd_car[19] = AddStaticVehicleEx(523, 1545.7043, -1667.6414, 5.4657, 89.5909, 0, 1, 600);
	lspd_car[20] = AddStaticVehicleEx(523, 1545.6930, -1663.1404, 5.4719, 90.0000, 0, 1, 600);
	lspd_car[21] = AddStaticVehicleEx(601, 1545.4475, -1659.0334, 5.6477, 89.9272, 0, 1, 600);
	lspd_car[22] = AddStaticVehicleEx(601, 1545.4456, -1655.0054, 5.6652, 89.9993, 0, 1, 600);
	lspd_car[23] = AddStaticVehicleEx(427, 1538.1487, -1644.9996, 6.0336, 180.0003, 0, 1, 600);
	lspd_car[24] = AddStaticVehicleEx(427, 1534.1730, -1644.9996, 6.0335, 180.0002, 0, 1, 600);
	lspd_car[25] = AddStaticVehicleEx(427, 1529.9532, -1644.9991, 6.0335, 180.0003, 0, 1, 600);
	lspd_car[26] = AddStaticVehicleEx(497, 1559.2762,-1644.1458,28.5774,90.9602, 0, 1, 600);
}
stock DialogGunLSPD(playerid)
{
    SPD(playerid, 26, DIALOG_STYLE_TABLIST_HEADERS, "��������� �����",
	!"\
		{FFFFFF}���:\t{FFFFFF}�������:\
		\n1) Deagle\t\t35\
		\n2) ShotGun\t\t20\
		\n3) MP5\t\t60\
		\n4) ������\
		\n5) ����������", "�������", "������\
	");
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ������� ������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cmd:menu(playerid)//cmd:��� �������(playerid, params[])
{
    SPD(playerid, 8, DIALOG_STYLE_LIST, !"���",!"\
	{F5DEB3}��������\
	\n{F5DEB3}���������\
	\n{F5DEB3}������ ������\
	\n{F5DEB3}������� �������\
	\n{F5DEB3}���������\
	\n{F5DEB3}���������� �������",!"�����",!"�����");
	return true;
}
alias:menu("mm", "mn", "kpk");//alias:�������(�������������� �������);
cmd:time(playerid)
{
    new
		string[84];
    gettime(hour_server, minute_server, second_server);
    format(string, sizeof(string), "{008000}����� �� �������: %d ����� %d ����� %d ������", hour_server, minute_server, second_server);
    SCM(playerid, 0x008000FF, string);
}
cmd:gps(playerid)
{
    ShowGPS(playerid);
}
cmd:report(playerid)
{
    DialogReport(playerid);
}
cmd:donate(playerid)
{
    SPD(playerid, 20, DIALOG_STYLE_LIST, !"�����-�������",!"\
	{F5DEB3}������� ������\
	\n{F5DEB3}�������\
	\n{F5DEB3}�������",!"�������",!"�����");
	return true;
}
alias:donate("donat", "don");
cmd:kick(playerid, params[])
{
	if(player[playerid][padmin] < 1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);
    if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
	if(sscanf(params, "ds[144]", params[0], params[1]))//"ds" - �������������, params[0] - ID, params[1] - �������([144] - ������)
		return SCM(playerid, ColorGreen, !"������� ������� /kick [ID] [�������]");
	if(!IsPlayerConnected(params[0]))
	    return SCM(playerid, ColorRed, !"����� �� ������!");
	if(login_check{params[0]} == false)
		return SCM(playerid, ColorRed, !"����� �� �����������!");
	if(player[params[0]][padmin] >= player[playerid][padmin])
	    return SCM(playerid, ColorRed, !"��������� ����� ���� ��� ��� ����� ��� �� ������ �����������������!");
	static const
	    	fmt_str[] = "������������� %s ������ ������ %s. �������: %s";
	new
	    	string[sizeof(fmt_str)+MAX_PLAYER_NAME*2+70];

	format(string, sizeof(string), fmt_str, GN(playerid), GN(params[0]), params[1]);
	SCMTA(ColorOrange, string);
	Tkick(params[0]);
	return true;
}
cmd:alogin(playerid, params[])
{
    if(player[playerid][padmin] < 1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    DialogAdminRegistration(playerid);
	if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);
	return true;
}
cmd:ahelp(playerid)
{
    if(player[playerid][padmin] < 1)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	    
	SPD(playerid, 24, DIALOG_STYLE_LIST, !"�����-�������", !"\
		{DF8600}������� ������� �������:\
		{FFFFFF}1 �������\
		{FFFFFF}2 �������\
		{FFFFFF}3 �������\
		{FFFFFF}4 �������\
		{FFFFFF}5 �������\
		{FFFFFF}6 �������\
		{FFFFFF}7 �������\
		{FFFFFF}8 �������\
		\n", !"�������", !"������");
	return true;
}
cmd:makeleader(playerid, params[])
{
    if(player[playerid][padmin] < 6)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
    if(sscanf(params, "dd", params[0], params[1]))
		return SCM(playerid, ColorGreen, !"������� ������� /makeleader [ID] [ID ������� (0 - 1)]");//��������
		//return SCM(playerid, ColorGreen, strcat(!"������� ������� /makeleader [ID] [ID ������� (0 - ", MAX_LEADER));
	if(!IsPlayerConnected(params[0]))
	    return SCM(playerid, ColorRed, !"����� �� ������!");
	if(login_check{params[0]} == false)
		return SCM(playerid, ColorRed, !"����� �� �����������!");
	if(!(0 <= params[1] <= MAX_LEADER_NUM))
	    return SCM(playerid, ColorGreen, !"������� � ������ ID �� ����������!");
	if(params[1] == 0)
	{
	    if(player[params[0]][pmember] == 0)
	        return SCM(playerid, ColorGreen, !"����� �� ������� �� �������!");
	        
		player[params[0]][pmember] = 0;
		player[params[0]][prank] = 0;
		SavePlayer(params[0], "Member", player[params[0]][pmember], "d");
		SavePlayer(params[0], "Rank", player[params[0]][prank], "d");
		ClearKillFeed(params[0]);
		ResetPlayerWeapons(params[0]);//��������� ������ �������
		SetPlayerArmour(params[0], 0.0);//��������� ������ �����
		SetPlayerHealth(params[0], 100.0);//��������� ������ ��������
		SetPlayerSkin(params[0], player[params[0]][pskin]);
		Clist(params[0]);
		static const
			fmt_str[] = "�� ����� %s[%d] � �������",
		    fmt_str_2[] = "������������� %s[%d] ���� ��� � �������";
		new
		    string[sizeof(fmt_str) + MAX_PLAYER_NAME],
		    string_2[sizeof(fmt_str_2) + MAX_PLAYER_NAME];

		format(string, sizeof(string), fmt_str, GN(params[0]), params[0]);
		format(string_2, sizeof(string), fmt_str_2, GN(playerid), playerid);
		SCM(playerid, ColorRed, string);
		AdmChat(ColorRed, string_2);
		return true;
	}
	
	player[params[0]][prank] = 10;
	switch(params[1])
	{
	    case 1:
	    {
	        if(player[params[0]][psex] == 1)
				SetPlayerSkin(params[0], 288); // M sex
			else
                SetPlayerSkin(params[0], 306); // W sex
	    }
	}
	player[params[0]][pmodel] = GetPlayerSkin(params[0]);
	player[params[0]][pmember] = params[1];
	Clist(params[0]);
	ResetPlayerWeapons(params[0]);
	ClearKillFeed(params[0]);
	SetPlayerArmour(params[0], 0.0);
	SetPlayerHealth(params[0], 100.0);
	SavePlayer(params[0], "Model", player[params[0]][pmodel], "d");
	SavePlayer(params[0], "Member", player[params[0]][pmember], "d");
	SavePlayer(params[0], "Rank", player[params[0]][prank], "d");
	static const
		fmt_str[] = "�� ��������� %s[%d] �� ������� %s",
	    fmt_str_2[] = "������������� %s[%d] �������� %s[%d] �� ������� %s";
	new
 		string[sizeof(fmt_str) + MAX_PLAYER_NAME + 30],
   		string_2[sizeof(fmt_str_2) + MAX_PLAYER_NAME + 30];

	format(string, sizeof(string), fmt_str, GN(params[0]), params[0], leaders_info[player[params[0]][pmember] - 1]);
	format(string_2, sizeof(string), fmt_str_2, GN(playerid), playerid, GN(params[0]), params[0], leaders_info[player[params[0]][pmember] - 1]);
	SCM(playerid, ColorRed, string);
	AdmChat(ColorRed, string_2);
	return true;
}
cmd:veh(playerid, params[])
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	if(sscanf(params, "ddd", params[0], params[1], params[2]))
		return SCM(playerid, ColorGreen, !"������� ������� /veh [ID ����������] [ID ������� �����] [ID ������� �����]");
	if(!(400 <= params[0] <= 611))
		return SCM(playerid, ColorGreen, !"�������� id ���������� [400 - 611]");
	if(params[1] < 0 || params[1] > 255 || params[2] < 0 || params[2] > 255)
		return SCM(playerid, ColorGreen, !"�������� id �����");
	
	new
	    currentveh,
	    Float: X,
		Float: Y,
		Float: Z,
		Float: Angle; //������, Float � pawn ������ ���� � ������� �����
		
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, X, Y, Z);
	currentveh = CreateVehicle(params[0], X + 3.0, Y, Z + 1.0, Angle, params[1], params[2], 99999);//�������� ����������(� ����� - ����� � ����� ������)
	SetVehicleNumberPlate(currentveh, "Admin");
	static const
			fmt_str[] = "�� ������� ��������� - {FFFF00}%s";
	new
		    string[sizeof(fmt_str) + 40];

	format(string, sizeof(string), fmt_str, GetVehicleName(params[0]));
	SCM(playerid, ColorGreen, string);
	return true;
}
cmd:destroyveh(playerid)
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	new
		currentveh;
	currentveh = GetPlayerVehicleID(playerid);
	DestroyVehicle(currentveh);
	return true;
}
alias:destroyveh("remove", "remveh", "delveh");
cmd:elegyveh(playerid)
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
    new
		elegytun,
		Float: X,
		Float: Y,
		Float: Z,
		Float: Angle;
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, X, Y, Z);
	elegytun = CreateVehicle(562, X + 3.0, Y, Z + 1.0, Angle, 1, 3, 99999);
    AddVehicleComponent(elegytun,1035);
    AddVehicleComponent(elegytun,1036);
    AddVehicleComponent(elegytun,1040);
    AddVehicleComponent(elegytun,1046);
    AddVehicleComponent(elegytun,1147);
    AddVehicleComponent(elegytun,1149);
    AddVehicleComponent(elegytun,1171);
    ChangeVehiclePaintjob(elegytun, 2);
    ChangeVehicleColor(elegytun, 6, 6);
    AddVehicleComponent(elegytun,1010);
    AddVehicleComponent(elegytun,1080);
    AddVehicleComponent(elegytun,1087);
    SetVehicleNumberPlate(elegytun, "Admin");
	return true;
}
cmd:sultanveh(playerid)
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
    new
		sultanveh,
		Float: X,
		Float: Y,
		Float: Z,
		Float: Angle;
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, X, Y, Z);
	sultanveh = CreateVehicle(560, X + 3.0, Y, Z + 1.0, Angle, 1, 3, 99999);
	AddVehicleComponent(sultanveh,1029);
    AddVehicleComponent(sultanveh,1030);
    AddVehicleComponent(sultanveh,1031);
    AddVehicleComponent(sultanveh,1033);
    AddVehicleComponent(sultanveh,1046);
    AddVehicleComponent(sultanveh,1139);
    AddVehicleComponent(sultanveh,1170);
    ChangeVehiclePaintjob(sultanveh, 1);
    ChangeVehicleColor(sultanveh, 1, 1);
    AddVehicleComponent(sultanveh,1010);
    AddVehicleComponent(sultanveh,1080);
    AddVehicleComponent(sultanveh,1087);
    SetVehicleNumberPlate(sultanveh, "Admin");
	return true;
}
cmd:flashveh(playerid)
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
    new
		flashveh,
		Float: X,
		Float: Y,
		Float: Z,
		Float: Angle;
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, X, Y, Z);
	flashveh = CreateVehicle(565, X + 3.0, Y, Z + 1.0, Angle, 1, 3, 99999);
	AddVehicleComponent(flashveh,1045);
    AddVehicleComponent(flashveh,1047);
    AddVehicleComponent(flashveh,1050);
    AddVehicleComponent(flashveh,1052);
    AddVehicleComponent(flashveh,1053);
    AddVehicleComponent(flashveh,1151);
    AddVehicleComponent(flashveh,1153);
    ChangeVehiclePaintjob(flashveh, 0);
    ChangeVehicleColor(flashveh, 1, 1);
    AddVehicleComponent(flashveh,1010);
    AddVehicleComponent(flashveh,1080);
    AddVehicleComponent(flashveh,1087);
    SetVehicleNumberPlate(flashveh, "Admin");//(id ����������, �������)
	return true;
}
cmd:vehid(playerid)
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	new
		currentveh,
		vehmodel;

	currentveh = GetPlayerVehicleID(playerid);
	vehmodel = GetVehicleModel(currentveh);
	static const
		fmt_str[] = "������ ��������� ����� id: {FFFF00}%d {008000}, ������ ����������: {FFFF00}%s[%d]";
	new
 		string[sizeof(fmt_str) + 30];

	format(string, sizeof(string), fmt_str, currentveh, GetVehicleName(vehmodel) ,vehmodel);
	SCM(playerid, ColorGreen, string);
	return true;
}
cmd:changenumberplate(playerid, params[]) //��������
{
    if(player[playerid][padmin] < 3)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	if(sscanf(params, "s", params[0]))
		return SCM(playerid, ColorGreen, !"������� ������� /changenumberplate [�������� ����]");
	new
	    currentveh,
	    string[20];
	format(string,sizeof(string),"%s",params[0]);
    currentveh = GetPlayerVehicleID(playerid);
    SetVehicleNumberPlate(currentveh, string);
	return true;
}
cmd:spawn(playerid)
{
    if(player[playerid][padmin] < 1)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	SetPlayerSpawn(playerid);
	return true;
}
CMD:test(playerid)// ���� �������
{
    if(player[playerid][padmin] < 7)//�������� � ������ �����-������� (1)
	    return SCM(playerid, ColorRed, !"�� �� ������������ ������������ ������ �������!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"������� ������� /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//�������� � ������ �����-������� (2)
	SetPlayerPos(playerid, 316.524993,-167.706985,999.593750);
	SetPlayerInterior(playerid, 6);
	return true;
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ ��������� ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
main()
{
	print("\n---------------------------------------");
	print("=== [This mode was made by rialbat] ===");
	print(GM_NAME);
	print("=== [vk.com] ===");
	print("---------------------------------------\n");
	print("\n");
}
