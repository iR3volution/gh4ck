#!/bin/bash

echo "Game Hackers Toolkit v0.6 -- kD3\/"
echo

declare -a args
game="${@}"
args="$(echo $@|sed 's/--//'|sed 's/-//')"
s="/"

if [ "${args}" == "help" ]
then
     echo "Hack games and package your own hacks"
     exit
elif [ "${args}" == "pkg" ]
then
      make-gh4ck
      exit $?
fi

echo "Searching for ${game}.app...."
cd /var/mobile/Applications/*/*${game}*.app &>>/dev/null
if [ "$?" == "0" ]
then
        echo "Found"
        gameApp="${PWD}"
else
        echo "Not found"
      echo
      echo "Searching in all Info.plist for ${game}..."
      for n in /var/mobile/Applications/*/*.app
      do
        cd ${n%/*}/*.app
        app="$(plutil -key CFBundleDisplayName Info.plist)"
        if [ "x${app}" == "x" ]
        then
              app="$(plutil -key CFBundleExecutable Info.plist)"
        fi
        if [ "${app}" == "${game}" ]
        then
              echo "Found"
              gameApp="${n}"
              break
        fi
      done
      if [ "x${gameApp}" == "x" ]
      then
            echo "Still not found"
            echo 
            echo "Exiting..."
            exit 127
      fi
fi


cd ${gameApp}
echo
rm -rf gh4ck
echo "Updating locatedb..."
updatedb
echo "Done"

echo
echo "Searching for vulnerabilities..."
declare -a vlEXT
vlEXT=([0]=".xml" [1]=".XML" [2]=".plist" [3]=".PLIST" [4]=".html" [5]=".HTML" [6]=".js" [7]=".JS" [8]=".mp4" [9]=".MP4" [10]=".m4v" [11]=".M4V" [12]=".mov" [13]=".MOV" [14]=".sqlite" [15]=".SQLITE" [16]=".bin" [17]=".BIN" [18]=".png" [19]=".PNG" [20]=".jpg" [21]=".JPG" [22]=".jpeg" [23]=".JPEG" [24]=".psd" [25]=".PSD" [26]=".bmp" [27]=".BMP" [28]=".sqlite3" [29]=".SQLITE3" [30]=".db" [31]=".DB")
y="0"
mkdir gh4ck
dir="/private${gameApp%/*}/"
for ((x=0;x<18;x++))
do
for file in $(locate "${vlEXT[x]}"|sed '/Info.plist/ d'|sed '/.binary/ d'|sed '/Entitlements.plist/ d'|sed '/ResourcesRules.plist/ d'|grep ${PWD})
do
    files[y]="${file}"
    fileT="${file#*.app/}"
    filesT[y]="${fileT}"
    y=$[y+1]
done
for file in $(locate "${vlEXT[x]}"|sed '/.binary/ d'|sed '/'".app"'/ d'|sed '/iTunesMetadata/ d'|grep ${PWD%/*})
do
    files[y]="${file}"
    fileT="../${file#$dir}"
    filesT[y]="${fileT}"
    y=$[y+1]
done
done


if [ "x${files[@]}" == "x" ]
then
      echo 'Not found'
      exit 127
fi 2>>/dev/null

echo 'Found'
echo

echo "Installing gh4ck into app..."
cd ${gameApp}
cd gh4ck
echo ${files[@]}|tr ' ' '\n' >files2hack
echo ${filesT[@]}|tr ' ' '\n' >test
cp -R /var/gh4ck/app/* ./
for icon in ../*con.png
do
    cp ${icon} icon.png
    break
done
cat >> Instructions.txt << _EOF
All the files you can hack are listed in the 'files2hack' file. Read it and hack those files however you want. Then test all hacks. When you are ready to put it in cydia, go to the folder 'package' and edit the files to suit your hacks.

Now go to terminal, locate this folder, and type in "make-gh4ck" then "make-gh4ck remove"

Ex:

$ su
Password: 
# cd ${gameApp}
# cd gh4ck
# make-gh4ck
Checking dependencies...
Packaging...(Part 1)
Creating installer....
Packaging...(Part 2)
Done
# make-gh4ck remove
Removing gh4ck from app...
Done

Once this is done, your package will be ready for Cydia. Just send it to BigBoss or ModMyi or your own.

Enjoy!! ;)

Q: Where is my package?
A: It is in the .app folder you hacked.
   ${gameApp}/com.yourcompany.product_1.0_iphonesos-arm.deb

Q: How does this package work?
A: It is now installable. Just tap it in iFile and choose Installer.
_EOF
mkdir backup
cp -Rf ${files[@]} backup/
echo "${game}" > game

rm -f hack.HTML
cat >> hack.HTML << _HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">



<head>

<meta content="yes" name="apple-mobile-web-app-capable" />

<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />

<meta content="minimum-scale=1.0, width=device-width, maximum-scale=0.6667, user-scalable=no" name="viewport" />

<link href="/var/gh4ck/html/css/style.css" rel="stylesheet" media="screen" type="text/css" />

<script src="/var/gh4ck/html/php/php.js"></script>

<script type="text/javascript">
function displayFile(filename) {
         file = fopen(filename,'r');
         fileB = parseInt(filesize(file));
         if (fileB>4077) {
             alert('This file is too large to display!');
             return -1;
         }
         fileR = fread(file,fileB);
         document.body.style.backgroundColor = 'white';
         document.getElementById('content').style.display = 'none';
document.body.innerHTML = '<textarea id="display">'+fileR+'</textarea>'
document.getElementById('display').style.width= '320px';
document.getElementById('display').style.height = '480px';
}
</script>

<title>${game} Hacker Toolkit</title>

<meta content="keyword1,keyword2,keyword3" name="keywords" />

<meta content="Hack ${game}" name="description" />

</head>



<body style="background-color: black">



<div id="topbar" class="black"><div id="title">${game} Hacking Toolkit</div></div>

<div id="newcontent"></div>

<div id="content">
<ul class="pageitem">
<li class="textbox">
<p>This is a small GUI allowing you to see the files you can hack. Currently it shows the source code of each file. SOME FILES MAY BE TOO LARGE TO VIEW!(over 4077bytes). Though you can edit in this browser, changes are NOT saved. Files which you can hack are listed below:</p></li>
_HTML
for fileT in $(echo ${filesT[@]}|tr ' ' '\n')
do
          file="${fileT##*/}"
          fileJS="backup/$file"
          cat >> hack.HTML <<FEND
<li class="menu"><a href="javascript:displayFile('${fileJS}')">

                <img alt="list" src="/var/gh4ck/html/thumbs/file.png" /><span class="name">${file}</span><span class="arrow"></span></a></li>
FEND
done
cat >> hack.HTML << _END_HTML
</ul>
</div>



</body>



</html>

_END_HTML

echo 'Done'
echo
echo "Good Luck ;) Hope to see your ${game} hacks soon!"
