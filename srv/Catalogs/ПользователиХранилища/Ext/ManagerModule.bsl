﻿
Функция ПолучитьПоНаименованию(Наименование, Хранилище) Экспорт
	
	Пользователь = НайтиПоНаименованию(Наименование, Истина,, Хранилище);
	Если Не ЗначениеЗаполнено(Пользователь) Тогда
		ВызватьИсключение "Не удалось получить пользователя по наименованию " + Наименование;
	КонецЕсли;
	
	Возврат Пользователь;
	
КонецФункции