﻿///////////////////////////////////////////////////////////////////////////////////////////////////
//Интерфейс

Процедура ВыполнитьСборМетрикПоВерсии(Версия) Экспорт
	
	Хранилище = Версия.Владелец;
	ДанныеВерсии = Справочники.ВерсииКонфигурацийХранилища.СобратьДанныеПоВерсии(Версия);
	
	Справочники.Хранилища.УставновитьОтметкуЗанятости(Хранилище, Истина, "Выгрузка в локальный репозиторий");
	
	ЛогОтладка("--Сбор метрик по " + Хранилище + "--");
	
	Справочники.Хранилища.ПолучитьВерсиюИзХранилища(Хранилище, ДанныеВерсии);
	
	СобратьМетрикиПоВерсии(Версия);
	
	ЛогОтладка("--Закончен сбор метрик по " + Хранилище + "--");
	
	Справочники.Хранилища.УставновитьОтметкуЗанятости(Хранилище, Ложь);
	
КонецПроцедуры	


Процедура СобратьМетрикиПоВерсии(Версия) Экспорт 
	
	Хранилище = Версия.Владелец;
	
	СписокФайлов = ПолучитьСписокФайловИзВерсии(Версия, Хранилище);
	
	МассивУдаленныхФайлов = ОбщегоНазначенияКлиентСервер.НайтиСтрокиВМассиве(СписокФайлов, Новый Структура("ТипИзменения", Перечисления.ТипыИзменений.Удаление));
	
	ТаблицаМетрик = СобратьМетрикиПоСпискуФайлов(СписокФайлов, Версия, Хранилище);
	ТаблицаМетрик = ДобавитьОбнулениеОтсутствующих(Хранилище, Версия, МассивУдаленныхФайлов,  ТаблицаМетрик);
	ЗаписатьТаблицуМетрик(ТаблицаМетрик, Хранилище, Версия);
		
КонецПроцедуры

Процедура СобратьМетрикиПоХранилищу(Хранилище, Знач Версия = Неопределено) Экспорт 
	
	СписокФайлов = ПолучитьСписокФайловИзХранилища(Хранилище);
	
	Если Версия = Неопределено Тогда 
		Версия = НайтиПоследнуюВыгруженнуюВерсию(Хранилище);
	КонецЕсли;
	
	ТаблицаМетрик = СобратьМетрикиПоСпискуФайлов(СписокФайлов, Версия, Хранилище);
	ТаблицаМетрик = ДобавитьОбнулениеОтсутствующих(Хранилище, Версия,, ТаблицаМетрик);
	
	ЗаписатьТаблицуМетрик(ТаблицаМетрик, Хранилище, Версия);
	
КонецПроцедуры	

///////////////////////////////////////////////////////////////////////////////////////////////////
//Служебные
//Получение списка файлов

Функция ПолучитьСписокФайловИзВерсии(Версия, Хранилище)
	
	Результат = Новый Массив;
	
	ПутьККаталогуКонфигурации = Справочники.Хранилища.ПолныйПутьККаталогуКонфигурации(Хранилище);
	
	Для Каждого СтрокаИзменения из Версия.ИзмененныеФайлы Цикл 
		
		ПолноеИмяФайла = ОбщегоНазначенияКлиентСервер.ПолучитьПолноеИмяФайла(ПутьККаталогуКонфигурации, СтрокаИзменения.Файл);
		Файл = Новый Файл(ПолноеИмяФайла);
		Результат.Добавить(СобратьСтруктуруФайла(Файл, СтрокаИзменения.ТипИзменения, ПутьККаталогуКонфигурации));
		
	КонецЦикла;	
	
	Возврат Результат;	
	
КонецФункции

Функция ПолучитьСписокФайловИзХранилища(Хранилище)
	
	ПутьККаталогуКонфигурации = Справочники.Хранилища.ПолныйПутьККаталогуКонфигурации(Хранилище);
	
	Результат = Новый Массив;
	
	Для Каждого НайденныйФайл из НайтиФайлы(ПутьККаталогуКонфигурации, "*.bsl",Истина) Цикл 
		
		Результат.Добавить(СобратьСтруктуруФайла(НайденныйФайл, Перечисления.ТипыИзменений.Изменени, ПутьККаталогуКонфигурации));
		
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции

