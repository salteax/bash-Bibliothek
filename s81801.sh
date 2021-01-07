#!/bin/bash

operation=$1 # erster Kommandozeilenparameter
author=$2 # zweiter Kommandozeilenparameter

# Fehlerbehandlung fuer Parametereingabe

if [[ $operation == "" ]]
then
	printf "Ungueltige Anzahl an Parametern.\nDas Programm wird beendet!\n"
	exit 1
fi

# Pruefung auf Existenz der Datei 'bib.csv'

datei="bib.csv"

if [[ -f $datei  ]]
then
	printf "Die Datei '%s' existiert.\n" "$datei"
else
	printf "Die Datei '%s' existiert nicht.\nLaden sie sich die Datei unter 'https://www.informatik.htw-dresden.de/~robge/bs1/bs1.html' herunter und speichern sie diese lokal unter dem Namen '%s' in diesem Ordner ab.\nDas Programm wird beendet!" "$datei" "$datei"
	exit 1
fi

#Einlesen der Datei und speichern der Daten in verschiedenen Arrays fuer spaeteren Zugriff

declare -a arr_titel
declare -a arr_verfasser
declare -a arr_schriftreihe
declare -a arr_kategorie
declare -a arr_jahr
declare -a arr_verlag
declare -a arr_seiten
declare -a arr_isbn

IFS=";" # Trennoperator für CSV Datei

while read -r titel verfasser schriftreihe kategorie jahr verlag seiten isbn
	do
		arr_titel+=("$titel")
		arr_verfasser+=("$verfasser")
		arr_schriftreihe+=("$schriftreihe")
		arr_kategorie+=("$kategorie")
		arr_jahr+=("$jahr")
		arr_verlag+=("$verlag")
		arr_seiten+=("$seiten")
		arr_isbn+=("$isbn")
	done < $datei #bib.csv wird als Standarteingabe für die while-Schleife gesetzt

# Verschiedene Operationen die zur Ausfuehrung zur Verfuegung stehen

