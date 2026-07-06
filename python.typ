#import "styles.typ": *

#align(center)[
  = Python Cheat Sheet
  *Prüfungsrelevante Syntax & Konzepte*
]

= 1. Datentypen, Typisierung & Built-ins

== Wichtige Eigenschaften
- *Mutable (Veränderbar):* Objekt kann in-place modifiziert werden (gleiche Speicheradresse).
- *Iterable:* Kann in einer Schleife durchlaufen werden (`__iter__`).

#table(
  columns: 4,
  [*Typ*], [*Mutable*], [*Iterable*], [*Beispiele / Notes*],
  [int / float / bool], [Nein], [Nein], [42, 3.14, True],
  [NoneType], [Nein], [Nein], [Repräsentiert Leere / Nullwert],
  [list], [Ja], [Ja], [`[1, "a", [2]]`],
  [tuple], [Nein], [Ja], [`(1, 2)` (kann mutable Elemente enthalten!)],
  [str], [Nein], [Ja], [`"Text"`],
  [range], [Nein], [Ja], [`range(start, stop, step)` (stop ist exklusiv)],
  [dict], [Ja], [Ja (Keys)], [`{"id": 1}` -> *Keys MÜSSEN immutable sein!*],
  [set], [Ja], [Ja], [`{1, 2}` -> *Elemente MÜSSEN immutable sein!*]
)

== Wichtige Built-ins & Methoden
- `sum(iter, start=0)`: Summiert alle numerischen Elemente.
- `enumerate(iter)`: Liefert `(Index, Wert)`.
- `zip(*iters)`: Aggregiert parallel zu Tupeln. Bricht ab, wenn kürzestes Iterable zu Ende.
- `sorted(iter, reverse=True)`: Gibt *neue* sortierte Liste zurück (`list.sort()` modifiziert in-place).

- *F-Strings (Float-Formatierung):* `f"Wert: {pi:.2f}"` -> `3.14` (Rundet auf 2 Nachkommastellen).

== String-Methoden (Erzeugen immer einen neuen String!)
- `.strip()`: Entfernt Whitespaces am Anfang und Ende.
- `.split(sep)`: Zerlegt den String am Trennzeichen `sep` in eine Liste.
- `sep.join(iter)`: Verbindet eine Liste von Strings mit dem Trennzeichen `sep`.
- `.replace(old, new)`: Ersetzt Vorkommen von `old` durch `new`.
- `.lower()` / `.upper()`: Transformiert in Klein- bzw. Großbuchstaben.
- `.startswith(prefix)` / `.endswith(suffix)`: Liefert `True` oder `False`.


== F-Strings 
In Python entfällt die Puffer-Verwaltung. Strings werden dynamisch im Speicher erzeugt. F-Strings (Präfix `f`) werten Ausdrücke in den geschweiften Klammern `{}` direkt zur Laufzeit aus.

*Wichtige Format-Specifier (Klausur-Klassiker):*
- `:.2f`: Fließkommazahl (float) auf 2 Nachkommastellen runden.
- `:04X`: Hexadezimalwert (großgeschrieben), mit Nullen auf 4 Stellen aufgefüllt.
- `:08d`: Integer, mit führenden Nullen auf 8 Stellen aufgefüllt.
- `:<10` / `:>10` / `:^10`: Text linksbündig / rechtsbündig / zentriert auf 10 Zeichen Breite ausrichten (aufgefüllt mit Leerzeichen).

```python
messwert = 1024
spannung = 3.3456
reg_val = 255

# F-String Syntax: f"Text {variable:formatierung}"
ausgabe = f"Wert: {messwert:05d}, U: {spannung:.1f}V"
# -> "Wert: 01024, U: 3.3V"

hex_ausgabe = f"Register: 0x{reg_val:04X}"
# -> "Register: 0x00FF"

ausrichtung = f"|{messwert:<6}|{messwert:>6}|"
# -> "|1024  |  1024|"
```


== Listen-Methoden (Modifizieren die Liste meist in-place!)
- `.append(x)`: Hängt das Element `x` hinten an die Liste an.
- `.extend(iter)`: Hängt alle Elemente des Iterables `iter` an die Liste an.
- `.insert(index, x)`: Fügt `x` an der Position `index` ein.
- `.pop(index=-1)`: Entfernt das Element am `index` (Standard: letztes) und gibt es zurück.
- `.remove(x)`: Entfernt das *erste* Vorkommen von `x` (wirft ValueError, wenn nicht existent).
- `.clear()`: Entfernt alle Elemente aus der Liste.
- `.sort(key=None, reverse=False)`: Sortiert die Original-Liste (Gegensatz zu `sorted()`).
- `.reverse()`: Reverse the list.

== Set-Operationen (Mengenlehre)
Sets filtern Duplikate automatisch heraus. Logische Verknüpfungen (Bsp: `a = {1, 2}`, `b = {2, 3}`):
- *Vereinigung (Union):* `a | b` -> `{1, 2, 3}` (Elemente aus a oder b)
- *Schnittmenge (Intersection):* `a & b` -> `{2}` (Elemente, die in a UND b sind)
- *Differenz (Difference):* `a - b` -> `{1}` (Elemente in a, die NICHT in b sind)
- *Sym. Differenz (XOR):* `a ^ b` -> `{1, 3}` (Elemente, die in genau einem der Sets sind)

