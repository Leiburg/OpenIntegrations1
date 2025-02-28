#Использовать osparser

Перем ФайлСоставаОПИ;
Перем КаталогСписковСотава;
Перем МодульСоставаОПИ;
Перем СоответствиеМодулейКоманд;
Перем ТекущийМодуль;
Перем ТаблицаОписанийПараметров;
Перем ОбщийМассивМодулей;
Перем ТекущийФайлСостава;

Процедура ПриСозданииОбъекта()
    
    МодульСоставаОПИ     = Новый ТекстовыйДокумент();
    ФайлСоставаОПИ       = "./cli/data/Classes/СоставБиблиотеки.os";
    КаталогСписковСотава = "./cli/data/Classes/internal/Classes/";

    ЗаписатьНачалоФайла();
    ЗаписатьФункциюОпределенияВерсии();
    ЗаписатьФункциюОпределенияКоманд();
    ЗаписатьВспомогательныеФункции();
    МодульСоставаОПИ.Записать(ФайлСоставаОПИ);

    ЗаполнитьТаблицыСостава();

КонецПроцедуры

Процедура ЗаписатьНачалоФайла()
    
    МодульСоставаОПИ.ДобавитьСтроку("#Использовать ""./internal""");
    МодульСоставаОПИ.ДобавитьСтроку("");
    
КонецПроцедуры

