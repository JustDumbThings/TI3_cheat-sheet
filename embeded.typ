#import "styles.typ": *

#align(center)[
= Embedded C Cheat Sheet
Prüfungsrelevante Syntax, Speicher & Hardware
]

= 1. Build-Prozess & C-Toolchain

#table(
columns: 3,
[Werkzeug], [Eingabeformat], [Ausgabeformat],
[C-Präprozessor], [C-Code (.c, .h)], [Erweiterter C-Code (Makros aufgelöst, Includes eingefügt)],
[C-Compiler], [Erweiterter C-Code], [Assemblercode (.s oder .asm)],
[Assembler], [Assemblercode], [Maschinencode / Object-Code (.o)],
[Linker], [Maschinencode (.o + Libs)], [Ausführbare Datei (.elf, .bin, .hex) + Map-File (.map)]
)
Hinweis: Das .map-File des Linkers ist essenziell, um zu prüfen, wie viel RAM/Flash verbraucht wird und wo Variablen im Speicher exakt liegen.

= 2. Speicher-Layout, Variablen & Pointer

Ein kompiliertes C-Programm wird im Speicher in spezifische Segmente unterteilt:

== Speicherbereiche (Memory Layout)

- .text / .rodata (Flash/ROM): Speichert ausführbaren Maschinencode (.text) und Konstanten/Strings (.rodata). Read-Only!

- .data (RAM): Speichert initialisierte globale/statische Variablen (z.B. int x = 5;). Initialwerte werden beim Booten vom Flash ins RAM kopiert.

- .bss (RAM): Speichert uninitialisierte globale/statische Variablen (z.B. int y;). Wird vom Startup-Code mit 0 initialisiert.

- Heap (RAM): Wächst "nach oben". Für dynamischen Speicher (malloc, free). Bei Embedded oft vermieden (Fragmentierungsgefahr!).

- Stack (RAM): Wächst "nach unten". Für lokale Variablen, Funktionsparameter, Rücksprungadressen. Automatische Verwaltung. Gefahr: Stack Overflow.

*Keywords:*
  - `volatile`: Verbietet dem Compiler Optimierungen und Caching. Zwingend für Hardware-Register, ISR-Variablen und geteilte RTOS-Daten.
  - `static`: Lokal: Behält den Wert zwischen Aufrufen (Speicherung im RAM, nicht Stack). Global: Begrenzt Sichtbarkeit strikt auf die aktuelle `.c`-Datei.
  - `const`: Schreibschutz. Legt Daten platzsparend im Flash (`.rodata`) statt im RAM ab. (Klausurfalle: `const volatile` für Read-Only HW-Register).
  - `extern`: Deklariert Variablen/Funktionen aus anderen `.c`-Dateien. Der Linker verbindet die Adressen später.
  - `inline`: Fügt den Funktionscode direkt an der Aufrufstelle ein, um den Performance-Overhead eines echten Funktionsaufrufs zu sparen.
== Wichtige Speicherklassen (Storage Classes)

static:

Lokale Variable: Behält ihren Wert zwischen Funktionsaufrufen (wird in .data/.bss statt auf dem Stack gespeichert).

Globale Variable / Funktion: Begrenzt die Sichtbarkeit strikt auf die aktuelle .c-Datei (Kapselung).

const: Deklariert Werte als unveränderlich. Der Compiler legt diese meist ins .rodata-Segment (spart wertvolles RAM).

extern: Deklariert eine Variable, die in einer anderen .c-Datei definiert wurde.

== Pointer & Call-by-Reference
Pointer speichern Speicheradressen. Wichtig, um große Structs effizient zu übergeben oder mehrere Rückgabewerte zu erzeugen.

&variable: "Adresse-von" Operator.

\*pointer: Dereferenzierungs-Operator.

```c
int div_int(int a, int b, int *res) {
if (b == 0) return 1; // Fehlercode
*res = a / b;         // Wert an die übergebene Adresse schreiben
return 0;             // SUCCESS
}
```

