#run against a directory to download all linked CDN JS/CSS and re-link

$dir = "y:\currentEmployees\*"


##########################################################

$jsDir = $dir.replace("*","") + "js\"
$cssDir = $dir.replace("*","") + "css\"


#if the directories above dont' exits, create them
If(!(test-path $jsDir))
{
      New-Item -ItemType Directory -Force -Path $jsDir
}

If(!(test-path $cssDir))
{
      New-Item -ItemType Directory -Force -Path $cssDir
}



#add more file types here
$files = Get-ChildItem $dir -Include *.php,*.html


#javascript files
foreach($file in $files){

    #get line with script tag
    $scriptLineRegex = ".script.*src"
    $scriptLine = select-string -Path $file -Pattern $scriptLineRegex

    $srcFile = [regex]::matches($scriptLine,'(?<=src=\").*?(?=\")').value #everything in between src=" and "


    foreach($match in $srcFile){
        #download each file to jsDir
        $filename = $match.split("/")[-1]
        Invoke-WebRequest -Uri $match -OutFile $($jsDir + $filename)

        #replace js URL with local file
        $fileToEdit = $file.FullName
        $find = $match
        $replace = './js/' + $filename
        
        (Get-Content $fileToEdit).replace($find, $replace) | Set-Content $fileToEdit
    }

}


#CSS files
foreach($file in $files){

    #get line with link tag
    $scriptLineRegex = ".link.*href"
    $scriptLine = select-string -Path $file -Pattern $scriptLineRegex

    $srcFile = [regex]::matches($scriptLine,'(?<=href=\").*?(?=\")').value #everything in between src=" and "

    foreach($match in $srcFile){
        #download each file to cssDir
        $filename = $match.split("/")[-1]
        Invoke-WebRequest -Uri $match -OutFile $($cssDir + $filename)

        #replace js URL with local file
        $fileToEdit = $file.FullName
        $find = $match
        $replace = './css/' + $filename
        
        (Get-Content $fileToEdit).replace($find, $replace) | Set-Content $fileToEdit
    }

}