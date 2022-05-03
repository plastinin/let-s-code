#Область СлужебныйПрограммныйИнтерфейс

// Фунция получает путь к исполняемому фалу PowerShell
//
// Возвращаемое значение:
//		Строка - путь к исполняемому файлу
//
Функция ПутьКИсполняемомуФайлуPowerShell() Экспорт    
	
	// BSLLS:UsingHardcodePath-off
	Возврат "%SystemRoot%\System32\WindowsPowerShell\v1.0\PowerShell.exe";
	// BSLLS:UsingHardcodePath-on	
	
КонецФункции       

#КонецОбласти