== Zuweisungen bei Pointern (Klausurfalle!)
```c
struct data *old = malloc(sizeof(struct data));
struct data *new = malloc(sizeof(struct data));

old = new;   // FALSCH! Pointer wird umgebogen. Speicher von 'old' ist verloren (Leak)!
*old = *new; // RICHTIG! Kopiert den tatsächlichen INHALT von 'new' nach 'old'.
```
== Wild Pointer, Dangling Pointer & Segmentation Fault

- *Wild Pointer (Wilder Zeiger):* \
  Ein Pointer, der deklariert, aber nicht initialisiert wurde. Er enthält einen zufälligen "Müllwert" aus dem Speicher als Adresse. Das Dereferenzieren eines Wild Pointers führt zu völlig unvorhersehbarem Verhalten oder sofortigen Abstürzen.

  Gegenmaßnahme: Pointer bei der Deklaration immer direkt mit NULL oder einer gültigen Adresse initialisieren (`int *ptr = NULL;`).

- *Dangling Pointer (Hängender Zeiger):*\
  Ein Zeiger, der auf eine Speicheradresse zeigt, die nicht mehr gültig ist oder bereits freigegeben wurde. Der Pointer "hängt" quasi in der Luft.

  Ursachen: 1. Freigabe von Heap-Speicher via free(ptr);, ohne den Pointer danach auf NULL zu setzen. Der Pointer zeigt weiterhin auf die alte Adresse, obwohl der Speicher vom System neu vergeben werden kann.
  2. Rückgabe der Adresse einer lokalen Variable aus einer Funktion (nach dem Verlassen des Stack-Frames ist die Adresse ungültig -> siehe Aufgabe 12).

  Gegenmaßnahme: Nach einem free(ptr); den Zeiger sofort auf NULL setzen (ptr = NULL;).

- *Segmentation Fault (Speicherzugriffsfehler / SIGSEGV):*\ 
  Ein Laufzeitfehler, der auftritt, wenn ein Programm versucht, auf einen Speicherbereich zuzugreifen, für den es keine Berechtigung besitzt oder der physikalisch nicht existiert.

Typische Auslöser in Klausuren:\
Dereferenzieren eines NULL-Pointers.\
Zugriff auf Adressen außerhalb des erlaubten Adressraums des Mikrocontrollers (siehe Aufgabe 5).\
Schreibversuche in Read-Only-Segmente (z. B. Ändern eines Strings im .rodata-Segment).

Ein Pufferüberlauf (Buffer Overflow), der kritische Stack-Bereiche oder Rücksprungadressen überschreibt (siehe Aufgabe 13).

```c
// 1. Wild Pointer
int *wild_ptr;
// *wild_ptr = 42; // KLAUSURFALLE: Undefiniertes Verhalten / Absturz!

// 2. Dangling Pointer durch free()
int dangling_ptr = (int)malloc(sizeof(int));
*dangling_ptr = 100;
free(dangling_ptr); // Speicher ist frei, ptr zeigt immer noch hin
// *dangling_ptr = 50; // FALSCH: Speicher gehört uns nicht mehr!

// Sicheres Pattern:
dangling_ptr = NULL;

// 3. Segmentation Fault Auslöser
int *null_ptr = NULL;
// *null_ptr = 10; // Absturz: Dereferenzierung von NULL
```


= 3. Structs, Alignment, Padding & Endianness

== Speicherausrichtung (Alignment) & Padding

=== Padding
Variablen müssen an Adressen abgelegt werden, die ein Vielfaches ihrer Größe sind (z.B. 32-Bit-int an durch 4 teilbaren Adressen). Der Compiler fügt unsichtbare "Füllbytes" (Padding) ein, um dies zu gewährleisten.

```c
struct bad_layout {
char c1;      // 1 Byte (+ 3 Bytes Padding)
int i;        // 4 Bytes (Muss auf 4-Byte-Grenze liegen)
char c2;      // 1 Byte (+ 3 Bytes Padding am ENDE für Array-Alignment)
}; // sizeof = 12 Bytes!

struct good_layout {
int i;        // 4 Bytes
char c1;      // 1 Byte
char c2;      // 1 Byte
// (+ 2 Bytes Padding am Ende)
}; // sizeof = 8 Bytes! (Nach Größe absteigend sortieren spart RAM!)
```

