# Programmazione lineare su grafi

Queste funzioni lavorano con gli oggetti `digraph` forniti dalla libreria di base di MATLAB, appositamente complementati da informazioni riguardanti i **bilanci** ai *nodi* e i **costi** e le **capacità** agli *archi*.
La funzione `create_cap_flow_graph()` è delegata alla creazione di grafi di flusso capacitato di questo tipo, fornendo un vettore dei bilanci e un array di celle di archi (indicati da nodi di partenza e arrivo, costo e capacità), come argomenti:

```matlab
>> budgets = [-2 0 0 2];
>> edges = {[1, 2, 2, 3], [1, 3, 4, 5], [3, 2, 4 2], [2, 4, 5, 6], [3, 4, 5, 7]};
>> CFG = create_cap_flow_graph(budgets, edges); % CFG è il grafo di flusso capacitato
>> p = plot(CFG); % opzionale, disegno il grafo
```

Esistono anche le funzioni `create_flow_graph()`, per grafi con capacità infinite (usati per il flusso non capacitato e per i cammini minimi), e `create_cap_graph()` , per grafi con costi nulli (usati per il flusso massimo e per i tagli minimi).

Il grafo così creato può essere visualizzato, oltre che con la `plot()`, accedendo alle tabelle dei nodi e degli archi:
```vim
>> CFG.Nodes
ans =
  4×1 table
    Budgets
    _______
      -2   
       0   
       0   
       2   
>> CFG.Edges
ans =
  5×3 table
    EndNodes    Costs    Caps
    ________    _____    ____
     1    2       2       3  
     1    3       4       5  
     2    4       4       2  
     3    2       5       6  
     3    4       5       7  
```

A questo punto si possono usare le varie funzioni fornite, fra cui riportiamo quelle che implementano gli algoritmi più importanti.
Si nota che la maggior parte di queste funzioni accettano un ultimo argomento, `verbose`, che permette di stampare, in corso di esecuzione, informazioni sui passaggi intermedi.
`verbose` è un intero, che restituisce per valori crescenti maggiori di zero più informazioni sul funzionamento interno (ad esempio, 0 o l'omissione stessa di `verbose` non stampa nulla, 1 stampa basi e indici entranti e uscenti, 2 stampa soluzioni intermedie e via dicendo).

## Simplesso per flussi
Il simplesso per flussi è implementato dalla `min_flow_simplex()`.
Questa funzione richiede una base di partenza, cioè una partizione TLU rappresentata come array di celle di array di vettori a due elementi (che rappresentano i nodi di partenza e arrivo di un arco).
La struttura della TLU può essere qualsiasi, finché si specificano la partizione T e U:

```matlab
>> TLU = {{[1, 2], [1, 3], [2, 4]}, {}}; % si specificano T e U, con U fra l'altro vuota
```

A questo punto si può chiamare la `min_flow_simplex()` con la base inserita:
```matlab
>> min_flow_simplex(CFG, TLU)
ans = 
  digraph with properties:

    Edges: [5×2 table]
    Nodes: [4×0 table]
```
e consultare i flussi ottenuti, che verranno inseriti nella tabella degli archi:
```vim
>> ans.Edges
ans =
  5×2 table
    EndNodes    Flows
    ________    _____
     1    2       2  
     1    3       0  
     2    4       2  
     3    2       0  
     3    4       0  
```

Una base ammissibile si può ottenere anche attraverso l' apposita `feasible_min_flow()`:
```matlab
>> feasible_min_flow(CFG);
```
che restituirà direttamente una partizione TLU ben formata per l'uso con `min_flow_simplex()`.

## Cammini minimi
La `shortest_path_tree()` accetta un grafo nella forma vista finora e applica Dijsktra per trovare l'albero dei cammini minimi a partire da un nodo dato:
```matlab
>> shortest_path_tree(CFG, 1) % trova i cammini minimi a partire dal nodo 1
ans = 
  digraph with properties:

    Edges: [3×2 table]
    Nodes: [4×0 table]
```

Ancora una volta, i risultati ottenuti vengono messi nella tabella degli archi:
```vim
>> ans.Edges
ans =
  3×2 table
    EndNodes    Costs
    ________    _____
     1    2       2  
     1    3       4  
     2    4       6  
```

## Flusso massimo - taglio minimo
Per il flusso minimo e il taglio minimo è predisposta la funzione `max_flow_min_cut()`, che prende in argomento il grafo, il nodo sorgente e il nodo destinzazione, e restituisce il grafo dei flussi e il taglio minimo:
```matlab
>> [ans, cut] = max_flow_min_cut(CFG, 1, 4) % restituisce il flusso massimo fra i nodi 1 e 4
ans = 
  digraph with properties:

    Edges: [5×2 table]
    Nodes: [4×0 table]
cut =
     1     2
```

Anche qui la tabella degli archi contiene i flussi ottimi:
```vim
>> ans.Edges
ans =
  5×2 table
    EndNodes    Flows
    ________    _____
     1    2       2  
     1    3       5  
     2    4       2  
     3    2       0  
     3    4       5  
```


Altre funzioni, sopratutto di utilità per il calcolo di soluzioni intermedie o la conversione fra rappresentazioni delle basi, sono documentate nelle implementazioni stesse.
In ogni caso, si consiglia di provare a fornire il parametro `verbose` con valore 1 o 2 per ottenere più informazioni.