Процедура ЗаписатьФункциюОпределенияВерсии()

    Версия = ПолучитьВерсиюПакета();
    МодульСоставаОПИ.ДобавитьСтроку("Функция ПолучитьВерсию() Экспорт");
    МодульСоставаОПИ.ДобавитьСтроку("  Возврат """ + Версия + """;");
    МодульСоставаОПИ.ДобавитьСтроку("КонецФункции");
    МодульСоставаОПИ.ДобавитьСтроку("");

КонецПроцедуры

Процедура ЗаписатьФункциюОпределенияКоманд()

    МодульСоставаОПИ.ДобавитьСтроку("Функция ПолучитьСоответствиеКомандМодулей() Экспорт");
    МодульСоставаОПИ.ДобавитьСтроку("СоответствиеКомандМодулей  = Новый Соответствие();");

    ОпределитьСоответствиеМодулейКоманд();
    
    Для Каждого КомандаМодуля Из СоответствиеМодулейКоманд Цикл
        МодульСоставаОПИ.ДобавитьСтроку("СоответствиеКомандМодулей.Вставить("""
            + КомандаМодуля.Значение
            + """, """
            + КомандаМодуля.Ключ
            + """);");
    КонецЦикла;

    МодульСоставаОПИ.ДобавитьСтроку("Возврат СоответствиеКомандМодулей;");
    МодульСоставаОПИ.ДобавитьСтроку("КонецФункции");
    МодульСоставаОПИ.ДобавитьСтроку("");

КонецПроцедуры

Процедура ЗаписатьВспомогательныеФункции()

    МодульСоставаОПИ.ДобавитьСтроку("
    |
    |Функция ПолучитьСостав(Знач Команда) Экспорт
    |    ТекущийСостав = Новый(Команда);
    |    Возврат ТекущийСостав.ПолучитьСостав();
    |КонецФункции
    |
    |Функция ПолучитьПолныйСостав() Экспорт
    |
    |    ОбщаяТаблица = Неопределено;
    |
    |    Для Каждого Команда Из ПолучитьСоответствиеКомандМодулей() Цикл
    |
    |        ТекущаяТаблица = ПолучитьСостав(Команда.Ключ);
    |        
    |        Если ОбщаяТаблица = Неопределено Тогда
    |            ОбщаяТаблица = ТекущаяТаблица;
    |        Иначе
    |            Для Каждого СтрокаТаблицы Из ТекущаяТаблица Цикл
    |                ЗаполнитьЗначенияСвойств(ОбщаяТаблица.Добавить(), СтрокаТаблицы);
    |            КонецЦикла;
    |        КонецЕсли;
    |
    |    КонецЦикла;
    |
    |    Возврат ОбщаяТаблица;
    |
    |КонецФункции
    |");
    
КонецПроцедуры

Процедура ЗаполнитьТаблицыСостава()
    
    Для Каждого Модуль Из ОбщийМассивМодулей Цикл

        ТекущийМодуль = Модуль.ИмяБезРасширения;

        Если Не СоответствиеМодулейКоманд[ТекущийМодуль] = Неопределено Тогда    
            РазобратьМодуль(Модуль);
        КонецЕсли;
	  
    КонецЦикла;

КонецПроцедуры

Процедура РазобратьМодуль(Модуль)
    
    ЗаписатьНачалоСоставаБиблиотеки();

    Парсер         = Новый ПарсерВстроенногоЯзыка;
	ДокументМодуля = Новый ТекстовыйДокумент;
	ДокументМодуля.Прочитать(Модуль.ПолноеИмя);
	ТекстМодуля = ДокументМодуля.ПолучитьТекст();

	СтруктураМодуля = Парсер.Разобрать(ТекстМодуля);
    ТекущаяОбласть  = "Основные методы";
	Для Каждого Метод Из СтруктураМодуля.Объявления Цикл

        Если Метод.Тип = "ИнструкцияПрепроцессораОбласть" Тогда
            ТекущаяОбласть = Синонимайзер(Метод.Имя);
        КонецЕсли;

		Если Метод.Тип = "ОбъявлениеМетода" И Метод.Сигнатура.Экспорт = Истина Тогда
            ТаблицаОписанийПараметров.Очистить();
			РазобратьКомментарийМетода(ДокументМодуля, Метод, Модуль, ТекущаяОбласть);	

		КонецЕсли;

	КонецЦикла;

    Команда = СоответствиеМодулейКоманд[Модуль.ИмяБезРасширения];
    ЗаписатьОкончаниеСоставаБиблиотеки(Команда);

КонецПроцедуры

Процедура ЗаписатьНачалоСоставаБиблиотеки()
    
    ТекущийФайлСостава = Новый ТекстовыйДокумент();

    ТекущийФайлСостава.ДобавитьСтроку("Функция ПолучитьСостав() Экспорт
    |
    |    ТаблицаСостава = Новый ТаблицаЗначений();
    |    ТаблицаСостава.Колонки.Добавить(""Библиотека"");
    |    ТаблицаСостава.Колонки.Добавить(""Модуль"");
    |    ТаблицаСостава.Колонки.Добавить(""Метод"");
    |    ТаблицаСостава.Колонки.Добавить(""МетодПоиска"");
    |    ТаблицаСостава.Колонки.Добавить(""Параметр"");
    |    ТаблицаСостава.Колонки.Добавить(""Описание"");
    |    ТаблицаСостава.Колонки.Добавить(""ОписаниеМетода"");
    |    ТаблицаСостава.Колонки.Добавить(""Область"");
    |");

	ТаблицаОписанийПараметров = Новый ТаблицаЗначений;
	ТаблицаОписанийПараметров.Колонки.Добавить("Имя");
	ТаблицаОписанийПараметров.Колонки.Добавить("Типы");
	ТаблицаОписанийПараметров.Колонки.Добавить("Описание");
	ТаблицаОписанийПараметров.Колонки.Добавить("ЗначениеПоУмолчанию");

КонецПроцедуры

Процедура ЗаписатьОкончаниеСоставаБиблиотеки(Библиотека)
 
    ТекущийФайлСостава.ДобавитьСтроку("    Возврат ТаблицаСостава;");
    ТекущийФайлСостава.ДобавитьСтроку("КонецФункции");
    ТекущийФайлСостава.ДобавитьСтроку(Символы.ПС);

    ТекущийФайлСостава.Записать(КаталогСписковСотава + Библиотека + ".os");

КонецПроцедуры

Процедура РазобратьКомментарийМетода(ТекстовыйДокумент, Метод, Модуль, Область)

	НомерСтроки         = Метод.Начало.НомерСтроки;
	ИмяМетода           = Метод.Сигнатура.Имя;
	
	МассивКомментария = ПарсингКомментария(ТекстовыйДокумент, НомерСтроки);

	Если МассивКомментария.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	МассивПараметров  = Новый Массив;
	ОписаниеМетода    = "";

	СформироватьСтруктуруМетода(МассивКомментария, МассивПараметров, ОписаниеМетода);
	СформироватьТаблицуОписанийПараметров(МассивПараметров, Метод);

	ДопОписание = "";
    ОпределитьДопОписание(ДопОписание, Модуль);

    ОписаниеМетода = СокрЛП(ОписаниеМетода) + ДопОписание;
    
    Для Каждого СтрокаПараметра Из ТаблицаОписанийПараметров Цикл

        ЗаписатьСозданиеПараметраСостава(СтрокаПараметра, ИмяМетода, Область, СокрЛП(ОписаниеМетода));
        ОписаниеМетода = "";

    КонецЦикла;

КонецПроцедуры

Функция ПарсингКомментария(Знач ТекстовыйДокумент, Знач НомерСтроки)

	ТекущаяСтрока       = ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки - 1);
	ТекстКомментария    = ТекущаяСтрока;
	
	Счетчик	= 1;
	Пока СтрНайти(ТекущаяСтрока, "//") > 0 Цикл

		Счетчик = Счетчик + 1;

		ТекущаяСтрока    = ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки - Счетчик);
		ТекстКомментария = ТекущаяСтрока + Символы.ПС + ТекстКомментария;

	КонецЦикла;

    Если СтрНайти(ТекстКомментария, "!NOCLI") > 0 Тогда
        Возврат Новый Массив;
    КонецЕсли;

    МассивКомментария = СтрРазделить(ТекстКомментария, "//", Ложь);

    Если МассивКомментария.Количество() = 0 Тогда
        Сообщить(ТекстКомментария);
		Возврат Новый Массив;
    Иначе
        МассивКомментария.Удалить(0);
    КонецЕсли;

    Возврат МассивКомментария;

КонецФункции

Процедура СформироватьСтруктуруМетода(Знач МассивКомментария, МассивПараметров, ОписаниеМетода)

	ЗаписыватьПараметры = Ложь;
    ЗаписыватьОписание  = Истина;

	Счетчик = 0;
	Для Каждого СтрокаКомментария Из МассивКомментария Цикл

        Счетчик = Счетчик + 1;

        Если Не ЗначениеЗаполнено(СокрЛП(СтрокаКомментария)) Тогда
            ЗаписыватьОписание = Ложь;
        КонецЕсли;
            
        Если ЗаписыватьОписание = Истина И Счетчик > 1 Тогда
            ОписаниеМетода = ?(ЗначениеЗаполнено(ОписаниеМетода), ОписаниеМетода + "    |   ", ОписаниеМетода) 
                + СтрокаКомментария;
        КонецЕсли;

        Если СтрНайти(СтрокаКомментария, "Параметры:") > 0 Тогда
            ЗаписыватьПараметры = Истина;
            ЗаписыватьОписание  = Ложь;

        ИначеЕсли СтрНайти(СтрокаКомментария, "Возвращаемое значение:") > 0 Тогда
            Прервать;

        ИначеЕсли ЗаписыватьПараметры = Истина 
            И ЗначениеЗаполнено(СокрЛП(СтрокаКомментария)) 
            И Не СтрНачинаетсяС(СокрЛП(СтрокаКомментария), "*") = 0 Тогда
            
            МассивПараметров.Добавить(СтрокаКомментария);

        Иначе
            Продолжить;
        КонецЕсли;

    КонецЦикла;

КонецПроцедуры

Процедура СформироватьТаблицуОписанийПараметров(Знач МассивПараметров, Знач Метод)

	Разделитель = "-";

	Для Каждого ПараметрМетода Из МассивПараметров Цикл

		МассивЭлементовПараметра = СтрРазделить(ПараметрМетода, Разделитель, Ложь);
		КоличествоЭлементов      = МассивЭлементовПараметра.Количество();
	
		Для Н = 0 По МассивЭлементовПараметра.ВГраница() Цикл
			МассивЭлементовПараметра[Н] = СокрЛП(МассивЭлементовПараметра[Н]);
		КонецЦикла;
	
		Если КоличествоЭлементов < 4 Тогда
			Возврат;
		КонецЕсли;
	
        Имя1С     = МассивЭлементовПараметра[0];
		Имя       = "--" + МассивЭлементовПараметра[3];
		Типы      = МассивЭлементовПараметра[1];
		Описание  = ?(КоличествоЭлементов >= 5, МассивЭлементовПараметра[4], МассивЭлементовПараметра[2]);
        
		НоваяСтрокаТаблицы = ТаблицаОписанийПараметров.Добавить();
		НоваяСтрокаТаблицы.Имя      = Имя;
		НоваяСтрокаТаблицы.Типы     = Типы;
		НоваяСтрокаТаблицы.Описание = Описание;
        
        НоваяСтрокаТаблицы.ЗначениеПоУмолчанию = ПолучитьЗначениеПараметраПоУмолчанию(Имя1С, Метод);
    КонецЦикла;

КонецПроцедуры

Функция ПолучитьЗначениеПараметраПоУмолчанию(Знач Имя, Знач Метод)

    Значение = "";

    Для Каждого ПараметрМетода Из Метод.Сигнатура.Параметры Цикл

        Если ПараметрМетода.Имя = Имя Тогда

            ЗначениеПараметра = ПараметрМетода.Значение;
            Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
                Попытка
                    Значение = ЗначениеПараметра["Элементы"][0]["Значение"];
                Исключение 
                    Значение = ЗначениеПараметра.Значение;
                КонецПопытки;
                Значение = ?(ЗначениеЗаполнено(Значение), Значение, "Пустое значение");
            КонецЕсли;

        КонецЕсли;

    КонецЦикла;

    Возврат Значение;

КонецФункции

Процедура ОпределитьДопОписание(ДопОписание, Модуль)

    ЕстьМассив       = Ложь;
    ЕстьДата         = Ложь;
    ТекстДополнения  = "";
	ИмяМодуля        = Модуль.ИмяБезРасширения;

    ДЛя Каждого СтрокаПараметра Из ТаблицаОписанийПараметров Цикл
        
		Типы = СтрокаПараметра["Типы"];
		Имя  = СтрокаПараметра["Имя"];

        Если СтрНайти(Типы, "Массив") > 0 Тогда
            ЕстьМассив = Истина;
        КонецЕсли;

        Если СтрНайти(Типы, "Дата") > 0 Тогда
            ЕстьДата = Истина;
        КонецЕсли;

		ОпределитьДопОписаниеПоПараметру(ТекстДополнения, ИмяМодуля, Имя)

    КонецЦикла;

    Если ЕстьМассив Тогда
        ТекстДополнения =  
            "
            |
            |    Пример указания параметра типа массив:
            |    --param ""['Val1','Val2','Val3']""
            |" + ТекстДополнения;

    КонецЕсли;

    Если ЕстьДата Тогда
        ТекстДополнения =  
            "
            |
            |    Дата указывается в формате ISO 8601:
            |    ""2024-04-07""
            |    ""2024-04-07T13:34:42+00:00"" 
            |    ""2024-04-07T13:34:42Z""
            |" + ТекстДополнения;
    КонецЕсли;

    ТекстДополнения = СтрЗаменить(ТекстДополнения, Символы.ПС, Символы.ПС + "    |");
    ДопОписание     = ДопОписание +  СтрЗаменить(ТекстДополнения, """", """""");

КонецПроцедуры

Процедура ОпределитьДопОписаниеПоПараметру(ТекстДополнения, ИмяМодуля, ИмяПараметра)

	Если ИмяМодуля = "OPI_VK" Тогда
		Если ИмяПараметра = "--auth" Тогда
			ТекстДополнения = ТекстДополнения + "
				|
				|    Структура JSON данных авторизации (параметр --auth):
				|    {
				|     ""access_token"": """",
				|     ""owner_id""    : """",   
				|     ""app_id""      : """",  
				|     ""group_id""    : """"  
				|    }
				|";
        ИначеЕсли ИмяПараметра = "--product" Тогда
            ТекстДополнения = ТекстДополнения + "
                |
                |    Структура JSON данных описания товара (параметр --product):
                |    {
                |     ""Имя""                : ""Новый товар"",
                |     ""Описание""           : ""Описание товара"",
                |     ""Категория""          : ""20173"",
                |     ""Цена""               : 1,
                |     ""СтараяЦена""         : """",
                |     ""ОсновноеФото""       : """",
                |     ""URL""                : """",
                |     ""ДополнительныеФото"" : [],
                |     ""ЗначенияСвойств""    : [],
                |     ""ГлавныйВГруппе""     : ""Ложь"",
                |     ""Ширина""             : """",
                |     ""Высота""             : """",
                |     ""Глубина""            : """",
                |     ""Вес""                : """",
                |     ""SKU""                : """",
                |     ""ДоступныйОстаток""   : ""1""
                |    }
                |";
		КонецЕсли;
	КонецЕсли;

	Если ИмяМодуля = "OPI_Telegram" Тогда
		Если ИмяПараметра = "--media" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных медиагруппы (параметр --media):
			|    {
			|     ""ПутьКФайлу"": ""ТипМедиа"",
			|     ""ПутьКФайлу"": ""ТипМедиа"",
			|     ...
			|    }
			|";
		КонецЕсли;
	КонецЕсли;

    Если ИмяМодуля = "OPI_Twitter" Тогда
		Если ИмяПараметра = "--auth" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных авторизации (параметр --auth):
            |    {
            |     ""redirect_uri""            : """",  
            |     ""client_id""               : """",  
            |     ""client_secret""           : """",  
            |     ""access_token""            : """",  
            |     ""refresh_token""           : """",  
            |     ""oauth_token""             : """",  
            |     ""oauth_token_secret""      : """",  
            |     ""oauth_consumer_key""      : """", 
            |     ""oauth_consumer_secret""   : """"  
            |    }
			|";
		КонецЕсли;
	КонецЕсли;

    Если ИмяМодуля = "OPI_Notion" Тогда
		Если ИмяПараметра = "--data" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных страницы (параметр --data):
            |    {
            |     ""Имя поля БД 1""  : ""Значение1"",
            |     ""Имя поля БД 2""  : ""Значение2"",
            |     ...
            |    }
			|";
        ИначеЕсли ИмяПараметра = "--props" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON полей базы (параметр --props):
            |    {
            |     ""Имя поля БД c обычным типом""     : ""Тип данных 1"",
            |     ""Имя поля БД с выбором значения""  : 
            |        {
            |         ""Вариант1""  : ""green"",
            |         ""Вариант2""  : ""red"",
            |         ...
            |        },
            |     ...
            |    }
            |    
            |    Доуступные типы: title(ключевой), rich_text, number, status,
            |    date, files, checkbox, url, email, phone_number, people
			|";
		КонецЕсли;
	КонецЕсли;

    Если ИмяМодуля = "OPI_GoogleCalendar" Тогда
        Если ИмяПараметра = "--props" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных события (параметр --props):
            |    {
            |     ""Описание""                : """", 
            |     ""Заголовок""               : """", 
            |     ""МестоПроведения""         : """", 
            |     ""ДатаНачала""              : """",
            |     ""ДатаОкончания""           : """",      
            |     ""МассивURLФайловВложений"" :           
            |         {
            |          ""НазваниеФайла1"" : ""URLФайла1"",
            |          ""НазваниеФайла2"" : ""URLФайла2"",
            |          ...
            |         },
            |     ""ОтправлятьУведомления""   : true       
            |    }
			|";
        КонецЕсли;
    КонецЕсли;

    Если ИмяМодуля = "OPI_GoogleDrive" Тогда
        Если ИмяПараметра = "--props" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных объекта (параметр --props):
            |    {
            |     ""MIME""        : ""image/jpeg"",
            |     ""Имя""         : ""Новый файл.jpg"",
            |     ""Описание""    : ""Это новый файл"",
            |     ""Родитель""    : ""root""
            |    }
			|";
        КонецЕсли;
    КонецЕсли;

    Если ИмяМодуля = "OPI_GoogleSheets" Тогда
        Если ИмяПараметра = "--data" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных ячеек (параметр --data):
            |    {
            |     ""A1"": ""Это данные ячейки A1"",
            |     ""B2"": ""Это данные ячейки B2"",
            |     ...
            |    }
			|";
        КонецЕсли;
    КонецЕсли;

    Если ИмяМодуля = "OPI_Airtable" Тогда

        ФункцииПолей = "Функции формирования описаний полей: "
            + "ПолучитьПолеСтроковое, "
            + "ПолучитьПолеНомера, "
            + "ПолучитьПолеВложения, "
            + "ПолучитьПолеФлажка, "
            + "ПолучитьПолеДаты, "
            + "ПолучитьПолеПочты, "
            + "ПолучитьПолеТелефона, "
            + "ПолучитьПолеСсылки";

        Если ИмяПараметра = "--fielddata" Тогда
            ТекстДополнения = ТекстДополнения + Символы.ПС + ФункцииПолей + Символы.ПС;
        КонецЕсли;

        Если ИмяПараметра = "--fieldsdata" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных массива полей (параметр --fieldsdata):
            |    [
            |        {
            |          <Данные описание поля 1>
            |        },
            |        {
            |          <Данные описание поля 2>
            |        },
            |    ]
			|";

            ТекстДополнения = ТекстДополнения + Символы.ПС + ФункцииПолей + Символы.ПС;

        КонецЕсли;

        Если ИмяПараметра = "--tablesdata" Тогда
			ТекстДополнения = ТекстДополнения + "
			|
			|    Структура JSON данных описания таблиц (параметр --tablesdata):
            |  {
            |    ""Имя таблицы 1"": [
            |                         {
            |                          <Данные описание поля 1>
            |                         },
            |                         {
            |                          <Данные описание поля 2>
            |                        },
            |                       ],
            |   ...
            |  }
			|";

            ТекстДополнения = ТекстДополнения + Символы.ПС + ФункцииПолей + Символы.ПС;

        КонецЕсли;

    КонецЕсли;
КонецПроцедуры

Процедура ЗаписатьСозданиеПараметраСостава(СтрокаПараметра, ИмяМетода, Область, ОписаниеМетода = "") 

	Имя        = СтрокаПараметра["Имя"];
	Описание   = СтрокаПараметра["Описание"];
	Значение   = СтрокаПараметра["ЗначениеПоУмолчанию"];
    Библиотека = СоответствиеМодулейКоманд.Получить(ТекущийМодуль);

	Если ЗначениеЗаполнено(Значение) Тогда
        Описание = Описание + " (необяз. по ум. - " + Значение + ")";
	КонецЕсли;

    ТекущийФайлСостава.ДобавитьСтроку(Символы.ПС);

    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока = ТаблицаСостава.Добавить();");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Библиотека  = """ + Библиотека + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Модуль      = """ + ТекущийМодуль + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Метод       = """ + ИмяМетода + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.МетодПоиска = """ + вРег(ИмяМетода) + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Параметр    = """ + Имя + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Описание    = """ + Описание + """;");
    ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.Область     = """ + Область + """;");

    Если ЗначениеЗаполнено(ОписаниеМетода) Тогда
        ТекущийФайлСостава.ДобавитьСтроку("    НоваяСтрока.ОписаниеМетода   = """ + ОписаниеМетода + """;");
    КонецЕсли;

    ТекущийФайлСостава.ДобавитьСтроку(Символы.ПС);
    
КонецПроцедуры

Процедура ОпределитьСоответствиеМодулейКоманд()

    СоответствиеМодулейКоманд  = Новый Соответствие();

    ОбщийМассивМодулей = Новый Массив;

    ФайлыМодулей = НайтиФайлы("./", "*.os", Истина);

    Для Каждого Модуль Из ФайлыМодулей Цикл
        
        КомандаCLI = ОпределитьКомандуCLI(Модуль.ПолноеИмя);

        Если Не ЗначениеЗаполнено(КомандаCLI) Тогда
            Продолжить;
        КонецЕсли;

        СоответствиеМодулейКоманд.Вставить(Модуль.ИмяБезРасширения, КомандаCLI);
        ОбщийМассивМодулей.Добавить(Модуль);
        
    КонецЦикла;

КонецПроцедуры

Функция ОпределитьКомандуCLI(Знач ПутьКМодулю)

    КомандаCLI     = "";
    ДокументМодуля = Новый ТекстовыйДокумент();
    Признак        = "// Команда CLI: ";
    ДокументМодуля.Прочитать(ПутьКМодулю);

    Для Н = 1 По ДокументМодуля.КоличествоСтрок() Цикл

      ТекущаяСтрока = СокрЛП(ДокументМодуля.ПолучитьСтроку(Н));

      Если Не ЗначениеЗаполнено(ТекущаяСтрока) Тогда
        Прервать;
      КонецЕсли;

      Если СтрНачинаетсяС(ТекущаяСтрока, Признак) Тогда
        КомандаCLI = СтрЗаменить(ТекущаяСтрока, Признак, "");
        КомандаCLI = СокрЛП(КомандаCLI);
        Прервать;
      КонецЕсли;

    КонецЦикла;

    Возврат КомандаCLI;

КонецФункции

Функция ПолучитьВерсиюПакета()

    Версия     = "";
    Packagedef = "./OInt/packagedef";
    Признак    = ".Версия(""";

    ТекстФайла = Новый ТекстовыйДокумент();
    ТекстФайла.Прочитать(Packagedef);

    Для Н = 1 По ТекстФайла.КоличествоСтрок() Цикл

        ТекущаяСтрока = СокрЛП(ТекстФайла.ПолучитьСтроку(Н));
        Если СтрНайти(ТекущаяСтрока, Признак) Тогда
            Версия = СтрЗаменить(ТекущаяСтрока, Признак, "");
            Версия = Лев(Версия, СтрДлина(Версия) - 2);
            Прервать;
        КонецЕсли;    
    КонецЦикла;

    Возврат Версия;

КонецФункции

Функция Синонимайзер(ИмяРеквизита)
    
    Перем Синоним, ъ, Символ, ПредСимвол, СледСимвол, Прописная, ПредПрописная, СледПрописная, ДлинаСтроки;
    
    Синоним = ВРег(Сред(ИмяРеквизита, 1, 1));
    ДлинаСтроки = СтрДлина(ИмяРеквизита);
    Для ъ=2 По ДлинаСтроки Цикл
        Символ = Сред(ИмяРеквизита, ъ, 1);
        ПредСимвол = Сред(ИмяРеквизита, ъ-1, 1);
        СледСимвол = Сред(ИмяРеквизита, ъ+1, 1);
        Прописная = Символ = ВРег(Символ);
        ПредПрописная = ПредСимвол = ВРег(ПредСимвол);
        СледПрописная = СледСимвол = ВРег(СледСимвол);
        
        // Варианты:
        Если НЕ ПредПрописная И Прописная Тогда
            Синоним = Синоним + " " + Символ;
        ИначеЕсли Прописная И НЕ СледПрописная Тогда
            Синоним = Синоним + " " + Символ;
        Иначе
            Синоним = Синоним + Символ;
        Конецесли;
    КонецЦикла;

	Синоним = ВРег(Лев(Синоним,1)) + нРег(Сред(Синоним,2));
    
    Возврат Синоним;
    
КонецФункции

ПриСозданииОбъекта();