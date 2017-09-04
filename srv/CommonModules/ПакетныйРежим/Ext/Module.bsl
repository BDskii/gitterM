﻿
///////////////////////////////////////////////////////////////////////////////////////////////////
//Таблица версий

Функция ПолучитьТаблицуВерсийХранилища(Знач Хранилище, НачинаяСВерсии = Неопределено, ЗаканчиваяНаВерсии = Неопределено, ПолучатьИзменения = Ложь) Экспорт
	
	ТабличныйДокументВерсий = ПолучитьИмяВременногоФайла("mxl"); 
	
	ТекстКоманды = СоздатьКоманду(Хранилище.Приложение1С);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", Хранилище.ТранзитнаяБазаАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", Хранилище.ТранзитнаяБазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", Хранилище.ТранзитнаяБазаПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryF", Хранилище.ХранилищеАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryN", Хранилище.ХранилищеПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryP", Хранилище.ХранилищеПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryReport", ТабличныйДокументВерсий);
	
	Если ЗначениеЗаполнено(НачинаяСВерсии) Тогда
		
		ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-NBegin", Формат(НачинаяСВерсии, "ЧН=; ЧГ=0"));
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ЗаканчиваяНаВерсии) Тогда
		
		ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-NEnd", Формат(ЗаканчиваяНаВерсии, "ЧН=; ЧГ=0"));
		
	КонецЕсли;
	
	КодВозврата = ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
	
	Если КодВозврата <> 0 Тогда
		
		ОписаниеОшибки = "При получении таблицы версий хранилища произошла неизвестная ошибка";
		ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
		
	КонецЕсли;
	
	ТабДок = Новый ТабличныйДокумент();
	ТабДок.Прочитать(ТабличныйДокументВерсий);
	ТаблицаВерсий = ПолучитьТаблицуВерсийИзТабличногоДокумента(ТабДок, ПолучатьИзменения);
	
	УдалитьФайлПоВозможности(ТабличныйДокументВерсий);
		
	Возврат ТаблицаВерсий;
	
КонецФункции

Функция ПолучитьТаблицуВерсийИзТабличногоДокумента(ТабличныйДокумент, ПолучатьИзменения)
	
	ТаблицаВерсий = Новый ТаблицаЗначений;
	ТаблицаВерсий.Колонки.Добавить("НомерВерсии", Новый ОписаниеТипов("Число"));
	ТаблицаВерсий.Колонки.Добавить("ИмяПользователя", Новый ОписаниеТипов("Строка"));
	ТаблицаВерсий.Колонки.Добавить("ДатаСоздания", Новый ОписаниеТипов("Дата"));
	ТаблицаВерсий.Колонки.Добавить("Комментарий", Новый ОписаниеТипов("Строка"));
	ТаблицаВерсий.Колонки.Добавить("Изменения", Новый ОписаниеТипов("ТаблицаЗначений"));
	
	ШаблонТаблицыИзменений = Новый ТаблицаЗначений;
	ШаблонТаблицыИзменений.Колонки.Добавить("ТипИзменения", ГлОписаниеТипаСтрока(20));
	ШаблонТаблицыИзменений.Колонки.Добавить("Объект", ГлОписаниеТипаСтрока());
	
	
	СтруктураЛокали = ПолучитьСтруктуруЛокализации(ТабличныйДокумент.Область(1,1,1,1).Текст);

	
	МассивЧисел = СтроковыеФункцииКлиентСервер.ПолучитьМассивСимволов("Цифры");
	
	НачинаяСоСтроки = 1;
	Пока ТабличныйДокумент.ВысотаТаблицы >= НачинаяСоСтроки Цикл
		
		ОбластьПоиска = ТабличныйДокумент.Область(НачинаяСоСтроки,1,ТабличныйДокумент.ВысотаТаблицы,1);
		ОбластьРезультат = ТабличныйДокумент.НайтиТекст(СтруктураЛокали.Версия,,ОбластьПоиска, Истина, Истина, Истина, Ложь);
				
		Если ОбластьРезультат = Неопределено Тогда
			Прервать;
		КонецЕсли;	
		
		НоваяСтрока = ТаблицаВерсий.Добавить();
		НоваяСтрока.НомерВерсии = Число(СтроковыеФункцииКлиентСервер.ОставитьВСтрокеСимволыИзМассива(ТабличныйДокумент.Область(ОбластьРезультат.Верх, 2).Текст,МассивЧисел));
		НоваяСтрока.ИмяПользователя = ТабличныйДокумент.Область(ОбластьРезультат.Верх + 1, 2).Текст;
		ДатаСоздания = ТабличныйДокумент.Область(ОбластьРезультат.Верх + 2, 2).Текст;
		ВремяСоздания = ТабличныйДокумент.Область(ОбластьРезультат.Верх + 3, 2).Текст;
		НоваяСтрока.ДатаСоздания = РазобратьВремя(ДатаСоздания, ВремяСоздания);   			
		НоваяСтрока.Комментарий = ТабличныйДокумент.Область(ОбластьРезультат.Верх + 4, 2).Текст;
		
		НачинаяСоСтроки = ОбластьРезультат.Верх + 5;
	КонецЦикла;
	
	Возврат ТаблицаВерсий;
	
