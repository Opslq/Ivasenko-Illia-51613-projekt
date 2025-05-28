# Project Title

A brief description of what this project does and who it's for

# Kalkulator Kosztów Kredytu Konsumenckiego

## Opis

Prosta aplikacja konsolowa w Pythonie do obliczania kosztów kredytów konsumenckich. Umożliwia analizę rat, całkowitego kosztu, generowanie harmonogramu spłat oraz porównywanie różnych ofert kredytowych. Dodatkowo, oferuje wizualizację struktury kosztów kredytu.

Projekt ten został stworzony, aby pomóc użytkownikom w lepszym zrozumieniu zobowiązań finansowych związanych z kredytami konsumenckimi i podejmowaniu bardziej świadomych decyzji.

## Funkcjonalności

Kalkulator oferuje następujące możliwości:

*   **Obliczanie rat kredytu:**
    *   Raty równe (annuitetowe)
    *   Raty malejące
*   **Kalkulacja całkowitego kosztu kredytu:** Suma wszystkich odsetek i innych opłat (np. prowizji).
*   **Prosty harmonogram spłat:** Wyświetla szczegółowy plan spłaty kredytu, pokazując dla każdej raty część kapitałową, odsetkową oraz pozostały kapitał do spłaty.
*   **Porównanie ofert kredytowych:** Umożliwia zestawienie kluczowych parametrów (np. wysokość raty, całkowity koszt) dla maksymalnie 2-3 ofert (możliwość rozszerzenia).
*   **Wizualizacja struktury kosztów kredytu:** Generuje wykres przedstawiający udział kapitału i odsetek w poszczególnych ratach.

## Technologie

Do stworzenia aplikacji wykorzystano:

*   **Python 3.x**
*   **NumPy:** Do efektywnych obliczeń numerycznych (choć w obecnej wersji jego rola jest minimalna, stanowi dobrą bazę pod rozbudowę).
*   **Matplotlib:** Do generowania wykresów i wizualizacji danych.

## Instalacja i Uruchomienie

Aby uruchomić kalkulator, wykonaj poniższe kroki:

1.  **Sklonuj repozytorium lub pobierz pliki.**
    ```
    # Jeśli używasz Git
    git clone <adres-repozytorium>
    cd <nazwa-katalogu-repozytorium>
    ```
    Jeśli nie, po prostu pobierz plik `kalkulator_kredytowy.py` (lub inną nazwę, pod którą zapisałeś kod).

2.  **Zainstaluj wymagane biblioteki:**
    Upewnij się, że masz zainstalowanego Pythona oraz menedżer pakietów `pip`. Następnie zainstaluj potrzebne biblioteki:
    ```
    pip install numpy matplotlib
    ```

3.  **Uruchom skrypt:**
    Przejdź do katalogu, w którym znajduje się plik Pythona i uruchom go za pomocą polecenia:
    ```
    python kalkulator_kredytowy.py
    ```

## Użycie

Główne funkcje kalkulatora są dostępne bezpośrednio w kodzie skryptu. Możesz modyfikować przykładowe dane wejściowe w sekcji `# Przykładowe użycie` w pliku `kalkulator_kredytowy.py`, aby dostosować obliczenia do swoich potrzeb.

## Struktura projektu

Projekt składa się z jednego głównego pliku:

*   `kalkulator_kredytowy.py`: Zawiera całą logikę aplikacji, w tym funkcje do obliczeń, generowania harmonogramu, porównywania ofert i wizualizacji.

## Możliwe usprawnienia (TODO)

*   Stworzenie interfejsu graficznego użytkownika (GUI) np. przy użyciu Tkinter, PyQt lub Kivy.
*   Możliwość wczytywania i zapisywania danych ofertowych z/do pliku (np. CSV, JSON).
*   Dodanie obsługi innych opłat (np. ubezpieczenie).
*   Bardziej zaawansowane opcje porównywania ofert.
*   Testy jednostkowe dla poszczególnych funkcji.

