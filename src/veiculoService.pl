:- module(veiculoService, [
    cadastra_veiculo/1,
    verifica_veiculo/1
    ]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2]).
:- use_module('menu.pl', [menu/0]).

:- dynamic veiculo/3.

cadastra_veiculo(placa) :- 
    write('Insira o tipo de veículo: '), input_line(tipo),
    write('Insira a cor do veículo: '), input_line(cor),
    add_fact('src/veiculo.pl', veiculo(tipo, placa, cor)),
    menu.

verifica_veiculo(Placa) :-
    consult('src/veiculos.pl'),
    veiculo(_, PlacaCompound, _),
    with_output_to(atom(Placa), write(PlacaCompound)).
    % file_to_facts('src/clientes.pl', Clientes),