КонецФункции

Функция ПолучитьСтруктуруЛокализации(ТекстЗаголовка)
	
	СтруктураЛокали = Новый Структура("Версия,Изменены,Добавлены,Удалены");
	
	Если СтрНачинаетсяС(ТекстЗаголовка, "Отчет по версиям хранилища:") Тогда 
		
		СтруктураЛокали.Вставить("Версия","Версия");
		СтруктураЛокали.Вставить("Добавлены","Добавлены");
		СтруктураЛокали.Вставить("Изменены","Изменены");
		СтруктураЛокали.Вставить("Удалены","Удалены");
		
	ИначеЕсли СтрНачинаетсяС(ТекстЗаголовка, "Repository Versions Report:") Тогда 
		
		СтруктураЛокали.Вставить("Версия","Version");
		СтруктураЛокали.Вставить("Добавлены","Added");
		СтруктураЛокали.Вставить("Изменены","Changed");
		СтруктураЛокали.Вставить("Удалены","Deleted");
		
	Иначе 
		ВызватьИсключение НСтр("ru = 'Не удалось определьить локаль файла отчета по конфигурации.'");
	КонецЕсли;	
	
	Возврат СтруктураЛокали;
	
КонецФункции	


Функция РазобратьВремя(ДатаСоздания, ВремяСоздания)
	
	Если СтрНайти(ВремяСоздания, "AM") <> Неопределено или СтрНайти(ВремяСоздания, "PM") <> Неопределено Тогда 
		ДопЧасы = 0;
		Если СтрНайти(ВремяСоздания, "PM") <> Неопределено Тогда 
			ДопЧасы = 12;
		КонецЕсли;
		ВремяСоздания = СтрЗаменить(ВремяСоздания, "PM","");
		ВремяСоздания = СтрЗаменить(ВремяСоздания, "AM","");
		ВремяСоздания = СокрЛП(ВремяСоздания);
		
		ДатаСоздания = СтрЗаменить(ДатаСоздания,"/",".");
		ДатаСоздания = СокрЛП(ДатаСоздания);
		МассивЧастейДаты = СтрРазделить(ДатаСоздания,".");
		ДатаСоздания = МассивЧастейДаты[1]+"."+МассивЧастейДаты[0]+"."+МассивЧастейДаты[2];
		
		Возврат Дата(ДатаСоздания + " " + ВремяСоздания) + (ДопЧасы*60*60);
	Иначе 	
		Возврат Дата(ДатаСоздания + " " + ВремяСоздания);   	
	КонецЕсли;	
	
КонецФункции	

//Таблица версий
///////////////////////////////////////////////////////////////////////////////////////////////////


