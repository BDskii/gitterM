﻿
Функция Параметры( Знач пСсылка ) Экспорт

	структ = Новый Структура;
	
	структ.Вставить( "НаименованиеКонфигурацииВАПК", пСсылка.НаименованиеКонфигурацииВАПК );
	структ.Вставить( "СтрокаСоединения", пСсылка.СтрокаСоединения );
	структ.Вставить( "Пользователь", пСсылка.АПКПользователь );
	структ.Вставить( "Пароль", пСсылка.АПКПароль );
	
	структ.Вставить( "Приложение1С", пСсылка.Владелец.Приложение1С );
	структ.Вставить( "Владелец", пСсылка.Владелец );
	
	Возврат структ;

КонецФункции // Параметры()

Процедура ВыполнитьПроверку(Знач пПроверкаАПК ) Экспорт

	структПараметры = Параметры( пПроверкаАПК );
	
	Хранилище = структПараметры.Владелец;
	
	
	Справочники.Хранилища.УставновитьОтметкуЗанятости(Хранилище, Истина, "Проверка АПК");
	
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	СписокИзменений.Объект КАК ПутьОбъекта,
	               |	СписокИзменений.ТипОбъекта КАК ТипОбъекта,
	               |	СписокИзменений.Версия.Пользователь.ИмяПользователя КАК Ответственный,
	               |	СписокИзменений.Версия.Пользователь.Email КАК АдресЭлектроннойПочты
	               |ИЗ
	               |	РегистрСведений.СписокИзменений КАК СписокИзменений
	               |ГДЕ
	               |	СписокИзменений.Хранилище = &Хранилище
	               |	И НЕ СписокИзменений.Объект = """"";  
	Запрос.УстановитьПараметр("Хранилище", Хранилище );
	
	тз = Запрос.Выполнить().Выгрузить();
	
	имяФайлаОтветственных = ПолучитьИмяВременногоФайла();
	
	ЗначениеВФайл( имяФайлаОтветственных, тз );
	
	стрПараметрЗапуска = "/CЗапускПроверки_" + "КОНФ=" + структПараметры.НаименованиеКонфигурацииВАПК;
	стрПараметрЗапуска = стрПараметрЗапуска + ";";
	стрПараметрЗапуска = стрПараметрЗапуска + "Ответственные=" + имяФайлаОтветственных;
	
	
	ПакетныйРежим.ОбновитьКонфигурациюБазыДанных( Хранилище,
											Хранилище.Приложение1С,
											Хранилище.ТранзитнаяБазаАдрес,
											Хранилище.ТранзитнаяБазаПользователь,
											Хранилище.ТранзитнаяБазаПароль );
	ПакетныйРежим.ЗапуститьВРежимеПредприятияПоСтрокеСоединения( структПараметры.Приложение1С,
																	структПараметры.СтрокаСоединения,
																	структПараметры.Пользователь,
																	структПараметры.Пароль,
																	Истина,
																	стрПараметрЗапуска);
	
																	
	Справочники.Хранилища.УставновитьОтметкуЗанятости(Хранилище, Ложь);

	
	УдалитьФайлы( имяФайлаОтветственных );
	
КонецПроцедуры

