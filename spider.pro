% spider.pro
%
% Se resuelve el problema de conseguir las arañas de cobertura
% de un grafo, si las tuviese.
%
% @author Jean Alexander, 12-10848 y Diego Pedroza, 12-11281

:- dynamic([graph/1]).

%% spider(+Grafo:atom, -Spider:list)
%
% Spider es una lista con las aristas de una araña de cobertura
% del Grafo (si tiene alguna).
%
% Se borran todas las cláusulas graph(_) porque se usan para
% guardar las coberturas arañas en la base de conocimiento.
%
% @param Grafo  nombre del grafo
% @param Spider lista con las aristas de una araña de cobertura
spider(Grafo, Spider) :-
	retractall(graph(_)),
	nodes(Grafo, Nodes),
	edges(Grafo, Edges),
	ms_tree(Nodes, Edges, Spider),
	es_spider(Nodes, Spider).

%% es_spider(+Nodos:list, +Spider:list)
%
% Verifica si Spider es una araña de cobertura. Si lo es
% y es una araña que no hemos visto antes la agregamos
% a la base de conocimiento de Prolog como graph(Spider).
%
% @param Nodos  lista de nodos
% @param Spider lista con aristas de una araña de cobertura
es_spider(Nodes, Spider) :-
	member(Node, Nodes),
	findall(X, member(edge(X, Node), Spider), L1),
	findall(Y, member(edge(Node, Y), Spider), L2),
	append(L1, L2, L),
	length(L, N),
	N >= 3,
	\+graph(Spider),
	asserta((graph(Spider))),
	!.

%% nodes(+Grafo:atom, ?Nodos:list)
%
% Nodos es la lista con todos los nodos del Grafo.
%
% @param Grafo nombre del grafo
% @param Nodos lista con los nodos del Grafo
nodes(Grafo, Nodes) :-
	findall(X, (edge(Grafo, X, _); edge(Grafo, _, X)), T_nodes),
	quitar_duplicados(T_nodes, [], Nodes),
	sort(Nodes),
	!.

%% quitar_duplicados(+List1:list, +Acum:list, ?List2:list)
%
% List2 es la lista List1 sin elementos repetidos.
%
% @param List1 lista 
% @param Acum acumulador (lista)
% @param List2 lista resultante
quitar_duplicados([], Nodos, Nodos).
quitar_duplicados([Nodo | Nodos], Acum, Todos) :-
	member(Nodo, Acum),
	quitar_duplicados(Nodos, Acum, Todos).
quitar_duplicados([Nodo | Nodos], Acum, Todos) :-
	quitar_duplicados(Nodos, [Nodo | Acum], Todos).
	
%% edges(+Grafo:atom, ?Lados:list)
%
% Lados es la lista con todos los lados del Grafo.
%
% @param Grafo nombre del grafo
% @param Lados lista con los lados del Grafo
edges(Grafo, Edges) :-
	findall(edge(X, Y), edge(Grafo, X, Y), Edges),
	!.

%% ms_tree(+Nodos:list, +Lados:list, ?Tree:list)
% 
% Tree es la lista que representa el árbol de cobertura mínimo del
% grafo representado por la lista Nodos y la lista Lados. (consigue todos
% los árboles cobertores mínimos por backtracking)
%
% @param Nodos lista con los nodos del grafo
% @param Lados lista con las aristas del grafo
% @param Tree  lista con las aristas del árbol de cobertura mínimo
ms_tree([_|Nodes], Graph_edges, Tree_edges) :- 
	sort(Graph_edges, Graph_edges_sorted),
	transferir(Nodes, Graph_edges_sorted, Tree_edges_unsorted),
	sort(Tree_edges_unsorted, Tree_edges).

%% transferir(+Nodos:list, +Graph_edges:list, -Tree_edges:list)
%
% Transfiere lados de Graph_edges a Tree_edges hasta que la lista
% Nodos de nodos de árbol aún no conectados se vacíe. Una arista es
% aceptable si y sólo si uno de sus extremos ya está conectado al
% árbol y el otro no. (predicado con backtracking)
%
% @param Nodos       lista de nodos de un grafo
% @param Graph_edges lista de aristas de un grafo
% @param Tree_edges  lista de aristas del árbol
transferir([], _, []).
transferir(Nodes, Graph_edges, [Graph_edge | Tree_edges]) :- 
	select(Graph_edge, Graph_edges, Graph_edges1),
	incidente(Graph_edge, X, Y),
	aceptable(X, Y, Nodes),
	delete(Nodes, X, Nodes1),
	delete(Nodes1, Y, Nodes2),
	transferir(Nodes2, Graph_edges1, Tree_edges).

%% incidente(+Lado:atom, +Inicio:atom, +Final:atom)
% 
% incidente(edge(X, Y), Inicio, Final) es exitoso si Inicio unifica
% con X y Final unifica con Y. Prueba de incidencia de un lado.
%
% @param Lado   lado de un grafo representado como edge(Inicio,Final)
% @param Inicio nodo de inicio
% @param Final  nodo final
incidente(edge(X,Y),X,Y).

%% aceptable(+Inicio:atom, +Final:atom, +Nodos:list)
%
% aceptable(Inicio, Final, Nodos) es exitoso si Inicio es miembro de
% Nodos y Final no lo es, ó si Final es miembro de Nodos e Inicio no
% lo es.
%
% @param Inicio nodo de inicio 
% @param Final  nodo final
% @param Nodos  lista de nodos 
aceptable(X, Y, Ns) :-
	memberchk(X,Ns),
	\+ memberchk(Y,Ns),
	!.
aceptable(X, Y, Ns) :-
	memberchk(Y,Ns),
	\+ memberchk(X,Ns).