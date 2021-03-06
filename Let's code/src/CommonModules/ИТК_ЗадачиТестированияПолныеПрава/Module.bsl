#Область ПрограммныйИнтерфейс

// Функция выполняет скрипт OneScript с помощью PowerShell
// Параметры:
//		Скрипт - Строка - код для выполнения
// Возвращаемое значение:
//		Строка - Результат выполнения скрипта  
//
Функция ВыполнитьСкрипт(Скрипт) Экспорт
	
	// Сохраняем скрипт OneScript
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("os");
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(Скрипт);
	ТекстовыйДокумент.Записать(ИмяВременногоФайла);
	
	// Задаем таймаут выполнения команды в секундах
	ТаймаутВыполненияКомандыСек = 5;
	
	// Структура результата выполнения команды
	РезультатВыполненияСкрипта = Новый Структура;
	РезультатВыполненияСкрипта.Вставить("Вывод", "");
	РезультатВыполненияСкрипта.Вставить("Ошибки", "");
	
	// Вспомогательные переменные
	ТекстСкриптаДляВыполнения = "";
	ВременныйФайлСкрипта = "";
	ВременныйФайлРезультат = "";

	КомандаВыполнение = СтрШаблон("oscript ""%1""", ИмяВременногоФайла);
			
	// Подготавливаем скрипт PowerShell для запуска,
	// но для запуска используем BAT'ник, чтобы сохранить
	// условия безопасного запуска через WScript.Shell
	#Область ПодготовкаСкриптаPowerShell
	
	ПутьКПриложению = ПутьКИсполняемомуФайлуPowerShell();
	ВременныйФайлСкрипта = ПолучитьИмяВременногоФайла("bat");
	ВременныйФайлСкриптаPowerShell = ПолучитьИмяВременногоФайла("ps1");
	ВременныйФайлРезультат = ПолучитьИмяВременногоФайла("log");
	
	ТекстСкриптаДляВыполнения = СтрШаблон("%1 -executionpolicy bypass -File ""%2"" > ""%3""",
									ПутьКПриложению,
									ВременныйФайлСкриптаPowerShell,
									ВременныйФайлРезультат);
 
	ТекстСкриптаPowerShell = КомандаВыполнение;
	
	ЗаписьТекстаСкриптаPowerShell = Новый ТекстовыйДокумент;
	ЗаписьТекстаСкриптаPowerShell.УстановитьТекст(ТекстСкриптаPowerShell);
	ЗаписьТекстаСкриптаPowerShell.Записать(ВременныйФайлСкриптаPowerShell, КодировкаТекста.UTF8);
	
	ЗаписатьФайлВФорматеУниверсальнойКодировки(ТекстСкриптаДляВыполнения, ВременныйФайлСкрипта); 	
	ТекстСкриптаДляВыполнения = ВременныйФайлСкрипта;
	
	#КонецОбласти
	
	НачалоВыполненияКоманды = ТекущаяДатаСеанса();
	ЗавершениеВыполненияКоманды = НачалоВыполненияКоманды + ТаймаутВыполненияКомандыСек;
	
	// Инициализация объекта WScript.Shell
	Попытка		
		objShell = Новый COMОбъект("WScript.Shell");		
	Исключение		
		ВызватьИсключение 
			"Не удалось инициализировать WScript.Shell.
			|Подробнее:
			|" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());		
	КонецПопытки;
	
	// Выполнение команды
	objWshScriptExec = objShell.Exec(ТекстСкриптаДляВыполнения);
	
	// Проверка истечения времени таймаута
	КомандаЗавершенаПоТаймауту = Ложь;
	Пока objWshScriptExec.Status = 0 Цикл		
		Если ЗначениеЗаполнено(ТаймаутВыполненияКомандыСек) Тогда			
			Если ЗавершениеВыполненияКоманды <= ТекущаяДатаСеанса() Тогда			
				КомандаЗавершенаПоТаймауту = Истина;			
				Прервать;				
			КонецЕсли;			
		Иначе			
			Прервать;			
		КонецЕсли;		
	КонецЦикла;
		
	// "Насильно" завершаем процесс по завершению работы
	// и "уничтожаем" COM-объект
	Попытка		
		objWshScriptExec.Terminate();
		objWshScriptExec = Неопределено;		
	Исключение		
		objWshScriptExec = Неопределено;		
	КонецПопытки;	
	objShell = Неопределено;
	
	// Если команда завершена по таймауту - вызываем исключение.
	// Иначе читаем результат и удаляем временные файлы
	Если КомандаЗавершенаПоТаймауту Тогда		
		Возврат Ложь;		
	Иначе	
		
		// Если ошибок при выполнении нет, то получаем строку вывода результата
		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.Прочитать(ВременныйФайлРезультат, "cp866");
		ТекстРезультат = ТекстовыйДокумент.ПолучитьТекст();
		
		УдалитьФайлы(ВременныйФайлСкрипта);
		УдалитьФайлы(ВременныйФайлСкриптаPowerShell);
		УдалитьФайлы(ИмяВременногоФайла);
		УдалитьФайлы(ВременныйФайлРезультат);
						
		Возврат ТекстРезультат;
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции 

Процедура ЗаписатьФайлВФорматеУниверсальнойКодировки(текст, полноеИмяФайла)
	
	КоличествоСимволовДляОтсечения = 4;
	
    // записываем в файл с символами BOM в начале файле	
    ТекстовыйФайлUTF8_Bom = Новый ТекстовыйДокумент();
    ТекстовыйФайлUTF8_Bom.ДобавитьСтроку(текст);
    ТекстовыйФайлUTF8_Bom.Записать(полноеИмяФайла, "UTF-8");
	
    // открываем файл и считываем символы после символов BOM
    Данные = Новый ДвоичныеДанные(полноеИмяФайла);
    Строка64 = Base64Строка(Данные);
    Строка64 = Прав(Строка64, СтрДлина(Строка64) - КоличествоСимволовДляОтсечения);
    ДанныеНаЗапись = Base64Значение(Строка64);
    ДанныеНаЗапись.Записать(полноеИмяФайла); // записываем
     	
КонецПроцедуры
 
Функция ПутьКИсполняемомуФайлуPowerShell()
	
	Возврат ИТК_ОбщегоНазначенияПовтИсп.ПутьКИсполняемомуФайлуPowerShell();
	
КонецФункции

#КонецОбласти