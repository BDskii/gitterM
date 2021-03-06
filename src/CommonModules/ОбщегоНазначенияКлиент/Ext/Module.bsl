﻿////////////////////////////////////////////////////////////////////////////////
// Методы для работы с асинхронными вызовами универсальные

// Процедура - Подключить расширениеработы с файлами асинхронно - выполняет асинхронное подключение расширения работы с файлами и устаноку его в случае необходимости 
// результат работы возвращается путем вызова ОписаниеОповещения из ДополнительныеПараметры.ОбработкаЗавершения и передачей в результат одного из трех значений "Подключено", "НеУдалосьПодключить", "ОтказОтУстановки"
//
// Параметры:
//  Результат				 - Произвольный - служебный 
//  ДополнительныеПараметры	 - Структура - скорее всего нужно передать что-то типа этого Новый Структура("ОбработкаЗавершения",ОписаниеОповещения)
//
Процедура ПодключитьРасширениеРаботыСФайламиАсинхронно(Результат = Неопределено, ДополнительныеПараметры) Экспорт 
	
	Если Не ДополнительныеПараметры.Свойство("Этап") Тогда 
		
		ДополнительныеПараметры.Вставить("Этап","Начало");
		
	КонецЕсли; 
	
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПодключитьРасширениеРаботыСФайламиАсинхронно", ОбщегоНазначенияКлиент, ДополнительныеПараметры);
	
	Если ЭтапПереопределен(ДополнительныеПараметры, ОписаниеОповещения) Тогда 
		Возврат;
	КонецЕсли;	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Если ДополнительныеПараметры.Этап = "Начало" Тогда 
		
		ДополнительныеПараметры.Вставить("БылаУстановка",Ложь);
		
		ДополнительныеПараметры.Этап = "Подключение";
		ВыполнитьОбработкуОповещения(ОписаниеОповещения);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "Подключение" Тогда 
		
		ДополнительныеПараметры.Этап = "ПослеПодключения";
		НачатьПодключениеРасширенияРаботыСФайлами(ОписаниеОповещения);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПодключения" Тогда 
		Если Результат = Истина Тогда 
			ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения,"Подключено");
			
		Иначе 
			Если ДополнительныеПараметры.БылаУстановка Или ПолучитьЗначениеПараметраСеанса("НеПредлагатьУстановкуРасширенияРаботыСФайламиВТеченииСеанса") Тогда 
				ДополнительныеПараметры.Этап = "Конец";
				ВыполнитьОбработкуОповещения(ОписаниеОповещения,"НеУдалосьПодключить");
				
			Иначе 	
				ДополнительныеПараметры.Этап = "ПослеВопроса";
				ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Установить расширение для работы с файлами?'"), РежимДиалогаВопрос.ДаНет,,КодВозвратаДиалога.Да);
				
			КонецЕсли;
			
		КонецЕсли;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеВопроса" Тогда 
		УстановитьЗначениеПараметраСеанса("НеПредлагатьУстановкуРасширенияРаботыСФайламиВТеченииСеанса", Истина);  //либо пользователь отказался и не стоит его вопросами мучать либо он согласился и оно поставится или не поставится но всеравно новые вопросы не нужны

		Если Результат = КодВозвратаДиалога.Да Тогда 
			ДополнительныеПараметры.Этап = "ПослеУстановки";
			
			ОписаниеКонвертора = Новый ОписаниеОповещения("КонвертерВызоваОбработкиОповещения1в2", ОбщегоНазначенияКлиент,Новый Структура("ОбработкаЗавершения",ОписаниеОповещения));
			НачатьУстановкуРасширенияРаботыСФайлами(ОписаниеКонвертора);
			
		Иначе 
						ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения,"ОтказОтУстановки");
			
		КонецЕсли;	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеУстановки" Тогда 
			
		ДополнительныеПараметры.БылаУстановка = Истина;
		ДополнительныеПараметры.Этап = "Подключение";
		ВыполнитьОбработкуОповещения(ОписаниеОповещения);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "Конец" Тогда 
		
		Если ДополнительныеПараметры.Свойство("ОбработкаЗавершения") Тогда 
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Результат);
		КонецЕсли;	
		
	КонецЕсли; 
	
КонецПроцедуры	

