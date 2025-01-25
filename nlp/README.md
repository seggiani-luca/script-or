# Programmazione non lineare

Si implementano diverse funzioni per l'ottimizazione non lineare vincolata e non, in una variabile o in più variabili.
Nello specifico, gli algoritmi su più variabili cercano minimi, e non massimi (quelli su una variabile cercano soltanto punti stazionari).

## Ottimizzazione non vincolata su una variabile

Queste funzioni lavorano su funzioni simboliche (è necessaria la toolbox Symbolic Math di MATLAB), assumendo come variabile reale `x`, cercando punti stazionari.
Restituiscono il punto stazionario, `opt`, e il valore assunto dalla funzione in quel punto `opt_val`.

- `bisect()`: applica l'algoritmo di bisezione al primo argomento `func`, fra gli estremi `a` e `b`:

```matlab
>> syms x;
>> func = x^4 + 2 * x^2 - 3 * x;
>> [opt, opt_val] = bisect(func, 0, 1, 1)
    k       a_k        b_k        x_k        f1(x_k)  
    __    _______    _______    _______    ___________
     0          0          1        0.5           -0.5
     1        0.5          1       0.75         1.6875
     2        0.5       0.75      0.625        0.47656
     3        0.5      0.625     0.5625      -0.038086
     4     0.5625      0.625    0.59375        0.21228
     5     0.5625    0.59375    0.57812       0.085403
     6     0.5625    0.57812    0.57031       0.023241
     7     0.5625    0.57031    0.56641     -0.0075262
     8    0.56641    0.57031    0.56836      0.0078314
     9    0.56641    0.56836    0.56738     0.00014614
    10    0.56641    0.56738    0.56689     -0.0036916
    11    0.56689    0.56738    0.56714     -0.0017732
    12    0.56714    0.56738    0.56726    -0.00081361
    13    0.56726    0.56738    0.56732    -0.00033376
    14    0.56732    0.56738    0.56735    -9.3816e-05
opt =
    0.5674
opt_val =
   -0.9547
```
  
- `exact_min()`: trova il minimo esatto attraverso derivata prima e seconda di `func`:

```matlab
>> [opt, opt_val] = exact_min(func)
opt =
    0.5674
opt_val =
   -0.9547
```
  
- `newton()`: trova una stima dei punti stazionari di `func` a partire da `x0`:

```matlab
>> [opt, opt_val] = newton(func, 1, 1)
    k      x_k       f1(x_k)      f2(x_k)
    _    _______    __________    _______
    0          1             5        16 
    1     0.6875        1.0498    9.6719 
    2    0.57896      0.092081    8.0223 
    3    0.56748    0.00090927    7.8644 
    4    0.56736    9.1024e-08    7.8628 
opt =
    0.5674
opt_val =
   -0.9547
```

- `backtrack()`: applica l'algoritmo di backtracking a partire dalla stima `x0`, con `a` alla condizione di Armijo e `g` moltiplicatore della stima:

```matlab
>> [opt, opt_val] = backtrack(func, 10^-4, 0.5, 1, 1)
    m    g^m * x    f(g^m * x)    armijo 
    _    _______    __________    _______
    0        1             0      -0.0003
    1      0.5       -0.9375            0
opt =
    0.5000
opt_val =
   -0.9375
```

Tutte queste funzioni (tranne la `exact_min()`, che ha poco da dire) prendono poi come argomento sia il parametro `verbose` per la stampa di informazioni sui passaggi intermedi, che un parametro `epsilon` che determina la soglia di nullità per i valori che desideriamo svanire a termine degli algoritmi iterativi (solitamente le derivate prime).
Sostanzialmente, si trasforma qualsiasi espressione: `a == 0` in `abs(a) < epsilon`, per cercare di evitare problemi di approssimazione numerica.

Esiste poi la funzione `wolfe()`, che restituisce i punti di frontiera della regione individuata dal sistema di Armijo-Frank-Wolfe con parametri `a` e `b` sulla funzione `func`.

## Ottimizzazione non vincolata su più variabili

Le funzioni di ottimizzazione libera su più variabili fornite si basano sugli algoritmi riportati sopra (tranne `bisect()`, che risulta scomodo), più un algoritmo a passo costante, e variano il metodo di scelta della direzione di discesa.
I due metodi disponibili sono:

- **Gradiente negato**: si prosegue nella direzione opposta al gradiente;
- **Newton**: come prima, ma si moltiplica il gradiente per l'inversa dell'Hessiana.

Combinando quindi i 3 metodi di scelta del passo con i 2 metodi di scelta delle direzioni si ottengono le funzioni (gli esempi sono solo sul caso a passo fisso, in quanto gli altri sono analoghi):

#### Discesa a gradiente

- `gradient_fixed()`: metodo del gradiente con passo fisso:

```matlab
>> syms x1 x2;
>> func = x1^2 + x2^2 - 5 * x1;
>> x0 = [3, 4];
>> [opt, opt_val] = gradient_fixed(func, x0, 2)
	L:
2
	a:
    0.5000
<------------------------------ Descent step 0 ------------------------------>

x_k:
     3     4

d_k:
    -1    -8
opt =
    2.5000         0
opt_val =
   -6.2500
```

- `gradient_exact()`: metodo del gradiente con ricerca del passo esatto:
- `gradient_backtrack`: metodo del gradiente con backtracking;

#### Metodo di Newton

- `newton_fixed()`: metodo di Newton con passo fisso;

```matlab
>> [opt, opt_val] = newton_fixed(func, x0, 2)
	L:
2
	a:
    0.5000
<------------------------------ Descent step 0 ------------------------------>

x_k:
     3     4

d_k:
   -0.5000   -4.0000
<------------------------------ Descent step 1 ------------------------------>

x_k:
    2.7500    2.0000

d_k:
   -0.2500   -2.0000
<------------------------------ Descent step 2 ------------------------------>

x_k:
    2.6250    1.0000

d_k:
   -0.1250   -1.0000
[...]
<------------------------------ Descent step 15 ------------------------------>

x_k:
    2.5000    0.0001

d_k:
   1.0e-03 *
   -0.0153   -0.1221
opt =
    2.5000    0.0001
opt_val =
   -6.2500
```
  
- `newton_exact()`: metodo di Newton con ricerca del passo esatto;
- `newton_backtrack`: metodo di Newton con backtracking.

I metodi a passo fisso prendono opzionalmente un parametro `a`, altrimenti calcolano il passo ottimo come 1/L, con L costante di Lipschitz di `func`.
