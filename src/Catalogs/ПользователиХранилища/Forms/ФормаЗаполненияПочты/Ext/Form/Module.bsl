﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Для Каждого СтрокаПользователя из Параметры.ПользователиДляЗаполнения Цикл 
		
		НоваяСтрока = ТаблицаПользователей.Добавить();
		НоваяСтрока.Пользователь = СтрокаПользователя.Значение;
		если ЗначениеЗаполнено(НоваяСтрока.Пользователь.Email) Тогда 
			ОбластиЯщика = СтрРазделить(НоваяСтрока.Пользователь.Email,"@");
			Если ЗначениеЗаполнено(ОбластиЯщика) Тогда 			
				НоваяСтрока.Ящик = ОбластиЯщика[0];
			КонецЕсли;
		КонецЕсли;
		
		
	КонецЦикла;		
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	Если не ПроверитьЗаполнение() Тогда 
		Возврат;
	КонецЕсли;
	
	ЗаписатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	
	Для Каждого СтрокаПользователя из ТаблицаПользователей Цикл 
		
		РедактируемыйОбъект = СтрокаПользователя.Пользователь.ПолучитьОбъект();
		РедактируемыйОбъект.Email = СформироватьАдрес(СтрокаПользователя.Ящик, ПочтовыйСервер);
		РедактируемыйОбъект.Записать();
		
	КонецЦикла;
	
КонецПроцедуры


&НаКлиентеНаСервереБезКонтекста
Функция СформироватьАдрес(Ящик, Домен)
	
	Возврат ящик +"@"+ Домен;
	
КонецФункции	