Функция СобратьСтруктуруФайла(Файл , ТипИзменения, ПутьККаталогуКонфигурации)
	
	СтруктураФайла = Новый Структура();
	СтруктураФайла.Вставить("ПолныйПуть", Файл.ПолноеИмя);
	СтруктураФайла.Вставить("ОтносительныйПуть", СтрЗаменить(Файл.ПолноеИмя, ПутьККаталогуКонфигурации, ""));
	СтруктураФайла.Вставить("ТипИзменения", ТипИзменения);
	
	Если ТипИзменения = Перечисления.ТипыИзменений.Удаление Тогда 
		СтруктураФайла.Вставить("Содержимое", "");

	Иначе 
		ТД = Новый ТекстовыйДокумент;
		ТД.Прочитать(Файл.ПолноеИмя, КодировкаТекста.UTF8);
		ТД.ПолучитьТекст();
		
		СтруктураФайла.Вставить("Содержимое", ТД.ПолучитьТекст());
	КонецЕсли;
	
	
	Возврат СтруктураФайла;
	
КонецФункции	

//Получение списка файлов
///////////////////////////////////////////////////////////////////////////////////////////////////

Функция СобратьМетрикиПоСпискуФайлов(СписокФайлов, Версия, Хранилище)
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Хранилище", Новый ОписаниеТипов("СправочникСсылка.Хранилища"));
	Результат.Колонки.Добавить("Версия", Новый ОписаниеТипов("СправочникСсылка.ВерсииКонфигурацийХранилища"));
	Результат.Колонки.Добавить("Метрика", Новый ОписаниеТипов("СправочникСсылка.Метрики"));
	Результат.Колонки.Добавить("Файл", ГлОписаниеТипаСтрока());
	Результат.Колонки.Добавить("Область", ГлОписаниеТипаСтрока());
	Результат.Колонки.Добавить("MD5Области", ГлОписаниеТипаСтрока(32));
	Результат.Колонки.Добавить("Значение", ГлОписаниеТипаЧисло(10,3));
	
	Для Каждого СтрокаМетрики из Хранилище.ИспользуемыеМетрики Цикл 
		
		ОбработкаМетрики = ОбщегоНазначениеСервер.СоздатьВнешнююОбработкуОтчетПоСсылке(СтрокаМетрики.Метрика);
		
		Для Каждого СтрокаФайла из  СписокФайлов Цикл 
			Если СтрокаФайла.ТипИзменения = Перечисления.ТипыИзменений.Удаление Тогда 
				Продолжить;
			КонецЕсли;	
			
			ОбластиДляАнализа = РазбитьТекстНаОбасти(СтрокаФайла.Содержимое);
			Для Каждого СтрокаОбласти из ОбластиДляАнализа Цикл 	
				ЗначениеМетрики = ОбработкаМетрики.ПолучитьЗначенние(СтрокаОбласти.Значение);
				
				ГлЗаполнитьСтрокуТаблицы(Результат.Добавить(),
				Хранилище,
				Версия,
				СтрокаМетрики.Метрика,
				СтрокаФайла.ОтносительныйПуть,
				СтрокаОбласти.Ключ,
				ОбщегоНазначениеСервер.ВычислитьХешСтрокиПоАлгоритмуMD5(СтрокаФайла.ОтносительныйПуть + " " + СтрокаОбласти.Ключ),
				ЗначениеМетрики);
				
			КонецЦикла;	
			
		КонецЦикла;	
	КонецЦикла;	
	
	Возврат Результат;
	
	
КонецФункции	

