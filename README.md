# Ejercicios-2-mar


---

## Cómo compilar y ejecutar

**Paso 1:** flex convierte el `.l` en un `.c`
```bash
flex punto1.l
flex punto2.l
flex punto3.l
```

**Paso 2:** gcc compila el `.c` y genera el ejecutable `.out`
```bash
cc lex.yy.c -o punto1.out
cc lex.yy.c -o punto2.out
cc lex.yy.c -o punto3.out
```

**Paso 3:** ejecutar pasando el archivo de texto
```bash
./punto1.out < texto.txt
./punto2.out < texto.txt
./punto3.out < texto.txt
```

---

## Punto 1 — ¿Por qué `^.*\n` no funciona?

El `.` en lex no coincide con `\n`. Entonces `^.*` nunca llega a ver el salto
de línea y el patrón no puede satisfacerse.

**Solución:** usar `[^\n]*\n`, que significa "cualquier carácter excepto `\n`,
seguido de `\n`". Eso sí captura una línea completa.

---

## Punto 2 — Concordancia sin distinguir mayúsculas

Se modifican dos cosas sin guardar copias extra de las palabras:

- `symhash()` aplica `tolower()` al calcular el hash → "Hola" y "hola" caen en el mismo slot.
- `lookup()` usa `strcasecmp()` en vez de `strcmp()` → las reconoce como iguales al comparar.

La palabra se guarda tal como apareció la primera vez, pero el sistema la trata
como la misma sin importar cómo venga escrita después.

---

## Punto 3 — Chaining vs Rehashing: ¿cuál es mejor?

**Chaining es mejor** para el cross-referenciador.

Con rehashing, al llenarse la tabla hay que reubicar todas las entradas, lo que
desordena las entradas y complica mantener los números de línea en orden.

Con chaining nunca se llena: si hay colisión, `malloc()` crea un nuevo nodo y
lo encadena. Las entradas no se mueven y los números de línea quedan intactos.
