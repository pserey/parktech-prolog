:- module(vagaService, [
    vagas_disponiveis/0,
    vagas_disponiveis_andar/0,
    adiciona_vaga/0,
    adiciona_andar/0,
    adiciona_tempo_vaga/0,
    find_vaga_by_id/2,
    disponiibilidade_vaga/2,
    get_vaga_id/3,
    get_vaga_tipo/2,
    get_vagas_disponiveis_tipo/2,
    get_vaga_numero_andar/3,
    get_tempo_vaga/2,
    get_vaga_status/2
    ]).
:- use_module('menu.pl', [menu/0]).
:- use_module('util.pl', [input_line/1, posix_time/1]).
:- use_module('databaseManager.pl', [add_fact/2, read_file/2, update_fact/3]).
:- discontiguous vagaService:adiciona_vaga_andar/3.

% vaga é dinamico pois clausulas serão removidas, adicionadas e atualizadas
:- dynamic vaga/7.

% verifica a quantidade de vagas total no banco de dados a partir de interação com o usuário
vagas_disponiveis :-
    consult('src/vagas.pl'),
    findall(Status, vaga(Status, _, _, _, _, _, _), Statuses),
    count(0, Statuses, Available),
    write('Total de vagas disponíveis: '),
    write(Available), nl, menu.

% verifica a quantidade de vagas por andar no banco de dados a partir de interação com o usuário
vagas_disponiveis_andar :-
    write('Informe o andar: '),
    input_line(AndarString),
    atom_number(AndarString, Andar),
    consult('src/vagas.pl'),
    findall(Status, vaga(Status, _, Andar, _, _, _, _), Statuses),
    count(0, Statuses, Available),
    write('Total de vagas disponíveis no andar '), write(Andar), write(': '),
    write(Available), nl, menu.

count(_, [], 0).

count(Value, [Value|Tail], Count) :-
    !, count(Value, Tail, TailCount),
    Count is TailCount + 1.

count(Value, [_|Tail], Count) :-
    count(Value, Tail, Count).

% adiciona vaga no banco de dados a partir de interação com o usuário
adiciona_vaga :- 
    write('--- ADICIONAR VAGA ---'), nl,
    write('Dê os dados da vaga a ser adicionada:'), nl,
    write('Tipo de veículo: '), input_line(TipoVeiculo),
    write('Andar: '), input_line(AndarString),

    % calcular próximo número de vaga em andar que vaga será adicionada
    atom_number(AndarString, Andar),
    prox_num_vaga(Andar, NumNovo),

    % checa se número de vagas no andar não é maior que 20
    (NumNovo > 20 -> write('Número máximo de vagas no andar atingido!'), nl, menu ; true),

    % acessa posix time atual
    posix_time(Now),

    % gera id da vaga nova
    generate_id_vaga(NumNovo, Andar, TipoVeiculo, IdVaga),

    % adiciona fato no banco de dados
    add_fact('src/vagas.pl', vaga(0, NumNovo, Andar, TipoVeiculo, Now, IdVaga, "none")),
    write('Vaga adicionada com sucesso!'), nl, menu.

% prox_num_vaga(+Andar, -NumNovo)
% retorna próximo número de vaga do andar somando 1 no número mais alto
prox_num_vaga(Andar, NumNovo) :-
    consult('src/vagas.pl'),
    findall(Num, vaga(_,Num,Andar,_,_,_,_), Vagas),
    (Vagas \= [] -> max_list(Vagas, Max), NumNovo is Max + 1 ; NumNovo is 1).

% generate_id_vaga(+NumVaga, +Andar, +TipoVeiculo, -Id)
% retorna id gerado a partir da concatenação 'NumVaga-TipoVeiculo-Andar'
generate_id_vaga(NumVaga, Andar, TipoVeiculo, Id) :-
    atomic_list_concat([NumVaga, TipoVeiculo, Andar], '-', IdAtom),
    atom_string(IdAtom, Id).

adiciona_tempo_vaga :-
   write('--- FUNÇÃO PARA MODIFICAR O TEMPO DE UM VAGA PARA TESTES ---'),nl,
   write('Insira os dados da modificação'),nl,
   write('Número da vaga: '), input_line(VagaString),
   atom_number(VagaString, Vaga),
   write('Numero do andar: '), input_line(AndarString),
   atom_number(AndarString, Andar),
   write('Novo tempo: '), input_line(TempoString),
   atom_number(TempoString, NovoTempo),
   consult('src/vagas.pl'),
   vaga(Status,Vaga,Andar,TipoVeiculo,Tempo,IdVaga,Placa),
   NewTempo is NovoTempo+Tempo,
   update_fact('src/vagas.pl', vaga(Status,Vaga,Andar,TipoVeiculo,Tempo,IdVaga,Placa),vaga(Status,Vaga,Andar,TipoVeiculo,NewTempo,IdVaga,Placa)),
   write('Tempo adicionado com sucesso'), nl,menu.

