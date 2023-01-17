
:- module(estacionamentoService, [
    estacionaVeiculo/0,
    pagaEstacionamento/0,
    tempoVaga/0
    ]).
:- use_module('menu.pl', [menu/0]).

estacionaVeiculo :- nl, write('estacionaVeiculo').
pagaEstacionamento :- nl, write('pagaEstacionamento').
tempoVaga :- nl, write('tempoVaga').