#Область ОбработчикиСобытий

Процедура ПередНачаломРаботыСистемы(Отказ)

	Если ИТК_ЗадачиТестированияВызовСервера.ЭтоПолноправныйПользователь() Тогда
		КлиентскоеПриложение.УстановитьРежимОсновногоОкна(РежимОсновногоОкнаКлиентскогоПриложения.Обычный);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти