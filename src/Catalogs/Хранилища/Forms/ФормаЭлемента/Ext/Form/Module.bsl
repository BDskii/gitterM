﻿
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	НевыгруженныеВерсии.Параметры.УстановитьЗначениеПараметра("Владелец" , Объект.Ссылка);
	СписокПроверокАПК.Параметры.УстановитьЗначениеПараметра("Владелец" , Объект.Ссылка);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	НевыгруженныеВерсии.Параметры.УстановитьЗначениеПараметра("Владелец" , Объект.Ссылка);
	СписокПроверокАПК.Параметры.УстановитьЗначениеПараметра("Владелец" , Объект.Ссылка);
КонецПроцедуры

&НаКлиенте
Процедура ЛокальныйРепозиторийАдресОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ЗапуститьПриложение(Объект.ЛокальныйРепозиторийАдрес);
	
КонецПроцедуры
