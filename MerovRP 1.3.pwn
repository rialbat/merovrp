//Admin Skin - 98
//MerovRP v1.3
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Инклуды ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include 			<a_samp>
#include 			<a_mysql>
#include 			<foreach>
#include 			<mxdate>
#include 			<Pawn.CMD>
#include 			<sscanf2>
#include 			<streamer>
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ База данных ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define MySQL_HOST 	"127.0.0.1" //Дефайны, константы, которые используем вместо переменных в функциях
#define MySQL_USER 	"root"
#define MySQL_DB 	"MerovRP"
#define MySQL_PASS  ""
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Цвета ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Дефайны ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define GM_NAME			!"=== [MerovRP v1.3] ==="
#define GN(%0)			player_name[%0]//Дефайн с параментром, %0 - парядковый номер аргумента функции
#define SCM     		SendClientMessage
#define SPD 			ShowPlayerDialog
#define Tkick(%0)   	SetTimerEx("@_PlayerKick", 100, false, "i",%0)
#define Freeze(%0,%1) 	TogglePlayerControllable(%0, %1)
#define SCMTA    		SendClientMessageToAll

#define MAX_LEADER_NUM 	1

#if !defined isnull//Макросы (1 - для оптимизации strlen();)
#define isnull(%0)      ((!(%0[0])) || (((%0[0]) == '\1') && (!(%0[1]))))
#endif

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Переменные ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
new
	connect_mysql,
	hour_server,
 	minute_server,
  	second_server,
	
	number_skin[MAX_PLAYERS char],//Создание массива
	number_pass[MAX_PLAYERS char],
	update_timer[MAX_PLAYERS],
	login_timer[MAX_PLAYERS],
	player_name[MAX_PLAYERS][MAX_PLAYER_NAME],
	report_timer[MAX_PLAYERS],
 	//MAX_LEADER[7] = "1)]",
	
	Text: td_select_skin[MAX_PLAYERS][3],//Переменные для текстдравов
	Text: td_uper_text[MAX_PLAYERS][4],
	
	lspd_pick[7],// Пикапы ЛСПД
	lspd_car[27],// Транспорт ЛСПД
	
	Float: pos_pick[3][MAX_PLAYERS],//Переменные типа float
	
	bool: login_check[MAX_PLAYERS char],//Переменная бул типа, для проверци регистрации
	bool: report_check[MAX_PLAYERS char],
	bool: access_check[MAX_PLAYERS char],
	bool: anti_flood_pick[MAX_PLAYERS char],
	
	sex_info[2][7+1] = {"Мужской", "Женский"},//Двумерные массивы
	nations_info[5][10+1] = {"Русский", "Американец", "Японец", "Китаец", "Итальянец"},
	leaders_info[1][4+1] = {"LSPD"},// Лидерки
	Iterator: connect_admins<MAX_PLAYERS>;//Итераторы
