﻿
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	#Если ТолстыйКлиентОбычноеПриложение Тогда
		Справочники.Хранилища.ЗагрузитьПользователейХранилища(ПараметрКоманды);
	#Иначе
		ЗагрузитьПользователейХранилища(ПараметрКоманды);
	#КонецЕсли
	ПоказатьОповещениеПользователя("Загрузка пользователей",,"Загрузка пользователей из хранилища выполнена успешно. Укажите email для новых пользователей.");
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьПользователейХранилища(Хранилище)
	
	Справочники.Хранилища.ЗагрузитьПользователейХранилища(Хранилище);												
	
КонецПроцедуры