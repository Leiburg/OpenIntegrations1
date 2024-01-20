// MIT License

// Copyright (c) 2023 Anton Tsitavets

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// https://github.com/Bayselonarrend/OpenIntegrations
#Область СлужебныйПрограммныйИнтерфейс

#Область HTTPМетоды

Функция Get(Знач URL, Знач Параметры = "", Знач ДопЗаголовки = "") Экспорт

	Если Не ЗначениеЗаполнено(Параметры) Тогда
		Параметры = Новый Структура;
	КонецЕсли;

	Заголовки = Новый Соответствие;

	Если ТипЗнч(ДопЗаголовки) = Тип("Соответствие") Тогда

		Для Каждого Заголовок Из ДопЗаголовки Цикл
			Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
		КонецЦикла;

	КонецЕсли;

	СтруктураURL = РазбитьURL(URL);
	Соединение   = Новый HTTPСоединение(СтруктураURL["Сервер"], 443, , , , 300, Новый ЗащищенноеСоединениеOpenSSL);
	Запрос       = Новый HTTPЗапрос(СтруктураURL["Адрес"] + ПараметрыЗапросаВСтроку(Параметры), Заголовки);
	Ответ        = Соединение.Получить(Запрос);

	Попытка
		ТелоОтвета = JsonВСтруктуру(Ответ.ПолучитьТелоКакДвоичныеДанные());
	Исключение
		ТелоОтвета = Ответ.ПолучитьТелоКакДвоичныеДанные();
	КонецПопытки;

	Возврат ТелоОтвета;

КонецФункции

// BSLLS:CognitiveComplexity-off

