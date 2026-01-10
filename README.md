# Hotel Management System

Projekt zrealizowany w ramach przedmiotu "Bazy Danych 1". System sluzy do kompleksowego zarzadzania rezerwacjami, goscmi oraz uslugami hotelowymi, wykorzystujac zaawansowane mechanizmy bazy danych Oracle oraz aplikacje kliencka w jezyku Java.

## Zakres projektu
System umozliwia pelna obsluge procesow hotelowych, w tym:
* Zarzadzanie baza gosci i pracownikow (CRUD).
* Ewidencje pokoi z podzialem na typy i cenniki.
* Obsluge rezerwacji z mechanizmem zapobiegania konfliktom terminow.
* Modul rozliczeniowy, ktory automatycznie kalkuluje koszty pobytu wraz z uslugami dodatkowymi.
* Modul audytowy logujacy kluczowe zdarzenia w systemie (np. rejestracja nowych gosci).

## Technologie
* Baza danych: Oracle Database 19c
* Logika biznesowa: PL/SQL (Wyzwalacze, Procedury, Funkcje, Kursory)
* Aplikacja kliencka: Java 17+ (Interfejs konsolowy)
* Komunikacja: JDBC

## Struktura projektu i instrukcja uruchomienia

Aby poprawnie zainicjowac system, nalezy wykonac skrypty SQL w nastepujacej kolejnosci:

1. 00_cleanup.sql
   Skrypt czyszczacy srodowisko. Usuwa wszystkie tabele i sekwencje zwiazane z projektem, umozliwiajac czysty start.

2. 01_structure.sql
   Skrypt DDL. Tworzy tabele, klucze obce, wiezy integralnosci oraz sekwencje.

3. 02_data.sql
   Skrypt ladujacy dane (DML). Wypelnia slowniki (typy pokoi, stanowiska) oraz proceduralnie generuje 30 pokoi hotelowych przy uzyciu petli PL/SQL.

4. 03_logic.sql
   Kompilacja obiektow PL/SQL. Wgrywa do bazy:
    * Funkcje (sprawdzanie dostepnosci, obliczanie kosztow).
    * Procedury (tworzenie rezerwacji, generowanie raportow).
    * Wyzwalacze (walidacja dat, audyt).

5. 04_tests.sql
   Zestaw zapytan SQL weryfikujacych poprawnosc dzialania logiki biznesowej (testy funkcji, procedur i zlozonych zapytan raportowych).

## Aplikacja Java

Kod zrodlowy aplikacji znajduje sie w pliku: Main.java.

Konfiguracja:
Przed uruchomieniem aplikacji nalezy uzupelnic dane logowania do bazy danych w pliku Main.java (zmienne USER oraz PASS).

Funkcjonalnosc aplikacji:
Aplikacja oferuje tekstowe menu umozliwiajace:
* Wyswietlanie listy gosci i rezerwacji.
* Dodawanie nowych gosci.
* Wyszukiwanie dostepnych pokoi w zadanym terminie.
* Dokonywanie rezerwacji (wywolanie procedury skladowanej).
* Obliczanie calkowitego kosztu pobytu (wywolanie funkcji skladowanej).