@echo off
:: Установщик голосового ассистента
:: Автоматически устанавливает Python, зависимости и настраивает приложение

set ASSISTANT_DIR=%USERPROFILE%\VCAS
set PYTHON_VERSION=3.10.6
set PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe
set REPO_URL=https://github.com/yourusername/voice-assistant/archive/main.zip

echo Установка голосового ассистента v0.1 ...
echo.

:: Проверка и установка Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python не найден. Устанавливаем Python %PYTHON_VERSION%...
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_URL%', 'python_installer.exe')"
    start /wait python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
    del python_installer.exe
    echo Python успешно установлен.
) else (
    echo Python уже установлен.
)

:: Создание директории для ассистента
if not exist "%ASSISTANT_DIR%" (
    mkdir "%ASSISTANT_DIR%"
    echo Создана директория для ассистента: %ASSISTANT_DIR%
)

:: Загрузка кода ассистента
echo Загрузка кода ассистента...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%REPO_URL%', '%ASSISTANT_DIR%\assistant.zip')"
powershell -Command "Expand-Archive -Path '%ASSISTANT_DIR%\assistant.zip' -DestinationPath '%ASSISTANT_DIR%' -Force"
del "%ASSISTANT_DIR%\assistant.zip"
echo Код ассистента успешно загружен.

:: Создание виртуального окружения
echo Создание виртуального окружения...
cd "%ASSISTANT_DIR%"
python -m venv venv
call "%ASSISTANT_DIR%\venv\Scripts\activate.bat"

:: Установка зависимостей
echo Установка зависимостей...
pip install --upgrade pip
pip install speechrecognition pyttsx3 requests vk-api spotipy pyyaml

:: Создание конфигурационного файла
echo Создание конфигурационного файла...
echo {
echo     "wake_words": ["ассистент", "помощник", "компьютер"],
echo     "app_mapping": {
echo         "браузер": "https://google.com",
echo         "телеграм": "tg://",
echo         "вк": "https://vk.com"
echo     },
echo     "music_priority": ["vk", "yandex", "spotify"],
echo     "api_keys": {
echo         "vk": {"login": "", "password": "", "token": ""},
echo         "spotify": {"client_id": "", "client_secret": ""},
echo         "yandex": {"token": ""}
echo     }
echo } > "%ASSISTANT_DIR%\assistant_config.json"

:: Создание ярлыка для запуска
echo Создание ярлыка для запуска...
echo @echo off > "%ASSISTANT_DIR%\start_assistant.bat"
echo call "%ASSISTANT_DIR%\venv\Scripts\activate.bat" >> "%ASSISTANT_DIR%\start_assistant.bat"
echo python "%ASSISTANT_DIR%\main.py" >> "%ASSISTANT_DIR%\start_assistant.bat"
echo pause >> "%ASSISTANT_DIR%\start_assistant.bat"

:: Создание ярлыка на рабочем столе
echo Создание ярлыка на рабочем столе...
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Voice Assistant.lnk'); $Shortcut.TargetPath = '%ASSISTANT_DIR%\start_assistant.bat'; $Shortcut.WorkingDirectory = '%ASSISTANT_DIR%'; $Shortcut.IconLocation = '%SystemRoot%\System32\SHELL32.dll,3'; $Shortcut.Save()"

echo.
echo Установка завершена успешно!
echo Для запуска ассистента используйте ярлык на рабочем столе.
pause