// Процедура - Помещение файла асинхронно
// выполняет помещение файла во временное хранилище
//
// возвращает струтуру с полями Имя,Хранение или неопределено если получить файл не удалось
//
// на входе ожидается структура с полями 
//	Этап - строка - обязательное - текущий этап для запуска "Начало"
//	УникальныйИдентификаторФормы - УникальныйИдентификатор - обязательное - уникальный идентификатор формы для хранения данных см НачатьПомещениеФайлов
//	ОписаниеДиалога - структура - содержит значения для установки в Диалог выбора состав полей смотреть в ДиалогВыбораФайла
//	ОбработкаЗавершения - ОписаниеОповещения - вызывается поле выполнения процедуры и возвращается 
//	ПереопределениеЭтапов - Структура - используется для переопределения отдельных этапов процесса для подробностей см ЭтапПереопределен  
//
// Параметры:
//  Результат				 - Произвольный - служебный
//  ДополнительныеПараметры	 - Структура - 
//
Процедура ЗагрузкаФайлаАсинхронно(Результат, ДополнительныеПараметры) Экспорт 
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузкаФайлаАсинхронно", ОбщегоНазначенияКлиент, ДополнительныеПараметры);
	
	Если ЭтапПереопределен(ДополнительныеПараметры, ОписаниеОповещения) Тогда 
		Возврат;
	КонецЕсли;	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Если ДополнительныеПараметры.Этап = "Начало" Тогда 
		
		ДополнительныеПараметры.Этап = "ПослеПодключения";
		ПодключитьРасширениеРаботыСФайламиАсинхронно(,Новый Структура("ОбработкаЗавершения",ОписаниеОповещения));
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПодключения" Тогда 
		РасширениеПодключено = Результат = "Подключено";
		
		Если РасширениеПодключено Тогда
			ДополнительныеПараметры.Этап = "ЗагрузкаСРасширением";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения);
			
		Иначе
			ДополнительныеПараметры.Этап = "ЗагрузкаБезРасширения";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения);
			
		КонецЕсли;	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ЗагрузкаСРасширением" Тогда 
		
		
		ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
		Если ДополнительныеПараметры.Свойство("ОписаниеДиалога") Тогда 
			ЗаполнитьЗначенияСвойств(ДиалогВыбораФайла, ДополнительныеПараметры.ОписаниеДиалога);
		КонецЕсли;
		
		ДополнительныеПараметры.Этап = "ПослеПомещенияФайлов"; 
		НачатьПомещениеФайлов(ОписаниеОповещения, ,ДиалогВыбораФайла, Истина, ДополнительныеПараметры.УникальныйИдентификаторФормы);
		
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПомещенияФайлов" Тогда 
		Если Результат = Неопределено Тогда 
			ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения, Неопределено);
			Возврат;
			
		КонецЕсли;	                               
		
		ВозвращаемоеЗначение = новый Массив;
		Для Каждого ОписаниеПереданногоФайла из Результат Цикл 
			ВозвращаемоеЗначение.Добавить(Новый Структура("Имя,Хранение", ОписаниеПереданногоФайла.Имя, ОписаниеПереданногоФайла.Хранение));
		КонецЦикла;	
		
		ДополнительныеПараметры.Этап = "Конец";
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, ВозвращаемоеЗначение);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ЗагрузкаБезРасширения" Тогда 
		
		
		
		ДополнительныеПараметры.Этап = "ПослеПомещениеФайла";
		ОписаниеКонвертора = Новый ОписаниеОповещения("КонвертерВызоваОбработкиОповещения4в2", ОбщегоНазначенияКлиент,Новый Структура("ОбработкаЗавершения",ОписаниеОповещения));
		
		НачатьПомещениеФайла(ОписаниеКонвертора, , , Истина, ДополнительныеПараметры.УникальныйИдентификаторФормы); 
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПомещениеФайла" Тогда 
		Если Результат.Результат1 = Ложь Тогда //пользователь отказался
			ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения, Неопределено);
			Возврат;
		КонецЕсли;	
		
		ВозвращаемоеЗначение = Новый Массив;
		ВозвращаемоеЗначение.Добавить(Новый Структура("Имя,Хранение", Результат.Результат3, Результат.Результат2));
		
		ДополнительныеПараметры.Этап = "Конец";
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, ВозвращаемоеЗначение);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "Конец" Тогда 
		
		Если ДополнительныеПараметры.Свойство("ОбработкаЗавершения") Тогда 
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Результат);
		КонецЕсли;	
	КонецЕсли; 
	
КонецПроцедуры	

