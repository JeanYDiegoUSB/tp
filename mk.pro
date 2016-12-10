% mk.pro
%
% Se resuelve el problema del máximo número de caballos en un tablero
% de tamaño NxN. Además, se puede imprimir la solución (o soluciones)
% en pantalla.
%
% @author Jean Alexander, 12-10848 y Diego Pedroza, 12-11281

%% arre (+N:int, ?M:int, ?List:list)
%
% List es una configuración solución del problema del máximo
% número de caballos en un tablero NxN. M es el máximo de caballos
% en un tablero NxN, es decir, el tamaño de List.
% 
% Si N es 2, entonces la solución es única y trivial, puesto que
% en un tablero 2x2 caben máximo 4 caballos sin amenazarse entre ellos.
%
% Si N es 3, hay dos soluciones. Una de ellas la conseguimos probando
% sol1(3, LP, List). La segunda solución la conseguimos probando
% odds(LP, List).
% 
% Para cualquier N impar la solución se consigue probando odds(LP, List).
% 
% Para cualquier N par (que no sea 2) las soluciones se consiguen
% probando sol1(N, LP, List).
%
% LP es la lista de todas las posiciones del tablero representadas como k(X,Y).
%
% @param N número entero (tamaño del tablero)
% @param M número entero (número máximo de caballos para el tablero de tamaño NxN)
% @param List lista con las posiciones de los caballos como pares k(X,Y)
arre(2, N, L) :-
	lista(2, L),
	length(L, N),
	!.
arre(3, N, L) :-
	lista(3, LP),
	sol1(3, LP, L),
	length(L, N).
arre(N, M, L) :-
	odd(N),
	lista(N, LP),
	odds(LP, L),
	length(L, M),
	!.
arre(N, M, L) :-
	even(N),
	lista(N, LP),
	sol1(N, LP, L),
	length(L, M).

%% sol1(+N:int, +List1:list, ?List2:list)
% 
% List2 es la lista con la configuración solución
% para el problema del máximo de caballos en un tablero NxN. 
%
% Si N es 3 se agrupan los elementos de la lista List1 en
% grupos de tamaño 3. Conservamos las posiciones pares del
% primer y último grupo, y luego concatenamos para obtener
% la lista List2.
%
% Para cualquier otro N se agrupan los elementos de List1
% en grupos de tamaño N. Se prueba el predicado odd_even(L, Sol),
% donde L es la lista List1 con sus elementos agrupados en listas
% de a N elementos. Luego se concatena Sol para obtener List2.
%
% Para cualquier otro N se agrupan los elementos de List1
% en grupos de tamaño N. Se prueba el predicado even_odd(L, Sol),
% donde L es la lista List1 con sus elementos agrupados en listas
% de a N elementos. Luego se concatena Sol para obtener List2.
% 
% @param N número entero
% @param List1 lista cualquiera
% @param List2 lista resultante
sol1(3, LP, Res) :-
	group(3, LP, [A, B, C]),
	evens(A, D),
	evens(C, E),
	concat([D, B, E], Res).
sol1(N, LP, Res) :-
	group(N, LP, L),
	odd_even(L, Sol),
	concat(Sol, Res).
sol1(N, LP, Res) :-
	group(N, LP, L),
	even_odd(L, Sol),
	concat(Sol, Res),
	!.

%% lista(+N:int, ?List:list)
%
% List es la lista resultante de probar
% gen(N, L), pares(L, List).
%
% @param N número entero
% @param List lista resultante	
lista(N, LP) :-
	gen(N, L),
	pares(L, LP),
	!.
	
%% gen(+N:int, ?List:list)
%
% List es la lista desde 1 hasta N.
%
% @param N número entero
% @param List lista de enteros resultante
gen(N, L) :-
	gen(N, [], L),
	!.

% predicado auxiliar
%% gen(+N:int, +Acum:list, ?List:list)
% 
% List es la lista desde 1 hasta N.
% Se van acumulando los números en Acum hasta
% hacer a N 0, luego se unifica Acum con List.
% 
% @param N número entero
% @param Acum lista para acumular
% @param List lista resultante
gen(0, A, A).
gen(N, A, R) :-
	N > 0,
	N1 is N - 1,
	gen(N1, [N | A], R).

