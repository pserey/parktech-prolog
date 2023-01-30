
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

retorna_horas(TEMPO_VAGA, Horas) :-
    TEMPO_VAGA = RETORNO,
    Horas is RETORNO / 3600.

taxa_pagamento(IdVaga, ISDiaSemana, Taxa) :-
    consult('src/vagas.pl'),
    vaga(_, Num, Andar, TipoVeiculo, TempoInicial, _,_),
    posix_time(Current),
    horas(Current, TempoInicial, Diferenca),
    retorna_horas(Diferenca, Horas),
    (TipoVeiculo == 'carro' -> Horas > 2 -> ISDiaSemana -> Taxa is (6 + (((Horas) -2) * 1.5)) ; Taxa is (8 + (((Horas) -2) * 2))),
    (TipoVeiculo == 'carro' -> Horas < 2 -> ISDiaSemana -> Taxa is 6 ; Taxa is 8),
    (TipoVeiculo == 'moto' -> Horas > 2 -> ISDiaSemana -> Taxa is (4 + (((Horas) -2))) ; Taxa is (6 + (((Horas) -2) * 1.5))),
    (TipoVeiculo == 'moto' -> Horas < 2 -> ISDiaSemana -> Taxa is 4 ; Taxa is 6),
    (TipoVeiculo == 'van' -> Horas > 2 -> ISDiaSemana -> Taxa is (8 + (((Horas) -2) * 2)) ; Taxa is (10 + (((Horas) -2) * 2.5))),
    (TipoVeiculo == 'van' -> Horas < 2 -> ISDiaSemana -> Taxa is 8 ; Taxa is 10).

paga_estacionamento :-
    write('--- PAGAMENTO ---'),nl,
    write('Informe o numero do andar:'), input_line(AndarString),
    write('Informe o numero da vaga:'), input_line(VagaString),
    atom_number(AndarString, Andar),
    atom_number(VagaString, Vaga),
    vaga(Status, Vaga, Andar,_,_,IdVaga,_),
    write('É dia comercial?[S/N]'),
    input_line(WeekString),
    taxa_pagamento(IdVaga, WeekString, taxa),
    (Status == false -> write('A vaga nao esta ocupada, falha ao realizar o pagamento')).

tempo_vaga :- nl, write('tempo_vaga').