enum pinfo //Название структуры
{
	ppass[32+1], pmail[70+1], plevel, pmoney, psex, pskin, page, pnations, pid, preferal_check, preferal[MAX_PLAYER_NAME+1], pdate_reg[11+1], pexp, pmaxexp,
	padmin, pdonate, pakeys, pakey[20+1], pmember, prank, pmodel//Все переменные из БД, +1 для нуля-терменатора
}
new player[MAX_PLAYERS][pinfo];//MAX_PLAYERS
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Паблики ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])//Паблик диалога
{
	switch(dialogid)
	{
	    case 1:
	    {
   			if(response)//Если нажата левая клавиша
   			{
				new
				    len = strlen(inputtext);
   			    if(!len)
   			    {
					SCM(playerid, ColorGreen, !"Вы ничего не ввели");
					DialogRegistration(playerid);
					return true;
			   	}
			   	if(!(6 <= len <= 32))
			   	{
			   	    SCM(playerid, ColorGreen, !"Неверная длина пароля");
					DialogRegistration(playerid);
					return true;
		   		}
		   		if(CheckRussianText(inputtext, len+1))// Проверка на русские символы
		   		{
					SCM(playerid, ColorGreen, !"Смените раскладку клавиатуры!");
					DialogRegistration(playerid);
					return true;
				}
				strmid(player[playerid][ppass], inputtext, 0, len, 32+1);//Запись текста/значений в массив - куда записывать, откуда, с какого символа, длина текста, максимальная длина считываемого текста
				DialogEmail(playerid);
      		}
		   	else //Если нажата правая клавиша
		   	{
				SCM(playerid, ColorRed, !"Введите (/q)uit чтобы выйти");
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
					SCM(playerid, ColorGreen, !"Вы ничего не ввели");
					DialogEmail(playerid);
					return true;
			   	}
			   	if(!(6 <= len <= 70))
			   	{
			   	    SCM(playerid, ColorGreen, !"Неверная длина почты");
					DialogEmail(playerid);
					return true;
		   		}
		   		if(strfind(inputtext, "@", false) == -1 || strfind(inputtext, ".", false) == -1)//Ищет символ в строке - строка, сивол, учитывается ли регистр
		   		{
		   		    SCM(playerid, ColorGreen, !"Неверный формат почты!");
					DialogEmail(playerid);
					return true;
		   		}
		   		if(CheckRussianText(inputtext, len+1))// Проверка на русские символы
		   		{
					SCM(playerid, ColorGreen, !"Смените раскладку клавиатуры!");
					DialogRegistration(playerid);
					return true;
				}
				strmid(player[playerid][pmail], inputtext, 0, len, 70+1);//Запись текста/значений в массив - куда записывать, откуда, с какого символа, длина текста, максимальная длина считываемого текста
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
					SCM(playerid, ColorGreen, !"Вы ничего не ввели");
					DialogRegistration(playerid);
					return true;
			   	}
			   	if(!(18 <= val <= 70))
			   	{
			   	    SCM(playerid, ColorGreen, !"Возраст не может быть меньше 18-ти или больше 70-ти лет!");
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
					SCM(playerid, ColorGreen, !"Вы ничего не ввели");
					DialogReferal(playerid);
					return true;
			   	}
			   	static //Удаляем const, если используем mysql format
			    fmt_str[] = "SELECT `Level` FROM `accounts` WHERE `Name` = '%e' LIMIT 1";//Что-либо из БД аккаунты, по имени
				new
				    string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//Отнимаем 2 из-за %s, +1 из-за нуля-терминатора

				mysql_format(connect_mysql, string, sizeof(string), fmt_str, (inputtext));
				mysql_function_query(connect_mysql, string, true, "@_CheckRef", "de", playerid, inputtext);//@_PlayerCheck - паблик, d - параметры(id игрока)
				//SCM(playerid, ColorWhite, string);//Отправить сообщение игроку в чате
			}
 			else
	 		{
	 		    //strmid(player[playerid][preferal], "None", 0, strlen("None"), 4+1);//Если нажата кнопка "Пропустить", в рефералы записывается сново "None"
    			DialogSex(playerid);
	   		}
		}
		case 6:
     	{
     	    SpawnPlayer(playerid);
   			if(response)
   			{
	  			player[playerid][psex] = 1;//Мужской
	  			SetPlayerSkin(playerid, 78);//Установка скина игроку (id игрока, номер скина)
				number_skin{playerid} = 1;//{} - т.к используем оператор char, оператор char нельзя использловать, если значение переменной больше, чем 255 и в таймерах
		   	}
 			else
	 		{
    			player[playerid][psex] = 2;//Женский
    			SetPlayerSkin(playerid, 10);
    			number_skin{playerid} = 11;
	   		}
	   		
	   		for(new i; i!=3; i++)
	   		{
	   		TextDrawShowForPlayer(playerid, td_select_skin[playerid][i]);
	   		}
	   		SelectTextDraw(playerid, 0xFF0000FF);//При наведении на текстдрав, текстдрав подсвечивается(меняет цвет на красный)
	   		SetPlayerVirtualWorld(playerid, playerid);//Создаёт отдельный мир для игрока, необходимо для того, чтобы игрок не соприкосался с другими игроками(id игрока, id виртуального мира)
			SetPlayerInterior(playerid, 3);//Поместить игрока в интерьер(id игрока, id интерьера)
			SetPlayerPos(playerid, 513.4482,-13.6003,1001.5653);//Перемещение игрока на позицию интерьера
			SetPlayerFacingAngle(playerid, 343.2249);//Поворот игрока
			SetPlayerCameraPos(playerid, 514.7122, -9.7444, 1001.5653);//Установка позиции камеры
			SetPlayerCameraLookAt(playerid, 513.4482,-13.6003,1001.5653);//На что смотрит камера
			Freeze(playerid, 0);//Заморозка игрока: 0 - заморозка, 1 - разморозка (TogglePlayerControllable(playerid, 0))
		}
		case 7:
     	{
   			if(response)
   			{
   			    if(isnull(inputtext))
   			    {
					SCM(playerid, ColorGreen, !"Вы ничего не ввели");
					DialogLogin(playerid);
					return true;
			   	}
			   	static //Удаляем const, если используем mysql format
    				fmt_str[] = "SELECT * FROM `accounts` WHERE `Name` = '%s' AND `Pass` = '%s' LIMIT 1";//Что-либо из БД аккаунты, по имени
				new
	    			string[sizeof(fmt_str)+MAX_PLAYER_NAME+29];

				mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid), inputtext);
				mysql_function_query(connect_mysql, string, true, "@_OnLogin", "d", playerid);
			   	
			}
 			else
	 		{
    			SCM(playerid, ColorRed, !"Введите (/q)uit чтобы выйти");
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
   			        case 0: ComBase(playerid);// Основные
   			        /*case 1: ComWork(playerid);// Работа
   			        case 2: ComChat(playerid);// Чат
   			        case 3: ComPhone(playerid);// Телефон
   			        case 4: ComHome(playerid);// Дом/Отель
   			        case 5: ComBiz(playerid);// Бизнес
   			        case 6: ComVeh(playerid);// Транспорт
   			        case 7: ComFood(playerid);// Рыбалка/Еда
   			        case 8: ComWed(playerid);// Свадьбы
   			        case 9: ComIRC(playerid);// IRC
   			        case 10: ComLeder(playerid);// Лидерство
   			        case 11: ComAnim(playerid);// Анимации
   			        case 12: ComRull(playerid);// Законники
   			        case 13: ComLoy(playerid);// Адвокаты
   			        case 14: ComMCHS(playerid);// МЧС
   			        case 15: ComTaxi(playerid);// Такси
   			        case 16: ComHitman(playerid);// Наёмные убийцы
   			        case 17: ComRep(playerid);// Репортёры*/
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
   			if(!response)//!Т.к проверка только на правую клавишу(Меняем клавиши местами)
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
   			        SCM(playerid, ColorGreen, !"Вы ничего не ввели");
   			        return true;
			   	}
				if(report_check{playerid} == true)
				{

   			        DialogReport(playerid);
   			        SCM(playerid, ColorGreen, !"Пожалуйста подождите перед отправкой следующего сообщения администрации!");
   			        return true;
				}

			    static const
				    fmt_str[] = "Ваша жалоба: %s",
				    fmt_str_2[] = "%s[%d] отправил жалобу: %s";
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
   			        SCM(playerid, ColorGreen, !"Вы ничего не ввели");
   			        return true;
			   	}
   			    if(player[playerid][pdonate] < val)
   			    {
   			        DialogDonateConv(playerid);
   			        SCM(playerid, ColorGreen, !"У вас недостаточно донат-рублей!");
   			        return true;
			   	}
			   	if(!(0 < val <= 99999999999))
			   	{
			   	    SCM(playerid, ColorGreen, !"Неверное значение введённого числа!");
					DialogDonateConv(playerid);
					return true;
		   		}
		   		static const
			    	fmt_str[] = "Вы перевели {FFFF00}%d {FFFFFF}донат-рублей в {FFFF00}%d{FFFFFF} игровых долларов";
				new
			    	string[sizeof(fmt_str)+18],
			    	money = val*1_000;//Курс

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
       			SCM(playerid, ColorGreen, !"Вы ничего не ввели");
		        return true;
		   	}
			new
				len = strlen(inputtext);
   			if(!(6 <= len <= 20))
			   	{
			   	    SCM(playerid, ColorGreen, !"Неверная длина пароля");
					DialogAdminRegistration(playerid);
					return true;
		   		}
        	if(CheckRussianText(inputtext, len+1))
		   		{
					SCM(playerid, ColorGreen, !"Смените раскладку клавиатуры!");
					DialogAdminRegistration(playerid);
					return true;
				}
            static const
	    		fmt_str[] = "Ваш админ-пароль:	%s";
			new
	    		string[sizeof(fmt_str)+38];

			format(string, sizeof(string), fmt_str, inputtext);
			SCM(playerid, ColorGreen, string);
			SCM(playerid, ColorGreen, !"Рекомендуем сделать скриншот (F8), чтобы не забыть админ-пароль!");
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
       			SCM(playerid, ColorGreen, !"Вы ничего не ввели");
		        return true;
		   	}
			if(strcmp(player[playerid][pakey], inputtext, false) != 0 || len <=0)
			{
			    DialogAdminLogin(playerid);
   			    SCM(playerid, ColorRed, !"Неверный админ-пароль!");
			    return true;
			}
		 	static const
	    		fmt_str[] = "Администратор: {FFFFFF}%s[%d], %d уровня {DF8600}авторизовался!";
		 	new
	    		string[sizeof(fmt_str)+MAX_PLAYER_NAME];

			format(string, sizeof(string), fmt_str, GN(playerid), playerid, player[playerid][padmin]);
			AdmChat(ColorOrange, string);
			access_check{playerid} = true;
			SCM(playerid, ColorGreen, !"Админ-авторизация прошла успешно! Добро пожаловать!");
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
   			            SCM(playerid, ColorRed, !"Выберите уровень администрирования!");
			   		}
			   		case 1:
   			        {
						SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 1-го уровня", !"\
						\n{00BFFF}/kick {FFFFFF} - Кикнуть игрока\
						\n{00BFFF}/spawn {FFFFFF} - Спавн\
						", !"Принять", !"Назад");
			   		}
			   		case 2:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 2-го уровня", !"\
						\n{FF0000}В разработке\
						", !"Принять", !"Назад");
			   		}
			   		case 3:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 3-го уровня", !"\
						\n{00BFFF}/veh {FFFFFF} - Создать транспорт\
						", !"Принять", !"Назад");
			   		}
			   		case 4:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 4-го уровня", !"\
						\n{FF0000}В разработке\
						", !"Принять", !"Назад");
			   		}
			   		case 5:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 5-го уровня", !"\
						\n{FF0000}В разработке\
						", !"Принять", !"Назад");
			   		}
			   		case 6:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 6-го уровня", !"\
						\n{FF0000}/makeleader - Назначить/уволить лидера\
						", !"Принять", !"Назад");
			   		}
			   		case 7:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 7-го уровня", !"\
						\n{FF0000}В разработке\
						", !"Принять", !"Назад");
			   		}
			   		case 8:
   			        {
                        SPD(playerid, 25, DIALOG_STYLE_MSGBOX, !"Команды 8-го уровня", !"\
						\n{FF0000}В разработке\
						", !"Принять", !"Назад");
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
				        GivePlayerWeapon(playerid, 24, 35);//Выдача игроку оружия
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
				DialogGunLSPD(playerid);//Обновление диалога после выбора
			}
		}
	}
	return true;
}
public OnGameModeInit()//При запуске сервера
{
	SetGameModeText("MerovRP");
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0); //Спавн игрока по параметрам: id скина, 3 коорд. , угол поворота, 6 ненужных значений
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);//Показывает маркеры игрока 0- нет, 1- по всей карте, 2 - ограниченно
    ShowNameTags(true); //Показывает Теги у игроков
    SetNameTagDrawDistance(20.0); //На какой дистанции видны имена игроков
    DisableInteriorEnterExits();//Убирает вход в стандартные дома из сингла
    EnableStuntBonusForAll(0);//Убирает бонус за трюки
    connect_mysql = mysql_connect(MySQL_HOST, MySQL_USER, MySQL_DB, MySQL_PASS);//Подключение к БД: хост, имя пользователя, База данных, пароль
    mysql_function_query(connect_mysql, "SET NAMES utf8", false, "", "");//Подключение к базе, тип сравнения, кэширование, паблик, кол-во аргуметов паблика
    mysql_function_query(connect_mysql, "SET CHARACTER SET 'cp1251'", false, "", "");/*Подключение к базе, выставление кодировки для приёма русских символов в бд,
	кэширование, паблик, кол-во аргуметов паблика*/
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

	GetPlayerName(playerid, player_name[playerid], MAX_PLAYER_NAME);//id игрока, массив,куда записываем, кол-во
	static //Удаляем const, если используем mysql format
	    fmt_str[] = "SELECT * FROM `accounts` WHERE `Name` = '%s' LIMIT 1";//Что-либо из БД аккаунты, по имени
	new
	    string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//Отнимаем 2 из-за %s, +1 из-за нуля-терминатора
	
	mysql_format(connect_mysql, string, sizeof(string), fmt_str, GN(playerid));
	mysql_function_query(connect_mysql, string, true, "@_PlayerCheck", "d", playerid);//@_PlayerCheck - паблик, d - параметры(id игрока)
	//SCM(playerid, ColorWhite, string);//Отправить сообщение игроку в чате
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
	    SCM(playerid, ColorGreen, "Вы не авторизованы!");
	    return false;
	}
	
	switch(player[playerid][pmember])//Клист в чате, в зависимости от фракции
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
	    ApplyAnimation(playerid, "PED", "IDLE_chat", 4.1, 0, 1, 1, 1, 1);// Применить анимацию (id игрока, библиотека, конкретная анимация из библиотеки, время воспроизведения, координаты, таймер)
	    SetTimerEx("@_ClearAnim", 3_000, false, "i", playerid);//Таймер для очистки анимации
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
public OnPlayerStateChange(playerid, newstate, oldstate)//Меняет расположение игрока
{
	//Система ключей
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
			    SCM(playerid, ColorGreen, "Вы не можете управлять транспортом ЛСПД!");
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
public OnPlayerPickUpDynamicPickup(playerid, pickupid)//Пикапы
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
	    SetPlayerPos(playerid, 246.5715, 65.2846, 1003.6406);//Кооры спавна
		SetPlayerFacingAngle(playerid, 2.3383);//Угол поворота
		SetPlayerVirtualWorld(playerid, 1);//Помещение игрока в мир с id = 0
		SetPlayerInterior(playerid, 6);//Установка интерьера
		SetCameraBehindPlayer(playerid);//Установка камеры позади игрока
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
			return SCM(playerid, ColorGrey, !"В не состоите в LSPD!");

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
	    SCM(playerid, ColorGreen, "Вы не авторизованы!");
	    return false;
	}
	return true;
}
public OnPlayerClickTextDraw(playerid, Text: clickedid)
{
	if(clickedid == Text:INVALID_TEXT_DRAW && number_skin{playerid} > 0)
	    SelectTextDraw(playerid, 0xFF0000FF);// Для возвращения кликабельности после нажатия кнопки Esc
	if(clickedid == td_select_skin[playerid][0])
	{
	    number_skin{playerid} ++;
	    if(player[playerid][psex] == 1)//Вращение скинов по кругу
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
	        // Мужские скины
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
	        // Женские скины
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
	    if(player[playerid][psex] == 1)//Вращение скинов по кругу
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
	        // Мужские скины
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
	        // Женские скины
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
	    for(new i; i != 3; i++) TextDrawHideForPlayer(playerid, td_select_skin[playerid][i]);//Скрытие текстдравов
	    SCM(playerid, ColorWhite, !"Создание аккаунта прошло успешно!");
	    login_check{playerid} = true;
	    update_timer[playerid] = SetTimerEx("@_UpdateTime", 1_000, false, "i", playerid);//Для перезапуска таймера, после входа игрока, и выключение при выходу
	    Freeze(playerid, 1);
	    number_skin{playerid} = 0;//Выходим из режима выбора скина
	    CancelSelectTextDraw(playerid);//Выходим из режима кликабельности текстдровов
		//Создание аккаунта
	    player[playerid][plevel] = 0;//Начальный уровень
	    player[playerid][pmoney] = 300;//Начальные деньги
	    player[playerid][pmaxexp] = 4;
	    player[playerid][pdonate] = 0;
	    player[playerid][pskin] = GetPlayerSkin(playerid);
		//
		getdate(year_server, mounth_server, day_server);//Получение даты с компьютера (год, месяц, день)
		format(player[playerid][pdate_reg], 10+1, "%02d/%02d/%02d", day_server, mounth_server, year_server);
		//
		static
		    fmt_str[] =
			"\
				INSERT INTO `accounts` (`Name`, `Pass`, `Mail`, `Sex`, `Skin`, `Age`, `Nations`, `Level`, `Referal`, `Referal Check`, `Money`, `Exp`, `Maxexp`, `Date Reg`) VALUES ('%s', '%s', \
				'%s', '%d', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%s')\
			";// VALUES - Связывает строки со значениями
		new
		    string[sizeof(fmt_str)+MAX_PLAYER_NAME*2+94];//Переподсчёт значений

		mysql_format(connect_mysql, string, sizeof(string), fmt_str,
		GN(playerid), player[playerid][ppass], player[playerid][pmail], player[playerid][psex], player[playerid][pskin], player[playerid][page],
		player[playerid][pnations], player[playerid][plevel], player[playerid][preferal], player[playerid][preferal_check], player[playerid][pmoney], player[playerid][pexp],
		player[playerid][pmaxexp], player[playerid][pdate_reg]);
		
		mysql_function_query(connect_mysql, string, true, "@_GetID", "i", playerid);
	    SpawnPlayer(playerid);
	}

 	return true;
}
@_PlayerCheck(playerid);//Объявление нового паблика, @_ - вместо forward
@_PlayerCheck(playerid)//Класс приёма данных(Регистрация, авторизация)
{
	new
		rows,
		fields;
		
	cache_get_data(rows, fields);
	if(rows) //Авторизация
	{
	        login_timer[playerid] = SetTimerEx("@_CheckLogin", 1_000 * 60, false, "i",playerid);
			DialogLogin(playerid);
 	}
	else //Регистрация
	{
			static const
	   			reset_data[pinfo];
	        player[playerid] = reset_data;
			DialogRegistration(playerid);
	}
	SCM(playerid, ColorRed, !"{FF0000}Добро пожаловать на сервер {FFFF00}Merov Role Play"); //{Код цвета}, !Упоковывание текста(сокращение кол-ва выделенной памяти)
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

	update_timer[playerid] = SetTimerEx("@_UpdateTime", 1_000, false, "i",playerid);//Таймер, который будет функционировать только у определённого игрока, i - идентификатор id, playerid - id игрока
	//SetTimer("@_UpdateTime", false, 1_000);//Стандартный таймер - Пабик, True/false - сам циклирует или же нет,если false - то скарботает один раз, через какое время
	return true;
}
@_PlayerKick(playerid);
@_PlayerKick(playerid)
{
	Kick(playerid);
	return true;
}
@_CheckRef(playerid, name[]);//Объявление нового паблика, @_ - вместо forward
@_CheckRef(playerid, name[])
{
	new
		rows,
		fields;

	cache_get_data(rows, fields);
	if(!rows)//Если аккаунт не был найден
	{
	    SCM(playerid, ColorGreen, !"Аккаунт не найден");
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

	player[playerid][pid] = cache_insert_id();// Напрямую получаем id из авто инкримент
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
  	    //Загрузка текстовых данных из БД
		cache_get_field_content(0, "Pass", player[playerid][ppass], connect_mysql, 32+1);// Загружаем данные из Pass в ppass
		cache_get_field_content(0, "Mail", player[playerid][pmail], connect_mysql, 60+1);
		cache_get_field_content(0, "Referal", player[playerid][preferal], connect_mysql, MAX_PLAYER_NAME+1);
		cache_get_field_content(0, "Date Reg", player[playerid][pdate_reg], connect_mysql, 11+1);
		cache_get_field_content(0, "Akey", player[playerid][pakey], connect_mysql, 20+1);
		//Загрузка целочисленных данных из БД
		player[playerid][pid] = cache_get_field_content_int(0, "ID");//(Идентификатор, строка загрузки)
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
  		static //Удаляем const, если используем mysql format
			fmt_str[] = "SELECT * FROM `referal` WHERE `Name` = '%s'";//Что-либо из БД аккаунты, по имени
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
	        SCM(playerid, ColorGreen, !"Попытки на ввод закончились. Введите (/q)uit чтобы выйти");
	        Tkick(playerid);
	        return true;
	    }

	    static const
		    fmt_str[] = "Вы ввели неверный пароль, осталось попыток: %d";
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
	SCM(playerid, ColorGreen, !"Время на авторизацию вышло. Введите (/q)uit чтобы выйти");
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
	    SCM(playerid, ColorGreen, !"Ваш реферал достиг 3-го уровня!");
	    static //Удаляем const, если используем mysql format
			fmt_str[] = "DELETE FROM `referal` WHERE `Name` = '%s' LIMIT 1";//Удаление из БД
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
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Стоки ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
stock DialogRegistration(playerid)
{
		static const//Тк используем форматирование
	    	fmt_str[] = "{FFFFFF}Здравствуй {008000}%s, {FFFFFF}приветствую на сервере {FFFF00}MerovRP\n\
						\n{FFFFFF}Не забудь посетить нашу группу во вконтакте {FF0000}www.vk.com\n\
		 				\n{FFFFFF}Придумай и введи свой пароль:";
		new
	    	string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//Отнимаем 2 из-за %s, +1 из-за нуля-терминатора

		format(string, sizeof(string), fmt_str, GN(playerid));
		SPD(playerid, 1, DIALOG_STYLE_INPUT, !"Регистрация",string,!"Далее",!"Выход");
		// ShowPlayerDialog(id игрока,id диалога, тип диалога, название диалога, сам текст диалога, левая клавиша, правая клавиша), если только одна кнопка,то вторую не писать
		//DIALOG_STYLE_PASSWORD - Засекреченный диалог
		//DIALOG_STYLE_MSGBOX - Информационный диалог
		//DIALOG_STYLE_INPUT - Стандартный диалог
		//DIALOG_STYLE_LIST - Список/Выбор
		//DIALOG_STYLE_TABLIST_HEADERS - Создание таблиц
		//\-перенос кавычки
}
stock DialogEmail(playerid)
{
SPD(playerid, 2, DIALOG_STYLE_INPUT,  !"Почта", !"{FFFFFF}Введите вашу почту: ", !"Далее", !"Назад");
}
stock DialogNation(playerid)
{
SPD(playerid, 3, DIALOG_STYLE_LIST, !"Национальность", !"Русский\nАмериканец\nЯпонец\nКитаец\nИтальянец", !"Выбрать", !"Назад");
}
stock DialogAge(playerid)
{
	SPD(playerid, 4, DIALOG_STYLE_INPUT,  !"Возраст", !"{FFFFFF}Введите ваш возраст (от 18 до 70 лет): ", !"Далее", !"Назад");
}
stock DialogReferal(playerid)
{
    SPD(playerid, 5, DIALOG_STYLE_INPUT,  !"Реферальная система", !"{FFFFFF}Укажите никнейм игрока, пригласившего вас: \nПри достижении 3-го уровня, вы получите 50.000$", !"Далее", !"Пропустить");
}
stock DialogSex(playerid)
{
    SPD(playerid, 6, DIALOG_STYLE_MSGBOX,  !"Выберите пол", !"{FFFFFF}Выберите пол: ", !"Мужчина", !"Женщина");
}
stock Clear(playerid)
{
	number_skin{playerid} = 0;
	number_pass{playerid} = 0;
	
	login_check{playerid} = false;
	report_check{playerid} = false;
	access_check{playerid} = false;
}
stock SetPlayerSpawn(playerid)//Функция спавне игрока
{
	Clist(playerid);//Установка цвета игрока при спавне со 100% прозрачностью (00)
	SetPlayerScore(playerid, player[playerid][plevel]);//Задание очков(уровня игрока)
	if(player[playerid][pmember] > 0)//Проверка на скин фрацкии, выдача скина в зависимости от наличия фракции
	{
	    SetPlayerSkin(playerid, player[playerid][pmodel]);
		switch(player[playerid][pmember])
		{
		    case 1:
		    {
     			SetPlayerPos(playerid, 254.1158, 77.7199, 1003.6406);//Кооры спавна LSPD
     			SetPlayerFacingAngle(playerid, 180.0);//Угол поворота
				SetPlayerInterior(playerid, 6);//Установка интерьера
			}
		}
		SetPlayerVirtualWorld(playerid, player[playerid][pmember]);//Помещение игрока в мир с id = 0
	    SetCameraBehindPlayer(playerid);//Установка камеры позади игрока
	    return true;
	}
	SetPlayerSkin(playerid, player[playerid][pskin]);
	SetPlayerPos(playerid, 2840.1497, 1303.2096, 11.3906);//Кооры спавна
	SetPlayerFacingAngle(playerid, 88.1048);//Угол поворота
	SetPlayerVirtualWorld(playerid, 0);//Помещение игрока в мир с id = 0
	SetPlayerInterior(playerid, 0);//Установка интерьера
	SetCameraBehindPlayer(playerid);//Установка камеры позади игрока
	return true;
}
stock KillTimers(playerid)
{
    KillTimer(update_timer[playerid]);
    KillTimer(login_timer[playerid]);
    KillTimer(report_timer[playerid]);
}
stock PlayerTextDraws(playerid)//Текстдровы
{
//Выбор скина
td_select_skin[playerid][0] = TextDrawCreate(475.200042, 309.120056, "LD_BEAT:right");
TextDrawLetterSize(td_select_skin[playerid][0], 0.000000, 0.000000);
TextDrawTextSize(td_select_skin[playerid][0], 85.599975, 39.813354);
TextDrawAlignment(td_select_skin[playerid][0], 2);//Заменяем второй параметр на 2, для выравнивания по центру
TextDrawColor(td_select_skin[playerid][0], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][0], 0);
TextDrawSetOutline(td_select_skin[playerid][0], 0);
TextDrawFont(td_select_skin[playerid][0], 4);
TextDrawSetSelectable(td_select_skin[playerid][0], true);

td_select_skin[playerid][1] = TextDrawCreate(89.800018, 307.133209, "LD_BEAT:left");
TextDrawLetterSize(td_select_skin[playerid][1], 0.000000, 0.000000);
TextDrawTextSize(td_select_skin[playerid][1], 85.599975, 39.813354);
TextDrawAlignment(td_select_skin[playerid][1], 2);//Заменяем второй параметр на 2, для выравнивания по центру
TextDrawColor(td_select_skin[playerid][1], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][1], 0);
TextDrawSetOutline(td_select_skin[playerid][1], 0);
TextDrawFont(td_select_skin[playerid][1], 4);
TextDrawSetSelectable(td_select_skin[playerid][1], true);

