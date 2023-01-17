% include('vagaService.pl').
% include('estacionamentoService.pl').
% use_module(vagaService).
% use_module(estacionamentoService).
% importar outros modulos não está funcionando

:- module(menu, [menu/0]).
:- use_module('vagaService.pl', [
    vagasDisponiveis/0,
    vagasDisponiveisAndar/0,
    adicionaVaga/0,
    adicionaAndar/0,
    adicionaTempoVaga/0
    ]).
:- use_module('estacionamentoService.pl', [
    estacionaVeiculo/0,
    pagaEstacionamento/0,
    tempoVaga/0
    ]).
:- encoding(utf8).



menu :-
    write('--- FAÇA LOGIN ---'), nl,
    write('1. Sou cliente'), nl,
    write('2. Sou administrador'), nl,
    write('3. Sair do sistema'), nl,

    read(Choice),
    (Choice = 1 -> menuCliente;
    Choice = 2 -> menuAdministrador; 
    Choice = 3 -> halt;
    menu).

menuCliente :-
    write('--- BEM VINDO! ---'), nl,
    write('O estacionamento está funcionando! Escolha o que você quer fazer: '), nl,
    write('1 - Estacionar veículo'), nl,
    write('2 - Pagar estacionamento'), nl,
    write('3 - Ver vagas disponíveis'), nl,
    write('4 - Ver vagas disponíveis por andar'), nl,
    write('5 - Ver o tempo que está na vaga'), nl,
    write('6 - Voltar para o menu inicial'),

    (Choice = 1 -> estacionaVeiculo;
    Choice = 2 -> pagaEstacionamento;
    Choice = 3 -> vagasDisponiveis;
    Choice = 4 -> vagasDisponiveisAndar;
    Choice = 5 -> tempoVaga;
    Choice = 6 -> menu;
    menuCliente).

menuAdministrador :-
    write('--- BEM VINDO! ---'), nl,
    write('Escolha o que você quer fazer:'), nl,
    write('1 - Adicionar vaga'), nl,
    write('2 - Adicionar andar'), nl,
    write('3 - Adicionar tempo em vaga'), nl,
    write('4 - Voltar para o menu inicial'),

    (Choice = 1 -> adicionaVaga;
    Choice = 2 -> adicionaAndar;
    Choice = 3 -> adicionaTempoVaga;
    Choice = 4 -> menu).