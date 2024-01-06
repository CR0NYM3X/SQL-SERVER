@echo off
setlocal enabledelayedexpansion

set "nueva_ruta="
set "archivo=rutas.txt"

set "drives="

for /f "skip=1 delims=" %%a in ('wmic logicaldisk get caption') do (
    for %%b in (%%a) do (
        set "drive=%%b"
        if "!drive:~1,1!"==":" (
            set "drives=!drives!,!drive:~0,1!"
        )
    )
)


set drives=%drives:~1%
set "letras=%drives%"

echo.
echo "Letras de unidad de disco duro conectados"
echo.

echo %letras%
rem set "letras=A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"

if not exist %archivo% (
    echo El archivo %archivo% no existe.
    exit /b
)

echo.
echo verificando si las rutas existen ......
echo.

for /f "tokens=* delims=" %%a in (%archivo%) do (
    set "ruta=%%a"
    if not exist "!ruta!" (
rem             echo La ruta "!ruta!" no existe.
		echo "!ruta!" >> RUTAS_NO_EXISTEN.TXT
    ) 
rem	else (
rem        echo La ruta "!ruta!"  existe.
rem	       echo "!ruta!" >> RUTAS_SI_EXISTEN.TXT   )
)


set "archivo_NOEXISTENTES=RUTAS_NO_EXISTEN.TXT"

echo.
echo "Aplicando metodos de busqueda en las rutas no encontradas ....."
echo.
set "ttt="
for /f "tokens=* delims=" %%j in (%archivo_NOEXISTENTES%) do (
rem    echo "aaaa --- !%%j:~2!"
	
	for %%l in ("%letras:,=" "%") do (
		set "nueva_ruta=%%j"
		set ttt=!nueva_ruta:~1,1!
		if not "%%~l"=="!ttt!" (
			set nueva_ruta="%%~l!nueva_ruta:~2! 
			echo !nueva_ruta! >> nueva_rutas.txt
		)

	 )		
	
)   

set "archivo=nueva_rutas.txt"

echo.
echo "Buscando posibles rutas....."
echo.

for /f "tokens=* delims=" %%f in (%archivo%) do (
    set "ruta2=%%f"
    if  exist "!ruta2!" (
	echo !ruta2! >> RUTAS_ENCONTRADAS.TXT
     ) 
REM  else (
REM    	echo !ruta2! >> RUTAS_NO_ENCONTRADAS.TXT
REM    )

)


rem del nueva_rutas.txt

echo.
echo Validacion completa.
echo.


pause
