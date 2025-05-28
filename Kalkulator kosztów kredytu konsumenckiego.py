import numpy as np
import matplotlib.pyplot as plt

def oblicz_rate(kwota, oprocentowanie_roczne, liczba_rat, rodzaj_rat="rowne", prowizja=0):
    """
    Oblicza ratę kredytu (równe lub malejące).

    Args:
        kwota (float): Kwota kredytu.
        oprocentowanie_roczne (float): Oprocentowanie roczne (np. 0.05 dla 5%).
        liczba_rat (int): Liczba rat.
        rodzaj_rat (str): "rowne" dla rat równych lub "malejace" dla rat malejących.
        prowizja (float): Prowizja za udzielenie kredytu (np. 0.02 dla 2%).

    Returns:
        list: Lista wysokości rat.
    """

    oprocentowanie_miesieczne = oprocentowanie_roczne / 12
    kwota_z_prowizja = kwota * (1 + prowizja)

    if rodzaj_rat == "rowne":
        rata = (kwota_z_prowizja * oprocentowanie_miesieczne) / (1 - (1 + oprocentowanie_miesieczne)**(-liczba_rat))
        raty = [rata] * liczba_rat
    elif rodzaj_rat == "malejace":
        kapital = kwota_z_prowizja / liczba_rat
        raty = []
        for i in range(1, liczba_rat + 1):
            odsetki = (kwota_z_prowizja - (i - 1) * kapital) * oprocentowanie_miesieczne
            rata = kapital + odsetki
            raty.append(rata)
    else:
        raise ValueError("Nieznany rodzaj rat. Wybierz 'rowne' lub 'malejace'.")

    return raty

def calkowity_koszt_kredytu(raty, kwota):
    """
    Oblicza całkowity koszt kredytu.

    Args:
        raty (list): Lista wysokości rat.
        kwota (float): Kwota kredytu.

    Returns:
        float: Całkowity koszt kredytu.
    """
    return sum(raty) - kwota

def harmonogram_splat(kwota, oprocentowanie_roczne, liczba_rat, rodzaj_rat="rowne", prowizja=0):
    """
    Tworzy harmonogram spłat kredytu.

    Args:
        kwota (float): Kwota kredytu.
        oprocentowanie_roczne (float): Oprocentowanie roczne.
        liczba_rat (int): Liczba rat.
        rodzaj_rat (str): "rowne" dla rat równych lub "malejace" dla rat malejących.
        prowizja (float): Prowizja za udzielenie kredytu.

    Returns:
        list: Lista słowników, gdzie każdy słownik reprezentuje jedną ratę.
    """
    oprocentowanie_miesieczne = oprocentowanie_roczne / 12
    kwota_z_prowizja = kwota * (1 + prowizja)
    kapital_pozostaly = kwota_z_prowizja
    harmonogram = []

    if rodzaj_rat == "rowne":
        rata = (kwota_z_prowizja * oprocentowanie_miesieczne) / (1 - (1 + oprocentowanie_miesieczne)**(-liczba_rat))
        for i in range(1, liczba_rat + 1):
            odsetki = kapital_pozostaly * oprocentowanie_miesieczne
            kapital_splacony = rata - odsetki
            kapital_pozostaly -= kapital_splacony
            harmonogram.append({
                "numer_raty": i,
                "rata": rata,
                "odsetki": odsetki,
                "kapital": kapital_splacony,
                "kapital_pozostaly": kapital_pozostaly
            })
    elif rodzaj_rat == "malejace":
        kapital = kwota_z_prowizja / liczba_rat
        for i in range(1, liczba_rat + 1):
            odsetki = kapital_pozostaly * oprocentowanie_miesieczne
            rata = kapital + odsetki
            kapital_pozostaly -= kapital
            harmonogram.append({
                "numer_raty": i,
                "rata": rata,
                "odsetki": odsetki,
                "kapital": kapital,
                "kapital_pozostaly": kapital_pozostaly
            })
    else:
        raise ValueError("Nieznany rodzaj rat. Wybierz 'rowne' lub 'malejace'.")

    return harmonogram

def porownaj_oferty(oferty):
    """
    Porównuje oferty kredytowe.

    Args:
        oferty (list): Lista słowników, gdzie każdy słownik reprezentuje jedną ofertę kredytową.

    Returns:
        dict: Słownik z porównaniem ofert.
    """
    porownanie = {}
    for i, oferta in enumerate(oferty):
        raty = oblicz_rate(oferta["kwota"], oferta["oprocentowanie_roczne"], oferta["liczba_rat"], oferta.get("rodzaj_rat", "rowne"), oferta.get("prowizja", 0))
        koszt = calkowity_koszt_kredytu(raty, oferta["kwota"])
        porownanie[f"oferta_{i+1}"] = {
            "rata": raty[0] if oferta.get("rodzaj_rat", "rowne") == "rowne" else "różne",
            "calkowity_koszt": koszt
        }
    return porownanie

def wizualizacja_struktury_kosztow(harmonogram):
    """
    Wizualizuje strukturę kosztów kredytu.

    Args:
        harmonogram (list): Harmonogram spłat kredytu.
    """
    numery_rat = [rata["numer_raty"] for rata in harmonogram]
    odsetki = [rata["odsetki"] for rata in harmonogram]
    kapital = [rata["kapital"] for rata in harmonogram]

    plt.figure(figsize=(12, 6))
    plt.bar(numery_rat, kapital, label="Kapitał", color="#4CAF50")
    plt.bar(numery_rat, odsetki, bottom=kapital, label="Odsetki", color="#FF9800")

    plt.xlabel("Numer raty")
    plt.ylabel("Kwota")
    plt.title("Struktura kosztów kredytu")
    plt.legend()
    plt.grid(axis='y')
    plt.show()


# Przykładowe użycie
kwota = 20000
oprocentowanie_roczne = 0.05
liczba_rat = 36
prowizja = 0.02

raty_rowne = oblicz_rate(kwota, oprocentowanie_roczne, liczba_rat, "rowne", prowizja)
koszt_calkowity_rowne = calkowity_koszt_kredytu(raty_rowne, kwota)

raty_malejace = oblicz_rate(kwota, oprocentowanie_roczne, liczba_rat, "malejace", prowizja)
koszt_calkowity_malejace = calkowity_koszt_kredytu(raty_malejace, kwota)

print("Raty równe:", raty_rowne[0])
print("Całkowity koszt kredytu (raty równe):", koszt_calkowity_rowne)
print("Całkowity koszt kredytu (raty malejące):", koszt_calkowity_malejace)

harmonogram_rowne = harmonogram_splat(kwota, oprocentowanie_roczne, liczba_rat, "rowne", prowizja)
wizualizacja_struktury_kosztow(harmonogram_rowne)

oferta1 = {"kwota": 20000, "oprocentowanie_roczne": 0.05, "liczba_rat": 36, "prowizja": 0.02}
oferta2 = {"kwota": 20000, "oprocentowanie_roczne": 0.06, "liczba_rat": 36}

porownanie = porownaj_oferty([oferta1, oferta2])
print("Porównanie ofert:", porownanie)
