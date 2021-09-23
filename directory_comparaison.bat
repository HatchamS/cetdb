@echo off
CHCP 65001
SETLOCAL ENABLEDELAYEDEXPANSION

set /p directoryone=Chemin absolu répertoire source 
CALL :numberfile "%directoryone%" , 1
set /a numberfiledirone = %numberfile%



set /p directorytwo=Chemin absolu répertoire cible 
CALL :numberfile "%directorytwo%", 2
set /a numberfiledirtwo= %numberfile%
CALL :dataintegrity "%directoryone%" , "%directorytwo%"




if %numberfiledirone% equ %numberfiledirtwo% (
    echo Le nombre de fichiers est identique.
    
    
) else (
    echo Le nombre de fichiers est différent.
    
    )
pause



EXIT /B %ERRORLEVEL%

:numberfile
set /a numberfile = 0


for /f "delims=" %%a in ('dir /s /b /a:-d "%~1"') DO (
    set /a numberfile+=1
)

echo.
echo Le nombre de fichier pour le répertoire numéro %~2 est %numberfile% 
echo.


EXIT /B 0

:dataintegrity

for /f "delims=" %%a in ('dir /s /b /a:-d "%~1"') do (

	
    set var1=%%a
    
    set token_string=!var1!
    CALL :find_last_loop
    
    (dir /s /b /a:-d "%~2" | findstr /c:"!last!">Nul && (
        for /f "delims=" %%b in ('dir /s /b /a:-d "%~1" ^| findstr /c:"!last!"') DO (
            set pathone=%%b
            for /f "delims=" %%c in ('dir /s /b /a:-d "%~2" ^| findstr /c:"!last!"') DO (
                set pathtwo=%%c
            )
        )
        
        CALL :comparehash "!pathone!" "!pathtwo!"
    ) || Echo Impossible de trouvé "!last!" dans le répertoire ou les sous répertoires cible && echo. )

     
)
EXIT /B 0

:find_last_loop
for /F "tokens=1* delims=\" %%A in ( "%token_string%" ) do (
    set last=%%A
     set token_string=%%B
     goto find_last_loop)
EXIT /B 0

:comparehash
CALL :cleanCertutilfunction "%~1" hashfileone
CALL :cleanCertutilfunction "%~2" hashfiletwo
if !hashfileone! neq !hashfiletwo! (
    echo Les fichiers suivant présente un hash différant :
    echo "%~1"
    echo "%~2"
    echo.
)

 
EXIT /B 0

:cleanCertutilfunction

for /f "skip=1 delims=:" %%b in ('Certutil -hashfile "%~1" MD5') do ( 
    if %%b neq CertUtil ( 
        set %~2=%%b
    ) 
)
EXIT /B 0


