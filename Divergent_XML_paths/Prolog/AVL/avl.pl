% AVL Trees (Almost balanced binary search trees)
% AVL Tree is avl(Left, Root, Right)/Height or nil

% gt(Tree1, Tree2) if the root of Tree1 is greater than the root of
% Tree2.
%
% A node is a tree whose node is triple made of a tag (atom), an
% interval lower bound and the corresponding upper bound (both
% integers). The intervals made of the lower and upper bounds are
% disjoint (so we can only compare their lower bounds).
%
gt(tree((_, Low1, _), _),
   tree((_, Low2, _), _)) :-
  Low1 @> Low2.

% max1(U, V, M) if M is 1 plus the maximum of U and V
%
max1(U, V, M) :- U > V, !, M is U + 1.
max1(_, V, M) :- M is V + 1.

% combine(Tree1, A, Tree2, B, Tree3, NewTree)
%
combine(T1/H1, A, avl(T21,B,T22)/H2, C, T3/H3,
         avl(avl(T1/H1,A,T21)/Ha, B, avl(T22,C,T3/H3)/Hc)/Hb) :-
  H2 > H1, H2 > H3,                        % Middle subtree tallest
  Ha is H1 + 1,
  Hc is H3 + 1,
  Hb is Ha + 1.

combine(T1/H1, A, T2/H2, C, T3/H3,
        avl(T1/H1, A, avl(T2/H2,C,T3/H3)/Hc)/Ha) :-
  H1 >= H2, H1 >= H3,                      % Left subtree tallest
  max1(H2, H3, Hc),
  max1(H1, Hc, Ha).

combine(T1/H1, A, T2/H2, C, T3/H3,
        avl(avl(T1/H1,A,T2/H2)/Ha, C, T3/H3)/Hc) :-
  H3 >= H2, H3 >= H1,                      % Right subtree tallest
  max1(H1, H2, Ha),
  max1(Ha, H3, Hc).

% addAVL(Tree, Node, NewTree)
%
addAVL(nil/0, Node, avl(nil/0, Node, nil/0)/1) :- !.  % Uniqueness

addAVL(avl(Left, Root, Right)/_, Node, NewTree) :-
  gt(Root, Node),
  addAVL(Left, Node, avl(Left1, NewRoot, Left2)/_),
  combine(Left1, NewRoot, Left2, Root, Right, NewTree).

addAVL(avl(Left, Root, Right)/_, Node, NewTree) :-
  gt(Node, Root),
  addAVL(Right, Node, avl(Right1, NewRoot, Right2)/_),
  combine(Left, Root, Right1, NewRoot, Right2, NewTree).

% memAVL(Node, Tree)
%
memAVL(Node, avl(_, Node, _)/_) :- !. % Uniqueness

memAVL(Node, avl(Left, Root, _)/_) :-
  gt(Root, Node),
  memAVL(Node, Left).

memAVL(Node, avl(_, Root, Right)/_) :-
  gt(Node, Root),
  memAVL(Node, Right).