Функция PostMultipart(Знач URL, Знач Параметры, Знач Файлы = "", Знач ТипКонтента = "image/jpeg",
	Знач ДопЗаголовки = "") Экспорт

	Если Не ЗначениеЗаполнено(Параметры) Тогда
		Параметры = Новый Структура;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(Файлы) Тогда
		Файлы = Новый Соответствие;
	КонецЕсли;

	ЗаменаТочки              = "___";
	GZip                     = "gzip";
	Boundary                 = СтрЗаменить(Строка(Новый УникальныйИдентификатор), "-", "");
	СтруктураURL             = РазбитьURL(URL);

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", "multipart/form-data; boundary=" + Boundary);
	Заголовки.Вставить("Accept-Encoding", GZip);
	Заголовки.Вставить("Accept", "*/*");
	Заголовки.Вставить("Connection", "keep-alive");

	Если ТипЗнч(ДопЗаголовки) = Тип("Соответствие") Тогда

		Для Каждого Заголовок Из ДопЗаголовки Цикл
			Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
		КонецЦикла;

	КонецЕсли;

	Соединение     = Новый HTTPСоединение(СтруктураURL["Сервер"], 443, , , , 300, Новый ЗащищенноеСоединениеOpenSSL);
	НовыйЗапрос    = Новый HTTPЗапрос(СтруктураURL["Адрес"], Заголовки);
	ТелоЗапроса    = НовыйЗапрос.ПолучитьТелоКакПоток();
	ЗаписьТекста   = Новый ЗаписьДанных(ТелоЗапроса, КодировкаТекста.UTF8, ПорядокБайтов.LittleEndian, "", "", Ложь);

	РазделительСтрок = Символы.ВК + Символы.ПС;

	Для Каждого Параметр Из Параметры Цикл

		ЗаписьТекста.ЗаписатьСтроку("--" + boundary + РазделительСтрок);
		ЗаписьТекста.ЗаписатьСтроку("Content-Disposition: form-data; name=""" + Параметр.Ключ + """");
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);

		Если ТипЗнч(Параметр.Значение) = Тип("Строка") Тогда
			ЗаписьТекста.ЗаписатьСтроку(Параметр.Значение);
		Иначе
			ЗаписьТекста.Записать(Параметр.Значение);
		КонецЕсли;

		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);

	КонецЦикла;

	Счетчик = 0;
	Для Каждого Файл Из Файлы Цикл

		ПутьФайл = СтрЗаменить(Файл.Ключ, ЗаменаТочки, ".");

		Если ТипКонтента = "image/jpeg" Тогда
			ИмяФайлаОтправки = "photo";
		Иначе
			ИмяФайлаОтправки = СтрЗаменить(Файл.Ключ, ЗаменаТочки, ".");
			ИмяФайлаОтправки = Лев(ИмяФайлаОтправки, СтрНайти(ИмяФайлаОтправки, ".") - 1);
			ИмяФайлаОтправки = ?(ЗначениеЗаполнено(ИмяФайлаОтправки), ИмяФайлаОтправки, СтрЗаменить(Файл.Ключ,
				ЗаменаТочки, "."));
		КонецЕсли;

		ЗаписьТекста.ЗаписатьСтроку("--" + boundary + РазделительСтрок);
		ЗаписьТекста.ЗаписатьСтроку("Content-Disposition: form-data; name=""" + ИмяФайлаОтправки + """; filename=""" + ПутьФайл
			+ """");
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);
		ЗаписьТекста.ЗаписатьСтроку("Content-Type: " + ТипКонтента);
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);
		ЗаписьТекста.Записать(Файл.Значение);
		ЗаписьТекста.ЗаписатьСтроку(РазделительСтрок);

		Счетчик = Счетчик + 1;

	КонецЦикла;

	ЗаписьТекста.ЗаписатьСтроку("--" + boundary + "--" + РазделительСтрок);

	ЗаписьТекста.Закрыть();

	Ответ = Соединение.ВызватьHTTPМетод("POST", НовыйЗапрос);

	НужнаРаспаковка = Ответ.Заголовки.Получить("Content-Encoding") = GZip Или Ответ.Заголовки.Получить(
		"content-encoding") = GZip;

	Если НужнаРаспаковка Тогда
		Ответ = РаспаковатьОтвет(Ответ);
	КонецЕсли;

	Возврат ?(ТипЗнч(Ответ) = Тип("ДвоичныеДанные"), JsonВСтруктуру(Ответ), JsonВСтруктуру(
		Ответ.ПолучитьТелоКакДвоичныеДанные()));

КонецФункции

// BSLLS:CognitiveComplexity-on

Функция Post(Знач URL, Знач Параметры = "", Знач ДопЗаголовки = "", Знач JSON = Истина) Экспорт

	Если Не ЗначениеЗаполнено(Параметры) Тогда
		Параметры = Новый Структура;
	КонецЕсли;

	GZip         = "gzip";
	ТипДанных    = ?(JSON, "application/json", "application/x-www-form-urlencoded");
	СтруктураURL = РазбитьURL(URL);

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-Type", ТипДанных);
	Заголовки.Вставить("Accept-Encoding", GZip);
	Заголовки.Вставить("Accept", "*/*");
	Заголовки.Вставить("Connection", "keep-alive");

	Если ТипЗнч(ДопЗаголовки) = Тип("Соответствие") Тогда

		Для Каждого Заголовок Из ДопЗаголовки Цикл
			Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
		КонецЦикла;

	КонецЕсли;

	Соединение  = Новый HTTPСоединение(СтруктураURL["Сервер"], 443, , , , 300, Новый ЗащищенноеСоединениеOpenSSL);
	НовыйЗапрос = Новый HTTPЗапрос(СтруктураURL["Адрес"], Заголовки);

	Если JSON Тогда
		Данные           = JSONСтрокой(Параметры);
	Иначе
		СтрокаПараметров = ПараметрыЗапросаВСтроку(Параметры);
		Данные           = Прав(СтрокаПараметров, СтрДлина(СтрокаПараметров) - 1);
	КонецЕсли;

	НовыйЗапрос.УстановитьТелоИзСтроки(Данные);

	Ответ = Соединение.ВызватьHTTPМетод("POST", НовыйЗапрос);

	НужнаРаспаковка = Ответ.Заголовки.Получить("Content-Encoding") = GZip Или Ответ.Заголовки.Получить(
		"content-encoding") = GZip;

	Если НужнаРаспаковка Тогда
		Ответ = РаспаковатьОтвет(Ответ);
	КонецЕсли;

	Ответ = ?(ТипЗнч(Ответ) = Тип("HTTPОтвет"), Ответ.ПолучитьТелоКакДвоичныеДанные(), Ответ);

	Если ТипЗнч(Ответ) = Тип("ДвоичныеДанные") Тогда

		Попытка
			Ответ = JsonВСтруктуру(Ответ);
		Исключение
			Ответ = ПолучитьСтрокуИзДвоичныхДанных(Ответ);
		КонецПопытки;

	КонецЕсли;

	Возврат Ответ;

КонецФункции

Функция ПараметрыЗапросаВСоответствие(Знач СтрокаПараметров) Экспорт

	СоответствиеВозврата = Новый Соответствие;
	КоличествоЧастей     = 2;
	МассивПараметров     = СтрРазделить(СтрокаПараметров, "&", Ложь);

	Для Каждого Параметр Из МассивПараметров Цикл

		МассивКлючЗначение = СтрРазделить(Параметр, "=");

		Если МассивКлючЗначение.Количество() = КоличествоЧастей Тогда
			СоответствиеВозврата.Вставить(МассивКлючЗначение[0], МассивКлючЗначение[1]);
		КонецЕсли;

	КонецЦикла;

	Возврат СоответствиеВозврата;

КонецФункции

Процедура ЗаменитьСпецСимволы(Текст) Экспорт

	МассивСимволов = Новый Соответствие;
	МассивСимволов.Вставить("<", "&lt;");
	МассивСимволов.Вставить(">", "&gt;");
	МассивСимволов.Вставить("&", "&amp;");
	МассивСимволов.Вставить("_", " ");
	МассивСимволов.Вставить("[", "(");
	МассивСимволов.Вставить("]", ")");

	Для Каждого СимволМассива Из МассивСимволов Цикл
		Текст = СтрЗаменить(Текст, СимволМассива.Ключ, СимволМассива.Значение);
	КонецЦикла;

КонецПроцедуры

Функция UNIXTime(Знач Дата) Экспорт
	Возврат Формат(Дата - Дата(1970, 1, 1, 1, 0, 0), "ЧГ=0");
КонецФункции

#КонецОбласти

#Область Служебные

Функция ПараметрыЗапросаВСтроку(Знач Параметры) Экспорт

	Если Параметры.Количество() = 0 Тогда
		Возврат "";
	КонецЕсли;

	СтрокаПараметров = "?";

	Для Каждого Параметр Из Параметры Цикл
		СтрокаПараметров = СтрокаПараметров + Параметр.Ключ + "=" + КодироватьСтроку(Параметр.Значение,
			СпособКодированияСтроки.КодировкаURL) + "&";
	КонецЦикла;

	СтрокаПараметров = Лев(СтрокаПараметров, СтрДлина(СтрокаПараметров) - 1);

	Возврат СтрокаПараметров;

КонецФункции

Функция РазбитьURL(Знач URL) Экспорт

	URL = СтрЗаменить(URL, "https://", "");
	URL = СтрЗаменить(URL, "http://", "");
	URL = СтрЗаменить(URL, "www.", "");

	СтруктураВозврата = Новый Структура;
	СтруктураВозврата.Вставить("Сервер", Лев(URL, СтрНайти(URL, "/", НаправлениеПоиска.СНачала) - 1));
	СтруктураВозврата.Вставить("Адрес", Прав(URL, СтрДлина(URL) - СтрНайти(URL, "/", НаправлениеПоиска.СНачала) + 1));

	Возврат СтруктураВозврата;

КонецФункции

Функция JsonВСтруктуру(Знач Текст, Знач Кодировка = "utf-8") Экспорт

	Если Не ЗначениеЗаполнено(Текст) Тогда
		Возврат "";
	КонецЕсли;

	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьПоток(Текст.ОткрытьПотокДляЧтения());

	Данные = ПрочитатьJSON(ЧтениеJSON, Истина, Неопределено, ФорматДатыJSON.ISO);
	ЧтениеJSON.Закрыть();

	Возврат Данные;

КонецФункции

Функция JSONСтрокой(Знач Данные) Экспорт

	ПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Windows, " ", Истина, ЭкранированиеСимволовJSON.Нет,
		Ложь, Ложь, Ложь, Ложь);

	ЗаписьJSON                        = Новый ЗаписьJSON;
	ЗаписьJSON.ПроверятьСтруктуру     = Истина;
	ЗаписьJSON.УстановитьСтроку(ПараметрыJSON);

	ЗаписатьJSON(ЗаписьJSON, Данные);
	Возврат ЗаписьJSON.Закрыть();

КонецФункции

Функция ЧислоВСтроку(Знач Число) Экспорт
	Возврат СтрЗаменить(Строка(Число), Символы.НПП, "");
КонецФункции

Процедура ВыполнитьСкрипт(Знач Текст) Экспорт

	ИмяСкрипта   = ПолучитьИмяВременногоФайла(".ps1");
	ТекстСкрипта = Новый ТекстовыйДокумент;

	ТекстСкрипта.УстановитьТекст(Текст);

	ТекстСкрипта.Записать(ИмяСкрипта, КодировкаТекста.UTF8);

	КодВозврата = 0;
	ЗапуститьПриложение("powershell -file " + ИмяСкрипта + " -noexit", , Истина, КодВозврата);

	УдалитьФайлы(ИмяСкрипта);

КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область GZip

// Описание структур см. здесь https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
// Источник: https://github.com/vbondarevsky/Connector 

// Коннектор: удобный HTTP-клиент для 1С:Предприятие 8
//
// Copyright 2017-2023 Vladimir Bondarevskiy
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//
// URL:    https://github.com/vbondarevsky/Connector
// e-mail: vbondarevsky@gmail.com
// Версия: 2.4.8
//
// Требования: платформа 1С версии 8.3.10 и выше

// BSLLS:LatinAndCyrillicSymbolInWord-off

Функция РаспаковатьОтвет(Ответ)

	Попытка
		Возврат ПрочитатьGZip(Ответ.ПолучитьТелоКакДвоичныеДанные());
	Исключение
		Возврат Ответ;
	КонецПопытки;

КонецФункции

Функция ПрочитатьGZip(СжатыеДанные) Экспорт

	РазмерПрефиксаGZip  = 10;
	РазмерПостфиксаGZip = 8;

	ЧтениеДанных = Новый ЧтениеДанных(СжатыеДанные);
	ЧтениеДанных.Пропустить(РазмерПрефиксаGZip);
	РазмерСжатыхДанных = ЧтениеДанных.ИсходныйПоток().Размер() - РазмерПрефиксаGZip - РазмерПостфиксаGZip;

	ПотокZip     = Новый ПотокВПамяти(ZipРазмерLFH() + РазмерСжатыхДанных + ZipРазмерDD() + ZipРазмерCDH() 
	   + ZipРазмерEOCD());
	ЗаписьДанных = Новый ЗаписьДанных(ПотокZip);
	ЗаписьДанных.ЗаписатьБуферДвоичныхДанных(ZipLFH());
	ЧтениеДанных.КопироватьВ(ЗаписьДанных, РазмерСжатыхДанных);

	ЗаписьДанных.Закрыть();
	ЗаписьДанных = Новый ЗаписьДанных(ПотокZip);

	CRC32 = ЧтениеДанных.ПрочитатьЦелое32();
	РазмерНесжатыхДанных = ЧтениеДанных.ПрочитатьЦелое32();
	ЧтениеДанных.Закрыть();

	ЗаписьДанных.ЗаписатьБуферДвоичныхДанных(ZipDD(CRC32, РазмерСжатыхДанных, РазмерНесжатыхДанных));
	ЗаписьДанных.ЗаписатьБуферДвоичныхДанных(ZipCDH(CRC32, РазмерСжатыхДанных, РазмерНесжатыхДанных));
	ЗаписьДанных.ЗаписатьБуферДвоичныхДанных(ZipEOCD(РазмерСжатыхДанных));
	ЗаписьДанных.Закрыть();

	Возврат ПрочитатьZip(ПотокZip);

КонецФункции

Функция ПрочитатьZip(СжатыеДанные, ТекстОшибки = Неопределено)

	Каталог   = ПолучитьИмяВременногоФайла();
	ЧтениеZip = Новый ЧтениеZipФайла(СжатыеДанные);
	ИмяФайла  = ЧтениеZip.Элементы[0].Имя;
	Попытка
		ЧтениеZip.Извлечь(ЧтениеZip.Элементы[0], Каталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	Исключение
        // Игнорируем проверку целостности архива, просто читаем результат
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	ЧтениеZip.Закрыть();

	Результат = Новый ДвоичныеДанные(Каталог + ПолучитьРазделительПути() + ИмяФайла);
	УдалитьФайлы(Каталог);

	Возврат Результат;

КонецФункции

Функция ZipРазмерLFH()

	Возврат 34;

КонецФункции

Функция ZipРазмерDD()

	Возврат 16;

КонецФункции

Функция ZipРазмерCDH()

	Возврат 50;

КонецФункции

Функция ZipРазмерEOCD()

	Возврат 22;

КонецФункции

Функция ZipLFH()
    
    // Local file header
	Буфер = Новый БуферДвоичныхДанных(ZipРазмерLFH());
	Буфер.ЗаписатьЦелое32(0, 67324752); // signature 0x04034b50
	Буфер.ЗаписатьЦелое16(4, 20);       // version
	Буфер.ЗаписатьЦелое16(6, 10);       // bit flags    
	Буфер.ЗаписатьЦелое16(8, 8);        // compression method
	Буфер.ЗаписатьЦелое16(10, 0);       // time
	Буфер.ЗаписатьЦелое16(12, 0);       // date
	Буфер.ЗаписатьЦелое32(14, 0);       // crc-32
	Буфер.ЗаписатьЦелое32(18, 0);       // compressed size
	Буфер.ЗаписатьЦелое32(22, 0);       // uncompressed size
	Буфер.ЗаписатьЦелое16(26, 4);       // filename legth - "data"
	Буфер.ЗаписатьЦелое16(28, 0);       // extra field length
	Буфер.Записать(30, ПолучитьБуферДвоичныхДанныхИзСтроки("data", "ascii", Ложь));

	Возврат Буфер;

КонецФункции

Функция ZipDD(CRC32, РазмерСжатыхДанных, РазмерНесжатыхДанных)
    
    // Data descriptor
	Буфер = Новый БуферДвоичныхДанных(ZipРазмерDD());
	Буфер.ЗаписатьЦелое32(0, 134695760);
	Буфер.ЗаписатьЦелое32(4, CRC32);
	Буфер.ЗаписатьЦелое32(8, РазмерСжатыхДанных);
	Буфер.ЗаписатьЦелое32(12, РазмерНесжатыхДанных);

	Возврат Буфер;

КонецФункции

Функция ZipCDH(CRC32, РазмерСжатыхДанных, РазмерНесжатыхДанных)
    
    // Central directory header
	Буфер = Новый БуферДвоичныхДанных(ZipРазмерCDH());
	Буфер.ЗаписатьЦелое32(0, 33639248);              // signature 0x02014b50
	Буфер.ЗаписатьЦелое16(4, 798);                   // version made by
	Буфер.ЗаписатьЦелое16(6, 20);                    // version needed to extract
	Буфер.ЗаписатьЦелое16(8, 10);                    // bit flags
	Буфер.ЗаписатьЦелое16(10, 8);                    // compression method
	Буфер.ЗаписатьЦелое16(12, 0);                    // time
	Буфер.ЗаписатьЦелое16(14, 0);                    // date
	Буфер.ЗаписатьЦелое32(16, CRC32);                // crc-32
	Буфер.ЗаписатьЦелое32(20, РазмерСжатыхДанных);   // compressed size
	Буфер.ЗаписатьЦелое32(24, РазмерНесжатыхДанных); // uncompressed size
	Буфер.ЗаписатьЦелое16(28, 4);                    // file name length
	Буфер.ЗаписатьЦелое16(30, 0);                    // extra field length
	Буфер.ЗаписатьЦелое16(32, 0);                    // file comment length
	Буфер.ЗаписатьЦелое16(34, 0);                    // disk number start
	Буфер.ЗаписатьЦелое16(36, 0);                    // internal file attributes
	Буфер.ЗаписатьЦелое32(38, 2176057344);           // external file attributes
	Буфер.ЗаписатьЦелое32(42, 0);                    // relative offset of local header
	Буфер.Записать(46, ПолучитьБуферДвоичныхДанныхИзСтроки("data", "ascii", Ложь));

	Возврат Буфер;

КонецФункции

Функция ZipEOCD(РазмерСжатыхДанных)
    
    // End of central directory
	РазмерCDH = 50;
	Буфер = Новый БуферДвоичныхДанных(ZipРазмерEOCD());
	Буфер.ЗаписатьЦелое32(0, 101010256); // signature 0x06054b50
	Буфер.ЗаписатьЦелое16(4, 0); // number of this disk
	Буфер.ЗаписатьЦелое16(6, 0); // number of the disk with the start of the central directory
	Буфер.ЗаписатьЦелое16(8, 1); // total number of entries in the central directory on this disk
	Буфер.ЗаписатьЦелое16(10, 1); // total number of entries in the central directory
	Буфер.ЗаписатьЦелое32(12, РазмерCDH); // size of the central directory    
    // offset of start of central directory with respect to the starting disk number
	Буфер.ЗаписатьЦелое32(16, ZipРазмерLFH() + РазмерСжатыхДанных + ZipРазмерDD());
	Буфер.ЗаписатьЦелое16(20, 0); // the starting disk number

	Возврат Буфер;

КонецФункции

// BSLLS:LatinAndCyrillicSymbolInWord-on

#КонецОбласти

#КонецОбласти