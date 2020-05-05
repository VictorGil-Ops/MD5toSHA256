# Función para hashear a SHA256 es llamada luego
function HashSha256 {

    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $ClearString
    )

    $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
    $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ClearString))

    $hashString = [System.BitConverter]::ToString($hash)
    $hashString.Replace('-', '')

}

# Definiendo las rutas de los archivos con los que se trabajará
$path1 = "$env:HOMEPATH\Desktop\passwords.md5"
$path2 = "$env:HOMEPATH\Desktop\passwords.txt"
$path3 = "$env:HOMEPATH\Desktop\passwords.temp"
$path4 = "$env:HOMEPATH\Desktop\passwords_new.txt"

# Descarga el fichero de contraseñas hasheadas en MD5
(Invoke-WebRequest -uri "https://raw.githubusercontent.com/jaesga/master-ciberseguridad-web-colaborativa/master/PASSWORDS.md" -UseBasicParsing).Content >> "$path1"
$hashPasswd = Get-Content "$path1"

# Recorre cada hash descifrando el MD5 y luego lo cifra a SHA256
foreach($hash in $hashPasswd ) {
    
    $regex = ‘(?<=text=)(.*)(?=">)’
    $eventResult = (Invoke-WebRequest "https://hashtoolkit.com/decrypt-hash/?hash=$hash" -UseBasicParsing).Links | Select-String -pattern $regex | % { $_.Matches } | % { $_.Value } | select-object -first 1
       
    $regex = $eventResult

  if ($eventResult -ne $null){

        echo "$eventResult" >> "$path2"
        HashSha256 $eventResult >> "$path3"


  } else {


        #echo "$hash     >  No enontrado" >> "$path2"
        echo " " >> "$path2"

  }
        
  sleep -Seconds 1    
               
       
}

# Cambia el orden de los hashes (ramdon)
function Randomize-List
{
   Param(
     [array]$InputList
   )

   return $InputList | Get-Random -Count $InputList.Count;
}


$list = Get-Content -Path $path3 

Write-Output (Randomize-List -InputList $list) >> $path4
