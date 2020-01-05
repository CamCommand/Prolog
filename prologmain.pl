place_mirrors(LaserY, Obstacles, R):-
  get_human_xs(Obstacles, Human_Xs),
  go_next(0:LaserY, right, LaserY, 8, Obstacles, Human_Xs, [], [], RR),
  reverse(RR,R).

% go to the next point and check the possible next moves
go_next(X:Y, D, LaserY, Mirrors, Obstacles, Human_Xs, Pt_Acc, Mirror_Acc, Mirror_Res):-
  room_check(X:Y, 12, 10),
  \+ member(X:Y, Pt_Acc),
  update_human_xs(Human_Xs, X:Y, Human_Xs1), check_human_xs(Human_Xs1),
  check_obstacles(X:Y, Obstacles),
  mirror(X, M, Mirrors, Mirrors1),
  deviate(D, M, D1),
  update_mirror(X:Y, M, Mirror_Acc, MA1),
  travel(X:Y, D1, X1:Y1),
  go_next(X1:Y1, D1, LaserY, Mirrors1, Obstacles,Human_Xs1, [X:Y|Pt_Acc], MA1, Mirror_Res).
  go_next(12:LaserY, right,LaserY,_,_,_,_,Mirror_Res, Mirror_Res).


% Update the list of mirrors iff there is no mirror (first case) then I
% do not change anything  otherwise I add to the list, together with its
% coordinates I check that I do not have two mirrors in the same location
update_mirror(_, '_', Mirrors, Mirrors):- !.
update_mirror(X:Y, Mirror, Mirrors, [[X,Y,Mirror]|Mirrors]):-
\+ member([X,Y,_], Mirrors).

% check that the X and Y are in the room
room_check(X:Y, Width, Height):-
X >= 0, X < Width,
Y >= 0, Y < Height.

% To check that a human can be placed in the room I need to check that there
% are a pair of consecutive X's which have the first 6 spots free
% For this I maintain a list of X's that can be used by a human, and every time
% I go to a new location it updates the list by removing X's if the Y is below or equal to 5

% This function generates the list of available X's for the human.  It removes
% the X's if there are obstacles that make it impossible for a human to be placed at that X


get_human_xs(Obstacles, Xs):-
  ghx_rec(Obstacles, [1,2,3,4,5,6,7,8,9,10], Xs).
ghx_rec([Obstacle|Obstacles], Xs, R):-
  ghx_filter_xs(Xs,Obstacle, [], Xs2),
  ghx_rec(Obstacles, Xs2, R).
ghx_rec([], R, R).
ghx_filter_xs([X|Xs], [Ox,Ow,Oh], A, R):-
  ( X < Ox ; X >= Ox+Ow ; Oh < 4 ), !,
  ghx_filter_xs(Xs,[Ox,Ow,Oh],[X|A],R).
ghx_filter_xs([_|Xs], Obstacle, A, R):-
  ghx_filter_xs(Xs, Obstacle, A, R).
ghx_filter_xs([], _, R, R).

% I hate this human so much

% make sure that there are at least two consecutive Xs
check_human_xs([X1,X2|_]):-
  X2 is X1 + 1, !.
check_human_xs([X1,X2|Xs]):-
  X2 =\= X1+1,
check_human_xs([X2|Xs]).

% delete some Xs if they interact with where the human can be assume Xs are not repeated
% will this jackass fit, prolog only knows
update_human_xs(Xs, X:Y, R):-
  update_human_xs_rec(Xs, X:Y, [], RR),
  reverse(RR, R).
update_human_xs_rec([X|Xs], X:Y, A, R):-
  Y > 5,
  update_human_xs_rec(Xs, X:Y, [X|A], R).
update_human_xs_rec([X|Xs], X:Y, A, R):-
  Y =< 5,
  update_human_xs_rec(Xs, X:Y, A, R).
update_human_xs_rec([X1|Xs], X2:Y, A, R):-
  X1 =\= X2,
  update_human_xs_rec(Xs, X2:Y, [X1|A], R).
update_human_xs_rec([], _, A, A).

% Generate situations with a mirror: we either don't use a mirror or use / or \
% If we use a mirror we decrease the number of mirrors available.
mirror(_,'_',Mirrors,Mirrors).
mirror(X,'/',Mirrors,Mirrors1):-
  X > 0, X < 11,
  Mirrors > 0,
  Mirrors1 is Mirrors - 1.
mirror(X,'\\',Mirrors,Mirrors1):-
  X > 0, X < 11,
  Mirrors > 0,
  Mirrors1 is Mirrors - 1.

% Go through the list of obstacles to check that the location X:Y is valid
check_obstacles(X:Y,[[Ox,Ow,Oh]|Obstacles]):-
  ( X < Ox ; X >= Ox+Ow ; Y < 10-Oh ),!,
  check_obstacles(X:Y,Obstacles).
check_obstacles(_,[]).

% change direction based on the mirror
deviate(D,'_',D).
deviate(up,'/',right).
deviate(left,'/',down).
deviate(down,'/',left).
deviate(right,'/',up).
deviate(up,'\\',left).
deviate(left,'\\',up).
deviate(down,'\\',right).
deviate(right,'\\',down).

% change location based on the direction
travel(X:Y,right,X1:Y):-
  X1 is X+1.
travel(X:Y,left,X1:Y):-
  X1 is X-1.
travel(X:Y,down,X:Y1):-
  Y1 is Y-1.
travel(X:Y,up,X:Y1):-
  Y1 is Y+1.
