edge(g1,a,b).
edge(g1,b,c).
edge(g1,a,c).
edge(g1,d,a).
edge(g1,d,b).
edge(g1,d,c).
edge(g1,d,e).

:- dynamic([graph/1]).

nodes(Grafo, Nodes) :-
	findall(X, (edge(Grafo, X, _); edge(Grafo, _, X)), T_nodes),
	quitar_duplicados(T_nodes, [], Nodes),
	sort(Nodes),
	!.

edges(Grafo, Edges) :-
	findall(edge(X, Y), edge(Grafo, X, Y), Edges).

quitar_duplicados([], Nodos, Nodos).
quitar_duplicados([Nodo | Nodos], Acum, Todos) :-
	member(Nodo, Acum),
	quitar_duplicados(Nodos, Acum, Todos).
quitar_duplicados([Nodo | Nodos], Acum, Todos) :-
	quitar_duplicados(Nodos, [Nodo | Acum], Todos).
	
spider(Grafo, Spider) :-
	nodes(Grafo, Nodes),
	edges(Grafo, Edges),
	ms_tree(Nodes, Edges, Spider),
	es_spider(Nodes, Spider).

es_spider(Nodes, Spider) :-
	member(Node, Nodes),
	findall(X, member(edge(X, Node), Spider), L1),
	findall(Y, member(edge(Node, Y), Spider), L2),
	append(L1, L2, L),
	length(L, N),
	N >= 3,
	\+graph(Spider),
	assertz((graph(Spider))),
	!.

transferir([], _, []).
transferir(Nodes, Graph_edges, [Graph_edge | Tree_edges]) :- 
   select(Graph_edge, Graph_edges, Graph_edges1),
   incidente(Graph_edge, X, Y),
   aceptable(X, Y, Nodes),
   delete(Nodes, X, Nodes1),
   delete(Nodes1, Y, Nodes2),
   transferir(Nodes2, Graph_edges1, Tree_edges).

incidente(edge(X,Y),X,Y).

aceptable(X, Y, Ns) :-
	memberchk(X,Ns),
	\+ memberchk(Y,Ns),
	!.
aceptable(X, Y, Ns) :-
	memberchk(Y,Ns),
	\+ memberchk(X,Ns).

ms_tree([_|Nodes], Graph_edges, Tree_edges) :- 
   sort(Graph_edges, Graph_edges_sorted),
   transferir(Nodes, Graph_edges_sorted, Tree_edges_unsorted),
   sort(Tree_edges_unsorted, Tree_edges).