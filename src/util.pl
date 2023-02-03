:- module(util, [input_line/1, posix_time/1, remove_last/2, most_repeated_element/2, replace/4]).
:- use_module(library(aggregate)).

% input_line(-Line)
% lê linha de input e retorna string
input_line(Line) :-
    read_line_to_string(user_input, Line).

% posix_time(-Now)
% retorna posix time do momento em que é chamado em segundos
posix_time(Now) :- 
    get_time(NowFloat),
    Now is round(NowFloat).

% remove_last(+List, -NewList)
% remove último elemento de uma lista
remove_last([_], []).
remove_last([X|Xs], [X|WithoutLast]) :- 
    remove_last(Xs, WithoutLast).

% retorna elemento que mais se repete em uma lista
most_repeated_element(List, MostRepeated) :-
    setof(Count-Element, (member(Element,List), aggregate(count, member(Element,List), Count)), Counts),
    sort(Counts, SortedCounts),
    reverse(SortedCounts, [_MostRepeatedCount-MostRepeated|_]).

replace(_, _, [], []).
replace(Old, New, [Old|Tail], [New|NewTail]) :-
    replace(Old, New, Tail, NewTail).
replace(Old, New, [Head|Tail], [Head|NewTail]) :-
    Old \= Head,
    replace(Old, New, Tail, NewTail).