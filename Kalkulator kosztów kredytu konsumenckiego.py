import numpy as np
import matplotlib.pyplot as plt

def oblicz_rate_input():
    kwota = float(input("Podaj kwotę kredytu: "))
    oprocentowanie_roczne = float(input("Podaj oprocentowanie roczne (np. 0.05 dla 5%): "))
    liczba_rat = int(input("Podaj liczbę rat: "))
    rodzaj_rat = input("Podaj rodzaj rat ('rowne' lub 'malejace'): ")
    prowizja = float(input("Podaj prowizję (np. 0.02 dla 2%): "))

    oprocentowanie_miesieczne = oprocentowanie_roczne / 12
    kwota_z_prowizja = kwota * (1 + prowizja)

    if rodzaj_rat == "rowne":
        rata = (kwota_z_prowizja * oprocentowanie_miesieczne) / (1 - (1 + oprocentowanie_miesieczne) ** (-liczba_rat))
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

    print(f"Pierwsza rata: {raty[0]:.2f}")
    print(f"Całkowity koszt kredytu: {sum(raty) - kwota:.2f}")
    return raty, kwota, oprocentowanie_roczne, liczba_rat, rodzaj_rat, prowizja

def harmonogram_splat_input(kwota, oprocentowanie_roczne, liczba_rat, rodzaj_rat, prowizja):
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
def porownaj_oferty_input():
    n = int(input("Ile ofert chcesz porównać? "))
    oferty = []

    for i in range(n):
        print(f"\nOferta {i+1}")
        kwota = float(input("Kwota kredytu: "))
        oprocentowanie_roczne = float(input("Oprocentowanie roczne (np. 0.05): "))
        liczba_rat = int(input("Liczba rat: "))
        rodzaj_rat = input("Rodzaj rat ('rowne' lub 'malejace') [domyślnie: rowne]: ") or "rowne"
        prowizja = input("Prowizja (np. 0.02) [domyślnie: 0]: ")
        prowizja = float(prowizja) if prowizja else 0.0

        oferty.append({
            "kwota": kwota,
            "oprocentowanie_roczne": oprocentowanie_roczne,
            "liczba_rat": liczba_rat,
            "rodzaj_rat": rodzaj_rat,
            "prowizja": prowizja
})

    wyniki = porownaj_oferty(oferty)
    print("\nPorównanie ofert:")
    for nazwa, dane in wyniki.items():
        print(f"{nazwa}: rata: {dane['rata']}, całkowity koszt: {dane['calkowity_koszt']:.2f}")

def porownaj_oferty(oferty):
    porownanie = {}
    for i, oferta in enumerate(oferty):
        raty = oblicz_rate(
            oferta["kwota"],
            oferta["oprocentowanie_roczne"],
            oferta["liczba_rat"],
            oferta.get("rodzaj_rat", "rowne"),
            oferta.get("prowizja", 0)
        )
        koszt = calkowity_koszt_kredytu(raty, oferta["kwota"])
        porownanie[f"oferta_{i+1}"] = {
            "rata": raty[0] if oferta.get("rodzaj_rat", "rowne") == "rowne" else "różne",
            "calkowity_koszt": koszt
        }
    return porownanie

def oblicz_rate(kwota, oprocentowanie_roczne, liczba_rat, rodzaj_rat="rowne", prowizja=0):
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
    return sum(raty) - kwota
if __name__ == "__main__":
    oblicz_rate_input()
