
:- module(estacionamentoService, [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [update_fact/3]).

estaciona_veiculo :- nl, write('estaciona_veiculo').


horas(FINAL, INICIAL, HORAS) :-
    round(FINAL, DATE1),
    round(INICIAL, DATE2),
    HORAS is DATE1 - DATE2.

retorna_horas(TEMPO_VAGA, Horas) :-
    TEMPO_VAGA = RETORNO,
    Horas is RETORNO / 3600.

taxa_pagamento(IdVaga, IsDiaSemana, Taxa) :-
    consult('src/vagas.pl'),
    vaga(_, Num, Andar, TipoVeiculo, TempoInicial, IdVaga,_),
    posix_time(Current),
    horas(Current, TempoInicial, Diferenca),
    retorna_horas(Diferenca, Hora),
    round(Hora, Horas),
    (TipoVeiculo == 'carro', Horas > 2, IsDiaSemana == 1 -> Taxa is 6 + ((Horas-2)*1.5) ;
    TipoVeiculo == 'carro', Horas > 2, IsDiaSemana == 0 -> Taxa is 8 + ((Horas-2)*2) ;
    TipoVeiculo == 'carro', Horas =< 2, IsDiaSemana == 1 -> Taxa is 6;
    TipoVeiculo == 'carro', Horas =< 2, IsDiaSemana == 0 -> Taxa is 8;
    TipoVeiculo == 'moto', Horas > 2, IsDiaSemana == 1 -> Taxa is 4 + ((Horas-2)*1) ;
    TipoVeiculo == 'moto', Horas > 2, IsDiaSemana == 0 -> Taxa is 6 + ((Horas-2)*1.5) ;
    TipoVeiculo == 'moto', Horas =< 2, IsDiaSemana == 1 -> Taxa is 4;
    TipoVeiculo == 'moto', Horas =< 2, IsDiaSemana == 0 -> Taxa is 6;
    TipoVeiculo == 'van', Horas > 2, IsDiaSemana == 1 -> Taxa is 8 + ((Horas-2)*2) ;
    TipoVeiculo == 'van', Horas > 2, IsDiaSemana == 0 -> Taxa is 10 + ((Horas-2)*2.5) ;
    TipoVeiculo == 'van', Horas =< 2, IsDiaSemana == 1 -> Taxa is 8;
    TipoVeiculo == 'van', Horas =< 2, IsDiaSemana == 0 -> Taxa is 10;
    true).

paga_estacionamento :-
    write('--- PAGAMENTO ---'),nl,
    write('Informe o numero do andar:'), input_line(AndarString),
    write('Informe o numero da vaga:'), input_line(VagaString),
    atom_number(AndarString, Andar),
    atom_number(VagaString, Vaga),
    consult('src/vagas.pl'),
    vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),
    (Status == 0 -> write('A vaga nao está ocupada, falha ao realizar o pagamento'),nl,menu;true),
    write('é Dia comercial? [0/1] '), input_line(WeekString),
    atom_number(WeekString, Week),
    taxa_pagamento(IdVaga, Week, Taxa),
    string_concatenation('O preço final é ', Taxa, Resultado),
    write(Resultado),nl,
    write('Faça o seu pagamento '), input_line(Valor),
    atom_number(Valor, ValorPago),
    Troco is ValorPago - Taxa,
    string_concatenation('Estacionamento não foi pago. O valor da taxa ', Taxa, Intermed),
    atom_concat(Intermed, ' é maior que o valor pago', Menor),
    string_concatenation('Seu troco é ', Troco, Maior),
    posix_time(Curr),
    (Troco < 0 -> write(Menor),nl,menu;
    Troco == 0 -> write('Estacionamento Pago com sucesso'),update_fact('src/vagas.pl',vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),vaga(0, Vaga, Andar,TipoVeiculo,Curr,IdVaga,'none')),nl,menu;
    Troco > 0 ->  write(Maior),update_fact('src/vagas.pl',vaga(Status, Vaga, Andar,TipoVeiculo,_,IdVaga,_),vaga(0, Vaga, Andar,TipoVeiculo,Curr,IdVaga,'none')),nl, menu).

string_concatenation(String, Int, Result) :-
    number_string(Int, IntString),
    atom_concat(String, IntString, Result).


tempo_vaga :- nl, write('tempo_vaga').