% include('vagaService.pl').
% include('estacionamentoService.pl').
% use_module(vagaService).
% use_module(estacionamentoService).
% importar outros modulos não está funcionando

:- module(menu, [menu/0]).
:- use_module('vagaService.pl', [
    vagas_disponiveis/0,
    vagas_disponiveis_andar/0,
    adiciona_vaga/0,
    adiciona_andar/0,
    adiciona_tempo_vaga/0
    ]).
:- use_module('estacionamentoService.pl', [
    estaciona_veiculo/0,
    paga_estacionamento/0,
    tempo_vaga/0
    ]).
:- use_module('util.pl', [input_line/1]).
:- encoding(utf8).



menu :-
    write('--- FAÇA LOGIN ---'), nl,
    write('1. Sou cliente'), nl,
    write('2. Sou administrador'), nl,
    write('3. Sair do sistema'), nl,

    input_line(ChoiceString),
    atom_number(ChoiceString, Choice),
    (Choice = 1 -> menu_cliente;
    Choice = 2 -> menu_administrador; 
    Choice = 3 -> halt;
    menu).

menu_cliente :-
    write('--- BEM VINDO! ---'), nl,
    write('O estacionamento está funcionando! Escolha o que você quer fazer: '), nl,
    write('1 - Estacionar veículo'), nl,
    write('2 - Pagar estacionamento'), nl,
    write('3 - Ver vagas disponíveis'), nl,
    write('4 - Ver vagas disponíveis por andar'), nl,
    write('5 - Ver o tempo que está na vaga'), nl,
    write('6 - Voltar para o menu inicial'), nl,

    input_line(ChoiceString),
    atom_number(ChoiceString, Choice),
    (Choice = 1 -> estaciona_veiculo;
    Choice = 2 -> paga_estacionamento;
    Choice = 3 -> vagas_disponiveis;
    Choice = 4 -> vagas_disponiveis_andar;
    Choice = 5 -> tempo_vaga;
    Choice = 6 -> menu;
    menu_cliente).

menu_administrador :-
    write('--- BEM VINDO! ---'), nl,
    write('Escolha o que você quer fazer:'), nl,
    write('1 - Adicionar vaga'), nl,
    write('2 - Adicionar andar'), nl,
    write('3 - Adicionar tempo em vaga'), nl,
    write('4 - Voltar para o menu inicial'), nl,

    input_line(ChoiceString),
    atom_number(ChoiceString, Choice),
    (Choice = 1 -> adiciona_vaga;
    Choice = 2 -> adiciona_andar;
    Choice = 3 -> adiciona_tempo_vaga;
    Choice = 4 -> menu).