Функция НайтиПоследнуюВыгруженнуюВерсию(Хранилище)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Хранилище",Хранилище);
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВерсииКонфигурацийХранилища.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВерсииКонфигурацийХранилища КАК ВерсииКонфигурацийХранилища
	|ГДЕ
	|	ВерсииКонфигурацийХранилища.Владелец = &Хранилище
	|	И ВерсииКонфигурацийХранилища.ВыгруженаВЛокальныйРепозиторий
	|	И ВерсииКонфигурацийХранилища.ПометкаУдаления = ЛОЖЬ
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВерсииКонфигурацийХранилища.Код УБЫВ";
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда 
		Возврат Справочники.ВерсииКонфигурацийХранилища.ПустаяСсылка();
	КонецЕсли;
	
	Возврат Запрос.Выполнить().Выгрузить()[0].Ссылка;
	
КонецФункции	

Функция ДобавитьОбнулениеОтсутствующих(Хранилище, Версия, МассивУдаленныхФайлов = Неопределено, ТаблицаМетрик)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = ОбщегоНазначениеСервер.ПоместитьТаблицуВМенеджерВТ(ТаблицаМетрик, "ТаблицаМетрик");
	Запрос.УстановитьПараметр("Хранилище",Хранилище);
	Запрос.УстановитьПараметр("Версия",Версия);
	Запрос.УстановитьПараметр("МассивУдаленныхФайлов",МассивУдаленныхФайлов);
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДанныеМетрик.Хранилище КАК Хранилище,
	|	ДанныеМетрик.Версия КАК Версия,
	|	ДанныеМетрик.Метрика КАК Метрика,
	|	ДанныеМетрик.MD5Области КАК MD5Области,
	|	ДанныеМетрик.Значение КАК Значение,
	|	ДанныеМетрик.Файл КАК Файл,
	|	ДанныеМетрик.Область КАК Область
	|ПОМЕСТИТЬ ПоследниеЗначенияМетрик
	|ИЗ
	|	РегистрСведений.ДанныеМетрик КАК ДанныеМетрик
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|			ДанныеМетрик.Хранилище КАК Хранилище,
	|			ДанныеМетрик.Метрика КАК Метрика,
	|			МАКСИМУМ(ДанныеМетрик.Версия.Код) КАК ВерсияКод,
	|			ДанныеМетрик.MD5Области КАК MD5Области
	|		ИЗ
	|			РегистрСведений.ДанныеМетрик КАК ДанныеМетрик
	|		ГДЕ
	|			ДанныеМетрик.Хранилище = &Хранилище
	|			И (&МассивУдаленныхФайлов = НЕОПРЕДЕЛЕНО
	|					ИЛИ ДанныеМетрик.Файл В (&МассивУдаленныхФайлов))
	|		
	|		СГРУППИРОВАТЬ ПО
	|			ДанныеМетрик.Хранилище,
	|			ДанныеМетрик.Метрика,
	|			ДанныеМетрик.MD5Области) КАК ПоследниеМетрики
	|		ПО ДанныеМетрик.Хранилище = ПоследниеМетрики.Хранилище
	|			И ДанныеМетрик.Метрика = ПоследниеМетрики.Метрика
	|			И ДанныеМетрик.MD5Области = ПоследниеМетрики.MD5Области
	|			И ДанныеМетрик.Версия.Код = ПоследниеМетрики.ВерсияКод
	|ГДЕ
	|	ДанныеМетрик.Значение <> 0
	|	И (&МассивУдаленныхФайлов = НЕОПРЕДЕЛЕНО
	|			ИЛИ ДанныеМетрик.Файл В (&МассивУдаленныхФайлов))
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПоследниеЗначенияМетрик.Хранилище КАК Хранилище,
	|	&Версия КАК Версия,
	|	ПоследниеЗначенияМетрик.Метрика КАК Метрика,
	|	ПоследниеЗначенияМетрик.MD5Области КАК MD5Области,
	|	0 КАК Значение,
	|	ПоследниеЗначенияМетрик.Файл КАК Файл,
	|	ПоследниеЗначенияМетрик.Область КАК Область
	|ИЗ
	|	ПоследниеЗначенияМетрик КАК ПоследниеЗначенияМетрик
	|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаМетрик КАК ТаблицаМетрик
	|		ПО ПоследниеЗначенияМетрик.Хранилище = ТаблицаМетрик.Хранилище
	|			И ПоследниеЗначенияМетрик.Метрика = ТаблицаМетрик.Метрика
	|			И ПоследниеЗначенияМетрик.MD5Области = ТаблицаМетрик.MD5Области
	|ГДЕ
	|	ТаблицаМетрик.Хранилище ЕСТЬ NULL
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ТаблицаМетрик.Хранилище,
	|	ТаблицаМетрик.Версия,
	|	ТаблицаМетрик.Метрика,
	|	ТаблицаМетрик.MD5Области,
	|	ТаблицаМетрик.Значение,
	|	ТаблицаМетрик.Файл,
	|	ТаблицаМетрик.Область
	|ИЗ
	|	ТаблицаМетрик КАК ТаблицаМетрик";
	Возврат Запрос.Выполнить().Выгрузить(); 
	
