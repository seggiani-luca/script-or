# Programmazione lineare intera

Queste funzioni implementano algoritmi di risoluzione per problemi di programmazione lineare intera, sia attraverso i *piani di taglio*, che attraverso algoritmi *branch and bound*.

## Piani di taglio

La funzione `gomory_cut()` implementa un algoritmo basato sul teorema di Gomory per i piani di taglio, che restituisce disequazioni valide per la restrizione del dominio di un problema lineare all'insieme di copertura dei suoi punti interi.

Notare che l'algoritmo viene eseguito su una versione del problema riportata al formato duale standard (con vincoli di uguaglianza). 
Nel caso di problemi con soluzioni a componenti negative, questo potrebbe generare delle incompatibilità.
Si lascia all'utente il compito di portare il problema in formati che non diano problemi, magari agendo sui segni delle diseguaglianze.

Gli argomenti da fornire sono quindi i parametri del problema (vettore dei costi, matrice dei vincoli e vettore dei vincoli).
A questo punto la funzione restituirà due matrici simboliche:
- `cuts`: corrispondente ai tagli realizzati sulle variabili introdotte in fase di conversione al duale standard;
- `normalized_cuts`: corrispondente agli stessi tagli, ma definiti sulle variabili originali del problema.

Un esempio di esecuzione è il seguente:

```matlab
>> c = [0.3, 0.4];
>> A = [3, 5; 4, 4];
>> b = [15, 16];
>> [cuts, norm_cuts] = gomory_cut(c, A, b)
cuts =
[0.5 <= 0.5*x3 + 0.625*x4, 0.5 <= 0.5*x3 + 0.625*x4]
norm_cuts =
[-17.0 <= - 4.0*x1 - 5.0*x2, -17.0 <= - 4.0*x1 - 5.0*x2]
```

Come notiamo, il taglio generato è utile al ricavo di un approssimazione migliore della soluzione intera del problema:

```matlab
>> primal_simplex(c, A, b, B)
ans =
    2.5000
    1.5000
[...] % eseguo un taglio e aggiorno A e b
>> A = [3, 5; 4, 4; 4, 5];
>> b = [15, 16, 17];
>> B = feasible_primal_simplex(c, A, b); % non so più qual'è una base ammissibile, la genero
>> primal_simplex(c, A, b, B)
ans =
    2.0000
    1.8000
```

## Branch and bound

La funzione `branch_and_bound()` fornisce un implementazione generale del metodo del *branch and bound* per l'ottimizzazione intera.
Questa richiede i seguenti argomenti:
- `data`: una cella (o un oggetto di qualsiasi altro tipo) che contiene i dati del problema;
> ⚠️ **Attenzione:** il campo `data` è effettivamente inutile, in quanto le informazioni necessarie agli handle di funzione sono già comprese nella *closure* delle funzioni stesse. L'autore si prenderà, tempo permettendo, la briga di correggere l'errore e rielaborare gli algoritmi già implementati sulla base di questa funzione.

- `inferior_eval`: un handle di funzione che manipola `data` e i vincoli attivi, e ottiene una valutazione *inferiore* del sottoproblema corrispondente;
- `superior_eval`: un handle di funzione che manipola `data` e i vincoli attivi, e ottiene una valutazione *superiore* del sottoproblema corrispondente;

- `get_constraints`: un handle di funzione che ottiene una nuova lista di vincoli a partire da un dato nodo. 

L'algoritmo costruisce l'albero di branch attraverso queste funzioni, restituendo l'albero stesso, il valore ottimo e l'argomento della funzione obiettivo che lo ottiene.

L'utilità della funzione `branch_and_bound()` sta principalmente negli wrapper messi a disposizione per la risoluzione di problemi di ottimizzazione intera di vario tipo, che vengono riportati in seguito.

### Zaino binario e intero