Процедура ЗагрузитьКонфигурациюИзХранилища(Знач Хранилище, НомерВерсии) Экспорт
	
	ТекстКоманды = СоздатьКоманду(Хранилище.Приложение1С);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", Хранилище.ТранзитнаяБазаАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", Хранилище.ТранзитнаяБазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", Хранилище.ТранзитнаяБазаПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryF", Хранилище.ХранилищеАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryN", Хранилище.ХранилищеПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryP", Хранилище.ХранилищеПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/ConfigurationRepositoryUpdateCfg");
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-v", Формат(НомерВерсии, "ЧГ="));
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-revised");
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-force");
	
	КодВозврата = ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
	
	Если КодВозврата <> 0 Тогда
		
		ОписаниеОшибки = "При обновлении основной конфигурации конфигурацией из хранилища произошла неизвестная ошибка";
		ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыгрузитьКонфигурациюВФайлы(Знач Хранилище, Каталог) Экспорт
	
	выгрузкаСОбновлением = Хранилище.ОбновлениеВыгрузки;
	
	Если выгрузкаСОбновлением Тогда
		
		Если Не ФайлСуществует(Каталог + "\ConfigDumpInfo.xml") Тогда
			
			выгрузкаСОбновлением = Ложь;
			
		Иначе
			
			имяФайлаИзменений = Справочники.Хранилища.ИмяФайлаИзменений(Хранилище);
			
			ТекстКоманды = СоздатьКоманду(Хранилище.Приложение1С);
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", Хранилище.ТранзитнаяБазаАдрес);
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", Хранилище.ТранзитнаяБазаПользователь);
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", Хранилище.ТранзитнаяБазаПароль);
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/DumpConfigToFiles", Каталог);
			
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-getChanges", имяФайлаИзменений);
			
			ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
			
			выгрузкаСОбновлением = Не ПроверитьФайлИзменений_ТребуетсяПолнаяВыгрузка(Хранилище);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не выгрузкаСОбновлением Тогда
		
		Справочники.Хранилища.УдалитьВсеФайлыВКаталоге(Каталог);
		
	КонецЕсли;
	
	ТекстКоманды = СоздатьКоманду(Хранилище.Приложение1С);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", Хранилище.ТранзитнаяБазаАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", Хранилище.ТранзитнаяБазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", Хранилище.ТранзитнаяБазаПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/DumpConfigToFiles", Каталог);
	
	Если выгрузкаСОбновлением Тогда
		
		ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-update");
		ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-force");
		
	КонецЕсли;
	
	КодВозврата = ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
	
	Если КодВозврата <> 0 Тогда
		
		ОписаниеОшибки = "При выгрузке основной конфигурации в файлы произошла неизвестная ошибка";
		ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
		
	КонецЕсли;
	
КонецПроцедуры


Процедура ВыгрузитьКонфигурациюВCF(Знач Хранилище, Знач Приложение, Знач БазаАдрес, Знач БазаПользователь, Знач БазаПароль, Знач пПутьКCF) Экспорт
	
	ТекстКоманды = СоздатьКоманду(Приложение);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", БазаАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", БазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", БазаПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/DumpCfg", пПутьКCF);
	
	КодВозврата = ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
	Если КодВозврата <> 0 Тогда
		ОписаниеОшибки = "При выгрузке основной конфигурации в CF произошла неизвестная ошибка";
		ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьКонфигурациюБазыДанных(Знач Хранилище, Знач Приложение, Знач БазаАдрес, Знач БазаПользователь, Знач БазаПароль) Экспорт
	
	ТекстКоманды = СоздатьКоманду(Приложение);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/F", БазаАдрес);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", БазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", БазаПароль);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/UpdateDBCfg");
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-Dynamic–");
	
	КодВозврата = ВыполнитьКоманду1С(ТекстКоманды, Хранилище);
	Если КодВозврата <> 0 Тогда
		ОписаниеОшибки = "При обновлении конфигурации базы данных произошла неизвестная ошибка";
		ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
	КонецЕсли;
	
КонецПроцедуры


Процедура ЗапуститьВРежимеПредприятияПоСтрокеСоединения(Знач Приложение, Знач пСтрокаСоединения, Знач БазаПользователь, Знач БазаПароль, Знач пОжидатьЗавершения = Ложь, Знач пПараметрЗапуска = "") Экспорт
	
	ТекстКоманды = СоздатьКоманду(Приложение, Ложь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/IBConnectionString", пСтрокаСоединения);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/N", БазаПользователь);
	ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/P", БазаПароль);
	
	Если ЗначениеЗаполнено(пПараметрЗапуска) Тогда
		ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/C" + пПараметрЗапуска);
	КонецЕсли;
	
	Если пОжидатьЗавершения Тогда
		
		КодВозврата = ВыполнитьКоманду1С(ТекстКоманды,, пОжидатьЗавершения);
		Если КодВозврата <> 0 Тогда
			ОписаниеОшибки = "При запуске в режиме предприятия произошла ошибка.";
			ВызватьИсключение ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды);
		КонецЕсли;
		
	Иначе
		
		ВыполнитьКоманду1С(ТекстКоманды,, пОжидатьЗавершения);
		
	КонецЕсли;
	