// Процедура - Сохранение файлов асинхронно
// выполняет сохранение файлов на машине клиента 
//
// возвращает струтуру с полями 
//	Успех - булево - успешность сохранения 
//	Ошибка - описание ошибки только при успех = ложь
//	Детали - массив структур с полями Имя,Хранение только при успех = истина
//
// на входе ожидается структура с полями 
//	Этап - строка - обязательное - текущий этап для запуска "Начало"
//	ПолучаемыеФайлы - массив - обязательное - массив объектов ОписаниеПередаваемогоФайла 
//	ОписаниеДиалога - структура - содержит значения для установки в Диалог выбора состав полей смотреть в ДиалогВыбораФайла
//	ОбработкаЗавершения - ОписаниеОповещения - вызывается поле выполнения процедуры и возвращается 
//	ПереопределениеЭтапов - Структура - используется для переопределения отдельных этапов процесса для подробностей см ЭтапПереопределен 
//
// Параметры:
//  Результат				 - Произвольный - служебный
//  ДополнительныеПараметры	 - Структура - 
//
Процедура СохранениеФайловАсинхронно(Результат, ДополнительныеПараметры) Экспорт 
	
	ОписаниеОповещения = Новый ОписаниеОповещения("СохранениеФайловАсинхронно", ОбщегоНазначенияКлиент, ДополнительныеПараметры);
	
	Если ЭтапПереопределен(ДополнительныеПараметры, ОписаниеОповещения) Тогда 
		Возврат;
	КонецЕсли;	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Если ДополнительныеПараметры.Этап = "Начало" Тогда 
		
		Если Не ЗначениеЗаполнено(ДополнительныеПараметры.ПолучаемыеФайлы) Тогда
			ВызватьИсключение НСтр("ru = 'Не получены описания файлов.'");
		КонецЕсли;
		
		ДополнительныеПараметры.Этап = "ПослеПодключения";
		ПодключитьРасширениеРаботыСФайламиАсинхронно(,Новый Структура("ОбработкаЗавершения",ОписаниеОповещения));
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПодключения" Тогда 
		РасширениеПодключено = Результат = "Подключено";
		Если РасширениеПодключено Тогда 
			
			ДополнительныеПараметры.Этап = "СохранениеСРасширением";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения);
			
		Иначе 
			
			ДополнительныеПараметры.Этап = "СохранениеБезРасширения";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения);
			
		КонецЕсли;	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "СохранениеСРасширением" Тогда 
		
		
		Если ДополнительныеПараметры.ПолучаемыеФайлы.Количество() = 1 Тогда  
			ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
		Иначе 
			ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
		КонецЕсли;
		
		Если ДополнительныеПараметры.Свойство("ОписаниеДиалога") Тогда 
			ЗаполнитьЗначенияСвойств(ДиалогВыбораФайла, ДополнительныеПараметры.ОписаниеДиалога);
		КонецЕсли;
		
		ДополнительныеПараметры.Этап = "ПослеПолученияФайлов"; 
		НачатьПолучениеФайлов(ОписаниеОповещения, ДополнительныеПараметры.ПолучаемыеФайлы ,ДиалогВыбораФайла, Истина);
		
		
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "ПослеПолученияФайлов" Тогда 
		Если Результат = Неопределено Тогда 
			
			ВозвращаемоеЗначение = Новый Структура;
			ВозвращаемоеЗначение.Вставить("Успех",Ложь);
			ВозвращаемоеЗначение.Вставить("Ошибка","ПользовательОтказался");
		Иначе 
			
			ВозвращаемоеЗначение = Новый Структура;
			ВозвращаемоеЗначение.Вставить("Успех",Истина);
			ВозвращаемоеЗначение.Вставить("Детали",Новый Массив);
			Для Каждого СтрокаРезультата из Результат Цикл
				ВозвращаемоеЗначение.Детали.Добавить(Новый Структура("Имя,Хранение",СтрокаРезультата.Имя,СтрокаРезультата.Хранение));
			КонецЦикла;	
			
		КонецЕсли;
		
		
		ДополнительныеПараметры.Этап = "Конец";
		ВыполнитьОбработкуОповещения(ОписаниеОповещения, ВозвращаемоеЗначение);
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "СохранениеБезРасширения" Тогда 
		
		Если ДополнительныеПараметры.ПолучаемыеФайлы.Количество() = 1 Тогда  
			
			ПолучаемыйФайл = ДополнительныеПараметры.ПолучаемыеФайлы[0];
			ПолучитьФайл(ПолучаемыйФайл.Хранение, ПолучаемыйФайл.Имя, Истина);
			
			ВозвращаемоеЗначение = Новый Структура;
			ВозвращаемоеЗначение.Вставить("Успех",Истина);
			ВозвращаемоеЗначение.Вставить("Детали",Новый Массив);
			ВозвращаемоеЗначение.Детали.Добавить(Новый Структура("Имя,Хранение","", ПолучаемыйФайл.Хранение));
			ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения, ВозвращаемоеЗначение);
			
		Иначе 
			ВозвращаемоеЗначение = Новый Структура;
			ВозвращаемоеЗначение.Вставить("Успех",Истина);
			ВозвращаемоеЗначение.Вставить("Детали",Новый Массив);
			
			Для Каждого ПолучаемыйФайл из ДополнительныеПараметры.ПолучаемыеФайлы Цикл 
				ПолучитьФайл(ПолучаемыйФайл.Хранение, ПолучаемыйФайл.Имя, Истина);
				ВозвращаемоеЗначение.Детали.Добавить(Новый Структура("Имя,Хранение","", ПолучаемыйФайл.Хранение));
			КонецЦикла;
			ДополнительныеПараметры.Этап = "Конец";
			ВыполнитьОбработкуОповещения(ОписаниеОповещения, ВозвращаемоеЗначение);
			
		КонецЕсли;	
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	ИначеЕсли ДополнительныеПараметры.Этап = "Конец" Тогда 
		
		Если ДополнительныеПараметры.Свойство("ОбработкаЗавершения") Тогда 
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Результат);
		КонецЕсли;	
	КонецЕсли; 
	
