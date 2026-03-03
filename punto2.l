/*
 * PUNTO 2: Concordancia que ignora mayúsculas/minúsculas
 *
 * Lex reconoce las palabras. Luego las guardamos en una tabla
 * usando tolower() para el hash y strcasecmp() para comparar.
 * Así "Hola", "hola" y "HOLA" se tratan como la misma palabra.
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* ---------- Tabla de símbolos ---------- */
#define NHASH 29
#define MULT  31

int lineno = 1;

typedef struct Nref {
    int lineno;
    struct Nref *next;
} Nref;

typedef struct Nword {
    char *word;
    Nref *refs;
    struct Nword *next;
} Nword;

Nword *symtab[NHASH];

/* Hash que ignora mayúsculas */
unsigned int symhash(const char *str) {
    unsigned int h = 0;
    while (*str) {
        h = h * MULT + (unsigned char)tolower(*str);  /* tolower aquí */
        str++;
    }
    return h % NHASH;
}

/* Buscar o crear entrada; compara ignorando mayúsculas */
Nword *lookup(const char *word) {
    unsigned int h = symhash(word);
    for (Nword *np = symtab[h]; np; np = np->next)
        if (strcasecmp(np->word, word) == 0)   /* strcasecmp aquí */
            return np;

    /* No existe: crear con malloc */
    Nword *np = malloc(sizeof(Nword));
    np->word = strdup(word);
    np->refs = NULL;
    np->next = symtab[h];
    symtab[h] = np;
    return np;
}

/* Agregar número de línea a una palabra */
void addref(const char *word, int ln) {
    Nword *np = lookup(word);
    Nref  *rp = malloc(sizeof(Nref));
    rp->lineno = ln;
    rp->next   = np->refs;
    np->refs   = rp;
}

/* Imprimir la concordancia al final */
void print_concordance() {
    printf("\n%-20s %s\n", "PALABRA", "LÍNEAS");
    printf("%-20s %s\n", "-------", "------");
    for (int i = 0; i < NHASH; i++)
        for (Nword *np = symtab[i]; np; np = np->next) {
            printf("%-20s ", np->word);
            for (Nref *rp = np->refs; rp; rp = rp->next)
                printf("%d ", rp->lineno);
            printf("\n");
        }
}
%}

%%

[a-zA-Z]+   {
    /* Lex reconoció una palabra: la registramos con su número de línea */
    addref(yytext, lineno);
}

\n          { lineno++; }   /* contamos líneas */

.           { /* ignorar espacios, puntuación, etc. */ }

%%

int yywrap() { return 1; }

int main() {
    yylex();           /* lex procesa todo el input */
    print_concordance();
    return 0;
}
