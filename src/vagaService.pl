:- module(vagaService, [
    vagasDisponiveis/0,
    vagasDisponiveisAndar/0,
    adicionaVaga/0,
    adicionaAndar/0,
    adicionaTempoVaga/0
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1]).
:- use_module('databaseManager.pl', [addFact/2]).

% vaga é dinamico pois clausulas serão removidas, adicionadas e atualizadas
:- dynamic vaga/7.

vagasDisponiveis :- write('vagasDisponiveis').

vagasDisponiveisAndar :- write('vagasDisponiveisAndar').

% adiciona vaga no banco de dados a partir de interação com o usuário
adicionaVaga :- 
    write('--- ADICIONAR VAGA ---'), nl,
    write('Dê os dados da vaga a ser adicionada:'), nl,
    write('Tipo de veículo: '), input_line(TipoVeiculo),
    write('Andar: '), input_line(AndarString),

    % calcular próximo número de vaga em andar que vaga será adicionada
    atom_number(AndarString, Andar),
    proxNumVaga(Andar, NumNovo),

    % checa se número de vagas no andar não é maior que 20k
    (NumNovo > 20 -> write('Número máximo de vagas no andar atingido!'), nl, menu ; true),

    % acessa posix time atual
    posixTime(Now),

    % gera id da vaga nova
    generateIdVaga(NumNovo, Andar, TipoVeiculo, IdVaga),

    % adiciona fato no banco de dados
    addFact('src/vagas.pl', vaga(0, NumNovo, Andar, TipoVeiculo, Now, IdVaga, 'none')),
    write('Vaga adicionada com sucesso!'), nl, menu.

% proxNumVaga(+Andar, -NumNovo)
% retorna próximo número de vaga do andar somando 1 no número mais alto
proxNumVaga(Andar, NumNovo) :-
    consult('src/vagas.pl'),
    findall(Num, vaga(_,Num,Andar,_,_,_,_), Vagas),
    (Vagas \= [] -> max_list(Vagas, Max), NumNovo is Max + 1 ; NumNovo is 1).

% posixTime(-Now)
% retorna posix time do momento em que é chamado em segundos
posixTime(Now) :- 
    get_time(NowFloat),
    Now is round(NowFloat).

% generateIdVaga(+NumVaga, +Andar, +TipoVeiculo, -Id)
% retorna id gerado a partir da concatenação 'NumVaga-TipoVeiculo-Andar'
generateIdVaga(NumVaga, Andar, TipoVeiculo, Id) :-
    number_string(NumVaga, NumVagaString),
    number_string(Andar, AndarString),
    string_concat(NumVagaString, '-', IdParte1),
    string_concat(IdParte1, TipoVeiculo, IdParte2),
    string_concat(IdParte2, '-', IdParte3),
    string_concat(IdParte3, AndarString, Id).

adicionaAndar :- write('adicionaAndar').
adicionaTempoVaga :- write('adicionaTempoVaga').