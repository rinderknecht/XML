% lt(Node1, Node2) if Node1 is lower than Node2.
%
lt((_, Low1, _), (_, Low2, _)) :- Low1 @< Low2.

comp((_, Low1, Up1), (_, Low2, Up2), Relation) :-
  lt(Low1, Low2),
  lt(Up2, Up1),
  Relation=includes.

comp((_, Low1, Up1), (_, Low2, Up2), Relation) :-
  lt(Low2, Low1),
  lt(Up1, Up2),
  Relation=included.

comp((_, _, Up1), (_, Low2, _), Relation) :-
  lt(Up1, Low2),
  Relation=left_disjoint.

comp((_, Low1, _), (_, _, Up2), Relation) :-
  lt(Up2, Low1),
  Relation=right_disjoint.
  
% add(Node, Tree, NewTree) if the tree NewTree is the tree Tree
% augmented with the node Node.

add(Node,nil) :- tree(Node, []).

add(Node, tree(Root, Subtrees), tree(Node, tree(Root, Subtrees))) :-
  comp(Node, Root, includes).

add(Node, tree(Root, Subtrees), tree(Root, NewSubtrees)) :-
  comp(Node, Root, included),
  add_to_forest(Node, Subtrees, NewSubtrees).
  
add_to_forest(Node, [Tree | Trees], [NewTree | Trees]) :-
  comp(Node, Tree, included),
  add(Node, Tree, NewTree).

add_to_forest(Node, [Tree | Trees], [Node, Tree | Trees]) :-
  comp(Node, Tree, left_disjoint).

add_to_forest(Node, [Tree | Trees], NewForest) :-
  comp(Node, Tree, right_disjoint),
  add_to_forest(Node, Trees, NewForest).

% mem(Node, Tree, Path) if the node Node is present in the tree Tree,
% in which case Path is the sequence of nodes from the root to Node
% (included) in Tree.
%
mem(Node, tree(Node, _), [Node]).
mem(Node, tree(Root, Subtrees), [Root | Subpath]) :-
  f_mem(Node, Subtrees, Subpath).

% f_mem(Node, Forest, Path) if the node Node is present at least in
% one of the trees of the forest Forest (a list of trees), with the
% path Path from the root.
%
%f_mem(Node, AVLsubtrees, Path) :- 
%  memAVL(Subtree, AVLsubtrees),
%  mem(Node, Subtree, Path).

f_mem(Node, [Tree | _], Path) :- mem(Node, Tree, Path).
f_mem(Node, [_ | Trees], Path) :- f_mem(Node, Trees, Path).

% ind(Path1, Path2) if paths Path1 and Path2 are not prefix one of the
% other (called _independent_). In other words, the ending nodes of
% Path1 and Path2 must not belong to the same path from the root.
%
% Note the cut in the first clause.
%
ind([Node1 | _], [Node2 | _]) :- once(Node1 \= Node2).
ind([Node | Subpath1], [Node | Subpath2]) :- ind(Subpath1, Subpath2).
  
% indep(NewPath, Paths) if path NewPath is independent from all the
% paths in Paths.
%
indep(_, []).
indep(NewPath, [Path | Paths]) :-
  ind(NewPath, Path),
  indep(NewPath, Paths).

% solve_aux(Tree, Nodes, Paths) if the n-th node in the list Nodes is
% the last node of the n-th path of Paths, which are valid paths in
% the tree Tree.
%
solve_aux(_, [], []).
solve_aux(Tree, [Node | Nodes], [Path | Paths]) :-
  mem(Node, Tree, Path),
  solve_aux(Tree, Nodes, Paths),
  indep(Path, Paths).

% solve(Tree, Nodes) if the nodes in the list Nodes are in the tree
% Tree.
%
solve(Tree, Nodes) :- solve_aux(Tree, Nodes, _).

% Processing (all solutions are found, if any)
%
process(end_of_file) :- !.
process(Tree) :-
  findall((Xa/Ya,Xb/Yb,Xc/Yc),
          solve(Tree, [(a,Xa,Ya), (b,Xb,Yb), (c,Xc,Yc)]), 
          Solutions),
  write(Solutions),
  seen.

% Entry point
%
go :-
  see(interval_terms),
  read(Tree),
  process(Tree).