case $operation in
	"search")
		# Pruefung ob Suchstring $author leer ist
		if [[ $author = "" ]]
		then
			printf "Operation '%s' benoetigt einen zweiten Parameter fuer den gesuchten Author.\n" "$operation"
		       	exit 1
		fi

		# Ausgabe der Authoren die den Suchstring '$author' beinhalten
		printf "Die folgenden Authoren wurden unter dem Suchstring '%s' gefunden:\n" "$author"

		for i in "${!arr_verfasser[@]}"
			do
				if [[ ${arr_verfasser[i]} == *$author* ]]
				then
					printf "%s\n" "${arr_verfasser[i]}"
				fi
			done
		;;
	"count")
		# Ausgabe der Anzahl der Eintraege in der Literaturdatenbank (Anzahl der Titel)
		printf "In der Literaturdatenbank befinden sich %i Eintraege.\n" "${#arr_kategorie[@]}"
		;;
	"categories")
		# Ausgabe der verschiedenen Kategorien in sortierter Reihenfolge

		# Leere Zeilen in 'Leere Kategorie' aendern
		for i in "${!arr_kategorie[@]}"
			do
				if [[ ${arr_kategorie[i]} == "" ]]
				then
					arr_kategorie[i]="Leere Kategorie"
				fi
			done
		printf "Die folgenden Kategorien sind vorhanden:\n"
		# alle Eintraege in arr_kategorie sortieren mit Paramter 'u' damit nur einzigartige Eintraege verbleiben
		printf "%s\n" "${arr_kategorie[@]}" | sort -u
		;;
	"years")
		# Ausgabe der Anzahl an veroeffentlichten Buecher pro Jahr
		printf "Anzahl der Bücher die pro Jahr veroeffentlicht wurden:\n"
		a=""
		for i in "${!arr_jahr[@]}"
			do
				a=${arr_jahr[i]}
				arr_jahr[i]=${a:(-4)} # Zugriff auf die vier letzten Zeichen, welche somit immer dem Jahr entsprechen

				if [[ ${arr_jahr[i]} == "" ]]
				then
					arr_jahr[i]="Keine Angabe"
				fi
			done
		printf "\nAnzahl\tJahr\n"
		# alle Eintraege in arr_jahr sortieren und uniq damit nur einzigartige Eintraege verbleiben welche dann mit dem Paramter von uniq 'c' gezaehlt werden
		printf "%s\n" "${arr_jahr[@]}" | sort | uniq -c
		;;
	"nopub")
		# Ausgabe der Titel ohne angegebenen Verlag
		printf "Die folgenden Titel haben keinen Verlag angegeben:\n"
		for i in "${!arr_verlag[@]}"
			do
				if [[ ${arr_verlag[i]} == "" ]]
				then
					printf "Titel: %s\n" "${arr_titel[i]}"
				fi
			done
		;;
	"isbn")
		# Ausgabe der fehlerhaften ISBN mit deskriptiver Fehlermeldung
		printf "Die folgenden ISBN sind fehlerhaft angegeben:\n"
		for i in "${!arr_isbn[@]}"
			do
				# ersetzen des Zeichen '-' mit ''
				arr_isbn[i]=${arr_isbn[i]//-}

				if [[ ${#arr_isbn[i]} == 10 ]]
				then
					if ! [[ ${arr_isbn[i]} =~ [0123456789]{8}[0123456789X]{1} ]]
					then
						printf "Die '%s' enthaelt Zeichen die nicht der Norm entsprechen." "${arr_isbn[i]}"
					else
						if [[ ${arr_isbn[i]:9:1} == 'X' ]]; then
							isbn_modulo=$((${arr_isbn[i]:0:1}+2*${arr_isbn[i]:1:1}+3*${arr_isbn[i]:2:1}+4*${arr_isbn[i]:3:1}+5*${arr_isbn[i]:4:1}+6*${arr_isbn[i]:5:1}+7*${arr_isbn[i]:6:1}+8*${arr_isbn[i]:7:1}+9*${arr_isbn[i]:8:1}+10*10))
						else
							isbn_modulo=$((${arr_isbn[i]:0:1}+2*${arr_isbn[i]:1:1}+3*${arr_isbn[i]:2:1}+4*${arr_isbn[i]:3:1}+5*${arr_isbn[i]:4:1}+6*${arr_isbn[i]:5:1}+7*${arr_isbn[i]:6:1}+8*${arr_isbn[i]:7:1}+9*${arr_isbn[i]:8:1}+10*${arr_isbn[i]:9:1}))
						fi
						isbn_modulo=$(($isbn_modulo % 11))
						if ! [[ $isbn_modulo == 0 ]]
						then
							printf "Die ISBN '%s' bekommt bei teilen mit Modulo 11 nicht das Ergebnis von 0.\n" "${arr_isbn[i]}"
						fi
					fi
				elif [[ ${#arr_isbn[i]} == 13 ]]
				then
					if ! [[ ${arr_isbn[i]} =~ [0123456789]{13} ]]
					then
						printf "Die '%s' enthaelt Zeichen die nicht der Norm entsprechen." "${arr_isbn[i]}"
					fi
				elif [[ ${#arr_isbn[i]} == 0 ]]
				then
					printf "Die ISBN '%s' ist leer.\n" "${arr_isbn[i]}"
				else
					printf "Die ISBN '%s' hat mit %s Zeichen die falsche Anzahl an Zeichen, vorgegeben sind 10 oder 13.\n" "${arr_isbn[i]}" "${#arr_isbn[i]}"
				fi
			done
		;;
	"longest")
		# Gibt den Titel mit der höchsten Seitenanzahl an
		max=${arr_seiten[0]}
		max_index=0
		printf "Der folgende Titel besitzt die meisten Seiten:\n"
		for i in "${!arr_seiten[@]}"
			do
				if (( arr_seiten[i] > max ))
				then
					max=${arr_seiten[i]}
					max_index=$i
				fi
			done
		printf "Titel: %s, Author: %s, Seitenzahl: %d\n" "${arr_titel[$max_index]}" "${arr_verfasser[$max_index]}" "${arr_seiten[$max_index]}"
		;;
	*)
		#Default-Case, falls der erste Parameter fehlerhaft eingegeben wurde und somit keinem anderem Case zugewiesen werden konnte.
		printf "Die Operation '%s' wurde nicht gefunden, pruefen sie ihre Eingabe auf Fehler.\nDie zu verfuegung stehenden Operationen sind: 'categories', 'count', 'isbn', 'longest', 'nopub', 'search' und 'years'.\nDas Programm wird beendet!\n" "$operation"
		;;
esac

exit 0