== Typisierungskonzepte
- *Duck Typing:* Typ egal, Hauptsache Objekt hat benötigte Methode ("quakt wie eine Ente").
- *EAFP vs. LBYL:* EAFP (einfach ausführen, Fehler mit try/except fangen) ist Python-Standard. LBYL (vorher mit `if` prüfen) begünstigt Race Conditions.

= 2. Ablaufsteuerung & Algorithmen

== KLAUSURFALLE: Mutable Default-Parameter
Default-Argumente werden nur *einmalig* bei Funktionsdefinition ausgewertet. Niemals mutbare Typen (wie `[]`) als Default setzen!

```python
# FALSCH: Teilt die Liste über alle Aufrufe hinweg!
def append_to(element, target=[]): 
    target.append(element)

# RICHTIG:
def append_to_clean(element, target=None):
    if target is None: target = []
    target.append(element)
```

== Rekursion
Zwei zwingende Komponenten für jede rekursive Funktion:
1. *Basisfall:* Abbruchbedingung (z.B. `if n <= 1: return 1`), verhindert Endlosschleife.
2. *Rekursionsschritt:* Selbstaufruf mit modifiziertem, verkleinertem Problem.

== Slicing, Comprehensions & Match-Case
- *Slicing:* `sequence[start:stop:step]` (stop ist exklusiv!). Invertieren: `liste[::-1]`
- *List Comprehension:* `[expr for item in iter if cond]`
- *Match-Case (ab 3.10):* ```python
match kommando:
    case "start" | "run": return "Startet" # OR-Verknüpfung
    case ["move", direction]: return direction # Sequenz-Entpacken
    case _: return "Default / Wildcard"
```

= 3. Funktionen, Exceptions & Dateihandling

== Funktionale Werkzeuge & Generatoren
- *Generatoren:* Nutzen `yield` statt `return`. Erlauben träge Auswertung (*Lazy Evaluation*). Berechnen Werte erst bei Bedarf (spart RAM).
- *Lambda:* Anonyme Einzeiler: `lambda x, y: x + y`
- `map(func, iter)`: Wendet Funktion auf alle Elemente an.
- `filter(cond, iter)`: Behält nur Elemente, bei denen die Bedingung True liefert.
- `reduce(func, iter)`: Reduziert Iterable schrittweise auf Endwert (braucht `functools`).
- `*args` / `**kwargs`: Nimmt variable Argumente als *Tupel* (`args`) bzw. *Dict* (`kwargs`).

== Exceptions (try-except-else-finally)
```python
try:
    wert = int("abc") # Wirft ValueError
except ValueError as e:
    print("Falscher Typ!")
except Exception as e:
    print("Fängt alle restlichen Fehler")
else:
    print("Läuft NUR, wenn KEIN Fehler auftrat")
finally:
    print("Läuft IMMER (gut für Aufräumarbeiten/close)")
```

== Kontextmanager & CSV-Handling
```python
# CSV Schreiben (ohne csv-Modul)
daten = [["ID", "Name"], [1, "Alice"], [2, "Bob"]]

with open("daten.csv", "w", encoding="utf-8") as f:
    for zeile in daten:
        # Alle Elemente in Strings umwandeln und mit Semikolon verbinden
        zeile_string = ";".join(str(element) for element in zeile)
        f.write(zeile_string + "\n")


# CSV Lesen (ohne csv-Modul)
with open("daten.csv", "r", encoding="utf-8") as f:
    for zeile in f:
        # Zeilenumbruch (.strip) entfernen und am Semikolon trennen
        werte = zeile.strip().split(";")
        print(werte)
```

= 4. Objektorientierte Programmierung (OOP)

== Klassen, Sichtbarkeiten & UML
- *Public (`name`):* Überall les/schreibbar (UML: `+`)
- *Protected (`_name`):* Nur Konvention, nicht strikt (UML: `#`)
- *Private (`__name`):* Aktiviert *Name Mangling* -> wird intern zu `_Klasse__name`. Direkter Zugriff von außen wirft `AttributeError`! (UML: `-`)
- *UML-Beziehungen:* Leere, geschlossene Pfeilspitze = *Vererbung*. Einfache Linie = *Assoziation*.

```python
from abc import ABC, abstractmethod

class Konto(ABC): # Abstrakte Basisklasse
    bank_name = "Sparkasse" # Klassenattribut (statisch, geteilt von allen)

    def __init__(self, inhaber):
        self.inhaber = inhaber   # Public (+)
        self.__saldo = 0         # Private (-)

    @property
    def saldo(self):             # GETTER (Aufruf ohne Klammern: k.saldo)
        return self.__saldo

    @saldo.setter
    def saldo(self, wert):       # SETTER (Zuweisung: k.saldo = 100)
        if wert < 0: raise ValueError()
        self.__saldo = wert

    @abstractmethod
    def sprich(self): pass       # MUSS in Subklasse überschrieben werden

    @classmethod
    def von_string(cls, string): # Factory (erhält Klasse als 'cls')
        return cls(string)

    @staticmethod
    def info():                  # Braucht weder self noch cls
        return "Bank-Info"
```

= 5. Testing & Binärdaten

- *TDD Zyklus:* Red (Test schlägt fehl) -> Green (Test klappt) -> Refactor (Code aufräumen).
- *Pytest Error Check:* `with pytest.raises(TypeError):`
- *Binärdateien:* Modus `rb` (Lesen) oder `wb` (Schreiben).
    - `bytes`: *Immutable* (`b"Hello"`)
    - `bytearray`: *Mutable* (`bytearray(b"Hello")`)