
call cmake -G "Ninja" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_BUILD_TYPE=Release -D LIBRARY_INC=%LIBRARY_INC% .
if errorlevel 1 exit 1

call cmake --build . --target install --config Release
if errorlevel 1 exit 1

set "PATH=%LIBRARY_BIN%;%PATH%"
rem Match the upstream Windows exclusion of the CRT closed-descriptor test.
powershell -NoProfile -Command "$p='tests/test_util_file.expected'; $s=[IO.File]::ReadAllText($p); $s=[regex]::Replace($s, '(?m)^OK: json_object_from_fd\(closed_fd\)[^\r\n]*\r?\n', ''); [IO.File]::WriteAllText($p,$s,[Text.UTF8Encoding]::new($false))"
if errorlevel 1 exit /b 1
set "VERBOSE=1"
ctest -C Release --output-on-failure
if not errorlevel 1 exit /b 0
rem Diagnose the sole remaining file-I/O test without suppressing failure.
dumpbin /imports tests\test_util_file.exe
dumpbin /exports tests\json-c.dll
pushd tests\testSubDir\test_util_file.test
powershell -NoProfile -Command "& '..\..\test_util_file.exe' '..\..'; Write-Output ('Native exit: ' + $LASTEXITCODE)"
popd
set "JSONC_TEST_TRACE=1"
ctest -C Release -R test_util_file --output-on-failure
exit /b 1
