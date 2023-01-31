:- module(clienteService, [
    cadastra_cliente/1
    ]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2]).
:- use_module('menu.pl', [menu/0]).

cadastra_cliente(cpfCliente) :- 
    write('Insira o nome: '), input_line(nome),
    add_fact('src/cliente.pl', cliente(CpfCliente, nome)),
    menu.
