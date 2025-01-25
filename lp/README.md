# Programmazione lineare
Queste funzioni implementano principalmente algoritmi di risoluzione di problemi di programmazione lineare primali e duali, nei formati standard descriti in _M. Pappalardo, Ricerca Operativa_ (si veda la pagina iniziale del progetto), adattati per quanto possibile al formato che si aspetta la funzione `linprog()` dell'Optimization Toolbox di MATLAB.

Nello specifico, si hanno:
- **Formato primale:** vettore costo `c`, matrice dei vincoli `A` e vettore dei vincoli `b`;
- **Formato duale:** vettore costo `b`, matrice dei vincoli `A'` (ci si aspetta che la matrice venga fornita trasposta, cioè che venga fornita la corrispondente al primale associato) e vettore dei vincoli `c`.

Su questi formati sono disponibili le seguenti funzioni:

## Simplesso primale e duale
Implementazioni del simplesso che lavorano sul formato primale e duale standard si trovano in `primal_simplex()` e `dual_simplex()`.
Ad esempio. per il simplesso primale:

```matlab
>> c = [0.3 0.4];
>> A = [3 5; 4 4; -1 0; 0 -1];
>> b = [15 16 0 0];
>> [optimum, base] = primal_simplex(c, A, b, [3, 4]) % richiedo il simplesso a partire dalla base 3, 4, e metto la base ottima in base
optimum =
    2.5000
    1.5000
base =
     1     2
```
e per il simplesso primale, notando che la scelta di nomenclatura delle variabili risulta in una conversione immediata fra primale e duale:
```matlab
>> [optimum, base] = dual_simplex(c, A, b, [1, 4])
optimum =
    0.0500    0.0375         0         0
base =
     1     2
```

Queste funzioni ottengono gli stessi risultati (se nulla va storto) di `linprog()` con le dovute modifiche agli input (ad esempio, `linprog()` minimizza il primale mentre `primal_simplex()` lo massimizza, come da formato primale standard), con il vantaggio di fornire passaggi intermedi per valori del parametro `verbose` maggiori di 0.

## Simplesso ausiliare e duale
Un'implementazione del simplesso duale ausiliario per la ricerca di una base di partenza si trova in `feasible_dual_simplex()`, che prende in argomento solo le variabili del problema:

```matlab
>> feasible_dual_simplex(c, A, b)
ans =
     1     2
```

Una funzione simile, `feasible_primal_simplex()`, è fornita per il primale:
```matlab
>> feasible_primal_simplex(c, A, b)
ans =
     3     4
```
> ⚠️ **Attenzione:** MATLAB c'è l'ha a morte con le matrici singolari (e come biasimarlo). C'è un bug noto della `feasible_primal_simplex()` dove, se i primi `n` indici che vengono selezionati ad arbitrio per valutare le disequazioni valide e non, si crea una matrice di base singolare e l'algoritmo fallisce. In questo caso il `feasible_dual_simplex()` dovrebbe essere più sicuro.

Nel caso di problemi che rispettano le condizioni di cui sopra, quindi, si può emulare il comportamento di `linprog()` come segue:
- Si ricava una base ammissibile di partenza con `feasible_primal_simplex()` o `feasible_dual_simplex()`:
```matlab
>> B = feasible_primal_simplex(c, A, b);
```
- Si risolve con il simplesso a partire dalla base ricavata, con `primal_simplex()` o `dual_simplex()`:
```matlab
>> primal_simplex(c, A, b, B) % B è la base precedente, ricavata con feasible_primal_simplex()
ans =
    2.5000
    1.5000
```

Altre funzioni, principalmente di calcolo di risultati intermedi e utilità di conversione (fra cui la `dualize()` vista prima) sono rese disponibili e documentate nel codice.

Si nota che alcune di queste funzioni accettano (come visto sopra) un ultimo argomento, `verbose`, che permette di stampare, in corso di esecuzione, informazioni sui passaggi intermedi. `verbose` è un intero, che restituisce per valori crescenti maggiori di zero più informazioni sul funzionamento interno (ad esempio, 0 o l'omissione stessa di `verbose` non stampa nulla, 1 stampa basi e indici entranti e uscenti, 2 stampa soluzioni intermedie e via dicendo).
