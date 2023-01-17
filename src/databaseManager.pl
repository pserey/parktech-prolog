:- module(databaseManager, [
    addFact/2]).

addFact(Arquivo, Fact) :-
    open(Arquivo, append, Stream),
    format(Stream, '~w.~n', [Fact]),
    close(Stream).