% adiciona um andar ao estacionamento buscando o numero do ultimo andar criado. Ao cria-lo, cria mais 10 vagas, divididas entre carro, moto e van.
adiciona_andar :-
    consult('src/vagas.pl'),
    findall(Andar, vaga(_, _, Andar, _, _, _, _), Andares),
    (Andares \= [] -> max_list(Andares, Max), NewAndar is Max + 1; NewAndar is 1),
    write('Andar adicionado com sucesso: '), write(NewAndar), nl,
    adiciona_vaga_andar(NewAndar, 4, carro),
    adiciona_vaga_andar(NewAndar, 4, moto),
    adiciona_vaga_andar(NewAndar, 2, van),
    menu.
  
% funcao para adicionar as vagas de maneira correta ao se criar um novo andar.
adiciona_vaga_andar(_, 0, _).
adiciona_vaga_andar(Andar, Count, TipoVeiculo) :-
    % calcular próximo número de vaga em andar que vaga será adicionada
    prox_num_vaga(Andar, NumNovo),
    % acessa posix time atual
    posix_time(Now),
    % gera id da vaga nova
    generate_id_vaga(NumNovo, Andar, TipoVeiculo, IdVaga),
    % adiciona fato no banco de dados
    add_fact('src/vagas.pl', vaga(0, NumNovo,Andar, TipoVeiculo, Now, IdVaga, 'none')),
    NewCount is Count - 1,
    adiciona_vaga_andar(Andar, NewCount, TipoVeiculo).



% find_vaga_by_id(+ID, -Vaga)
% encontra vaga no database por id
find_vaga_by_id(ID, Vaga) :-
    open('src/vagas.pl', read, Stream),
    read_file(Stream, Vagas),
    close(Stream),
    find_vaga_by_id_list(Vagas, ID, Vaga), !.

% encontra vaga com id na lista e retorna o fato
find_vaga_by_id_list(List, ID, Vaga) :-
    member(Vaga, List),
    Vaga =.. [_,_,_,_,_,_,ID1,_],
    ID1 = ID.

disponiibilidade_vaga(Vaga, Andar) :-
    consult('src/vagas.pl'),
    vaga(0, Vaga, Andar, _, _, _, _), !.

get_vaga_id(Vaga, Andar, ID) :-
    consult('src/vagas.pl'),
    vaga(_, Vaga, Andar, _, _, ID, _), !.

get_vaga_tipo(ID, Tipo) :-
    consult('src/vagas.pl'),
    vaga(_, _, _, Tipo, _, ID, _), !.

get_vaga_status(ID,Status):-
    consult('src/vagas.pl'),
    vaga(Status, _, _, _, _, ID, _), !.

get_vaga_numero_andar(ID, Vaga, Andar) :-
    consult('src/vagas.pl'),
    vaga(_, Vaga, Andar, _, _, ID, _), !.

get_vagas_disponiveis_tipo(Tipo, Disponiveis) :-
    consult('src/vagas.pl'),
    findall(ID, vaga(0, _, _, Tipo, _, ID, _), Disponiveis).

get_tempo_vaga(ID, Tempo) :- 
    consult('src/vagas.pl'),
    vaga(_,_,_,_,Tempo,ID,_), !.

% funcao para adicionar as vagas de maneira correta ao se criar um novo andar.
adiciona_vaga_andar(_, 0, _).
adiciona_vaga_andar(Andar, Count, TipoVeiculo) :-
    % calcular próximo número de vaga em andar que vaga será adicionada
    prox_num_vaga(Andar, NumNovo),
    % acessa posix time atual
    posix_time(Now),
    % gera id da vaga nova
    generate_id_vaga(NumNovo, Andar, TipoVeiculo, IdVaga),
    % adiciona fato no banco de dados
    add_fact('src/vagas.pl', vaga(0, NumNovo,Andar, TipoVeiculo, Now, IdVaga, 'none')),
    NewCount is Count - 1,
    adiciona_vaga_andar(Andar, NewCount, TipoVeiculo).