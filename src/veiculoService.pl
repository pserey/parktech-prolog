:- module(veiculoService, [
    cadastraVeiculo/1
    ]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2]).
:- use_module('menu.pl', [menu/0]).

cadastra_veiculo(placa) :- 
    write('Insira o tipo de veículo: '), input_line(tipo),
    write('Insira a cor do veículo: '), input_line(cor),
    add_fact('src/veiculo.pl', veiculo(tipo, placa, cor)),
    menu.