Um das Padding zu deaktivieren kann das attribute packed verwendet werden:

```C
struct layout {
char c1;      // 1 Byte (+ 3 Bytes Padding)
int i;        // 4 Bytes (Muss auf 4-Byte-Grenze liegen)
char c2;      // 1 Byte (+ 3 Bytes Padding am ENDE für Array-Alignment)
}__attribute__((packed)); // sizeof = 6 Bytes!
```

=== Speichermanipulation

- *memset:* Setzen aller Bytes eines Speicherbereichs auf einen bestimmten Wert\
  `void*memset(void*ptr, intvalue, size_tnum);`

- *memcpy, memmove:*
  Kopieren eines Speicherbereichs\
  `void*memcpy(void*destination, constvoid*source, size_tnum);`\
  memcpy und memmove haben die gleiche Signatur und verhalten sich (bei korrekter Verwendung gleich).\ *Unterschied:* Bei memmove dürfen die Speicherbereiche überlappen bei memcpy nicht.

- *memcmp:* 
  Byteweises vergleichen zweier Speicherbereicheint\
  `memcmp(const void *ptr1, const void *ptr2, size_t num);` 
  `Rückgabewert:<0`: \ 
  Das erste verschiedene Byte hat in Bereich 1 (ptr1) einen kleineren Wert als in Bereich 2 (ptr2)>0: Das erste verschiedene Byte hat in Bereich 1 (ptr1) einen größeren Wert als in Bereich 2 (ptr2) 0: Die Speicherbereiche haben identische Werte
KLAUSURFALLE memcmp(): Da Padding-Bytes zufälligen Müll enthalten, schlägt der direkte Vergleich zweier Structs mit memcmp() oft fehl. Immer die Elemente einzeln vergleichen!

=== Alignment

Um das Alignment an Adresse 0xAB001000 zu berechnen muss man die größte 2er Potenz finden durch die die Adresse restlos teilbar ist:
da $"0xAB001000" / "0x1000"$ 
ein Integer ist, ist das Maximale Alignment $2^12 "Byte"$ also $4 "kibi Byte"$

== Bitfelder (Bitfields)
Erlauben das Packen mehrerer kleiner Werte in ein einzelnes Byte/Wort. Sehr nützlich für Protokoll-Header.
Achtung: Das Layout im Speicher (MSB vs. LSB) ist stark compilerabhängig!
```c
typedef struct {
uint8_t flag1 : 1; // Belegt exakt 1 Bit
uint8_t flag2 : 1;
uint8_t mode  : 6; // Belegt 6 Bits
} status_reg_t;        // sizeof = 1 Byte
```

== Endianness (Byte-Reihenfolge)
Speicherung von Mehrbyte-Variablen (z.B. 0xAABBCCDD) im Speicher:

Little-Endian (ARM Cortex, x86): LSB (DD) auf kleinster Adresse. (Speicher: DD CC BB AA)

Big-Endian (Netzwerkprotokolle): MSB (AA) auf kleinster Adresse. (Speicher: AA BB CC DD)

= 4. Hardwarenahe Programmierung

== Direkter Register-Zugriff & volatile
Um Hardware-Register zu beschreiben, muss eine feste Hex-Adresse gecastet werden. Das Schlüsselwort volatile ist zwingend nötig: Es verbietet dem Compiler, Lese-/Schreibzugriffe wegzuroptimieren oder in Registern zwischenzuspeichern.

```c
// Lese-/Schreibregister (z.B. GPIO Output)
*((volatile uint32_t *)0x40001000) = 0xFFFF;

// KLAUSURFALLE: Read-Only Hardware Register (z.B. ADC-Wert, Status-Flags)
// Muss als 'const volatile' deklariert werden!
// const: Software darf nicht schreiben. volatile: Wert kann sich durch HW ändern.
uint32_t adc_val = *((const volatile uint32_t *)0x40001004);
```

