:- module(util, [input_line/1]).

input_line(Line) :-
    read_line_to_string(user_input, Line).