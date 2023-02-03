:- module(veiculoService, [
    cadastra_veiculo/1,
    verifica_veiculo/1,
    get_tipo_veiculo/2
    ]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2]).
:- use_module('menu.pl', [menu/0]).

:- dynamic veiculo/3.

cadastra_veiculo(Placa) :- 
    write('Insira o tipo de veículo: '), input_line(Tipo),
    write('Insira a cor do veículo: '), input_line(Cor),
    add_fact('src/veiculos.pl', veiculo(Tipo, Placa, Cor)),
    menu.

verifica_veiculo(Placa) :-
    consult('src/veiculos.pl'),
    veiculo(_, Placa, _).

get_tipo_veiculo(Placa, Tipo) :-
    consult('src/veiculos.pl'),
    veiculo(Tipo, Placa, _).
