
:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).

estaciona_veiculo :- nl, write('estaciona_veiculo').
horas(FINAL, INICIAL, HORAS) :-
    round(FINAL, DATE1),
    round(INICIAL, DATE2),
    HORAS is DATE1 - DATE2.

retorna_horas(TEMPO_VAGA, HORAS) :-
    TEMPO_VAGA = RETORNO,
    HORAS is RETORNO / 3600.

taxa_pagamento(Vaga, ISDiaSemana, Taxa) :-
    posix_time(Current),
    DataFinal is Current,
    tempo_inicial(Vaga, Inicial),
    DataInicial is Inicial,
    horas(DataFinal, DataInicial, Diferenca),
    D is Diferenca.
paga_estacionamento :- nl, write('paga_estacionamento').
tempo_vaga :- nl, write('tempo_vaga').