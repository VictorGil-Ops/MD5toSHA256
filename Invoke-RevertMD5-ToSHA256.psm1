using namespace System

<#
.Synopsis
  
  Descarga un fichero con contraseñas 'hasheadas' en MD5 de (https://raw.githubusercontent.com/jaesga/master-ciberseguridad-web-colaborativa/master/PASSWORDS.md)
  ,lo guarda en un fichero (path1), descifra cada hash utilizando la API de (https://hashtoolkit.com/decrypt-hash/) dejando las que no encuente en blanco.
  Por último cifra cada contraseÃ±a en claro con SHA256 utilizando como 'SALT' un Timestamp. 

.Example
  
  Primero importar el módulo 

  PS C:\> Import-Module Invoke-RevertMD5-ToSHA256.psm1

  Eliminar módulo
  
  PS C:\> Remove-Module Invoke-RevertMD5-ToSHA256.psm1


.Example
  
  Llamada a la función

  PS C:\> Invoke-RevertMD5-ToSHA256

  
.Example
  
  #TODO
  Revertir las contraseñas SHA256
  
  PS C:\> 


#>

# PATHS
$path1 = "$env:HOMEPATH\Desktop\passwords.md5"
$path2 = "$env:HOMEPATH\Desktop\passwords.txt"
$path3 = "$env:HOMEPATH\Desktop\passwords_new.txt"


function HashSha256 {

  Param (
      [Parameter(Mandatory=$true)]
      [string]
      $ClearString
  )

  # Format Get-Date = 2020-05-05T19:06:37.0639256+02:00 
  $SaltTimeStamp = Get-Date -Format o
  
  $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
  $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ClearString+$SaltTimeStamp))

  $hashString = [System.BitConverter]::ToString($hash)
  $hashString.Replace('-', '')

}


function Invoke-RevertMD5-ToSHA256{

    (Invoke-WebRequest -uri "https://raw.githubusercontent.com/jaesga/master-ciberseguridad-web-colaborativa/master/PASSWORDS.md" -UseBasicParsing).Content >> $path1
    $hashPasswd = Get-Content $path1

    # Recorre cada hash descifrando el MD5
    foreach($hash in $hashPasswd ) {
    
    $regex = ‘(?<=text=)(.*)(?=">)’
    $eventResult = (Invoke-WebRequest "https://hashtoolkit.com/decrypt-hash/?hash=$hash" -UseBasicParsing).Links | Select-String -pattern $regex | % { $_.Matches } | % { $_.Value } | Select-Object -first 1
    
    $regex = $eventResult
    
        if ($null -ne $eventResult){
    
            
            Write-Output $eventResult >> $path2
            HashSha256 $eventResult >> $path3
        
    
        }else{

            Write-Output "  " >> $path2

        }
    
    }




}
