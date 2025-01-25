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

## Ottimizzazione vincolata su più variabili

Si hanno poi due funzioni per l'ottimizzazione vincolata su più variabili: il metodo di Frank-Wolfe implementato in `frank_wolfe()` e il metodo del gradiente proiettato implementato in `projected_gradient()`. 
Entrambe queste funzioni accettano come argomenti la funzione `func`, un poliedro definito dalla matrice `A` e dal vettore `b`, e un punto iniziale `x0`, e restituiscono l'argomento del valore ottimo `opt` e il valore ottimo stesso `opt_val`.

Un esempio di utilizzo per quanto riguarda `frank_wolfe()` è il seguente:

```matlab
>> syms x1 x2 real;
>> func = -2 * x1^2 - 10 * x1 * x2 + 4 * x1 + 10 * x2;
>> A = [-1, -2; -4, 3; 3, -2; 2, 1];
>> b = [-3, -1, 9, 13];
>> x0 = [5/3, 2/3];
>> [opt, opt_val] = frank_wolfe(func, A, b, x0, 2)
<------------------------------ Descent step 0 ------------------------------>
	x_k:
    1.6667    0.6667
	y_k:
     4     5
	func(x_k)
   -3.3333
	func(y_k)
  -166
	c:
   -9.3333
   -6.6667
	d_k:
    2.3333
    4.3333

Phi:
- 112.0*x^2 - 50.666666666666666666666666666667*x - 3.3333333333333333333333333333333

t_k:	     1
[...]
opt =
    4.0556    4.8889
opt_val =
 -166.0556
>> 
```

mentre per quanto riguarda `projected_gradient()` è il seguente:

```matlab
>> [opt, opt_val] = projected_gradient(func, A, b, x0, 2)
<------------------------------ Descent step 0 ------------------------------>
	x_k:
    1.6667    0.6667
	M:
    -1    -2
	H:
    0.8000   -0.4000
   -0.4000    0.2000
	func_1(x_k):
   -9.3333
   -6.6667
	d_k:
    4.8000
   -2.4000

Phi:
69.12*x^2 - 28.8*x - 3.3333333333333333333333333333333

t_hat_k:	    0.2778

t_k:	    0.2083
[...]
opt =
    4.0556    4.8889
opt_val =
 -166.0556
```

## Sistema LKT

Viene fornita una funzione per la valutazione del sistema Lagrange-Khun-Tucker in `lkt()`. 
Questa prende in argomento `func`, una funzione simbolica, e `g` e `h`, due vettori di funzioni simboliche che definiscono rispettivamente i vincoli di diseguaglianza e di uguaglianza.
La funzione restituisce una tabella con tutte le soluzioni trovate al sistema LKT.
Opzionalmente, si può fornire alla funzione un punto `x0`.
In tal caso, la funzione cercherà di trovare il valore dei moltiplicatori in quel punto, se quel punto è soluzione dell'LKT.

Un esempio di utilizzo è il seguente:

```matlab
>> cons1 = -x1 - 2 * x2 + 3;
>> cons2 = -4 * x1 + 3 * x2 + 1;
>> cons3 = 3 * x1 - 2 * x2 - 9;
>> cons4 = 2 * x1 + x2 - 13;
>> cons = [cons1; cons2; cons3; cons4]; % non conosco un modo migliore di farlo
>> lkt(func, cons, [], 2)
	LKT system:
3*lambda3 - 4*lambda2 - lambda1 + 2*lambda4 - 4*x1 - 10*x2 + 4
      3*lambda2 - 2*lambda1 - 2*lambda3 + lambda4 - 10*x1 + 10
                                      -lambda1*(x1 + 2*x2 - 3)
                                     lambda2*(3*x2 - 4*x1 + 1)
                                    -lambda3*(2*x2 - 3*x1 + 9)
                                      lambda4*(2*x1 + x2 - 13)
     x1        x2      lambda1    lambda2    lambda3    lambda4
    _____    ______    _______    _______    _______    _______
    1        0         0          0          0           0     
    3        0         -19/2      0          -1/2        0     
    8/3      1/6       -25/3      0          0           0     
    1        1         -30/11     -20/11     0           0     
    31/46    13/23     0          -25/23     0           0     
    4        5         0          -1/5       0           153/5 
    23/3     -7/3      -130/3     0          0           -20   
    32/17    -57/34    0          0          -75/17      0     
    5        3         0          0          -34/7       212/7 
    73/18    44/9      0          0          0           275/9 
    25       33        0          1572       2238        0
```

o nel caso specifico del punto `[4, 5]`:

```matlab
>> lkt(func, cons, [], 2, [4, 5])
	LKT system:
3*lambda3 - 4*lambda2 - lambda1 + 2*lambda4 - 62
3*lambda2 - 2*lambda1 - 2*lambda3 + lambda4 - 30
                                     -11*lambda1
                                               0
                                      -7*lambda3
                                               0
    x1    x2    lambda1    lambda2    lambda3    lambda4
    __    __    _______    _______    _______    _______
    0     0        0        -1/5         0        153/5 
```

Si nota poi che ci sono altre funzioni nella presente directory, fra cui alcune funzioni per il disegno della regione ammissibile, nel caso questa sia un poliedro, e della funzione ivi contenuta (`draw_cons_func()` e `draw_free_func()`), e una funzione per il calcolo dei vertici di un poliedro (`get_vertices()`).
Queste sono documentate più che sufficientemente nella loro implementazione.
In caso di dubbi, si ricorda che il parametro `verbose` è accettato dalla maggior parte delle funzioni e restituisce informazioni via via maggiori sul procedimento interno eseguito (e nel caso di sottofunzioni che vengono chiamate, del loro funzionamento interno, cosa che torna utile per osservare il comportamento degli algoritmi di ottimizzazione iterativi).
