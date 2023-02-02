:- module(clienteService, [
    cadastra_cliente/1,
    verifica_cliente/1
    ]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2, file_to_facts/2]).
:- use_module('menu.pl', [menu/0]).

:- dynamic cliente/2.

cadastra_cliente(CpfCliente) :- 
    write('Insira o nome: '), input_line(nome),
    add_fact('src/cliente.pl', cliente(CpfCliente, nome)),
    menu.

verifica_cliente(CpfCliente) :-
    consult('src/clientes.pl'),
    cliente(CpfCliente, _).
    % file_to_facts('src/clientes.pl', Clientes),