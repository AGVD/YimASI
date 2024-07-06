 @echo off
 
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
 
:UACPrompt 
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
 
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
 
:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
   @echo OFF
SET CUR_DIR=%~dp0
 
powershell set-ExecutionPolicy Bypass | exit
powershell set-executionpolicy Unrestricted | exit
 
if exist ScriptHookV.dll (
	echo Trying to patch ScriptHookV.dll
) else (
	echo Can not find ScriptHookV.dll
	pause
)
if exist test_scripthook.ps1 (
	del test_scripthook.ps1
)
echo   Add-Type -Language Csharp -TypeDefinition '   >> test_scripthook.ps1
echo   using System.IO;   >> test_scripthook.ps1
echo   using System;    >> test_scripthook.ps1
echo   public class PatcherOnTheGo {    >> test_scripthook.ps1
echo   public static void DoPatch() {    >> test_scripthook.ps1
echo   	string dllname = @"ScriptHookV.dll";   >> test_scripthook.ps1
echo   	var OLDpattern = new byte[] {0x74,0x3A,0x48};    >> test_scripthook.ps1
echo   	var NEWpattern = new byte[] {0xEB,0x3A,0x48};   >> test_scripthook.ps1
echo   	byte[] theFile = File.ReadAllBytes(dllname);   >> test_scripthook.ps1
echo   	int foundOLD = Search(theFile,OLDpattern);   >> test_scripthook.ps1
echo   	int foundNEW = Search(theFile,NEWpattern);   >> test_scripthook.ps1
echo   	Console.WriteLine("Old pattern first byte search result: " + foundOLD);    >> test_scripthook.ps1
echo   	Console.WriteLine("New pattern first byte search result: " + foundNEW);    >> test_scripthook.ps1
echo   		if(foundOLD!=-1){   >> test_scripthook.ps1
echo   			Console.WriteLine("Old byte value result: 0x"+(theFile[foundOLD].ToString("X2"))+" (" + theFile[foundOLD] + ")");    >> test_scripthook.ps1
echo   		}else if(foundNEW!=-1){   >> test_scripthook.ps1
echo   			Console.WriteLine("New byte value result: 0x"+(theFile[foundNEW].ToString("X2"))+" (" + theFile[foundNEW] + ")");   >> test_scripthook.ps1
echo   		}   >> test_scripthook.ps1
echo   		if(foundOLD!=-1){   >> test_scripthook.ps1
echo 				for (int xx = 0; xx ^< NEWpattern.Length; xx++)  >>  test_scripthook.ps1
echo 				{  >>  test_scripthook.ps1
echo 					theFile[foundOLD+xx] = NEWpattern[xx];  >> test_scripthook.ps1
echo 				}  >> test_scripthook.ps1
echo   			Console.WriteLine("Sucesfully patched!");   >> test_scripthook.ps1
echo   			File.WriteAllBytes(dllname, theFile);   >> test_scripthook.ps1
echo   		}else{   >> test_scripthook.ps1
echo   			Console.WriteLine("Already patched!");   >> test_scripthook.ps1
echo   		}   >> test_scripthook.ps1
echo   	}   >> test_scripthook.ps1
echo   	public static int Search(byte[] src, byte[] pattern)   >> test_scripthook.ps1
echo   	{   >> test_scripthook.ps1
echo   		int maxFirstCharSlot = src.Length - pattern.Length + 1;   >> test_scripthook.ps1
echo     for (int i = 0; i ^< maxFirstCharSlot; i++)   >> test_scripthook.ps1
echo   		{   >> test_scripthook.ps1
echo   			if (src[i] != pattern[0]) >> test_scripthook.ps1
echo   				continue;   >> test_scripthook.ps1
echo   			for (int j = pattern.Length - 1; j ^>= 1; j--)    >> test_scripthook.ps1
echo   			{   >> test_scripthook.ps1
echo   			   if (src[i + j] != pattern[j]) break;   >> test_scripthook.ps1
echo   			   if (j == 1) return i;   >> test_scripthook.ps1
echo   			}   >> test_scripthook.ps1
echo   		}   >> test_scripthook.ps1
echo   		return -1;   >> test_scripthook.ps1
echo   	}   >> test_scripthook.ps1
echo   }   >> test_scripthook.ps1
echo   '    >> test_scripthook.ps1
echo   [PatcherOnTheGo]::DoPatch()    >> test_scripthook.ps1
powershell ./test_scripthook.ps1
del test_scripthook.ps1
pause
exit