КонецПроцедуры	

// Процедура - Конвертер вызова обработки оповещения4в2
//  преобразует результат вызова обработки оповещения с 4 параметрами в вызов с двумя
//  результат отдается в ДополнительныеПараметры.ОбработкаЗавершения в виде структуры с полями Результат, Результат2 и Результат3
//  может использоваться для принятия результата НачатьПомещениеФайла или прочих методов отдающих 4 параметра
//
// Параметры:
//  Результат1				 - Произвольный	 - служебный
//  Результат2				 - Произвольный	 - служебный
//  Результат3				 - Произвольный	 - служебный				 - 
//  ДополнительныеПараметры	 - Структура	 - чтото типа этого Новый Структура("ОбработкаЗавершения",ОписаниеОповещения)
//
Процедура КонвертерВызоваОбработкиОповещения4в2(Результат1, Результат2, Результат3, ДополнительныеПараметры) Экспорт 
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Новый Структура("Результат1,Результат2,Результат3",Результат1, Результат2, Результат3));
	
КонецПроцедуры	

// Процедура - Конвертер вызова обработки оповещения3в2
//  преобразует результат вызова обработки оповещения с 3 параметрами в вызов с двумя
//  результат отдается в ДополнительныеПараметры.ОбработкаЗавершения в виде структуры с полями Результат и Результат2 
//  может использоваться для принятия результата ПоказатьВыборДействия или прочих методов отдающих 3 параметра
//
// Параметры:
//  Результат1				 - Произвольный	 - служебный
//  Результат2				 - Произвольный	 - служебный
//  ДополнительныеПараметры	 - Структура	 - чтото типа этого Новый Структура("ОбработкаЗавершения",ОписаниеОповещения)
//
Процедура КонвертерВызоваОбработкиОповещения3в2(Результат1, Результат2, ДополнительныеПараметры) Экспорт 
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Новый Структура("Результат1,Результат2",Результат1, Результат2));
	
КонецПроцедуры	


// Процедура - Конвертер вызова обработки оповещения1в2
//  преобразует результат вызова обработки оповещения с 1 параметрами в вызов с двумя
//
// Параметры:
//  ДополнительныеПараметры	 - Структура	 - чтото типа этого Новый Структура("ОбработкаЗавершения",ОписаниеОповещения)
//
Процедура КонвертерВызоваОбработкиОповещения1в2(ДополнительныеПараметры) Экспорт 
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОбработкаЗавершения, Неопределено);
	
КонецПроцедуры	

Функция ЭтапПереопределен(ДополнительныеПараметры,ОписаниеОповещения) Экспорт 
	//в случае если нужно поменять поведение одного из этапов можно его переопределить
	Если Не ДополнительныеПараметры.Свойство("ПереопределениеЭтапов") Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	Если не ДополнительныеПараметры.ПереопределениеЭтапов.Свойство(ДополнительныеПараметры.Этап) Тогда
		Возврат Ложь;
	КонецЕсли;	
	
	ПереопределенноеОписаниеОповещения = ДополнительныеПараметры.ПереопределениеЭтапов[ДополнительныеПараметры.Этап];
	ПереопределенноеОписаниеОповещения.ДополнительныеПараметры.Вставить("ПереопределямемоеОповещение", ОписаниеОповещения);
	
	ВыполнитьОбработкуОповещения(ПереопределенноеОписаниеОповещения);
	Возврат Истина;
КонецФункции	

Процедура ПроцедураКотораяНичегоНеДелает(Результат, ДополнительныеПараметры) Экспорт
	
	а = 1;
	а = а;
	//нужна для приема управления после НачатьЗапускПриложения в случае если последующая обработка не требуется
	
КонецПроцедуры	


Функция ПолучитьЗначениеПараметраСеанса(Имя) Экспорт 
	
	Возврат ОбщегоНазначенияКлиентПовтИсп.ПолучитьЗначениеПараметраСеанса(Имя);
	
КонецФункции	

Процедура УстановитьЗначениеПараметраСеанса(Имя, Значение) Экспорт 
	
	ОбщегоНазначенияПривилегированныйСервер.УстановитьЗначениеПараметраСеанса(Имя, Значение);
	ОбновитьПовторноИспользуемыеЗначения();
	
КонецПроцедуры	

