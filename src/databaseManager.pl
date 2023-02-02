:- module(databaseManager, [
    add_fact/2, update_fact/3, read_file/2]).

% add_fact(+Arquivo, +Fact)
% adiciona fato passado como parametro a arquivo
% Arquivo deve ser string com path para arquivo (a partir do PWD)
add_fact(Arquivo, Fact) :-
    open(Arquivo, append, Stream),
    format(Stream, '~w.~n', [Fact]),
    close(Stream).

% update_fact(+File, +OldFact, +NewFact)
% atualiza um fato em um arquivo substituindo-o por um fato novo
update_fact(File, OldFact, NewFact) :-
    open(File, read, Stream),
    read_file(Stream, Facts),
    close(Stream),
    replace_fact(OldFact, NewFact, Facts, NewFacts),
    open(File, write, Stream2),
    write_file(Stream2, NewFacts),
    close(Stream2).

% update_fact(+File, +OldFact, +Attribute)
% atualiza um fato em um arquivo substituindo-o por um fato novo
update_fact(File, OldFact, NewFact) :-
    open(File, read, Stream),
    read_file(Stream, Facts),
    close(Stream),
    replace_fact(OldFact, NewFact, Facts, NewFacts),
    open(File, write, Stream2),
    write_file(Stream2, NewFacts),
    close(Stream2).

% replace_fact(+OldFact, +NewFact, +Facts, -NewFacts)
% substitui um fato por outro numa lista de fatos
replace_fact(_, _, [], []).
replace_fact(OldFact, NewFact, [OldFact|Tail], [NewFact|Tail]).
replace_fact(OldFact, NewFact, [Head|Tail], [Head|NewTail]) :-
    Head \= OldFact,
    replace_fact(OldFact, NewFact, Tail, NewTail).

% read_file(+Stream, -Facts)
% lê arquivo para uma lista de fatos
read_file(Stream, []) :-
    at_end_of_stream(Stream).
read_file(Stream, [Fact|Facts]) :-
    \+ at_end_of_stream(Stream),
    read(Stream, Fact),
    read_file(Stream, Facts).


% write_file(+Stream, +Facts)
% escreve os fatos no arquivo adicionando um ponto e uma nova linha no fim
write_file(_, []).
write_file(_, [end_of_file|_]).
write_file(Stream, [Fact|Facts]) :-
    write(Stream, Fact),
    write(Stream, '.'),
    nl(Stream),
    write_file(Stream, Facts).

% lê linhas de arquivo e retorna lista de strings
% read_file_lines(File, Lines) :-
%     open(File, read, Stream),
%     read_lines(Stream, Lines),
%     close(Stream).

% read_lines(Stream, []) :-
%     at_end_of_stream(Stream).
% read_lines(Stream, [Line|Lines]) :-
%     \+ at_end_of_stream(Stream),
%     read_line_to_codes(Stream, LineCodes),
%     atom_codes(Line, LineCodes),
%     read_lines(Stream, Lines).