КонецФункции	

Процедура ЗаписатьТаблицуМетрик(ТаблицаМетрик, Хранилище, Версия)
	
	НаборЗаписей = РегистрыСведений.ДанныеМетрик.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Хранилище.Установить(Хранилище);	
	НаборЗаписей.Отбор.Версия.Установить(Версия);
	
	НаборЗаписей.Загрузить(ТаблицаМетрик);
	
	НаборЗаписей.Записывать = Истина;
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры	

///////////////////////////////////////////////////////////////////////////////////////////////////
//Разделение текста на области

Функция РазбитьТекстНаОбасти(знач РазбираемыйТекст) 
	
	СтруктураПараметров = СформироватьСтруктуруПараметров();
	СтруктураПараметров.РазбираемыйТекст = РазбираемыйТекст;
	СтруктураПараметров.Режим = "ПоискНачалаМетода";
	СтруктураПараметров.ТекущийМассивКлючевыхСтрок = СтруктураПараметров.МассивКлючевыхСловПоискаНачала;		
	
	Для Каждого АнализируемаяСтрока Из СтрРазделить(РазбираемыйТекст, Символы.ПС) Цикл 
		СтруктураПараметров.НомерСтроки = СтруктураПараметров.НомерСтроки + 1;
		
		Если (СтруктураПараметров.Режим	= "ПоискНачалаМетода" Или  СтруктураПараметров.Режим	= "ПоискКонцаМетода") 
			И СтроковыеФункцииКлиентСервер.СтрокаСодержитСловоИзМассива(АнализируемаяСтрока, СтруктураПараметров.ТекущийМассивКлючевыхСтрок) = Ложь Тогда 
			ДобавитьТекстВОбласть(СтруктураПараметров, АнализируемаяСтрока);
			Продолжить;
		КонецЕсли;	
		
		РазобратьСтроку(АнализируемаяСтрока, СтруктураПараметров);
		
	КонецЦикла;	
	
	СобратьОсновнуюОбласть(СтруктураПараметров);
	
	Возврат СтруктураПараметров.Области;
	
КонецФункции