%% pares(+List1:list, ?List2:list)
%
% List2 es la lista de k(X,Y), donde X es miembro de List1
% y Y es miembro de List1.
%
% @param List1 lista cualquiera
% @param List2 lista resultante
pares(L, LP) :-
	findall(k(X, Y), (member(X, L), member(Y, L)), LP).

%% odd_even(+List1:list, ?List2:list)
%
% List2 es la lista List1 con cada par de elementos
% aplicandoles los predicados odds e evens, respectivamente.
% List1 debe ser una lista de tamaño par.
%
% @param List1 lista de listas cualquiera
% @param List2 lista de listas resultante
odd_even([], []) :-
	!.
odd_even([X, Y | Resto], [A , B | Nuevo]) :-
	odds(X, A),
	evens(Y, B),
	odd_even(Resto, Nuevo),
	!.

%% even_odd(+List1:list, ?List2:list)
%
% List2 es la lista List1 con cada par de elementos
% aplicandoles los predicados evens y odds, respectivamente.
% List1 debe ser una lista de tamaño par.
%
% @param List1 lista de listas cualquiera
% @param List2 lista de listas resultante
even_odd([], []) :-
	!.
even_odd([X, Y | Resto], [A , B | Nuevo]) :-
	evens(X, A),
	odds(Y, B),
	even_odd(Resto, Nuevo),
	!.

%% concat(+List1:list, ?List2:list)
% 
% List2 es la lista List1 con todos sus elementos
% concatenados entre si. List1 debe ser una lista
% de listas.
%
% @param List1 lista de listas cualquiera
% @param List2 lista resultante
concat([], []) :-
	!.
concat([L | Ls], As) :-
	append(L, Ws, As),
	concat(Ls, Ws),
	!.

%% group(+N:int, +List1:list, ?List2:list)
%
% List2 es la lista List1 con sus elementos
% agrupados en listas de tamaño N. El último
% grupo puede tener menos de N elementos.
%
% @param N número entero
% @param List1 lista cualquiera
% @param List2 lista de listas resultante
group(_, [], []) :-
	!.
group(N, L, [T | G]) :-
	take(N, L, T),
	drop(N, L, D),
	group(N, D, G),
	!.

%% take(+N:int, +List1:list, ?List2:list)
%
% List2 es la lista List1 con sólo sus primeros
% N elementos.
%
% @param N número entero
% @param List1 lista cualquiera
% @param List2 lista resultante
take(_, [], []) :-
	!.
take(0, L, L) :-
	!.
take(1, [X | _], [X]) :-
	!.
take(N, [X | R], [X | Sol]) :-
	N > 0,
	N1 is N - 1,
	take(N1, R, Sol),
	!.

%% drop(+N:int, +List1:list, ?List2:list)
%
% List2 es la lista List1 sin sus primeros
% N elementos. 
%
% @param N número entero
% @param List1 lista cualquiera
% @param List2 lista resultante
drop(_, [], []) :-
	!.
drop(N, L, L) :-
	N =< 0,
	!.
drop(1, [_ | R], R) :-
	!.
drop(N, [_ | R], Sol) :-
	N1 is N - 1,
	drop(N1, R, Sol),
	!.

%% odds(+List1:list, ?List2:list)
%
% List2 es la lista List1 con sólo los elementos
% de las posiciones impares.
%
% @param List1 lista cualquiera
% @param List2 lista resultante
odds([X, _ | L], [X | R]) :-
	!,
	odds(L, R).
odds(X, X).

%% evens(+List1:list, ?List2:list)
%
% List2 es la lista List1 con sólo los elementos
% de las posiciones pares.
%
% @param List1 lista cualquiera
% @param List2 lista resultante
evens([],[]).
evens([_, X | L], [X | R]) :-
	!,
	evens(L, R).
evens([X],[]).

%% odd(+N:int)
% 
% Dado un N prueba si ese N es impar
%
% @param N número entero
odd(N) :-
	1 =:= N mod 2.

%% even(+N:int)
% 
% Dado un N prueba si ese N es par
%
% @param N número entero
even(N) :-
	0 =:= N mod 2.