== Bitmanipulation (Bitmasking)
Einzelne Bits verändern, ohne andere zu beeinflussen (N = Bit-Position, 0 = LSB).

Setzen (1): REG |= (1 << N);

Löschen (0): REG &= ~(1 << N);

Umschalten (Toggle): REG ^= (1 << N);

Prüfen: if (REG & (1 << N)) { ... }

= 5. Präprozessor & Makros

Der Präprozessor führt reine Text-Ersetzungen aus.

Include Guards: Verhindern, dass Header mehrfach inkludiert werden (Vermeidung von Redefinition-Errors).
```c
#ifndef MY_HEADER_H
#define MY_HEADER_H
// Deklarationen...
#endif
```

KLAUSURFALLE Makro-Klammerung: Parameter und das gesamte Makro immer klammern!
```c
#define MULT_FALSCH(a, b) a * b
#define MULT_RICHTIG(a, b) ((a) * (b))
int res = MULT_FALSCH(2+3, 4); // Ergibt 2 + 3 * 4 = 14 (FALSCH)
```

= 6. Interrupts, Nebenläufigkeit & RTOS

== Interrupt Service Routinen (ISR)
Unterbrechen das Hauptprogramm asynchron bei Hardware-Events.
Regeln für ISRs:

Kurz und schnell ausführen.

Keine blockierenden Aufrufe (kein printf, malloc, delay, Mutex blockieren).

Globale Variablen, die zwischen ISR und main() geteilt werden, MÜSSEN als volatile deklariert sein. Oft muss der Zugriff in main() durch kurzzeitiges Deaktivieren der Interrupts atomar gemacht werden.

== RTOS, Semaphoren & Mutexe
Schützen kritische Bereiche vor gleichzeitigem Zugriff (Data Races).

Mutex: Sperrt eine Ressource (Besitzer-Konzept). Task A sperrt, Task A muss entsperren.

Semaphore: Reiner Zähler. Eignet sich zur Signalisierung zwischen Task und ISR (ISR gibt Semaphore frei, Task konsumiert).

Priority Inversion: High-Prio-Task wartet auf Low-Prio-Task, der einen Mutex hält. Medium-Prio-Task unterbricht Low-Prio-Task. High-Prio-Task verhungert. (Lösung: Priority Inheritance).

Deadlock: Tasks blockieren sich gegenseitig zirkulär (A wartet auf B, B wartet auf A).

= 7. Watchdog Timer (WDT)
Ein Hardware-Timer, der das System (Microcontroller) automatisch neu startet (Reset), wenn er nicht regelmäßig von der Software zurückgesetzt wird ("kicking" / "feeding the dog").

Zweck: System-Recovery bei Software-Hängern (Endlosschleifen, Deadlocks) oder starken EMI-Störungen, die den Program-Counter verfälschen.

Regel: Der WDT darf niemals in einem Interrupt gefüttert werden (da Interrupts weiterlaufen könnten, auch wenn die main() in einem Deadlock hängt).

= 8. Wichtige Standard-Funktionen (I/O)

== printf() & Formatierung
printf benötigt viel Flash und Laufzeit. In Embedded oft per Retargeting auf UART umgeleitet.

Format-Specifier:

- %d / %i: Vorzeichenbehaftet (int)

- %u: Vorzeichenlos (unsigned)

- %x / %X: Hexadezimal -> Sehr wichtig für Register!

- %s: String / %c: Char / %p: Pointer

Formatierung (Klausur-Klassiker):

%04X: Hex-Wert mit führenden Nullen auf exakt 4 Stellen auffüllen (z.B. 0x00FF).

%8d: Integer rechtsbündig, Breite 8 (mit Leerzeichen aufgefüllt).

%.2f: Float auf 2 Nachkommastellen runden.


#pagebreak()
= Code Beispiele

== Pointer 

#include "code_examples/pointer.typ"

== Makefile
#include "code_examples/Makefile.typ"

== Linker Skripte

#include "code_examples/linkerscript.typ"

== Linked Lists
#include "code_examples/linkedlists.typ"
