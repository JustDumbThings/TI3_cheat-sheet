```c 
// Adresse printen:
  printf("Adresse %p\n", &a);


// Inhalt des Pointers printen (nicht so wichtig)
   printf("Inhalt pointer p: %p\n",p);


// Zugriff auf das Element auf das der Pointer //zeigt printen
 printf("Element auf das Pointer zeigt: %d\n", *p);

// setzen eines wertes an einer Adresse
  *((volatile uint16_t*)0x00F3B404) = 0xFFFF;
// oder
 volatile uint8_t *p = (volatile uint8_t *)ADRESS;
  *p = 1;
```