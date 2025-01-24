# Script MATLAB per la Ricerca Operativa

Questi sono script che ho implementato per esercizio durante un corso di ricerca operativa.
Si noti che gli script sono stati realizzati per puro scopo educativo, e sono ben lontani dall'essere ottimizzati per applicazioni reali.

Gli script sono organizzati in funzioni, divise fra le subdirectory:

| Categoria | Subdirectory | Descrizione | 
| - | - | - |
| Programmazione lineare | `lp` | Funzioni per la gestione dei poliedri, conversione primale / duale e soluzioni di entrambi, simplesso primale e duale e ausiliari. | 
| Programmazione lineare su grafi | `glp` | Funzioni per la gestione dei grafi, simplesso per flussi, cammini minimi, flussi massimi e tagli minimi. |
| Programmazione lineare intera | `ilp` | Tagli di Gomory, Branch and Bound per caricamento binario e intero, e per TSP simmetrico e asimmetrico |
| Programmazione non lineare | `nlp` | Algoritmi di NLP su una e più variabili, metodo di Franke-Wolfe, metodo del gradiente proiettato |

Una documentazione più accurata degli algoritmi usati di quella che viene fatta nel codice può trovarsi nei [miei appunti](https://github.com/seggiani-luca/appunti-or) o nel testo _M. Pappalardo, Ricerca Operativa, Pisa University Press, 2010_.
