/*
 * PUNTO 1: ¿Por qué ^.*\n no funciona?
 *
 * En lex, "." tampoco coincide con '\n' por defecto.
 * Por eso ^.*\n nunca matchea una línea completa.
 *
 * SOLUCIÓN:
 *   Usamos la regla: [^\n]*\n
 *   Que significa: cualquier carácter excepto '\n', seguido de '\n'
 *   Esto sí captura una línea entera.
 *
 * Este programa imprime cada línea que contenga el patrón "hola"
 * (sin importar mayúsculas).
 */

%{
#include <stdio.h>
#include <string.h>

int lineno = 1;
%}

/* Con esta opción "." tampoco matchea '\n', lo cual es el comportamiento normal */
/* Para matchear líneas completas usamos [^\n]* en su lugar                      */

%%

[^\n]*"hola"[^\n]*\n   {
    /* Línea completa que contiene "hola" (minúsculas) */
    printf("Línea %d: %s", lineno, yytext);
    lineno++;
}

[^\n]*"Hola"[^\n]*\n   {
    /* Línea completa que contiene "Hola" */
    printf("Línea %d: %s", lineno, yytext);
    lineno++;
}

[^\n]*"HOLA"[^\n]*\n   {
    /* Línea completa que contiene "HOLA" */
    printf("Línea %d: %s", lineno, yytext);
    lineno++;
}

\n      { lineno++; }   /* líneas que no contienen el patrón */
.       { /* ignorar resto de caracteres */ }

%%

int yywrap() { return 1; }

int main() {
    printf("=== Líneas que contienen 'hola' (cualquier forma) ===\n");
    yylex();
    return 0;
}
