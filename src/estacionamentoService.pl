
:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).

estaciona_veiculo :- nl, write('estaciona_veiculo').
paga_estacionamento :- nl, write('paga_estacionamento').
tempo_vaga :- nl, write('tempo_vaga').