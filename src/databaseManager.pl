:- module(databaseManager, [
    addFact/2]).

% addFact(+Arquivo, +Fact)
% adiciona fato passado como parametro a arquivo
% Arquivo deve ser string com path para arquivo (a partir do PWD)
addFact(Arquivo, Fact) :-
    open(Arquivo, append, Stream),
    format(Stream, '~w.~n', [Fact]),
    close(Stream).