`binary_knapsack()` e `integer_knapsack()` sfruttano il metodo del branch and bound per la risoluzione, rispettivamente, di problemi di zaino binario e intero.
Gli argomenti da fornire in entrambi i casi sono `values`, il vettore dei valori, `weights`, il vettore dei pesi, e `maximum`, il peso massimo supportato.
L'algoritmo sceglie automaticamente le variabili da istanziare sulla base delle soluzioni non intere del rilassato continuo.

Un esempio di esecuzione del caso binario può essere:

```matlab
>> values = [28, 31, 35, 24];
>> weights = [12, 9, 7, 6];
>> max = 17;
>> [opt_arg, opt, b_tree] = binary_knapsack(values, weights, max)
opt_arg =
     0
     1
     1
     0
opt =
    66
b_tree = 
  digraph with properties:

    Edges: [8×1 table]
    Nodes: [9×2 table]
```

Mentre per quanto riguarda il caso intero si ha:

```matlab
[...] % stessi argomenti di prima
>> [opt_arg, opt, b_tree] = integer_knapsack(values, weights, max)
opt_arg =
     0
     0
     2
     0
opt =
    70
b_tree = 
  digraph with properties:

    Edges: [7×1 table]
    Nodes: [8×2 table]
```

### TSP asimmetrico e simmetrico

`asymmetric_TSP` e `symmetric_TSP` sfruttano il metodo del branch and bound per la risoluzione, rispettivamente, di problemi del commesso viaggiatore asimmetrici e simmetrici.
La prima si basa sull'implementazione dell'algoritmo delle toppe presente in `patching_algorithm()`, mentre la seconda si basa sulle implementazioni degli algoritmi del nodo più vicino e del k-albero presenti in `closeset_node()` e `k_tree()`.

Gli argomenti da fornire sono `costs`, la matrice dei costi, per il problema asimmetrico, e `costs`, `k` e `from` per il problema simmetrico, dove `k` è la k del k-albero e `from` e il nodo di partenza per l'applicazione dell'algoritmo del nodo più vicino.
Le funzioni accettano inoltre un argomento `constraints`, una cella di vettori che indica quali archi instanziare nell'esplorazione dell'albero di enumerazione.

Un esempio di esecuzione del caso asimmetrico può essere:

```matlab
>> costs = [0, 33, 13, 25, 33;
            33, 0, 46, 58, 76;
            39, 33, 0, 12, 30;
            35, 29, 12, 0, 23;
            60, 54, 30, 23, 0];
>> constraints = {[3, 2], [2, 1]};
>> [opt_arg, opt, b_tree] = asymmetric_TSP(costs, constraints)
opt_arg =
  1×5 cell array
    {[1 3]}    {[3 5]}    {[5 4]}    {[4 2]}    {[2 1]}
opt =
   128
b_tree = 
  digraph with properties:

    Edges: [4×1 table]
    Nodes: [5×2 table]
>> plot(b_tree) % opzionale, stampo l'albero di enumerazione
```

Mentre per quanto riguarda il caso asimmetrico si ha:

```matlab
>> costs = [29, 24, 28, 47;
            0, 18, 94, 61;
            0, 0, 53, 26;
            0, 0, 0, 20];
>> constraints = {[1, 3], [2, 3]};
>> k = 3;
>> from = 3;
>> [opt_arg, opt, b_tree] = symmetric_TSP(costs, constraints, from, k)
opt_arg =
  1×5 cell array
    {[3 2]}    {[2 1]}    {[1 4]}    {[4 5]}    {[5 3]}
opt =
   121
b_tree = 
  digraph with properties:

    Edges: [4×1 table]
    Nodes: [5×2 table]
>> plot(b_tree) % come sopra
```

Si nota poi che esiste una funzione `sym_to_asym()` per la conversione della matrice dei costi del problema simmetrico nella forma tipica del problema asimmetrico, nel caso si volesse usare l'algoritmo delle toppe anzichè quelli disposti per il TSP simmetrico.
