/*
 * PUNTO 3: Tabla de símbolos dinámica con CHAINING
 *
 * ¿Por qué chaining y no rehashing?
 *   - Rehashing: cuando la tabla se llena, hay que reubicar todas las entradas.
 *     Eso rompe el orden de inserción y complica mantener los números de línea.
 *   - Chaining: la tabla nunca muere. Si hay colisión, malloc() crea un nuevo
 *     nodo y lo encadena. Simple, sin perder nada.
 *
 * Estructura visual:
 *   symtab[0] --> [palabra_A] --> [palabra_B] --> NULL
 *   symtab[1] --> NULL
 *   symtab[2] --> [palabra_C] --> NULL
 *
 * Lex detecta las palabras; la tabla las almacena dinámicamente.
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* ---------- Tabla de símbolos con chaining ---------- */
#define NHASH 29
#define MULT  31

int lineno = 1;

typedef struct Nref {
    int lineno;
    struct Nref *next;
} Nref;

typedef struct Nword {
    char  *word;
    Nref  *refs;
    struct Nword *next;   /* <-- enlace del chaining */
} Nword;

Nword *symtab[NHASH];   /* inicialmente todo NULL */

/* Hash */
unsigned int symhash(const char *str) {
    unsigned int h = 0;
    while (*str) {
        h = h * MULT + (unsigned char)tolower(*str);
        str++;
    }
    return h % NHASH;
}

/*
 * lookup con chaining:
 *   - Recorre la cadena en symtab[h]
 *   - Si encuentra la palabra, la devuelve
 *   - Si NO la encuentra, usa malloc() para crear una entrada nueva
 *     y la encadena al frente: NUNCA falla por tabla llena
 */
Nword *lookup(const char *word) {
    unsigned int h = symhash(word);

    /* Recorrer la cadena */
    for (Nword *np = symtab[h]; np; np = np->next)
        if (strcasecmp(np->word, word) == 0)
            return np;   /* encontrada en la cadena */

    /* No está: creamos nueva entrada con malloc */
    Nword *np = malloc(sizeof(Nword));
    if (!np) { perror("malloc"); exit(1); }

    np->word = strdup(word);
    np->refs = NULL;
    np->next = symtab[h];    /* encadenar al frente */
    symtab[h] = np;

    printf("  [chaining] Nueva entrada '%s' en slot %u\n", word, h);
    return np;
}

/* Agregar referencia de línea */
void addref(const char *word, int ln) {
    Nword *np = lookup(word);
    Nref  *rp = malloc(sizeof(Nref));
    if (!rp) { perror("malloc"); exit(1); }
    rp->lineno = ln;
    rp->next   = np->refs;
    np->refs   = rp;
}

/* Imprimir tabla final */
void print_table() {
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

/* Liberar toda la memoria */
void symtab_free() {
    for (int i = 0; i < NHASH; i++) {
        Nword *np = symtab[i];
        while (np) {
            Nword *nw = np->next;
            Nref  *rp = np->refs;
            while (rp) { Nref *nr = rp->next; free(rp); rp = nr; }
            free(np->word);
            free(np);
            np = nw;
        }
    }
}
%}

%%

[a-zA-Z]+   {
    /* Lex encontró una palabra: la insertamos en la tabla dinámica */
    addref(yytext, lineno);
}

\n          { lineno++; }

.           { /* ignorar espacios y puntuación */ }

%%

int yywrap() { return 1; }

int main() {
    yylex();
    print_table();
    symtab_free();
    return 0;
}
