#!/bin/bash

function installBKPGH {
        echo 'Installing backup...'
        if test -e backup
        then
        cd backup
        for d in $( cat ../files2hack )
        do
            for i in *
            do
                dir=${d%/*}
                file="${dir}/$i"
                if [ "$d" == "$file" ]
                then
                     cp $i $d
                fi
            done
        done
        echo 'Done'
        else
            echo 'No backup found'
            exit 127
        fi
}

function pkgMAKEGH {

if test -e files2hack
then
     if test -e game
     then
          game=$(cat game)
     else
         echo "File: 'game' missing!"
         exit 127
     fi
else
     echo "No 'files2hack' file found"
     exit 127
fi

echo "Checking dependencies...."
y=0
for d in $( cat files2hack )
do
     if test -e "${d}"
     then
         files[y]=${d}
         y=$[y+1]
     else
         echo "Unmet dependency found: ${d}"
         exit 127
     fi
done

cd ..
cp -R gh4ck ../
cd $OLDPWD

echo 'Packaging...(Part 1)'
mkdir -p DEBIAN usr/games/${game}/bkp/../hacks
cp -Rf ${files[@]} usr/games/${game}/hacks
mv package/* DEBIAN/
rm -rf package backup
mv Default.png usr/games/${game}/
rm -f 'Instructions.txt' 'game' 'hack.HTML'
mv test usr/games/${game}/
cp files2hack usr/games/${game}/hacks.list
mv files2hack DEBIAN/
cd DEBIAN

echo 'Creating installer...'
rm -f postinst prerm
cat >> postinst << _END_INST
#!/bin/bash
export game="${game}"
_END_INST
cat >> prerm << _END_RM
#!/bin/bash
export game="${game}"
_END_RM
cat /var/gh4ck/post/postinst >>postinst
cat /var/gh4ck/post/prerm >>prerm
chmod 0755 p*

echo 'Packaging...(Part 2)'
rm -f files2hack
cat >> control << _END_CON
Package: $(cat ID)
Name: $(cat Name)
Version: $(cat Version)
Maintainer: $(cat Author) <$(cat Email)>
Architecture: iphoneos-arm
Description: $(cat Description)
Homepage: $(cat Website)
Section: Games

_END_CON
mv AuthorsNote ../usr/games/${game}/aNote
mkdir ../usr/games/${game}/settings
mv ../icon.png ../usr/games/${game}/settings/${game}.png
cat >> ../usr/games/${game}/settings/${game}.plist << _ROOT_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>entry</key>
  <dict>
    <key>cell</key>
    <string>PSLinkCell</string>
    <key>icon</key>
    <string>${game}.png</string>
    <key>label</key>
    <string>${game} Hacks</string>
  </dict>
  <key>items</key>
  <array>
    <dict>
      <key>cell</key>
      <string>PSGroupCell</string>
      <key>label</key>
      <string>${game} Hacks made by $(cat Author).

$(cat Description)

Toolkit created by gH4ck
gH4ck By kD3\/

gH4ck: http://ir3volution.com/gh4ck
$(cat Author): $(cat Website)</string>
    </dict>
  </array>
  <key>title</key>
  <string>${game} Hacks</string>
</dict>
</plist>
_ROOT_EOF
rm -f ID Name Description Author Website Version Email
cd ../..

dpkg-deb -b gh4ck .//

echo Done with $?

rm -rf gh4ck
mv ../gh4ck ./

}

function removeGH {
        echo 'Removing gh4ck...'
        cd ..
        if test -e gh4ck
        then
        rm -rf gh4ck
        else
        echo 'gh4ck not found: Please make sure the command was run in the gh4ck folder'
        exit 1
        fi
        echo 'Done'
}

args=$1

if [ "${args}" == "install-backup" ]
then
      installBKPGH
elif [ "${args}" == "remove" ]
then
       removeGH
else
       pkgMAKEGH
fi