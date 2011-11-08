#!bin/bash

# VideoThumbnailer
# [Befehl] -arg zeit
# arg kann sein: t -> thaumbnails erstellen, c -> Kontaktabzug erstellen, tc beides
# zeit ist abstand zwischen bildern

calcTime()
{
    echo "Calculate Time"

# Videolänge als Variable
    dur=$(ffmpeg -i $1 2>&1 | grep Duration | awk '{print $2}')

# komma entfernen
    dur="${dur//,/}"
    echo $dur

# dur in Sekunden
    HH=`echo $dur | awk -F ':' '{print $1}'`
    MM=`echo $dur | awk -F ':' '{print $2}'`
    SS=`echo $dur | awk -F ':' '{print $3}'`
# Umrechnung in Sekunden
    DURSEC=$(echo "$SS + ($MM*60) + ($HH*3600)" | bc)
#Ausgabe
    echo Dauer = $HH Stunden,  $MM Minuten und $SS Sekunden
    echo Dauer in Sekunden = $DURSEC
}

calcPics()
{
# Anzahl Bilder
bilderanzahl=$(echo "$1/$2" | bc)
bilderanzahl=$(echo "($bilderanzahl+0.5)/1" | bc)
echo calcPics $bilderanzahl

}

createThumb()
{
    echo createThumbs $1 $2 $3
    ffmpeg -ss $2 -i $1 -vcodec mjpeg -vframes 1 -an -f rawvideo -s 1280x720 $3.jpg
}

createPics()
{
echo createPics $1 $2
TMP_argument=$1
TMP_dateinameSans=$2
TMP_datei=$3

#thumbnails
echo "creating Thumbnails"

mkdir Thumbs_$TMP_dateinameSans

j=0
for ((i=0; i <= $bilderanzahl ; i++));
do
    zeit=$(echo "$i*$intervall" | bc)
    createThumb $TMP_datei $zeit Thumbs_$TMP_dateinameSans/$j
    j=$(echo "$j + 1" | bc)
done


if [ "$TMP_argument" == "-c" -o "$TMP_argument" == "-tc" ]
then
    echo "creating Contact Sheet"

# in Verzeichniss wechseln
    cd Thumbs_$TMP_dateinameSans

# collage erstellen
    montage -size 512x512 '*.*[120x90]' -auto-orient -geometry +1+1 -background black $TMP_dateinameSans.html

# collage aus tmp ordener verschieben
    if [ "$4" == "dir" ]
    then
	mv $TMP_dateinameSans.png ../$5
    else
	mv $TMP_dateinameSans.png ..
    fi

# aus temp raus und tmp löschen
    cd ..
    if [ "$TMP_argument" == "-tc" ]
    then
	cd Thumbs_$TMP_dateinameSans
#	rm HD*
	cd ..
    else
	rm -r Thumbs_$TMP_dateinameSans
    fi
fi

if [ "$4" == "dir" ]
then
    cp -r Thumbs_$TMP_dateinameSans/ $5
    rm -r Thumbs_$TMP_dateinameSans/
fi

}

####################################################################################

intervall=$3

#datei oder verzeichnis
if [ -f "$1" ]
then
    echo "$1 is a file."

# dateiname ohne endung
    dateinameSans=${1%.*}
    echo $dateinameSans
    calcTime $1
    calcPics $DURSEC $intervall
    createPics $2 $dateinameSans $1

elif [  -d "$1" ]
then
    echo "$1 is a directory"

# jede datei in verzeichniss
    for f in $1/*; do

# verzeichniss aus string entfernen
    dateiname=${f#$1}
# slash entfernen
    dateiname=${dateiname#/}
# dateiname ohne endung
    dateinameSans=${dateiname%.*}

    calcTime $f
    calcPics $DURSEC $intervall 
    createPics $2 $dateinameSans $f dir $1

    done
fi


exit 0
