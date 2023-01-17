:- module(vagaService, [
    vagasDisponiveis/0,
    vagasDisponiveisAndar/0,
    adicionaVaga/0,
    adicionaAndar/0,
    adicionaTempoVaga/0
    ]).
:- use_module('menu.pl', [menu/0]).

vagasDisponiveis :- nl, write('vagasDisponiveis').
vagasDisponiveisAndar :- nl, write('vagasDisponiveisAndar').
adicionaVaga :- write('--- adiciona vaga ---').
adicionaAndar :- nl, write('adicionaAndar').
adicionaTempoVaga :- nl, write('adicionaTempoVaga').