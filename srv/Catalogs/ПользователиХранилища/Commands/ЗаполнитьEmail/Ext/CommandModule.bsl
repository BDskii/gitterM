﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	
	ПользователиДляЗаполнения = Новый СписокЗначений;
	ПользователиДляЗаполнения.ЗагрузитьЗначения(ПараметрКоманды);
	
	ПараметрыФормы = Новый Структура("ПользователиДляЗаполнения", ПользователиДляЗаполнения);
	ОткрытьФорму("Справочник.ПользователиХранилища.Форма.ФормаЗаполненияПочты", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
	
КонецПроцедуры