Функция СформироватьСтруктуруПараметров()
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("РазбираемыйТекст","");
	СтруктураПараметров.Вставить("Области",Новый Структура);
	СтруктураПараметров.Вставить("ИмяОбласти","");
	СтруктураПараметров.Вставить("Режим","");
	СтруктураПараметров.Вставить("НомерСтроки",0);
	
	СтруктураПараметров.Вставить("ТекущийМассивКлючевыхСтрок");
	
	СтруктураПараметров.Вставить("МассивКлючевыхСловПоискаНачала", Новый Массив);
	СтруктураПараметров.МассивКлючевыхСловПоискаНачала.Добавить("Функция");
	СтруктураПараметров.МассивКлючевыхСловПоискаНачала.Добавить("Funсtion");
	СтруктураПараметров.МассивКлючевыхСловПоискаНачала.Добавить("Процедура");
	СтруктураПараметров.МассивКлючевыхСловПоискаНачала.Добавить("Procedure");
	
	СтруктураПараметров.Вставить("МассивКлючевыхСловПроцедуры", Новый Массив);
	СтруктураПараметров.МассивКлючевыхСловПроцедуры.Добавить("КонецПроцедуры");
	СтруктураПараметров.МассивКлючевыхСловПроцедуры.Добавить("EndProcedure");
	
	СтруктураПараметров.Вставить("МассивКлючевыхСловФункции", Новый Массив);
	СтруктураПараметров.МассивКлючевыхСловФункции.Добавить("КонецФункции");
	СтруктураПараметров.МассивКлючевыхСловФункции.Добавить("EndFunction");
	
	СтруктураПараметров.Вставить("РазделителиСлов", Новый Массив);
	СтруктураПараметров.РазделителиСлов.Добавить(" ");	
	СтруктураПараметров.РазделителиСлов.Добавить("(");
	СтруктураПараметров.РазделителиСлов.Добавить(")");
	СтруктураПараметров.РазделителиСлов.Добавить(";");
	СтруктураПараметров.РазделителиСлов.Добавить(",");
	СтруктураПараметров.РазделителиСлов.Добавить(".");
	СтруктураПараметров.РазделителиСлов.Добавить("""");
	СтруктураПараметров.РазделителиСлов.Добавить("'");
	СтруктураПараметров.РазделителиСлов.Добавить("|");	
	
	Возврат  СтруктураПараметров;
	
КонецФункции	

Процедура СобратьОсновнуюОбласть(СтруктураПараметров)
	
	ОсновнаяОбласть = СтруктураПараметров.РазбираемыйТекст;
	
	Для Каждого ОбластьРезультата из СтруктураПараметров.Области Цикл 
		ОсновнаяОбласть = СтрЗаменить(ОсновнаяОбласть, ОбластьРезультата.Значение, "");
	КонецЦикла;		
	СтруктураПараметров.Области.Вставить("ОсновнойТекст", ОсновнаяОбласть);
	
КонецПроцедуры	

Процедура РазобратьСтроку(АнализируемаяСтрока, СтруктураПараметров)
	
	БуферСтроки = "";
	Для НомерСимвола = 1 по СтрДлина(АнализируемаяСтрока) + 2 Цикл 
		ТекущийСимвол = Сред(АнализируемаяСтрока + " ", НомерСимвола, 1); 
		
		ПредПоследнийБуферСтроки = БуферСтроки;
		БуферСтроки = БуферСтроки + ТекущийСимвол;
		
		Если СтрЗаканчиваетсяНа(БуферСтроки,"//") Тогда 
			ДобавитьТекстВОбласть(СтруктураПараметров, АнализируемаяСтрока);
			Прервать; //дальше все закоментированно
		КонецЕсли;
		
		Если СтроковыеФункцииКлиентСервер.СтрокаСодержитСловоИзМассива(БуферСтроки, СтруктураПараметров.РазделителиСлов) = Ложь Тогда 
			Продолжить;
		КонецЕсли;
		БуферСтроки = "";
		
		
		Если СтруктураПараметров.Режим = "ПоискНачалаМетода" Тогда 
			
			
			НомерВМассивеСлов = СтруктураПараметров.ТекущийМассивКлючевыхСтрок.Найти(ПредПоследнийБуферСтроки);
			Если НомерВМассивеСлов = 0 или НомерВМассивеСлов = 1 Тогда 
				СтруктураПараметров.Режим = "ПоискИмениФункции";
				
			ИначеЕсли НомерВМассивеСлов = 2 или НомерВМассивеСлов = 3 Тогда 
				СтруктураПараметров.Режим = "ПоискИмениПроцедуры"
				
			Иначе 	
				Продолжить;
			КонецЕсли;
			
			
		ИначеЕсли СтруктураПараметров.Режим = "ПоискИмениПроцедуры" 
			или СтруктураПараметров.Режим = "ПоискИмениФункции" Тогда 
			
			
			Если СтруктураПараметров.Области.Свойство(ПредПоследнийБуферСтроки) Тогда 
				ВызватьИсключение "Ошибка разбора модуля. Получены повторяющиеся имена областей. " + ПредПоследнийБуферСтроки;
			КонецЕсли;
			
			СтруктураПараметров.ИмяОбласти = ПредПоследнийБуферСтроки;
			
			ДобавитьКоментарийПередМетодом(СтруктураПараметров);		
			ДобавитьТекстВОбласть(СтруктураПараметров, АнализируемаяСтрока);
			
			
			Если СтруктураПараметров.Режим = "ПоискИмениПроцедуры" Тогда 
				СтруктураПараметров.ТекущийМассивКлючевыхСтрок = СтруктураПараметров.МассивКлючевыхСловПроцедуры;
				
			ИначеЕсли СтруктураПараметров.Режим = "ПоискИмениФункции" Тогда  	
				СтруктураПараметров.ТекущийМассивКлючевыхСтрок = СтруктураПараметров.МассивКлючевыхСловФункции;
				
			КонецЕсли; 
			
			СтруктураПараметров.Режим	= "ПоискКонцаМетода";
			
			
			//Коментарий от перед методом тоже часть метода 
			
			
		ИначеЕсли СтруктураПараметров.Режим	= "ПоискКонцаМетода" Тогда 
			
			Если СтруктураПараметров.ТекущийМассивКлючевыхСтрок.Найти(ПредПоследнийБуферСтроки) = Неопределено Тогда 
				Продолжить;
			КонецЕсли;
			
			ДобавитьТекстВОбласть(СтруктураПараметров, АнализируемаяСтрока);
			
			СтруктураПараметров.ТекущийМассивКлючевыхСтрок = СтруктураПараметров.МассивКлючевыхСловПоискаНачала;
			СтруктураПараметров.ИмяОбласти = "";
			СтруктураПараметров.Режим = "ПоискНачалаМетода";
			
			//Коментарий от конц до конца строки тоже относится
			
		КонецЕсли;	
		
	КонецЦикла;	
	
	
КонецПроцедуры	

Процедура ДобавитьКоментарийПередМетодом(СтруктураПараметров)
	
	МассивКоментариев = Новый Массив;
	Для Н = 1 по СтруктураПараметров.НомерСтроки + 1 Цикл 
		ПроверяемаяСтрока = СтруктураПараметров.НомерСтроки - Н;
		СтрокаДляПроверки = СтрПолучитьСтроку(СтруктураПараметров.РазбираемыйТекст, ПроверяемаяСтрока);
		Если СтрНачинаетсяС(СокрП(СтрокаДляПроверки),"//") Тогда 
			МассивКоментариев.Добавить(СтрокаДляПроверки);
			Продолжить;
		КонецЕсли;
		Прервать;
	КонецЦикла;	
	
	Если не ЗначениеЗаполнено(МассивКоментариев) Тогда 
		Возврат;
	КонецЕсли;	
	
	МассивКоментариев = ОбщегоНазначенияКлиентСервер.МассивВОбратномПорядке(МассивКоментариев);
	ДобавитьТекстВОбласть(СтруктураПараметров, СтрСоединить(МассивКоментариев, Символы.ПС));	
	
	
КонецПроцедуры	

Процедура ДобавитьТекстВОбласть(СтруктураПараметров, Текст)
	
	Если не ЗначениеЗаполнено(СтруктураПараметров.ИмяОбласти) Тогда 
		Возврат;
	КонецЕсли;
	
	Если СтруктураПараметров.Области.Свойство(СтруктураПараметров.ИмяОбласти) = Ложь Тогда 
		СтруктураПараметров.Области.Вставить(СтруктураПараметров.ИмяОбласти, "");
	КонецЕсли;	
	
	ТекстОбласти = СтруктураПараметров.Области[СтруктураПараметров.ИмяОбласти];
	
	ТекстОбласти = ТекстОбласти + ?(ЗначениеЗаполнено(ТекстОбласти),Символы.ПС,"") + Текст;
	
	СтруктураПараметров.Области[СтруктураПараметров.ИмяОбласти] = ТекстОбласти;
	
КонецПроцедуры	

//Разделение текста на области
///////////////////////////////////////////////////////////////////////////////////////////////////