td_select_skin[playerid][2] = TextDrawCreate(320.200256, 321.813415, "SELECT");
TextDrawLetterSize(td_select_skin[playerid][2], 0.449999, 1.600000);
TextDrawTextSize(td_select_skin[playerid][2], 20, 70);
TextDrawAlignment(td_select_skin[playerid][2], 2);//Заменяем второй параметр на 2, для выравнивания по центру
TextDrawColor(td_select_skin[playerid][2], -1061109505);
TextDrawSetShadow(td_select_skin[playerid][2], 0);
TextDrawSetOutline(td_select_skin[playerid][2], 1);
TextDrawBackgroundColor(td_select_skin[playerid][2], 255);
TextDrawFont(td_select_skin[playerid][2], 2);
TextDrawSetProportional(td_select_skin[playerid][2], 2);//Между буквами
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
		static const//Тк используем форматирование
	    	fmt_str[] = "{FFFFFF}Здравствуй {008000}%s, {FFFFFF}приветствую на сервере {FFFF00}MerovRP\n\
						\n{FFFFFF}Ваш аккаунт уже зарегистрирован!\n\
		 				\n{FFFFFF}Пожалуйста, укажите свой пароль:";
		new
	    	string[sizeof(fmt_str)-2+MAX_PLAYER_NAME+1];//Отнимаем 2 из-за %s, +1 из-за нуля-терминатора

		format(string, sizeof(string), fmt_str, GN(playerid));
		SPD(playerid, 7, DIALOG_STYLE_PASSWORD, !"Авторизация",string,!"Далее",!"Выход");
}
stock CheckRussianText(string[], size = sizeof(string))
{
    for(new i; i < size; i++)
				switch(string[i])
				{
				    case 'А'..'Я', 'а'..'я':
					return true;
				}
	return false;
}
stock ShowPers(playerid)
{
	SPD(playerid, 9, DIALOG_STYLE_LIST, !"Персонаж","\
	{F5DEB3}Статистика\
	\n{F5DEB3}Навыки\
	\n{F5DEB3}Лицензии",!"Далее",!"Назад");
	return true;
}
stock ShowGPS(playerid)
{
    SPD(playerid, 10, DIALOG_STYLE_LIST, !"Навигация",!"\
	{F5DEB3}Трудоустройство\
	\n{F5DEB3}Доп. Заработок\
	\n{F5DEB3}Фракции\
	\n{F5DEB3}Магазины одежды\
	\n{F5DEB3}Аренда транспорта\
	\n{F5DEB3}Прочие важные места\
	\n{F5DEB3}Поиск дома по 'ID'\
	\n{F5DEB3}Свободные дома\
	\n{F5DEB3}Тюнинг авто\
	\n{F5DEB3}Ближайший отель\
	\n{F5DEB3}Ближайший тир\
	\n{F5DEB3}Аренда рекламных щитов\
	\n{F5DEB3}Ёлка\
	\n{FF80AB}Убрать отметку (/gps off)",!"Далее",!"Назад");
	return true;
}
stock ShowOnline(playerid)
{
    SPD(playerid, 11, DIALOG_STYLE_LIST, !"Игроки онлайн",!"\
	{F5DEB3}Хелперы Оналйн\
	\n{F5DEB3}Лидеры Онлайн\
	\n{F5DEB3}Адвокаты Онлайн\
	\n{F5DEB3}Детективы Онлайн\
	\n{F5DEB3}Участники Онлайн\
	\n{F5DEB3}Модераторы Онлайн\
	\n{F5DEB3}Репортёры Онлайн",!"Далее",!"Назад");
	return true;
}
stock ShowComm(playerid)
{
    SPD(playerid, 12, DIALOG_STYLE_LIST, !"Команды сервера",!"\
	{F5DEB3}Основные\
	\n{F5DEB3}Работа\
	\n{F5DEB3}Чат\
	\n{F5DEB3}Телефон\
	\n{F5DEB3}Дом/Отель\
	\n{F5DEB3}Бизнес\
	\n{F5DEB3}Транспорт\
	\n{F5DEB3}Рыбалка/Еда\
	\n{F5DEB3}Свадьбы\
	\n{F5DEB3}IRC\
	\n{F5DEB3}Лидерство\
	\n{F5DEB3}Анимации\
	\n{F5DEB3}Законники\
	\n{F5DEB3}Адвокаты\
	\n{F5DEB3}МЧС\
	\n{F5DEB3}Такси\
	\n{F5DEB3}Наёмные убийцы\
	\n{F5DEB3}Репортёры",!"Далее",!"Выход");
	return true;
}
stock ShowSet(playerid)
{
    SPD(playerid, 13, DIALOG_STYLE_LIST, !"Настройки",!"\
	{F5DEB3}Управление чатом\
	\n{F5DEB3}Смена пароля\
	\n{F5DEB3}Защита аккаунта",!"Далее",!"Назад");
	return true;
}
stock ShowMis(playerid)//Лишь наметка (переделать)
{
 	SPD(playerid, 14, DIALOG_STYLE_LIST, !"Ежедневные задания",!"\
	{F5DEB3}Подрывник\
	\n{F5DEB3}Водитель погрузчика\
	\n{F5DEB3}Донор",!"Далее",!"Назад");
	return true;
}
stock ShowStat(playerid, id)
{
    static const
	    	fmt_str[] = "{FFFFFF}ID аккаунта:\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}Имя игрока:\t\t\t{F5DEB3}%s\n\
						\n{FFFFFF}Дата регистрации:\t\t{F5DEB3}%s\n\
						\n{FFFFFF}Уровень:\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}EXP:\t\t\t\t{F5DEB3}%d/%d\n\
						\n{FFFFFF}Деньги:\t\t\t\t{F5DEB3}%d\n\
						\n{FFFFFF}Возраст:\t\t\t{F5DEB3}%d лет\n\
						\n{FFFFFF}Пол:\t\t\t\t{F5DEB3}%s\n\
		 				\n{FFFFFF}Национальность:\t\t{F5DEB3}%s";// \t-табуляция текста
	new
	    	string[sizeof(fmt_str)+MAX_PLAYER_NAME+35];//Отнимаем 2 из-за %s, +1 из-за нуля-терминатора

	format(string, sizeof(string), fmt_str, player[id][pid], GN(id), player[id][pdate_reg], player[id][plevel], player[id][pexp], player[id][pmaxexp],
 	player[id][pmoney], player[id][page], sex_info[player[id][psex] - 1], nations_info[player[id][pnations] - 1]);
	
    SPD(playerid, 15, DIALOG_STYLE_MSGBOX, !"Статистика",string,!"Выход",!"Назад");
	return true;
}
stock ShowSkills(playerid)
{
    SPD(playerid, 16, DIALOG_STYLE_LIST, !"Навыки",!"\
	",!"Далее",!"Назад");
	return true;
}
stock ShowLic(playerid)
{
    SPD(playerid, 17, DIALOG_STYLE_LIST, !"Лицензии",!"\
	",!"Далее",!"Назад");
	return true;
}
stock PayDay()
{
	gettime(hour_server, minute_server, second_server);
	SetWorldTime(hour_server);
	foreach(new i: Player)//forearch нужен для создания цикла для игроков
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
		    SCM(i, ColorGreen, !"Поздравляем! Вы получили новый уровень!");
		    SetPlayerScore(i, player[i][plevel]);
      		SavePlayer(i, "Level", player[i][plevel], "d");
      		SavePlayer(i, "Money", player[i][pmoney], "d");
		    //SavePlayer(i, "Level", player[i][plevel], "d");
		    if(player[i][plevel] == 3 && player[i][preferal_check] == 1)
		    {
		        static
   					fmt_str[] = "INSERT INTO `referal` (`Name`) VALUES ('%s')";// \t-табуляция текста
				new
					string[sizeof(fmt_str)+ MAX_PLAYER_NAME-1];
				mysql_format(connect_mysql, string, sizeof(string), fmt_str, player[i][preferal]);// Обновляем данные в таблице
				mysql_function_query(connect_mysql, string, false, "", "");
		        player[i][preferal_check] = 0;
		        SavePlayer(i, "Referal Check", player[i][preferal_check], "d");
			}
		}
		SCM(i, ColorOrange, !"==============================");
  		SavePlayer(i, "Exp", player[i][pexp], "d");
    	SavePlayer(i, "Maxexp", player[i][pmaxexp], "d");
		//SavePlayer(i, "Exp", player[i][pexp], "d");// Для проверки по форматам
	}
	return true;
}
stock SavePlayer(playerid, const field_name[], const set[], const type[])
{
	new
	    string[128+1];
	    
	if(!strcmp(type, "d", true))//Проверки по форматам
	    mysql_format(connect_mysql, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%d' WHERE `Name` = '%s' LIMIT 1", field_name, set, GN(playerid));// Обновляем данные в таблице
 	else if(!strcmp(type, "s", true))//Проверки по форматам
	    mysql_format(connect_mysql, string, sizeof(string), "UPDATE `accounts` SET `%s` = '%s' WHERE `Name` = '%s' LIMIT 1", field_name, set, GN(playerid));

    mysql_function_query(connect_mysql, string, false, "", "");
	return true;
}
stock SavePlayerExit(playerid)
{
    static
   		fmt_str[] = "UPDATE `accounts` SET `Money` = '%d', `Exp` = '%d', `Level` = '%d', `Maxexp` = '%d' WHERE `Name` = '%s' LIMIT 1";// \t-табуляция текста
	new
		string[sizeof(fmt_str)+ MAX_PLAYER_NAME + 13];
	mysql_format(connect_mysql, string, sizeof(string), fmt_str, player[playerid][pmoney], player[playerid][pexp], player[playerid][plevel], player[playerid][pmaxexp], GN(playerid));// Обновляем данные в таблице
	mysql_function_query(connect_mysql, string, false, "", "");
}
stock ComBase(playerid)
{
    SPD(playerid, 18, DIALOG_STYLE_MSGBOX, !"Команды",!"\
	{F5DEB3}/kpk - Открыть меню\
	\n{F5DEB3}/gps - Открыть навигатор\
	\n{F5DEB3}/report - Отправить сообщение админам\
	\n{F5DEB3}/donate - Покупки за донат валюту\
	\n{F5DEB3}/time - Узнать время",!"Назад",!"Выход");
	return true;
}
//Шаблон для стока
/*stock Имя(playerid, функции)
{
	return true;
}*/
stock DialogReport(playerid)
{
	SPD(playerid, 19, DIALOG_STYLE_INPUT, !"Репорт", !"{FFFFFF}Напишите свой вопрос/жалобу администрации:", !"Далее", !"Назад");
	return true;
}
stock AdmChat(color, str[])
{
	foreach(new i: connect_admins) SCM(i, color, str);// Перебераем лишь тех игроков, которые попали под данный итератор
	return true;
}
stock DialogDonateConv(playerid)
{
    static const
	    	fmt_str[] = "Донат рублей: {FFFF00}%d";
	new
	    	string[sizeof(fmt_str)+10];

	format(string, sizeof(string), fmt_str, player[playerid][pdonate]);
    SPD(playerid, 21, DIALOG_STYLE_INPUT, string, !"{FFFFFF}Конвертация по курсу: 1 руб = 10.000$, введите сумму:", !"Далее", !"Назад");
	return true;
}
stock DialogAdminRegistration(playerid)
{
    SPD(playerid, 22, DIALOG_STYLE_INPUT, !"Админ-регистрация", !"\
		{FFFFFF}Придумайте ваш админ-пароль:\
		\n{FFFFFF}Его вы будете использовать каждый раз при админ-авторизации!\
		\n{DF8600}Длина пароля от 6 до 20 символов.\
		\n", !"Далее", !"Назад");
	return true;
}
stock DialogAdminLogin(playerid)
{
    SPD(playerid, 23, DIALOG_STYLE_PASSWORD, !"Админ-авторизация", !"\
		{FFFFFF}Введите ваш админ-пароль:\
		\n", !"Далее", !"Назад");
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
	    case 0: SetPlayerColor(playerid, 0xFFFFFF00);//Установка цвета ника игрока
	    case 1..3: SetPlayerColor(playerid, 0x0100F6AA);//Установка цвета ника игрока (с диапозоном кейсов)
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
	lspd_pick[0] = CreateDynamicPickup(1318, 23, 1555.5059, -1675.7415, 16.1953); //(id pickup-а, тип pickup-а, кооры) Дверь на улице
	lspd_pick[1] = CreateDynamicPickup(1318, 23, 1568.6741, -1689.9702, 6.2188);//(id pickup-а, тип pickup-а, кооры) Дверь в гараже
	lspd_pick[2] = CreateDynamicPickup(1318, 23, 246.8043, 62.3237, 1003.6406, 1, 6);//(id pickup-а, тип pickup-а, кооры) Дверь в участке
	lspd_pick[3] = CreateDynamicPickup(1318, 23, 246.4056, 88.0078, 1003.6406, 1, 6);//(id pickup-а, тип pickup-а, кооры) Дверь из гаража
	lspd_pick[4] = CreateDynamicPickup(1318, 23, 1524.4835,-1677.8490,6.2188); // Дверь в оружейную
	lspd_pick[5] = CreateDynamicPickup(1318, 23, 316.3202,-170.2966,999.5938); // Дверь из оружейной
	lspd_pick[6] = CreateDynamicPickup(2061, 23, 312.1859,-168.7103,999.5938); // Боеприпасы
}
stock Cars()//Сток со спавном транспорта
{
    lspd_car[0] = AddStaticVehicleEx(596, 1602.4960, -1683.9705, 5.6106, 89.9966, 0, 1, 600);//Спавн транспорта (id транспорта, кооры, угол поворота, цвета, время респавна)
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
    SPD(playerid, 26, DIALOG_STYLE_TABLIST_HEADERS, "Оружейный склад",
	!"\
		{FFFFFF}Имя:\t{FFFFFF}Патроны:\
		\n1) Deagle\t\t35\
		\n2) ShotGun\t\t20\
		\n3) MP5\t\t60\
		\n4) Сухпаёк\
		\n5) Бронежилет", "Выбрать", "Отмена\
	");
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Команды сервера ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cmd:menu(playerid)//cmd:имя команды(playerid, params[])
{
    SPD(playerid, 8, DIALOG_STYLE_LIST, !"КПК",!"\
	{F5DEB3}Персонаж\
	\n{F5DEB3}Навигация\
	\n{F5DEB3}Игроки онлайн\
	\n{F5DEB3}Команды сервера\
	\n{F5DEB3}Настройки\
	\n{F5DEB3}Ежедневные задания",!"Далее",!"Выход");
	return true;
}
alias:menu("mm", "mn", "kpk");//alias:команда(альтернативные команды);
cmd:time(playerid)
{
    new
		string[84];
    gettime(hour_server, minute_server, second_server);
    format(string, sizeof(string), "{008000}Время на сервере: %d часов %d минут %d секунд", hour_server, minute_server, second_server);
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
    SPD(playerid, 20, DIALOG_STYLE_LIST, !"Донат-магазин",!"\
	{F5DEB3}Игровая валюта\
	\n{F5DEB3}Выбрать\
	\n{F5DEB3}Выбрать",!"Выбрать",!"Выход");
	return true;
}
alias:donate("donat", "don");
cmd:kick(playerid, params[])
{
	if(player[playerid][padmin] < 1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);
    if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
	if(sscanf(params, "ds[144]", params[0], params[1]))//"ds" - спецификаторы, params[0] - ID, params[1] - Причина([144] - размер)
		return SCM(playerid, ColorGreen, !"Введите команду /kick [ID] [Причина]");
	if(!IsPlayerConnected(params[0]))
	    return SCM(playerid, ColorRed, !"Игрок не найден!");
	if(login_check{params[0]} == false)
		return SCM(playerid, ColorRed, !"Игрок не авторизован!");
	if(player[params[0]][padmin] >= player[playerid][padmin])
	    return SCM(playerid, ColorRed, !"Введенный игрок выше вас или равен вам по уровню администрирования!");
	static const
	    	fmt_str[] = "Администратор %s кикнул игрока %s. Причина: %s";
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
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    DialogAdminRegistration(playerid);
	if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);
	return true;
}
cmd:ahelp(playerid)
{
    if(player[playerid][padmin] < 1)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	    
	SPD(playerid, 24, DIALOG_STYLE_LIST, !"Админ-команды", !"\
		{DF8600}Введите уровень админки:\
		{FFFFFF}1 уровень\
		{FFFFFF}2 уровень\
		{FFFFFF}3 уровень\
		{FFFFFF}4 уровень\
		{FFFFFF}5 уровень\
		{FFFFFF}6 уровень\
		{FFFFFF}7 уровень\
		{FFFFFF}8 уровень\
		\n", !"Выбрать", !"Отмена");
	return true;
}
cmd:makeleader(playerid, params[])
{
    if(player[playerid][padmin] < 6)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
    if(sscanf(params, "dd", params[0], params[1]))
		return SCM(playerid, ColorGreen, !"Введите команду /makeleader [ID] [ID фракции (0 - 1)]");//Временно
		//return SCM(playerid, ColorGreen, strcat(!"Введите команду /makeleader [ID] [ID фракции (0 - ", MAX_LEADER));
	if(!IsPlayerConnected(params[0]))
	    return SCM(playerid, ColorRed, !"Игрок не найден!");
	if(login_check{params[0]} == false)
		return SCM(playerid, ColorRed, !"Игрок не авторизован!");
	if(!(0 <= params[1] <= MAX_LEADER_NUM))
	    return SCM(playerid, ColorGreen, !"Фракции с данным ID не существует!");
	if(params[1] == 0)
	{
	    if(player[params[0]][pmember] == 0)
	        return SCM(playerid, ColorGreen, !"Игрок не состоит во фракции!");
	        
		player[params[0]][pmember] = 0;
		player[params[0]][prank] = 0;
		SavePlayer(params[0], "Member", player[params[0]][pmember], "d");
		SavePlayer(params[0], "Rank", player[params[0]][prank], "d");
		ClearKillFeed(params[0]);
		ResetPlayerWeapons(params[0]);//Обнуление оружия игроков
		SetPlayerArmour(params[0], 0.0);//Установка уровня брони
		SetPlayerHealth(params[0], 100.0);//Установка уровня здоровья
		SetPlayerSkin(params[0], player[params[0]][pskin]);
		Clist(params[0]);
		static const
			fmt_str[] = "Вы сняли %s[%d] с лидерки",
		    fmt_str_2[] = "Администратор %s[%d] снял вас с лидерки";
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
		fmt_str[] = "Вы назначили %s[%d] на лидерку %s",
	    fmt_str_2[] = "Администратор %s[%d] назначил %s[%d] на лидерку %s";
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
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	if(sscanf(params, "ddd", params[0], params[1], params[2]))
		return SCM(playerid, ColorGreen, !"Введите команду /veh [ID транспорта] [ID первого цвета] [ID второго цвета]");
	if(!(400 <= params[0] <= 611))
		return SCM(playerid, ColorGreen, !"Неверный id транспорта [400 - 611]");
	if(params[1] < 0 || params[1] > 255 || params[2] < 0 || params[2] > 255)
		return SCM(playerid, ColorGreen, !"Неверный id цвета");
	
	new
	    currentveh,
	    Float: X,
		Float: Y,
		Float: Z,
		Float: Angle; //АХТУНГ, Float в pawn должен быть с большой буквы
		
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, X, Y, Z);
	currentveh = CreateVehicle(params[0], X + 3.0, Y, Z + 1.0, Angle, params[1], params[2], 99999);//Создание транспорта(В конце - цвета и время спавна)
	SetVehicleNumberPlate(currentveh, "Admin");
	static const
			fmt_str[] = "Вы создали транспорт - {FFFF00}%s";
	new
		    string[sizeof(fmt_str) + 40];

	format(string, sizeof(string), fmt_str, GetVehicleName(params[0]));
	SCM(playerid, ColorGreen, string);
	return true;
}
cmd:destroyveh(playerid)
{
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	new
		currentveh;
	currentveh = GetPlayerVehicleID(playerid);
	DestroyVehicle(currentveh);
	return true;
}
alias:destroyveh("remove", "remveh", "delveh");
cmd:elegyveh(playerid)
{
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
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
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
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
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
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
    SetVehicleNumberPlate(flashveh, "Admin");//(id транспорта, надпись)
	return true;
}
cmd:vehid(playerid)
{
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	new
		currentveh,
		vehmodel;

	currentveh = GetPlayerVehicleID(playerid);
	vehmodel = GetVehicleModel(currentveh);
	static const
		fmt_str[] = "Данный транспорт имеет id: {FFFF00}%d {008000}, модель транспорта: {FFFF00}%s[%d]";
	new
 		string[sizeof(fmt_str) + 30];

	format(string, sizeof(string), fmt_str, currentveh, GetVehicleName(vehmodel) ,vehmodel);
	SCM(playerid, ColorGreen, string);
	return true;
}
cmd:changenumberplate(playerid, params[]) //Доделать
{
    if(player[playerid][padmin] < 3)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	if(sscanf(params, "s", params[0]))
		return SCM(playerid, ColorGreen, !"Введите команду /changenumberplate [Номерной знак]");
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
    if(player[playerid][padmin] < 1)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	SetPlayerSpawn(playerid);
	return true;
}
CMD:test(playerid)// Тест команда
{
    if(player[playerid][padmin] < 7)//Вставить в каждую админ-команду (1)
	    return SCM(playerid, ColorRed, !"Вы не уполномочены использовать данную команду!");
	if(player[playerid][pakeys] == 0)
	    return SCM(playerid, ColorGreen, !"Введите команду /alogin!");
    if(access_check{playerid} == false)
	    return DialogAdminLogin(playerid);//Вставить в каждую админ-команду (2)
	SetPlayerPos(playerid, 316.524993,-167.706985,999.593750);
	SetPlayerInterior(playerid, 6);
	return true;
}
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ [ Остальное ] ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
main()
{
	print("\n---------------------------------------");
	print("=== [This mode was made by rialbat] ===");
	print(GM_NAME);
	print("=== [vk.com] ===");
	print("---------------------------------------\n");
	print("\n");
}