КонецПроцедуры


Функция СоздатьКоманду(Знач Приложение, Знач пРежимКонфигуратора = Истина)
	
	Если пРежимКонфигуратора Тогда
		ТекстКоманды = """" + Приложение + """" + " DESIGNER ";
	Иначе
		ТекстКоманды = """" + Приложение + """" + " ENTERPRISE ";
	КонецЕсли;
	Возврат ТекстКоманды;
	
КонецФункции

Функция ВыполнитьКоманду1С(ТекстКоманды, Знач Хранилище = Неопределено, Знач пОжидатьЗавершения = Истина)
	
	Если Хранилище = Неопределено Тогда
		
		КаталогКонфигурации = Неопределено;
		
	Иначе
		
		Если ЗначениеЗаполнено(Хранилище.ФайлВыводаСлужебныхСообщений) Тогда
			
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "/Out", Хранилище.ФайлВыводаСлужебныхСообщений);
			ДобавитьВКомандуКлючЗначение(ТекстКоманды, "-NoTruncate");
			
			ОбеспечитьТекстовыйФайл(Хранилище.ФайлВыводаСлужебныхСообщений);
			
			записьФайла = Новый ЗаписьТекста(Хранилище.ФайлВыводаСлужебныхСообщений, , , Истина);
			записьФайла.ЗаписатьСтроку("" + ТекущаяДата());
			записьФайла.ЗаписатьСтроку(ТекстКоманды);
			записьФайла.Закрыть();
			
		КонецЕсли;
		
		КаталогКонфигурации = Справочники.Хранилища.ПолучитьКаталогКонфигурации(Хранилище);
		
	КонецЕсли;
	
	Возврат ВыполнитьКоманду(КаталогКонфигурации, ТекстКоманды, пОжидатьЗавершения);
	
КонецФункции




Процедура ДобавитьВКомандуКлючЗначение(ТекстКоманды, Ключ, Значение = Неопределено)
	
	Если Значение = Неопределено Тогда
		ТекстКоманды = ТекстКоманды + " " + Ключ;
	Иначе	
		ТекстКоманды = ТекстКоманды + " " + Ключ + " """ + Экранировать(Значение) + """";
	КонецЕсли;
	
КонецПроцедуры

Функция ИсключениеОшибкаПриВыполненииКоманды(ОписаниеОшибки, ТекстКоманды)
	
	Возврат ОписаниеОшибки + "(" + ТекстКоманды + ")";	
	
КонецФункции



Функция ПроверитьФайлИзменений_ТребуетсяПолнаяВыгрузка(Знач Хранилище)
	
	Если Не Хранилище.ОбновлениеВыгрузки Тогда
		Возврат Истина;
	КонецЕсли;
	
	имяФайлаИзменений = Справочники.Хранилища.ИмяФайлаИзменений(Хранилище);
	
	Если Не ФайлСуществует(имяФайлаИзменений) Тогда
		Возврат Истина;
	Иначе
		
		чтениеФайла = Новый ЧтениеТекста(имяФайлаИзменений);
		текстПервойСтроки = чтениеФайла.ПрочитатьСтроку();
		чтениеФайла.Закрыть();
		Если Найти(ВРег(текстПервойСтроки), ВРег("FullDump")) = 1 Тогда
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

Функция ПроверитьФайлИзменений_ЕстьИзменения(Знач Хранилище) Экспорт
	
	Если Не Хранилище.ОбновлениеВыгрузки Тогда
		Возврат Истина;
	КонецЕсли;
	
	имяФайлаИзменений = Справочники.Хранилища.ИмяФайлаИзменений(Хранилище);
	
	Если Не ФайлСуществует(имяФайлаИзменений) Тогда
		Возврат Ложь;
	Иначе
		
		чтениеФайла = Новый ЧтениеТекста(имяФайлаИзменений);
		Если Не ЗначениеЗаполнено(ВРег(чтениеФайла.ПрочитатьСтроку())) Тогда
			Возврат Ложь;
		КонецЕсли;
		чтениеФайла.Закрыть();
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции


