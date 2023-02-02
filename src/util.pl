:- module(util, [input_line/1, posix_time/1, remove_last/2]).

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