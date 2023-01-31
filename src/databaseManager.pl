:- module(databaseManager, [
    add_fact/2, update_fact/3]).

:- dynamic vaga/7.

% add_fact(+Arquivo, +Fact)
% adiciona fato passado como parametro a arquivo
% Arquivo deve ser string com path para arquivo (a partir do PWD)
add_fact(Arquivo, Fact) :-
    open(Arquivo, append, Stream),
    format(Stream, '~w.~n', [Fact]),
    close(Stream).

update_fact(Arquivo, OldFact, NewFact) :-
    consult(Arquivo),
    retract(OldFact), 
    asserta(NewFact),
    tell(Arquivo), 
    listing(vaga/7), 
    told.